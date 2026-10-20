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
  static const int minChirpSamples = 16;
  static const int maxChirpSamples = 16384;
  static const double parabolicMaxFractionalOffset = 0.5;
  static const double decibelAmplitudeFactor = 20.0;
  static const double minNoiseFloorEpsilon = 1e-9;
  static const double defaultUltrasonicSnrDb = 24.0;
  static const double snrMinConfidenceDb = 6.0;
  static const double snrSpanConfidenceDb = 18.0;
  static const double microsecondsPerSecond = 1e6;
  static const double minSolvedAcousticDistanceMeters = 0.05;
  static const double maxSolvedAcousticDistanceMeters = 5.0;
  static const double minValidAcousticDistanceMeters = 0.12;
  static const double maxValidAcousticDistanceMeters = 1.65;
  static const double minValidAcousticConfidence = 0.15;

  // Winter's Biomechanical Anthropometry ratios (fraction of total stature H_user)
  static const double defaultUserStatureMeters = 1.72;
  static const double minValidStatureMeters = 1.10;
  static const double maxValidStatureMeters = 2.30;
  static const double eyeToCrownOffsetMeters = 0.11;
  static const double shoulderWidthToStatureRatio = 0.259;
  static const double upperArmToStatureRatio = 0.186;
  static const double forearmToStatureRatio = 0.146;
  static const double legLengthToStatureRatio = 0.530;
  static const double shoulderDropToStatureRatio = 0.18;
  static const double defaultVisorPhysicalWidthMeters = 0.155;
  static const double defaultCameraVerticalFovRadians = 1.0471975512; // 60 deg
  static const double defaultCameraHorizontalFovRadians = 1.308996939; // 75 deg
  static const double defaultStandingStanceDepthMeters = 0.34;
  static const double seatedHeightRatioThreshold = 0.76;
  static const double crouchingHeightRatioThreshold = 0.88;
  static const double jumpHeightDeltaThresholdMeters = 0.055;
  static const double jumpVerticalVelocityThresholdMetersPerSec = 0.65;

  // Tri-Camera Body Fusion Filter & IK constants
  static const double defaultJoystickToEyeHeightRatio = 0.68;
  static const double defaultJoystickRelHeadY = -0.45;
  static const double defaultJoystickRelHeadZ = -0.38;
  static const double defaultFootLateralOffsetMeters = 0.14;
  static const double minFilterDtSeconds = 0.001;
  static const double maxFilterDtSeconds = 0.25;
  static const double filterBlendRateHz = 12.0;
  static const double minFilterBlendFactor = 0.08;
  static const double minVisorNormalizedWidth = 0.03;
  static const double defaultFallbackVisorNormalizedWidth = 0.25;
  static const double minClampedVisorNormalizedWidth = 0.04;
  static const double maxClampedVisorNormalizedWidth = 0.95;
  static const double ultrasonicRangeFusionWeight = 0.80;
  static const double visualVisorDistanceFusionWeight = 0.20;
  static const double maxJoyAboveHeadFlipThresholdY = 0.25;
  static const double minHeadToJoyVerticalMeters = 0.05;
  static const double maxHeadToJoyVerticalMeters = 0.95;
  static const double minJoyHorizontalForwardMeters = 0.18;
  static const double minFootDepressionRayY = -0.12;
  static const double minCamera2JoyHeightMeters = 0.35;
  static const double maxCamera2JoyHeightMeters = 1.55;
  static const double minFusedJoyHeightMeters = 0.30;
  static const double minVisorFloorDistanceMeters = 0.45;
  static const double visorFloorFusionWeight = 0.60;
  static const double chainFloorFusionWeight = 0.40;
  static const double minCalibrationStandingEyeHeightMeters = 1.15;
  static const double maxCalibrationStandingEyeHeightMeters = 2.10;
  static const double maxCalibrationVerticalVelocityMetersPerSec = 0.15;
  static const double calibrationHeightGainMarginMeters = 0.02;
  static const double calibrationTargetSampleCount = 10.0;
  static const double minCalibrationConfidence = 0.25;
  static const double calibratedHeightRetentionWeight = 0.85;
  static const double calibratedHeightUpdateWeight = 0.15;
  static const double minEffectiveLegLengthMeters = 0.55;
  static const double maxLegSwingRadians = 0.85;
  static const double steppingSwingDiffThresholdRadians = 0.16;
  static const double steppingFootSpeedThresholdMetersPerSec = 0.18;
  static const double stridePhaseAngularVelocityRadPerSec = 5.5;
  static const double walkSpeedSwingScale = 1.6;
  static const double walkSpeedFootVelocityScale = 0.4;
  static const double maxWalkSpeedMetersPerSec = 2.4;
  static const double minHandForwardDistanceMeters = 0.05;
  static const double armElevationBiasPiFraction = 0.38;
  static const double minArmFlexionRadians = -0.35;
  static const double maxArmFlexionRadians = 1.85;
  static const double armAbductionLateralGain = 1.4;
  static const double minArmAbductionRadians = 0.04;
  static const double maxArmAbductionRadians = 1.25;
  static const double oneHandedIdleLeftAbductionRadians = 0.06;
  static const double oneHandedCounterSwingFactor = 0.4;
  static const double crouchingLeanRadians = 0.18;
  static const double standingLeanRadians = 0.04;
  static const double walkingBobAmplitudeMeters = 0.025;
  static const double liftedFootPlaneHeightMeters = 0.08;
  static const double minGroundProjectionRaySlopeY = -0.05;
  static const double minFootRayDistanceMeters = 0.15;
  static const double maxFootRayDistanceMeters = 2.50;
  static const double maxFootLateralReachMeters = 0.65;
  static const double maxFootForwardReachMeters = 0.75;

  static const double clavicleRiseScaleMeters = 0.024;
  static const double clavicleForwardScaleMeters = 0.014;
  static const double armLiftMaxCombinedPiFraction = 0.75;

  // Universal Accessibility & Seated / One-Handed Reach Calibration constants
  static const String postureModeAdaptiveAutoId = 'adaptive_auto';
  static const String postureModeSeatedWheelchairId = 'seated_wheelchair';
  static const String postureModeStandingRoomscaleId = 'standing_roomscale';
  static const String postureModeOneHandedReachId = 'one_handed_reach';

  static const double defaultEyeElevationBoostMeters = 0.0;
  static const double seatedWheelchairEyeElevationBoostMeters = 0.42;
  static const double minCompensatedEyeHeightMeters = 0.50;
  static const double maxCompensatedEyeHeightMeters = 2.40;

  static const double defaultReachMultiplier = 1.0;
  static const double seatedWheelchairReachMultiplier = 1.35;
  static const double oneHandedReachMultiplier = 1.45;
  static const double minReachMultiplier = 0.50;
  static const double maxReachMultiplier = 2.50;

  static const double defaultUiScaleMultiplier = 1.0;
  static const double lowVisionUiScaleMultiplier = 1.35;
  static const double minUiScaleMultiplier = 0.75;
  static const double maxUiScaleMultiplier = 2.00;
}
