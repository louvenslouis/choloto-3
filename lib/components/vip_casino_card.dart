import 'dart:math' as math;

import 'package:flutter/material.dart';
import '/flutter_flow/flutter_flow_theme.dart';

/// A raised, foil-edged playing-card surface. Its decoration never takes space
/// from the existing VIP grid or intercepts taps and accessibility semantics.
class VipCasinoCard extends StatelessWidget {
  const VipCasinoCard({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final tokens = theme.designToken;
    final radius = BorderRadius.circular(tokens.radius.md);
    return Container(
      margin: EdgeInsets.all(tokens.spacing.xs),
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: [tokens.shadow.lg, tokens.shadow.sm],
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: DecoratedBox(
          decoration: BoxDecoration(gradient: tokens.vip.felt),
          child: CustomPaint(
            painter: _CasinoEngraving(tokens),
            foregroundPainter: _CasinoRim(tokens),
            child: child,
          ),
        ),
      ),
    );
  }
}

class VipCasinoPlaque extends StatelessWidget {
  const VipCasinoPlaque({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final tokens = FlutterFlowTheme.of(context).designToken;
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: tokens.vip.plaque,
        borderRadius: BorderRadius.circular(tokens.radius.sm),
        border: Border.all(color: tokens.vip.plaqueEdge, width: 0.7),
      ),
      child: child,
    );
  }
}

class VipCasinoChip extends StatelessWidget {
  const VipCasinoChip({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final tokens = FlutterFlowTheme.of(context).designToken;
    return DecoratedBox(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: tokens.vip.chip,
        boxShadow: [tokens.shadow.md],
      ),
      child: CustomPaint(
        foregroundPainter: _ChipEdge(tokens),
        child: child,
      ),
    );
  }
}

class _CasinoEngraving extends CustomPainter {
  _CasinoEngraving(this.tokens);
  final FFDesignTokens tokens;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = tokens.vip.ornament
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.6;
    // A fine diamond weave recalls the reverse of engraved playing cards.
    final step = tokens.spacing.lg;
    for (double y = step; y < size.height + step; y += step) {
      for (double x = 0; x < size.width + step; x += step) {
        canvas.drawPath(
          Path()
            ..moveTo(x, y - step / 2)
            ..lineTo(x + step / 2, y)
            ..lineTo(x, y + step / 2)
            ..lineTo(x - step / 2, y)
            ..close(),
          paint,
        );
      }
    }
    // Broad engraved arcs in one corner add depth without obscuring numbers.
    for (final radius in [0.42, 0.52, 0.64]) {
      canvas.drawCircle(
        Offset(size.width * 0.93, size.height * 0.87),
        size.shortestSide * radius,
        paint..strokeWidth = 1,
      );
    }
  }

  @override
  bool shouldRepaint(_CasinoEngraving old) => old.tokens.theme != tokens.theme;
}

class _CasinoRim extends CustomPainter {
  _CasinoRim(this.tokens);
  final FFDesignTokens tokens;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final radius = tokens.radius.md;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..shader = tokens.vip.gold.createShader(rect);
    canvas.drawRRect(
        RRect.fromRectAndRadius(rect.deflate(0.8), Radius.circular(radius)),
        paint);
    final inset = tokens.spacing.xs;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          rect.deflate(inset), Radius.circular(radius - inset)),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.5
        ..color = tokens.vip.goldLight.withValues(alpha: 0.28),
    );
    // A dark lower bevel and a bright upper edge make the card feel substantial.
    final bottom = Rect.fromLTWH(0, size.height - inset, size.width, inset);
    canvas.drawRect(
        bottom,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              tokens.vip.goldShade.withValues(alpha: 0),
              tokens.vip.goldShade.withValues(alpha: 0.6)
            ],
          ).createShader(bottom));
  }

  @override
  bool shouldRepaint(_CasinoRim old) => old.tokens.theme != tokens.theme;
}

class _ChipEdge extends CustomPainter {
  _ChipEdge(this.tokens);
  final FFDesignTokens tokens;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.shortestSide / 2;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = tokens.vip.goldShade;
    canvas.drawCircle(center, radius - 0.5, paint);
    canvas.drawCircle(center, radius - tokens.spacing.xs, paint);
    for (var i = 0; i < 24; i++) {
      final angle = i * math.pi / 12;
      final direction = Offset(math.cos(angle), math.sin(angle));
      canvas.drawLine(
        center + direction * (radius - 3),
        center + direction * (radius - 1),
        paint..color = i.isEven ? tokens.vip.goldLight : tokens.vip.goldShade,
      );
    }
  }

  @override
  bool shouldRepaint(_ChipEdge old) => old.tokens.theme != tokens.theme;
}
