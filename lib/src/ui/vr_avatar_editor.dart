import 'dart:async';

import 'package:flutter/material.dart';

import '../model/vr_avatar_profile.dart';
import 'vr_avatar_labels.dart';
import 'vr_avatar_preview.dart';

/// An embeddable form. The host owns identity, guards, persistence and navigation.
///
/// [onChanged] is a local preview callback; [onSave] commits a validated profile.
/// The form neither uploads appearance nor starts audio by itself. For a spatial
/// room, drive the same immutable models with joystick actions and render
/// [VrAvatarPreview] in the room texture instead of expecting touch input here.
class VrAvatarEditor extends StatefulWidget {
  const VrAvatarEditor({
    super.key,
    required this.initialValue,
    required this.displayName,
    required this.onSave,
    this.onChanged,
    this.labels = const VrAvatarLabels(),
  });

  final VrAvatarProfile initialValue;
  final String displayName;
  final FutureOr<void> Function(VrAvatarProfile value) onSave;
  final ValueChanged<VrAvatarProfile>? onChanged;
  final VrAvatarLabels labels;

  @override
  State<VrAvatarEditor> createState() => _VrAvatarEditorState();
}

class _VrAvatarEditorState extends State<VrAvatarEditor> {
  late VrAvatarProfile _draft = widget.initialValue;
  bool _dirty = false;
  bool _saving = false;
  bool _saved = false;
  bool _failed = false;
  int _saveGeneration = 0;

  @override
  void didUpdateWidget(VrAvatarEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    final identityChanged =
        oldWidget.initialValue.profileId != widget.initialValue.profileId;
    if (identityChanged ||
        (!_dirty &&
            !_saving &&
            oldWidget.initialValue != widget.initialValue)) {
      _draft = widget.initialValue;
      _dirty = false;
      _saved = false;
      _failed = false;
      _saving = false;
      _saveGeneration++;
    }
  }

  void _change(VrAvatarProfile value) {
    setState(() {
      _draft = value;
      _dirty = true;
      _saved = false;
      _failed = false;
    });
    widget.onChanged?.call(value);
  }

  Future<void> _save() async {
    if (_saving) return;
    final value = _draft;
    final generation = ++_saveGeneration;
    setState(() {
      _saving = true;
      _saved = false;
      _failed = false;
    });
    try {
      await widget.onSave(value);
      if (!mounted || generation != _saveGeneration) return;
      setState(() {
        _dirty = _draft != value;
        _saved = !_dirty;
      });
    } catch (_) {
      if (!mounted || generation != _saveGeneration) return;
      setState(() => _failed = true);
    } finally {
      if (mounted && generation == _saveGeneration) {
        setState(() => _saving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final labels = widget.labels;
    final appearance = _draft.appearance;
    final preferences = _draft.preferences;
    final theme = Theme.of(context);
    return ListView(
      shrinkWrap: true,
      padding: const EdgeInsets.all(20),
      children: [
        Text(labels.title, style: theme.textTheme.headlineSmall),
        if (widget.displayName.isNotEmpty)
          Text(widget.displayName, style: theme.textTheme.titleMedium),
        Center(
          child: VrAvatarPreview(
            appearance: appearance,
            semanticLabel:
                '${labels.title}: ${labels.speciesName(appearance.species)}',
          ),
        ),
        Text(labels.appearance, style: theme.textTheme.titleLarge),
        const SizedBox(height: 12),
        DropdownButtonFormField<VrAvatarSpecies>(
          key: ValueKey('avatar-species-${appearance.species.name}'),
          initialValue: appearance.species,
          decoration: InputDecoration(labelText: labels.species),
          items: [
            for (final species in VrAvatarSpecies.values)
              DropdownMenuItem(
                value: species,
                child: Text(labels.speciesName(species)),
              ),
          ],
          onChanged: _saving
              ? null
              : (species) {
                  if (species != null) {
                    _change(
                      _draft.copyWith(
                        appearance: appearance.copyWith(species: species),
                      ),
                    );
                  }
                },
        ),
        const SizedBox(height: 16),
        _palette(
          labels.bodyColor,
          appearance.bodyColorArgb,
          (color) => _change(
            _draft.copyWith(
              appearance: appearance.copyWith(bodyColorArgb: color),
            ),
          ),
        ),
        const SizedBox(height: 12),
        _palette(
          labels.accentColor,
          appearance.accentColorArgb,
          (color) => _change(
            _draft.copyWith(
              appearance: appearance.copyWith(accentColorArgb: color),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          '${labels.virtualHeight}: ${appearance.heightMeters.toStringAsFixed(2)} m',
        ),
        Slider(
          key: const ValueKey('avatar-height'),
          value: appearance.heightMeters,
          min: VrAvatarAppearance.minHeightMeters,
          max: VrAvatarAppearance.maxHeightMeters,
          divisions: 24,
          label: '${appearance.heightMeters.toStringAsFixed(2)} m',
          onChanged: _saving
              ? null
              : (value) => _change(
                  _draft.copyWith(
                    appearance: appearance.copyWith(heightMeters: value),
                  ),
                ),
        ),
        _proportion(
          key: 'avatar-head-scale',
          title: labels.headSize,
          value: appearance.headScale,
          min: VrAvatarAppearance.minHeadScale,
          max: VrAvatarAppearance.maxHeadScale,
          onChanged: (value) => _change(
            _draft.copyWith(appearance: appearance.copyWith(headScale: value)),
          ),
        ),
        _proportion(
          key: 'avatar-feature-scale',
          title: labels.featureSize,
          value: appearance.featureScale,
          min: VrAvatarAppearance.minFeatureScale,
          max: VrAvatarAppearance.maxFeatureScale,
          onChanged: (value) => _change(
            _draft.copyWith(
              appearance: appearance.copyWith(featureScale: value),
            ),
          ),
        ),
        DropdownButtonFormField<VrAvatarPattern>(
          key: ValueKey('avatar-pattern-${appearance.pattern.name}'),
          initialValue: appearance.pattern,
          decoration: InputDecoration(labelText: labels.pattern),
          items: [
            for (final pattern in VrAvatarPattern.values)
              DropdownMenuItem(
                value: pattern,
                child: Text(labels.patternName(pattern)),
              ),
          ],
          onChanged: _saving
              ? null
              : (pattern) {
                  if (pattern != null) {
                    _change(
                      _draft.copyWith(
                        appearance: appearance.copyWith(pattern: pattern),
                      ),
                    );
                  }
                },
        ),
        const SizedBox(height: 24),
        Text(labels.preferences, style: theme.textTheme.titleLarge),
        SwitchListTile(
          key: const ValueKey('avatar-own-body'),
          contentPadding: EdgeInsets.zero,
          title: Text(labels.showOwnBody),
          value: preferences.showOwnBody,
          onChanged: _saving
              ? null
              : (value) => _change(
                  _draft.copyWith(
                    preferences: preferences.copyWith(showOwnBody: value),
                  ),
                ),
        ),
        SwitchListTile(
          key: const ValueKey('avatar-nameplates'),
          contentPadding: EdgeInsets.zero,
          title: Text(labels.showNameplates),
          value: preferences.showNameplates,
          onChanged: _saving
              ? null
              : (value) => _change(
                  _draft.copyWith(
                    preferences: preferences.copyWith(showNameplates: value),
                  ),
                ),
        ),
        SwitchListTile(
          key: const ValueKey('avatar-proximity-voice'),
          contentPadding: EdgeInsets.zero,
          title: Text(labels.proximityVoice),
          subtitle: Text(labels.voiceHint),
          value: preferences.proximityVoiceEnabled,
          onChanged: _saving
              ? null
              : (value) => _change(
                  _draft.copyWith(
                    preferences: preferences.copyWith(
                      proximityVoiceEnabled: value,
                    ),
                  ),
                ),
        ),
        Text(
          '${labels.personalSpace}: ${preferences.personalSpaceMeters.toStringAsFixed(1)} m',
        ),
        Slider(
          key: const ValueKey('avatar-personal-space'),
          value: preferences.personalSpaceMeters,
          min: 0.4,
          max: 2,
          divisions: 16,
          label: '${preferences.personalSpaceMeters.toStringAsFixed(1)} m',
          onChanged: _saving
              ? null
              : (value) => _change(
                  _draft.copyWith(
                    preferences: preferences.copyWith(
                      personalSpaceMeters: value,
                    ),
                  ),
                ),
        ),
        if (_failed || _saved)
          Semantics(
            liveRegion: true,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                _failed ? labels.saveError : labels.saved,
                style: TextStyle(
                  color: _failed ? theme.colorScheme.error : null,
                ),
              ),
            ),
          ),
        FilledButton(
          key: const ValueKey('avatar-save'),
          onPressed: _saving ? null : _save,
          child: Text(_saving ? labels.saving : labels.save),
        ),
      ],
    );
  }

  Widget _proportion({
    required String key,
    required String title,
    required double value,
    required double min,
    required double max,
    required ValueChanged<double> onChanged,
  }) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text('$title: ${(value * 100).round()}%'),
      Slider(
        key: ValueKey(key),
        value: value,
        min: min,
        max: max,
        divisions: 20,
        label: '${(value * 100).round()}%',
        semanticFormatterCallback: (value) =>
            '$title ${(value * 100).round()}%',
        onChanged: _saving ? null : onChanged,
      ),
    ],
  );

  Widget _palette(String title, int selected, ValueChanged<int> onSelected) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final color in {...VrAvatarAppearance.palette, selected})
                Semantics(
                  label: '$title #${color.toRadixString(16).substring(2)}',
                  selected: color == selected,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Color(color),
                      foregroundColor: Colors.white,
                      minimumSize: const Size(48, 48),
                      padding: EdgeInsets.zero,
                      shape: const CircleBorder(),
                      side: BorderSide(
                        width: color == selected ? 3 : 1,
                        color: color == selected
                            ? Theme.of(context).colorScheme.onSurface
                            : Colors.transparent,
                      ),
                    ),
                    onPressed: _saving ? null : () => onSelected(color),
                    child: color == selected
                        ? const Icon(
                            Icons.check,
                            shadows: [Shadow(blurRadius: 2)],
                          )
                        : const SizedBox.shrink(),
                  ),
                ),
            ],
          ),
        ],
      );
}
