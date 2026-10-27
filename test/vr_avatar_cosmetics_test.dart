import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vrlizate_avatar/vrlizate_avatar.dart';

void main() {
  test('legacy appearance bytes omit the accessory and remain unchanged', () {
    final appearance = VrAvatarAppearance();
    expect(
      jsonEncode(appearance.toJson()),
      '{"style":"explorer","species":"human","bodyColorArgb":4281956550,"accentColorArgb":4286509277,"heightMeters":1.7,"headScale":1.0,"featureScale":1.0,"pattern":"solid"}',
    );
    expect(VrAvatarAppearance.fromJson(appearance.toJson()).cosmeticId, isNull);
  });

  test('four built-in accessories have stable unique IDs and display copy', () {
    expect(VrAvatarCosmeticCatalog.all.map((c) => c.id).toSet(), {
      'expedition_canopy',
      'expedition_aurora',
      'expedition_neon',
      'expedition_wayfinder',
    });
    for (final item in VrAvatarCosmeticCatalog.all) {
      expect(VrAvatarCosmeticCatalog.byId(item.id), same(item));
      expect(item.title, isNotEmpty);
      expect(item.description, isNotEmpty);
    }
    expect(VrAvatarCosmeticCatalog.byId('download://mesh'), isNull);
  });

  test('equipping and clearing preserve every species and personal choice', () {
    for (final species in VrAvatarSpecies.values) {
      final custom = VrAvatarAppearance(
        species: species,
        bodyColorArgb: 0xff8258c9,
        accentColorArgb: 0xffd2ad45,
        heightMeters: 1.95,
        headScale: 1.2,
        featureScale: .7,
        pattern: VrAvatarPattern.stripes,
      );
      for (final item in VrAvatarCosmeticCatalog.all) {
        final equipped = custom.copyWith(cosmeticId: item.id);
        expect(equipped.copyWith(clearCosmetic: true), custom);
        final data = equipped.toJson()..remove('cosmeticId');
        expect(data, custom.toJson());
        expect(
          equipped.copyWith(bodyColorArgb: 0xff3978c6).cosmeticId,
          item.id,
        );
        expect(equipped, isNot(custom));
      }
    }
  });

  test(
    'profile and share-code roundtrip keep accessory without an inventory',
    () {
      final original = VrAvatarProfile(
        profileId: 'owner-profile',
        appearance: VrAvatarAppearance(
          species: VrAvatarSpecies.axolotl,
          cosmeticId: VrAvatarCosmeticCatalog.aurora,
        ),
        preferences: VrAvatarPreferences(proximityVoiceEnabled: true),
      );
      final restored = VrAvatarProfile.fromJson(
        jsonDecode(jsonEncode(original.toJson())),
      );
      expect(restored, original);
      expect(restored.hashCode, original.hashCode);
      expect(restored.toPublicJson().containsKey('preferences'), isFalse);
      expect(
        VrAvatarShareCodeCodec.decode(VrAvatarShareCodeCodec.encode(original)),
        original,
      );
      expect(
        original.appearance.toJson().keys,
        isNot(contains('unlockedRewards')),
      );
    },
  );

  test(
    'unknown IDs and malformed optional fields never become asset inputs',
    () {
      for (final invalid in [
        null,
        1,
        [],
        'unknown',
        'https://example.org/model.glb',
      ]) {
        expect(
          () => VrAvatarAppearance.fromJson({
            ...VrAvatarAppearance().toJson(),
            'cosmeticId': invalid,
          }),
          throwsFormatException,
        );
      }
      expect(
        () => VrAvatarAppearance(cosmeticId: 'unknown'),
        throwsArgumentError,
      );
      final equipped = VrAvatarAppearance(
        cosmeticId: VrAvatarCosmeticCatalog.neon,
      );
      expect(
        equipped
            .copyWith(clearCosmetic: true)
            .toJson()
            .containsKey('cosmeticId'),
        isFalse,
      );
    },
  );

  testWidgets('every species preview paints every built-in accessory', (
    tester,
  ) async {
    for (final species in VrAvatarSpecies.values) {
      for (final item in VrAvatarCosmeticCatalog.all) {
        final appearance = VrAvatarAppearance(
          species: species,
          cosmeticId: item.id,
        );
        await tester.pumpWidget(
          MaterialApp(
            home: Center(child: VrAvatarPreview(appearance: appearance)),
          ),
        );
        expect(tester.takeException(), isNull, reason: '$species/${item.id}');
        expect(
          VrAvatarPainter(appearance).shouldRepaint(
            VrAvatarPainter(appearance.copyWith(clearCosmetic: true)),
          ),
          isTrue,
        );
      }
    }
  });
}
