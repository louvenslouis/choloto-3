import '/auth/firebase_auth/auth_util.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';

import 'bingo_comment_service.dart';

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
}) async {
  if (bingoReference == null) return;
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (_) => FractionallySizedBox(
      heightFactor: 0.82,
      child: _BingoPublicCommentsSheet(bingoReference: bingoReference),
    ),
  );
}

class _BingoPublicCommentsSheet extends StatefulWidget {
  const _BingoPublicCommentsSheet({required this.bingoReference});

  final DocumentReference bingoReference;

  @override
  State<_BingoPublicCommentsSheet> createState() =>
      _BingoPublicCommentsSheetState();
}

class _BingoPublicCommentsSheetState extends State<_BingoPublicCommentsSheet> {
  late Future<List<BingoPublicComment>> _commentsFuture;
  final Set<String> _pendingLikes = {};
  final Set<String> _pendingDeletes = {};

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    _commentsFuture = loadPublicBingoComments(
      bingoReference: widget.bingoReference,
    );
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
      if (mounted) setState(_reload);
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
        setState(_reload);
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
    final localizations = FFLocalizations.of(context);

    return Material(
      color: theme.secondaryBackground,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(28.0)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          const SizedBox(height: 10.0),
          Container(
            width: 42.0,
            height: 4.0,
            decoration: BoxDecoration(
              color: theme.alternate,
              borderRadius: BorderRadius.circular(99.0),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20.0, 14.0, 12.0, 12.0),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        localizations.getVariableText(
                          frText: 'Commentaires du BINGO',
                          crText: 'Kòmantè Bingo a',
                          enText: 'Bingo comments',
                        ),
                        style: theme.titleLarge.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 2.0),
                      Text(
                        localizations.getVariableText(
                          frText: 'Les auteurs restent anonymes.',
                          crText: 'Non moun yo rete anonim.',
                          enText: 'Authors remain anonymous.',
                        ),
                        style: theme.bodySmall.copyWith(
                          color: theme.secondaryText,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ),
          ),
          Divider(height: 1.0, color: theme.alternate),
          Expanded(
            child: FutureBuilder<List<BingoPublicComment>>(
              future: _commentsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return _CommentsMessage(
                    icon: Icons.cloud_off_rounded,
                    message: localizations.getVariableText(
                      frText: 'Impossible de charger les commentaires.',
                      crText: 'Nou pa ka chaje kòmantè yo.',
                      enText: 'Comments could not be loaded.',
                    ),
                    actionLabel: localizations.getVariableText(
                      frText: 'Réessayer',
                      crText: 'Eseye ankò',
                      enText: 'Retry',
                    ),
                    onAction: () => setState(_reload),
                  );
                }
                final comments = snapshot.data ?? const [];
                if (comments.isEmpty) {
                  return _CommentsMessage(
                    icon: Icons.forum_outlined,
                    message: localizations.getVariableText(
                      frText: 'Aucun commentaire pour ce BINGO.',
                      crText: 'Pa gen kòmantè pou Bingo sa a.',
                      enText: 'No comments for this Bingo yet.',
                    ),
                  );
                }
                return RefreshIndicator(
                  onRefresh: () async => setState(_reload),
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 28.0),
                    itemCount: comments.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12.0),
                    itemBuilder: (context, index) => BingoPublicCommentCard(
                      comment: comments[index],
                      likePending: _pendingLikes.contains(comments[index].id) ||
                          _pendingDeletes.contains(comments[index].id),
                      canDelete: comments[index].isOwnedBy(currentUserUid),
                      deletePending:
                          _pendingDeletes.contains(comments[index].id),
                      onLike: () => _toggleLike(comments[index]),
                      onDelete: () => _deleteComment(comments[index]),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
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
  });

  final BingoPublicComment comment;
  final bool likePending;
  final bool canDelete;
  final bool deletePending;
  final VoidCallback onLike;
  final Future<void> Function() onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final localizations = FFLocalizations.of(context);
    final commentDate = comment.updatedAt ?? comment.createdAt;

    return Container(
      padding: const EdgeInsets.all(15.0),
      decoration: BoxDecoration(
        color: theme.primaryBackground,
        borderRadius: BorderRadius.circular(18.0),
        border: Border.all(color: theme.alternate),
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
              const SizedBox(width: 10.0),
              Expanded(
                child: Text(
                  localizations.getVariableText(
                    frText: 'Membre CHOLOTO',
                    crText: 'Manm CHOLOTO',
                    enText: 'CHOLOTO member',
                  ),
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
          const SizedBox(height: 11.0),
          Text(comment.text, style: theme.bodyMedium.copyWith(height: 1.4)),
          if (comment.hasAdminReply) ...[
            const SizedBox(height: 12.0),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: theme.primary.withValues(alpha: 0.07),
                borderRadius: BorderRadius.circular(14.0),
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
                      const SizedBox(width: 6.0),
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
                  const SizedBox(height: 6.0),
                  Text(
                    comment.adminReply,
                    style: theme.bodyMedium.copyWith(height: 1.35),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 7.0),
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
                  '${comment.likedByCurrentUser ? localizations.getVariableText(frText: 'Aimé', crText: 'Renmen', enText: 'Liked') : localizations.getVariableText(frText: 'J’aime', crText: 'Renmen', enText: 'Like')} · ${comment.likeCount}',
                ),
              ),
              const Spacer(),
              if (canDelete)
                Tooltip(
                  message: localizations.getText(
                    'bingo_story_comment_delete',
                  ),
                  child: FlutterFlowIconButton(
                    key: ValueKey('bingo-comment-delete-${comment.id}'),
                    borderRadius: theme.designToken.radius.full,
                    buttonSize: 48.0,
                    showLoadingIndicator: true,
                    onPressed: deletePending ? null : onDelete,
                    icon: Icon(
                      Icons.delete_outline_rounded,
                      color: theme.error,
                      size: 20.0,
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
