import '../model/vr_avatar_profile.dart';

/// Host-injected strings: use the existing SINT translation service if desired.
class VrAvatarLabels {
  const VrAvatarLabels({
    this.title = 'Tu avatar',
    this.appearance = 'Apariencia',
    this.style = 'Estilo',
    this.species = 'Especie',
    this.human = 'Humano',
    this.fox = 'Zorro',
    this.axolotl = 'Ajolote',
    this.sprout = 'Botánico',
    this.headSize = 'Tamaño de cabeza',
    this.featureSize = 'Tamaño de rasgos',
    this.pattern = 'Patrón',
    this.solid = 'Liso',
    this.spots = 'Manchas',
    this.stripes = 'Franjas',
    this.explorer = 'Explorador',
    this.robot = 'Robot',
    this.orb = 'Orbe',
    this.bodyColor = 'Color principal',
    this.accentColor = 'Color de detalles',
    this.virtualHeight = 'Altura virtual',
    this.preferences = 'Preferencias de realidad virtual',
    this.showOwnBody = 'Mostrar mi cuerpo virtual',
    this.showNameplates = 'Mostrar nombres de otros avatares',
    this.proximityVoice = 'Participar en voz de proximidad',
    this.voiceHint = 'La plataforma conecta el audio y solicita el micrófono.',
    this.personalSpace = 'Espacio personal',
    this.save = 'Guardar avatar',
    this.saving = 'Guardando…',
    this.saved = 'Avatar guardado',
    this.saveError = 'No se pudo guardar. Tus cambios siguen disponibles.',
  });

  final String title;
  final String appearance;
  final String style;
  final String species, human, fox, axolotl, sprout;
  final String headSize, featureSize, pattern, solid, spots, stripes;
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
