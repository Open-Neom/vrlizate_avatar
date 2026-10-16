# vrlizate_avatar

The avatar extension of an existing Open Neom profile. This package owns avatar
appearance and personal VR preferences, with a lightweight Flutter editor and
an illustration suitable for an editor or spatial room texture.

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
for an orb, head scale changes its core. `copyWith` validates changes. The
editor exposes these options and keeps its preview isolated in a
`RepaintBoundary`; it has no animation timer or per-frame reactive updates.

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

The schema remains v1 beta. Old documents containing only `style`, colors and
height receive neutral detail scales and a solid pattern; old styles map to
human, robot and orb. `style` remains a compatibility API and JSON field. It is
a **lossy projection** for the new organic species, so new hosts must persist
`species` and consume it when rendering. Conflicting style/species values or
unknown and out-of-range customization fail explicitly. Renderers should reuse
geometry and update transforms/materials for customization instead of creating
new downloadable models for each combination.

Use `VrAvatarPreview(appearance: avatar.appearance)` in a room's rasterized
widget and change the immutable model using the existing room actions and
joystick. The ordinary `VrAvatarEditor` form is for hosts that receive Flutter
touch/keyboard input; a texture alone does not forward those events.

The preview is a 2D illustration. Actual tracked, remote or first-person 3D
avatars must be rendered by a scene adapter using the same appearance and world
pose. The package intentionally has no renderer or external model dependency.

## Persistence, presence and preferences

- `VrAvatarProfile.toJson()` / `fromJson()` are the private versioned persistence
  representation. Unsupported schemas, missing data and invalid values fail
  explicitly instead of silently changing the user's settings.
- `toPublicJson()` includes only schema, profile reference and appearance. It
  excludes private preferences. A world transport still needs authentication,
  visibility/blocking rules, authority and validation before publishing it.
- `showOwnBody`, `showNameplates`, `personalSpaceMeters` and
  `proximityVoiceEnabled` are **preferences for a consuming host**, not automatic
  engine behavior. Voice is disabled by default; saving a preference does not
  open the microphone or request permission. The audio/session host applies
  consent, operating-system permission and world membership.
- Virtual height is visual scale; it does not recalibrate physical eye height.
- Localized `VrAvatarLabels` can be populated by SINT without a new translation
  framework. Spanish labels are provided by default.

## Validation

Run `flutter test` and `flutter analyze`. Tests cover v1 migration, non-human species round trips, bounded
customization, public/private separation, identity-preserving edits, failed-save
retry, concurrent saves and identity changes during asynchronous persistence.
