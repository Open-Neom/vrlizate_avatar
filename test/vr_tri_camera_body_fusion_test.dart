import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:vector_math/vector_math.dart';
import 'package:vrlizate_avatar/vrlizate_avatar.dart';

void main() {
  group('VrUltrasonicTofSolver (Inter-Smartphone Acoustic Ranging)', () {
    test('detects FMCW chirp arrival and solves clock-offset-free TW-ToF distance', () {
      const solver = VrUltrasonicTofSolver(
        sampleRateHz: 48000.0,
        ambientTemperatureCelsius: 20.0,
      );
      final upChirp = solver.generateLinearChirp();
      expect(upChirp.length, 480);

      // Simulate a 0.55 m acoustic distance between Joystick and Visor
      final c = VrUltrasonicTofSolver.speedOfSoundMetersPerSec(20.0);
      const trueDistanceMeters = 0.55;
      final propagationSamples = (trueDistanceMeters / c) * 48000.0; // ~76.9 samples

      // Embed chirp at sample lag 150 in simulated recording buffer
      final buffer = Float64List(1200);
      const trueLag = 150;
      for (var i = 0; i < upChirp.length; i++) {
        buffer[trueLag + i] = upChirp[i];
      }

      final detection = solver.detectChirpArrival(
        recordedPcm: buffer,
        referenceChirp: upChirp,
      );
      expect(detection.sampleIndex, closeTo(trueLag.toDouble(), 0.5));
      expect(detection.snrDb, greaterThan(15.0));

      // Verify BeepBeep TW-ToF cancels arbitrary clock offset (+50,000 samples on Visor)
      const clockOffsetSamples = 50000.0;
      const nAA = 100.0;
      final nAB = nAA + clockOffsetSamples + propagationSamples;
      final nBB = nAB + 2400.0; // 50 ms turnaround on Visor
      final nBA = (nBB - clockOffsetSamples) + propagationSamples;

      final rangeSample = solver.solveTwoWayTimeOfFlight(
        joystickSelfArrivalSample: nAA,
        joystickRemoteArrivalSample: nBA,
        visorRemoteArrivalSample: nAB,
        visorSelfArrivalSample: nBB,
        snrDb: detection.snrDb,
      );

      expect(rangeSample.isValidReach, isTrue);
      expect(rangeSample.distanceMeters, closeTo(trueDistanceMeters, 0.005));
    });
  });

  group('VrTriCameraBodyFusionEngine (3-Camera + Ultrasonic Body Pose & Scale)', () {
    test('calibrates user stature and head height from 3-camera + ultrasonic loop', () {
      final engine = VrTriCameraBodyFusionEngine(initialStatureMeters: 1.70);

      // Camera 3 (Joystick Front/Selfie): tilted upward +45° toward the Visor
      final joyFrontOrientation = Quaternion.axisAngle(
        Vector3(1.0, 0.0, 0.0),
        math.pi * 0.25,
      );
      final cam3 = VrCameraLandmarkFrame(
        role: VrCameraStreamRole.joystickFrontUpperBody,
        cameraOrientation: joyFrontOrientation,
        visorCenterUv: Vector2(0.5, 0.5),
        visorNormalizedWidth: 0.22,
      );

      // Ultrasonic TW-ToF measures 0.62 m between Joystick and Visor
      const ultrasonic = VrUltrasonicRangeSample(
        distanceMeters: 0.62,
        confidence: 0.98,
      );

      // Camera 2 (Joystick Rear): tilted downward -70° toward the floor & feet
      final joyRearOrientation = Quaternion.axisAngle(
        Vector3(1.0, 0.0, 0.0),
        -1.22,
      );
      final cam2 = VrCameraLandmarkFrame(
        role: VrCameraStreamRole.joystickRearFloor,
        cameraOrientation: joyRearOrientation,
        leftFootUv: Vector2(0.42, 0.52),
        rightFootUv: Vector2(0.58, 0.52),
        leftFootGrounded: true,
        rightFootGrounded: true,
      );

      // Camera 1 (Visor Front World): observes floor at 1.68 m
      final cam1 = VrCameraLandmarkFrame(
        role: VrCameraStreamRole.visorFrontWorld,
        cameraOrientation: Quaternion.identity(),
        observedFloorDistanceMeters: 1.68,
      );

      late VrFullBodyKinematicState state;
      for (var i = 0; i < 8; i++) {
        state = engine.update(
          dtSeconds: 0.1,
          visorFrontWorldFrame: cam1,
          joystickRearFloorFrame: cam2,
          joystickFrontUpperBodyFrame: cam3,
          ultrasonicRange: ultrasonic,
        );
      }

      expect(state.anthropometry.isCalibrated, isTrue);
      expect(state.headHeightMeters, greaterThan(1.45));
      expect(state.anthropometry.statureMeters, greaterThan(1.55));
      expect(state.headToJoystickDistanceMeters, closeTo(0.62, 0.08));
      expect(state.postureState, VrBodyPostureState.standing);
    });

    test('detects seated posture and foot walking swing from camera 2', () {
      final engine = VrTriCameraBodyFusionEngine(initialStatureMeters: 1.75)
        ..calibrateFromStandingHeadHeight(1.64);

      final joyRearOrientation = Quaternion.axisAngle(
        Vector3(1.0, 0.0, 0.0),
        -1.15,
      );

      // Simulate alternating foot steps in Camera 2
      final walkingState = engine.update(
        dtSeconds: 0.12,
        visorFrontWorldFrame: VrCameraLandmarkFrame(
          role: VrCameraStreamRole.visorFrontWorld,
          cameraOrientation: Quaternion.identity(),
          observedFloorDistanceMeters: 1.64,
        ),
        joystickRearFloorFrame: VrCameraLandmarkFrame(
          role: VrCameraStreamRole.joystickRearFloor,
          cameraOrientation: joyRearOrientation,
          leftFootUv: Vector2(0.40, 0.25),
          rightFootUv: Vector2(0.60, 0.78),
          leftFootGrounded: false,
          rightFootGrounded: true,
        ),
      );

      expect(walkingState.postureState, VrBodyPostureState.walking);
      expect(walkingState.locomotionVelocity.z, lessThan(0.0));
      expect(
        (walkingState.avatarPose.leftLegSwing -
                walkingState.avatarPose.rightLegSwing)
            .abs(),
        greaterThan(0.05),
      );

      // Now simulate sitting down (head height drops to 1.15 m)
      late VrFullBodyKinematicState seatedState;
      for (var i = 0; i < 10; i++) {
        seatedState = engine.update(
          dtSeconds: 0.15,
          visorFrontWorldFrame: VrCameraLandmarkFrame(
            role: VrCameraStreamRole.visorFrontWorld,
            cameraOrientation: Quaternion.identity(),
            observedFloorDistanceMeters: 1.15,
          ),
        );
      }

      expect(seatedState.postureState, VrBodyPostureState.seated);
      expect(seatedState.avatarPose.sit, greaterThan(0.8));
    });
  });
}
