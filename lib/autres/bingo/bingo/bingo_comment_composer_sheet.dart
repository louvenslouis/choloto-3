import 'dart:async';

import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';

import 'bingo_story_comment_input.dart';

typedef BingoSheetCommentSubmitter = Future<bool> Function(String comment);

Future<bool?> showBingoCommentComposerSheet({
  required BuildContext context,
  required TextEditingController controller,
  required BingoSheetCommentSubmitter onSubmitted,
}) {
  final theme = FlutterFlowTheme.of(context);
  final tokens = theme.designToken;

  return showModalBottomSheet<bool>(
    context: context,
    useSafeArea: true,
    isScrollControlled: true,
    requestFocus: true,
    backgroundColor: theme.secondaryBackground,
    barrierColor: theme.primaryBackground.withValues(alpha: 0.72),
    constraints: const BoxConstraints(maxWidth: 640.0),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(tokens.radius.lg),
      ),
    ),
    clipBehavior: Clip.antiAlias,
    builder: (_) => _BingoCommentComposerSheet(
      controller: controller,
      onSubmitted: onSubmitted,
    ),
  );
}

class _BingoCommentComposerSheet extends StatefulWidget {
  const _BingoCommentComposerSheet({
    required this.controller,
    required this.onSubmitted,
  });

  final TextEditingController controller;
  final BingoSheetCommentSubmitter onSubmitted;

  @override
  State<_BingoCommentComposerSheet> createState() =>
      _BingoCommentComposerSheetState();
}

class _BingoCommentComposerSheetState
    extends State<_BingoCommentComposerSheet> {
  var _pending = false;
  var _showError = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
  }

  @override
  void didUpdateWidget(covariant _BingoCommentComposerSheet oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_onTextChanged);
      widget.controller.addListener(_onTextChanged);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onTextChanged() {
    if (mounted) setState(() => _showError = false);
  }

  void _startSubmit(String comment) {
    unawaited(_submit(comment));
  }

  Future<void> _submit(String comment) async {
    if (_pending || comment.trim().isEmpty) return;
    setState(() {
      _pending = true;
      _showError = false;
    });

    final succeeded = await widget.onSubmitted(comment);
    if (!mounted) return;
    if (succeeded) {
      Navigator.of(context).pop(true);
      return;
    }

    setState(() {
      _pending = false;
      _showError = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final tokens = theme.designToken;
    final localizations = FFLocalizations.of(context);
    final canSubmit = !_pending && widget.controller.text.trim().isNotEmpty;

    return AnimatedPadding(
      key: const ValueKey('bingo-comment-sheet'),
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SingleChildScrollView(
        padding: EdgeInsetsDirectional.fromSTEB(
          tokens.spacing.md,
          tokens.spacing.sm,
          tokens.spacing.md,
          tokens.spacing.lg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 42.0,
                height: tokens.spacing.xs,
                decoration: BoxDecoration(
                  color: theme.alternate,
                  borderRadius: BorderRadius.circular(tokens.radius.full),
                ),
              ),
            ),
            SizedBox(height: tokens.spacing.sm),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        localizations.getVariableText(
                          frText: 'Ajouter un commentaire',
                          crText: 'Ekri yon kòmantè',
                          enText: 'Add a comment',
                        ),
                        style: theme.titleLarge.copyWith(
                          color: theme.primaryText,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  key: const ValueKey('bingo-comment-sheet-close'),
                  tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
                  onPressed:
                      _pending ? null : () => Navigator.of(context).pop(false),
                  icon: Icon(
                    Icons.close_rounded,
                    color: theme.secondaryText,
                  ),
                ),
              ],
            ),
            SizedBox(height: tokens.spacing.md),
            BingoStoryCommentInput(
              controller: widget.controller,
              enabled: !_pending,
              autofocus: true,
              onSubmitted: _startSubmit,
            ),
            if (_showError) ...[
              SizedBox(height: tokens.spacing.sm),
              Container(
                key: const ValueKey('bingo-comment-sheet-error'),
                padding: EdgeInsets.all(tokens.spacing.sm),
                decoration: BoxDecoration(
                  color: theme.error.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(tokens.radius.sm),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline_rounded, color: theme.error),
                    SizedBox(width: tokens.spacing.sm),
                    Expanded(
                      child: Text(
                        localizations.getText('bingo_story_comment_error'),
                        style: theme.bodySmall.copyWith(color: theme.error),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            SizedBox(height: tokens.spacing.md),
            FilledButton.icon(
              key: const ValueKey('bingo-comment-sheet-submit'),
              onPressed:
                  canSubmit ? () => _startSubmit(widget.controller.text) : null,
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(48.0),
                backgroundColor: theme.primary,
                foregroundColor: theme.onPrimary,
                disabledBackgroundColor: theme.primary.withValues(alpha: 0.28),
                disabledForegroundColor:
                    theme.onPrimary.withValues(alpha: 0.48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(tokens.radius.full),
                ),
              ),
              icon: _pending
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
    );
  }
}
