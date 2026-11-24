import 'package:flutter/material.dart';

import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart' show AccomplissementsWidget, ParametresWidget;
import '/support/support_text.dart';

class HomeHeaderBrand extends StatelessWidget {
  const HomeHeaderBrand({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final tokens = theme.designToken;
    final wide = MediaQuery.sizeOf(context).width >= kBreakpointLarge;
    final logoSize = wide ? tokens.spacing.lg * 2 : tokens.spacing.xl;
    final titleStyle = wide ? theme.headlineLarge : theme.headlineSmall;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(tokens.radius.sm),
          child: Image.asset(
            'assets/images/Logo_Choloto_509.png',
            key: const ValueKey('home-header-logo'),
            width: logoSize,
            height: logoSize,
            cacheWidth:
                (logoSize * MediaQuery.devicePixelRatioOf(context)).ceil(),
            fit: BoxFit.contain,
            excludeFromSemantics: true,
          ),
        ),
        SizedBox(width: tokens.spacing.sm),
        Flexible(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              FFLocalizations.of(context).getText('loh576na'),
              maxLines: 1,
              style: titleStyle.override(
                color: theme.primary,
                fontWeight: FontWeight.w900,
                fontStyle: FontStyle.italic,
                letterSpacing: -0.8,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class HomeHeaderActions extends StatelessWidget {
  const HomeHeaderActions({
    super.key,
    required this.onAchievements,
    required this.onSettings,
  });

  final Future<void> Function() onAchievements;
  final Future<void> Function() onSettings;

  factory HomeHeaderActions.navigation(BuildContext context) {
    return HomeHeaderActions(
      onAchievements: () async {
        logFirebaseEvent('HOME_PAGE_query_stats_ICN_ON_TAP');
        logFirebaseEvent('IconButton_navigate_to');
        await context.pushNamed(AccomplissementsWidget.routeName);
      },
      onSettings: () async {
        logFirebaseEvent('HOME_PAGE_settings_outlined_ICN_ON_TAP');
        logFirebaseEvent('IconButton_navigate_to');
        await context.pushNamed(ParametresWidget.routeName);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final tokens = theme.designToken;
    final strings = FFLocalizations.of(context);

    Widget action(String key, String label, IconData icon,
        Future<void> Function() onPressed) {
      return Tooltip(
        message: label,
        child: FlutterFlowIconButton(
          key: ValueKey(key),
          buttonSize: kMinInteractiveDimension,
          borderRadius: tokens.radius.md,
          hoverColor: tokens.home.edge.withValues(alpha: .24),
          focusBorderRadius: BorderRadius.circular(tokens.radius.md),
          hoverIconColor: tokens.home.statsAccent,
          focusBorderSide: BorderSide(color: tokens.home.statsAccent, width: 2),
          icon: Icon(icon, color: theme.primaryText, size: 21),
          onPressed: onPressed,
        ),
      );
    }

    return Center(
      widthFactor: 1,
      child: DecoratedBox(
        key: const ValueKey('home-header-actions'),
        decoration: BoxDecoration(
          color: tokens.home.surface.colors.last,
          border: Border.all(color: tokens.home.edge.withValues(alpha: .70)),
          borderRadius: BorderRadius.circular(tokens.radius.md),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            action('home-achievements-button', strings.getText('exm1ba5v'),
                Icons.signal_cellular_alt_rounded, onAchievements),
            SizedBox(
              width: 1,
              height: tokens.spacing.md,
              child: ColoredBox(color: tokens.home.edge),
            ),
            action('home-settings-button', strings.getText('oadu0jrq'),
                Icons.tune_rounded, onSettings),
          ],
        ),
      ),
    );
  }
}

class HomeSupportFab extends StatefulWidget {
  const HomeSupportFab({
    super.key,
    required this.onSupport,
    this.messageCount = 0,
    this.shakeTrigger = 0,
  });

  final Future<void> Function() onSupport;
  final int messageCount;
  final int shakeTrigger;

  @override
  State<HomeSupportFab> createState() => _HomeSupportFabState();
}

class _HomeSupportFabState extends State<HomeSupportFab>
    with SingleTickerProviderStateMixin {
  late final AnimationController _shakeController;
  late final Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 620),
    );
    _shakeAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: -0.12), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -0.12, end: 0.12), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 0.12, end: -0.08), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -0.08, end: 0.06), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 0.06, end: 0.0), weight: 1),
    ]).animate(_shakeController);
    if (widget.shakeTrigger > 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _playShake());
    }
  }

  @override
  void didUpdateWidget(covariant HomeSupportFab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.shakeTrigger != oldWidget.shakeTrigger &&
        widget.shakeTrigger > 0) {
      _playShake();
    }
  }

  void _playShake() {
    if (!mounted ||
        widget.shakeTrigger == 0 ||
        !TickerMode.valuesOf(context).enabled ||
        MediaQuery.disableAnimationsOf(context)) {
      return;
    }
    _shakeController.forward(from: 0.0);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!TickerMode.valuesOf(context).enabled ||
        MediaQuery.disableAnimationsOf(context)) {
      _shakeController.value = 0;
    }
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final tokens = theme.designToken;
    final title = supportText(context, 'title');
    final unread = widget.messageCount;
    return SizedBox.square(
      key: const ValueKey('home-support-button'),
      dimension: kMinInteractiveDimension,
      child: Stack(
        fit: StackFit.expand,
        clipBehavior: Clip.none,
        children: [
          FloatingActionButton(
            heroTag: 'home-support',
            tooltip: unread > 0
                ? '$title. ${supportMessageCountText(context, unread)}'
                : title,
            backgroundColor: tokens.home.surface.colors.first,
            foregroundColor: theme.primaryText,
            elevation: 2,
            shape: CircleBorder(side: BorderSide(color: tokens.home.edge)),
            onPressed: widget.onSupport,
            child: AnimatedBuilder(
              animation: _shakeAnimation,
              builder: (context, child) => Transform.rotate(
                angle: _shakeAnimation.value,
                child: child,
              ),
              child: const Icon(Icons.support_agent_rounded, size: 21),
            ),
          ),
          if (unread > 0)
            PositionedDirectional(
              top: -tokens.spacing.xs,
              end: -tokens.spacing.xs,
              child: IgnorePointer(
                child: ExcludeSemantics(
                  child: Container(
                    key: const ValueKey('home-support-message-count'),
                    constraints: const BoxConstraints(
                      minWidth: 22,
                      minHeight: 22,
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: theme.error,
                      borderRadius:
                          BorderRadius.circular(theme.designToken.radius.full),
                      border: Border.all(
                        color: theme.primaryBackground,
                        width: 2,
                      ),
                      boxShadow: [theme.designToken.shadow.sm],
                    ),
                    child: Text(
                      unread > 99 ? '99+' : '$unread',
                      style: theme.labelSmall.copyWith(
                        color: theme.onPrimary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
