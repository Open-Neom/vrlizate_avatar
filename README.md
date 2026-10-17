# vrlizate_avatar

The avatar extension of an existing Open Neom profile. This package owns avatar
appearance, social emotes, curated presets, share codes, and personal VR
preferences, with a lightweight Flutter editor and a 2D illustration suitable
for an editor or spatial room texture.

It does not replace `neom_profile`, create accounts, introduce another state
manager, or duplicate IPD, tracking, joystick or viewer calibration from
`vrlizate_scene` and `vrlizate_joystick`.

```dart
VrAvatarEditor(
  initialValue: avatarForCurrentProfile,
  displayName: profileService.profile.name,
  onSave: (avatar) => avatarStore.save(avatar.profileId, avatar.toJson()),
)
```

The host obtains `profileId` from its existing authenticated profile service and
applies its AuthGuard. The ID in this model is a reference, never authentication
proof. Scope storage by authenticated owner; never accept a claimed profile ID
as authorization. The editor reports save failures without discarding the draft
and ignores stale save completions when the host changes identity.

## Spatial rooms and rendering

`VrAvatarAppearance.species` selects a human, robot, floating orb, fox, axolotl
or botanical being (`human`, `robot`, `orb`, `fox`, `axolotl`, `sprout`). Every
species supports opaque ARGB body/accent colors, virtual height (1–2.2 m), head
scale (0.8–1.25), feature scale (0.6–1.4), and `solid`, `spots` or `stripes`
patterns. Feature scale changes ears, gills, leaves, antenna or orbital fins;
for an orb, head scale changes its core. `copyWith` validates changes.

```dart
final appearance = VrAvatarAppearance(
  species: VrAvatarSpecies.axolotl,
  bodyColorArgb: 0xff8258c9,
  accentColorArgb: 0xff7ef0dd,
  headScale: 1.1,
  featureScale: 1.25,
  pattern: VrAvatarPattern.spots,
);
```

## Social Emotes, Presets & Share Codes (1.0.0)

- **`VrAvatarEmote` & `VrAvatarEmoteState`**: Evaluate animated head/hand pose
  offsets and voice-amplitude mouth openness for `neutral`, `wave`, `nod`,
  `cheer`, `point`, and `speaking` at any `elapsedSeconds`.
- **`VrAvatarPresetCatalog`**: Access curated built-in appearances and default
  species presets (`explorer`, `cyber-bot`, `lumen-orb`, `ember-fox`,
  `coral-axolotl`, `moss-sprout`).
- **`VrAvatarShareCodeCodec`**: Encode and decode `VrAvatarProfile` into compact
  `VRLZ-AV1:` base64url strings for cross-device sharing.

## Persistence, presence and preferences

- `VrAvatarProfile.toJson()` / `fromJson()` are the private versioned persistence
  representation. Unsupported schemas, missing data and invalid values fail
  explicitly instead of silently changing the user's settings.
- `toPublicJson()` includes only schema, profile reference and appearance. It
  excludes private preferences.
- `showOwnBody`, `showNameplates`, `personalSpaceMeters` and
  `proximityVoiceEnabled` are **preferences for a consuming host**, not automatic
  engine behavior.
- Localized `VrAvatarLabels` can be populated by SINT without a new translation
  framework. Spanish labels are provided by default via
  `VrAvatarTranslationConstants`.

## Validation

Run `flutter test` and `flutter analyze`.
