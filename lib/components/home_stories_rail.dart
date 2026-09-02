import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';

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

    return Column(
      key: const ValueKey('home-stories-rail'),
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: 80.0,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              ...stories,
              if (loading)
                const _StoryBubbleSkeleton(
                  key: ValueKey('home-stories-loading'),
                ),
              if (loadFailed)
                _StoryLoadError(
                  key: const ValueKey('home-stories-error'),
                  onRetry: onRetry,
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StoryBubbleSkeleton extends StatelessWidget {
  const _StoryBubbleSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final spacing = theme.designToken.spacing;
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: spacing.sm,
        vertical: spacing.xs,
      ),
      child: Container(
        width: 72.0,
        height: 72.0,
        decoration: BoxDecoration(
          color: theme.primaryText.withValues(alpha: 0.07),
          shape: BoxShape.circle,
          border: Border.all(
            color: theme.primaryText.withValues(alpha: 0.08),
          ),
        ),
      ),
    );
  }
}

class _StoryLoadError extends StatelessWidget {
  const _StoryLoadError({super.key, required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final tokens = theme.designToken;
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: tokens.spacing.sm,
        vertical: tokens.spacing.xs,
      ),
      child: Material(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(tokens.radius.md),
        child: InkWell(
          onTap: onRetry,
          borderRadius: BorderRadius.circular(tokens.radius.md),
          child: Container(
            constraints: const BoxConstraints(minWidth: 152.0),
            padding: EdgeInsets.symmetric(horizontal: tokens.spacing.md),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(tokens.radius.md),
              border: Border.all(
                color: theme.error.withValues(alpha: 0.28),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.cloud_off_rounded, color: theme.error, size: 20.0),
                SizedBox(width: tokens.spacing.sm),
                Text(
                  FFLocalizations.of(context).getText('story_retry'),
                  style: theme.labelLarge.copyWith(
                    color: theme.primaryText,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
