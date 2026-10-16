import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vrlizate_avatar/vrlizate_avatar.dart';

Widget host(VrAvatarEditor editor) => MaterialApp(home: Scaffold(body: editor));

Future<void> reveal(WidgetTester tester, Finder target) async {
  await tester.scrollUntilVisible(
    target,
    200,
    scrollable: find.byType(Scrollable).first,
  );
  await tester.pumpAndSettle();
  await Scrollable.ensureVisible(tester.element(target), alignment: 0.5);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('non-human appearance controls share one saved identity', (
    tester,
  ) async {
    VrAvatarProfile? saved;
    await tester.pumpWidget(
      host(
        VrAvatarEditor(
          initialValue: VrAvatarProfile(profileId: 'same-owner'),
          displayName: 'Name',
          onSave: (value) => saved = value,
        ),
      ),
    );
    await tester.tap(find.byType(DropdownButtonFormField<VrAvatarSpecies>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Ajolote').last);
    await tester.pumpAndSettle();
    var preview = tester.widget<VrAvatarPreview>(find.byType(VrAvatarPreview));
    expect(preview.appearance.species, VrAvatarSpecies.axolotl);
    final feature = find.byKey(const ValueKey('avatar-feature-scale'));
    await reveal(tester, feature);
    tester.widget<Slider>(feature).onChanged!(1.3);
    await tester.pump();
    final pattern = find.byType(DropdownButtonFormField<VrAvatarPattern>);
    await reveal(tester, pattern);
    await tester.tap(pattern);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Franjas').last);
    await tester.pumpAndSettle();
    final save = find.byKey(const ValueKey('avatar-save'));
    await reveal(tester, save);
    await tester.tap(save);
    await tester.pumpAndSettle();
    expect(saved?.profileId, 'same-owner');
    expect(saved?.appearance.species, VrAvatarSpecies.axolotl);
    expect(saved?.appearance.featureScale, 1.3);
    expect(saved?.appearance.pattern, VrAvatarPattern.stripes);
    expect(tester.takeException(), isNull);
  });

  testWidgets('all species render at customization bounds without exceptions', (
    tester,
  ) async {
    for (final species in VrAvatarSpecies.values) {
      for (final pattern in VrAvatarPattern.values) {
        await tester.pumpWidget(
          MaterialApp(
            home: VrAvatarPreview(
              appearance: VrAvatarAppearance(
                species: species,
                pattern: pattern,
                heightMeters: 2.2,
                headScale: 1.25,
                featureScale: 1.4,
              ),
            ),
          ),
        );
        expect(tester.takeException(), isNull);
      }
    }
  });

  testWidgets(
    'draft choice is previewed and saved under the existing identity',
    (tester) async {
      VrAvatarProfile? previewed;
      VrAvatarProfile? saved;
      final original = VrAvatarProfile(profileId: 'neom-profile');
      await tester.pumpWidget(
        host(
          VrAvatarEditor(
            initialValue: original,
            displayName: 'Existing profile name',
            onChanged: (value) => previewed = value,
            onSave: (value) => saved = value,
          ),
        ),
      );
      await tester.tap(find.byType(DropdownButtonFormField<VrAvatarSpecies>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Robot').last);
      await tester.pumpAndSettle();
      expect(previewed?.appearance.style, VrAvatarStyle.robot);
      expect(original.appearance.style, VrAvatarStyle.explorer);
      final preview = tester.widget<VrAvatarPreview>(
        find.byType(VrAvatarPreview),
      );
      expect(preview.appearance.style, VrAvatarStyle.robot);
      await reveal(tester, find.byKey(const ValueKey('avatar-save')));
      await tester.tap(find.byKey(const ValueKey('avatar-save')));
      await tester.pumpAndSettle();
      expect(saved?.profileId, 'neom-profile');
      expect(saved?.appearance.style, VrAvatarStyle.robot);
      expect(find.text('Avatar guardado'), findsOneWidget);
    },
  );

  testWidgets('failed save retains draft and permits a successful retry', (
    tester,
  ) async {
    var attempts = 0;
    VrAvatarProfile? saved;
    await tester.pumpWidget(
      host(
        VrAvatarEditor(
          initialValue: VrAvatarProfile(profileId: 'profile'),
          displayName: 'Name',
          onSave: (value) async {
            attempts++;
            if (attempts == 1) throw StateError('storage unavailable');
            saved = value;
          },
        ),
      ),
    );
    final voice = find.byKey(const ValueKey('avatar-proximity-voice'));
    await reveal(tester, voice);
    await tester.tap(voice);
    await tester.pumpAndSettle();
    final save = find.byKey(const ValueKey('avatar-save'));
    await reveal(tester, save);
    await tester.tap(save);
    await tester.pumpAndSettle();
    expect(
      find.text('No se pudo guardar. Tus cambios siguen disponibles.'),
      findsOneWidget,
    );
    await reveal(tester, save);
    await tester.tap(save);
    await tester.pumpAndSettle();
    expect(saved?.preferences.proximityVoiceEnabled, isTrue);
    expect(attempts, 2);
  });

  testWidgets(
    'save is single flight and does not apply completion to new owner',
    (tester) async {
      final pending = Completer<void>();
      final saves = <String>[];
      Future<void> save(VrAvatarProfile value) {
        saves.add(value.profileId);
        return pending.future;
      }

      await tester.pumpWidget(
        host(
          VrAvatarEditor(
            initialValue: VrAvatarProfile(profileId: 'owner-one'),
            displayName: 'One',
            onSave: save,
          ),
        ),
      );
      final button = find.byKey(const ValueKey('avatar-save'));
      await reveal(tester, button);
      await tester.tap(button);
      await tester.pump();
      expect(tester.widget<FilledButton>(button).onPressed, isNull);
      expect(saves, ['owner-one']);
      await tester.pumpWidget(
        host(
          VrAvatarEditor(
            initialValue: VrAvatarProfile(
              profileId: 'owner-one',
              appearance: VrAvatarAppearance(style: VrAvatarStyle.orb),
            ),
            displayName: 'One updated externally',
            onSave: save,
          ),
        ),
      );
      expect(tester.widget<FilledButton>(button).onPressed, isNull);
      await tester.pumpWidget(
        host(
          VrAvatarEditor(
            initialValue: VrAvatarProfile(profileId: 'owner-two'),
            displayName: 'Two',
            onSave: save,
          ),
        ),
      );
      pending.complete();
      await tester.pumpAndSettle();
      expect(find.text('Avatar guardado'), findsNothing);
      expect(tester.widget<FilledButton>(button).onPressed, isNotNull);
      await reveal(tester, button);
      await tester.tap(button);
      await tester.pumpAndSettle();
      expect(saves, ['owner-one', 'owner-two']);
    },
  );

  testWidgets('host-provided labels and every preview style render', (
    tester,
  ) async {
    for (final style in VrAvatarStyle.values) {
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpWidget(
        host(
          VrAvatarEditor(
            initialValue: VrAvatarProfile(
              profileId: 'profile-${style.name}',
              appearance: VrAvatarAppearance(style: style, heightMeters: 2.2),
            ),
            displayName: 'Name',
            labels: const VrAvatarLabels(
              title: 'Avatar settings',
              save: 'Save',
            ),
            onSave: (_) {},
          ),
        ),
      );
      expect(find.text('Avatar settings'), findsOneWidget);
      await reveal(tester, find.byKey(const ValueKey('avatar-save')));
      expect(find.text('Save'), findsOneWidget);
      expect(tester.takeException(), isNull);
    }
  });
}
