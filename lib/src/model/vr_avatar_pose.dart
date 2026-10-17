import 'dart:math' as math;

/// Declarative, renderer-independent humanoid/avatar pose state.
///
/// Adapted from the procedural rig kinematics in Lemo-Opuscar
/// (`styles/brick-toy/demo/actors.js` and `TECHNIQUE.md` §10, MIT License).
///
/// All angles are in radians:
/// - [sit]: continuous `0..1` blend from standing (`0`) to seated (`1`).
/// - [lean]: torso forward/backward pitch (`+` leans forward).
/// - [turn]: torso yaw (`+` turns left/counter-clockwise around +Y).
/// - [bob]: vertical torso offset in meters.
/// - [nod], [look], [tilt]: head pitch, yaw, and roll in radians.
/// - [leftArmFlexion] / [rightArmFlexion]: forward/backward arm swing (`+` raises forward).
/// - [leftArmAbduction] / [rightArmAbduction]: outward lateral raise (`+` raises away from torso).
/// - [leftLegSwing] / [rightLegSwing]: hip forward/backward swing (`+` swings forward).
/// - [blink]: `0..1` eyelid closure (`1` compresses eye vertical scale to `0.15`).
class VrAvatarPose {
  const VrAvatarPose({
    this.sit = 0.0,
    this.lean = 0.0,
    this.turn = 0.0,
    this.bob = 0.0,
    this.nod = 0.0,
    this.look = 0.0,
    this.tilt = 0.0,
    this.leftArmFlexion = 0.0,
    this.leftArmAbduction = 0.0,
    this.rightArmFlexion = 0.0,
    this.rightArmAbduction = 0.0,
    this.leftLegSwing = 0.0,
    this.rightLegSwing = 0.0,
    this.blink = 0.0,
  });

  static const VrAvatarPose neutral = VrAvatarPose();

  /// Generates a walk-cycle pose at stride phase [phi] (radians) and [amplitude].
  ///
  /// Matches `walkPose(phi, amp)` from Lemo-Opuscar `actors.js`:
  /// opposite leg/arm counter-swing with double-frequency vertical bounce.
  factory VrAvatarPose.walk(
    double phi, {
    double amplitude = 0.55,
    double lean = 0.06,
    double look = 0.0,
    double blink = 0.0,
  }) {
    final s = math.sin(phi);
    return VrAvatarPose(
      lean: lean,
      bob: math.cos(phi).abs() * 0.032 * amplitude,
      look: look,
      leftLegSwing: s * amplitude,
      rightLegSwing: -s * amplitude,
      leftArmFlexion: -s * amplitude * 0.6,
      leftArmAbduction: 0.06,
      rightArmFlexion: s * amplitude * 0.6,
      rightArmAbduction: 0.06,
      blink: blink,
    );
  }

  /// Generates a seated pose (`sit` in `0..1`) with optional head look/nod.
  factory VrAvatarPose.seated({
    double sit = 1.0,
    double lean = 0.04,
    double nod = 0.0,
    double look = 0.0,
    double blink = 0.0,
  }) {
    final clampedSit = sit.clamp(0.0, 1.0);
    return VrAvatarPose(
      sit: clampedSit,
      lean: lean,
      nod: nod,
      look: look,
      leftArmFlexion: 0.25 * clampedSit,
      rightArmFlexion: 0.25 * clampedSit,
      leftArmAbduction: 0.08 * clampedSit,
      rightArmAbduction: 0.08 * clampedSit,
      blink: blink,
    );
  }

  /// Generates a friendly greeting wave pose at oscillation phase [phi].
  factory VrAvatarPose.wave(
    double phi, {
    bool leftHand = false,
    double waveAmount = 1.0,
    double blink = 0.0,
  }) {
    final w = waveAmount.clamp(0.0, 1.0);
    final wag = math.sin(phi * 4.0) * 0.28 * w;
    return VrAvatarPose(
      tilt: (leftHand ? -0.06 : 0.06) * w,
      leftArmFlexion: leftHand ? 0.85 * w : 0.0,
      leftArmAbduction: leftHand ? (1.15 * w + wag) : 0.04,
      rightArmFlexion: leftHand ? 0.0 : 0.85 * w,
      rightArmAbduction: leftHand ? 0.04 : (1.15 * w + wag),
      blink: blink,
    );
  }

  final double sit;
  final double lean;
  final double turn;
  final double bob;
  final double nod;
  final double look;
  final double tilt;
  final double leftArmFlexion;
  final double leftArmAbduction;
  final double rightArmFlexion;
  final double rightArmAbduction;
  final double leftLegSwing;
  final double rightLegSwing;
  final double blink;

  /// Vertical eye scale factor (`1.0` open, `0.15` closed blink).
  double get eyeScaleY => 1.0 - 0.85 * blink.clamp(0.0, 1.0);

  /// Linearly blends between two [VrAvatarPose] states without pose popping.
  static VrAvatarPose lerp(VrAvatarPose a, VrAvatarPose b, double t) {
    final u = t.clamp(0.0, 1.0);
    double l(double x, double y) => x + (y - x) * u;
    return VrAvatarPose(
      sit: l(a.sit, b.sit),
      lean: l(a.lean, b.lean),
      turn: l(a.turn, b.turn),
      bob: l(a.bob, b.bob),
      nod: l(a.nod, b.nod),
      look: l(a.look, b.look),
      tilt: l(a.tilt, b.tilt),
      leftArmFlexion: l(a.leftArmFlexion, b.leftArmFlexion),
      leftArmAbduction: l(a.leftArmAbduction, b.leftArmAbduction),
      rightArmFlexion: l(a.rightArmFlexion, b.rightArmFlexion),
      rightArmAbduction: l(a.rightArmAbduction, b.rightArmAbduction),
      leftLegSwing: l(a.leftLegSwing, b.leftLegSwing),
      rightLegSwing: l(a.rightLegSwing, b.rightLegSwing),
      blink: l(a.blink, b.blink),
    );
  }

  VrAvatarPose copyWith({
    double? sit,
    double? lean,
    double? turn,
    double? bob,
    double? nod,
    double? look,
    double? tilt,
    double? leftArmFlexion,
    double? leftArmAbduction,
    double? rightArmFlexion,
    double? rightArmAbduction,
    double? leftLegSwing,
    double? rightLegSwing,
    double? blink,
  }) {
    return VrAvatarPose(
      sit: sit ?? this.sit,
      lean: lean ?? this.lean,
      turn: turn ?? this.turn,
      bob: bob ?? this.bob,
      nod: nod ?? this.nod,
      look: look ?? this.look,
      tilt: tilt ?? this.tilt,
      leftArmFlexion: leftArmFlexion ?? this.leftArmFlexion,
      leftArmAbduction: leftArmAbduction ?? this.leftArmAbduction,
      rightArmFlexion: rightArmFlexion ?? this.rightArmFlexion,
      rightArmAbduction: rightArmAbduction ?? this.rightArmAbduction,
      leftLegSwing: leftLegSwing ?? this.leftLegSwing,
      rightLegSwing: rightLegSwing ?? this.rightLegSwing,
      blink: blink ?? this.blink,
    );
  }
}

/// Shoulder girdle & arm rotation rules from Lemo-Opuscar `TECHNIQUE.md` §10:
///
/// 1. Order shoulder rotation as **abduction first, then flexion** so raised
///    arms never cross into an unnatural X in front of the chest.
/// 2. As an arm lifts (`liftAmount`), the shoulder girdle rises slightly (+Y)
///    and shifts forward (+Z) to preserve natural silhouette continuity.
abstract final class VrShoulderKinematics {
  /// Normalized `0..1` arm elevation factor from [flexion] and [abduction].
  static double armLiftFactor({
    required double flexion,
    required double abduction,
  }) {
    final combined = math.sqrt(flexion * flexion + abduction * abduction);
    return (combined / (math.pi * 0.75)).clamp(0.0, 1.0);
  }

  /// Vertical clavicle lift in meters scaled by avatar [heightMeters].
  static double clavicleRiseMeters({
    required double flexion,
    required double abduction,
    double heightMeters = 1.0,
  }) {
    return armLiftFactor(flexion: flexion, abduction: abduction) *
        0.024 *
        heightMeters;
  }

  /// Forward clavicle shift in meters scaled by avatar [heightMeters].
  static double clavicleForwardMeters({
    required double flexion,
    required double abduction,
    double heightMeters = 1.0,
  }) {
    return armLiftFactor(flexion: flexion, abduction: abduction) *
        0.014 *
        heightMeters;
  }
}
