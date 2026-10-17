# Changelog

## 1.0.0

- Promoted `vrlizate_avatar` to stable `1.0.0` following the Open Neom modular directory architecture (`lib/utils/constants/`, `lib/utils/enums/`, `lib/domain/models/`, `lib/domain/services/`, `lib/ui/`).
- Split all multi-declaration files into single-declaration files while keeping `lib/src/**` barrel re-exports for backward compatibility.
- Centralized all UI strings and keys into `VrAvatarConstants` and `VrAvatarTranslationConstants`.
- Added `VrAvatarEmote` (`neutral`, `wave`, `nod`, `cheer`, `point`, `speaking`) and `VrAvatarEmoteState` for animated head/hand pose offsets and voice-amplitude mouth openness.
- Added `VrAvatarPresetCatalog` with curated appearances across all built-in species (`human`, `robot`, `orb`, `fox`, `axolotl`, `sprout`).
- Added `VrAvatarShareCodeCodec` to encode and decode `VrAvatarProfile` and `VrAvatarAppearance` into compact `VRLZ-AV1:` base64url share codes.

## 0.1.0

- Added `VrAvatarPose` (walk, seated, wave, blink, head look/nod/tilt, smooth `lerp`) and `VrShoulderKinematics` (abduction-first ordering and clavicle lift/forward shift).
- Added validated avatar appearance and private VR preference models.
- Added host-owned editor, appearance preview and injectable labels.
- Kept identity, persistence, authentication, rendering and microphone activation in the host.
