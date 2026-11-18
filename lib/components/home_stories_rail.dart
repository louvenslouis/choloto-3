import 'package:flutter/material.dart';

import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/internationalization.dart';
import 'home_story_bubble.dart';

class HomeStoriesRail extends StatelessWidget {
  const HomeStoriesRail({
    super.key,
    required this.stories,
    required this.loading,
    required this.loadFailed,
    required this.onRetry,
  });

  final List<Widget> stories;
  final bool loading;
  final bool loadFailed;
  final VoidCallback onRetry;

  bool get isVisible => stories.isNotEmpty || loading || loadFailed;

  @override
  Widget build(BuildContext context) {
    if (!isVisible) return const SizedBox.shrink();
    final theme = FlutterFlowTheme.of(context);
    final tokens = theme.designToken;
    final strings = FFLocalizations.of(context);

    return SizedBox(
      key: const ValueKey('home-stories-rail'),
      width: double.infinity,
      height: HomeStoryBubble.diameter + tokens.spacing.xs * 2,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.zero,
        children: [
          ...stories,
          if (loading)
            HomeStoryBubble(
              key: const ValueKey('home-stories-loading'),
              id: 'story-loading',
              semanticLabel: strings.getText('ytloading'),
              child: Icon(Icons.hourglass_empty_rounded,
                  color: tokens.home.mutedText, size: tokens.spacing.lg),
            ),
          if (loadFailed)
            HomeStoryBubble(
              key: const ValueKey('home-stories-error'),
              id: 'story-retry',
              semanticLabel: strings.getText('story_retry'),
              onTap: onRetry,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.refresh_rounded,
                      color: tokens.home.mutedText, size: tokens.spacing.lg),
                  Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: tokens.spacing.xs),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(strings.getText('story_retry'),
                          style: theme.labelSmall.copyWith(
                              color: theme.primaryText,
                              fontWeight: FontWeight.w700)),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
