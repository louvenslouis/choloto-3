import 'dart:math' show max, min;
import 'dart:ui' as ui show Gradient, TextDirection;

import 'package:flutter/material.dart';

import '/flutter_flow/flutter_flow_theme.dart';

/// Clips the artwork and paints its faceted jewel-toned rim.
class JewelPosterFrame extends StatelessWidget {
  const JewelPosterFrame({super.key, required this.rim, required this.child});
  final Gradient rim;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final tokens = FlutterFlowTheme.of(context).designToken;
    final frame = _PosterFrame(
      radius: tokens.radius.md,
      bevel: tokens.spacing.md,
      rim: rim,
    );
    return ClipPath(
      clipper: ShapeBorderClipper(shape: frame),
      child: DecoratedBox(
        position: DecorationPosition.foreground,
        decoration: ShapeDecoration(shape: frame),
        child: child,
      ),
    );
  }
}

/// Paints the satin name ribbon behind content sized by the caller.
class JewelPosterRibbon extends StatelessWidget {
  const JewelPosterRibbon(
      {super.key, required this.jewel, required this.child});
  final FFVipJewel jewel;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final tokens = FlutterFlowTheme.of(context).designToken;
    return CustomPaint(
      painter: _TitleRibbon(
        face: tokens.vip.titleRibbon(jewel),
        trim: tokens.vip.gold,
        bevel: tokens.spacing.sm + tokens.spacing.xs,
      ),
      child: child,
    );
  }
}

// Three rounded corners and one cut shoulder recall the bevel on the name ribbon.
class _PosterFrame extends ShapeBorder {
  const _PosterFrame(
      {required this.radius, required this.bevel, required this.rim});
  final double radius;
  final double bevel;
  final Gradient rim;

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.zero;

  @override
  Path getOuterPath(Rect rect, {ui.TextDirection? textDirection}) {
    final r = min(radius, rect.shortestSide / 2);
    final cut = min(bevel, rect.shortestSide / 2);
    final round = Radius.circular(r);
    return Path()
      ..moveTo(rect.left + r, rect.top)
      ..lineTo(rect.right - cut, rect.top)
      ..lineTo(rect.right, rect.top + cut)
      ..lineTo(rect.right, rect.bottom - r)
      ..arcToPoint(Offset(rect.right - r, rect.bottom), radius: round)
      ..lineTo(rect.left + r, rect.bottom)
      ..arcToPoint(Offset(rect.left, rect.bottom - r), radius: round)
      ..lineTo(rect.left, rect.top + r)
      ..arcToPoint(Offset(rect.left + r, rect.top), radius: round)
      ..close();
  }

  @override
  Path getInnerPath(Rect rect, {ui.TextDirection? textDirection}) =>
      getOuterPath(rect.deflate(1.5));

  @override
  void paint(Canvas canvas, Rect rect, {ui.TextDirection? textDirection}) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..shader = rim.createShader(rect);
    canvas.drawPath(getOuterPath(rect.deflate(.75)), paint);
    // One short inner facet catches the light at the cut, clear of the values.
    final shoulder = Path()
      ..moveTo(rect.right - bevel * 1.65, rect.top + 4)
      ..lineTo(rect.right - bevel - 2, rect.top + 4)
      ..lineTo(rect.right - 4, rect.top + bevel + 2)
      ..lineTo(rect.right - 4, rect.top + bevel * 1.65);
    canvas.drawPath(shoulder, paint..strokeWidth = .7);
  }

  @override
  ShapeBorder scale(double t) =>
      _PosterFrame(radius: radius * t, bevel: bevel * t, rim: rim);
}

class _TitleRibbon extends CustomPainter {
  const _TitleRibbon(
      {required this.face, required this.trim, required this.bevel});
  final Gradient face;
  final Gradient trim;
  final double bevel;

  @override
  void paint(Canvas canvas, Size size) {
    final bounds = Offset.zero & size;
    // The bevel stays narrow when a translated title wraps onto several lines.
    Path ribbon(double right, double bottom) => Path()
      ..moveTo(0, 0)
      ..lineTo(right, 0)
      ..lineTo(max(0.0, right - bevel), bottom)
      ..lineTo(0, bottom)
      ..close();
    final paint = Paint()..shader = trim.createShader(bounds);
    canvas.drawPath(ribbon(size.width, size.height), paint);
    paint.shader = face.createShader(bounds);
    canvas.drawPath(ribbon(size.width - 2.5, size.height - 1), paint);
  }

  @override
  bool shouldRepaint(_TitleRibbon old) =>
      face != old.face || trim != old.trim || bevel != old.bevel;
}

/// A small fan of engraved lines fades out before reaching the still life.
class JewelPosterEngraving extends CustomPainter {
  const JewelPosterEngraving(this.foil);
  final Color foil;

  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width * .57;
    final height = min(size.height, width);
    final baseline = size.height - height * .24;
    final path = Path();
    for (var i = 0; i < 5; i++) {
      final y = baseline - i * 3;
      path.moveTo(0, y);
      path.cubicTo(width * .35, y + height * .06, width * .56, y - height * .32,
          width, y - height * .27);
    }
    canvas.drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = .65
          ..shader = ui.Gradient.linear(Offset.zero, Offset(width, 0), [
            foil.withValues(alpha: .12),
            foil.withValues(alpha: .31),
            foil.withValues(alpha: 0),
          ], const [
            0,
            .42,
            1
          ]));
  }

  @override
  bool shouldRepaint(JewelPosterEngraving old) => foil != old.foil;
}
