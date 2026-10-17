import 'package:flutter/material.dart';

import '../domain/models/vr_avatar_appearance.dart';
import '../utils/constants/vr_avatar_translation_constants.dart';
import 'vr_avatar_painter.dart';

/// A lightweight species preview for editors and spatial UI textures.
///
/// This is an illustration, not a tracked 3D renderer. Its immutable appearance
/// is also consumed by scene adapters. There is no timer, download or state
/// manager; repainting is isolated and happens only when appearance changes.
class VrAvatarPreview extends StatelessWidget {
  const VrAvatarPreview({
    super.key,
    required this.appearance,
    this.size = 180,
    this.semanticLabel = VrAvatarTranslationConstants.defaultPreviewSemanticLabel,
  });

  final VrAvatarAppearance appearance;
  final double size;
  final String semanticLabel;

  @override
  Widget build(BuildContext context) => Semantics(
    label: semanticLabel,
    image: true,
    child: RepaintBoundary(
      child: SizedBox.square(
        dimension: size,
        child: CustomPaint(painter: VrAvatarPainter(appearance)),
      ),
    ),
  );
}
