import 'package:flutter/material.dart';

import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/internationalization.dart';
import 'vip_casino_card.dart';

/// The same engraved rim as the result chips frames each unread story.
class HomeStoryBubble extends StatelessWidget {
  const HomeStoryBubble({
    super.key,
    required this.id,
    required this.semanticLabel,
    required this.child,
    this.viewed,
    this.storyCount = 1,
    this.onTap,
  });

  static const diameter = 72.0;
  final String id;
  final String semanticLabel;

  /// Null for the loading and retry slots, which have no reading state.
  final bool? viewed;
  final int storyCount;
  final VoidCallback? onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final tokens = theme.designToken;
    final unread = viewed == false;
    final face = Container(
      margin: EdgeInsets.all(unread ? tokens.spacing.xs : 2),
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        gradient: tokens.home.surface,
        shape: BoxShape.circle,
      ),
      child: ClipOval(child: child),
    );
    final value = [
      if (viewed != null)
        FFLocalizations.of(context)
            .getText(unread ? 'home_story_unseen' : 'home_story_seen'),
      if (storyCount > 1) '$storyCount',
    ].join(', ');

    return Semantics(
      label: semanticLabel,
      value: value.isEmpty ? null : value,
      button: onTap != null,
      onTap: onTap,
      excludeSemantics: true,
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          key: ValueKey('$id-button'),
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: Padding(
            padding: EdgeInsets.all(tokens.spacing.xs),
            child: SizedBox.square(
              key: ValueKey('$id-circle'),
              dimension: diameter,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (unread)
                    VipCasinoChip(child: face)
                  else
                    DecoratedBox(
                      decoration: BoxDecoration(
                        color: tokens.home.edge,
                        shape: BoxShape.circle,
                      ),
                      child: face,
                    ),
                  if (storyCount > 1)
                    PositionedDirectional(
                      top: 0,
                      end: 0,
                      child: Container(
                        key: ValueKey('$id-count'),
                        constraints:
                            const BoxConstraints(minHeight: 20, minWidth: 20),
                        padding:
                            EdgeInsets.symmetric(horizontal: tokens.spacing.xs),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          gradient: unread
                              ? tokens.home.membership
                              : tokens.home.surface,
                          borderRadius:
                              BorderRadius.circular(tokens.radius.full),
                          border: Border.all(
                              color: tokens.background.home, width: 1.5),
                        ),
                        child: Text(
                          '$storyCount',
                          style: theme.labelSmall.copyWith(
                            color: unread ? theme.onPrimary : theme.primaryText,
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
    );
  }
}
