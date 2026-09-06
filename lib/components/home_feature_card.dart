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
    final spacing = theme.designToken.spacing;
    final radius = theme.designToken.radius;
    final darkMode = Theme.of(context).brightness == Brightness.dark;
    final baseColor = _brandColor(theme);
    final isChance = widget.tone == HomeFeatureTone.chance;
    final isVideo = widget.tone == HomeFeatureTone.video;
    final foreground = isChance ? theme.onPrimary : theme.onDecorative;
    final cardRadius = BorderRadius.circular(radius.lg);
    final gradientColors = _gradientColors(
      theme: theme,
      darkMode: darkMode,
      baseColor: baseColor,
    );
    final borderColor = switch (widget.tone) {
      HomeFeatureTone.vip => theme.primary.withValues(alpha: 0.24),
      HomeFeatureTone.chance => theme.onPrimary.withValues(alpha: 0.10),
      HomeFeatureTone.video => theme.onDecorative.withValues(alpha: 0.14),
    };
    final highlightColor = switch (widget.tone) {
      HomeFeatureTone.vip => theme.primary.withValues(alpha: 0.32),
      HomeFeatureTone.chance => theme.onDecorative.withValues(alpha: 0.40),
      HomeFeatureTone.video => theme.onDecorative.withValues(alpha: 0.24),
    };
    final interactionOffset = _pressed
        ? const Offset(0.0, 0.004)
        : (_hovered ? const Offset(0.0, -0.008) : Offset.zero);
    final interactionScale = _pressed ? 0.985 : (_hovered ? 1.008 : 1.0);

    return Semantics(
      button: true,
      label: '${widget.title}. ${widget.description}',
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
              child: AnimatedSlide(
                offset: interactionOffset,
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOutCubic,
                child: AnimatedScale(
                  key: ValueKey(
                    'home-feature-interaction-scale-${widget.semanticId}',
                  ),
                  scale: interactionScale,
                  duration: const Duration(milliseconds: 180),
                  curve: Curves.easeOutCubic,
                  child: AnimatedContainer(
                    key: ValueKey(
                      'home-feature-gradient-${widget.semanticId}',
                    ),
                    height: 150.0,
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeOutCubic,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: _hovered
                            ? const Alignment(-1.0, -0.65)
                            : const Alignment(-1.0, -0.80),
                        end: _hovered
                            ? const Alignment(1.0, 0.65)
                            : const Alignment(1.0, 0.80),
                        colors: gradientColors,
                        stops: const [0.0, 0.38, 0.76, 1.0],
                      ),
                      borderRadius: cardRadius,
                      border: Border.all(color: borderColor),
                      boxShadow: [
                        _pressed
                            ? theme.designToken.shadow.sm
                            : theme.designToken.shadow.md,
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      borderRadius: cardRadius,
                      child: InkWell(
                        key: ValueKey(
                          'home-feature-card-${widget.semanticId}',
                        ),
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
                        child: ClipRRect(
                          borderRadius: cardRadius,
                          child: Stack(
                            children: [
                              Positioned.fill(
                                child: AnimatedScale(
                                  scale: _hovered ? 1.035 : 1.0,
                                  duration: const Duration(milliseconds: 240),
                                  curve: Curves.easeOutCubic,
                                  child: Container(
                                    key: ValueKey(
                                      'home-feature-glow-${widget.semanticId}',
                                    ),
                                    decoration: BoxDecoration(
                                      gradient: RadialGradient(
                                        center: const Alignment(0.65, -0.75),
                                        radius: 1.25,
                                        colors: [
                                          theme.onDecorative.withValues(
                                            alpha: isChance ? 0.12 : 0.06,
                                          ),
                                          theme.onDecorative
                                              .withValues(alpha: 0.02),
                                          theme.onDecorative
                                              .withValues(alpha: 0.0),
                                        ],
                                        stops: const [0.0, 0.45, 1.0],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              PositionedDirectional(
                                top: 1.0,
                                start: spacing.lg,
                                end: spacing.lg,
                                child: Container(
                                  key: ValueKey(
                                    'home-feature-3d-edge-${widget.semanticId}',
                                  ),
                                  height: 1.0,
                                  decoration: BoxDecoration(
                                    borderRadius: cardRadius,
                                    gradient: LinearGradient(
                                      colors: [
                                        highlightColor.withValues(alpha: 0.0),
                                        highlightColor,
                                        highlightColor.withValues(alpha: 0.0),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: spacing.md + spacing.xs,
                                  vertical: spacing.sm + spacing.xs,
                                ),
                                child: LayoutBuilder(
                                  builder: (context, constraints) {
                                    final compact =
                                        constraints.maxWidth < 300.0;
                                    final artworkSize = compact ? 84.0 : 96.0;
                                    final cacheWidth = (artworkSize *
                                            MediaQuery.devicePixelRatioOf(
                                              context,
                                            ))
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
                                                key: ValueKey(
                                                  'home-feature-title-${widget.semanticId}',
                                                ),
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                                style:
                                                    theme.titleLarge.override(
                                                  color: foreground,
                                                  fontSize:
                                                      compact ? 18.0 : 20.0,
                                                  fontWeight: FontWeight.w700,
                                                  lineHeight: 1.12,
                                                ),
                                              ),
                                              SizedBox(height: spacing.sm),
                                              Text(
                                                widget.description,
                                                key: ValueKey(
                                                  'home-feature-description-${widget.semanticId}',
                                                ),
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                                style:
                                                    theme.bodyMedium.override(
                                                  color: foreground.withValues(
                                                    alpha:
                                                        isChance ? 0.78 : 0.86,
                                                  ),
                                                  fontSize:
                                                      compact ? 12.0 : 13.0,
                                                  fontWeight: FontWeight.w500,
                                                  lineHeight: 1.30,
                                                ),
                                              ),
                                              const Spacer(),
                                              AnimatedContainer(
                                                key: ValueKey(
                                                  'home-feature-arrow-${widget.semanticId}',
                                                ),
                                                width: 32.0,
                                                height: 32.0,
                                                duration: const Duration(
                                                  milliseconds: 180,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: isChance
                                                      ? theme.onPrimary
                                                      : (widget.tone ==
                                                              HomeFeatureTone
                                                                  .vip
                                                          ? theme.primary
                                                          : foreground
                                                              .withValues(
                                                              alpha: _hovered
                                                                  ? 0.18
                                                                  : 0.12,
                                                            )),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                    radius.full,
                                                  ),
                                                  border: Border.all(
                                                    color:
                                                        foreground.withValues(
                                                            alpha: 0.16),
                                                  ),
                                                ),
                                                child: AnimatedSlide(
                                                  offset: _hovered
                                                      ? const Offset(0.06, 0.0)
                                                      : Offset.zero,
                                                  duration: const Duration(
                                                    milliseconds: 180,
                                                  ),
                                                  curve: Curves.easeOutCubic,
                                                  child: Icon(
                                                    Icons.arrow_forward_rounded,
                                                    color: isChance
                                                        ? theme.primary
                                                        : (widget.tone ==
                                                                HomeFeatureTone
                                                                    .vip
                                                            ? theme.onPrimary
                                                            : foreground),
                                                    size: 18.0,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(width: spacing.sm),
                                        ExcludeSemantics(
                                          child: AnimatedRotation(
                                            turns: _hovered
                                                ? (isVideo ? 0.004 : -0.004)
                                                : 0.0,
                                            duration: const Duration(
                                              milliseconds: 220,
                                            ),
                                            curve: Curves.easeOutCubic,
                                            child: AnimatedScale(
                                              key: ValueKey(
                                                'home-feature-artwork-motion-${widget.semanticId}',
                                              ),
                                              scale: _pressed
                                                  ? 0.97
                                                  : (_hovered ? 1.03 : 1.0),
                                              duration: const Duration(
                                                milliseconds: 200,
                                              ),
                                              curve: Curves.easeOutCubic,
                                              child: SizedBox.square(
                                                dimension: artworkSize,
                                                child: _artwork(
                                                  size: artworkSize,
                                                  cacheWidth: cacheWidth,
                                                  foreground: foreground,
                                                ),
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
            ),
          ),
        ),
      ),
    );
  }
}
