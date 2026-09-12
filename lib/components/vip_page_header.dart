import 'dart:math' as math;

import 'package:flutter/material.dart';

import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/internationalization.dart';
import 'vip_casino_card.dart';
import 'vip_motion.dart';

/// The account entrance shares the gold and satin materials of the VIP cards.
class VipPageHeader extends StatelessWidget {
  const VipPageHeader(
      {super.key, required this.avatar, required this.onProfile});

  final Widget avatar;
  final VoidCallback onProfile;

  static TextStyle _title(FlutterFlowTheme theme) =>
      theme.headlineMedium.override(
        color: theme.primaryText,
        fontSize: 28,
        fontWeight: FontWeight.w700,
        lineHeight: 1.15,
      );

  static TextStyle _subtitle(FlutterFlowTheme theme) =>
      theme.bodyMedium.override(
        color: theme is DarkModeTheme ? theme.accent4 : theme.secondaryText,
        lineHeight: 1.45,
      );

  static TextStyle _badge(FlutterFlowTheme theme) => theme.labelMedium.override(
        color: theme.designToken.vip.numberText,
        fontWeight: FontWeight.w700,
        letterSpacing: 2,
        lineHeight: 1.2,
      );

  // Measure the localized copy so the pinned header also fits enlarged text.
  static double heightFor(BuildContext context, {double? width}) {
    final theme = FlutterFlowTheme.of(context);
    final spacing = theme.designToken.spacing;
    final contentWidth = (width ?? MediaQuery.sizeOf(context).width) -
        MediaQuery.paddingOf(context).horizontal -
        spacing.lg * 2;
    double measure(String key, TextStyle style, double availableWidth) {
      final painter = TextPainter(
        text: TextSpan(
            text: FFLocalizations.of(context).getText(key), style: style),
        textDirection: Directionality.of(context),
        textScaler: MediaQuery.textScalerOf(context),
      )..layout(maxWidth: math.max(1, availableWidth));
      final height = painter.height;
      painter.dispose();
      return height;
    }

    final titleWidth = contentWidth - spacing.xl * 2 - spacing.md;
    final headingHeight = math.max(
          18,
          measure('qzn6e3c5', _badge(theme), titleWidth - 18 - spacing.sm),
        ) +
        spacing.sm +
        measure('gfj3b9xn', _title(theme), titleWidth);
    return spacing.lg * 2 +
        math.max(spacing.xl * 2, headingHeight) +
        spacing.md +
        measure('pubct0u4', _subtitle(theme), contentWidth) +
        1;
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final tokens = theme.designToken;
    final strings = FFLocalizations.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(gradient: tokens.vip.felt),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: EdgeInsets.all(tokens.spacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(children: [
                            Icon(Icons.workspace_premium_outlined,
                                size: 18, color: tokens.vip.numberText),
                            SizedBox(width: tokens.spacing.sm),
                            Flexible(
                                child: Text(strings.getText('qzn6e3c5'),
                                    style: _badge(theme))),
                          ]),
                          SizedBox(height: tokens.spacing.sm),
                          Semantics(
                            header: true,
                            child: Text(strings.getText('gfj3b9xn'),
                                style: _title(theme)),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: tokens.spacing.md),
                    Tooltip(
                      message: strings.getText('ey6ffs78'),
                      child: Semantics(
                        button: true,
                        label: strings.getText('ey6ffs78'),
                        child: VipCasinoChip(
                          child: SizedBox.square(
                            dimension: tokens.spacing.xl * 2,
                            child: Material(
                              type: MaterialType.transparency,
                              shape: const CircleBorder(),
                              clipBehavior: Clip.antiAlias,
                              child: InkWell(
                                customBorder: const CircleBorder(),
                                onTap: onProfile,
                                child: Padding(
                                  padding: EdgeInsets.all(tokens.spacing.sm),
                                  child: ExcludeSemantics(
                                      child: ClipOval(child: avatar)),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ).vipActionFeedback(),
                  ],
                ),
                SizedBox(height: tokens.spacing.md),
                Text(strings.getText('pubct0u4'), style: _subtitle(theme)),
              ],
            ).vipEntrance(),
          ),
          Container(
              height: 1, decoration: BoxDecoration(gradient: tokens.vip.gold)),
        ],
      ),
    );
  }
}
