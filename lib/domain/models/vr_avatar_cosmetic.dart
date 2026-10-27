import 'package:flutter/foundation.dart';

/// A built-in visual accessory, never an asset URL, entitlement or inventory.
@immutable
final class VrAvatarCosmetic {
  const VrAvatarCosmetic({
    required this.id,
    required this.title,
    required this.description,
  });
  final String id, title, description;
}

/// Stable IDs understood by the preview and retained 3D avatar renderer.
/// The host derives availability from its local expedition progress.
abstract final class VrAvatarCosmeticCatalog {
  static const canopy = 'expedition_canopy';
  static const aurora = 'expedition_aurora';
  static const neon = 'expedition_neon';
  static const wayfinder = 'expedition_wayfinder';

  static const all = <VrAvatarCosmetic>[
    VrAvatarCosmetic(
      id: canopy,
      title: 'Insignia del dosel',
      description:
          'Dos hojas sobre una insignia de exploración. Completa Arrecifes.',
    ),
    VrAvatarCosmetic(
      id: aurora,
      title: 'Arco de aurora',
      description:
          'Un arco de luz junto a la cabeza. Completa el Archivo del museo.',
    ),
    VrAvatarCosmetic(
      id: neon,
      title: 'Baliza de neón',
      description:
          'Una baliza lateral con tres señales. Completa la Señal de neón.',
    ),
    VrAvatarCosmetic(
      id: wayfinder,
      title: 'Brújula del encuentro',
      description:
          'Una brújula de cuatro puntas. Llega al Festival de los encuentros.',
    ),
  ];

  static VrAvatarCosmetic? byId(String? id) {
    for (final cosmetic in all) {
      if (cosmetic.id == id) return cosmetic;
    }
    return null;
  }

  static bool isKnown(String id) => byId(id) != null;
}
