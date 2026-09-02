import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';

bool isBingoStoryAvailable({
  required bool viewed,
  required DateTime? bingoDate,
  required DateTime? expiration,
  required DateTime now,
}) {
  return viewed &&
      isBingoActive(
        bingoDate: bingoDate,
        expiration: expiration,
        now: now,
      );
}

bool isBingoActive({
  required DateTime? bingoDate,
  required DateTime? expiration,
  required DateTime now,
}) {
  return bingoDate != null && expiration != null && !expiration.isBefore(now);
}

bool isBingoStoryCollectionAvailable({
  required bool viewed,
  required int activeStoryCount,
}) =>
    viewed && activeStoryCount > 0;

class BingoStoryButton extends StatelessWidget {
  const BingoStoryButton({
    super.key,
    required this.onTap,
    this.viewed = false,
    this.storyCount = 1,
  });

  final VoidCallback onTap;
  final bool viewed;
  final int storyCount;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final spacing = theme.designToken.spacing;

    return Semantics(
      label: FFLocalizations.of(context).getText('bingo_story_open'),
      button: true,
      excludeSemantics: true,
      child: InkWell(
        key: const ValueKey('bingo-story-button'),
        onTap: onTap,
        borderRadius: BorderRadius.circular(theme.designToken.radius.md),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: spacing.sm,
            vertical: spacing.xs,
          ),
          child: SizedBox(
            width: 80.0,
            child: Center(
              child: SizedBox(
                key: const ValueKey('bingo-story-circle'),
                width: 72.0,
                height: 72.0,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: 72.0,
                      height: 72.0,
                      padding: EdgeInsets.all(spacing.xs),
                      decoration: BoxDecoration(
                        color: viewed ? theme.alternate : theme.primary,
                        shape: BoxShape.circle,
                        boxShadow: [theme.designToken.shadow.sm],
                      ),
                      child: ClipOval(
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.asset(
                              'assets/images/bg_bingo_-_Moyenne.jpeg',
                              fit: BoxFit.cover,
                              excludeFromSemantics: true,
                            ),
                            Center(
                              child: Text(
                                FFLocalizations.of(context)
                                    .getText('bingo_story_label'),
                                key: const ValueKey('bingo-story-label'),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                                style: theme.labelMedium.copyWith(
                                  color: theme.onPrimary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (storyCount > 1)
                      PositionedDirectional(
                        top: 0.0,
                        end: 0.0,
                        child: Container(
                          key: const ValueKey('bingo-story-count'),
                          constraints: const BoxConstraints(
                            minWidth: 20.0,
                            minHeight: 20.0,
                          ),
                          padding: EdgeInsets.symmetric(
                            horizontal: spacing.xs,
                          ),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: theme.primary,
                            borderRadius: BorderRadius.circular(
                              theme.designToken.radius.full,
                            ),
                            border: Border.all(
                              color: theme.primaryBackground,
                              width: 2.0,
                            ),
                          ),
                          child: Text(
                            '$storyCount',
                            style: theme.labelSmall.copyWith(
                              color: theme.onPrimary,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
