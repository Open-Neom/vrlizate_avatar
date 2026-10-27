import 'package:flutter/foundation.dart';

import '../../utils/constants/vr_avatar_constants.dart';
import '../../utils/enums/vr_avatar_pattern.dart';
import '../../utils/enums/vr_avatar_species.dart';
import '../../utils/enums/vr_avatar_style.dart';
import 'vr_avatar_cosmetic.dart';

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
    this.cosmeticId,
  }) : species = species ?? _speciesForStyle(style ?? VrAvatarStyle.explorer) {
    if (style != null && style != this.style) {
      throw ArgumentError.value(
        style,
        VrAvatarConstants.keyStyle,
        VrAvatarConstants.errConflictingSpecies,
      );
    }
    _opaqueColor(bodyColorArgb, VrAvatarConstants.keyBodyColorArgb);
    _opaqueColor(accentColorArgb, VrAvatarConstants.keyAccentColorArgb);
    if (cosmeticId != null && !VrAvatarCosmeticCatalog.isKnown(cosmeticId!)) {
      throw ArgumentError.value(
        cosmeticId,
        'cosmeticId',
        'Unknown avatar cosmetic.',
      );
    }
    _range(
      heightMeters,
      VrAvatarConstants.keyHeightMeters,
      minHeightMeters,
      maxHeightMeters,
    );
    _range(
      headScale,
      VrAvatarConstants.keyHeadScale,
      minHeadScale,
      maxHeadScale,
    );
    _range(
      featureScale,
      VrAvatarConstants.keyFeatureScale,
      minFeatureScale,
      maxFeatureScale,
    );
  }

  static const double minHeightMeters = 1.0;
  static const double maxHeightMeters = 2.2;
  static const double minHeadScale = .8;
  static const double maxHeadScale = 1.25;
  static const double minFeatureScale = .6;
  static const double maxFeatureScale = 1.4;
  static const List<int> palette = <int>[
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

  /// One equipped built-in accessory. Availability is enforced by the host;
  /// importing a profile or sharing this string never grants a reward.
  final String? cosmeticId;

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
    String? cosmeticId,
    bool clearCosmetic = false,
  }) => VrAvatarAppearance(
    style: style,
    species: species ?? (style == null ? this.species : null),
    bodyColorArgb: bodyColorArgb ?? this.bodyColorArgb,
    accentColorArgb: accentColorArgb ?? this.accentColorArgb,
    heightMeters: heightMeters ?? this.heightMeters,
    headScale: headScale ?? this.headScale,
    featureScale: featureScale ?? this.featureScale,
    pattern: pattern ?? this.pattern,
    cosmeticId: clearCosmetic ? null : cosmeticId ?? this.cosmeticId,
  );

  Map<String, dynamic> toJson() => {
    VrAvatarConstants.keyStyle: style.name,
    VrAvatarConstants.keySpecies: species.name,
    VrAvatarConstants.keyBodyColorArgb: bodyColorArgb,
    VrAvatarConstants.keyAccentColorArgb: accentColorArgb,
    VrAvatarConstants.keyHeightMeters: heightMeters,
    VrAvatarConstants.keyHeadScale: headScale,
    VrAvatarConstants.keyFeatureScale: featureScale,
    VrAvatarConstants.keyPattern: pattern.name,
    if (cosmeticId != null) 'cosmeticId': cosmeticId,
  };

  factory VrAvatarAppearance.fromJson(Map<String, dynamic> json) {
    final style = _readEnum(
      json,
      VrAvatarConstants.keyStyle,
      VrAvatarStyle.values,
    );
    try {
      final cosmetic = json['cosmeticId'];
      if (json.containsKey('cosmeticId') && cosmetic is! String) {
        throw const FormatException('Avatar cosmeticId must be a string.');
      }
      return VrAvatarAppearance(
        style: style,
        species: json.containsKey(VrAvatarConstants.keySpecies)
            ? _readEnum(
                json,
                VrAvatarConstants.keySpecies,
                VrAvatarSpecies.values,
              )
            : null,
        bodyColorArgb: _readInt(json, VrAvatarConstants.keyBodyColorArgb),
        accentColorArgb: _readInt(json, VrAvatarConstants.keyAccentColorArgb),
        heightMeters: _readDouble(json, VrAvatarConstants.keyHeightMeters),
        headScale: json.containsKey(VrAvatarConstants.keyHeadScale)
            ? _readDouble(json, VrAvatarConstants.keyHeadScale)
            : 1,
        featureScale: json.containsKey(VrAvatarConstants.keyFeatureScale)
            ? _readDouble(json, VrAvatarConstants.keyFeatureScale)
            : 1,
        pattern: json.containsKey(VrAvatarConstants.keyPattern)
            ? _readEnum(
                json,
                VrAvatarConstants.keyPattern,
                VrAvatarPattern.values,
              )
            : VrAvatarPattern.solid,
        cosmeticId: cosmetic as String?,
      );
    } on ArgumentError catch (error) {
      throw FormatException(
        '${VrAvatarConstants.errInvalidAppearancePrefix}${error.name}${VrAvatarConstants.period}',
      );
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
      other.pattern == pattern &&
      other.cosmeticId == cosmeticId;

  @override
  int get hashCode => Object.hash(
    species,
    bodyColorArgb,
    accentColorArgb,
    heightMeters,
    headScale,
    featureScale,
    pattern,
    cosmeticId,
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
  if (matches.length != 1) {
    throw FormatException(
      '${VrAvatarConstants.errUnknownAvatarPrefix}$key${VrAvatarConstants.period}',
    );
  }
  return matches.single;
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

void _opaqueColor(int value, String name) {
  if (value < 0xff000000 || value > 0xffffffff) {
    throw ArgumentError.value(
      value,
      name,
      VrAvatarConstants.errExpectedOpaqueColor,
    );
  }
}

int _readInt(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is! int) {
    throw FormatException(
      '${VrAvatarConstants.errAvatarPrefix}$key${VrAvatarConstants.errMustBeIntegerSuffix}',
    );
  }
  return value;
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
