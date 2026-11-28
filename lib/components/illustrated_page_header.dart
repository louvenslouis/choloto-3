import 'package:flutter/material.dart';

import '/flutter_flow/flutter_flow_theme.dart';
import 'home_feature_card.dart';

class IllustratedPageHeader extends StatelessWidget {
  const IllustratedPageHeader(
      {super.key,
      required this.title,
      required this.inset,
      required this.asset,
      required this.fallback,
      this.artworkKey,
      this.action});
  final String title;
  final double inset;
  final String asset;
  final IconData fallback;
  final Key? artworkKey;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final tokens = theme.designToken;
    final spacing = tokens.spacing;
    return Container(
      decoration: tokens.background.pageHeader(),
      padding: EdgeInsets.symmetric(horizontal: inset),
      child: LayoutBuilder(builder: (context, constraints) {
        final width = constraints.maxWidth;
        final wide = width >= 600;
        final textScale = MediaQuery.textScalerOf(context).scale(32) / 32;
        final showArtwork = width / textScale >= 230;
        final artworkSize =
            wide ? 96.0 : (width * .22).clamp(56.0, 80.0).toDouble();
        final titleStyle = wide ? theme.displaySmall : theme.headlineMedium;

        return Stack(
          alignment: AlignmentDirectional.centerStart,
          children: [
            if (showArtwork)
              PositionedDirectional(
                end: 0,
                width: artworkSize,
                top: spacing.xs,
                bottom: spacing.xs,
                child: IgnorePointer(
                  child: HomeRaisedArtwork(
                    asset: asset,
                    imageKey: artworkKey ?? ValueKey(asset),
                    width: artworkSize,
                    fallback: fallback,
                    foreground: tokens.vip.goldLight,
                  ),
                ),
              ),
            ConstrainedBox(
              constraints: BoxConstraints(minHeight: wide ? 112 : 96),
              child: Padding(
                padding: EdgeInsetsDirectional.fromSTEB(
                  0,
                  spacing.md,
                  showArtwork ? artworkSize + spacing.sm : 0,
                  spacing.md,
                ),
                child: Align(
                  alignment: AlignmentDirectional.centerStart,
                  heightFactor: 1,
                  child: Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: wide ? spacing.md : spacing.sm,
                    runSpacing: spacing.xs,
                    children: [
                      Semantics(
                        header: true,
                        child: Text(
                          title,
                          style: titleStyle.override(
                            color: theme.primaryText,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -1.1,
                            lineHeight: 1.05,
                          ),
                        ),
                      ),
                      if (action != null) action!,
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}
