import 'package:flutter/material.dart';

import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/internationalization.dart';

enum _Shortcut { video, saints, tchala, history }

class HomeShortcuts extends StatelessWidget {
  const HomeShortcuts({
    super.key,
    required this.wide,
    required this.onVideo,
    required this.onSaints,
    required this.onTchala,
    required this.onHistory,
  });

  final bool wide;
  final VoidCallback onVideo;
  final VoidCallback onSaints;
  final VoidCallback onTchala;
  final VoidCallback onHistory;

  @override
  Widget build(BuildContext context) {
    final strings = FFLocalizations.of(context);
    final tokens = FlutterFlowTheme.of(context).designToken;
    final palette = tokens.home;
    final actions = [
      (_Shortcut.video, 'fkwji2m2', palette.videoAccent, onVideo),
      (_Shortcut.saints, 'd4x9buzb', palette.heroGlow, onSaints),
      (_Shortcut.tchala, '40q38tw9', palette.tchalaAccent, onTchala),
      (_Shortcut.history, 'viphstttl', palette.historyAccent, onHistory),
    ];
    final spacing = tokens.spacing;
    return Container(
      key: const ValueKey('home-shortcuts-surface'),
      padding: EdgeInsets.symmetric(
        horizontal: wide ? spacing.sm : spacing.xs,
        vertical: spacing.sm,
      ),
      decoration: palette.panel,
      child: LayoutBuilder(builder: (context, constraints) {
        final textScale = MediaQuery.textScalerOf(context).scale(14) / 14;
        final columns = wide || constraints.maxWidth / textScale < 265 ? 2 : 4;
        final gap = wide ? spacing.sm : 0.0;
        final itemWidth =
            (constraints.maxWidth - (columns - 1) * gap) / columns;
        return Wrap(spacing: gap, runSpacing: spacing.xs, children: [
          for (final (shortcut, label, color, onTap) in actions)
            SizedBox(
              width: itemWidth,
              child: _ShortcutButton(
                shortcut: shortcut,
                label: strings.getText(label),
                color: color,
                size: wide
                    ? (itemWidth * .46).clamp(56.0, 84.0)
                    : (itemWidth * .78).clamp(48.0, 64.0),
                wide: wide,
                onTap: onTap,
              ),
            ),
        ]);
      }),
    );
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
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final tokens = theme.designToken;
    final motion = !MediaQuery.disableAnimationsOf(context);
    return Semantics(
      button: true,
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          key: ValueKey('home-shortcut-${widget.shortcut.name}'),
          onTap: widget.onTap,
          onHighlightChanged: (value) => setState(() => _pressed = value),
          borderRadius: BorderRadius.circular(tokens.radius.md),
          focusColor: widget.color.withValues(alpha: .25),
          hoverColor: widget.color.withValues(alpha: .08),
          highlightColor: widget.color.withValues(alpha: .14),
          child: Padding(
            padding: EdgeInsets.symmetric(
              vertical: widget.wide ? tokens.spacing.sm : tokens.spacing.xs,
              horizontal: widget.wide ? tokens.spacing.xs : 0,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedScale(
                  scale: motion && _pressed ? .94 : 1,
                  alignment: Alignment.bottomCenter,
                  duration: motion
                      ? const Duration(milliseconds: 100)
                      : Duration.zero,
                  curve: Curves.easeOutCubic,
                  child: Image.asset(
                    'assets/images/home/shortcut_${widget.shortcut.name}.webp',
                    width: widget.size,
                    height: widget.size,
                    alignment: Alignment.bottomCenter,
                    fit: BoxFit.contain,
                    excludeFromSemantics: true,
                  ),
                ),
                SizedBox(
                    height:
                        widget.wide ? tokens.spacing.sm : tokens.spacing.xs),
                Text(widget.label,
                    textAlign: TextAlign.center,
                    style: theme.labelMedium.override(
                      color: tokens.home.mutedText,
                      fontSize: widget.wide ? 16 : 12,
                      fontWeight: FontWeight.w600,
                      lineHeight: 1.12,
                    )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
