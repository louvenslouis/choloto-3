import '/components/home_story_bubble.dart';
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
  required int activeStoryCount,
}) =>
    activeStoryCount > 0;

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
    final strings = FFLocalizations.of(context);
    return HomeStoryBubble(
      id: 'bingo-story',
      viewed: viewed,
      storyCount: storyCount,
      onTap: onTap,
      semanticLabel: strings.getText('bingo_story_open'),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/bg_bingo_-_Moyenne.jpeg',
            fit: BoxFit.cover,
            excludeFromSemantics: true,
          ),
          Center(
            child: Padding(
              padding: EdgeInsets.all(theme.designToken.spacing.xs),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  strings.getText('bingo_story_label'),
                  key: const ValueKey('bingo-story-label'),
                  style: theme.titleMedium.override(
                    color: theme.onPrimary,
                    fontWeight: FontWeight.w800,
                    fontStyle: FontStyle.italic,
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
