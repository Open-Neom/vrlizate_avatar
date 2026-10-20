import 'dart:math' as math;

import '../../utils/constants/vr_avatar_constants.dart';

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
    return (combined /
            (math.pi * VrAvatarConstants.armLiftMaxCombinedPiFraction))
        .clamp(0.0, 1.0);
  }

  /// Vertical clavicle lift in meters scaled by avatar [heightMeters].
  static double clavicleRiseMeters({
    required double flexion,
    required double abduction,
    double heightMeters = 1.0,
  }) {
    return armLiftFactor(flexion: flexion, abduction: abduction) *
        VrAvatarConstants.clavicleRiseScaleMeters *
        heightMeters;
  }

  /// Forward clavicle shift in meters scaled by avatar [heightMeters].
  static double clavicleForwardMeters({
    required double flexion,
    required double abduction,
    double heightMeters = 1.0,
  }) {
    return armLiftFactor(flexion: flexion, abduction: abduction) *
        VrAvatarConstants.clavicleForwardScaleMeters *
        heightMeters;
  }
}
