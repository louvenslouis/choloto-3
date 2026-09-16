import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'package:flutter/material.dart';

import 'bingo_reaction_service.dart';

/// Shares the existing Bingo reactions and their total across VIP and stories.
class BingoReactionButton extends StatefulWidget {
  const BingoReactionButton({
    super.key,
    this.reference,
    this.selectedReaction,
    this.enabled = true,
    required this.onReaction,
    this.onMenuOpened,
    this.onMenuClosed,
  });

  final DocumentReference? reference;
  final BingoReaction? selectedReaction;
  final bool enabled;
  final ValueChanged<BingoReaction> onReaction;
  final VoidCallback? onMenuOpened;
  final VoidCallback? onMenuClosed;

  @override
  State<BingoReactionButton> createState() => _BingoReactionButtonState();
}

class _BingoReactionButtonState extends State<BingoReactionButton> {
  Future<int>? _count;

  @override
  void initState() {
    super.initState();
    _refreshCount();
  }

  @override
  void didUpdateWidget(BingoReactionButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.reference != widget.reference ||
        oldWidget.selectedReaction != widget.selectedReaction ||
        (!oldWidget.enabled && widget.enabled)) {
      _refreshCount();
    }
  }

  void _refreshCount() {
    // The historical public subcollection contains one document per reaction.
    // Aggregate on the server instead of downloading users' reaction records.
    _count = widget.reference == null
        ? Future.value(0)
        : widget.reference!.collection('bingostats').count().get().then(
              (snapshot) => snapshot.count ?? 0,
            );
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final tokens = theme.designToken;
    final strings = FFLocalizations.of(context);
    return PopupMenuButton<BingoReaction>(
      enabled: widget.enabled,
      tooltip: strings.getText('bingo_reactions'),
      position: PopupMenuPosition.over,
      elevation: 0,
      color: theme.secondaryBackground,
      surfaceTintColor: theme.secondaryBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(tokens.radius.md),
        side: BorderSide(color: theme.alternate),
      ),
      constraints: const BoxConstraints(minWidth: 240, maxWidth: 300),
      onOpened: () {
        setState(_refreshCount);
        widget.onMenuOpened?.call();
      },
      onCanceled: widget.onMenuClosed,
      onSelected: (reaction) {
        widget.onMenuClosed?.call();
        widget.onReaction(reaction);
      },
      itemBuilder: (context) => [
        for (final reaction in BingoReaction.values)
          PopupMenuItem(
            key: ValueKey(reaction == BingoReaction.positive
                ? 'bingo-story-like'
                : 'bingo-story-dislike'),
            value: reaction,
            padding: EdgeInsets.all(tokens.spacing.md),
            child: Semantics(
              selected: widget.selectedReaction == reaction,
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(tokens.spacing.sm),
                    decoration: BoxDecoration(
                      color: widget.selectedReaction == reaction
                          ? theme.primary
                          : theme.primaryBackground,
                      borderRadius: BorderRadius.circular(tokens.radius.sm),
                    ),
                    child: Icon(
                      reaction == BingoReaction.positive
                          ? Icons.thumb_up_alt_outlined
                          : Icons.thumb_down_alt_outlined,
                      color: widget.selectedReaction == reaction
                          ? theme.onPrimary
                          : theme.primaryText,
                      size: 22,
                    ),
                  ),
                  SizedBox(width: tokens.spacing.sm),
                  Expanded(
                    child: Text(
                      strings.getText(reaction == BingoReaction.positive
                          ? 'bingo_story_like'
                          : 'bingo_story_dislike'),
                      style: theme.bodyMedium,
                    ),
                  ),
                  if (widget.selectedReaction == reaction) ...[
                    SizedBox(width: tokens.spacing.xs),
                    Icon(Icons.check_rounded,
                        color: theme.primaryText, size: 18),
                  ],
                ],
              ),
            ),
          ),
      ],
      child: IgnorePointer(
        child: FutureBuilder<int>(
          future: _count,
          builder: (context, snapshot) => FFButtonWidget(
            onPressed: widget.enabled ? () {} : null,
            text: snapshot.hasError ? '—' : snapshot.data?.toString() ?? '…',
            icon: const Icon(Icons.thumbs_up_down_outlined, size: 22),
            options: FFButtonOptions(
              height: 48,
              padding: EdgeInsets.symmetric(horizontal: tokens.spacing.md),
              iconColor: theme.primaryText,
              color: widget.selectedReaction != null
                  ? theme.primary.withValues(alpha: 0.16)
                  : theme.secondaryBackground,
              disabledColor: theme.secondaryBackground,
              disabledTextColor: theme.secondaryText,
              textStyle: theme.labelLarge.override(color: theme.primaryText),
              elevation: 0,
              borderRadius: BorderRadius.circular(tokens.radius.full),
            ),
            showLoadingIndicator: false,
          ),
        ),
      ),
    );
  }
}
