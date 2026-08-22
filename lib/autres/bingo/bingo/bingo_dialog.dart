import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:webviewx_plus/webviewx_plus.dart';

import 'bingo_comment_service.dart';
import 'bingo_reaction_service.dart';
import 'bingo_widget.dart';

const bingoStatusAspectRatio = 9.0 / 16.0;
const bingoStatusMobileBreakpoint = 600.0;
// Original 400x400 card, including its 4px Card margin and 10px side padding.
const bingoCardPresentationSize = Size(428.0, 408.0);

class BingoStatusFrame extends StatelessWidget {
  const BingoStatusFrame({
    super.key,
    required this.child,
    this.publishedAt,
    this.selectedReaction,
    this.onReaction,
    this.reactionPending = false,
    this.commentController,
    this.onCommentSubmitted,
    this.commentPending = false,
  });

  final Widget child;
  final DateTime? publishedAt;
  final BingoReaction? selectedReaction;
  final ValueChanged<BingoReaction>? onReaction;
  final bool reactionPending;
  final TextEditingController? commentController;
  final ValueChanged<String>? onCommentSubmitted;
  final bool commentPending;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final frame = ColoredBox(
      color: theme.primaryBackground,
      child: WebViewAware(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            FocusScope.of(context).unfocus();
            FocusManager.instance.primaryFocus?.unfocus();
          },
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
              if (publishedAt != null)
                _BingoStoryHeader(publishedAt: publishedAt!),
              if (onReaction != null || onCommentSubmitted != null)
                _BingoStoryEngagementBar(
                  selectedReaction: selectedReaction,
                  reactionEnabled: !reactionPending,
                  onReaction: onReaction,
                  commentController: commentController,
                  commentEnabled: !commentPending,
                  onCommentSubmitted: onCommentSubmitted,
                ),
            ],
          ),
        ),
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
    required this.commentController,
    required this.commentEnabled,
    required this.onCommentSubmitted,
  });

  final BingoReaction? selectedReaction;
  final bool reactionEnabled;
  final ValueChanged<BingoReaction>? onReaction;
  final TextEditingController? commentController;
  final bool commentEnabled;
  final ValueChanged<String>? onCommentSubmitted;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final tokens = theme.designToken;
    final localizations = FFLocalizations.of(context);

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
          fillColor: selected ? theme.primary : theme.secondaryBackground,
          disabledColor: theme.secondaryBackground,
          disabledIconColor: theme.secondaryText,
          icon: Icon(
            icon,
            color: selected ? theme.onPrimary : theme.primaryText,
            size: 24.0,
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
          child: Row(
            key: const ValueKey('bingo-story-engagement-bar'),
            children: [
              if (commentController != null && onCommentSubmitted != null) ...[
                Expanded(
                  child: _BingoStoryCommentField(
                    controller: commentController!,
                    enabled: commentEnabled,
                    onSubmitted: onCommentSubmitted!,
                  ),
                ),
                if (onReaction != null) SizedBox(width: tokens.spacing.sm),
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
                    SizedBox(width: tokens.spacing.sm),
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
        ),
      ),
    );
  }
}

class _BingoStoryCommentField extends StatefulWidget {
  const _BingoStoryCommentField({
    required this.controller,
    required this.enabled,
    required this.onSubmitted,
  });

  final TextEditingController controller;
  final bool enabled;
  final ValueChanged<String> onSubmitted;

  @override
  State<_BingoStoryCommentField> createState() =>
      _BingoStoryCommentFieldState();
}

class _BingoStoryCommentFieldState extends State<_BingoStoryCommentField> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
  }

  @override
  void didUpdateWidget(covariant _BingoStoryCommentField oldWidget) {
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

  void _onTextChanged() => setState(() {});

  void _submit() {
    if (!widget.enabled || widget.controller.text.trim().isEmpty) {
      return;
    }
    widget.onSubmitted(widget.controller.text);
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final tokens = theme.designToken;
    final localizations = FFLocalizations.of(context);
    final hasComment = widget.controller.text.trim().isNotEmpty;
    final canSubmit = widget.enabled && hasComment;

    return SizedBox(
      height: 48.0,
      child: TextField(
        key: const ValueKey('bingo-story-comment-field'),
        controller: widget.controller,
        readOnly: !widget.enabled,
        maxLength: bingoCommentMaxLength,
        maxLines: 1,
        textInputAction: TextInputAction.send,
        style: theme.bodyMedium,
        onSubmitted: (_) => _submit(),
        decoration: InputDecoration(
          hintText: localizations.getText('bingo_story_comment_hint'),
          hintStyle: theme.labelMedium.copyWith(
            color: theme.secondaryText,
          ),
          counterText: '',
          filled: true,
          fillColor: theme.secondaryBackground,
          contentPadding: EdgeInsetsDirectional.only(
            start: tokens.spacing.md,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(tokens.radius.full),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(tokens.radius.full),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(tokens.radius.full),
            borderSide: BorderSide(
              color: theme.primary,
              width: 2.0,
            ),
          ),
          suffixIcon: hasComment
              ? Semantics(
                  label: localizations.getText('bingo_story_comment_send'),
                  button: true,
                  enabled: canSubmit,
                  child: IconButton(
                    key: const ValueKey('bingo-story-comment-send'),
                    onPressed: canSubmit ? _submit : null,
                    icon: Icon(
                      Icons.send_rounded,
                      color: canSubmit ? theme.primary : theme.secondaryText,
                      size: 20.0,
                    ),
                  ),
                )
              : null,
        ),
      ),
    );
  }
}

class _BingoStatusDialogBody extends StatefulWidget {
  const _BingoStatusDialogBody({
    required this.content,
    this.publishedAt,
  });

  final Widget content;
  final DateTime? publishedAt;

  @override
  State<_BingoStatusDialogBody> createState() => _BingoStatusDialogBodyState();
}

class _BingoStatusDialogBodyState extends State<_BingoStatusDialogBody> {
  late BingoReaction? _selectedReaction;
  final _commentController = TextEditingController();
  var _reactionPending = false;
  var _commentPending = false;

  @override
  void initState() {
    super.initState();
    _selectedReaction = bingoReactionFromState(FFAppState().bingo);
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _react(BingoReaction reaction) async {
    if (_reactionPending) {
      return;
    }

    setState(() => _reactionPending = true);
    try {
      final nextReaction = await toggleCurrentBingoReaction(reaction);
      if (mounted) {
        setState(() => _selectedReaction = nextReaction);
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

  Future<void> _submitComment(String comment) async {
    if (_commentPending) {
      return;
    }

    setState(() => _commentPending = true);
    try {
      await saveCurrentBingoComment(comment);
      if (mounted) {
        FocusScope.of(context).unfocus();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              FFLocalizations.of(context)
                  .getText('bingo_story_comment_success'),
            ),
            backgroundColor: FlutterFlowTheme.of(context).success,
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              FFLocalizations.of(context).getText('bingo_story_comment_error'),
            ),
            backgroundColor: FlutterFlowTheme.of(context).error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _commentPending = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BingoStatusFrame(
      publishedAt: widget.publishedAt,
      selectedReaction: _selectedReaction,
      reactionPending: _reactionPending,
      onReaction: _react,
      commentController: _commentController,
      commentPending: _commentPending,
      onCommentSubmitted: _submitComment,
      child: widget.content,
    );
  }
}

Future<T?> showBingoDialog<T>({
  required BuildContext context,
  Widget? content,
}) {
  return showDialog<T>(
    context: context,
    useSafeArea: false,
    builder: (dialogContext) {
      final theme = FlutterFlowTheme.of(dialogContext);

      return Dialog.fullscreen(
        key: const ValueKey('bingo-status-dialog'),
        backgroundColor: theme.primaryBackground,
        child: _BingoStatusDialogBody(
          publishedAt: FFAppState().bingo.date,
          content: content ?? const BingoWidget(),
        ),
      );
    },
  );
}
