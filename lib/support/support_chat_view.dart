import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '/flutter_flow/flutter_flow_theme.dart';
import 'support_conversation.dart';
import 'support_text.dart';

typedef SendSupportMessage = Future<void> Function(String text);

class SupportChatView extends StatefulWidget {
  const SupportChatView({
    super.key,
    required this.messages,
    required this.onSend,
    this.showOptionalPhoneOnFirstMessage = false,
  });

  final Stream<List<SupportMessage>> messages;
  final SendSupportMessage onSend;
  final bool showOptionalPhoneOnFirstMessage;

  @override
  State<SupportChatView> createState() => _SupportChatViewState();
}

class _SupportChatViewState extends State<SupportChatView> {
  final _controller = TextEditingController();
  final _phoneController = TextEditingController();
  final _scrollController = ScrollController();
  bool _sending = false;
  String? _error;
  int _messageCount = 0;
  bool _hasExistingMessages = false;
  bool _firstMessageSent = false;

  bool get _showOptionalPhone =>
      widget.showOptionalPhoneOnFirstMessage &&
      !_hasExistingMessages &&
      !_firstMessageSent;

  @override
  void dispose() {
    _controller.dispose();
    _phoneController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToLatest(int count) {
    if (count == _messageCount) return;
    _messageCount = count;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
      );
    });
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    final phone = _phoneController.text.trim();
    final outgoingText = _showOptionalPhone && phone.isNotEmpty
        ? '${supportText(context, 'phoneMessageLabel')}: $phone\n\n$text'
        : text;
    if (_sending || text.isEmpty || outgoingText.length > 1000) return;
    setState(() {
      _sending = true;
      _error = null;
    });
    try {
      await widget.onSend(outgoingText);
      if (mounted) {
        _controller.clear();
        _phoneController.clear();
        setState(() => _firstMessageSent = true);
      }
    } catch (_) {
      if (mounted) setState(() => _error = supportText(context, 'sendError'));
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final tokens = theme.designToken;
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(
            tokens.spacing.md,
            tokens.spacing.sm,
            tokens.spacing.md,
            tokens.spacing.sm,
          ),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.all(tokens.spacing.md),
            decoration: BoxDecoration(
              color: theme.secondaryBackground,
              borderRadius: BorderRadius.circular(tokens.radius.md),
              border: Border.all(color: theme.alternate.withValues(alpha: .35)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: theme.primary,
                    borderRadius: BorderRadius.circular(tokens.radius.full),
                  ),
                  child: Icon(
                    Icons.support_agent_rounded,
                    color: theme.onPrimary,
                    size: 24,
                  ),
                ),
                SizedBox(width: tokens.spacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(supportText(context, 'admin'),
                          style: theme.titleMedium),
                      SizedBox(height: tokens.spacing.xs),
                      Text(supportText(context, 'intro'),
                          style: theme.bodyMedium
                              .override(color: theme.secondaryText)),
                      SizedBox(height: tokens.spacing.sm),
                      Row(
                        children: [
                          Icon(Icons.schedule_rounded,
                              size: 16, color: theme.primary),
                          SizedBox(width: tokens.spacing.xs),
                          Expanded(
                            child: Text(
                              supportText(context, 'responseTime'),
                              style: theme.labelMedium
                                  .override(color: theme.secondaryText),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: StreamBuilder<List<SupportMessage>>(
            stream: widget.messages,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return _SupportState(
                  icon: Icons.cloud_off_rounded,
                  title: supportText(context, 'error'),
                );
              }
              if (!snapshot.hasData) {
                return Center(
                    child: CircularProgressIndicator(color: theme.primary));
              }
              final messages = snapshot.data!;
              final hasMessages = messages.isNotEmpty;
              if (hasMessages != _hasExistingMessages) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted && hasMessages != _hasExistingMessages) {
                    setState(() => _hasExistingMessages = hasMessages);
                  }
                });
              }
              _scrollToLatest(messages.length);
              if (messages.isEmpty) {
                return _SupportState(
                  icon: Icons.forum_outlined,
                  title: supportText(context, 'emptyTitle'),
                  body: supportText(context, 'emptyBody'),
                );
              }
              return ListView.builder(
                key: const ValueKey('support-message-list'),
                controller: _scrollController,
                padding: EdgeInsets.fromLTRB(
                  tokens.spacing.md,
                  tokens.spacing.sm,
                  tokens.spacing.md,
                  tokens.spacing.md,
                ),
                itemCount: messages.length,
                itemBuilder: (context, index) => _MessageBubble(
                  message: messages[index],
                ),
              );
            },
          ),
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            color: theme.secondaryBackground,
            border: Border(
              top: BorderSide(color: theme.alternate.withValues(alpha: .35)),
            ),
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: EdgeInsets.all(tokens.spacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (_error != null)
                    Padding(
                      padding: EdgeInsets.only(bottom: tokens.spacing.sm),
                      child: Semantics(
                        liveRegion: true,
                        child: Text(_error!,
                            style:
                                theme.bodySmall.override(color: theme.error)),
                      ),
                    ),
                  if (_showOptionalPhone) ...[
                    TextField(
                      key: const ValueKey('support-optional-phone-field'),
                      controller: _phoneController,
                      enabled: !_sending,
                      keyboardType: TextInputType.phone,
                      maxLength: 32,
                      style: theme.bodyLarge,
                      decoration: InputDecoration(
                        labelText: supportText(context, 'phoneOptionalLabel'),
                        hintText: supportText(context, 'phoneOptionalHint'),
                        counterText: '',
                        filled: true,
                        fillColor: theme.primaryBackground,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: tokens.spacing.md,
                          vertical: tokens.spacing.sm,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(tokens.radius.md),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(tokens.radius.md),
                          borderSide: BorderSide(
                            color: theme.alternate.withValues(alpha: .45),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(tokens.radius.md),
                          borderSide: BorderSide(color: theme.primary),
                        ),
                      ),
                    ),
                    SizedBox(height: tokens.spacing.sm),
                  ],
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: TextField(
                          key: const ValueKey('support-message-field'),
                          controller: _controller,
                          enabled: !_sending,
                          minLines: 1,
                          maxLines: 4,
                          maxLength: 1000,
                          textCapitalization: TextCapitalization.sentences,
                          style: theme.bodyLarge,
                          decoration: InputDecoration(
                            hintText: supportText(context, 'hint'),
                            hintStyle: theme.bodyMedium
                                .override(color: theme.secondaryText),
                            counterText: '',
                            filled: true,
                            fillColor: theme.primaryBackground,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: tokens.spacing.md,
                              vertical: tokens.spacing.sm,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.circular(tokens.radius.md),
                              borderSide: BorderSide(
                                color: theme.alternate.withValues(alpha: .45),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.circular(tokens.radius.md),
                              borderSide: BorderSide(color: theme.primary),
                            ),
                            disabledBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.circular(tokens.radius.md),
                              borderSide: BorderSide(
                                color: theme.alternate.withValues(alpha: .25),
                              ),
                            ),
                          ),
                          onSubmitted: (_) => _send(),
                        ),
                      ),
                      SizedBox(width: tokens.spacing.sm),
                      Semantics(
                        button: true,
                        label:
                            supportText(context, _sending ? 'sending' : 'send'),
                        child: IconButton.filled(
                          key: const ValueKey('support-send-button'),
                          onPressed: _sending ? null : _send,
                          style: IconButton.styleFrom(
                            backgroundColor: theme.primary,
                            foregroundColor: theme.onPrimary,
                            disabledBackgroundColor:
                                theme.primary.withValues(alpha: .45),
                            minimumSize: const Size(48, 48),
                          ),
                          icon: _sending
                              ? SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: theme.onPrimary,
                                  ),
                                )
                              : const Icon(Icons.send_rounded),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message});

  final SupportMessage message;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final tokens = theme.designToken;
    final fromAdmin = message.sentByAdmin;
    final time = message.createdAt == null
        ? ''
        : DateFormat('dd/MM · HH:mm').format(message.createdAt!.toLocal());
    return Align(
      alignment: fromAdmin ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 520),
        margin: EdgeInsets.only(bottom: tokens.spacing.md),
        padding: EdgeInsets.all(tokens.spacing.md),
        decoration: BoxDecoration(
          color: fromAdmin ? theme.secondaryBackground : theme.primary,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(tokens.radius.md),
            topRight: Radius.circular(tokens.radius.md),
            bottomLeft: Radius.circular(
                fromAdmin ? tokens.radius.sm : tokens.radius.md),
            bottomRight: Radius.circular(
                fromAdmin ? tokens.radius.md : tokens.radius.sm),
          ),
          border: fromAdmin
              ? Border.all(color: theme.alternate.withValues(alpha: .35))
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              fromAdmin
                  ? supportText(context, 'admin')
                  : supportText(context, 'you'),
              style: theme.labelSmall.override(
                color: fromAdmin ? theme.secondaryText : theme.onPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: tokens.spacing.xs),
            Text(
              message.text,
              style: theme.bodyLarge.override(
                color: fromAdmin ? theme.primaryText : theme.onPrimary,
              ),
            ),
            if (time.isNotEmpty) ...[
              SizedBox(height: tokens.spacing.xs),
              Text(
                time,
                style: theme.labelSmall.override(
                  color: fromAdmin
                      ? theme.secondaryText
                      : theme.onPrimary.withValues(alpha: .7),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SupportState extends StatelessWidget {
  const _SupportState({required this.icon, required this.title, this.body});

  final IconData icon;
  final String title;
  final String? body;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final spacing = theme.designToken.spacing;
    return Center(
      child: Padding(
        padding: EdgeInsets.all(spacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 44, color: theme.primary),
            SizedBox(height: spacing.md),
            Text(title, textAlign: TextAlign.center, style: theme.titleMedium),
            if (body != null) ...[
              SizedBox(height: spacing.sm),
              Text(
                body!,
                textAlign: TextAlign.center,
                style: theme.bodyMedium.override(color: theme.secondaryText),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
