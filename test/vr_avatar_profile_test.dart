import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:vrlizate_avatar/vrlizate_avatar.dart';

void main() {
  test('legacy v1 profiles infer species and neutral customization', () {
    for (final (style, species) in [
      (VrAvatarStyle.explorer, VrAvatarSpecies.human),
      (VrAvatarStyle.robot, VrAvatarSpecies.robot),
      (VrAvatarStyle.orb, VrAvatarSpecies.orb),
    ]) {
      final legacy = {
        'schemaVersion': 1,
        'profileId': 'legacy-profile',
        'appearance': {
          'style': style.name,
          'bodyColorArgb': 0xff3978c6,
          'accentColorArgb': 0xff7ef0dd,
          'heightMeters': 1.7,
        },
        'preferences': VrAvatarPreferences().toJson(),
      };
      final restored = VrAvatarProfile.fromJson(legacy);
      expect(restored.appearance.species, species);
      expect(restored.appearance.headScale, 1);
      expect(restored.appearance.featureScale, 1);
      expect(restored.appearance.pattern, VrAvatarPattern.solid);
      expect(restored.toJson()['schemaVersion'], 1);
      expect(restored.appearance.style, style);
    }
  });

  test(
    'non-human species preserve customization in public and private data',
    () {
      for (final species in VrAvatarSpecies.values) {
        final appearance = VrAvatarAppearance(
          species: species,
          headScale: 1.15,
          featureScale: 1.3,
          pattern: VrAvatarPattern.spots,
        );
        final avatar = VrAvatarProfile(
          profileId: 'neom-profile',
          appearance: appearance,
        );
        final restored = VrAvatarProfile.fromJson(
          jsonDecode(jsonEncode(avatar.toJson())) as Map<String, dynamic>,
        );
        expect(restored, avatar);
        expect(restored.hashCode, avatar.hashCode);
        expect(avatar.toPublicJson()['appearance'], appearance.toJson());
      }
    },
  );

  test(
    'species changes preserve colors and details, legacy style remains usable',
    () {
      final fox = VrAvatarAppearance(
        species: VrAvatarSpecies.fox,
        headScale: 1.2,
        featureScale: .7,
        pattern: VrAvatarPattern.stripes,
      );
      final plant = fox.copyWith(species: VrAvatarSpecies.sprout);
      expect(plant.species, VrAvatarSpecies.sprout);
      expect(plant.style, VrAvatarStyle.explorer);
      expect(plant.headScale, fox.headScale);
      expect(plant.featureScale, fox.featureScale);
      expect(plant.pattern, fox.pattern);
      expect(
        plant.copyWith(bodyColorArgb: 0xff8258c9).species,
        VrAvatarSpecies.sprout,
      );
      expect(
        plant.copyWith(style: VrAvatarStyle.robot).species,
        VrAvatarSpecies.robot,
      );
      expect(fox.species, VrAvatarSpecies.fox);
    },
  );

  test('malformed customization and conflicting species are rejected', () {
    final baseline = VrAvatarAppearance(species: VrAvatarSpecies.fox).toJson();
    for (final (field, invalid) in <(String, Object?)>[
      ('species', 'download://alien'),
      ('species', null),
      ('species', VrAvatarSpecies.robot.name),
      ('pattern', 'custom-script'),
      ('headScale', .79),
      ('headScale', 1.26),
      ('headScale', double.nan),
      ('featureScale', .59),
      ('featureScale', 1.41),
      ('featureScale', '1.0'),
    ]) {
      expect(
        () => VrAvatarAppearance.fromJson({...baseline, field: invalid}),
        throwsFormatException,
        reason: '$field=$invalid',
      );
    }
    expect(
      () => VrAvatarAppearance(
        species: VrAvatarSpecies.fox,
        style: VrAvatarStyle.orb,
      ),
      throwsArgumentError,
    );
  });

  test('private persistence round trip preserves all avatar choices', () {
    final value = VrAvatarProfile(
      profileId: 'existing-neom-profile',
      appearance: VrAvatarAppearance(
        style: VrAvatarStyle.robot,
        bodyColorArgb: 0xff8258c9,
        accentColorArgb: 0xffcc704d,
        heightMeters: 1.95,
      ),
      preferences: VrAvatarPreferences(
        showOwnBody: true,
        showNameplates: false,
        proximityVoiceEnabled: true,
        personalSpaceMeters: 1.5,
      ),
    );
    final decoded =
        jsonDecode(jsonEncode(value.toJson())) as Map<String, dynamic>;
    expect(VrAvatarProfile.fromJson(decoded), value);
    expect(VrAvatarProfile.fromJson(decoded).hashCode, value.hashCode);
  });

  test(
    'public announcement excludes local preferences and account details',
    () {
      final value = VrAvatarProfile(
        profileId: 'existing-neom-profile',
        preferences: VrAvatarPreferences(proximityVoiceEnabled: true),
      );
      final publicValue = value.toPublicJson();
      expect(publicValue.keys.toSet(), {
        'schemaVersion',
        'profileId',
        'appearance',
      });
      expect(jsonEncode(publicValue), isNot(contains('proximityVoiceEnabled')));
      expect(publicValue['appearance'], value.appearance.toJson());
    },
  );

  test('editing retains identity and does not mutate the original', () {
    final original = VrAvatarProfile(profileId: 'profile-one');
    final edited = original.copyWith(
      appearance: original.appearance.copyWith(style: VrAvatarStyle.orb),
      preferences: original.preferences.copyWith(showOwnBody: true),
    );
    expect(edited.profileId, original.profileId);
    expect(original.appearance.style, VrAvatarStyle.explorer);
    expect(original.preferences.showOwnBody, isFalse);
    expect(edited.appearance.style, VrAvatarStyle.orb);
    expect(edited.preferences.showOwnBody, isTrue);
    expect(edited.preferences.proximityVoiceEnabled, isFalse);
  });

  test('invalid identity references are rejected', () {
    for (final id in [
      '',
      ' profile',
      'profile ',
      'profile\nother',
      'a' * 257,
    ]) {
      expect(() => VrAvatarProfile(profileId: id), throwsArgumentError);
    }
  });

  test('appearance accepts only opaque colors and finite bounded height', () {
    for (final color in [-1, 0x803978c6, 0x100000000]) {
      expect(
        () => VrAvatarAppearance(bodyColorArgb: color),
        throwsArgumentError,
      );
      expect(
        () => VrAvatarAppearance(accentColorArgb: color),
        throwsArgumentError,
      );
    }
    for (final height in [double.nan, double.infinity, 0.9, 2.3]) {
      expect(
        () => VrAvatarAppearance(heightMeters: height),
        throwsArgumentError,
      );
    }
    expect(VrAvatarAppearance(heightMeters: 1).heightMeters, 1);
    expect(VrAvatarAppearance(heightMeters: 2.2).heightMeters, 2.2);
  });

  test('private preferences validate personal space', () {
    for (final distance in [double.nan, double.infinity, 0.3, 2.1]) {
      expect(
        () => VrAvatarPreferences(personalSpaceMeters: distance),
        throwsArgumentError,
      );
    }
  });

  test('malformed persisted documents fail explicitly instead of clamping', () {
    final baseline = VrAvatarProfile(profileId: 'profile').toJson();
    for (final field in [
      'appearance',
      'preferences',
      'profileId',
      'schemaVersion',
    ]) {
      final json = {...baseline}..remove(field);
      expect(() => VrAvatarProfile.fromJson(json), throwsFormatException);
    }
    expect(
      () => VrAvatarProfile.fromJson({...baseline, 'schemaVersion': 2}),
      throwsFormatException,
    );
    expect(
      () => VrAvatarProfile.fromJson({
        ...baseline,
        'profileId': 'profile\tother',
      }),
      throwsFormatException,
    );
    expect(
      () => VrAvatarProfile.fromJson({...baseline, 'appearance': []}),
      throwsFormatException,
    );
    final appearance = baseline['appearance'] as Map<String, dynamic>;
    for (final invalid in <Map<String, dynamic>>[
      {...appearance, 'style': 'untrusted-download'},
      {...appearance, 'heightMeters': '1.7'},
      {...appearance, 'heightMeters': double.nan},
      {...appearance, 'heightMeters': 10},
      {...appearance, 'bodyColorArgb': 0x00000000},
      {...appearance, 'accentColorArgb': 'blue'},
    ]) {
      expect(
        () => VrAvatarProfile.fromJson({...baseline, 'appearance': invalid}),
        throwsFormatException,
      );
    }
    final preferences = baseline['preferences'] as Map<String, dynamic>;
    expect(
      () => VrAvatarProfile.fromJson({
        ...baseline,
        'preferences': {...preferences, 'proximityVoiceEnabled': 'true'},
      }),
      throwsFormatException,
    );
  });
}
