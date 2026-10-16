import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../model/vr_avatar_profile.dart';

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
    this.semanticLabel = 'Avatar',
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
        child: CustomPaint(painter: _AvatarPainter(appearance)),
      ),
    ),
  );
}

class _AvatarPainter extends CustomPainter {
  const _AvatarPainter(this.appearance);
  final VrAvatarAppearance appearance;

  @override
  void paint(Canvas canvas, Size size) {
    final unit = math.min(size.width, size.height);
    canvas.translate((size.width - unit) / 2, (size.height - unit) / 2);
    canvas.scale(unit / 180);
    final body = Color(appearance.bodyColorArgb);
    final accent = Color(appearance.accentColorArgb);
    final dark = Color.lerp(body, const Color(0xff091c2e), .58)!;
    final light = Color.lerp(body, Colors.white, .34)!;
    final paint = Paint()..isAntiAlias = true;
    canvas.drawOval(
      const Rect.fromLTWH(36, 155, 108, 12),
      paint..color = Colors.black.withValues(alpha: .16),
    );
    // Fit enlarged ears/gills/leaves without clipping; keep the floor stable.
    final species = appearance.species;
    final (featureTop, featurePivot) = switch (species) {
      VrAvatarSpecies.robot => (13.0, 36.0),
      VrAvatarSpecies.fox => (20.0, 46.0),
      VrAvatarSpecies.axolotl => (37.0, 62.0),
      VrAvatarSpecies.sprout => (8.0, 42.0),
      _ => (35.0, 61.0),
    };
    final headTop =
        63 +
        (featurePivot +
                (featureTop - featurePivot) * appearance.featureScale -
                63) *
            appearance.headScale;
    final fitHeight = math.min(1.0, 146 / (160 - math.min(14.0, headTop)));
    final fitWidth = species == VrAvatarSpecies.axolotl
        ? math.min(
            1.0,
            154 / (104 * appearance.headScale * appearance.featureScale),
          )
        : 1.0;
    final scale =
        (.68 + (appearance.heightMeters - 1) / 1.2 * .32) *
        math.min(fitHeight, fitWidth);
    canvas.translate(90, 160);
    canvas.scale(scale);
    canvas.translate(-90, -160);

    void oval(Rect rect, Color color) =>
        canvas.drawOval(rect, paint..color = color);
    void capsule(Rect rect, Color color, [double radius = 18]) =>
        canvas.drawRRect(
          RRect.fromRectAndRadius(rect, Radius.circular(radius)),
          paint..color = color,
        );
    void gradientBody(Rect rect, {double radius = 28}) {
      final shape = RRect.fromRectAndRadius(rect, Radius.circular(radius));
      final bodyPaint = Paint()
        ..isAntiAlias = true
        ..shader = LinearGradient(
          colors: [light, body, dark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ).createShader(rect);
      canvas.drawRRect(shape, bodyPaint);
      canvas.save();
      canvas.clipRRect(shape);
      _pattern(canvas, rect, accent, appearance.pattern);
      canvas.restore();
    }

    void feature(Offset pivot, void Function() draw) {
      canvas.save();
      canvas.translate(pivot.dx, pivot.dy);
      canvas.scale(appearance.featureScale);
      canvas.translate(-pivot.dx, -pivot.dy);
      draw();
      canvas.restore();
    }

    void leaf(Offset start, Offset end, double breadth, Color color) {
      final middle = (start + end) / 2;
      final perpendicular = Offset(-(end.dy - start.dy), end.dx - start.dx);
      final normal = perpendicular / perpendicular.distance * breadth;
      final path = Path()
        ..moveTo(start.dx, start.dy)
        ..quadraticBezierTo(
          middle.dx + normal.dx,
          middle.dy + normal.dy,
          end.dx,
          end.dy,
        )
        ..quadraticBezierTo(
          middle.dx - normal.dx,
          middle.dy - normal.dy,
          start.dx,
          start.dy,
        )
        ..close();
      canvas.drawPath(path, paint..color = color);
    }

    if (species == VrAvatarSpecies.orb) {
      feature(const Offset(90, 92), () {
        oval(const Rect.fromLTWH(25, 77, 130, 25), dark);
        oval(const Rect.fromLTWH(30, 74, 120, 18), accent);
      });
      canvas.save();
      canvas.translate(90, 92);
      canvas.scale(appearance.headScale);
      canvas.translate(-90, -92);
      gradientBody(const Rect.fromLTWH(48, 48, 84, 84), radius: 42);
      capsule(const Rect.fromLTWH(62, 82, 56, 18), dark, 9);
      oval(const Rect.fromLTWH(70, 87, 7, 7), accent);
      oval(const Rect.fromLTWH(103, 87, 7, 7), accent);
      oval(const Rect.fromLTWH(62, 58, 28, 10), light.withValues(alpha: .65));
      canvas.restore();
      return;
    }

    if (species == VrAvatarSpecies.fox) {
      feature(const Offset(112, 125), () {
        final tail = Path()
          ..moveTo(109, 140)
          ..cubicTo(146, 145, 157, 107, 137, 89)
          ..cubicTo(140, 114, 117, 104, 107, 121)
          ..close();
        canvas.drawPath(tail, paint..color = dark);
        leaf(const Offset(137, 110), const Offset(137, 89), 13, accent);
      });
    }
    if (species == VrAvatarSpecies.sprout) {
      feature(const Offset(90, 105), () {
        leaf(const Offset(67, 116), const Offset(39, 79), 17, dark);
        leaf(const Offset(110, 116), const Offset(142, 82), 18, accent);
      });
      gradientBody(const Rect.fromLTWH(60, 86, 60, 65), radius: 24);
      capsule(const Rect.fromLTWH(65, 143, 22, 15), dark, 7);
      capsule(const Rect.fromLTWH(94, 143, 22, 15), dark, 7);
    } else {
      capsule(const Rect.fromLTWH(64, 120, 22, 39), dark, 10);
      capsule(const Rect.fromLTWH(94, 120, 22, 39), dark, 10);
      capsule(const Rect.fromLTWH(45, 82, 19, 48), body, 10);
      capsule(const Rect.fromLTWH(116, 82, 19, 48), dark, 10);
      gradientBody(
        const Rect.fromLTWH(59, 78, 62, 57),
        radius: species == VrAvatarSpecies.robot ? 14 : 27,
      );
      capsule(const Rect.fromLTWH(63, 148, 25, 11), accent, 5);
      capsule(const Rect.fromLTWH(92, 148, 25, 11), accent, 5);
    }

    canvas.save();
    canvas.translate(90, 63);
    canvas.scale(appearance.headScale);
    canvas.translate(-90, -63);
    switch (species) {
      case VrAvatarSpecies.fox:
        feature(const Offset(90, 46), () {
          for (final left in [true, false]) {
            final x = left ? 65.0 : 115.0;
            final ear = Path()
              ..moveTo(x - 12, 51)
              ..quadraticBezierTo(x - 13, 28, x, 20)
              ..quadraticBezierTo(x + 13, 31, x + 12, 51)
              ..close();
            canvas.drawPath(ear, paint..color = body);
            leaf(Offset(x, 47), Offset(x, 27), 6, accent);
          }
        });
        gradientBody(const Rect.fromLTWH(54, 40, 72, 49), radius: 25);
        leaf(const Offset(88, 83), const Offset(58, 63), 15, accent);
        leaf(const Offset(92, 83), const Offset(122, 63), 15, accent);
        oval(const Rect.fromLTWH(86, 73, 8, 6), dark);
      case VrAvatarSpecies.axolotl:
        feature(const Offset(90, 62), () {
          for (final side in [-1.0, 1.0]) {
            for (var index = 0; index < 3; index++) {
              leaf(
                Offset(90 + side * 29, 62),
                Offset(
                  90 + side * (48 + (index == 1 ? 4 : 0)),
                  37 + index * 21.0,
                ),
                8,
                index == 1 ? light : accent,
              );
            }
          }
        });
        gradientBody(const Rect.fromLTWH(52, 40, 76, 50), radius: 25);
        oval(const Rect.fromLTWH(62, 67, 12, 7), accent.withValues(alpha: .6));
        oval(const Rect.fromLTWH(106, 67, 12, 7), accent.withValues(alpha: .6));
      case VrAvatarSpecies.sprout:
        feature(const Offset(90, 42), () {
          leaf(const Offset(90, 45), const Offset(66, 15), 15, accent);
          leaf(const Offset(90, 45), const Offset(115, 14), 14, light);
          leaf(const Offset(90, 44), const Offset(91, 8), 12, dark);
        });
        gradientBody(const Rect.fromLTWH(58, 40, 64, 52), radius: 27);
      case VrAvatarSpecies.robot:
        feature(const Offset(90, 36), () {
          capsule(const Rect.fromLTWH(88, 19, 4, 20), dark, 2);
          oval(const Rect.fromLTWH(85, 13, 10, 10), accent);
        });
        gradientBody(const Rect.fromLTWH(59, 36, 62, 52), radius: 15);
        capsule(const Rect.fromLTWH(65, 49, 50, 25), dark, 8);
        capsule(const Rect.fromLTWH(72, 57, 10, 7), accent, 3);
        capsule(const Rect.fromLTWH(98, 57, 10, 7), accent, 3);
      case VrAvatarSpecies.human:
        feature(const Offset(90, 61), () {
          oval(const Rect.fromLTWH(54, 55, 12, 19), accent);
          oval(const Rect.fromLTWH(114, 55, 12, 19), accent);
        });
        gradientBody(const Rect.fromLTWH(60, 35, 60, 54), radius: 26);
        capsule(const Rect.fromLTWH(65, 49, 50, 22), dark, 10);
        capsule(const Rect.fromLTWH(72, 55, 36, 6), accent, 3);
      case VrAvatarSpecies.orb:
        break;
    }
    if (species == VrAvatarSpecies.fox ||
        species == VrAvatarSpecies.axolotl ||
        species == VrAvatarSpecies.sprout) {
      oval(const Rect.fromLTWH(72, 59, 6, 8), dark);
      oval(const Rect.fromLTWH(102, 59, 6, 8), dark);
      if (species != VrAvatarSpecies.fox) {
        canvas.drawArc(
          const Rect.fromLTWH(83, 68, 14, 8),
          .12,
          math.pi - .24,
          false,
          Paint()
            ..color = dark
            ..strokeWidth = 1.8
            ..style = PaintingStyle.stroke,
        );
      }
    }
    canvas.restore();
  }

  void _pattern(
    Canvas canvas,
    Rect bounds,
    Color color,
    VrAvatarPattern pattern,
  ) {
    final paint = Paint()
      ..color = color.withValues(alpha: .64)
      ..isAntiAlias = true;
    switch (pattern) {
      case VrAvatarPattern.solid:
        return;
      case VrAvatarPattern.spots:
        for (var index = 0; index < 6; index++) {
          canvas.drawCircle(
            Offset(
              bounds.left + bounds.width * (.25 + (index % 2) * .5),
              bounds.top + bounds.height * (.24 + (index ~/ 2) * .26),
            ),
            bounds.width * .055,
            paint,
          );
        }
      case VrAvatarPattern.stripes:
        paint
          ..strokeWidth = bounds.width * .07
          ..strokeCap = StrokeCap.round;
        for (var index = 0; index < 3; index++) {
          final y = bounds.top + bounds.height * (.25 + index * .25);
          canvas.drawLine(
            Offset(bounds.left, y + 5),
            Offset(bounds.right, y - 5),
            paint,
          );
        }
    }
  }

  @override
  bool shouldRepaint(_AvatarPainter oldDelegate) =>
      oldDelegate.appearance != appearance;
}
