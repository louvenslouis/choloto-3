import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '/flutter_flow/flutter_flow_theme.dart';

enum HomeFeatureTone { draws, chance }

class HomeFeatureCard extends StatefulWidget {
  const HomeFeatureCard({
    super.key,
    required this.semanticId,
    required this.title,
    required this.assetPath,
    required this.tone,
    required this.onTap,
    this.minHeight = 112,
  });

  final String semanticId;
  final String title;
  final double minHeight;
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

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final tokens = theme.designToken;
    final draws = widget.tone == HomeFeatureTone.draws;
    final foreground = draws ? theme.onPrimary : theme.onDecorative;
    final cardRadius = BorderRadius.circular(tokens.radius.lg);
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final duration =
        reduceMotion ? Duration.zero : const Duration(milliseconds: 180);

    return Semantics(
      button: true,
      onTap: widget.onTap,
      label: widget.title,
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
                  duration: duration,
                  decoration: BoxDecoration(
                    gradient:
                        draws ? tokens.home.membership : tokens.home.chance,
                    image: DecorationImage(
                      image: AssetImage(draws
                          ? 'assets/images/home/brushed_gold.webp'
                          : 'assets/images/home/amethyst.webp'),
                      fit: BoxFit.cover,
                      opacity: draws ? 1 : 0.8,
                      colorFilter: draws
                          ? null
                          : ColorFilter.mode(
                              theme.onPrimary.withValues(alpha: 0.22),
                              BlendMode.srcATop,
                            ),
                    ),
                    borderRadius: cardRadius,
                    border: Border.all(
                      color: theme.onDecorative
                          .withValues(alpha: _hovered ? 0.60 : 0.30),
                    ),
                    boxShadow: [tokens.shadow.sm],
                  ),
                  child: Material(
                    type: MaterialType.transparency,
                    child: InkWell(
                      key: ValueKey('home-feature-card-${widget.semanticId}'),
                      borderRadius: cardRadius,
                      splashColor: foreground.withValues(alpha: .10),
                      highlightColor: foreground.withValues(alpha: .06),
                      hoverColor: foreground.withValues(alpha: .035),
                      onHighlightChanged: (pressed) {
                        if (_pressed != pressed) {
                          setState(() => _pressed = pressed);
                        }
                      },
                      onTap: widget.onTap,
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final width = constraints.maxWidth;
                          final scaler = MediaQuery.textScalerOf(context);
                          final portrait =
                              width / (scaler.scale(16) / 16) < 240;
                          final inset = width < 175
                              ? tokens.spacing.sm + tokens.spacing.xs
                              : tokens.spacing.md;
                          final artHeight = portrait
                              ? math.min(width * .53, widget.minHeight * .75)
                              : math.min(widget.minHeight * 1.04, width * .42);
                          final artWidth = artHeight * (draws ? .80 : 1.0);
                          final artTop = -artHeight * (portrait ? .18 : .07);
                          final artRight =
                              portrait ? tokens.spacing.xs : tokens.spacing.sm;
                          final title = Text(
                            widget.title,
                            key: ValueKey(
                                'home-feature-title-${widget.semanticId}'),
                            style: theme.titleLarge.override(
                              color: foreground,
                              fontSize: (width * (portrait ? .117 : .083))
                                  .clamp(17.0, 39.0),
                              fontWeight: FontWeight.w900,
                              letterSpacing: -.65,
                              lineHeight: 1.02,
                            ),
                          );
                          return Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Positioned(
                                top: artTop,
                                right: artRight,
                                width: artWidth,
                                height: artHeight,
                                child: IgnorePointer(
                                  child: AnimatedScale(
                                    key: ValueKey(
                                        'home-feature-artwork-motion-${widget.semanticId}'),
                                    scale: reduceMotion
                                        ? 1
                                        : (_pressed
                                            ? .97
                                            : (_hovered ? 1.03 : 1)),
                                    duration: duration,
                                    child: HomeRaisedArtwork(
                                      asset: widget.assetPath,
                                      imageKey: ValueKey(
                                          'home-feature-image-${widget.semanticId}'),
                                      width: artWidth,
                                      fallback: draws
                                          ? Icons.confirmation_number_outlined
                                          : Icons.close_rounded,
                                      foreground: foreground,
                                    ),
                                  ),
                                ),
                              ),
                              ConstrainedBox(
                                constraints:
                                    BoxConstraints(minHeight: widget.minHeight),
                                child: Padding(
                                  padding: EdgeInsets.fromLTRB(
                                    inset,
                                    portrait
                                        ? artHeight * .77
                                        : tokens.spacing.sm,
                                    portrait ? inset : artWidth + artRight,
                                    portrait ? inset : tokens.spacing.sm,
                                  ),
                                  child: Align(
                                    heightFactor: 1,
                                    alignment: portrait
                                        ? Alignment.bottomLeft
                                        : Alignment.centerLeft,
                                    child: title,
                                  ),
                                ),
                              ),
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
    );
  }
}

/// The same cutout casts a soft shadow that follows its transparent silhouette.
class HomeRaisedArtwork extends StatelessWidget {
  const HomeRaisedArtwork({
    super.key,
    required this.asset,
    required this.imageKey,
    required this.width,
    required this.fallback,
    required this.foreground,
  });

  final String asset;
  final Key imageKey;
  final double width;
  final IconData fallback;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    final material = FlutterFlowTheme.of(context);
    final image = ResizeImage.resizeIfNeeded(
      (width * MediaQuery.devicePixelRatioOf(context)).ceil(),
      null,
      AssetImage(asset),
    );
    final blur = (width * .023).clamp(2.0, 8.0);
    return RepaintBoundary(
      child: Stack(
        fit: StackFit.expand,
        clipBehavior: Clip.none,
        children: [
          Transform.translate(
            offset: Offset(blur * .65, blur * 1.9),
            child: ImageFiltered(
              imageFilter: ui.ImageFilter.blur(sigmaX: blur, sigmaY: blur),
              child: Image(
                image: image,
                fit: BoxFit.contain,
                color: material.onPrimary.withValues(alpha: .68),
                colorBlendMode: BlendMode.srcIn,
                excludeFromSemantics: true,
                errorBuilder: (_, __, ___) => const SizedBox.shrink(),
              ),
            ),
          ),
          Image(
            image: image,
            key: imageKey,
            fit: BoxFit.contain,
            excludeFromSemantics: true,
            errorBuilder: (_, __, ___) =>
                Icon(fallback, size: width * .7, color: foreground),
          ),
        ],
      ),
    );
  }
}
