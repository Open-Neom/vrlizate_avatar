import 'dart:math' as math;

import 'package:flutter/foundation.dart';

import '../../utils/enums/vr_avatar_emote.dart';
import 'vr_avatar_pose.dart';

/// Computes animated head/hand pose offsets and voice amplitude mouth openness
/// for a given [VrAvatarEmote] and [elapsedSeconds].
@immutable
class VrAvatarEmoteState {
  factory VrAvatarEmoteState({
    required VrAvatarEmote emote,
    required double elapsedSeconds,
    double voiceAmplitude = 0.0,
    VrAvatarPose basePose = VrAvatarPose.neutral,
  }) => VrAvatarEmoteState.evaluate(
    emote: emote,
    elapsedSeconds: elapsedSeconds,
    voiceAmplitude: voiceAmplitude,
    basePose: basePose,
  );

  const VrAvatarEmoteState._({
    required this.emote,
    required this.elapsedSeconds,
    required this.voiceAmplitude,
    required this.pose,
    required this.mouthOpenness,
    required this.headPitchOffset,
    required this.headYawOffset,
    required this.leftHandHeightOffset,
    required this.rightHandHeightOffset,
  });

  factory VrAvatarEmoteState.evaluate({
    required VrAvatarEmote emote,
    required double elapsedSeconds,
    double voiceAmplitude = 0.0,
    VrAvatarPose basePose = VrAvatarPose.neutral,
  }) {
    final safeTime = elapsedSeconds.isFinite && elapsedSeconds > 0
        ? elapsedSeconds
        : 0.0;
    final clampedVoice = voiceAmplitude.isFinite
        ? voiceAmplitude.clamp(0.0, 1.0)
        : 0.0;
    final phase = safeTime * 2.0 * math.pi;

    double headPitch = 0.0;
    double headYaw = 0.0;
    double headRoll = 0.0;
    double leftFlex = 0.0;
    double leftAbd = 0.0;
    double rightFlex = 0.0;
    double rightAbd = 0.0;
    double bob = 0.0;
    double leftHandHeight = 0.0;
    double rightHandHeight = 0.0;
    double emoteMouth = 0.0;

    switch (emote) {
      case VrAvatarEmote.neutral:
        headPitch = math.sin(phase * 0.25) * 0.015;
      case VrAvatarEmote.wave:
        final wag = math.sin(phase * 2.0) * 0.28;
        headRoll = 0.06;
        rightFlex = 0.85;
        rightAbd = 1.15 + wag;
        rightHandHeight = 0.36 + 0.05 * math.sin(phase * 2.0);
        emoteMouth = 0.2;
      case VrAvatarEmote.nod:
        headPitch = (0.14 + 0.14 * math.sin(phase * 1.8));
        headYaw = math.sin(phase * 0.9) * 0.03;
      case VrAvatarEmote.cheer:
        final pulse = (math.sin(phase * 2.2) + 1.0) * 0.5;
        bob = pulse * 0.045;
        headPitch = -0.10 - 0.06 * pulse;
        leftFlex = 1.05 + 0.20 * pulse;
        rightFlex = 1.05 + 0.20 * pulse;
        leftAbd = 1.25 + 0.15 * pulse;
        rightAbd = 1.25 + 0.15 * pulse;
        leftHandHeight = 0.45 + 0.12 * pulse;
        rightHandHeight = 0.45 + 0.12 * pulse;
        emoteMouth = 0.45 + 0.35 * pulse;
      case VrAvatarEmote.point:
        headYaw = -0.05;
        rightFlex = 1.35;
        rightAbd = 0.18;
        rightHandHeight = 0.28;
      case VrAvatarEmote.speaking:
        final syllable = (math.sin(phase * 3.2) + 1.0) * 0.5;
        headPitch = math.sin(phase * 1.1) * 0.05;
        headYaw = math.cos(phase * 0.7) * 0.06;
        leftFlex = 0.22 + 0.12 * syllable;
        rightFlex = 0.26 + 0.14 * (1.0 - syllable);
        leftAbd = 0.14;
        rightAbd = 0.14;
        leftHandHeight = 0.08 * syllable;
        rightHandHeight = 0.08 * (1.0 - syllable);
        emoteMouth = math.max(clampedVoice, 0.25 + 0.55 * syllable);
    }

    final mouthOpenness = math.max(clampedVoice, emoteMouth).clamp(0.0, 1.0);
    final pose = basePose.copyWith(
      bob: basePose.bob + bob,
      nod: basePose.nod + headPitch,
      look: basePose.look + headYaw,
      tilt: basePose.tilt + headRoll,
      leftArmFlexion: basePose.leftArmFlexion + leftFlex,
      leftArmAbduction: basePose.leftArmAbduction + leftAbd,
      rightArmFlexion: basePose.rightArmFlexion + rightFlex,
      rightArmAbduction: basePose.rightArmAbduction + rightAbd,
    );

    return VrAvatarEmoteState._(
      emote: emote,
      elapsedSeconds: safeTime,
      voiceAmplitude: clampedVoice,
      pose: pose,
      mouthOpenness: mouthOpenness,
      headPitchOffset: headPitch,
      headYawOffset: headYaw,
      leftHandHeightOffset: leftHandHeight,
      rightHandHeightOffset: rightHandHeight,
    );
  }

  final VrAvatarEmote emote;
  final double elapsedSeconds;
  final double voiceAmplitude;
  final VrAvatarPose pose;
  final double mouthOpenness;
  final double headPitchOffset;
  final double headYawOffset;
  final double leftHandHeightOffset;
  final double rightHandHeightOffset;
}
