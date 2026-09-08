import 'dart:math' as math;

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
    this.stories,
  });

  final Widget vipCard;
  final Widget chanceCard;
  final Widget draws;
  final Widget videoCard;
  final Widget? stories;

  @override
  Widget build(BuildContext context) {
    final spacing = FlutterFlowTheme.of(context).designToken.spacing;

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 680.0) {
          final shortScreen = MediaQuery.sizeOf(context).height < 700.0;
          return Column(
            key: const ValueKey('home-feature-mobile-layout'),
            children: [
              if (stories != null && !shortScreen) ...[
                stories!,
                SizedBox(height: spacing.sm),
              ],
              vipCard,
              SizedBox(height: spacing.sm),
              chanceCard,
              SizedBox(height: spacing.sm),
              draws,
              SizedBox(height: spacing.sm),
              if (stories != null && shortScreen) ...[
                stories!,
                SizedBox(height: spacing.sm),
              ],
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
            if (stories != null) ...[
              stories!,
              SizedBox(height: spacing.sm),
            ],
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
            SizedBox(height: spacing.sm),
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

class _HomeFeatureCardState extends State<HomeFeatureCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _entranceController;
  late final Animation<double> _entranceOpacity;
  late final Animation<double> _entranceScale;
  late final Animation<Offset> _entranceOffset;

  bool _hovered = false;
  bool _pressed = false;
  bool _entranceScheduled = false;

  @override
  void initState() {
    super.initState();
    final delayMilliseconds = widget.tone.index * 55;
    final totalMilliseconds = 480 + delayMilliseconds;
    final entranceStart = delayMilliseconds / totalMilliseconds;

    _entranceController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: totalMilliseconds),
    );
    _entranceOpacity = CurvedAnimation(
      parent: _entranceController,
      curve: Interval(
        entranceStart,
        entranceStart + ((1.0 - entranceStart) * 0.70),
        curve: Curves.easeOut,
      ),
    );
    _entranceScale = Tween<double>(begin: 0.985, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: Interval(
          entranceStart,
          1.0,
          curve: Curves.easeOutCubic,
        ),
      ),
    );
    _entranceOffset = Tween<Offset>(
      begin: const Offset(0.0, 0.045),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: Interval(
          entranceStart,
          1.0,
          curve: Curves.easeOutCubic,
        ),
      ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduceMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    if (reduceMotion) {
      _entranceController.value = 1.0;
      _entranceScheduled = true;
      return;
    }
    if (_entranceScheduled) {
      return;
    }
    _entranceScheduled = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _entranceController.forward();
      }
    });
  }

  @override
  void dispose() {
    _entranceController.dispose();
    super.dispose();
  }

  Color _brandColor(FlutterFlowTheme theme) {
    switch (widget.tone) {
      case HomeFeatureTone.vip:
        // VIP purple is an established feature identity without a theme token.
        return const Color(0xFF5D2A78);
      case HomeFeatureTone.chance:
        return theme.primary;
      case HomeFeatureTone.video:
        // YouTube red remains a deliberate destination-specific exception.
        return const Color(0xFFE62117);
    }
  }

  List<Color> _gradientColors({
    required FlutterFlowTheme theme,
    required bool darkMode,
    required Color baseColor,
  }) {
    Color shade(double amount) =>
        Color.lerp(baseColor, theme.onPrimary, amount)!;

    // A broad, off-centre highlight gives the existing artwork a satin backdrop.
    // Keep the text side deep and derive every shade from the feature identity.
    switch (widget.tone) {
      case HomeFeatureTone.vip:
        return [
          shade(darkMode ? 0.52 : 0.42),
          shade(0.24),
          baseColor,
          shade(0.18),
        ];
      case HomeFeatureTone.chance:
        return [
          shade(darkMode ? 0.12 : 0.08),
          theme.primary,
          Color.lerp(theme.primary, theme.onDecorative, 0.28)!,
          Color.lerp(theme.primary, theme.onDecorative, 0.08)!,
        ];
      case HomeFeatureTone.video:
        return [
          shade(darkMode ? 0.64 : 0.56),
          shade(0.46),
          shade(0.32),
          shade(0.44),
        ];
    }
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

  Widget _artwork({
    required double size,
    required int cacheWidth,
    required Color foreground,
  }) {
    return Image.asset(
      widget.assetPath,
      key: ValueKey('home-feature-image-${widget.semanticId}'),
      width: size,
      height: size,
      cacheWidth: cacheWidth,
      fit: BoxFit.contain,
      errorBuilder: (_, __, ___) => SizedBox.square(
        dimension: size,
        child: Icon(
          _fallbackIcon,
          size: size * 0.62,
          color: foreground,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final tokens = theme.designToken;
    final viewport = MediaQuery.sizeOf(context);
    final compact = viewport.height > 0 &&
        viewport.height < 700 &&
        viewport.width < 680 &&
        MediaQuery.textScalerOf(context).scale(14) <= 20;
    final isChance = widget.tone == HomeFeatureTone.chance;
    final isVideo = widget.tone == HomeFeatureTone.video;
    final foreground = isVideo
        ? theme.primaryText
        : (isChance ? theme.onPrimary : theme.onDecorative);
    final cardRadius = BorderRadius.circular(tokens.radius.lg);
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final duration =
        reduceMotion ? Duration.zero : const Duration(milliseconds: 180);
    final gradientColors = isVideo
        ? [theme.secondaryBackground, theme.secondaryBackground]
        : _gradientColors(
            theme: theme,
            darkMode: Theme.of(context).brightness == Brightness.dark,
            baseColor: _brandColor(theme),
          );

    return Semantics(
      button: true,
      onTap: widget.onTap,
      label: '${widget.title}. ${widget.description}',
      excludeSemantics: true,
      child: FadeTransition(
        key: ValueKey('home-feature-entrance-${widget.semanticId}'),
        opacity: _entranceOpacity,
        child: SlideTransition(
          position: _entranceOffset,
          child: ScaleTransition(
            scale: _entranceScale,
            child: MouseRegion(
              onEnter: (_) => setState(() => _hovered = true),
              onExit: (_) => setState(() {
                _hovered = false;
                _pressed = false;
              }),
              child: AnimatedScale(
                key: ValueKey(
                  'home-feature-interaction-scale-${widget.semanticId}',
                ),
                scale: reduceMotion
                    ? 1.0
                    : (_pressed ? 0.985 : (_hovered ? 1.008 : 1.0)),
                duration: duration,
                curve: Curves.easeOutCubic,
                child: AnimatedContainer(
                  key: ValueKey('home-feature-gradient-${widget.semanticId}'),
                  constraints: BoxConstraints(minHeight: compact ? 48.0 : 88.0),
                  duration: duration,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.bottomRight,
                      colors: gradientColors,
                    ),
                    borderRadius: cardRadius,
                    border: Border.all(
                      color:
                          foreground.withValues(alpha: _hovered ? 0.22 : 0.10),
                    ),
                  ),
                  child: Material(
                    type: MaterialType.transparency,
                    child: InkWell(
                      key: ValueKey('home-feature-card-${widget.semanticId}'),
                      borderRadius: cardRadius,
                      splashColor: foreground.withValues(alpha: 0.10),
                      highlightColor: foreground.withValues(alpha: 0.06),
                      hoverColor: foreground.withValues(alpha: 0.035),
                      onHighlightChanged: (pressed) {
                        if (_pressed != pressed) {
                          setState(() => _pressed = pressed);
                        }
                      },
                      onTap: widget.onTap,
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: tokens.spacing.md,
                          vertical:
                              compact ? tokens.spacing.xs : tokens.spacing.sm,
                        ),
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            // Give enlarged text the full card width; the artwork
                            // is decorative and may sit above it when space is tight.
                            final stacked =
                                MediaQuery.textScalerOf(context).scale(14.0) >
                                    20.0;
                            final artworkSize = compact
                                ? 40.0
                                : (constraints.maxWidth < 300.0 ? 56.0 : 72.0);
                            final artwork = ExcludeSemantics(
                              child: AnimatedScale(
                                key: ValueKey(
                                  'home-feature-artwork-motion-${widget.semanticId}',
                                ),
                                scale: reduceMotion
                                    ? 1.0
                                    : (_pressed
                                        ? 0.97
                                        : (_hovered ? 1.03 : 1.0)),
                                duration: duration,
                                child: SizedBox.square(
                                  dimension: artworkSize,
                                  child: Stack(
                                    fit: StackFit.expand,
                                    children: [
                                      _artwork(
                                        size: artworkSize,
                                        cacheWidth: (artworkSize *
                                                MediaQuery.devicePixelRatioOf(
                                                    context))
                                            .ceil(),
                                        foreground: foreground,
                                      ),
                                      if (widget.tone == HomeFeatureTone.vip)
                                        const Positioned.fill(
                                          child: _VipSparkles(),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                            final copy = Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.title,
                                  key: ValueKey(
                                    'home-feature-title-${widget.semanticId}',
                                  ),
                                  style: theme.titleLarge.override(
                                    color: foreground,
                                    fontSize: 18.0,
                                    fontWeight: FontWeight.w700,
                                    lineHeight: 1.15,
                                  ),
                                ),
                                if (!compact) ...[
                                  SizedBox(height: tokens.spacing.xs),
                                  Text(
                                    widget.description,
                                    key: ValueKey(
                                      'home-feature-description-${widget.semanticId}',
                                    ),
                                    style: theme.bodyMedium.override(
                                      color: foreground.withValues(alpha: 0.82),
                                      fontSize: 14.0,
                                      lineHeight: 1.3,
                                    ),
                                  ),
                                ],
                              ],
                            );
                            if (stacked) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  artwork,
                                  SizedBox(height: tokens.spacing.md),
                                  copy,
                                ],
                              );
                            }
                            return Row(
                              children: [
                                Expanded(child: copy),
                                SizedBox(width: tokens.spacing.sm),
                                artwork,
                              ],
                            );
                          },
                        ),
                      ),
                    ),
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

/// Decorative stars stay inside the artwork so they never obscure the copy.
class _VipSparkles extends StatefulWidget {
  const _VipSparkles();

  @override
  State<_VipSparkles> createState() => _VipSparklesState();
}

class _VipSparklesState extends State<_VipSparkles>
    with SingleTickerProviderStateMixin {
  late final _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2800),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context) ||
        !TickerMode.valuesOf(context).enabled) {
      _controller.stop();
    } else if (!_controller.isAnimating) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return IgnorePointer(
      child: ExcludeSemantics(
        child: RepaintBoundary(
          child: CustomPaint(
            key: const ValueKey('home-vip-sparkles'),
            painter: _VipSparklePainter(
              _controller,
              Color.lerp(theme.primary, theme.onDecorative, 0.55)!,
            ),
          ),
        ),
      ),
    );
  }
}

class _VipSparklePainter extends CustomPainter {
  _VipSparklePainter(this.animation, this.color) : super(repaint: animation);

  final Animation<double> animation;
  final Color color;

  // Relative positions keep the same constellation on compact and wide cards.
  static const _stars = [
    (Offset(0.13, 0.20), 4.0, 0.0),
    (Offset(0.47, 0.09), 3.0, 0.38),
    (Offset(0.85, 0.18), 4.5, 0.70),
    (Offset(0.91, 0.61), 3.0, 0.18),
    (Offset(0.70, 0.88), 3.5, 0.54),
    (Offset(0.12, 0.74), 3.0, 0.84),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    for (final (position, radius, phase) in _stars) {
      final pulse = (1 + math.sin((animation.value + phase) * 2 * math.pi)) / 2;
      final extent = radius * (0.65 + pulse * 0.35);
      final inset = extent * 0.24;
      canvas.save();
      canvas.translate(position.dx * size.width, position.dy * size.height);
      canvas.drawPath(
        Path()
          ..moveTo(0, -extent)
          ..lineTo(inset, -inset)
          ..lineTo(extent, 0)
          ..lineTo(inset, inset)
          ..lineTo(0, extent)
          ..lineTo(-inset, inset)
          ..lineTo(-extent, 0)
          ..lineTo(-inset, -inset)
          ..close(),
        paint..color = color.withValues(alpha: 0.18 + pulse * 0.72),
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_VipSparklePainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.animation != animation;
}
