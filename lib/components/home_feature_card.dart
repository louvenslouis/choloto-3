import 'package:flutter/material.dart';

import '/flutter_flow/flutter_flow_theme.dart';

enum HomeFeatureTone { vip, chance, video }

class HomeFeatureSection extends StatelessWidget {
  const HomeFeatureSection({
    super.key,
    required this.vipCard,
    required this.chanceCard,
    required this.draws,
    required this.videoCard,
  });

  final Widget vipCard;
  final Widget chanceCard;
  final Widget draws;
  final Widget videoCard;

  @override
  Widget build(BuildContext context) {
    final spacing = FlutterFlowTheme.of(context).designToken.spacing;

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 680.0) {
          return Column(
            key: const ValueKey('home-feature-mobile-layout'),
            children: [
              vipCard,
              SizedBox(height: spacing.md),
              chanceCard,
              SizedBox(height: spacing.md),
              draws,
              SizedBox(height: spacing.md),
              videoCard,
            ],
          );
        }

        final columnCount = constraints.maxWidth >= 1000.0 ? 3 : 2;
        final gapCount = columnCount - 1;
        final cardWidth =
            (constraints.maxWidth - (spacing.md * gapCount)) / columnCount;

        return Column(
          key: const ValueKey('home-feature-wide-layout'),
          children: [
            Wrap(
              alignment: WrapAlignment.center,
              spacing: spacing.md,
              runSpacing: spacing.md,
              children: [
                SizedBox(width: cardWidth, child: vipCard),
                SizedBox(width: cardWidth, child: chanceCard),
                SizedBox(width: cardWidth, child: videoCard),
              ],
            ),
            SizedBox(height: spacing.md),
            draws,
          ],
        );
      },
    );
  }
}

class HomeFeatureCard extends StatefulWidget {
  const HomeFeatureCard({
    super.key,
    required this.semanticId,
    required this.title,
    required this.description,
    required this.assetPath,
    required this.tone,
    required this.onTap,
  });

  final String semanticId;
  final String title;
  final String description;
  final String assetPath;
  final HomeFeatureTone tone;
  final VoidCallback onTap;

  @override
  State<HomeFeatureCard> createState() => _HomeFeatureCardState();
}

class _HomeFeatureCardState extends State<HomeFeatureCard> {
  bool _hovered = false;
  bool _pressed = false;

  Color _brandColor(FlutterFlowTheme theme) {
    switch (widget.tone) {
      case HomeFeatureTone.vip:
        // The purple is the existing, feature-specific VIP identity.
        return const Color(0xFF650BB0);
      case HomeFeatureTone.chance:
        return theme.primary;
      case HomeFeatureTone.video:
        // A dedicated video red keeps the destination immediately recognizable.
        return const Color(0xFFE62117);
    }
  }

  Color _shiftLightness(Color color, double amount) {
    final hsl = HSLColor.fromColor(color);
    return hsl
        .withLightness(
          (hsl.lightness + amount).clamp(0.0, 1.0).toDouble(),
        )
        .toColor();
  }

  IconData get _fallbackIcon {
    switch (widget.tone) {
      case HomeFeatureTone.vip:
        return Icons.workspace_premium_rounded;
      case HomeFeatureTone.chance:
        return Icons.auto_awesome_rounded;
      case HomeFeatureTone.video:
        return Icons.play_arrow_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final spacing = theme.designToken.spacing;
    final radius = theme.designToken.radius;
    final darkMode = Theme.of(context).brightness == Brightness.dark;
    final baseColor = _brandColor(theme);
    final foreground = widget.tone == HomeFeatureTone.chance
        ? theme.onPrimary
        : theme.onDecorative;
    final glowColor = widget.tone == HomeFeatureTone.chance
        ? theme.onDecorative
        : theme.primary;
    final gradientColors = darkMode
        ? [
            _shiftLightness(baseColor, -0.28),
            _shiftLightness(baseColor, -0.10),
            baseColor,
          ]
        : [
            _shiftLightness(baseColor, -0.12),
            baseColor,
            _shiftLightness(baseColor, 0.10),
          ];

    return Semantics(
      button: true,
      label: '${widget.title}. ${widget.description}',
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: AnimatedScale(
          scale: _pressed ? 0.985 : (_hovered ? 1.012 : 1.0),
          duration: const Duration(milliseconds: 140),
          curve: Curves.easeOutCubic,
          child: Container(
            key: ValueKey('home-feature-gradient-${widget.semanticId}'),
            height: 184.0,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: gradientColors,
                stops: const [0.0, 0.58, 1.0],
              ),
              borderRadius: BorderRadius.circular(radius.lg),
              border: Border.all(
                color: foreground.withValues(alpha: darkMode ? 0.16 : 0.22),
              ),
              boxShadow: [theme.designToken.shadow.md],
            ),
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(radius.lg),
              child: InkWell(
                key: ValueKey('home-feature-card-${widget.semanticId}'),
                borderRadius: BorderRadius.circular(radius.lg),
                splashColor: foreground.withValues(alpha: 0.10),
                highlightColor: foreground.withValues(alpha: 0.06),
                hoverColor: foreground.withValues(alpha: 0.04),
                onHighlightChanged: (pressed) {
                  if (_pressed != pressed) {
                    setState(() => _pressed = pressed);
                  }
                },
                onTap: widget.onTap,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(radius.lg),
                  child: Stack(
                    children: [
                      PositionedDirectional(
                        top: -54.0,
                        end: -28.0,
                        child: Container(
                          width: 196.0,
                          height: 196.0,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                glowColor.withValues(alpha: 0.28),
                                glowColor.withValues(alpha: 0.0),
                              ],
                            ),
                          ),
                        ),
                      ),
                      PositionedDirectional(
                        bottom: -72.0,
                        start: -42.0,
                        child: Container(
                          width: 168.0,
                          height: 168.0,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: foreground.withValues(alpha: 0.055),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(spacing.md),
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            final compact = constraints.maxWidth < 300.0;
                            final iconSize = compact ? 104.0 : 124.0;
                            final cacheWidth = (iconSize *
                                    MediaQuery.devicePixelRatioOf(context))
                                .ceil();

                            return Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        widget.title,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: theme.titleLarge.override(
                                          color: foreground,
                                          fontSize: compact ? 19.0 : 21.0,
                                          fontWeight: FontWeight.w700,
                                          lineHeight: 1.05,
                                        ),
                                      ),
                                      SizedBox(height: spacing.sm),
                                      Text(
                                        widget.description,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: theme.bodyMedium.override(
                                          color: foreground.withValues(
                                            alpha: 0.84,
                                          ),
                                          fontSize: compact ? 12.5 : 13.5,
                                          fontWeight: FontWeight.w500,
                                          lineHeight: 1.25,
                                        ),
                                      ),
                                      const Spacer(),
                                      Container(
                                        width: 34.0,
                                        height: 34.0,
                                        decoration: BoxDecoration(
                                          color: foreground.withValues(
                                            alpha: 0.13,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            radius.full,
                                          ),
                                          border: Border.all(
                                            color: foreground.withValues(
                                              alpha: 0.13,
                                            ),
                                          ),
                                        ),
                                        child: Icon(
                                          Icons.arrow_forward_rounded,
                                          color: foreground,
                                          size: 19.0,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(width: spacing.sm),
                                ExcludeSemantics(
                                  child: Image.asset(
                                    widget.assetPath,
                                    key: ValueKey(
                                      'home-feature-image-${widget.semanticId}',
                                    ),
                                    width: iconSize,
                                    height: iconSize,
                                    cacheWidth: cacheWidth,
                                    fit: BoxFit.contain,
                                    errorBuilder: (_, __, ___) => SizedBox(
                                      width: iconSize,
                                      height: iconSize,
                                      child: Icon(
                                        _fallbackIcon,
                                        size: iconSize * 0.66,
                                        color: foreground,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
