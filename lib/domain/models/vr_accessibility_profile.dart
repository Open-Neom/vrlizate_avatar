import 'package:vector_math/vector_math.dart';

import '../../utils/constants/vr_avatar_constants.dart';
import '../../utils/enums/vr_accessibility_posture_mode.dart';

/// Universal accessibility configuration for inclusive VR experiences,
/// supporting seated/wheelchair virtual eye-level compensation, one-handed
/// extended reach, high-contrast wireframes, colorblind-safe palettes, and
/// spatial UI scaling.
class VrAccessibilityProfile {
  const VrAccessibilityProfile({
    this.postureMode = VrAccessibilityPostureMode.adaptiveAuto,
    this.virtualEyeElevationBoostMeters =
        VrAvatarConstants.defaultEyeElevationBoostMeters,
    this.reachMultiplier = VrAvatarConstants.defaultReachMultiplier,
    this.highContrastWireframe = false,
    this.colorblindSafePalette = false,
    this.uiScaleMultiplier = VrAvatarConstants.defaultUiScaleMultiplier,
  });

  /// Standard uncompensated room-scale/adaptive profile.
  const VrAccessibilityProfile.standard()
    : postureMode = VrAccessibilityPostureMode.adaptiveAuto,
      virtualEyeElevationBoostMeters =
          VrAvatarConstants.defaultEyeElevationBoostMeters,
      reachMultiplier = VrAvatarConstants.defaultReachMultiplier,
      highContrastWireframe = false,
      colorblindSafePalette = false,
      uiScaleMultiplier = VrAvatarConstants.defaultUiScaleMultiplier;

  /// Preset for seated or wheelchair users: adds `+0.42 m` of virtual eye
  /// elevation so the user interacts at standing eye level, and amplifies
  /// 3D hand/joystick reach by `1.35x`.
  const VrAccessibilityProfile.seatedOrWheelchair({
    this.virtualEyeElevationBoostMeters =
        VrAvatarConstants.seatedWheelchairEyeElevationBoostMeters,
    this.reachMultiplier = VrAvatarConstants.seatedWheelchairReachMultiplier,
    this.highContrastWireframe = false,
    this.colorblindSafePalette = false,
    this.uiScaleMultiplier = VrAvatarConstants.defaultUiScaleMultiplier,
  }) : postureMode = VrAccessibilityPostureMode.seatedWheelchair;

  /// Preset for one-handed operation: amplifies 3D hand/joystick reach by
  /// `1.45x` and enables automatic secondary-arm counter-balance.
  const VrAccessibilityProfile.oneHanded({
    this.virtualEyeElevationBoostMeters =
        VrAvatarConstants.defaultEyeElevationBoostMeters,
    this.reachMultiplier = VrAvatarConstants.oneHandedReachMultiplier,
    this.highContrastWireframe = false,
    this.colorblindSafePalette = false,
    this.uiScaleMultiplier = VrAvatarConstants.defaultUiScaleMultiplier,
  }) : postureMode = VrAccessibilityPostureMode.oneHandedReach;

  /// Preset for users with low vision or color vision deficiency: enables
  /// high-contrast 3D wireframes, colorblind-safe palettes, and `1.35x` spatial
  /// UI scaling.
  const VrAccessibilityProfile.lowVisionHighContrast({
    this.postureMode = VrAccessibilityPostureMode.adaptiveAuto,
    this.virtualEyeElevationBoostMeters =
        VrAvatarConstants.defaultEyeElevationBoostMeters,
    this.reachMultiplier = VrAvatarConstants.defaultReachMultiplier,
    this.uiScaleMultiplier = VrAvatarConstants.lowVisionUiScaleMultiplier,
  }) : highContrastWireframe = true,
       colorblindSafePalette = true;

  final VrAccessibilityPostureMode postureMode;
  final double virtualEyeElevationBoostMeters;
  final double reachMultiplier;
  final bool highContrastWireframe;
  final bool colorblindSafePalette;
  final double uiScaleMultiplier;

  /// Applies virtual eye-height elevation compensation (`+virtualEyeElevationBoostMeters`)
  /// to [rawEyeHeightMeters], clamped to a safe human/room range.
  double applyEyeHeightCompensation(double rawEyeHeightMeters) {
    final effectiveBoost =
        (postureMode == VrAccessibilityPostureMode.seatedWheelchair &&
            virtualEyeElevationBoostMeters == 0.0)
        ? VrAvatarConstants.seatedWheelchairEyeElevationBoostMeters
        : virtualEyeElevationBoostMeters;
    return (rawEyeHeightMeters + effectiveBoost).clamp(
      VrAvatarConstants.minCompensatedEyeHeightMeters,
      VrAvatarConstants.maxCompensatedEyeHeightMeters,
    );
  }

  /// Applies 3D reach amplification (`reachMultiplier`) to a hand or joystick
  /// vector [relativeHandOrJoystickPos] measured relative to the head/shoulders.
  Vector3 applyReachCompensation(Vector3 relativeHandOrJoystickPos) {
    final clampedMult = reachMultiplier.clamp(
      VrAvatarConstants.minReachMultiplier,
      VrAvatarConstants.maxReachMultiplier,
    );
    return relativeHandOrJoystickPos * clampedMult;
  }
}
