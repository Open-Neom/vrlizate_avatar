import 'package:flutter_test/flutter_test.dart';
import 'package:vrlizate_avatar/vrlizate_avatar.dart';

void main() {
  group('VrAvatarEmote & VrAvatarEmoteState', () {
    test('evaluates animated pose offsets and mouth openness for all emotes', () {
      for (final emote in VrAvatarEmote.values) {
        final state = VrAvatarEmoteState.evaluate(
          emote: emote,
          elapsedSeconds: 0.25,
          voiceAmplitude: 0.35,
        );
        expect(state.emote, emote);
        expect(state.elapsedSeconds, 0.25);
        expect(state.voiceAmplitude, 0.35);
        expect(state.mouthOpenness, inInclusiveRange(0.35, 1.0));
      }

      final waveState = VrAvatarEmoteState(
        emote: VrAvatarEmote.wave,
        elapsedSeconds: 0.1,
      );
      expect(waveState.pose.rightArmFlexion, greaterThan(0.5));
      expect(waveState.rightHandHeightOffset, greaterThan(0.2));

      final nodState = VrAvatarEmoteState(
        emote: VrAvatarEmote.nod,
        elapsedSeconds: 0.15,
      );
      expect(nodState.headPitchOffset, greaterThan(0.0));

      final cheerState = VrAvatarEmoteState(
        emote: VrAvatarEmote.cheer,
        elapsedSeconds: 0.2,
      );
      expect(cheerState.leftHandHeightOffset, greaterThan(0.4));
      expect(cheerState.rightHandHeightOffset, greaterThan(0.4));
      expect(cheerState.mouthOpenness, greaterThan(0.4));

      final pointState = VrAvatarEmoteState(
        emote: VrAvatarEmote.point,
        elapsedSeconds: 0.5,
      );
      expect(pointState.pose.rightArmFlexion, closeTo(1.35, 1e-6));

      final speakingState = VrAvatarEmoteState(
        emote: VrAvatarEmote.speaking,
        elapsedSeconds: 0.3,
        voiceAmplitude: 0.85,
      );
      expect(speakingState.mouthOpenness, greaterThanOrEqualTo(0.85));
    });
  });

  group('VrAvatarPresetCatalog', () {
    test('provides curated presets for every species', () {
      expect(VrAvatarPresetCatalog.presetIds.length, 6);
      expect(VrAvatarPresetCatalog.appearances.length, 6);

      for (final species in VrAvatarSpecies.values) {
        final appearance = VrAvatarPresetCatalog.defaultForSpecies(species);
        expect(appearance.species, species);
      }

      final profile = VrAvatarPresetCatalog.profileForPreset(
        presetId: VrAvatarConstants.presetCoralAxolotl,
        profileId: 'user-axolotl',
      );
      expect(profile.profileId, 'user-axolotl');
      expect(profile.appearance.species, VrAvatarSpecies.axolotl);

      expect(
        () => VrAvatarPresetCatalog.appearanceForPreset('unknown-preset'),
        throwsArgumentError,
      );
    });
  });

  group('VrAvatarShareCodeCodec', () {
    test('encodes and decodes full profile and appearance-only share codes', () {
      final original = VrAvatarProfile(
        profileId: 'owner-123',
        appearance: VrAvatarPresetCatalog.defaultForSpecies(
          VrAvatarSpecies.fox,
        ),
        preferences: VrAvatarPreferences(
          showOwnBody: true,
          showNameplates: false,
          proximityVoiceEnabled: true,
          personalSpaceMeters: 1.2,
        ),
      );

      final code = VrAvatarShareCodeCodec.encode(original);
      expect(code, startsWith(VrAvatarConstants.shareCodePrefix));

      final decoded = VrAvatarShareCodeCodec.decode(code);
      expect(decoded, original);

      final rebound = VrAvatarShareCodeCodec.decode(
        code,
        overrideProfileId: 'new-owner',
      );
      expect(rebound.profileId, 'new-owner');
      expect(rebound.appearance, original.appearance);

      final publicCode = VrAvatarShareCodeCodec.encode(
        original,
        includePreferences: false,
      );
      final publicDecoded = VrAvatarShareCodeCodec.decode(publicCode);
      expect(publicDecoded.appearance, original.appearance);
      expect(publicDecoded.preferences, VrAvatarPreferences());
      expect(
        VrAvatarShareCodeCodec.decodeAppearance(publicCode),
        original.appearance,
      );
    });

    test('rejects invalid share codes', () {
      for (final invalid in [
        '',
        'INVALID:abc',
        VrAvatarConstants.shareCodePrefix,
        '${VrAvatarConstants.shareCodePrefix}not-valid-base64!!!',
      ]) {
        expect(
          () => VrAvatarShareCodeCodec.decode(invalid),
          throwsFormatException,
        );
      }
    });
  });
}
