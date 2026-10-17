import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:vrlizate_avatar/vrlizate_avatar.dart';

void main() {
  group('VrAvatarPose & VrShoulderKinematics', () {
    test('walk, seated, wave, blink, and lerp work deterministically', () {
      final walk = VrAvatarPose.walk(math.pi / 2, amplitude: 0.6);
      expect(walk.leftLegSwing, closeTo(0.6, 1e-6));
      expect(walk.rightLegSwing, closeTo(-0.6, 1e-6));
      expect(walk.leftArmFlexion, closeTo(-0.36, 1e-6));
      expect(walk.rightArmFlexion, closeTo(0.36, 1e-6));

      final seated = VrAvatarPose.seated(sit: 1.0, blink: 1.0);
      expect(seated.sit, 1.0);
      expect(seated.eyeScaleY, closeTo(0.15, 1e-6));

      final wave = VrAvatarPose.wave(0.25, leftHand: false, waveAmount: 1.0);
      expect(wave.rightArmAbduction, greaterThan(1.0));
      expect(wave.rightArmFlexion, closeTo(0.85, 1e-6));

      final blended = VrAvatarPose.lerp(VrAvatarPose.neutral, seated, 0.5);
      expect(blended.sit, closeTo(0.5, 1e-6));
      expect(blended.blink, closeTo(0.5, 1e-6));
    });

    test('clavicle rise and forward shift increase with arm elevation', () {
      expect(
        VrShoulderKinematics.clavicleRiseMeters(flexion: 0, abduction: 0),
        0.0,
      );
      final raised = VrShoulderKinematics.clavicleRiseMeters(
        flexion: 1.0,
        abduction: 1.2,
        heightMeters: 1.5,
      );
      final forward = VrShoulderKinematics.clavicleForwardMeters(
        flexion: 1.0,
        abduction: 1.2,
        heightMeters: 1.5,
      );
      expect(raised, greaterThan(0.015));
      expect(forward, greaterThan(0.008));
    });
  });
}
