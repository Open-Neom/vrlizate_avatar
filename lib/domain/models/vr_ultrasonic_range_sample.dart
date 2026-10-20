import '../../utils/constants/vr_avatar_constants.dart';

/// Acoustic / near-ultrasonic Time-of-Flight (TW-ToF / BeepBeep) and Doppler
/// range measurement between the Visor smartphone and the Joystick smartphone.
class VrUltrasonicRangeSample {
  const VrUltrasonicRangeSample({
    required this.distanceMeters,
    this.radialVelocityMetersPerSec = 0.0,
    this.roundTripMicros = 0,
    this.signalToNoiseDb = VrAvatarConstants.defaultUltrasonicSnrDb,
    this.ambientTemperatureCelsius =
        VrAvatarConstants.defaultAmbientTemperatureCelsius,
    this.confidence = 1.0,
  });

  /// Metric distance $\|\mathbf{p}_{\text{head}} - \mathbf{p}_{\text{joy}}\|$
  /// between the Visor and Joystick smartphones in meters.
  final double distanceMeters;

  /// Radial velocity (`+` moving away from head, `-` moving closer) in m/s.
  final double radialVelocityMetersPerSec;

  /// Acoustic round-trip propagation time in microseconds.
  final int roundTripMicros;

  /// Matched-filter correlation peak SNR in decibels.
  final double signalToNoiseDb;

  /// Ambient air temperature in Celsius used to compute speed of sound $c(T)$.
  final double ambientTemperatureCelsius;

  /// Measurement confidence in `0.0..1.0`.
  final double confidence;

  /// Whether the acoustic distance falls within valid human arm reach (`0.12 m .. 1.65 m`).
  bool get isValidReach =>
      distanceMeters.isFinite &&
      distanceMeters >= VrAvatarConstants.minValidAcousticDistanceMeters &&
      distanceMeters <= VrAvatarConstants.maxValidAcousticDistanceMeters &&
      confidence > VrAvatarConstants.minValidAcousticConfidence;
}
