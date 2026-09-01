import 'dart:async';

import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/stories/story_viewer_shell.dart';
import 'package:flutter/material.dart';

import 'bingo_comment_service.dart';
import 'bingo_public_comments_sheet.dart';
import 'bingo_reaction_service.dart';
import 'bingo_widget.dart';

const bingoStatusAspectRatio = cholotoStoryAspectRatio;
const bingoStatusMobileBreakpoint = cholotoStoryMobileBreakpoint;
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
    this.commentCount,
    this.storyCount = 0,
    this.currentStoryIndex = 0,
    this.progressAnimation,
    this.onPreviousStory,
    this.onNextStory,
    this.onPause,
    this.onResume,
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
  final int? commentCount;
  final int storyCount;
  final int currentStoryIndex;
  final Animation<double>? progressAnimation;
  final VoidCallback? onPreviousStory;
  final VoidCallback? onNextStory;
  final VoidCallback? onPause;
  final VoidCallback? onResume;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final localizations = FFLocalizations.of(context);
    final navigationEnabled =
        onPreviousStory != null || onNextStory != null;

    return StoryViewerShell(
      frameKey: const ValueKey('bingo-status-frame'),
      keyPrefix: 'bingo',
      title: localizations.getText('bingo_story_label'),
      avatar: Container(
        padding: EdgeInsets.all(theme.designToken.spacing.xs),
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
      publishedAt: publishedAt,
      storyCount: storyCount,
      currentStoryIndex: currentStoryIndex,
      progressAnimation:
          progressAnimation ?? const AlwaysStoppedAnimation<double>(0.0),
      navigationEnabled: navigationEnabled,
      showHeader: publishedAt != null,
      showClose: onClose != null,
      onPreviousStory: onPreviousStory ?? () {},
      onNextStory: onNextStory ?? () {},
      onClose: onClose ?? () {},
      onPause: onPause,
      onResume: onResume,
      previousLabel: localizations.getText('bingo_story_previous'),
      nextLabel: localizations.getText('bingo_story_next'),
      closeLabel: localizations.getText('story_close'),
      child: Center(
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
      bottomOverlay: onReaction != null ||
              onCommentPressed != null ||
              onViewComments != null
          ? _BingoStoryEngagementBar(
              selectedReaction: selectedReaction,
              reactionEnabled: !reactionPending,
              onReaction: onReaction,
              commentEnabled: !commentPending,
              onCommentPressed: onCommentPressed,
              commentFeedback: commentFeedback,
              commentFeedbackIsError: commentFeedbackIsError,
              commentStatus: commentStatus,
              onViewComments: onViewComments,
              commentCount: commentCount,
            )
          : null,
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
    required this.commentCount,
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
  final int? commentCount;

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

      return AnimatedScale(
        scale: selected ? 1.06 : 1.0,
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOutCubic,
        child: Semantics(
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
        ),
      );
    }

    final commentsAction = onViewComments ?? onCommentPressed;
    final commentsLabel = commentCount != null && commentCount! > 0
        ? '${localizations.getText('bingo_story_comments')} · $commentCount'
        : localizations.getText('bingo_story_comments');

    return SafeArea(
      child: Align(
        alignment: AlignmentDirectional.bottomEnd,
        child: Container(
          padding: EdgeInsetsDirectional.fromSTEB(
            tokens.spacing.md,
            tokens.spacing.lg,
            tokens.spacing.md,
            tokens.spacing.md,
          ),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: AlignmentDirectional.topCenter,
              end: AlignmentDirectional.bottomCenter,
              colors: [
                theme.primaryBackground.withValues(alpha: 0.0),
                theme.primaryBackground.withValues(alpha: 0.92),
              ],
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (commentStatus?.hasAdminInteraction ?? false) ...[
                _BingoAdminInteractionCard(
                  status: commentStatus!,
                  onTap: commentsAction,
                ),
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
                  if (commentsAction != null) ...[
                    Expanded(
                      child: Semantics(
                        label: commentsLabel,
                        button: true,
                        enabled: commentEnabled,
                        child: SizedBox(
                          key: const ValueKey('bingo-story-comments-open'),
                          height: 48.0,
                          child: Material(
                            color: engagementButtonColor,
                            borderRadius: BorderRadius.circular(
                              tokens.radius.full,
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: InkWell(
                              key: const ValueKey('bingo-story-comment-open'),
                              onTap: commentEnabled ? commentsAction : null,
                              hoverColor: engagementButtonHoverColor,
                              child: Padding(
                                padding: EdgeInsetsDirectional.symmetric(
                                  horizontal: tokens.spacing.md,
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.forum_outlined,
                                      color: theme.secondaryText,
                                      size: 20.0,
                                    ),
                                    SizedBox(width: tokens.spacing.sm),
                                    Expanded(
                                      child: Text(
                                        commentsLabel,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: theme.labelLarge.copyWith(
                                          color: theme.primaryText,
                                          fontWeight: FontWeight.w700,
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
                    if (onReaction != null)
                      SizedBox(width: tokens.spacing.sm),
                  ],
                  if (onReaction != null)
                    Row(
                      key: const ValueKey('bingo-story-reactions'),
                      mainAxisSize: MainAxisSize.min,
                      children: [
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
  const _BingoAdminInteractionCard({
    required this.status,
    required this.onTap,
  });

  final BingoCommentStatus status;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final tokens = theme.designToken;
    final localizations = FFLocalizations.of(context);

    final labelKey = status.hasAdminReply
        ? 'bingo_story_admin_replied'
        : 'bingo_story_comment_liked';
    final icon = status.hasAdminReply
        ? Icons.verified_rounded
        : Icons.favorite_rounded;

    return Material(
      key: const ValueKey('bingo-story-admin-interaction'),
      color: theme.secondaryBackground.withValues(alpha: 0.96),
      borderRadius: BorderRadius.circular(tokens.radius.full),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        hoverColor: theme.primary.withValues(alpha: 0.10),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 360.0),
          padding: EdgeInsetsDirectional.symmetric(
            horizontal: tokens.spacing.md,
            vertical: tokens.spacing.sm,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(tokens.radius.full),
            border: Border.all(
              color: theme.primary.withValues(alpha: 0.28),
            ),
          ),
          child: Row(
            children: [
              Icon(icon, color: theme.primary, size: 18.0),
              SizedBox(width: tokens.spacing.sm),
              Expanded(
                child: Text(
                  localizations.getText(labelKey),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.labelLarge.copyWith(
                    color: theme.primaryText,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (onTap != null) ...[
                SizedBox(width: tokens.spacing.sm),
                Icon(
                  Icons.arrow_forward_rounded,
                  color: theme.primary,
                  size: 18.0,
                ),
              ],
            ],
          ),
        ),
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
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late final AnimationController _progressController;
  late final List<BingoReaction?> _selectedReactions;
  late final List<DocumentReference?> _reactionReferences;
  late final List<BingoCommentStatus?> _commentStatuses;
  late final List<int?> _commentCounts;
  final _commentController = TextEditingController();
  var _currentIndex = 0;
  var _reactionPending = false;
  var _commentPending = false;
  var _commentSheetOpen = false;
  var _lifecyclePaused = false;
  var _accessibilityPaused = false;
  String? _commentFeedback;
  var _commentFeedbackIsError = false;
  Timer? _commentFeedbackTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
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
    _commentCounts = List<int?>.filled(
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
    WidgetsBinding.instance.removeObserver(this);
    _commentFeedbackTimer?.cancel();
    _progressController
      ..removeStatusListener(_onProgressStatusChanged)
      ..dispose();
    _commentController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final mediaQuery = MediaQuery.maybeOf(context);
    final shouldPause = mediaQuery?.accessibleNavigation == true ||
        mediaQuery?.disableAnimations == true;
    if (_accessibilityPaused == shouldPause) return;
    _accessibilityPaused = shouldPause;
    if (shouldPause) {
      _pauseProgress();
    } else {
      _resumeProgress();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _lifecyclePaused = state != AppLifecycleState.resumed;
    if (_lifecyclePaused) {
      _pauseProgress();
    } else {
      _resumeProgress();
    }
  }

  void _onProgressStatusChanged(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      _showNextStory();
    }
  }

  void _restartProgress() {
    if (_lifecyclePaused || _accessibilityPaused || _commentSheetOpen) {
      _progressController.value = 0.0;
      return;
    }
    _progressController.forward(from: 0.0);
  }

  void _pauseProgress() => _progressController.stop();

  void _resumeProgress() {
    if (mounted &&
        !_lifecyclePaused &&
        !_accessibilityPaused &&
        !_commentSheetOpen &&
        !_commentPending) {
      _progressController.forward();
    }
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
      final statusFuture = loadBingoCommentStatus(
        bingoReference: widget.stories[index].reference,
      );
      final countFuture = loadBingoCommentCount(
        bingoReference: widget.stories[index].reference,
      );
      final status = await statusFuture;
      final count = await countFuture;
      if (!mounted) return;
      setState(() {
        _commentStatuses[index] = status;
        _commentCounts[index] = count;
      });
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

  Future<void> _showComments({bool autofocus = false}) async {
    if (_commentSheetOpen || _commentPending) return;

    _pauseProgress();
    setState(() => _commentSheetOpen = true);
    try {
      final storyIndex = _currentIndex;
      await showBingoPublicCommentsSheet(
        context: context,
        bingoReference: widget.stories[storyIndex].reference,
        controller: _commentController,
        onSubmitted: _submitComment,
        initialCommentId: _commentStatuses[storyIndex]?.commentId,
        autofocus: autofocus,
        canComment: currentUserUid.isNotEmpty ||
            widget.commentSubmitter != null,
      );
    } finally {
      if (mounted) {
        setState(() => _commentSheetOpen = false);
        _resumeProgress();
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
      onCommentPressed: () => _showComments(autofocus: true),
      commentFeedback: _commentFeedback,
      commentFeedbackIsError: _commentFeedbackIsError,
      commentStatus: _commentStatuses[_currentIndex],
      commentCount: _commentCounts[_currentIndex],
      onViewComments: _showComments,
      storyCount: widget.stories.length,
      currentStoryIndex: _currentIndex,
      progressAnimation: _progressController,
      onPreviousStory: _showPreviousStory,
      onNextStory: _showNextStory,
      onPause: _pauseProgress,
      onResume: _resumeProgress,
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
