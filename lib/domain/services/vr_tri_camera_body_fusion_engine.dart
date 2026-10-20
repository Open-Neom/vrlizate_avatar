import 'dart:math' as math;

import 'package:vector_math/vector_math.dart';

import '../../utils/constants/vr_avatar_constants.dart';
import '../../utils/enums/vr_accessibility_posture_mode.dart';
import '../../utils/enums/vr_body_posture_state.dart';
import '../models/vr_accessibility_profile.dart';
import '../models/vr_avatar_pose.dart';
import '../models/vr_camera_landmark_frame.dart';
import '../models/vr_full_body_kinematic_state.dart';
import '../models/vr_ultrasonic_range_sample.dart';
import '../models/vr_user_anthropometry.dart';

/// Real-time sensor-fusion engine that combines the **3 Smartphone Cameras**,
/// **2 IMUs**, and **Ultrasonic Inter-Device Ranging** to solve:
///
/// 1. **User Stature & Anthropometry ($H_{\text{user}}$):**
///    By closing the vertical kinematic loop from the Floor ($y=0$) through the
///    Joystick Rear Camera ($H_{\text{joy}}$) and the Joystick Front Camera +
///    Ultrasonic ToF ($\Delta H_{\text{head}-\text{joy}}$) up to the Visor
///    ($H_{\text{head}} = H_{\text{joy}} + \Delta H_{\text{head}-\text{joy}}$),
///    cross-validated against the Visor Front World Camera (`visorFrontWorld`).
/// 2. **Head Height ($H_{\text{head}}$) & Posture (`standing`, `walking`, `crouching`, `seated`, `jumping`):**
///    Tracks physical head elevation relative to the calibrated standing eye height,
///    with optional universal accessibility compensation (`seatedWheelchair`
///    virtual eye-height boost and `oneHandedReach` reach multiplier).
/// 3. **6DoF Joystick / Arm Kinematics ($\mathbf{p}_{\text{joy}} - \mathbf{p}_{\text{head}}$):**
///    Combines the direction ray from Camera 3 (`joystickFrontUpperBody`) with
///    the metric ultrasonic range $r_{\text{acoustic}}$ (and monocular visor width)
///    to solve shoulder flexion and abduction angles (`leftArmFlexion`, `rightArmFlexion`, etc.).
/// 4. **3D Foot Tracking & Locomotion ($\mathbf{p}_{\text{foot},L}, \mathbf{p}_{\text{foot},R}$):**
///    Intersects the rays from Camera 2 (`joystickRearFloor`) with the ground
///    plane at depth $-H_{\text{joy}}$ to track left/right foot swing and walking cadence.
class VrTriCameraBodyFusionEngine {
  VrTriCameraBodyFusionEngine({
    double initialStatureMeters = VrAvatarConstants.defaultUserStatureMeters,
    this.accessibilityProfile = const VrAccessibilityProfile.standard(),
  }) : _anthropometry = VrUserAnthropometry.fromStature(initialStatureMeters),
       _smoothedHeadHeightMeters =
           initialStatureMeters - VrAvatarConstants.eyeToCrownOffsetMeters,
       _smoothedJoystickHeightMeters =
           (initialStatureMeters - VrAvatarConstants.eyeToCrownOffsetMeters) *
           VrAvatarConstants.defaultJoystickToEyeHeightRatio;

  VrAccessibilityProfile accessibilityProfile;
  VrUserAnthropometry _anthropometry;
  double _smoothedHeadHeightMeters;
  double _smoothedJoystickHeightMeters;
  Vector3 _smoothedJoystickRelHead = Vector3(
    0.0,
    VrAvatarConstants.defaultJoystickRelHeadY,
    VrAvatarConstants.defaultJoystickRelHeadZ,
  );
  Vector3 _smoothedLeftFoot = Vector3(
    -VrAvatarConstants.defaultFootLateralOffsetMeters,
    0.0,
    0.0,
  );
  Vector3 _smoothedRightFoot = Vector3(
    VrAvatarConstants.defaultFootLateralOffsetMeters,
    0.0,
    0.0,
  );
  double _stridePhaseRadians = 0.0;
  int _standingCalibrationSamples = 0;

  VrUserAnthropometry get anthropometry => _anthropometry;

  /// Explicitly calibrates user anthropometry from a measured standing head height.
  void calibrateFromStandingHeadHeight(double headHeightMeters) {
    _anthropometry = VrUserAnthropometry.fromStandingHeadHeight(
      headHeightMeters,
      isCalibrated: true,
      calibrationConfidence: 1.0,
    );
    _smoothedHeadHeightMeters = _anthropometry.standingEyeHeightMeters;
  }

  /// Advances the tri-camera + ultrasonic fusion filter by [dtSeconds] and
  /// returns the solved [VrFullBodyKinematicState].
  VrFullBodyKinematicState update({
    required double dtSeconds,
    VrCameraLandmarkFrame? visorFrontWorldFrame,
    VrCameraLandmarkFrame? joystickRearFloorFrame,
    VrCameraLandmarkFrame? joystickFrontUpperBodyFrame,
    VrUltrasonicRangeSample? ultrasonicRange,
    bool isOneHandedLaserMode = false,
  }) {
    final dt = dtSeconds.clamp(
      VrAvatarConstants.minFilterDtSeconds,
      VrAvatarConstants.maxFilterDtSeconds,
    );
    final blend = (dt * VrAvatarConstants.filterBlendRateHz).clamp(
      VrAvatarConstants.minFilterBlendFactor,
      1.0,
    );

    // -------------------------------------------------------------------------
    // STEP 1: Solve 3D vector between Joystick and Head (Camera 3 + Ultrasonic)
    // -------------------------------------------------------------------------
    var headToJoyDistance = _smoothedJoystickRelHead.length;
    if (ultrasonicRange != null && ultrasonicRange.isValidReach) {
      // Ultrasonic TW-ToF gives high-precision metric distance (±1-2 cm)
      if (joystickFrontUpperBodyFrame?.visorNormalizedWidth != null &&
          joystickFrontUpperBodyFrame!.visorNormalizedWidth! >
              VrAvatarConstants.minVisorNormalizedWidth) {
        final visualDist = _monocularVisorDistance(joystickFrontUpperBodyFrame);
        // Fuse 80% ultrasonic ToF + 20% visual apparent visor width
        headToJoyDistance =
            ultrasonicRange.distanceMeters *
                VrAvatarConstants.ultrasonicRangeFusionWeight +
            visualDist * VrAvatarConstants.visualVisorDistanceFusionWeight;
      } else {
        headToJoyDistance = ultrasonicRange.distanceMeters;
      }
    } else if (joystickFrontUpperBodyFrame?.visorNormalizedWidth != null &&
        joystickFrontUpperBodyFrame!.visorNormalizedWidth! >
            VrAvatarConstants.minVisorNormalizedWidth) {
      headToJoyDistance = _monocularVisorDistance(joystickFrontUpperBodyFrame);
    }

    Vector3 targetJoyRelHead = _smoothedJoystickRelHead.clone();
    if (joystickFrontUpperBodyFrame != null &&
        joystickFrontUpperBodyFrame.visorCenterUv != null) {
      // Ray from Joystick Front Camera pointing up toward the Visor/Head
      final rayJoyToHead = joystickFrontUpperBodyFrame.worldRayForUv(
        joystickFrontUpperBodyFrame.visorCenterUv!,
      );
      // Vector from Head to Joystick is opposite to rayJoyToHead
      targetJoyRelHead = -rayJoyToHead * headToJoyDistance;
      // Ensure physically plausible vertical & forward quadrant when looking up
      if (targetJoyRelHead.y > VrAvatarConstants.maxJoyAboveHeadFlipThresholdY) {
        targetJoyRelHead.y = -targetJoyRelHead.y.abs();
      }
    } else if (visorFrontWorldFrame != null &&
        visorFrontWorldFrame.observedJoystickUvInVisor != null) {
      // Ray from Visor Front Camera down toward the Joystick
      final rayHeadToJoy = visorFrontWorldFrame.worldRayForUv(
        visorFrontWorldFrame.observedJoystickUvInVisor!,
      );
      targetJoyRelHead = rayHeadToJoy * headToJoyDistance;
    } else if (ultrasonicRange != null && ultrasonicRange.isValidReach) {
      final dir = _smoothedJoystickRelHead.length > 1e-4
          ? _smoothedJoystickRelHead.normalized()
          : Vector3(0.0, -0.75, -0.66);
      targetJoyRelHead = dir * headToJoyDistance;
    }

    _smoothedJoystickRelHead =
        _smoothedJoystickRelHead * (1.0 - blend) + targetJoyRelHead * blend;
    final deltaHeadMinusJoyY = (-_smoothedJoystickRelHead.y).clamp(
      VrAvatarConstants.minHeadToJoyVerticalMeters,
      VrAvatarConstants.maxHeadToJoyVerticalMeters,
    );
    final joyHorizontalForwardDist = math.max(
      VrAvatarConstants.minJoyHorizontalForwardMeters,
      math.sqrt(
        _smoothedJoystickRelHead.x * _smoothedJoystickRelHead.x +
            _smoothedJoystickRelHead.z * _smoothedJoystickRelHead.z,
      ),
    );

    // -------------------------------------------------------------------------
    // STEP 2: Solve Joystick Height above Floor H_joy (Camera 2 -> Floor & Feet)
    // -------------------------------------------------------------------------
    var estimatedJoyHeight = _smoothedJoystickHeightMeters;
    var hasCamera2FloorEstimate = false;

    if (joystickRearFloorFrame != null) {
      final leftUv = joystickRearFloorFrame.leftFootUv;
      final rightUv = joystickRearFloorFrame.rightFootUv;
      final footMidUv = (leftUv != null && rightUv != null)
          ? (leftUv + rightUv) * 0.5
          : (leftUv ?? rightUv);

      if (footMidUv != null) {
        final footRay = joystickRearFloorFrame.worldRayForUv(footMidUv);
        // The ray points downward toward the ankles on the floor (footRay.y < 0).
        final horizMag = math.sqrt(
          footRay.x * footRay.x + footRay.z * footRay.z,
        );
        if (footRay.y < VrAvatarConstants.minFootDepressionRayY &&
            horizMag > 1e-4) {
          final tanDepression = (-footRay.y) / horizMag;
          // Horizontal distance from the held controller to the ankle column
          estimatedJoyHeight = (joyHorizontalForwardDist * tanDepression).clamp(
            VrAvatarConstants.minCamera2JoyHeightMeters,
            VrAvatarConstants.maxCamera2JoyHeightMeters,
          );
          hasCamera2FloorEstimate = true;
        }
      }
    }

    // -------------------------------------------------------------------------
    // STEP 3: Fuse with Camera 1 (Visor World Camera) to Solve Head Height H_head
    //         and Calibrate User Stature H_user
    // -------------------------------------------------------------------------
    final chainHeadHeight = estimatedJoyHeight + deltaHeadMinusJoyY;
    double targetHeadHeight;

    if (visorFrontWorldFrame?.observedFloorDistanceMeters != null &&
        visorFrontWorldFrame!.observedFloorDistanceMeters! >
            VrAvatarConstants.minVisorFloorDistanceMeters) {
      final visorFloorDist = visorFrontWorldFrame.observedFloorDistanceMeters!;
      if (hasCamera2FloorEstimate) {
        // Closed-loop fusion of Camera 1 (Visor->Floor) and Camera 2+3+Ultrasonic chain
        targetHeadHeight =
            visorFloorDist * VrAvatarConstants.visorFloorFusionWeight +
            chainHeadHeight * VrAvatarConstants.chainFloorFusionWeight;
        estimatedJoyHeight = (targetHeadHeight - deltaHeadMinusJoyY).clamp(
          VrAvatarConstants.minFusedJoyHeightMeters,
          VrAvatarConstants.maxCamera2JoyHeightMeters,
        );
      } else {
        targetHeadHeight = visorFloorDist;
        estimatedJoyHeight = (targetHeadHeight - deltaHeadMinusJoyY).clamp(
          VrAvatarConstants.minFusedJoyHeightMeters,
          VrAvatarConstants.maxCamera2JoyHeightMeters,
        );
      }
    } else if (hasCamera2FloorEstimate) {
      targetHeadHeight = chainHeadHeight;
    } else {
      targetHeadHeight = _smoothedHeadHeightMeters;
    }

    final prevHeadHeight = _smoothedHeadHeightMeters;
    _smoothedHeadHeightMeters =
        _smoothedHeadHeightMeters * (1.0 - blend) + targetHeadHeight * blend;
    _smoothedJoystickHeightMeters =
        _smoothedJoystickHeightMeters * (1.0 - blend) +
        estimatedJoyHeight * blend;
    final verticalHeadVelocity =
        (_smoothedHeadHeightMeters - prevHeadHeight) / dt;

    // Auto-calibrate standing stature when both feet are grounded and upright
    final bothFeetGrounded =
        (joystickRearFloorFrame?.leftFootGrounded ?? true) &&
        (joystickRearFloorFrame?.rightFootGrounded ?? true);
    if (bothFeetGrounded &&
        (hasCamera2FloorEstimate ||
            visorFrontWorldFrame?.observedFloorDistanceMeters != null) &&
        _smoothedHeadHeightMeters >=
            VrAvatarConstants.minCalibrationStandingEyeHeightMeters &&
        _smoothedHeadHeightMeters <=
            VrAvatarConstants.maxCalibrationStandingEyeHeightMeters &&
        verticalHeadVelocity.abs() <
            VrAvatarConstants.maxCalibrationVerticalVelocityMetersPerSec) {
      if (!_anthropometry.isCalibrated ||
          _smoothedHeadHeightMeters >
              _anthropometry.standingEyeHeightMeters +
                  VrAvatarConstants.calibrationHeightGainMarginMeters) {
        _standingCalibrationSamples++;
        final conf =
            (_standingCalibrationSamples /
                    VrAvatarConstants.calibrationTargetSampleCount)
                .clamp(VrAvatarConstants.minCalibrationConfidence, 1.0);
        final blendedEyeHeight = _anthropometry.isCalibrated
            ? (_anthropometry.standingEyeHeightMeters *
                      VrAvatarConstants.calibratedHeightRetentionWeight +
                  _smoothedHeadHeightMeters *
                      VrAvatarConstants.calibratedHeightUpdateWeight)
            : _smoothedHeadHeightMeters;
        _anthropometry = VrUserAnthropometry.fromStandingHeadHeight(
          blendedEyeHeight,
          isCalibrated: true,
          calibrationConfidence: conf,
        );
      }
    }

    // -------------------------------------------------------------------------
    // STEP 4: Solve 3D Foot Positions & Gait Swing from Camera 2 (Joystick Rear)
    // -------------------------------------------------------------------------
    var leftFootPos = _smoothedLeftFoot.clone();
    var rightFootPos = _smoothedRightFoot.clone();

    if (joystickRearFloorFrame != null) {
      final joyWorldPos = Vector3(
        _smoothedJoystickRelHead.x,
        _smoothedJoystickHeightMeters,
        _smoothedJoystickRelHead.z,
      );
      final centerRay = joystickRearFloorFrame.worldRayForUv(
        Vector2(0.5, 0.5),
      );
      if (joystickRearFloorFrame.leftFootUv != null) {
        leftFootPos = _projectFootRayToGround(
          joyWorldPos: joyWorldPos,
          centerRay: centerRay,
          ray: joystickRearFloorFrame.worldRayForUv(
            joystickRearFloorFrame.leftFootUv!,
          ),
          grounded: joystickRearFloorFrame.leftFootGrounded,
          defaultLateralOffset: -VrAvatarConstants.defaultFootLateralOffsetMeters,
        );
      }
      if (joystickRearFloorFrame.rightFootUv != null) {
        rightFootPos = _projectFootRayToGround(
          joyWorldPos: joyWorldPos,
          centerRay: centerRay,
          ray: joystickRearFloorFrame.worldRayForUv(
            joystickRearFloorFrame.rightFootUv!,
          ),
          grounded: joystickRearFloorFrame.rightFootGrounded,
          defaultLateralOffset: VrAvatarConstants.defaultFootLateralOffsetMeters,
        );
      }
    }

    final prevLeftZ = _smoothedLeftFoot.z;
    final prevRightZ = _smoothedRightFoot.z;
    _smoothedLeftFoot =
        _smoothedLeftFoot * (1.0 - blend) + leftFootPos * blend;
    _smoothedRightFoot =
        _smoothedRightFoot * (1.0 - blend) + rightFootPos * blend;

    // Leg swing angles (radians) from anteroposterior foot offset relative to hip
    final legLen = math.max(
      VrAvatarConstants.minEffectiveLegLengthMeters,
      _anthropometry.legLengthMeters,
    );
    final leftLegSwing = (-_smoothedLeftFoot.z / legLen).clamp(
      -VrAvatarConstants.maxLegSwingRadians,
      VrAvatarConstants.maxLegSwingRadians,
    );
    final rightLegSwing = (-_smoothedRightFoot.z / legLen).clamp(
      -VrAvatarConstants.maxLegSwingRadians,
      VrAvatarConstants.maxLegSwingRadians,
    );

    final footDeltaSpeed =
        ((_smoothedLeftFoot.z - prevLeftZ).abs() +
            (_smoothedRightFoot.z - prevRightZ).abs()) /
        dt;
    final isStepping =
        !(joystickRearFloorFrame?.leftFootGrounded ?? true) ||
        !(joystickRearFloorFrame?.rightFootGrounded ?? true) ||
        (leftLegSwing - rightLegSwing).abs() >
            VrAvatarConstants.steppingSwingDiffThresholdRadians ||
        footDeltaSpeed > VrAvatarConstants.steppingFootSpeedThresholdMetersPerSec;

    if (isStepping) {
      _stridePhaseRadians =
          (_stridePhaseRadians +
              dt * VrAvatarConstants.stridePhaseAngularVelocityRadPerSec) %
          (2.0 * math.pi);
    }

    final forwardWalkSpeed = isStepping
        ? ((leftLegSwing - rightLegSwing).abs() *
                      VrAvatarConstants.walkSpeedSwingScale +
                  footDeltaSpeed * VrAvatarConstants.walkSpeedFootVelocityScale)
              .clamp(0.0, VrAvatarConstants.maxWalkSpeedMetersPerSec)
        : 0.0;
    final locomotionVelocity = Vector3(0.0, 0.0, -forwardWalkSpeed);

    // -------------------------------------------------------------------------
    // STEP 5: Apply Universal Accessibility Compensation & Solve Posture/Arm IK
    // -------------------------------------------------------------------------
    final effectiveHeadHeightMeters = accessibilityProfile
        .applyEyeHeightCompensation(_smoothedHeadHeightMeters);
    final compensatedJoyRelHead = accessibilityProfile.applyReachCompensation(
      _smoothedJoystickRelHead,
    );
    final effectiveOneHanded =
        isOneHandedLaserMode ||
        accessibilityProfile.postureMode ==
            VrAccessibilityPostureMode.oneHandedReach;

    final heightRatio =
        _smoothedHeadHeightMeters /
        math.max(1.0, _anthropometry.standingEyeHeightMeters);

    final VrBodyPostureState posture;
    if (accessibilityProfile.postureMode ==
        VrAccessibilityPostureMode.seatedWheelchair) {
      posture = VrBodyPostureState.seated;
    } else if (_smoothedHeadHeightMeters -
                _anthropometry.standingEyeHeightMeters >
            VrAvatarConstants.jumpHeightDeltaThresholdMeters ||
        verticalHeadVelocity >
            VrAvatarConstants.jumpVerticalVelocityThresholdMetersPerSec) {
      posture = VrBodyPostureState.jumping;
    } else if (heightRatio <= VrAvatarConstants.seatedHeightRatioThreshold) {
      posture = VrBodyPostureState.seated;
    } else if (heightRatio <= VrAvatarConstants.crouchingHeightRatioThreshold) {
      posture = VrBodyPostureState.crouching;
    } else if (isStepping) {
      posture = VrBodyPostureState.walking;
    } else {
      posture = VrBodyPostureState.standing;
    }

    final sitFactor =
        ((VrAvatarConstants.crouchingHeightRatioThreshold - heightRatio) /
                (VrAvatarConstants.crouchingHeightRatioThreshold -
                    VrAvatarConstants.seatedHeightRatioThreshold))
            .clamp(0.0, 1.0);

    // Arm flexion & abduction from compensated 3D Joystick position relative to shoulders
    final shoulderDrop =
        VrAvatarConstants.shoulderDropToStatureRatio *
        _anthropometry.statureMeters;
    final handRelShoulderY = compensatedJoyRelHead.y + shoulderDrop;
    final handForwardDist = math.max(
      VrAvatarConstants.minHandForwardDistanceMeters,
      -compensatedJoyRelHead.z,
    );
    final armElevationAngle =
        math.atan2(handRelShoulderY, handForwardDist) +
        (math.pi * VrAvatarConstants.armElevationBiasPiFraction);
    final clampedFlexion = armElevationAngle.clamp(
      VrAvatarConstants.minArmFlexionRadians,
      VrAvatarConstants.maxArmFlexionRadians,
    );
    final lateralOffset = compensatedJoyRelHead.x;
    final rightAbduction =
        (lateralOffset * VrAvatarConstants.armAbductionLateralGain).clamp(
          VrAvatarConstants.minArmAbductionRadians,
          VrAvatarConstants.maxArmAbductionRadians,
        );
    final leftAbduction = effectiveOneHanded
        ? VrAvatarConstants.oneHandedIdleLeftAbductionRadians
        : (-lateralOffset * VrAvatarConstants.armAbductionLateralGain).clamp(
            VrAvatarConstants.minArmAbductionRadians,
            VrAvatarConstants.maxArmAbductionRadians,
          );
    final leftFlexion = effectiveOneHanded
        ? (-rightLegSwing * VrAvatarConstants.oneHandedCounterSwingFactor)
        : clampedFlexion;

    final avatarPose = VrAvatarPose(
      sit: sitFactor,
      lean: posture == VrBodyPostureState.crouching
          ? VrAvatarConstants.crouchingLeanRadians
          : VrAvatarConstants.standingLeanRadians,
      bob: isStepping
          ? math.sin(_stridePhaseRadians * 2.0).abs() *
                VrAvatarConstants.walkingBobAmplitudeMeters
          : 0.0,
      leftArmFlexion: leftFlexion,
      leftArmAbduction: leftAbduction,
      rightArmFlexion: clampedFlexion,
      rightArmAbduction: rightAbduction,
      leftLegSwing: leftLegSwing,
      rightLegSwing: rightLegSwing,
    );

    return VrFullBodyKinematicState(
      headHeightMeters: effectiveHeadHeightMeters,
      joystickHeightMeters: _smoothedJoystickHeightMeters,
      headToJoystickVerticalMeters: deltaHeadMinusJoyY,
      headToJoystickDistanceMeters: compensatedJoyRelHead.length,
      joystickPositionRelativeToHead: compensatedJoyRelHead,
      leftFootPosition: _smoothedLeftFoot.clone(),
      rightFootPosition: _smoothedRightFoot.clone(),
      locomotionVelocity: locomotionVelocity,
      postureState: posture,
      anthropometry: _anthropometry,
      avatarPose: avatarPose,
      stridePhaseRadians: _stridePhaseRadians,
    );
  }

  double _monocularVisorDistance(VrCameraLandmarkFrame frame) {
    final normWidth =
        (frame.visorNormalizedWidth ??
                VrAvatarConstants.defaultFallbackVisorNormalizedWidth)
            .clamp(
              VrAvatarConstants.minClampedVisorNormalizedWidth,
              VrAvatarConstants.maxClampedVisorNormalizedWidth,
            );
    final halfFovTan = math.tan(frame.horizontalFovRadians * 0.5);
    final dist =
        VrAvatarConstants.defaultVisorPhysicalWidthMeters /
        (2.0 * normWidth * halfFovTan);
    return dist.clamp(
      VrAvatarConstants.minValidAcousticDistanceMeters,
      VrAvatarConstants.maxValidAcousticDistanceMeters,
    );
  }

  Vector3 _projectFootRayToGround({
    required Vector3 joyWorldPos,
    required Vector3 centerRay,
    required Vector3 ray,
    required bool grounded,
    required double defaultLateralOffset,
  }) {
    final footPlaneY = grounded
        ? 0.0
        : VrAvatarConstants.liftedFootPlaneHeightMeters;
    if (ray.y >= VrAvatarConstants.minGroundProjectionRaySlopeY ||
        centerRay.y >= VrAvatarConstants.minGroundProjectionRaySlopeY) {
      return Vector3(defaultLateralOffset, footPlaneY, 0.0);
    }
    final tCenter = ((0.0 - joyWorldPos.y) / centerRay.y).clamp(
      VrAvatarConstants.minFootRayDistanceMeters,
      VrAvatarConstants.maxFootRayDistanceMeters,
    );
    final centerHit = joyWorldPos + centerRay * tCenter;

    final tFoot = ((footPlaneY - joyWorldPos.y) / ray.y).clamp(
      VrAvatarConstants.minFootRayDistanceMeters,
      VrAvatarConstants.maxFootRayDistanceMeters,
    );
    final footHit = joyWorldPos + ray * tFoot;
    final rel = footHit - centerHit;

    return Vector3(
      rel.x.clamp(
        -VrAvatarConstants.maxFootLateralReachMeters,
        VrAvatarConstants.maxFootLateralReachMeters,
      ),
      footPlaneY,
      rel.z.clamp(
        -VrAvatarConstants.maxFootForwardReachMeters,
        VrAvatarConstants.maxFootForwardReachMeters,
      ),
    );
  }
}
