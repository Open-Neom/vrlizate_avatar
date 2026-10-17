import '../utils/constants/vr_avatar_translation_constants.dart';
import '../utils/enums/vr_avatar_pattern.dart';
import '../utils/enums/vr_avatar_species.dart';
import '../utils/enums/vr_avatar_style.dart';

/// Host-injected strings: use the existing SINT translation service if desired.
class VrAvatarLabels {
  const VrAvatarLabels({
    this.title = VrAvatarTranslationConstants.title,
    this.appearance = VrAvatarTranslationConstants.appearance,
    this.style = VrAvatarTranslationConstants.style,
    this.species = VrAvatarTranslationConstants.species,
    this.human = VrAvatarTranslationConstants.human,
    this.fox = VrAvatarTranslationConstants.fox,
    this.axolotl = VrAvatarTranslationConstants.axolotl,
    this.sprout = VrAvatarTranslationConstants.sprout,
    this.headSize = VrAvatarTranslationConstants.headSize,
    this.featureSize = VrAvatarTranslationConstants.featureSize,
    this.pattern = VrAvatarTranslationConstants.pattern,
    this.solid = VrAvatarTranslationConstants.solid,
    this.spots = VrAvatarTranslationConstants.spots,
    this.stripes = VrAvatarTranslationConstants.stripes,
    this.explorer = VrAvatarTranslationConstants.explorer,
    this.robot = VrAvatarTranslationConstants.robot,
    this.orb = VrAvatarTranslationConstants.orb,
    this.bodyColor = VrAvatarTranslationConstants.bodyColor,
    this.accentColor = VrAvatarTranslationConstants.accentColor,
    this.virtualHeight = VrAvatarTranslationConstants.virtualHeight,
    this.preferences = VrAvatarTranslationConstants.preferences,
    this.showOwnBody = VrAvatarTranslationConstants.showOwnBody,
    this.showNameplates = VrAvatarTranslationConstants.showNameplates,
    this.proximityVoice = VrAvatarTranslationConstants.proximityVoice,
    this.voiceHint = VrAvatarTranslationConstants.voiceHint,
    this.personalSpace = VrAvatarTranslationConstants.personalSpace,
    this.save = VrAvatarTranslationConstants.save,
    this.saving = VrAvatarTranslationConstants.saving,
    this.saved = VrAvatarTranslationConstants.saved,
    this.saveError = VrAvatarTranslationConstants.saveError,
  });

  final String title;
  final String appearance;
  final String style;
  final String species;
  final String human;
  final String fox;
  final String axolotl;
  final String sprout;
  final String headSize;
  final String featureSize;
  final String pattern;
  final String solid;
  final String spots;
  final String stripes;
  final String explorer;
  final String robot;
  final String orb;
  final String bodyColor;
  final String accentColor;
  final String virtualHeight;
  final String preferences;
  final String showOwnBody;
  final String showNameplates;
  final String proximityVoice;
  final String voiceHint;
  final String personalSpace;
  final String save;
  final String saving;
  final String saved;
  final String saveError;

  String speciesName(VrAvatarSpecies value) => switch (value) {
    VrAvatarSpecies.human => human,
    VrAvatarSpecies.robot => robot,
    VrAvatarSpecies.orb => orb,
    VrAvatarSpecies.fox => fox,
    VrAvatarSpecies.axolotl => axolotl,
    VrAvatarSpecies.sprout => sprout,
  };

  String patternName(VrAvatarPattern value) => switch (value) {
    VrAvatarPattern.solid => solid,
    VrAvatarPattern.spots => spots,
    VrAvatarPattern.stripes => stripes,
  };

  String styleName(VrAvatarStyle value) => switch (value) {
    VrAvatarStyle.explorer => explorer,
    VrAvatarStyle.robot => robot,
    VrAvatarStyle.orb => orb,
  };
}
