import 'package:flutter/material.dart';

import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'home_header_actions.dart';

class HomePageScaffold extends StatelessWidget {
  const HomePageScaffold({
    super.key,
    this.scaffoldKey,
    required this.inTabShell,
    required this.support,
    required this.buildSections,
  });

  final GlobalKey<ScaffoldState>? scaffoldKey;
  final bool inTabShell;
  final HomeSupportFab support;
  final List<Widget> Function(Widget? supportBesideStories) buildSections;

  static const maxContentWidth = 1400.0;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final tokens = theme.designToken;
    final spacing = tokens.spacing;
    final showHeader =
        !inTabShell || MediaQuery.sizeOf(context).width < kBreakpointMedium;
    final sideInset = showHeader ? spacing.md : spacing.lg;
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: tokens.background.home,
        body: DecoratedBox(
          key: const ValueKey('home-background-gradient'),
          decoration: BoxDecoration(gradient: tokens.background.homeGradient),
          child: CustomPaint(
            painter: _HomeSapphireHorizon(
              color: tokens.home.heroGlow,
              compact: showHeader,
            ),
            child: SafeArea(
              top: false,
              child: CustomScrollView(
                slivers: [
                  if (showHeader)
                    SliverAppBar(
                      pinned: true,
                      toolbarHeight: 64,
                      backgroundColor: WidgetStateColor.resolveWith((states) =>
                          states.contains(WidgetState.scrolledUnder)
                              ? tokens.background.home
                              : tokens.background.home.withValues(alpha: 0)),
                      surfaceTintColor: tokens.background.home,
                      automaticallyImplyLeading: false,
                      titleSpacing: sideInset,
                      title: const HomeHeaderBrand(),
                      actions: [
                        Center(
                            child: SizedBox.square(
                                dimension: kMinInteractiveDimension,
                                child: support)),
                        SizedBox(width: spacing.xs),
                        HomeHeaderActions.navigation(context),
                        SizedBox(width: sideInset),
                      ],
                      centerTitle: false,
                      elevation: 0,
                      scrolledUnderElevation: 0,
                    ),
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(
                        sideInset,
                        showHeader ? 0 : spacing.md,
                        sideInset,
                        showHeader ? spacing.lg : spacing.xl),
                    sliver: SliverToBoxAdapter(
                      child: Center(
                          child: ConstrainedBox(
                        constraints:
                            const BoxConstraints(maxWidth: maxContentWidth),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: buildSections(showHeader ? null : support)
                              .divide(SizedBox(height: spacing.sm)),
                        ),
                      )),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The lit edge of a large sapphire disc, cropped above the story rail.
class _HomeSapphireHorizon extends CustomPainter {
  const _HomeSapphireHorizon({
    required this.color,
    required this.compact,
  });

  final Color color;
  final bool compact;

  @override
  void paint(Canvas canvas, Size size) {
    final radius = compact ? size.width.clamp(0.0, 540.0) : 680.0;
    if (radius == 0) return;
    final intensity = compact ? .68 : .23;
    final glow = RadialGradient(
      radius: .5,
      colors: [
        for (final opacity in const [0.0, .02, .18, 1.0, .27, .03, 0.0])
          color.withValues(alpha: opacity * intensity),
      ],
      stops: const [.0, .78, .88, .91, .925, .96, 1.0],
    );
    // Use a short ellipse on Web so the light sits behind the stories.
    final disc = Rect.fromCenter(
      center: Offset(compact ? -radius * .07 : size.width * .16,
          compact ? -radius * .38 : -130),
      width: radius * 2,
      height: compact ? radius * 1.56 : 540,
    );
    canvas.save();
    canvas.translate(disc.left, disc.top);
    canvas.scale(disc.width, disc.height);
    const bounds = Rect.fromLTWH(0, 0, 1, 1);
    canvas.drawRect(bounds, Paint()..shader = glow.createShader(bounds));
    canvas.restore();
  }

  @override
  bool shouldRepaint(_HomeSapphireHorizon old) =>
      old.color != color || old.compact != compact;
}
