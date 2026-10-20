import '../../utils/constants/vr_avatar_constants.dart';

/// Calibrated anthropometric body proportions of the user derived from the
/// closed-loop relationship between the 3 cameras (Floor <-> Joystick <-> Head)
/// and ultrasonic inter-device ranging.
class VrUserAnthropometry {
  const VrUserAnthropometry({
    required this.statureMeters,
    required this.standingEyeHeightMeters,
    required this.shoulderWidthMeters,
    required this.upperArmLengthMeters,
    required this.forearmLengthMeters,
    required this.legLengthMeters,
    this.isCalibrated = false,
    this.calibrationConfidence = 0.0,
  });

  /// Creates proportional human body segment lengths from a total [statureMeters]
  /// using Winter's Biomechanical Anthropometry ratios.
  factory VrUserAnthropometry.fromStature(
    double statureMeters, {
    bool isCalibrated = false,
    double calibrationConfidence = 0.0,
  }) {
    final clampedStature = statureMeters.clamp(
      VrAvatarConstants.minValidStatureMeters,
      VrAvatarConstants.maxValidStatureMeters,
    );
    return VrUserAnthropometry(
      statureMeters: clampedStature,
      standingEyeHeightMeters:
          clampedStature - VrAvatarConstants.eyeToCrownOffsetMeters,
      shoulderWidthMeters:
          clampedStature * VrAvatarConstants.shoulderWidthToStatureRatio,
      upperArmLengthMeters:
          clampedStature * VrAvatarConstants.upperArmToStatureRatio,
      forearmLengthMeters:
          clampedStature * VrAvatarConstants.forearmToStatureRatio,
      legLengthMeters:
          clampedStature * VrAvatarConstants.legLengthToStatureRatio,
      isCalibrated: isCalibrated,
      calibrationConfidence: calibrationConfidence.clamp(0.0, 1.0),
    );
  }

  /// Creates anthropometric proportions from a measured standing eye/visor
  /// height above the floor ($H_{\text{head,standing}}$).
  factory VrUserAnthropometry.fromStandingHeadHeight(
    double standingHeadHeightMeters, {
    bool isCalibrated = true,
    double calibrationConfidence = 1.0,
  }) {
    return VrUserAnthropometry.fromStature(
      standingHeadHeightMeters + VrAvatarConstants.eyeToCrownOffsetMeters,
      isCalibrated: isCalibrated,
      calibrationConfidence: calibrationConfidence,
    );
  }

  /// Total user height from floor to head crown ($H_{\text{user}}$) in meters.
  final double statureMeters;

  /// Upright standing eye/visor height above the floor ($H_{\text{head,standing}}$).
  final double standingEyeHeightMeters;

  /// Biacromial shoulder width ($0.259 \cdot H_{\text{user}}$).
  final double shoulderWidthMeters;

  /// Shoulder-to-elbow length ($0.186 \cdot H_{\text{user}}$).
  final double upperArmLengthMeters;

  /// Elbow-to-wrist/grip length ($0.146 \cdot H_{\text{user}}$).
  final double forearmLengthMeters;

  /// Greater trochanter (hip) to floor leg length ($0.530 \cdot H_{\text{user}}$).
  final double legLengthMeters;

  /// Total maximum arm reach ($L_{\text{upper}} + L_{\text{forearm}}$).
  double get totalArmReachMeters => upperArmLengthMeters + forearmLengthMeters;

  final bool isCalibrated;
  final double calibrationConfidence;
}
