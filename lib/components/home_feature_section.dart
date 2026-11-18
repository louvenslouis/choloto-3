import 'dart:math' as math;

import 'package:flutter/material.dart';

import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'home_feature_card.dart';
import 'home_shortcuts.dart';

class HomeFeatureSection extends StatelessWidget {
  const HomeFeatureSection({
    super.key,
    this.stories,
    this.storyAction,
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
  final Widget? storyAction;
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
      final heroHeight = (heroWidth * .555).clamp(168.0, 378.0);
      final tileHeight =
          wide ? (heroHeight - gap) / 2 : (width * .33).clamp(104.0, 170.0);
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
      final shortcuts = HomeShortcuts(
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
          if (stories != null || storyAction != null) ...[
            if (storyAction == null)
              stories!
            else
              Row(children: [
                Expanded(child: stories ?? const SizedBox.shrink()),
                SizedBox(width: spacing.md),
                SizedBox.square(
                    dimension: kMinInteractiveDimension, child: storyAction),
              ]),
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

class _VipHero extends StatefulWidget {
  const _VipHero({required this.height, required this.onTap});

  final double height;
  final VoidCallback onTap;

  @override
  State<_VipHero> createState() => _VipHeroState();
}

class _VipHeroState extends State<_VipHero>
    with SingleTickerProviderStateMixin {
  late final AnimationController _light = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _light.value = 1;
    } else if (!TickerMode.valuesOf(context).enabled) {
      _light.stop();
    } else if (!_light.isCompleted && !_light.isAnimating) {
      _light.forward();
    }
  }

  @override
  void dispose() {
    _light.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final tokens = theme.designToken;
    final strings = FFLocalizations.of(context);
    final title = strings.getText('covzb0rd');
    final action = strings.getText('home_open_vip');
    final radius = BorderRadius.circular(tokens.radius.lg);
    final ivory = Color.lerp(theme.onDecorative, tokens.vip.goldLight, .34)!;
    return LayoutBuilder(builder: (context, constraints) {
      final width = constraints.maxWidth;
      final large = width >= 495;
      final compact = width < 320;
      final scaler = MediaQuery.textScalerOf(context);
      final inset = large ? tokens.spacing.xl : tokens.spacing.md;
      final sideCopyWidth = width * .505 - inset;
      final titleStyle = theme.displaySmall.override(
        fontSize: (width * .10).clamp(27.0, 68.0),
        fontWeight: FontWeight.w900,
        color: ivory,
        letterSpacing: large ? -1.6 : -.9,
        lineHeight: 1.02,
      );
      // The entire localized word "Abonnement" must fit beside the medal. Only
      // fit the base font; the user's text scaling still applies afterwards.
      final measure = TextPainter(
        text: TextSpan(text: title, style: titleStyle),
        textDirection: Directionality.of(context),
      )..layout();
      final wordWidth = measure.minIntrinsicWidth;
      measure.dispose();
      final fontSize =
          titleStyle.fontSize! * math.min(1.0, sideCopyWidth / wordWidth);
      final scaledWordWidth =
          wordWidth * scaler.scale(fontSize) / titleStyle.fontSize!;
      final stacked = width < 245 || scaledWordWidth > sideCopyWidth + 1;
      final copyWidth = stacked
          ? width - 2 * inset
          : sideCopyWidth + (compact ? tokens.spacing.sm : 0);
      final titleSpan = TextSpan(
        children: [
          for (final word in title.split(' ').indexed)
            TextSpan(
              text: '${word.$1 == 0 ? '' : ' '}${word.$2}',
              style: word.$2 == 'VIP'
                  ? titleStyle.copyWith(fontSize: fontSize * 1.85, height: .98)
                  : null,
            ),
        ],
      );
      final artHeight = stacked
          ? math.min(width * .50, 180.0)
          : math.min(widget.height * 1.105, width * .62);
      final artWidth = artHeight * 1189 / 1323;
      final artRight = -artWidth * .052;
      final artTop = -artHeight * .078;
      final copy = Padding(
        padding: EdgeInsets.fromLTRB(
          inset,
          stacked ? artHeight * .87 : tokens.spacing.md,
          width - inset - copyWidth,
          tokens.spacing.md,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text.rich(titleSpan,
                style: titleStyle.copyWith(fontSize: fontSize)),
            SizedBox(height: large ? tokens.spacing.lg : tokens.spacing.md),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color.lerp(theme.primary, tokens.vip.goldLight, .52)!,
                    theme.primary,
                  ],
                ),
                borderRadius: BorderRadius.circular(tokens.radius.full),
                boxShadow: [tokens.shadow.md],
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: large
                      ? tokens.spacing.xl
                      : compact
                          ? tokens.spacing.sm
                          : tokens.spacing.md,
                  vertical: large ? tokens.spacing.md : tokens.spacing.sm,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        action,
                        style: theme.titleSmall.override(
                          color: theme.onPrimary,
                          fontWeight: FontWeight.w800,
                          fontSize: large ? 24 : (compact ? 12 : 13),
                        ),
                      ),
                    ),
                    SizedBox(
                        width: large ? tokens.spacing.sm : tokens.spacing.xs),
                    Icon(Icons.north_east_rounded,
                        size: large ? 24 : 15, color: theme.onPrimary),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
      return Semantics(
        button: true,
        label: '$title. $action',
        onTap: widget.onTap,
        excludeSemantics: true,
        child: Stack(
          key: const ValueKey('home-vip-hero'),
          clipBehavior: Clip.none,
          children: [
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: tokens.home.vipAmethyst,
                  image: DecorationImage(
                    image: const AssetImage('assets/images/home/amethyst.webp'),
                    colorFilter: ColorFilter.mode(
                        theme.onPrimary.withValues(alpha: .24),
                        BlendMode.srcATop),
                    fit: BoxFit.cover,
                  ),
                  borderRadius: radius,
                  border: Border.all(
                      color: tokens.home.amethystGlow.withValues(alpha: .62)),
                  boxShadow: [tokens.shadow.md],
                ),
                child: ClipRRect(
                  borderRadius: radius,
                  child: CustomPaint(
                    key: const ValueKey('home-vip-light-sweep'),
                    painter: _VipLightSweep(_light, tokens.home.amethystGlow),
                  ),
                ),
              ),
            ),
            Positioned(
              right: artRight,
              top: artTop,
              width: artWidth,
              height: artHeight,
              child: IgnorePointer(
                child: AnimatedBuilder(
                  animation: _light,
                  child: HomeRaisedArtwork(
                    asset: 'assets/images/home/vip_amethyst_medal.webp',
                    imageKey: const ValueKey('home-vip-medal'),
                    width: artWidth,
                    fallback: Icons.workspace_premium_rounded,
                    foreground: tokens.vip.goldLight,
                  ),
                  builder: (context, child) {
                    final lift = Curves.easeOutCubic.transform(_light.value);
                    final tilt = Curves.easeOutBack.transform(_light.value);
                    return Transform(
                      key: const ValueKey('home-vip-medal-motion'),
                      alignment: Alignment.center,
                      transform: Matrix4.identity()
                        ..translateByDouble(
                            0, artHeight * .10 * (1 - lift), 0, 1)
                        ..rotateZ(-.035 - .13 * (1 - tilt))
                        ..scaleByDouble(
                            .93 + .07 * lift, .93 + .07 * lift, 1, 1),
                      child: child,
                    );
                  },
                ),
              ),
            ),
            Material(
              type: MaterialType.transparency,
              child: InkWell(
                key: const ValueKey('home-open-vip'),
                borderRadius: radius,
                splashColor: theme.onDecorative.withValues(alpha: .08),
                onTap: widget.onTap,
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: widget.height),
                  child: Align(
                      heightFactor: 1,
                      alignment: Alignment.centerLeft,
                      child: copy),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}

/// A single soft studio light crosses the amethyst, leaving the texture still.
class _VipLightSweep extends CustomPainter {
  _VipLightSweep(this.progress, this.tint) : super(repaint: progress);

  final Animation<double> progress;
  final Color tint;

  @override
  void paint(Canvas canvas, Size size) {
    if (progress.value <= 0 || progress.value >= 1) return;
    final center = (size.width * 1.7 * progress.value) - size.width * .35;
    final beam = Rect.fromLTWH(
        center - size.width * .18, 0, size.width * .36, size.height);
    canvas.save();
    canvas.skew(-.30, 0);
    canvas.drawRect(
      beam,
      Paint()
        ..shader = LinearGradient(
          colors: [
            tint.withValues(alpha: 0),
            tint.withValues(alpha: .23),
            tint.withValues(alpha: 0),
          ],
        ).createShader(beam),
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(_VipLightSweep oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.tint != tint;
}
