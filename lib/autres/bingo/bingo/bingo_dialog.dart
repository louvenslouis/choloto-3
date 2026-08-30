import 'dart:async';

import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';

import 'bingo_comment_composer_sheet.dart';
import 'bingo_comment_service.dart';
import 'bingo_public_comments_sheet.dart';
import 'bingo_reaction_service.dart';
import 'bingo_widget.dart';

const bingoStatusAspectRatio = 9.0 / 16.0;
const bingoStatusMobileBreakpoint = 600.0;
const bingoStatusDuration = Duration(seconds: 15);
// Original 400x400 card, including its 4px Card margin and 10px side padding.
const bingoCardPresentationSize = Size(428.0, 408.0);

typedef BingoCommentSubmitter = Future<void> Function(
  String comment,
  DocumentReference? bingoReference,
);

class BingoStatusFrame extends StatelessWidget {
  const BingoStatusFrame({
    super.key,
    required this.child,
    this.onClose,
    this.publishedAt,
    this.selectedReaction,
    this.onReaction,
    this.reactionPending = false,
    this.onCommentPressed,
    this.commentPending = false,
    this.commentFeedback,
    this.commentFeedbackIsError = false,
    this.commentStatus,
    this.onViewComments,
    this.storyCount = 0,
    this.currentStoryIndex = 0,
    this.progressAnimation,
    this.onPreviousStory,
    this.onNextStory,
  });

  final Widget child;
  final VoidCallback? onClose;
  final DateTime? publishedAt;
  final BingoReaction? selectedReaction;
  final ValueChanged<BingoReaction>? onReaction;
  final bool reactionPending;
  final VoidCallback? onCommentPressed;
  final bool commentPending;
  final String? commentFeedback;
  final bool commentFeedbackIsError;
  final BingoCommentStatus? commentStatus;
  final VoidCallback? onViewComments;
  final int storyCount;
  final int currentStoryIndex;
  final Animation<double>? progressAnimation;
  final VoidCallback? onPreviousStory;
  final VoidCallback? onNextStory;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    // WebViewAware inserts a fullscreen HtmlElementView on Web. That invisible
    // layer consumes the trusted touch Safari/Chrome need to open a mobile IME.
    // The Bingo status contains no WebView, so it must use a plain Stack.
    final frame = ColoredBox(
      color: theme.primaryBackground,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Center(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: SizedBox(
                key: const ValueKey('bingo-status-content-area'),
                width: bingoCardPresentationSize.width,
                height: bingoCardPresentationSize.height,
                child: child,
              ),
            ),
          ),
          if (onPreviousStory != null || onNextStory != null)
            Positioned.fill(
              top: 80.0,
              bottom: 80.0,
              child: Row(
                children: [
                  Expanded(
                    child: Semantics(
                      label: FFLocalizations.of(context)
                          .getText('bingo_story_previous'),
                      button: true,
                      child: GestureDetector(
                        key: const ValueKey('bingo-story-previous-area'),
                        behavior: HitTestBehavior.translucent,
                        onTap: onPreviousStory,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Semantics(
                      label: FFLocalizations.of(context)
                          .getText('bingo_story_next'),
                      button: true,
                      child: GestureDetector(
                        key: const ValueKey('bingo-story-next-area'),
                        behavior: HitTestBehavior.translucent,
                        onTap: onNextStory,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          if (publishedAt != null) _BingoStoryHeader(publishedAt: publishedAt!),
          if (onClose != null) _BingoStoryCloseButton(onClose: onClose!),
          if (onReaction != null ||
              onCommentPressed != null ||
              onViewComments != null)
            _BingoStoryEngagementBar(
              selectedReaction: selectedReaction,
              reactionEnabled: !reactionPending,
              onReaction: onReaction,
              commentEnabled: !commentPending,
              onCommentPressed: onCommentPressed,
              commentFeedback: commentFeedback,
              commentFeedbackIsError: commentFeedbackIsError,
              commentStatus: commentStatus,
              onViewComments: onViewComments,
            ),
          if (storyCount > 0 && progressAnimation != null)
            _BingoStoryProgress(
              storyCount: storyCount,
              currentStoryIndex: currentStoryIndex,
              progressAnimation: progressAnimation!,
            ),
        ],
      ),
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final fillsMobileViewport =
            constraints.maxWidth <= bingoStatusMobileBreakpoint &&
                constraints.maxHeight >= constraints.maxWidth;

        if (fillsMobileViewport) {
          return SizedBox.expand(
            key: const ValueKey('bingo-status-frame'),
            child: frame,
          );
        }

        return Center(
          child: AspectRatio(
            key: const ValueKey('bingo-status-frame'),
            aspectRatio: bingoStatusAspectRatio,
            child: frame,
          ),
        );
      },
    );
  }
}

class _BingoStoryProgress extends StatelessWidget {
  const _BingoStoryProgress({
    required this.storyCount,
    required this.currentStoryIndex,
    required this.progressAnimation,
  });

  final int storyCount;
  final int currentStoryIndex;
  final Animation<double> progressAnimation;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final spacing = theme.designToken.spacing;

    return SafeArea(
      child: Align(
        alignment: AlignmentDirectional.topCenter,
        child: Padding(
          padding: EdgeInsetsDirectional.fromSTEB(
            spacing.sm,
            spacing.xs,
            spacing.sm,
            0.0,
          ),
          child: AnimatedBuilder(
            animation: progressAnimation,
            builder: (context, _) => Row(
              key: const ValueKey('bingo-story-progress'),
              children: List.generate(storyCount, (index) {
                final progress = index < currentStoryIndex
                    ? 1.0
                    : index == currentStoryIndex
                        ? progressAnimation.value
                        : 0.0;

                return Expanded(
                  child: Padding(
                    padding: EdgeInsetsDirectional.only(
                      end: index == storyCount - 1 ? 0.0 : spacing.xs,
                    ),
                    child: ClipRRect(
                      borderRadius:
                          BorderRadius.circular(theme.designToken.radius.full),
                      child: Container(
                        key: ValueKey('bingo-story-progress-track-$index'),
                        height: 3.0,
                        color: theme.secondaryText.withValues(alpha: 0.35),
                        alignment: AlignmentDirectional.centerStart,
                        child: FractionallySizedBox(
                          key: ValueKey('bingo-story-progress-fill-$index'),
                          widthFactor: progress,
                          heightFactor: 1.0,
                          child: ColoredBox(color: theme.primary),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

class _BingoStoryCloseButton extends StatelessWidget {
  const _BingoStoryCloseButton({required this.onClose});

  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final localizations = FFLocalizations.of(context);

    return SafeArea(
      child: Align(
        alignment: AlignmentDirectional.topEnd,
        child: Padding(
          padding: EdgeInsets.all(theme.designToken.spacing.md),
          child: Tooltip(
            message: localizations.getVariableText(
              frText: 'Fermer',
              enText: 'Close',
              crText: 'Fèmen',
            ),
            child: FlutterFlowIconButton(
              key: const ValueKey('bingo-story-close-button'),
              borderRadius: theme.designToken.radius.sm,
              buttonSize: 40.0,
              icon: Icon(
                Icons.close_outlined,
                color: theme.primaryText,
                size: 24.0,
              ),
              onPressed: onClose,
            ),
          ),
        ),
      ),
    );
  }
}

class _BingoStoryHeader extends StatelessWidget {
  const _BingoStoryHeader({required this.publishedAt});

  final DateTime publishedAt;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final tokens = theme.designToken;
    final localizations = FFLocalizations.of(context);

    return SafeArea(
      child: Align(
        alignment: AlignmentDirectional.topStart,
        child: Padding(
          padding: EdgeInsets.all(tokens.spacing.md),
          child: Row(
            key: const ValueKey('bingo-story-header'),
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 44.0,
                height: 44.0,
                padding: EdgeInsets.all(tokens.spacing.xs),
                decoration: BoxDecoration(
                  color: theme.primary,
                  shape: BoxShape.circle,
                ),
                child: ClipOval(
                  child: Image.asset(
                    'assets/images/bg_bingo_-_Moyenne.jpeg',
                    fit: BoxFit.cover,
                    excludeFromSemantics: true,
                  ),
                ),
              ),
              SizedBox(width: tokens.spacing.sm),
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    localizations.getText('bingo_story_label'),
                    key: const ValueKey('bingo-story-header-title'),
                    style: theme.titleMedium.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    dateTimeFormat(
                      'relative',
                      publishedAt,
                      locale: localizations.languageCode,
                    ),
                    key: const ValueKey('bingo-story-published-age'),
                    style: theme.labelMedium.copyWith(
                      color: theme.secondaryText,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BingoStoryEngagementBar extends StatelessWidget {
  const _BingoStoryEngagementBar({
    required this.selectedReaction,
    required this.reactionEnabled,
    required this.onReaction,
    required this.commentEnabled,
    required this.onCommentPressed,
    required this.commentFeedback,
    required this.commentFeedbackIsError,
    required this.commentStatus,
    required this.onViewComments,
  });

  final BingoReaction? selectedReaction;
  final bool reactionEnabled;
  final ValueChanged<BingoReaction>? onReaction;
  final bool commentEnabled;
  final VoidCallback? onCommentPressed;
  final String? commentFeedback;
  final bool commentFeedbackIsError;
  final BingoCommentStatus? commentStatus;
  final VoidCallback? onViewComments;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final tokens = theme.designToken;
    final localizations = FFLocalizations.of(context);
    final feedbackColor = commentFeedbackIsError ? theme.error : theme.success;
    final engagementButtonColor =
        theme.secondaryBackground.withValues(alpha: 0.48);
    final engagementButtonHoverColor =
        theme.secondaryBackground.withValues(alpha: 0.72);
    final selectedReactionColor = theme.primary.withValues(alpha: 0.16);

    Widget reactionButton({
      required BingoReaction reaction,
      required IconData icon,
      required String labelKey,
      required Key key,
    }) {
      final selected = selectedReaction == reaction;

      return Semantics(
        label: localizations.getText(labelKey),
        button: true,
        selected: selected,
        child: FlutterFlowIconButton(
          key: key,
          borderRadius: tokens.radius.full,
          buttonSize: 48.0,
          fillColor: selected ? selectedReactionColor : engagementButtonColor,
          disabledColor: engagementButtonColor,
          disabledIconColor: theme.secondaryText,
          hoverColor: selected
              ? theme.primary.withValues(alpha: 0.24)
              : engagementButtonHoverColor,
          hoverIconColor: theme.primaryText,
          icon: Icon(
            icon,
            color: selected ? theme.primaryText : theme.secondaryText,
            size: 20.0,
          ),
          onPressed: reactionEnabled && onReaction != null
              ? () => onReaction!(reaction)
              : null,
        ),
      );
    }

    return SafeArea(
      child: Align(
        alignment: AlignmentDirectional.bottomEnd,
        child: Padding(
          padding: EdgeInsets.all(tokens.spacing.md),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (commentStatus?.hasAdminInteraction ?? false) ...[
                _BingoAdminInteractionCard(status: commentStatus!),
                SizedBox(height: tokens.spacing.sm),
              ],
              if (commentFeedback != null) ...[
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Container(
                    key: ValueKey(
                      commentFeedbackIsError
                          ? 'bingo-story-comment-error'
                          : 'bingo-story-comment-success',
                    ),
                    constraints: const BoxConstraints(maxWidth: 320.0),
                    padding: EdgeInsetsDirectional.symmetric(
                      horizontal: tokens.spacing.md,
                      vertical: tokens.spacing.sm,
                    ),
                    decoration: BoxDecoration(
                      color: feedbackColor.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(tokens.radius.full),
                      border: Border.all(
                        color: feedbackColor.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          commentFeedbackIsError
                              ? Icons.error_outline
                              : Icons.check_circle_outline,
                          color: feedbackColor,
                          size: 18.0,
                        ),
                        SizedBox(width: tokens.spacing.sm),
                        Flexible(
                          child: Text(
                            commentFeedback!,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: theme.labelMedium.copyWith(
                              color: theme.primaryText,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: tokens.spacing.sm),
              ],
              Row(
                key: const ValueKey('bingo-story-engagement-bar'),
                children: [
                  if (onCommentPressed != null) ...[
                    Expanded(
                      child: Semantics(
                        label: localizations.getText(
                          'bingo_story_comment_hint',
                        ),
                        button: true,
                        enabled: commentEnabled,
                        child: Material(
                          color: engagementButtonColor,
                          borderRadius: BorderRadius.circular(
                            tokens.radius.full,
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: InkWell(
                            key: const ValueKey('bingo-story-comment-open'),
                            onTap: commentEnabled ? onCommentPressed : null,
                            hoverColor: engagementButtonHoverColor,
                            child: SizedBox(
                              height: 48.0,
                              child: Padding(
                                padding: EdgeInsetsDirectional.symmetric(
                                  horizontal: tokens.spacing.md,
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.edit_outlined,
                                      color: theme.secondaryText,
                                      size: 20.0,
                                    ),
                                    SizedBox(width: tokens.spacing.sm),
                                    Expanded(
                                      child: Text(
                                        localizations.getText(
                                          'bingo_story_comment_hint',
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: theme.labelMedium.copyWith(
                                          color: theme.secondaryText,
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
                    ),
                    if (onReaction != null || onViewComments != null)
                      SizedBox(width: tokens.spacing.sm),
                  ],
                  if (onReaction != null || onViewComments != null)
                    Row(
                      key: const ValueKey('bingo-story-reactions'),
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (onViewComments != null) ...[
                          Semantics(
                            label: localizations.getVariableText(
                              frText: 'Voir les commentaires',
                              crText: 'Gade kòmantè yo',
                              enText: 'View comments',
                            ),
                            button: true,
                            child: FlutterFlowIconButton(
                              key: const ValueKey(
                                'bingo-story-comments-open',
                              ),
                              borderRadius: tokens.radius.full,
                              buttonSize: 48.0,
                              fillColor: engagementButtonColor,
                              hoverColor: engagementButtonHoverColor,
                              hoverIconColor: theme.primaryText,
                              icon: Icon(
                                Icons.forum_outlined,
                                color: theme.secondaryText,
                                size: 20.0,
                              ),
                              onPressed: onViewComments,
                            ),
                          ),
                          SizedBox(width: tokens.spacing.xs),
                        ],
                        if (onReaction != null) ...[
                          reactionButton(
                            reaction: BingoReaction.positive,
                            icon: Icons.thumb_up_alt_outlined,
                            labelKey: 'bingo_story_like',
                            key: const ValueKey('bingo-story-like'),
                          ),
                          SizedBox(width: tokens.spacing.xs),
                          reactionButton(
                            reaction: BingoReaction.negative,
                            icon: Icons.thumb_down_alt_outlined,
                            labelKey: 'bingo_story_dislike',
                            key: const ValueKey('bingo-story-dislike'),
                          ),
                        ],
                      ],
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BingoAdminInteractionCard extends StatelessWidget {
  const _BingoAdminInteractionCard({required this.status});

  final BingoCommentStatus status;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final tokens = theme.designToken;
    final localizations = FFLocalizations.of(context);

    return Container(
      key: const ValueKey('bingo-story-admin-interaction'),
      constraints: const BoxConstraints(maxWidth: 360.0),
      padding: EdgeInsets.all(tokens.spacing.md),
      decoration: BoxDecoration(
        color: theme.secondaryBackground.withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(tokens.radius.md),
        border: Border.all(color: theme.primary.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 18.0,
            offset: const Offset(0.0, 6.0),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (status.adminLiked)
            Row(
              children: [
                Icon(Icons.favorite_rounded, color: theme.primary, size: 18.0),
                SizedBox(width: tokens.spacing.sm),
                Expanded(
                  child: Text(
                    localizations.getText('bingo_story_comment_liked'),
                    style: theme.labelLarge.copyWith(
                      color: theme.primaryText,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          if (status.adminLiked && status.hasAdminReply)
            SizedBox(height: tokens.spacing.sm),
          if (status.hasAdminReply) ...[
            Row(
              children: [
                Icon(Icons.verified_rounded, color: theme.primary, size: 18.0),
                SizedBox(width: tokens.spacing.sm),
                Text(
                  localizations.getText('bingo_story_comment_reply_label'),
                  style: theme.labelLarge.copyWith(
                    color: theme.primary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            SizedBox(height: tokens.spacing.xs),
            Text(
              status.adminReply,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: theme.bodyMedium.copyWith(height: 1.35),
            ),
          ],
        ],
      ),
    );
  }
}

class BingoStatusItem {
  const BingoStatusItem({
    this.reference,
    this.publishedAt,
    this.expiration,
    this.dataStack = const [],
    this.selectedReaction,
    this.reactionReference,
    this.content,
  });

  factory BingoStatusItem.fromRecord(
    BingoRecord record, {
    BingoStruct? currentBingo,
  }) {
    final isCurrentBingo = currentBingo?.doc == record.reference;
    return BingoStatusItem(
      reference: record.reference,
      publishedAt: record.date,
      expiration: record.expiration,
      dataStack: record.dataStack.toList(),
      selectedReaction:
          isCurrentBingo ? bingoReactionFromState(currentBingo!) : null,
      reactionReference: isCurrentBingo ? currentBingo!.refGain : null,
    );
  }

  factory BingoStatusItem.fromCurrentState(
    BingoStruct bingo, {
    Widget? content,
  }) =>
      BingoStatusItem(
        reference: bingo.doc,
        publishedAt: bingo.date,
        expiration: bingo.expiration,
        dataStack: bingo.dataStack.toList(),
        selectedReaction: bingoReactionFromState(bingo),
        reactionReference: bingo.refGain,
        content: content,
      );

  final DocumentReference? reference;
  final DateTime? publishedAt;
  final DateTime? expiration;
  final List<DataStackStruct> dataStack;
  final BingoReaction? selectedReaction;
  final DocumentReference? reactionReference;
  final Widget? content;

  BingoStruct toBingoStruct({
    required BingoReaction? reaction,
    required DocumentReference? reactionReference,
  }) =>
      BingoStruct(
        date: publishedAt,
        doc: reference,
        gagner: switch (reaction) {
          BingoReaction.positive => true,
          BingoReaction.negative => false,
          null => null,
        },
        refGain: reactionReference,
        dataStack: dataStack.toList(),
        expiration: expiration,
      );
}

class _BingoStatusDialogBody extends StatefulWidget {
  const _BingoStatusDialogBody({
    required this.stories,
    required this.storyDuration,
    this.commentSubmitter,
  });

  final List<BingoStatusItem> stories;
  final Duration storyDuration;
  final BingoCommentSubmitter? commentSubmitter;

  @override
  State<_BingoStatusDialogBody> createState() => _BingoStatusDialogBodyState();
}

class _BingoStatusDialogBodyState extends State<_BingoStatusDialogBody>
    with SingleTickerProviderStateMixin {
  late final AnimationController _progressController;
  late final List<BingoReaction?> _selectedReactions;
  late final List<DocumentReference?> _reactionReferences;
  late final List<BingoCommentStatus?> _commentStatuses;
  final _commentController = TextEditingController();
  var _currentIndex = 0;
  var _reactionPending = false;
  var _commentPending = false;
  var _commentSheetOpen = false;
  String? _commentFeedback;
  var _commentFeedbackIsError = false;
  Timer? _commentFeedbackTimer;

  @override
  void initState() {
    super.initState();
    _selectedReactions = widget.stories
        .map((story) => story.selectedReaction)
        .toList(growable: false);
    _reactionReferences = widget.stories
        .map((story) => story.reactionReference)
        .toList(growable: false);
    _commentStatuses = List<BingoCommentStatus?>.filled(
      widget.stories.length,
      null,
      growable: false,
    );
    _progressController = AnimationController(
      vsync: this,
      duration: widget.storyDuration,
    )..addStatusListener(_onProgressStatusChanged);
    _progressController.forward();
    unawaited(_loadCommentStatus(0));
  }

  @override
  void dispose() {
    _commentFeedbackTimer?.cancel();
    _progressController
      ..removeStatusListener(_onProgressStatusChanged)
      ..dispose();
    _commentController.dispose();
    super.dispose();
  }

  void _onProgressStatusChanged(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      _showNextStory();
    }
  }

  void _restartProgress() {
    _progressController.forward(from: 0.0);
  }

  void _selectStory(int index) {
    FocusScope.of(context).unfocus();
    _commentFeedbackTimer?.cancel();
    _commentController.clear();
    setState(() {
      _currentIndex = index;
      _commentFeedback = null;
    });
    _restartProgress();
    unawaited(_loadCommentStatus(index));
  }

  Future<void> _loadCommentStatus(int index) async {
    try {
      final status = await loadBingoCommentStatus(
        bingoReference: widget.stories[index].reference,
      );
      if (!mounted) return;
      setState(() => _commentStatuses[index] = status);
    } catch (_) {
      // A missing acknowledgement must never prevent the Bingo story opening.
    }
  }

  void _showCommentFeedback(String message, {required bool isError}) {
    _commentFeedbackTimer?.cancel();
    setState(() {
      _commentFeedback = message;
      _commentFeedbackIsError = isError;
    });
    _commentFeedbackTimer = Timer(const Duration(seconds: 4), () {
      if (mounted) {
        setState(() => _commentFeedback = null);
      }
    });
  }

  void _showPreviousStory() {
    if (_currentIndex == 0) {
      _restartProgress();
      return;
    }
    _selectStory(_currentIndex - 1);
  }

  void _showNextStory() {
    if (!mounted) {
      return;
    }
    if (_currentIndex >= widget.stories.length - 1) {
      Navigator.of(context).pop();
      return;
    }
    _selectStory(_currentIndex + 1);
  }

  void _close() {
    _progressController.stop();
    Navigator.of(context).pop();
  }

  Future<void> _showPublicComments() async {
    _progressController.stop();
    await showBingoPublicCommentsSheet(
      context: context,
      bingoReference: widget.stories[_currentIndex].reference,
    );
    if (mounted && !_commentSheetOpen && !_commentPending) {
      _progressController.forward();
    }
  }

  Future<void> _showCommentComposer() async {
    if (_commentSheetOpen || _commentPending) return;

    _progressController.stop();
    setState(() => _commentSheetOpen = true);
    try {
      await showBingoCommentComposerSheet(
        context: context,
        controller: _commentController,
        onSubmitted: _submitComment,
      );
    } finally {
      if (mounted) {
        setState(() => _commentSheetOpen = false);
        if (!_commentPending) _progressController.forward();
      }
    }
  }

  Future<void> _react(BingoReaction reaction) async {
    if (_reactionPending) {
      return;
    }

    final storyIndex = _currentIndex;
    final story = widget.stories[storyIndex];
    setState(() => _reactionPending = true);
    try {
      final update = await toggleBingoReaction(
        bingo: story.toBingoStruct(
          reaction: _selectedReactions[storyIndex],
          reactionReference: _reactionReferences[storyIndex],
        ),
        requestedReaction: reaction,
        updateCurrentState: story.reference == FFAppState().bingo.doc,
      );
      if (mounted) {
        setState(() {
          _selectedReactions[storyIndex] = update.reaction;
          _reactionReferences[storyIndex] = update.reference;
        });
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              FFLocalizations.of(context).getText('bingo_story_reaction_error'),
            ),
            backgroundColor: FlutterFlowTheme.of(context).error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _reactionPending = false);
      }
    }
  }

  Future<bool> _submitComment(String comment) async {
    if (_commentPending) {
      return false;
    }

    final storyIndex = _currentIndex;
    final bingoReference = widget.stories[storyIndex].reference;
    _commentFeedbackTimer?.cancel();
    _progressController.stop();
    setState(() {
      _commentPending = true;
      _commentFeedback = null;
    });
    var succeeded = false;
    try {
      if (widget.commentSubmitter != null) {
        await widget.commentSubmitter!(comment, bingoReference);
      } else {
        await saveBingoComment(
          comment,
          bingoReference: bingoReference,
        );
      }
      if (mounted && storyIndex == _currentIndex) {
        succeeded = true;
        _commentController.clear();
        FocusScope.of(context).unfocus();
        unawaited(_loadCommentStatus(storyIndex));
        _showCommentFeedback(
          FFLocalizations.of(context).getText('bingo_story_comment_success'),
          isError: false,
        );
      }
    } catch (_) {
      if (mounted && storyIndex == _currentIndex) {
        _showCommentFeedback(
          FFLocalizations.of(context).getText('bingo_story_comment_error'),
          isError: true,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _commentPending = false);
      }
    }
    return succeeded;
  }

  @override
  Widget build(BuildContext context) {
    final story = widget.stories[_currentIndex];
    return BingoStatusFrame(
      onClose: _close,
      publishedAt: story.publishedAt,
      selectedReaction: _selectedReactions[_currentIndex],
      reactionPending: _reactionPending,
      onReaction: _react,
      commentPending: _commentPending,
      onCommentPressed: _showCommentComposer,
      commentFeedback: _commentFeedback,
      commentFeedbackIsError: _commentFeedbackIsError,
      commentStatus: _commentStatuses[_currentIndex],
      onViewComments: _showPublicComments,
      storyCount: widget.stories.length,
      currentStoryIndex: _currentIndex,
      progressAnimation: _progressController,
      onPreviousStory: _showPreviousStory,
      onNextStory: _showNextStory,
      child: story.content ??
          BingoWidget(
            key: ValueKey('bingo-story-content-$_currentIndex'),
            dataStack: story.dataStack,
          ),
    );
  }
}

Future<T?> showBingoDialog<T>({
  required BuildContext context,
  Widget? content,
  List<BingoRecord>? bingos,
  List<BingoStatusItem>? stories,
  Duration storyDuration = bingoStatusDuration,
  BingoCommentSubmitter? commentSubmitter,
}) {
  final currentBingo = FFAppState().bingo;
  final statusItems = content != null
      ? [BingoStatusItem.fromCurrentState(currentBingo, content: content)]
      : stories ??
          bingos
              ?.map(
                (record) => BingoStatusItem.fromRecord(
                  record,
                  currentBingo: currentBingo,
                ),
              )
              .toList(growable: false) ??
          [BingoStatusItem.fromCurrentState(currentBingo)];

  if (statusItems.isEmpty) {
    return Future<T?>.value();
  }

  return showDialog<T>(
    context: context,
    useSafeArea: false,
    builder: (dialogContext) {
      final theme = FlutterFlowTheme.of(dialogContext);

      return Dialog.fullscreen(
        key: const ValueKey('bingo-status-dialog'),
        backgroundColor: theme.primaryBackground,
        child: _BingoStatusDialogBody(
          stories: statusItems,
          storyDuration: storyDuration,
          commentSubmitter: commentSubmitter,
        ),
      );
    },
  );
}
