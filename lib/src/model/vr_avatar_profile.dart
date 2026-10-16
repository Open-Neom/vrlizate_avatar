import 'package:flutter/foundation.dart';

/// Legacy silhouettes retained for source and stored-profile compatibility.
/// New renderers and editors should use [VrAvatarAppearance.species].
enum VrAvatarStyle { explorer, robot, orb }

/// Built-in species with bounded customization and no executable asset data.
/// Humans are one option; a shared biped skeleton is not an avatar requirement.
enum VrAvatarSpecies { human, robot, orb, fox, axolotl, sprout }

enum VrAvatarPattern { solid, spots, stripes }

/// Public visual description. Height is virtual scale, not physical calibration.
///
/// Shapes and materials belong to each renderer. These immutable parameters
/// describe identity without coupling persistence to bones, URLs or a GPU.
@immutable
class VrAvatarAppearance {
  VrAvatarAppearance({
    VrAvatarStyle? style,
    VrAvatarSpecies? species,
    this.bodyColorArgb = 0xff3978c6,
    this.accentColorArgb = 0xff7ef0dd,
    this.heightMeters = 1.7,
    this.headScale = 1,
    this.featureScale = 1,
    this.pattern = VrAvatarPattern.solid,
  }) : species = species ?? _speciesForStyle(style ?? VrAvatarStyle.explorer) {
    if (style != null && style != this.style) {
      throw ArgumentError.value(style, 'style', 'Conflicting species.');
    }
    _opaqueColor(bodyColorArgb, 'bodyColorArgb');
    _opaqueColor(accentColorArgb, 'accentColorArgb');
    _range(heightMeters, 'heightMeters', minHeightMeters, maxHeightMeters);
    _range(headScale, 'headScale', minHeadScale, maxHeadScale);
    _range(featureScale, 'featureScale', minFeatureScale, maxFeatureScale);
  }

  static const minHeightMeters = 1.0;
  static const maxHeightMeters = 2.2;
  static const minHeadScale = .8;
  static const maxHeadScale = 1.25;
  static const minFeatureScale = .6;
  static const maxFeatureScale = 1.4;
  static const palette = <int>[
    0xff3978c6,
    0xff8258c9,
    0xffcc704d,
    0xff289b85,
    0xffd2ad45,
    0xff66869a,
  ];

  final VrAvatarSpecies species;
  final int bodyColorArgb;
  final int accentColorArgb;
  final double heightMeters;

  /// Relative head size. For an orb this changes its visible inner core.
  final double headScale;

  /// Relative size of ears, gills, leaves, antenna or orbital fins by species.
  final double featureScale;
  final VrAvatarPattern pattern;

  /// Lossy compatibility projection for hosts that only know the old styles.
  VrAvatarStyle get style => switch (species) {
    VrAvatarSpecies.robot => VrAvatarStyle.robot,
    VrAvatarSpecies.orb => VrAvatarStyle.orb,
    _ => VrAvatarStyle.explorer,
  };

  VrAvatarAppearance copyWith({
    VrAvatarStyle? style,
    VrAvatarSpecies? species,
    int? bodyColorArgb,
    int? accentColorArgb,
    double? heightMeters,
    double? headScale,
    double? featureScale,
    VrAvatarPattern? pattern,
  }) => VrAvatarAppearance(
    style: style,
    species: species ?? (style == null ? this.species : null),
    bodyColorArgb: bodyColorArgb ?? this.bodyColorArgb,
    accentColorArgb: accentColorArgb ?? this.accentColorArgb,
    heightMeters: heightMeters ?? this.heightMeters,
    headScale: headScale ?? this.headScale,
    featureScale: featureScale ?? this.featureScale,
    pattern: pattern ?? this.pattern,
  );

  Map<String, dynamic> toJson() => {
    'style': style.name,
    'species': species.name,
    'bodyColorArgb': bodyColorArgb,
    'accentColorArgb': accentColorArgb,
    'heightMeters': heightMeters,
    'headScale': headScale,
    'featureScale': featureScale,
    'pattern': pattern.name,
  };

  factory VrAvatarAppearance.fromJson(Map<String, dynamic> json) {
    final style = _readEnum(json, 'style', VrAvatarStyle.values);
    try {
      return VrAvatarAppearance(
        style: style,
        species: json.containsKey('species')
            ? _readEnum(json, 'species', VrAvatarSpecies.values)
            : null,
        bodyColorArgb: _readInt(json, 'bodyColorArgb'),
        accentColorArgb: _readInt(json, 'accentColorArgb'),
        heightMeters: _readDouble(json, 'heightMeters'),
        headScale: json.containsKey('headScale')
            ? _readDouble(json, 'headScale')
            : 1,
        featureScale: json.containsKey('featureScale')
            ? _readDouble(json, 'featureScale')
            : 1,
        pattern: json.containsKey('pattern')
            ? _readEnum(json, 'pattern', VrAvatarPattern.values)
            : VrAvatarPattern.solid,
      );
    } on ArgumentError catch (error) {
      throw FormatException('Invalid avatar appearance: ${error.name}.');
    }
  }

  @override
  bool operator ==(Object other) =>
      other is VrAvatarAppearance &&
      other.species == species &&
      other.bodyColorArgb == bodyColorArgb &&
      other.accentColorArgb == accentColorArgb &&
      other.heightMeters == heightMeters &&
      other.headScale == headScale &&
      other.featureScale == featureScale &&
      other.pattern == pattern;

  @override
  int get hashCode => Object.hash(
    species,
    bodyColorArgb,
    accentColorArgb,
    heightMeters,
    headScale,
    featureScale,
    pattern,
  );
}

VrAvatarSpecies _speciesForStyle(VrAvatarStyle style) => switch (style) {
  VrAvatarStyle.explorer => VrAvatarSpecies.human,
  VrAvatarStyle.robot => VrAvatarSpecies.robot,
  VrAvatarStyle.orb => VrAvatarSpecies.orb,
};

T _readEnum<T extends Enum>(
  Map<String, dynamic> json,
  String key,
  List<T> values,
) {
  final matches = values.where((value) => value.name == json[key]);
  if (matches.length != 1) throw FormatException('Unknown avatar $key.');
  return matches.single;
}

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
    _range(personalSpaceMeters, 'personalSpaceMeters', 0.4, 2.0);
  }

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
    'showOwnBody': showOwnBody,
    'showNameplates': showNameplates,
    'proximityVoiceEnabled': proximityVoiceEnabled,
    'personalSpaceMeters': personalSpaceMeters,
  };

  factory VrAvatarPreferences.fromJson(Map<String, dynamic> json) {
    try {
      return VrAvatarPreferences(
        showOwnBody: _readBool(json, 'showOwnBody'),
        showNameplates: _readBool(json, 'showNameplates'),
        proximityVoiceEnabled: _readBool(json, 'proximityVoiceEnabled'),
        personalSpaceMeters: _readDouble(json, 'personalSpaceMeters'),
      );
    } on ArgumentError catch (error) {
      throw FormatException('Invalid avatar preferences: ${error.name}.');
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
        profileId.length > 256 ||
        profileId.trim() != profileId ||
        RegExp(r'[\x00-\x1f\x7f]').hasMatch(profileId)) {
      throw ArgumentError.value(profileId, 'profileId', 'Invalid profile ID.');
    }
  }

  static const schemaVersion = 1;
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
    'preferences': preferences.toJson(),
  };

  /// Appearance-only announcement for an authorized world participant.
  /// Never broadcast the private persistence representation [toJson].
  Map<String, dynamic> toPublicJson() => {
    'schemaVersion': schemaVersion,
    'profileId': profileId,
    'appearance': appearance.toJson(),
  };

  factory VrAvatarProfile.fromJson(Map<String, dynamic> json) {
    if (json['schemaVersion'] != schemaVersion) {
      throw const FormatException('Unsupported avatar schemaVersion.');
    }
    final id = json['profileId'];
    if (id is! String) {
      throw const FormatException('Avatar profileId must be a string.');
    }
    try {
      return VrAvatarProfile(
        profileId: id,
        appearance: VrAvatarAppearance.fromJson(_readMap(json, 'appearance')),
        preferences: VrAvatarPreferences.fromJson(
          _readMap(json, 'preferences'),
        ),
      );
    } on ArgumentError catch (error) {
      throw FormatException('Invalid avatar profile: ${error.name}.');
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

void _range(double value, String name, double min, double max) {
  if (!value.isFinite || value < min || value > max) {
    throw ArgumentError.value(value, name, 'Expected $min–$max.');
  }
}

void _opaqueColor(int value, String name) {
  if (value < 0xff000000 || value > 0xffffffff) {
    throw ArgumentError.value(value, name, 'Expected opaque ARGB color.');
  }
}

int _readInt(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is! int) throw FormatException('Avatar $key must be an integer.');
  return value;
}

double _readDouble(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is! num || !value.isFinite) {
    throw FormatException('Avatar $key must be finite.');
  }
  return value.toDouble();
}

bool _readBool(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is! bool) throw FormatException('Avatar $key must be a boolean.');
  return value;
}

Map<String, dynamic> _readMap(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is! Map || value.keys.any((key) => key is! String)) {
    throw FormatException('Avatar $key must be an object.');
  }
  return Map<String, dynamic>.from(value);
}
