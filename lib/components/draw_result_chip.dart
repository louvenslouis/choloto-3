import 'dart:math' as math;

import 'package:flutter/material.dart';

import '/flutter_flow/flutter_flow_theme.dart';

/// The brushed-gold number chip used in draw histories and on the home page.
class DrawResultChip extends StatelessWidget {
  const DrawResultChip({super.key, required this.value, required this.size});

  final String value;
  final double size;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return RepaintBoundary(
      child: CustomPaint(
        painter: _ResultChipPainter(
            theme.designToken.vip.goldLight,
            theme.warning,
            theme.designToken.home.membership.colors.first,
            theme.onPrimary),
        child: SizedBox.square(
          dimension: size,
          child: Padding(
            padding: EdgeInsets.fromLTRB(
                size * .095, size * .10, size * .095, size * .14),
            child: Center(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(value,
                    style: theme.titleLarge.override(
                      color: theme.onPrimary,
                      fontSize: size * .43,
                      letterSpacing: -.45,
                      fontWeight: FontWeight.w900,
                      lineHeight: 1,
                    )),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The chip's edge inserts continue onto its visible lower bevel.
class _ResultChipPainter extends CustomPainter {
  const _ResultChipPainter(this.light, this.gold, this.brass, this.ink);

  final Color light;
  final Color gold;
  final Color brass;
  final Color ink;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 100, size.height / 100);
    final paint = Paint();
    const rim = Rect.fromLTWH(2, 1.5, 96, 92);
    const hub = Rect.fromLTWH(13, 11.5, 74, 72);
    final bronze = Color.lerp(brass, ink, .52)!;
    final edge = rim.shift(const Offset(0, 3.5));
    canvas.drawOval(
        edge.shift(const Offset(0, 2)),
        paint
          ..color = ink.withValues(alpha: .48)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.8));
    paint.maskFilter = null;
    canvas.drawOval(
        edge,
        paint
          ..color = light
          ..shader = LinearGradient(
            colors: [bronze, brass, bronze, brass, bronze],
          ).createShader(edge));
    canvas.drawOval(
        rim,
        paint
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [light, gold, brass, gold],
            stops: const [0, .28, .76, 1],
          ).createShader(rim));
    // The darker inserts are cut broad, like the wedges in the home artwork.
    paint.shader = null;
    for (var i = 0; i < 10; i++) {
      final angle = (i + .27) * math.pi / 5;
      final wedge = Path()
        ..arcTo(rim, angle, .25, true)
        ..arcTo(hub, angle + .25, -.25, false)
        ..close();
      canvas.drawPath(
          wedge,
          paint
            ..color = Color.lerp(
                brass, bronze, .15 + .27 * (1 + math.sin(angle)) / 2)!);
    }
    canvas.drawOval(hub.inflate(.65), paint..color = bronze);
    canvas.drawOval(
        hub,
        paint
          ..shader = RadialGradient(
            center: const Alignment(-.44, -.65),
            radius: 1.25,
            colors: [light, gold, brass],
            stops: const [0, .57, 1],
          ).createShader(hub));
    canvas.drawArc(
        rim.deflate(.7),
        3.25,
        2.75,
        false,
        paint
          ..shader = null
          ..color = light
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.1);
    canvas.restore();
  }

  @override
  bool shouldRepaint(_ResultChipPainter old) =>
      old.light != light ||
      old.gold != gold ||
      old.brass != brass ||
      old.ink != ink;
}
