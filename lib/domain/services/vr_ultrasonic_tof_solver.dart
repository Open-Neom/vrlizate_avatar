import 'dart:math' as math;
import 'dart:typed_data';

import '../../utils/constants/vr_avatar_constants.dart';
import '../models/vr_ultrasonic_range_sample.dart';

/// Acoustic & near-ultrasonic Time-of-Flight (TW-ToF / BeepBeep protocol) and
/// FMCW chirp matched-filter solver for ranging between the Visor smartphone
/// and the Joystick smartphone.
class VrUltrasonicTofSolver {
  const VrUltrasonicTofSolver({
    this.sampleRateHz = VrAvatarConstants.defaultAudioSampleRateHz,
    this.ambientTemperatureCelsius =
        VrAvatarConstants.defaultAmbientTemperatureCelsius,
    this.hardwareSeparationOffsetMeters = 0.0,
  });

  final double sampleRateHz;
  final double ambientTemperatureCelsius;

  /// Optional calibration offset accounting for speaker-to-microphone distance
  /// on the two smartphone chassis.
  final double hardwareSeparationOffsetMeters;

  /// Speed of sound in dry air at [temperatureCelsius]:
  /// $$c(T) = 331.3 + 0.606 \cdot T$$
  static double speedOfSoundMetersPerSec([
    double temperatureCelsius =
        VrAvatarConstants.defaultAmbientTemperatureCelsius,
  ]) {
    return VrAvatarConstants.defaultSpeedOfSoundZeroCelsius +
        VrAvatarConstants.speedOfSoundTempCoeff * temperatureCelsius;
  }

  /// Generates a Hann-windowed linear FMCW ultrasonic chirp waveform in `-1.0..1.0`.
  ///
  /// Defaults to the Joystick up-chirp (`18.5 kHz -> 20.5 kHz`, `10 ms` at `48 kHz`).
  Float64List generateLinearChirp({
    double startFreqHz = VrAvatarConstants.joystickChirpStartHz,
    double endFreqHz = VrAvatarConstants.joystickChirpEndHz,
    double durationSeconds = VrAvatarConstants.defaultChirpDurationSeconds,
  }) {
    final numSamples = (durationSeconds * sampleRateHz).round().clamp(
      VrAvatarConstants.minChirpSamples,
      VrAvatarConstants.maxChirpSamples,
    );
    final out = Float64List(numSamples);
    final sweepRate = (endFreqHz - startFreqHz) / durationSeconds;
    for (var i = 0; i < numSamples; i++) {
      final t = i / sampleRateHz;
      final phase = 2.0 * math.pi * (startFreqHz * t + 0.5 * sweepRate * t * t);
      // Hann envelope prevents audible clicks at chirp boundaries!
      final window =
          0.5 * (1.0 - math.cos((2.0 * math.pi * i) / (numSamples - 1)));
      out[i] = math.sin(phase) * window;
    }
    return out;
  }

  /// Finds the sub-sample arrival index of [referenceChirp] inside [recordedPcm]
  /// using normalized matched-filter cross-correlation and parabolic peak
  /// interpolation.
  ///
  /// Returns `(sampleIndex, snrDb)`.
  ({double sampleIndex, double snrDb}) detectChirpArrival({
    required Float64List recordedPcm,
    required Float64List referenceChirp,
  }) {
    final n = recordedPcm.length;
    final m = referenceChirp.length;
    if (n < m || m == 0) {
      return (sampleIndex: 0.0, snrDb: 0.0);
    }
    final maxLag = n - m;
    final corr = Float64List(maxLag + 1);
    var bestLag = 0;
    var bestVal = -1.0;
    var sumAbs = 0.0;

    for (var lag = 0; lag <= maxLag; lag++) {
      var dot = 0.0;
      for (var k = 0; k < m; k++) {
        dot += recordedPcm[lag + k] * referenceChirp[k];
      }
      final mag = dot.abs();
      corr[lag] = mag;
      sumAbs += mag;
      if (mag > bestVal) {
        bestVal = mag;
        bestLag = lag;
      }
    }

    // Sub-sample parabolic interpolation around bestLag
    var fractionalOffset = 0.0;
    if (bestLag > 0 && bestLag < maxLag) {
      final yMinus = corr[bestLag - 1];
      final yZero = corr[bestLag];
      final yPlus = corr[bestLag + 1];
      final denom = yMinus - 2.0 * yZero + yPlus;
      if (denom.abs() > 1e-12) {
        fractionalOffset = (0.5 * (yMinus - yPlus) / denom).clamp(
          -VrAvatarConstants.parabolicMaxFractionalOffset,
          VrAvatarConstants.parabolicMaxFractionalOffset,
        );
      }
    }

    final meanNoise = (sumAbs - bestVal) / math.max(1, maxLag);
    final snrRatio =
        bestVal /
        math.max(VrAvatarConstants.minNoiseFloorEpsilon, meanNoise);
    final snrDb =
        VrAvatarConstants.decibelAmplitudeFactor *
        (math.log(math.max(1.0, snrRatio)) / math.ln10);

    return (sampleIndex: bestLag + fractionalOffset, snrDb: snrDb);
  }

  /// Solves the clock-offset-free Two-Way Time-of-Flight (BeepBeep) distance
  /// between the Joystick smartphone and Visor smartphone from sample indices:
  /// - [joystickSelfArrivalSample]: $n_{AA}$ recorded on Joystick when emitting chirp A
  /// - [joystickRemoteArrivalSample]: $n_{BA}$ recorded on Joystick when receiving chirp B
  /// - [visorRemoteArrivalSample]: $n_{AB}$ recorded on Visor when receiving chirp A
  /// - [visorSelfArrivalSample]: $n_{BB}$ recorded on Visor when emitting chirp B
  VrUltrasonicRangeSample solveTwoWayTimeOfFlight({
    required double joystickSelfArrivalSample,
    required double joystickRemoteArrivalSample,
    required double visorRemoteArrivalSample,
    required double visorSelfArrivalSample,
    double? previousDistanceMeters,
    double? dtSeconds,
    double snrDb = VrAvatarConstants.defaultUltrasonicSnrDb,
  }) {
    final deltaJoystickSamples =
        joystickRemoteArrivalSample - joystickSelfArrivalSample;
    final deltaVisorSamples = visorSelfArrivalSample - visorRemoteArrivalSample;
    final roundTripSamples = math.max(
      0.0,
      deltaJoystickSamples - deltaVisorSamples,
    );
    final oneWaySeconds = (roundTripSamples * 0.5) / sampleRateHz;
    final c = speedOfSoundMetersPerSec(ambientTemperatureCelsius);
    final rawDistance = oneWaySeconds * c + hardwareSeparationOffsetMeters;
    final clampedDistance = rawDistance.clamp(
      VrAvatarConstants.minSolvedAcousticDistanceMeters,
      VrAvatarConstants.maxSolvedAcousticDistanceMeters,
    );

    var radialVelocity = 0.0;
    if (previousDistanceMeters != null &&
        dtSeconds != null &&
        dtSeconds > 1e-4) {
      radialVelocity = (clampedDistance - previousDistanceMeters) / dtSeconds;
    }

    final confidence =
        ((snrDb - VrAvatarConstants.snrMinConfidenceDb) /
                VrAvatarConstants.snrSpanConfidenceDb)
            .clamp(0.0, 1.0);

    return VrUltrasonicRangeSample(
      distanceMeters: clampedDistance,
      radialVelocityMetersPerSec: radialVelocity,
      roundTripMicros:
          ((roundTripSamples / sampleRateHz) *
                  VrAvatarConstants.microsecondsPerSecond)
              .round(),
      signalToNoiseDb: snrDb,
      ambientTemperatureCelsius: ambientTemperatureCelsius,
      confidence: confidence,
    );
  }
}
