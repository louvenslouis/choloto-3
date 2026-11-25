import 'package:flutter/material.dart';

import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';

/// A centered inscription on the same axis as the gold X.
class CrossPosterHeading extends StatelessWidget {
  const CrossPosterHeading({super.key, this.date});

  final DateTime? date;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final tokens = theme.designToken;
    final vip = tokens.vip;
    final spacing = tokens.spacing;
    final strings = FFLocalizations.of(context);
    final dateText =
        dateTimeFormat('yMMMMEEEEd', date, locale: strings.languageCode);

    return LayoutBuilder(builder: (context, constraints) {
      final width = constraints.maxWidth;
      final typeSize = (width * .093).clamp(26.0, 42.0);
      final titleStyle = vip.typography.posterTitle(compact: false).copyWith(
            color: theme.onPrimary,
            shadows: const [],
            fontSize: typeSize,
            fontVariations: [
              FontVariation.opticalSize(typeSize),
              const FontVariation.width(91),
              const FontVariation.slant(-8),
            ],
            letterSpacing: -typeSize * .025,
            height: 1.06,
          );
      final lineWidth = width / MediaQuery.textScalerOf(context).scale(1) >= 310
          ? (width * .075).clamp(16.0, 36.0)
          : 0.0;
      final foil = theme.onPrimary;

      return Padding(
        padding:
            EdgeInsets.fromLTRB(spacing.md, spacing.lg, spacing.md, spacing.sm),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Semantics(
              header: true,
              child: Text(strings.getText('63dg2p5g'),
                  textAlign: TextAlign.center, style: titleStyle),
            ),
            if (dateText.isNotEmpty) ...[
              SizedBox(height: spacing.sm),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (lineWidth > 0) _DateRule(foil: foil, width: lineWidth),
                  Flexible(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: spacing.sm),
                      child: Text(
                        dateText,
                        textAlign: TextAlign.center,
                        style: vip.typography.category(compact: true).copyWith(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              letterSpacing: .55,
                              color: theme.onPrimary.withValues(alpha: .85),
                            ),
                      ),
                    ),
                  ),
                  if (lineWidth > 0)
                    _DateRule(foil: foil, width: lineWidth, reverse: true),
                ],
              ),
            ],
          ],
        ),
      );
    });
  }
}

class _DateRule extends StatelessWidget {
  const _DateRule(
      {required this.foil, required this.width, this.reverse = false});

  final Color foil;
  final double width;
  final bool reverse;

  @override
  Widget build(BuildContext context) => Container(
        width: width,
        height: 1,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: reverse ? Alignment.centerRight : Alignment.centerLeft,
            end: reverse ? Alignment.centerLeft : Alignment.centerRight,
            colors: [foil.withValues(alpha: 0), foil.withValues(alpha: .72)],
          ),
        ),
      );
}
