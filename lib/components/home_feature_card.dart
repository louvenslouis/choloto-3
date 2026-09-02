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
    final entranceDelayMilliseconds = widget.tone.index * 90;
    final totalDurationMilliseconds = 620 + entranceDelayMilliseconds;
    final entranceStart = entranceDelayMilliseconds / totalDurationMilliseconds;
    _entranceController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: totalDurationMilliseconds),
    );
    _entranceOpacity = CurvedAnimation(
      parent: _entranceController,
      curve: Interval(
        entranceStart,
        entranceStart + ((1.0 - entranceStart) * 0.72),
        curve: Curves.easeOut,
      ),
    );
    _entranceScale = Tween<double>(begin: 0.96, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: Interval(
          entranceStart,
          1.0,
          curve: Curves.easeOutBack,
        ),
      ),
    );
    _entranceOffset = Tween<Offset>(
      begin: const Offset(0.0, 0.10),
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
    if (_entranceScheduled) {
      return;
    }
    _entranceScheduled = true;

    final reduceMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    if (reduceMotion) {
      _entranceController.value = 1.0;
      return;
    }

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

  List<Color> _gradientColors({
    required FlutterFlowTheme theme,
    required bool darkMode,
    required Color baseColor,
  }) {
    switch (widget.tone) {
      case HomeFeatureTone.vip:
        // Purple is the established VIP identity and has no equivalent theme
        // token. These shades deliberately stay dark enough for white copy.
        return darkMode
            ? const [
                Color(0xFF29103F),
                Color(0xFF5D168F),
                Color(0xFF7D2CAF),
              ]
            : const [
                Color(0xFF341047),
                Color(0xFF64188F),
                Color(0xFF7D2CAF),
              ];
      case HomeFeatureTone.chance:
        // This feature intentionally uses the CHOLOTO yellow as its surface;
        // onPrimary keeps the copy readable in both app themes.
        return [
          _shiftLightness(theme.primary, -0.08),
          theme.primary,
          _shiftLightness(theme.warning, 0.04),
        ];
      case HomeFeatureTone.video:
        // Preserve YouTube red while giving it the same gradient treatment.
        return darkMode
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

  Widget _featureArtwork({
    required double iconSize,
    required int cacheWidth,
    required Color foreground,
  }) {
    final imageKey = ValueKey('home-feature-image-${widget.semanticId}');

    return Image.asset(
      widget.assetPath,
      key: imageKey,
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
    final gradientColors = _gradientColors(
      theme: theme,
      darkMode: darkMode,
      baseColor: baseColor,
    );
    final borderColor = switch (widget.tone) {
      HomeFeatureTone.vip => theme.primary.withValues(alpha: 0.78),
      HomeFeatureTone.chance => theme.onPrimary.withValues(alpha: 0.24),
      HomeFeatureTone.video =>
        theme.onDecorative.withValues(alpha: darkMode ? 0.34 : 0.46),
    };
    final edgeHighlight = switch (widget.tone) {
      HomeFeatureTone.vip => theme.primary.withValues(alpha: 0.74),
      HomeFeatureTone.chance =>
        theme.onDecorative.withValues(alpha: darkMode ? 0.64 : 0.82),
      HomeFeatureTone.video =>
        theme.onDecorative.withValues(alpha: darkMode ? 0.46 : 0.62),
    };
    final glowColor = isVideo ? theme.primary : theme.onDecorative;
    final depthColor = _shiftLightness(baseColor, -0.26);
    final interactionOffset = _pressed
        ? const Offset(0.0, 0.012)
        : (_hovered ? const Offset(0.0, -0.022) : Offset.zero);
    final interactionScale = _pressed ? 0.972 : (_hovered ? 1.018 : 1.0);
    final cardRadius = BorderRadius.circular(radius.full);

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
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                child: AnimatedScale(
                  key: ValueKey(
                    'home-feature-interaction-scale-${widget.semanticId}',
                  ),
                  scale: interactionScale,
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOutCubic,
                  child: AnimatedContainer(
                    key: ValueKey(
                      'home-feature-gradient-${widget.semanticId}',
                    ),
                    height: 184.0,
                    duration: const Duration(milliseconds: 260),
                    curve: Curves.easeOutCubic,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: _hovered
                            ? const Alignment(-0.82, -1.0)
                            : Alignment.topLeft,
                        end: _hovered
                            ? const Alignment(0.92, 1.0)
                            : Alignment.bottomRight,
                        colors: gradientColors,
                        stops: const [0.0, 0.52, 1.0],
                      ),
                      borderRadius: cardRadius,
                      border: Border.all(color: borderColor, width: 2.0),
                      // The design-system shadow anchors the surface; the
                      // tone-derived shadow supplies the requested 3D depth.
                      boxShadow: [
                        theme.designToken.shadow.lg,
                        BoxShadow(
                          color: depthColor.withValues(
                            alpha: darkMode ? 0.62 : 0.34,
                          ),
                          offset: Offset(
                            0.0,
                            _pressed ? 2.0 : (_hovered ? 10.0 : 7.0),
                          ),
                          blurRadius: _pressed ? 5.0 : 13.0,
                          spreadRadius: -2.0,
                        ),
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
                        splashColor: foreground.withValues(alpha: 0.12),
                        highlightColor: foreground.withValues(alpha: 0.08),
                        hoverColor: foreground.withValues(alpha: 0.05),
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
                              PositionedDirectional(
                                top: -52.0,
                                end: -24.0,
                                child: AnimatedScale(
                                  scale: _hovered ? 1.10 : 1.0,
                                  duration: const Duration(milliseconds: 360),
                                  curve: Curves.easeOutCubic,
                                  child: Container(
                                    width: 194.0,
                                    height: 194.0,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: RadialGradient(
                                        colors: [
                                          glowColor.withValues(
                                            alpha: isChance ? 0.34 : 0.28,
                                          ),
                                          glowColor.withValues(alpha: 0.0),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              PositionedDirectional(
                                bottom: -70.0,
                                start: -38.0,
                                child: Container(
                                  width: 166.0,
                                  height: 166.0,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: foreground.withValues(alpha: 0.065),
                                  ),
                                ),
                              ),
                              PositionedDirectional(
                                top: 1.0,
                                start: spacing.xl,
                                end: spacing.xl,
                                child: Container(
                                  key: ValueKey(
                                    'home-feature-3d-edge-${widget.semanticId}',
                                  ),
                                  height: 3.0,
                                  decoration: BoxDecoration(
                                    borderRadius: cardRadius,
                                    gradient: LinearGradient(
                                      colors: [
                                        edgeHighlight.withValues(alpha: 0.0),
                                        edgeHighlight,
                                        edgeHighlight.withValues(alpha: 0.0),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              PositionedDirectional(
                                bottom: 0.0,
                                start: spacing.lg,
                                end: spacing.lg,
                                child: Container(
                                  height: 9.0,
                                  decoration: BoxDecoration(
                                    borderRadius: cardRadius,
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        depthColor.withValues(alpha: 0.0),
                                        depthColor.withValues(alpha: 0.34),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              if (!isVideo)
                                PositionedDirectional(
                                  top: 0.0,
                                  start: spacing.xl,
                                  end: spacing.xl,
                                  child: Container(
                                    key: ValueKey(
                                      'home-feature-accent-${widget.semanticId}',
                                    ),
                                    height: 2.0,
                                    decoration: BoxDecoration(
                                      borderRadius: cardRadius,
                                      gradient: LinearGradient(
                                        colors: [
                                          theme.primary.withValues(alpha: 0.0),
                                          theme.primary,
                                          theme.primary.withValues(alpha: 0.0),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: spacing.lg,
                                  vertical: spacing.md,
                                ),
                                child: LayoutBuilder(
                                  builder: (context, constraints) {
                                    final compact =
                                        constraints.maxWidth < 300.0;
                                    final iconSize = compact ? 100.0 : 120.0;
                                    final cacheWidth = (iconSize *
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
                                                      compact ? 18.0 : 21.0,
                                                  fontWeight: FontWeight.w800,
                                                  lineHeight: 1.05,
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
                                                    alpha: isChance
                                                        ? 0.76
                                                        : (isVideo
                                                            ? 0.86
                                                            : 0.92),
                                                  ),
                                                  fontSize:
                                                      compact ? 12.0 : 13.5,
                                                  fontWeight: FontWeight.w600,
                                                  lineHeight: 1.25,
                                                ),
                                              ),
                                              const Spacer(),
                                              AnimatedContainer(
                                                key: ValueKey(
                                                  'home-feature-arrow-${widget.semanticId}',
                                                ),
                                                width: 36.0,
                                                height: 36.0,
                                                duration: const Duration(
                                                  milliseconds: 220,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: isChance
                                                      ? theme.onPrimary
                                                      : foreground.withValues(
                                                          alpha: _hovered
                                                              ? 0.22
                                                              : 0.14,
                                                        ),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                    radius.full,
                                                  ),
                                                  border: Border.all(
                                                    color: isChance
                                                        ? theme.onDecorative
                                                            .withValues(
                                                            alpha: 0.28,
                                                          )
                                                        : foreground.withValues(
                                                            alpha: 0.20,
                                                          ),
                                                  ),
                                                  boxShadow: _hovered
                                                      ? [
                                                          theme.designToken
                                                              .shadow.sm,
                                                        ]
                                                      : const [],
                                                ),
                                                child: AnimatedSlide(
                                                  offset: _hovered
                                                      ? const Offset(0.10, 0.0)
                                                      : Offset.zero,
                                                  duration: const Duration(
                                                    milliseconds: 220,
                                                  ),
                                                  curve: Curves.easeOutCubic,
                                                  child: Icon(
                                                    Icons.arrow_forward_rounded,
                                                    color: isChance
                                                        ? theme.primary
                                                        : foreground,
                                                    size: 19.0,
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
                                                ? (isVideo ? 0.010 : -0.010)
                                                : 0.0,
                                            duration: const Duration(
                                              milliseconds: 320,
                                            ),
                                            curve: Curves.easeOutCubic,
                                            child: AnimatedScale(
                                              key: ValueKey(
                                                'home-feature-artwork-motion-${widget.semanticId}',
                                              ),
                                              scale: _pressed
                                                  ? 0.94
                                                  : (_hovered ? 1.065 : 1.0),
                                              duration: const Duration(
                                                milliseconds: 260,
                                              ),
                                              curve: Curves.easeOutBack,
                                              child: Container(
                                                width: iconSize,
                                                height: iconSize,
                                                decoration: isVideo
                                                    ? null
                                                    : BoxDecoration(
                                                        shape: BoxShape.circle,
                                                        gradient:
                                                            RadialGradient(
                                                          colors: [
                                                            glowColor
                                                                .withValues(
                                                              alpha: 0.22,
                                                            ),
                                                            glowColor
                                                                .withValues(
                                                              alpha: 0.0,
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                child: _featureArtwork(
                                                  iconSize: iconSize,
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
