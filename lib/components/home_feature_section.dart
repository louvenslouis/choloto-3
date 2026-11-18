import 'dart:math' as math;

import 'package:flutter/material.dart';

import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'home_feature_card.dart';

class HomeFeatureSection extends StatelessWidget {
  const HomeFeatureSection({
    super.key,
    this.stories,
    required this.draws,
    required this.onViewResults,
    required this.onVip,
    required this.onChance,
    required this.onVideo,
    required this.onStats,
    required this.onTchala,
    required this.onHistory,
  });

  final Widget? stories;
  final Widget draws;
  final VoidCallback onViewResults;
  final VoidCallback onVip;
  final VoidCallback onChance;
  final VoidCallback onVideo;
  final VoidCallback onStats;
  final VoidCallback onTchala;
  final VoidCallback onHistory;

  @override
  Widget build(BuildContext context) {
    final strings = FFLocalizations.of(context);
    final spacing = FlutterFlowTheme.of(context).designToken.spacing;
    final scale = MediaQuery.textScalerOf(context).scale(16) / 16;
    return LayoutBuilder(builder: (context, constraints) {
      final width = constraints.maxWidth;
      final wide = width >= 720 && width / scale >= 620;
      final gap = wide ? spacing.md : spacing.sm;
      final heroWidth = wide ? (width - gap) * .65 : width;
      final heroHeight = (heroWidth * .53).clamp(174.0, 405.0);
      final tileHeight =
          wide ? (heroHeight - gap) / 2 : (width * .32).clamp(112.0, 170.0);
      final hero = _VipHero(height: heroHeight, onTap: onVip);
      final latestDraws = HomeFeatureCard(
        semanticId: 'draws',
        tone: HomeFeatureTone.draws,
        title: strings.getText('home_latest_draws'),
        assetPath: 'assets/images/home/lottery_drum.webp',
        minHeight: tileHeight,
        onTap: onViewResults,
      );
      final chance = HomeFeatureCard(
        semanticId: 'chance',
        tone: HomeFeatureTone.chance,
        title: strings.getText('afym167o'),
        assetPath: 'assets/images/home/lucky_cross_3d_x.png',
        minHeight: tileHeight,
        onTap: onChance,
      );
      final shortcuts = _HomeShortcuts(
        wide: wide,
        onVideo: onVideo,
        onStats: onStats,
        onTchala: onTchala,
        onHistory: onHistory,
      );

      Widget split(Widget leading, Widget trailing) => Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(width: heroWidth, child: leading),
              SizedBox(width: gap),
              Expanded(child: trailing),
            ],
          );
      return Column(
        key: ValueKey(
            wide ? 'home-feature-wide-layout' : 'home-feature-mobile-layout'),
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (stories != null) ...[
            stories!,
            SizedBox(height: spacing.md),
          ],
          if (wide) ...[
            split(hero,
                Column(children: [latestDraws, SizedBox(height: gap), chance])),
            SizedBox(height: spacing.lg),
            split(draws, shortcuts),
          ] else ...[
            hero,
            SizedBox(height: spacing.md),
            if (width / scale < 255) ...[
              latestDraws,
              SizedBox(height: gap),
              chance,
            ] else
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: latestDraws),
                  SizedBox(width: gap),
                  Expanded(child: chance),
                ],
              ),
            SizedBox(height: spacing.md),
            shortcuts,
            SizedBox(height: spacing.md),
            draws,
          ],
        ],
      );
    });
  }
}

class _VipHero extends StatelessWidget {
  const _VipHero({required this.height, required this.onTap});

  final double height;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final tokens = theme.designToken;
    final strings = FFLocalizations.of(context);
    final title = strings.getText('covzb0rd');
    final action = strings.getText('home_open_vip');
    final radius = BorderRadius.circular(tokens.radius.lg);
    return LayoutBuilder(builder: (context, constraints) {
      final width = constraints.maxWidth;
      final large = width >= 495;
      final scaler = MediaQuery.textScalerOf(context);
      final inset = large ? tokens.spacing.lg : tokens.spacing.md;
      final contentWidth = width - inset - tokens.spacing.sm;
      final titleStyle = theme.displaySmall.override(
        fontSize: (width * .092).clamp(25.0, 74.0),
        fontWeight: FontWeight.w900,
        color: theme.onPrimary,
        letterSpacing: large ? -1.8 : -.8,
        lineHeight: 1.03,
      );
      // Reserve enough space for the longest localized word, including at
      // accessibility scales. The medal moves above the text on narrow layouts.
      final measure = TextPainter(
        text: TextSpan(text: title, style: titleStyle),
        textDirection: Directionality.of(context),
        textScaler: scaler,
      )..layout();
      final longestWord = measure.minIntrinsicWidth.ceilToDouble();
      measure.dispose();
      final stacked = longestWord > contentWidth * .70;
      final copyWidth =
          stacked ? contentWidth : math.max(contentWidth * .55, longestWord);
      final copy = Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: titleStyle),
          SizedBox(height: large ? tokens.spacing.lg : tokens.spacing.md),
          DecoratedBox(
            decoration: BoxDecoration(
              color: theme.onPrimary,
              borderRadius: BorderRadius.circular(tokens.radius.full),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: large ? tokens.spacing.lg : tokens.spacing.md,
                vertical: large ? tokens.spacing.md : tokens.spacing.sm,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Text(
                      action,
                      style: theme.titleSmall.override(
                        color: tokens.vip.goldLight,
                        fontWeight: FontWeight.w800,
                        fontSize: large ? 17 : 13,
                      ),
                    ),
                  ),
                  SizedBox(width: tokens.spacing.xs),
                  Icon(Icons.north_east_rounded,
                      size: large ? 18 : 15, color: tokens.vip.goldLight),
                ],
              ),
            ),
          ),
        ],
      );
      final artworkWidth = stacked
          ? math.min(contentWidth * .38, 160.0)
          : contentWidth - copyWidth;
      final medal = Image.asset(
        'assets/images/home/vip_membership_3d_v2.png',
        key: const ValueKey('home-vip-medal'),
        width: artworkWidth,
        height: stacked ? artworkWidth : height - tokens.spacing.md,
        fit: BoxFit.contain,
        cacheWidth:
            (artworkWidth * MediaQuery.devicePixelRatioOf(context)).ceil(),
        excludeFromSemantics: true,
      );
      return Semantics(
        button: true,
        label: '$title. $action',
        onTap: onTap,
        excludeSemantics: true,
        child: Container(
          key: const ValueKey('home-vip-hero'),
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            gradient: tokens.home.membership,
            image: const DecorationImage(
              image: AssetImage('assets/images/home/brushed_gold.webp'),
              fit: BoxFit.cover,
              opacity: .90,
            ),
            borderRadius: radius,
            border: Border.all(color: tokens.vip.goldLight),
            boxShadow: [tokens.shadow.sm],
          ),
          child: Stack(
            children: [
              const Positioned.fill(child: _VipSparkles()),
              Material(
                type: MaterialType.transparency,
                child: InkWell(
                  key: const ValueKey('home-open-vip'),
                  borderRadius: radius,
                  onTap: onTap,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: height - 2),
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(inset, tokens.spacing.sm,
                          tokens.spacing.sm, tokens.spacing.sm),
                      child: stacked
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Align(
                                    alignment: Alignment.centerRight,
                                    child: medal),
                                Padding(
                                    padding: EdgeInsets.only(
                                        bottom: tokens.spacing.sm),
                                    child: copy),
                              ],
                            )
                          : Row(children: [
                              SizedBox(width: copyWidth, child: copy),
                              Expanded(child: medal),
                            ]),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}

class _HomeShortcuts extends StatelessWidget {
  const _HomeShortcuts(
      {required this.wide,
      required this.onVideo,
      required this.onStats,
      required this.onTchala,
      required this.onHistory});

  final bool wide;
  final VoidCallback onVideo;
  final VoidCallback onStats;
  final VoidCallback onTchala;
  final VoidCallback onHistory;

  @override
  Widget build(BuildContext context) {
    final strings = FFLocalizations.of(context);
    final theme = FlutterFlowTheme.of(context);
    final tokens = theme.designToken;
    final material = tokens.home;
    final actions = [
      (
        'video',
        'fkwji2m2',
        Icons.play_arrow_outlined,
        material.videoAccent,
        onVideo
      ),
      (
        'stats',
        'o0ut0uym',
        Icons.signal_cellular_alt_rounded,
        material.statsAccent,
        onStats
      ),
      (
        'tchala',
        '40q38tw9',
        Icons.menu_book_outlined,
        material.tchalaAccent,
        onTchala
      ),
      (
        'history',
        'viphstttl',
        Icons.history_rounded,
        material.historyAccent,
        onHistory
      ),
    ];

    return LayoutBuilder(builder: (context, constraints) {
      final scale = MediaQuery.textScalerOf(context).scale(14) / 14;
      final columns = wide || constraints.maxWidth / scale < 265 ? 2 : 4;
      final gap = wide ? tokens.spacing.sm : tokens.spacing.xs;
      final itemWidth = (constraints.maxWidth - (columns - 1) * gap) / columns;

      Widget shortcut(String id, String label, IconData icon, Color color,
          VoidCallback onTap) {
        final symbol = Icon(icon, size: wide ? 35 : 26, color: color);
        final circleSize = (itemWidth * .61).clamp(44.0, 60.0);
        final shape = BorderRadius.circular(tokens.radius.md);
        return SizedBox(
          width: itemWidth,
          child: Material(
            type: MaterialType.transparency,
            child: Ink(
              decoration: wide
                  ? BoxDecoration(
                      gradient: material.surface,
                      borderRadius: shape,
                      border: Border.all(color: material.edge))
                  : null,
              child: Semantics(
                button: true,
                child: InkWell(
                  key: ValueKey('home-shortcut-$id'),
                  onTap: onTap,
                  borderRadius: shape,
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                        vertical: wide ? tokens.spacing.md : tokens.spacing.xs,
                        horizontal: tokens.spacing.xs),
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      if (wide)
                        symbol
                      else
                        Container(
                          width: circleSize,
                          height: circleSize,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Color.alphaBlend(color.withValues(alpha: .19),
                                      material.surface.colors.first),
                                  material.surface.colors.last,
                                ]),
                            border:
                                Border.all(color: color.withValues(alpha: .27)),
                          ),
                          child: symbol,
                        ),
                      SizedBox(height: tokens.spacing.xs),
                      Text(strings.getText(label),
                          textAlign: TextAlign.center,
                          style: theme.titleSmall.override(
                              color: theme.primaryText,
                              fontSize: wide ? 16 : 12,
                              fontWeight: FontWeight.w700,
                              lineHeight: 1.12)),
                    ]),
                  ),
                ),
              ),
            ),
          ),
        );
      }

      return Wrap(spacing: gap, runSpacing: gap, children: [
        for (final (id, label, icon, color, onTap) in actions)
          shortcut(id, label, icon, color, onTap),
      ]);
    });
  }
}

/// Stars cover the VIP panel behind its text and artwork.
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
    (Offset(0.05, 0.23), 3.0, 0.0),
    (Offset(0.13, 0.82), 3.5, 0.54),
    (Offset(0.22, 0.13), 3.0, 0.38),
    (Offset(0.29, 0.66), 2.5, 0.84),
    (Offset(0.37, 0.88), 3.5, 0.18),
    (Offset(0.43, 0.27), 3.0, 0.70),
    (Offset(0.52, 0.76), 3.0, 0.44),
    (Offset(0.60, 0.12), 4.0, 0.10),
    (Offset(0.66, 0.53), 2.5, 0.62),
    (Offset(0.73, 0.86), 3.5, 0.30),
    (Offset(0.81, 0.21), 3.0, 0.92),
    (Offset(0.87, 0.68), 3.0, 0.48),
    (Offset(0.95, 0.32), 3.5, 0.76),
    (Offset(0.94, 0.85), 2.5, 0.24),
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
        paint..color = color.withValues(alpha: 0.10 + pulse * 0.48),
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_VipSparklePainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.animation != animation;
}
