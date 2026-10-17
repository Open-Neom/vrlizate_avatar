import 'package:flutter/foundation.dart';

import '../../utils/constants/vr_avatar_constants.dart';
import 'vr_avatar_appearance.dart';
import 'vr_avatar_preferences.dart';

/// A VR extension of an existing profile ID; contains no social/account fields.
///
/// The host resolves [profileId] from its authenticated ProfileService. This
/// value is a reference, never authentication proof or permission to impersonate
/// an avatar in a networked world.
@immutable
class VrAvatarProfile {
  VrAvatarProfile({
    required this.profileId,
    VrAvatarAppearance? appearance,
    VrAvatarPreferences? preferences,
  }) : appearance = appearance ?? VrAvatarAppearance(),
       preferences = preferences ?? VrAvatarPreferences() {
    if (profileId.isEmpty ||
        profileId.length > maxProfileIdLength ||
        profileId.trim() != profileId ||
        RegExp(VrAvatarConstants.controlCharPattern).hasMatch(profileId)) {
      throw ArgumentError.value(
        profileId,
        VrAvatarConstants.keyProfileId,
        VrAvatarConstants.errInvalidProfileId,
      );
    }
  }

  static const int schemaVersion = 1;
  static const int maxProfileIdLength = 256;

  final String profileId;
  final VrAvatarAppearance appearance;
  final VrAvatarPreferences preferences;

  /// Identity is intentionally immutable across edits.
  VrAvatarProfile copyWith({
    VrAvatarAppearance? appearance,
    VrAvatarPreferences? preferences,
  }) => VrAvatarProfile(
    profileId: profileId,
    appearance: appearance ?? this.appearance,
    preferences: preferences ?? this.preferences,
  );

  /// Persistence representation; store privately under the owning profile.
  Map<String, dynamic> toJson() => {
    ...toPublicJson(),
    VrAvatarConstants.keyPreferences: preferences.toJson(),
  };

  /// Appearance-only announcement for an authorized world participant.
  /// Never broadcast the private persistence representation [toJson].
  Map<String, dynamic> toPublicJson() => {
    VrAvatarConstants.keySchemaVersion: schemaVersion,
    VrAvatarConstants.keyProfileId: profileId,
    VrAvatarConstants.keyAppearance: appearance.toJson(),
  };

  factory VrAvatarProfile.fromJson(Map<String, dynamic> json) {
    if (json[VrAvatarConstants.keySchemaVersion] != schemaVersion) {
      throw const FormatException(
        VrAvatarConstants.errUnsupportedSchemaVersion,
      );
    }
    final id = json[VrAvatarConstants.keyProfileId];
    if (id is! String) {
      throw const FormatException(VrAvatarConstants.errProfileIdNotString);
    }
    try {
      return VrAvatarProfile(
        profileId: id,
        appearance: VrAvatarAppearance.fromJson(
          _readMap(json, VrAvatarConstants.keyAppearance),
        ),
        preferences: VrAvatarPreferences.fromJson(
          _readMap(json, VrAvatarConstants.keyPreferences),
        ),
      );
    } on ArgumentError catch (error) {
      throw FormatException(
        '${VrAvatarConstants.errInvalidProfilePrefix}${error.name}${VrAvatarConstants.period}',
      );
    }
  }

  @override
  bool operator ==(Object other) =>
      other is VrAvatarProfile &&
      other.profileId == profileId &&
      other.appearance == appearance &&
      other.preferences == preferences;

  @override
  int get hashCode => Object.hash(profileId, appearance, preferences);
}

Map<String, dynamic> _readMap(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is! Map || value.keys.any((key) => key is! String)) {
    throw FormatException(
      '${VrAvatarConstants.errAvatarPrefix}$key${VrAvatarConstants.errMustBeObjectSuffix}',
    );
  }
  return Map<String, dynamic>.from(value);
}
