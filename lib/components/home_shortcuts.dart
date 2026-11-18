import 'package:flutter/material.dart';

import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/internationalization.dart';

enum _Shortcut { video, stats, tchala, history }

class HomeShortcuts extends StatelessWidget {
  const HomeShortcuts({
    super.key,
    required this.wide,
    required this.onVideo,
    required this.onStats,
    required this.onTchala,
    required this.onHistory,
  });

  final bool wide;
  final VoidCallback onVideo;
  final VoidCallback onStats;
  final VoidCallback onTchala;
  final VoidCallback onHistory;

  @override
  Widget build(BuildContext context) {
    final strings = FFLocalizations.of(context);
    final tokens = FlutterFlowTheme.of(context).designToken;
    final palette = tokens.home;
    final actions = [
      (_Shortcut.video, 'fkwji2m2', palette.videoAccent, onVideo),
      (_Shortcut.stats, 'o0ut0uym', palette.statsAccent, onStats),
      (_Shortcut.tchala, '40q38tw9', palette.tchalaAccent, onTchala),
      (_Shortcut.history, 'viphstttl', palette.historyAccent, onHistory),
    ];
    return LayoutBuilder(builder: (context, constraints) {
      final textScale = MediaQuery.textScalerOf(context).scale(14) / 14;
      final columns = wide || constraints.maxWidth / textScale < 265 ? 2 : 4;
      final gap = wide ? tokens.spacing.md : 0.0;
      final itemWidth = (constraints.maxWidth - (columns - 1) * gap) / columns;
      return Wrap(spacing: gap, runSpacing: tokens.spacing.sm, children: [
        for (final (shortcut, label, color, onTap) in actions)
          SizedBox(
            width: itemWidth,
            child: _ShortcutButton(
              shortcut: shortcut,
              label: strings.getText(label),
              color: color,
              size: wide
                  ? (itemWidth * .63).clamp(100.0, 146.0)
                  : (itemWidth * .69).clamp(46.0, 64.0),
              wide: wide,
              onTap: onTap,
            ),
          ),
      ]);
    });
  }
}

class _ShortcutButton extends StatefulWidget {
  const _ShortcutButton({
    required this.shortcut,
    required this.label,
    required this.color,
    required this.size,
    required this.wide,
    required this.onTap,
  });

  final _Shortcut shortcut;
  final String label;
  final Color color;
  final double size;
  final bool wide;
  final VoidCallback onTap;

  @override
  State<_ShortcutButton> createState() => _ShortcutButtonState();
}

class _ShortcutButtonState extends State<_ShortcutButton> {
  bool _hovered = false;
  bool _pressed = false;
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final tokens = theme.designToken;
    final home = tokens.home;
    final accent = widget.color;
    final dark = Theme.of(context).brightness == Brightness.dark;
    final motion = !MediaQuery.disableAnimationsOf(context);
    final active = _hovered || _focused || _pressed;
    final wide = widget.wide;
    final radius =
        BorderRadius.circular(wide ? tokens.radius.md : tokens.radius.full);
    final surface = home.surface.colors;
    final glass = BoxDecoration(
      borderRadius: radius,
      gradient: LinearGradient(
        begin: const Alignment(-.65, -1),
        end: const Alignment(.64, 1),
        colors: [
          Color.lerp(surface.first, accent, dark ? .22 : .09)!,
          Color.lerp(surface.first, accent, dark ? .06 : .025)!,
          surface.last,
          Color.lerp(surface.last, accent, dark ? .13 : .06)!,
        ],
        stops: const [0, .28, .74, 1],
      ),
      border: Border.all(
          color: active
              ? accent
              : Color.lerp(home.edge, accent, wide ? .12 : .33)!),
      boxShadow: [tokens.shadow.md],
    );
    final glyphSize = widget.size * (wide ? .45 : .56);
    final glyph = RepaintBoundary(
      child: CustomPaint(
        size: Size.square(glyphSize),
        painter:
            _ShortcutGlyph(widget.shortcut, accent, theme.onDecorative, dark),
      ),
    );
    final label = Text(widget.label,
        textAlign: TextAlign.center,
        style: theme.labelMedium.override(
          color: theme.primaryText,
          fontSize: wide ? (widget.size * .155).clamp(16.0, 22.0) : 12,
          fontWeight: FontWeight.w600,
          lineHeight: 1.12,
        ));
    final decoration = wide
        ? DecoratedBox(
            decoration: glass,
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: widget.size),
              child: Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: tokens.spacing.xs, vertical: tokens.spacing.sm),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      glyph,
                      SizedBox(height: tokens.spacing.sm),
                      label,
                    ]),
              ),
            ),
          )
        : Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
                width: widget.size,
                height: widget.size,
                decoration: glass,
                alignment: Alignment.center,
                child: glyph),
            SizedBox(height: tokens.spacing.xs),
            label,
          ]);
    return Semantics(
      button: true,
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          key: ValueKey('home-shortcut-${widget.shortcut.name}'),
          onTap: widget.onTap,
          onHighlightChanged: (value) => setState(() => _pressed = value),
          onHover: (value) => setState(() => _hovered = value),
          onFocusChange: (value) => setState(() => _focused = value),
          borderRadius: BorderRadius.circular(tokens.radius.md),
          child: AnimatedScale(
            duration:
                motion ? const Duration(milliseconds: 160) : Duration.zero,
            curve: Curves.easeOutCubic,
            scale: !motion ? 1 : (_pressed ? .96 : (_hovered ? 1.02 : 1)),
            child: decoration,
          ),
        ),
      ),
    );
  }
}

/// Native paths keep the tubular outlines crisp at both shortcut sizes.
class _ShortcutGlyph extends CustomPainter {
  const _ShortcutGlyph(this.shortcut, this.accent, this.highlight, this.dark);

  final _Shortcut shortcut;
  final Color accent;
  final Color highlight;
  final bool dark;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 48, size.height / 48);
    final path = Path();
    switch (shortcut) {
      case _Shortcut.video:
        path
          ..moveTo(10, 6)
          ..quadraticBezierTo(10, 4.3, 12, 5.4)
          ..lineTo(41, 22.4)
          ..quadraticBezierTo(43.5, 24, 41, 25.5)
          ..lineTo(12, 42.5)
          ..quadraticBezierTo(10, 43.6, 10, 41.6)
          ..close();
      case _Shortcut.stats:
        for (var i = 0; i < 4; i++) {
          final x = 6.5 + i * 11.5;
          path
            ..moveTo(x, 41)
            ..lineTo(x, 32.5 - i * 9.5);
        }
      case _Shortcut.tchala:
        path
          ..moveTo(24, 13)
          ..cubicTo(21, 7, 14, 5.5, 4.5, 8)
          ..quadraticBezierTo(3, 8.5, 3, 10.5)
          ..lineTo(3, 35)
          ..quadraticBezierTo(3, 37.3, 5, 36.8)
          ..cubicTo(14, 34.5, 20, 35.2, 24, 41)
          ..cubicTo(28, 35.2, 34, 34.5, 43, 36.8)
          ..quadraticBezierTo(45, 37.3, 45, 35)
          ..lineTo(45, 10.5)
          ..quadraticBezierTo(45, 8.5, 43.5, 8)
          ..cubicTo(34, 5.5, 27, 7, 24, 13)
          ..lineTo(24, 41);
      case _Shortcut.history:
        path
          ..addArc(const Rect.fromLTWH(5, 5, 38, 38), 3.55, 5.75)
          ..moveTo(5, 7)
          ..lineTo(5, 18)
          ..lineTo(15, 18)
          ..moveTo(24, 13)
          ..lineTo(24, 24)
          ..lineTo(32, 29);
    }
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round;
    if (dark) {
      canvas.drawPath(
          path,
          paint
            ..strokeWidth = 5
            ..color = accent.withValues(alpha: .30)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3.5));
    }
    paint
      ..maskFilter = null
      ..strokeWidth = shortcut == _Shortcut.stats ? 4.3 : 3.7
      ..color = accent
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color.lerp(accent, highlight, dark ? .84 : .35)!,
          accent,
          Color.lerp(accent, highlight, dark ? .37 : .12)!,
          accent
        ],
        stops: const [0, .42, .69, 1],
      ).createShader(const Rect.fromLTWH(4, 4, 40, 40));
    canvas.drawPath(path, paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(_ShortcutGlyph old) =>
      old.shortcut != shortcut ||
      old.accent != accent ||
      old.highlight != highlight ||
      old.dark != dark;
}
