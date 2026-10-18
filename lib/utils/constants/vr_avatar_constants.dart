abstract final class VrAvatarConstants {
  static const String keyStyle = 'style';
  static const String keySpecies = 'species';
  static const String keyBodyColorArgb = 'bodyColorArgb';
  static const String keyAccentColorArgb = 'accentColorArgb';
  static const String keyHeightMeters = 'heightMeters';
  static const String keyHeadScale = 'headScale';
  static const String keyFeatureScale = 'featureScale';
  static const String keyPattern = 'pattern';
  static const String keyShowOwnBody = 'showOwnBody';
  static const String keyShowNameplates = 'showNameplates';
  static const String keyProximityVoiceEnabled = 'proximityVoiceEnabled';
  static const String keyPersonalSpaceMeters = 'personalSpaceMeters';
  static const String keySchemaVersion = 'schemaVersion';
  static const String keyProfileId = 'profileId';
  static const String keyAppearance = 'appearance';
  static const String keyPreferences = 'preferences';

  static const String speciesFieldKeyPrefix = 'avatar-species-';
  static const String heightSliderKey = 'avatar-height';
  static const String headScaleSliderKey = 'avatar-head-scale';
  static const String featureScaleSliderKey = 'avatar-feature-scale';
  static const String patternFieldKeyPrefix = 'avatar-pattern-';
  static const String ownBodySwitchKey = 'avatar-own-body';
  static const String nameplatesSwitchKey = 'avatar-nameplates';
  static const String proximityVoiceSwitchKey = 'avatar-proximity-voice';
  static const String personalSpaceSliderKey = 'avatar-personal-space';
  static const String saveButtonKey = 'avatar-save';

  static const String controlCharPattern = r'[\x00-\x1f\x7f]';
  static const String shareCodePrefix = 'VRLZ-AV1:';
  static const String metersSuffix = ' m';
  static const String percentSuffix = '%';
  static const String hexPrefix = '#';
  static const String colonSeparator = ': ';
  static const String spaceSeparator = ' ';
  static const String enDash = '–';
  static const String period = '.';

  static const String errConflictingSpecies = 'Conflicting species.';
  static const String errInvalidAppearancePrefix =
      'Invalid avatar appearance: ';
  static const String errUnknownAvatarPrefix = 'Unknown avatar ';
  static const String errInvalidPreferencesPrefix =
      'Invalid avatar preferences: ';
  static const String errInvalidProfileId = 'Invalid profile ID.';
  static const String errUnsupportedSchemaVersion =
      'Unsupported avatar schemaVersion.';
  static const String errProfileIdNotString =
      'Avatar profileId must be a string.';
  static const String errInvalidProfilePrefix = 'Invalid avatar profile: ';
  static const String errExpectedRangePrefix = 'Expected ';
  static const String errExpectedOpaqueColor = 'Expected opaque ARGB color.';
  static const String errAvatarPrefix = 'Avatar ';
  static const String errMustBeIntegerSuffix = ' must be an integer.';
  static const String errMustBeFiniteSuffix = ' must be finite.';
  static const String errMustBeBooleanSuffix = ' must be a boolean.';
  static const String errMustBeObjectSuffix = ' must be an object.';
  static const String errInvalidShareCode = 'Invalid avatar share code.';
  static const String errUnknownPresetPrefix = 'Unknown avatar preset: ';

  static const String presetExplorer = 'explorer';
  static const String presetCyberBot = 'cyber-bot';
  static const String presetLumenOrb = 'lumen-orb';
  static const String presetEmberFox = 'ember-fox';
  static const String presetCoralAxolotl = 'coral-axolotl';
  static const String presetMossSprout = 'moss-sprout';
  static const String defaultPresetProfileId = 'preset-profile';

  // Tri-camera + Ultrasonic body tracking & anthropometry constants
  static const double defaultSpeedOfSoundZeroCelsius = 331.3;
  static const double speedOfSoundTempCoeff = 0.606;
  static const double defaultAmbientTemperatureCelsius = 20.0;
  static const double defaultAudioSampleRateHz = 48000.0;
  static const double joystickChirpStartHz = 18500.0;
  static const double joystickChirpEndHz = 20500.0;
  static const double visorChirpStartHz = 21500.0;
  static const double visorChirpEndHz = 19500.0;
  static const double defaultChirpDurationSeconds = 0.010;
  static const double minValidAcousticDistanceMeters = 0.12;
  static const double maxValidAcousticDistanceMeters = 1.65;

  // Winter's Biomechanical Anthropometry ratios (fraction of total stature H_user)
  static const double defaultUserStatureMeters = 1.72;
  static const double eyeToCrownOffsetMeters = 0.11;
  static const double shoulderWidthToStatureRatio = 0.259;
  static const double upperArmToStatureRatio = 0.186;
  static const double forearmToStatureRatio = 0.146;
  static const double legLengthToStatureRatio = 0.530;
  static const double defaultVisorPhysicalWidthMeters = 0.155;
  static const double defaultCameraVerticalFovRadians = 1.0471975512; // 60 deg
  static const double defaultCameraHorizontalFovRadians = 1.308996939; // 75 deg
  static const double defaultStandingStanceDepthMeters = 0.34;
  static const double seatedHeightRatioThreshold = 0.76;
  static const double crouchingHeightRatioThreshold = 0.88;
  static const double jumpHeightDeltaThresholdMeters = 0.055;
}
