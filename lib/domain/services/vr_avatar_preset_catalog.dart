import '../../utils/constants/vr_avatar_constants.dart';
import '../../utils/enums/vr_avatar_pattern.dart';
import '../../utils/enums/vr_avatar_species.dart';
import '../models/vr_avatar_appearance.dart';
import '../models/vr_avatar_preferences.dart';
import '../models/vr_avatar_profile.dart';

/// Curated, built-in avatar appearance and profile presets for VRlizate hosts.
abstract final class VrAvatarPresetCatalog {
  static final Map<String, VrAvatarAppearance> _presets =
      Map<String, VrAvatarAppearance>.unmodifiable({
        VrAvatarConstants.presetExplorer: VrAvatarAppearance(
          species: VrAvatarSpecies.human,
          bodyColorArgb: 0xff3978c6,
          accentColorArgb: 0xff7ef0dd,
          heightMeters: 1.72,
          headScale: 1.0,
          featureScale: 1.0,
          pattern: VrAvatarPattern.solid,
        ),
        VrAvatarConstants.presetCyberBot: VrAvatarAppearance(
          species: VrAvatarSpecies.robot,
          bodyColorArgb: 0xff66869a,
          accentColorArgb: 0xff7ef0dd,
          heightMeters: 1.85,
          headScale: 1.05,
          featureScale: 1.15,
          pattern: VrAvatarPattern.stripes,
        ),
        VrAvatarConstants.presetLumenOrb: VrAvatarAppearance(
          species: VrAvatarSpecies.orb,
          bodyColorArgb: 0xff8258c9,
          accentColorArgb: 0xffd2ad45,
          heightMeters: 1.55,
          headScale: 1.1,
          featureScale: 1.2,
          pattern: VrAvatarPattern.spots,
        ),
        VrAvatarConstants.presetEmberFox: VrAvatarAppearance(
          species: VrAvatarSpecies.fox,
          bodyColorArgb: 0xffcc704d,
          accentColorArgb: 0xffd2ad45,
          heightMeters: 1.60,
          headScale: 1.08,
          featureScale: 1.25,
          pattern: VrAvatarPattern.stripes,
        ),
        VrAvatarConstants.presetCoralAxolotl: VrAvatarAppearance(
          species: VrAvatarSpecies.axolotl,
          bodyColorArgb: 0xff8258c9,
          accentColorArgb: 0xff7ef0dd,
          heightMeters: 1.50,
          headScale: 1.12,
          featureScale: 1.30,
          pattern: VrAvatarPattern.spots,
        ),
        VrAvatarConstants.presetMossSprout: VrAvatarAppearance(
          species: VrAvatarSpecies.sprout,
          bodyColorArgb: 0xff289b85,
          accentColorArgb: 0xffd2ad45,
          heightMeters: 1.45,
          headScale: 1.05,
          featureScale: 1.20,
          pattern: VrAvatarPattern.spots,
        ),
      });

  /// Ordered preset identifiers available in the catalog.
  static List<String> get presetIds => _presets.keys.toList(growable: false);

  /// Immutable map of preset IDs to curated [VrAvatarAppearance] instances.
  static Map<String, VrAvatarAppearance> get appearancesById => _presets;

  /// Returns all curated presets as [VrAvatarAppearance] values.
  static List<VrAvatarAppearance> get appearances =>
      _presets.values.toList(growable: false);

  /// Looks up a curated [VrAvatarAppearance] by [presetId].
  static VrAvatarAppearance appearanceForPreset(String presetId) {
    final appearance = _presets[presetId];
    if (appearance == null) {
      throw ArgumentError.value(
        presetId,
        'presetId',
        '${VrAvatarConstants.errUnknownPresetPrefix}$presetId',
      );
    }
    return appearance;
  }

  /// Returns the default curated [VrAvatarAppearance] for [species].
  static VrAvatarAppearance defaultForSpecies(VrAvatarSpecies species) =>
      switch (species) {
        VrAvatarSpecies.human =>
          _presets[VrAvatarConstants.presetExplorer]!,
        VrAvatarSpecies.robot =>
          _presets[VrAvatarConstants.presetCyberBot]!,
        VrAvatarSpecies.orb =>
          _presets[VrAvatarConstants.presetLumenOrb]!,
        VrAvatarSpecies.fox =>
          _presets[VrAvatarConstants.presetEmberFox]!,
        VrAvatarSpecies.axolotl =>
          _presets[VrAvatarConstants.presetCoralAxolotl]!,
        VrAvatarSpecies.sprout =>
          _presets[VrAvatarConstants.presetMossSprout]!,
      };

  /// Builds a [VrAvatarProfile] for [profileId] from a curated [presetId].
  static VrAvatarProfile profileForPreset({
    required String presetId,
    String profileId = VrAvatarConstants.defaultPresetProfileId,
    VrAvatarPreferences? preferences,
  }) {
    return VrAvatarProfile(
      profileId: profileId,
      appearance: appearanceForPreset(presetId),
      preferences: preferences,
    );
  }
}
