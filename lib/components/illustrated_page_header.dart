import 'package:flutter/material.dart';

import '/flutter_flow/flutter_flow_theme.dart';
import 'home_feature_card.dart';

class IllustratedPageHeader extends StatelessWidget {
  const IllustratedPageHeader(
      {super.key,
      required this.title,
      required this.asset,
      required this.fallback,
      this.artworkKey,
      this.action});
  final String title;
  final String asset;
  final IconData fallback;
  final Key? artworkKey;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final tokens = theme.designToken;
    final spacing = tokens.spacing;
    return LayoutBuilder(builder: (context, constraints) {
      final width = constraints.maxWidth;
      final wide = width >= 600;
      final narrow = width < 320;
      final textScale = MediaQuery.textScalerOf(context).scale(32) / 32;
      final showArtwork = width / textScale >= 230;
      final inset = wide ? spacing.xl : spacing.md;
      final artworkSize =
          wide ? 136.0 : (width * .27).clamp(64.0, 104.0).toDouble();
      final titleStyle = wide
          ? theme.displayMedium
          : narrow
              ? theme.headlineMedium
              : theme.displaySmall;

      return Container(
        decoration: BoxDecoration(
          gradient: tokens.home.hero,
          image: const DecorationImage(
            image: AssetImage('assets/images/home/sapphire.webp'),
            fit: BoxFit.cover,
            alignment: Alignment.centerRight,
            opacity: .67,
          ),
          borderRadius: BorderRadius.circular(tokens.radius.lg),
          border:
              Border.all(color: tokens.home.heroGlow.withValues(alpha: .36)),
        ),
        child: Stack(
          alignment: AlignmentDirectional.centerStart,
          children: [
            if (showArtwork)
              PositionedDirectional(
                end: inset,
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
              constraints: BoxConstraints(minHeight: wide ? 144 : 110),
              child: Padding(
                padding: EdgeInsetsDirectional.fromSTEB(
                  inset,
                  spacing.md,
                  inset + (showArtwork ? artworkSize + spacing.xs : 0),
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
                            fontWeight: FontWeight.w900,
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
        ),
      );
    });
  }
}
