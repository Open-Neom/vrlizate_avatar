import '../constants/vr_avatar_constants.dart';
import '../constants/vr_avatar_translation_constants.dart';

/// Accessibility posture and interaction mode for inclusive VR calibration.
enum VrAccessibilityPostureMode {
  /// Automatically infers standing, walking, crouching, or seated posture from
  /// the 3-camera + ultrasonic loop without artificial height boosting.
  adaptiveAuto(VrAvatarConstants.postureModeAdaptiveAutoId),

  /// Optimized for seated users and wheelchair users: elevates virtual eye
  /// height to match standing horizon level and boosts 3D arm reach.
  seatedWheelchair(VrAvatarConstants.postureModeSeatedWheelchairId),

  /// Full room-scale standing locomotion mode.
  standingRoomscale(VrAvatarConstants.postureModeStandingRoomscaleId),

  /// Optimized for single-hand or limited-mobility operation: amplifies virtual
  /// arm reach and synthesizes natural counter-balance kinematics for the
  /// secondary arm.
  oneHandedReach(VrAvatarConstants.postureModeOneHandedReachId);

  const VrAccessibilityPostureMode(this.id);

  final String id;

  /// Localized display label for UI settings.
  String get displayLabel => switch (this) {
    VrAccessibilityPostureMode.adaptiveAuto =>
      VrAvatarTranslationConstants.postureAdaptiveAutoLabel,
    VrAccessibilityPostureMode.seatedWheelchair =>
      VrAvatarTranslationConstants.postureSeatedWheelchairLabel,
    VrAccessibilityPostureMode.standingRoomscale =>
      VrAvatarTranslationConstants.postureStandingRoomscaleLabel,
    VrAccessibilityPostureMode.oneHandedReach =>
      VrAvatarTranslationConstants.postureOneHandedReachLabel,
  };
}
