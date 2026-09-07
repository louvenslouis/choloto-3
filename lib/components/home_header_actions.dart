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

class HomeSupportFab extends StatelessWidget {
  const HomeSupportFab({super.key, required this.onSupport});

  final Future<void> Function() onSupport;

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
      onPressed: onSupport,
      child: const Icon(Icons.support_agent_rounded),
    );
  }
}
