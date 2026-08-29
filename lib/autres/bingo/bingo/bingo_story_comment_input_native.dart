import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';

import 'bingo_comment_service.dart';

/// Android and iOS implementation of the Bingo Story comment composer.
class BingoStoryCommentInput extends StatefulWidget {
  const BingoStoryCommentInput({
    super.key,
    required this.controller,
    required this.enabled,
    required this.onSubmitted,
    this.onFocusChanged,
  });

  final TextEditingController controller;
  final bool enabled;
  final ValueChanged<String> onSubmitted;
  final ValueChanged<bool>? onFocusChanged;

  @override
  State<BingoStoryCommentInput> createState() => _BingoStoryCommentInputState();
}

class _BingoStoryCommentInputState extends State<BingoStoryCommentInput> {
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode()..addListener(_onFocusChanged);
    widget.controller.addListener(_onTextChanged);
  }

  @override
  void didUpdateWidget(covariant BingoStoryCommentInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_onTextChanged);
      widget.controller.addListener(_onTextChanged);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    _focusNode
      ..removeListener(_onFocusChanged)
      ..dispose();
    super.dispose();
  }

  void _onTextChanged() => setState(() {});

  void _onFocusChanged() {
    widget.onFocusChanged?.call(_focusNode.hasFocus);
  }

  void _focusOnPointerDown(PointerDownEvent _) {
    if (!widget.enabled || _focusNode.hasFocus) return;
    FocusScope.of(context).requestFocus(_focusNode);
  }

  void _submit() {
    if (!widget.enabled || widget.controller.text.trim().isEmpty) return;
    widget.onSubmitted(widget.controller.text);
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final tokens = theme.designToken;
    final localizations = FFLocalizations.of(context);
    final hasComment = widget.controller.text.trim().isNotEmpty;
    final canSubmit = widget.enabled && hasComment;

    return Listener(
      behavior: HitTestBehavior.opaque,
      onPointerDown: _focusOnPointerDown,
      child: SizedBox(
        height: 48.0,
        child: TextField(
          key: const ValueKey('bingo-story-comment-field'),
          controller: widget.controller,
          focusNode: _focusNode,
          readOnly: !widget.enabled,
          maxLength: bingoCommentMaxLength,
          maxLines: 1,
          keyboardType: TextInputType.text,
          textInputAction: TextInputAction.send,
          style: theme.bodyMedium,
          onTapOutside: (_) => _focusNode.unfocus(),
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
      ),
    );
  }
}
