import 'package:flutter/foundation.dart';

import '../../utils/constants/vr_avatar_constants.dart';

/// Private user choices. Render/audio hosts explicitly apply these preferences.
///
/// Saving [proximityVoiceEnabled] alone never starts a microphone or grants OS
/// permission. Personal space describes a visual comfort preference, not server
/// collision or access-control authority.
@immutable
class VrAvatarPreferences {
  VrAvatarPreferences({
    this.showOwnBody = false,
    this.showNameplates = true,
    this.proximityVoiceEnabled = false,
    this.personalSpaceMeters = 0.8,
  }) {
    _range(
      personalSpaceMeters,
      VrAvatarConstants.keyPersonalSpaceMeters,
      minPersonalSpaceMeters,
      maxPersonalSpaceMeters,
    );
  }

  static const double minPersonalSpaceMeters = 0.4;
  static const double maxPersonalSpaceMeters = 2.0;

  final bool showOwnBody;
  final bool showNameplates;
  final bool proximityVoiceEnabled;
  final double personalSpaceMeters;

  VrAvatarPreferences copyWith({
    bool? showOwnBody,
    bool? showNameplates,
    bool? proximityVoiceEnabled,
    double? personalSpaceMeters,
  }) => VrAvatarPreferences(
    showOwnBody: showOwnBody ?? this.showOwnBody,
    showNameplates: showNameplates ?? this.showNameplates,
    proximityVoiceEnabled: proximityVoiceEnabled ?? this.proximityVoiceEnabled,
    personalSpaceMeters: personalSpaceMeters ?? this.personalSpaceMeters,
  );

  Map<String, dynamic> toJson() => {
    VrAvatarConstants.keyShowOwnBody: showOwnBody,
    VrAvatarConstants.keyShowNameplates: showNameplates,
    VrAvatarConstants.keyProximityVoiceEnabled: proximityVoiceEnabled,
    VrAvatarConstants.keyPersonalSpaceMeters: personalSpaceMeters,
  };

  factory VrAvatarPreferences.fromJson(Map<String, dynamic> json) {
    try {
      return VrAvatarPreferences(
        showOwnBody: _readBool(json, VrAvatarConstants.keyShowOwnBody),
        showNameplates: _readBool(json, VrAvatarConstants.keyShowNameplates),
        proximityVoiceEnabled: _readBool(
          json,
          VrAvatarConstants.keyProximityVoiceEnabled,
        ),
        personalSpaceMeters: _readDouble(
          json,
          VrAvatarConstants.keyPersonalSpaceMeters,
        ),
      );
    } on ArgumentError catch (error) {
      throw FormatException(
        '${VrAvatarConstants.errInvalidPreferencesPrefix}${error.name}${VrAvatarConstants.period}',
      );
    }
  }

  @override
  bool operator ==(Object other) =>
      other is VrAvatarPreferences &&
      other.showOwnBody == showOwnBody &&
      other.showNameplates == showNameplates &&
      other.proximityVoiceEnabled == proximityVoiceEnabled &&
      other.personalSpaceMeters == personalSpaceMeters;

  @override
  int get hashCode => Object.hash(
    showOwnBody,
    showNameplates,
    proximityVoiceEnabled,
    personalSpaceMeters,
  );
}

void _range(double value, String name, double min, double max) {
  if (!value.isFinite || value < min || value > max) {
    throw ArgumentError.value(
      value,
      name,
      '${VrAvatarConstants.errExpectedRangePrefix}$min${VrAvatarConstants.enDash}$max${VrAvatarConstants.period}',
    );
  }
}

double _readDouble(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is! num || !value.isFinite) {
    throw FormatException(
      '${VrAvatarConstants.errAvatarPrefix}$key${VrAvatarConstants.errMustBeFiniteSuffix}',
    );
  }
  return value.toDouble();
}

bool _readBool(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is! bool) {
    throw FormatException(
      '${VrAvatarConstants.errAvatarPrefix}$key${VrAvatarConstants.errMustBeBooleanSuffix}',
    );
  }
  return value;
}
