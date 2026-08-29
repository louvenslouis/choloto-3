import 'dart:js_interop';

import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:web/web.dart' as web;

import 'bingo_comment_service.dart';

/// Web implementation backed by a real DOM input.
///
/// Mobile browsers only show their software keyboard when a trusted pointer
/// event reaches a native editable element. Keeping the input itself inside the
/// platform view makes that first touch reliable on Safari and Chrome mobile.
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
  web.HTMLDivElement? _root;
  web.HTMLInputElement? _input;
  web.HTMLButtonElement? _sendButton;
  web.HTMLSpanElement? _sendIcon;

  late final web.EventListener _inputListener;
  late final web.EventListener _focusListener;
  late final web.EventListener _blurListener;
  late final web.EventListener _keyDownListener;
  late final web.EventListener _submitListener;

  String _placeholder = '';
  String _sendLabel = '';
  String _surfaceColor = '';
  String _textColor = '';
  String _secondaryTextColor = '';
  String _primaryColor = '';
  String _radius = '9999px';
  String _horizontalPadding = '16px';
  bool _hasFocus = false;

  @override
  void initState() {
    super.initState();
    _inputListener = ((web.Event _) => _handleDomInput()).toJS;
    _focusListener = ((web.Event _) => _handleFocus(true)).toJS;
    _blurListener = ((web.Event _) => _handleFocus(false)).toJS;
    _keyDownListener = ((web.Event event) {
      final keyboardEvent = event as web.KeyboardEvent;
      if (keyboardEvent.key == 'Enter' && !keyboardEvent.isComposing) {
        event.preventDefault();
        _submit();
      }
    }).toJS;
    _submitListener = ((web.Event event) {
      event.preventDefault();
      _submit();
    }).toJS;
    widget.controller.addListener(_syncDomFromController);
  }

  @override
  void didUpdateWidget(covariant BingoStoryCommentInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_syncDomFromController);
      widget.controller.addListener(_syncDomFromController);
    }
    _syncDomFromController();
  }

  @override
  void dispose() {
    widget.controller.removeListener(_syncDomFromController);
    final input = _input;
    if (input != null) {
      input
        ..removeEventListener('input', _inputListener)
        ..removeEventListener('focus', _focusListener)
        ..removeEventListener('blur', _blurListener)
        ..removeEventListener('keydown', _keyDownListener);
    }
    _sendButton?.removeEventListener('click', _submitListener);
    super.dispose();
  }

  void _handleDomInput() {
    final value = _input?.value ?? '';
    if (widget.controller.text != value) {
      widget.controller.value = TextEditingValue(
        text: value,
        selection: TextSelection.collapsed(offset: value.length),
      );
    }
    _syncSendButton();
  }

  void _handleFocus(bool focused) {
    if (_hasFocus == focused) return;
    _hasFocus = focused;
    _input?.setAttribute('data-bingo-comment-focused', focused.toString());
    _syncRootStyle();
    widget.onFocusChanged?.call(focused);
  }

  void _submit() {
    if (!widget.enabled || widget.controller.text.trim().isEmpty) return;
    widget.onSubmitted(widget.controller.text);
  }

  void _onElementCreated(Object element) {
    final root = element as web.HTMLDivElement;
    final input = web.HTMLInputElement();
    final sendButton = web.HTMLButtonElement();
    final sendIcon = web.HTMLSpanElement();

    root
      ..setAttribute('data-bingo-comment-composer', 'true')
      ..setAttribute('role', 'group');
    input
      ..type = 'text'
      ..name = 'bingo-comment'
      ..maxLength = bingoCommentMaxLength
      ..autocomplete = 'off'
      ..enterKeyHint = 'send'
      ..inputMode = 'text'
      ..setAttribute('autocapitalize', 'sentences')
      ..setAttribute('data-bingo-comment-input', 'true');
    sendButton
      ..type = 'button'
      ..setAttribute('data-bingo-comment-submit', 'true');
    sendIcon.setAttribute('aria-hidden', 'true');

    input
      ..addEventListener('input', _inputListener)
      ..addEventListener('focus', _focusListener)
      ..addEventListener('blur', _blurListener)
      ..addEventListener('keydown', _keyDownListener);
    sendButton.addEventListener('click', _submitListener);

    sendButton.appendChild(sendIcon);
    root
      ..appendChild(input)
      ..appendChild(sendButton);

    _root = root;
    _input = input;
    _sendButton = sendButton;
    _sendIcon = sendIcon;
    _styleElements();
    _syncDomFromController();
  }

  void _styleElements() {
    final root = _root;
    final input = _input;
    final button = _sendButton;
    final icon = _sendIcon;
    if (root == null || input == null || button == null || icon == null) return;

    root.style
      ..width = '100%'
      ..height = '100%'
      ..display = 'flex'
      ..alignItems = 'center'
      ..boxSizing = 'border-box'
      ..overflow = 'hidden'
      ..fontFamily = 'Inter, sans-serif'
      ..touchAction = 'manipulation';
    input.style
      ..flex = '1 1 auto'
      ..minWidth = '0'
      ..height = '100%'
      ..boxSizing = 'border-box'
      ..border = '0'
      ..outline = 'none'
      ..background = 'transparent'
      ..padding = '0 $_horizontalPadding'
      ..fontFamily = 'Inter, sans-serif'
      ..fontSize = '14px'
      ..fontWeight = '400'
      ..lineHeight = '20px'
      ..touchAction = 'manipulation';
    button.style
      ..width = '48px'
      ..height = '48px'
      ..flex = '0 0 48px'
      ..alignItems = 'center'
      ..justifyContent = 'center'
      ..boxSizing = 'border-box'
      ..border = '0'
      ..outline = 'none'
      ..background = 'transparent'
      ..padding = '0'
      ..cursor = 'pointer'
      ..touchAction = 'manipulation';
    icon.style
      ..display = 'block'
      ..width = '20px'
      ..height = '20px'
      ..clipPath = 'polygon(4% 5%, 96% 50%, 4% 95%, 19% 58%, 66% 50%, 19% 42%)';

    _syncRootStyle();
    _syncAccessibility();
  }

  void _syncDomFromController() {
    final input = _input;
    if (input != null && input.value != widget.controller.text) {
      input.value = widget.controller.text;
    }
    _syncAccessibility();
    _syncSendButton();
  }

  void _syncAccessibility() {
    final input = _input;
    final button = _sendButton;
    if (input == null || button == null) return;

    input
      ..placeholder = _placeholder
      ..disabled = !widget.enabled
      ..setAttribute('aria-label', _placeholder);
    button
      ..title = _sendLabel
      ..setAttribute('aria-label', _sendLabel);
  }

  void _syncRootStyle() {
    final root = _root;
    final input = _input;
    if (root == null || input == null) return;

    root.style
      ..backgroundColor = _surfaceColor
      ..borderRadius = _radius
      ..border =
          _hasFocus ? '2px solid $_primaryColor' : '2px solid transparent';
    input.style
      ..color = _textColor
      ..caretColor = _primaryColor
      ..opacity = widget.enabled ? '1' : '0.6';
  }

  void _syncSendButton() {
    final button = _sendButton;
    final icon = _sendIcon;
    if (button == null || icon == null) return;

    final hasComment = widget.controller.text.trim().isNotEmpty;
    final canSubmit = widget.enabled && hasComment;
    button
      ..disabled = !canSubmit
      ..style.display = hasComment ? 'flex' : 'none';
    button.style.cursor = canSubmit ? 'pointer' : 'default';
    icon.style.backgroundColor =
        canSubmit ? _primaryColor : _secondaryTextColor;
  }

  void _readDesignConfiguration(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final tokens = theme.designToken;
    final localizations = FFLocalizations.of(context);

    _placeholder = localizations.getText('bingo_story_comment_hint');
    _sendLabel = localizations.getText('bingo_story_comment_send');
    _surfaceColor = _cssColor(theme.secondaryBackground);
    _textColor = _cssColor(theme.primaryText);
    _secondaryTextColor = _cssColor(theme.secondaryText);
    _primaryColor = _cssColor(theme.primary);
    _radius = '${tokens.radius.full}px';
    _horizontalPadding = '${tokens.spacing.md}px';
  }

  String _cssColor(Color color) {
    final argb = color.toARGB32();
    final alpha = ((argb >> 24) & 0xff) / 255;
    final red = (argb >> 16) & 0xff;
    final green = (argb >> 8) & 0xff;
    final blue = argb & 0xff;
    return 'rgba($red, $green, $blue, ${alpha.toStringAsFixed(3)})';
  }

  @override
  Widget build(BuildContext context) {
    _readDesignConfiguration(context);
    _styleElements();
    _syncDomFromController();

    return SizedBox(
      height: 48.0,
      child: HtmlElementView.fromTagName(
        key: const ValueKey('bingo-story-comment-field'),
        tagName: 'div',
        onElementCreated: _onElementCreated,
      ),
    );
  }
}
