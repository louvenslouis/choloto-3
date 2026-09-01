import '/auth/firebase_auth/auth_util.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';

import 'bingo_comment_service.dart';
import 'bingo_story_comment_input.dart';

typedef BingoPublicCommentSubmitter = Future<bool> Function(String comment);

Future<bool> showBingoCommentDeleteConfirmation(BuildContext context) async {
  final localizations = FFLocalizations.of(context);
  return await showDialog<bool>(
        context: context,
        builder: (dialogContext) {
          final theme = FlutterFlowTheme.of(dialogContext);
          return AlertDialog(
            key: const ValueKey('bingo-comment-delete-dialog'),
            backgroundColor: theme.secondaryBackground,
            title: Text(
              localizations.getText('bingo_story_comment_delete_title'),
              style: theme.titleLarge,
            ),
            content: Text(
              localizations.getText('bingo_story_comment_delete_message'),
              style: theme.bodyMedium,
            ),
            actions: [
              TextButton(
                key: const ValueKey('bingo-comment-delete-cancel'),
                onPressed: () => Navigator.pop(dialogContext, false),
                child: Text(
                  localizations.getText(
                    'bingo_story_comment_delete_cancel',
                  ),
                ),
              ),
              TextButton(
                key: const ValueKey('bingo-comment-delete-confirm'),
                style: TextButton.styleFrom(foregroundColor: theme.error),
                onPressed: () => Navigator.pop(dialogContext, true),
                child: Text(
                  localizations.getText('bingo_story_comment_delete'),
                ),
              ),
            ],
          );
        },
      ) ??
      false;
}

Future<void> showBingoPublicCommentsSheet({
  required BuildContext context,
  required DocumentReference? bingoReference,
  TextEditingController? controller,
  BingoPublicCommentSubmitter? onSubmitted,
  String? initialCommentId,
  bool autofocus = false,
  bool canComment = true,
}) async {
  if (bingoReference == null && onSubmitted == null) return;
  final theme = FlutterFlowTheme.of(context);
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    requestFocus: true,
    backgroundColor: theme.primaryBackground.withValues(alpha: 0.0),
    barrierColor: theme.primaryBackground.withValues(alpha: 0.72),
    builder: (sheetContext) => AnimatedPadding(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      padding: EdgeInsets.only(
        bottom: MediaQuery.viewInsetsOf(sheetContext).bottom,
      ),
      child: FractionallySizedBox(
        heightFactor: 0.82,
        child: _BingoPublicCommentsSheet(
          bingoReference: bingoReference,
          controller: controller,
          onSubmitted: onSubmitted,
          initialCommentId: initialCommentId,
          autofocus: autofocus,
          canComment: canComment,
        ),
      ),
    ),
  );
}

class _BingoPublicCommentsSheet extends StatefulWidget {
  const _BingoPublicCommentsSheet({
    required this.bingoReference,
    required this.controller,
    required this.onSubmitted,
    required this.initialCommentId,
    required this.autofocus,
    required this.canComment,
  });

  final DocumentReference? bingoReference;
  final TextEditingController? controller;
  final BingoPublicCommentSubmitter? onSubmitted;
  final String? initialCommentId;
  final bool autofocus;
  final bool canComment;

  @override
  State<_BingoPublicCommentsSheet> createState() =>
      _BingoPublicCommentsSheetState();
}

class _BingoPublicCommentsSheetState extends State<_BingoPublicCommentsSheet> {
  final List<BingoPublicComment> _comments = [];
  final Set<String> _pendingLikes = {};
  final Set<String> _pendingDeletes = {};
  final GlobalKey _highlightedCommentKey = GlobalKey();
  var _loading = true;
  var _loadFailed = false;
  var _commentPending = false;
  var _commentFailed = false;
  var _commentSent = false;
  String? _optimisticComment;

  @override
  void initState() {
    super.initState();
    widget.controller?.addListener(_onDraftChanged);
    _reload();
  }

  @override
  void dispose() {
    widget.controller?.removeListener(_onDraftChanged);
    super.dispose();
  }

  void _onDraftChanged() {
    if (mounted) {
      setState(() {
        _commentFailed = false;
        _commentSent = false;
      });
    }
  }

  Future<void> _reload({bool showLoading = true}) async {
    if (showLoading && mounted) {
      setState(() {
        _loading = true;
        _loadFailed = false;
      });
    }
    try {
      final comments = await loadPublicBingoComments(
        bingoReference: widget.bingoReference,
      );
      if (!mounted) return;
      setState(() {
        _comments
          ..clear()
          ..addAll(comments);
        _loading = false;
        _loadFailed = false;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final highlightedContext = _highlightedCommentKey.currentContext;
        if (mounted && highlightedContext != null) {
          Scrollable.ensureVisible(
            highlightedContext,
            duration: const Duration(milliseconds: 260),
            alignment: 0.16,
          );
        }
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _loadFailed = true;
      });
    }
  }

  Future<void> _submitComment() async {
    final controller = widget.controller;
    final submitter = widget.onSubmitted;
    final draft = controller?.text.trim() ?? '';
    if (_commentPending || submitter == null || draft.isEmpty) return;

    setState(() {
      _commentPending = true;
      _commentFailed = false;
      _commentSent = false;
      _optimisticComment = draft;
    });
    final succeeded = await submitter(draft);
    if (!mounted) return;
    if (!succeeded) {
      setState(() {
        _commentPending = false;
        _commentFailed = true;
      });
      return;
    }

    await _reload(showLoading: false);
    if (!mounted) return;
    setState(() {
      _commentPending = false;
      _commentFailed = false;
      _commentSent = true;
      _optimisticComment = null;
    });
  }

  Future<void> _toggleLike(BingoPublicComment comment) async {
    if (_pendingLikes.contains(comment.id) ||
        _pendingDeletes.contains(comment.id)) {
      return;
    }
    setState(() => _pendingLikes.add(comment.id));
    try {
      await togglePublicBingoCommentLike(
        bingoReference: widget.bingoReference,
        commentId: comment.id,
      );
      if (mounted) await _reload(showLoading: false);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text(
                FFLocalizations.of(context).getVariableText(
                  frText: 'Connectez-vous pour aimer ce commentaire.',
                  crText: 'Konekte pou renmen kòmantè sa a.',
                  enText: 'Sign in to like this comment.',
                ),
              ),
            ),
          );
      }
    } finally {
      if (mounted) setState(() => _pendingLikes.remove(comment.id));
    }
  }

  Future<void> _deleteComment(BingoPublicComment comment) async {
    if (!comment.isOwnedBy(currentUserUid) ||
        _pendingDeletes.contains(comment.id)) {
      return;
    }

    final localizations = FFLocalizations.of(context);
    final confirmed = await showBingoCommentDeleteConfirmation(context);
    if (!confirmed || !mounted) return;

    setState(() => _pendingDeletes.add(comment.id));
    try {
      await deleteBingoComment(
        bingoReference: widget.bingoReference,
        commentId: comment.id,
      );
      if (mounted) {
        await _reload(showLoading: false);
        if (!mounted) return;
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text(
                localizations.getText(
                  'bingo_story_comment_delete_success',
                ),
              ),
              backgroundColor: FlutterFlowTheme.of(context).success,
            ),
          );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text(
                localizations.getText(
                  'bingo_story_comment_delete_error',
                ),
              ),
              backgroundColor: FlutterFlowTheme.of(context).error,
            ),
          );
      }
    } finally {
      if (mounted) setState(() => _pendingDeletes.remove(comment.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final tokens = theme.designToken;
    final localizations = FFLocalizations.of(context);
    final controller = widget.controller;
    final draftLength = controller?.text.characters.length ?? 0;
    final canSubmit = widget.canComment &&
        widget.onSubmitted != null &&
        !_commentPending &&
        (controller?.text.trim().isNotEmpty ?? false);

    return Material(
      key: const ValueKey('bingo-comment-sheet'),
      color: theme.secondaryBackground,
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(tokens.radius.lg),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          SizedBox(height: tokens.spacing.sm),
          Container(
            width: 42.0,
            height: tokens.spacing.xs,
            decoration: BoxDecoration(
              color: theme.alternate,
              borderRadius: BorderRadius.circular(tokens.radius.full),
            ),
          ),
          Padding(
            padding: EdgeInsetsDirectional.fromSTEB(
              tokens.spacing.md,
              tokens.spacing.sm,
              tokens.spacing.sm,
              tokens.spacing.sm,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _comments.isEmpty
                            ? localizations.getText('bingo_comments_title')
                            : '${localizations.getText('bingo_comments_title')} · ${_comments.length}',
                        style: theme.titleLarge.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      SizedBox(height: tokens.spacing.xs),
                      Text(
                        localizations.getText('bingo_comments_anonymous'),
                        style: theme.bodySmall.copyWith(
                          color: theme.secondaryText,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  key: const ValueKey('bingo-comment-sheet-close'),
                  tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ),
          ),
          Divider(height: 1.0, color: theme.alternate),
          Expanded(
            child: _buildComments(context),
          ),
          if (controller != null && widget.onSubmitted != null) ...[
            Divider(height: 1.0, color: theme.alternate),
            Container(
              padding: EdgeInsets.all(tokens.spacing.md),
              color: theme.secondaryBackground,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (!widget.canComment) ...[
                    _CommentInlineMessage(
                      key: const ValueKey('bingo-comment-sign-in-message'),
                      color: theme.info,
                      icon: Icons.lock_outline_rounded,
                      message: localizations.getText(
                        'bingo_comment_sign_in_required',
                      ),
                    ),
                    SizedBox(height: tokens.spacing.sm),
                  ],
                  BingoStoryCommentInput(
                    controller: controller,
                    enabled: widget.canComment && !_commentPending,
                    autofocus: widget.autofocus,
                    onSubmitted: (_) => _submitComment(),
                  ),
                  if (draftLength >= 450) ...[
                    SizedBox(height: tokens.spacing.xs),
                    Align(
                      alignment: AlignmentDirectional.centerEnd,
                      child: Text(
                        '$draftLength / $bingoCommentMaxLength',
                        key: const ValueKey('bingo-comment-character-count'),
                        style: theme.labelSmall.copyWith(
                          color: draftLength > bingoCommentMaxLength
                              ? theme.error
                              : theme.secondaryText,
                        ),
                      ),
                    ),
                  ],
                  if (_commentFailed) ...[
                    SizedBox(height: tokens.spacing.sm),
                    _CommentInlineMessage(
                      key: const ValueKey('bingo-comment-sheet-error'),
                      color: theme.error,
                      icon: Icons.error_outline_rounded,
                      message: localizations.getText(
                        'bingo_story_comment_error',
                      ),
                      actionLabel: localizations.getText('story_retry'),
                      onAction: _submitComment,
                    ),
                  ],
                  if (_commentSent) ...[
                    SizedBox(height: tokens.spacing.sm),
                    _CommentInlineMessage(
                      key: const ValueKey('bingo-comment-sheet-success'),
                      color: theme.success,
                      icon: Icons.check_circle_outline_rounded,
                      message: localizations.getText(
                        'bingo_story_comment_success',
                      ),
                    ),
                  ],
                  SizedBox(height: tokens.spacing.sm),
                  FilledButton.icon(
                    key: const ValueKey('bingo-comment-sheet-submit'),
                    onPressed: canSubmit ? _submitComment : null,
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(48.0),
                      backgroundColor: theme.primary,
                      foregroundColor: theme.onPrimary,
                      disabledBackgroundColor:
                          theme.primary.withValues(alpha: 0.28),
                      disabledForegroundColor:
                          theme.onPrimary.withValues(alpha: 0.48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(tokens.radius.full),
                      ),
                    ),
                    icon: _commentPending
                        ? SizedBox.square(
                            dimension: 18.0,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.0,
                              color: theme.onPrimary,
                            ),
                          )
                        : const Icon(Icons.send_rounded, size: 20.0),
                    label: Text(
                      localizations.getText('bingo_story_comment_send'),
                      style: theme.labelLarge.copyWith(
                        color: theme.onPrimary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildComments(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final tokens = theme.designToken;
    final localizations = FFLocalizations.of(context);
    if (_loading) return const _CommentsSkeleton();
    if (_loadFailed) {
      return _CommentsMessage(
        icon: Icons.cloud_off_rounded,
        message: localizations.getText('bingo_comments_load_error'),
        actionLabel: localizations.getText('story_retry'),
        onAction: _reload,
      );
    }
    if (_comments.isEmpty && _optimisticComment == null) {
      return _CommentsMessage(
        icon: Icons.forum_outlined,
        message: localizations.getText('bingo_comments_empty'),
      );
    }

    final optimisticOffset = _optimisticComment == null ? 0 : 1;
    return RefreshIndicator(
      onRefresh: () => _reload(showLoading: false),
      child: ListView.separated(
        padding: EdgeInsetsDirectional.fromSTEB(
          tokens.spacing.md,
          tokens.spacing.md,
          tokens.spacing.md,
          tokens.spacing.lg,
        ),
        itemCount: _comments.length + optimisticOffset,
        separatorBuilder: (_, __) => SizedBox(height: tokens.spacing.sm),
        itemBuilder: (context, index) {
          if (optimisticOffset == 1 && index == 0) {
            return _OptimisticCommentCard(
              text: _optimisticComment!,
              failed: _commentFailed,
              onRetry: _submitComment,
            );
          }
          final comment = _comments[index - optimisticOffset];
          final highlighted = comment.id == widget.initialCommentId;
          return KeyedSubtree(
            key: highlighted ? _highlightedCommentKey : ValueKey(comment.id),
            child: BingoPublicCommentCard(
              comment: comment,
              highlighted: highlighted,
              likePending: _pendingLikes.contains(comment.id) ||
                  _pendingDeletes.contains(comment.id),
              canDelete: comment.isOwnedBy(currentUserUid),
              deletePending: _pendingDeletes.contains(comment.id),
              onLike: () => _toggleLike(comment),
              onDelete: () => _deleteComment(comment),
            ),
          );
        },
      ),
    );
  }
}

class BingoPublicCommentCard extends StatelessWidget {
  const BingoPublicCommentCard({
    super.key,
    required this.comment,
    required this.likePending,
    required this.canDelete,
    required this.deletePending,
    required this.onLike,
    required this.onDelete,
    this.highlighted = false,
  });

  final BingoPublicComment comment;
  final bool likePending;
  final bool canDelete;
  final bool deletePending;
  final VoidCallback onLike;
  final Future<void> Function() onDelete;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final tokens = theme.designToken;
    final localizations = FFLocalizations.of(context);
    final commentDate = comment.updatedAt ?? comment.createdAt;

    return Container(
      padding: EdgeInsets.all(tokens.spacing.md),
      decoration: BoxDecoration(
        color: theme.primaryBackground.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(tokens.radius.md),
        border: Border.all(
          color: highlighted
              ? theme.primary.withValues(alpha: 0.58)
              : theme.primaryText.withValues(alpha: 0.08),
          width: highlighted ? 2.0 : 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18.0,
                backgroundColor: theme.primary.withValues(alpha: 0.1),
                child: Icon(
                  Icons.person_outline_rounded,
                  color: theme.primary,
                  size: 19.0,
                ),
              ),
              SizedBox(width: tokens.spacing.sm),
              Expanded(
                child: Text(
                  canDelete
                      ? localizations.getText('bingo_comment_you')
                      : localizations.getText('bingo_comment_member'),
                  style: theme.bodyMedium.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              if (commentDate != null)
                Text(
                  dateTimeFormat(
                    'relative',
                    commentDate,
                    locale: localizations.languageCode,
                  ),
                  style: theme.labelSmall.copyWith(
                    color: theme.secondaryText,
                  ),
                ),
            ],
          ),
          SizedBox(height: tokens.spacing.sm),
          Text(comment.text, style: theme.bodyMedium.copyWith(height: 1.4)),
          if (comment.hasAdminReply) ...[
            SizedBox(height: tokens.spacing.sm),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(tokens.spacing.sm),
              decoration: BoxDecoration(
                color: theme.primary.withValues(alpha: 0.07),
                borderRadius: BorderRadius.circular(tokens.radius.sm),
                border: Border.all(
                  color: theme.primary.withValues(alpha: 0.24),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.verified_rounded,
                        color: theme.primary,
                        size: 16.0,
                      ),
                      SizedBox(width: tokens.spacing.sm),
                      Text(
                        localizations.getText(
                          'bingo_story_comment_reply_label',
                        ),
                        style: theme.labelMedium.copyWith(
                          color: theme.primary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: tokens.spacing.sm),
                  Text(
                    comment.adminReply,
                    style: theme.bodyMedium.copyWith(height: 1.35),
                  ),
                ],
              ),
            ),
          ],
          SizedBox(height: tokens.spacing.xs),
          Row(
            children: [
              TextButton.icon(
                onPressed: likePending ? null : onLike,
                icon: likePending
                    ? const SizedBox(
                        width: 16.0,
                        height: 16.0,
                        child: CircularProgressIndicator(strokeWidth: 2.0),
                      )
                    : Icon(
                        comment.likedByCurrentUser
                            ? Icons.favorite_rounded
                            : Icons.favorite_border_rounded,
                        color: comment.likedByCurrentUser ? theme.error : null,
                      ),
                label: Text(
                  '${localizations.getText(comment.likedByCurrentUser ? 'bingo_comment_liked' : 'bingo_comment_like')} · ${comment.likeCount}',
                ),
              ),
              const Spacer(),
              if (canDelete)
                SizedBox.square(
                  key: ValueKey('bingo-comment-delete-${comment.id}'),
                  dimension: 48.0,
                  child: deletePending
                      ? Center(
                          child: SizedBox.square(
                            dimension: 18.0,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.0,
                              color: theme.error,
                            ),
                          ),
                        )
                      : PopupMenuButton<String>(
                          tooltip: localizations.getText(
                            'bingo_comment_options',
                          ),
                          color: theme.secondaryBackground,
                          onSelected: (_) async => onDelete(),
                          itemBuilder: (_) => [
                            PopupMenuItem<String>(
                              value: 'delete',
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.delete_outline_rounded,
                                    color: theme.error,
                                    size: 20.0,
                                  ),
                                  SizedBox(width: tokens.spacing.sm),
                                  Text(
                                    localizations.getText(
                                      'bingo_story_comment_delete',
                                    ),
                                    style: theme.bodyMedium.copyWith(
                                      color: theme.error,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                          icon: Icon(
                            Icons.more_horiz_rounded,
                            color: theme.secondaryText,
                          ),
                        ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _OptimisticCommentCard extends StatelessWidget {
  const _OptimisticCommentCard({
    required this.text,
    required this.failed,
    required this.onRetry,
  });

  final String text;
  final bool failed;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final tokens = theme.designToken;
    final localizations = FFLocalizations.of(context);
    final statusColor = failed ? theme.error : theme.info;
    return Container(
      key: const ValueKey('bingo-comment-optimistic'),
      padding: EdgeInsets.all(tokens.spacing.md),
      decoration: BoxDecoration(
        color: theme.primaryBackground.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(tokens.radius.md),
        border: Border.all(color: statusColor.withValues(alpha: 0.34)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                failed ? Icons.error_outline_rounded : Icons.schedule_rounded,
                color: statusColor,
                size: 18.0,
              ),
              SizedBox(width: tokens.spacing.sm),
              Expanded(
                child: Text(
                  localizations.getText(
                    failed
                        ? 'bingo_comment_send_failed'
                        : 'bingo_comment_sending',
                  ),
                  style: theme.labelMedium.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (failed)
                TextButton(
                  onPressed: onRetry,
                  child: Text(localizations.getText('story_retry')),
                ),
            ],
          ),
          SizedBox(height: tokens.spacing.sm),
          Text(text, style: theme.bodyMedium.copyWith(height: 1.4)),
        ],
      ),
    );
  }
}

class _CommentInlineMessage extends StatelessWidget {
  const _CommentInlineMessage({
    super.key,
    required this.color,
    required this.icon,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final Color color;
  final IconData icon;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final tokens = theme.designToken;
    return Container(
      padding: EdgeInsets.all(tokens.spacing.sm),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(tokens.radius.sm),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20.0),
          SizedBox(width: tokens.spacing.sm),
          Expanded(
            child: Text(
              message,
              style: theme.bodySmall.copyWith(color: theme.primaryText),
            ),
          ),
          if (actionLabel != null && onAction != null)
            TextButton(onPressed: onAction, child: Text(actionLabel!)),
        ],
      ),
    );
  }
}

class _CommentsSkeleton extends StatelessWidget {
  const _CommentsSkeleton();

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final tokens = theme.designToken;
    return ListView.separated(
      key: const ValueKey('bingo-comments-loading'),
      padding: EdgeInsets.all(tokens.spacing.md),
      itemCount: 3,
      separatorBuilder: (_, __) => SizedBox(height: tokens.spacing.sm),
      itemBuilder: (_, __) => Container(
        height: 112.0,
        decoration: BoxDecoration(
          color: theme.primaryText.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(tokens.radius.md),
        ),
      ),
    );
  }
}

class _CommentsMessage extends StatelessWidget {
  const _CommentsMessage({
    required this.icon,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 34.0, color: theme.secondaryText),
            const SizedBox(height: 10.0),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.bodyMedium.copyWith(color: theme.secondaryText),
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 10.0),
              TextButton(onPressed: onAction, child: Text(actionLabel!)),
            ],
          ],
        ),
      ),
    );
  }
}
