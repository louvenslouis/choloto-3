import 'package:flutter/material.dart';

import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/support/support_text.dart';

class HomeHeaderActions extends StatelessWidget {
  const HomeHeaderActions({
    super.key,
    required this.onAchievements,
    required this.onSettings,
  });

  final Future<void> Function() onAchievements;
  final Future<void> Function() onSettings;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final spacing = theme.designToken.spacing;

    return Row(
      key: const ValueKey('home-header-actions'),
      mainAxisSize: MainAxisSize.min,
      children: [
        FlutterFlowIconButton(
          key: const ValueKey('home-achievements-button'),
          buttonSize: 40.0,
          hoverIconColor: theme.primary,
          icon: Icon(
            Icons.query_stats_rounded,
            color: theme.primaryText,
            size: 22.0,
          ),
          onPressed: onAchievements,
        ),
        SizedBox(width: spacing.xs),
        FlutterFlowIconButton(
          key: const ValueKey('home-settings-button'),
          buttonSize: 40.0,
          hoverIconColor: theme.primary,
          icon: Icon(
            Icons.settings_outlined,
            color: theme.primaryText,
            size: 22.0,
          ),
          onPressed: onSettings,
        ),
      ],
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
    if (!mounted || widget.shakeTrigger == 0) return;
    _shakeController.forward(from: 0.0);
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return FloatingActionButton(
      key: const ValueKey('home-support-button'),
      heroTag: 'home-support',
      tooltip: supportText(context, 'title'),
      backgroundColor: theme.primary,
      foregroundColor: theme.onPrimary,
      elevation: 0,
      shape: const CircleBorder(),
      onPressed: widget.onSupport,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          AnimatedBuilder(
            animation: _shakeAnimation,
            builder: (context, child) => Transform.rotate(
              angle: _shakeAnimation.value,
              child: child,
            ),
            child: const Icon(Icons.support_agent_rounded),
          ),
          if (widget.messageCount > 0)
            PositionedDirectional(
              top: -10,
              end: -10,
              child: Semantics(
                label: supportMessageCountText(context, widget.messageCount),
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
                    widget.messageCount > 99 ? '99+' : '${widget.messageCount}',
                    style: theme.labelSmall.copyWith(
                      color: theme.primaryText,
                      fontWeight: FontWeight.w800,
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
