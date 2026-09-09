import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '/flutter_flow/flutter_flow_theme.dart';
import '/payments/proof_image.dart';
import 'support_conversation.dart';
import 'support_text.dart';
import 'support_audio.dart';
import 'support_audio_player.dart';
import 'support_voice_recorder.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';

typedef SendSupportMessage = Future<void> Function(
    String text, Uint8List? image);
typedef LoadSupportImage = Future<Uint8List> Function(String messageId);

class SupportChatView extends StatefulWidget {
  const SupportChatView({
    super.key,
    required this.messages,
    required this.onSend,
    this.loadImage,
    this.loadAudio,
    this.onSendAudio,
    this.recorderFactory,
    this.pickImage,
    this.showOptionalPhoneOnFirstMessage = false,
  });

  final Stream<List<SupportMessage>> messages;
  final SendSupportMessage onSend;
  final LoadSupportImage? loadImage;
  final Future<SupportAudio> Function(String messageId)? loadAudio;
  final Future<void> Function(String text, SupportAudio audio)? onSendAudio;
  final SupportVoiceRecorder Function()? recorderFactory;
  final Future<Uint8List?> Function()? pickImage;
  final bool showOptionalPhoneOnFirstMessage;

  @override
  State<SupportChatView> createState() => _SupportChatViewState();
}

class _SupportChatViewState extends State<SupportChatView>
    with WidgetsBindingObserver {
  SupportVoiceRecorder? _recorder;
  SupportAudio? _audio;
  bool _recording = false;
  bool _voiceBusy = false;
  Timer? _recordingTimer;
  final _recordingWatch = Stopwatch();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if ((state == AppLifecycleState.paused ||
            state == AppLifecycleState.hidden) &&
        _recording) {
      unawaited(_finishVoice());
    }
  }

  Future<void> _startVoice() async {
    if (_voiceBusy ||
        _recording ||
        _sending ||
        _preparingImage ||
        _image != null ||
        _audio != null) {
      return;
    }
    FocusScope.of(context).unfocus();
    SupportAudioPlayer.active.value = null;
    setState(() {
      _voiceBusy = true;
      _error = null;
    });
    try {
      _recorder ??=
          widget.recorderFactory?.call() ?? DeviceSupportVoiceRecorder();
      await _recorder!.start(() => unawaited(_finishVoice()));
      if (!mounted) return;
      final lifecycle = WidgetsBinding.instance.lifecycleState;
      if (lifecycle == AppLifecycleState.hidden ||
          lifecycle == AppLifecycleState.paused ||
          lifecycle == AppLifecycleState.detached) {
        await _recorder!.cancel();
        return;
      }
      _recordingWatch.reset();
      _recordingWatch.start();
      setState(() => _recording = true);
      _recordingTimer = Timer.periodic(const Duration(milliseconds: 200), (_) {
        if (_recordingWatch.elapsed.inSeconds >= maxSupportAudioSeconds) {
          unawaited(_finishVoice());
        } else if (mounted) {
          setState(() {});
        }
      });
    } catch (error) {
      try {
        await _recorder?.cancel();
      } catch (_) {}
      if (mounted) {
        setState(() => _error = supportText(
            context,
            error is MicrophonePermissionDenied
                ? 'audioPermission'
                : 'audioError'));
      }
    } finally {
      if (mounted) setState(() => _voiceBusy = false);
    }
  }

  Future<void> _finishVoice({bool discard = false}) async {
    if (!_recording || _voiceBusy) return;
    _recordingTimer?.cancel();
    _recordingWatch.stop();
    setState(() => _voiceBusy = true);
    try {
      if (discard) {
        await _recorder!.cancel();
      } else {
        final audio = await _recorder!.stop();
        if (mounted) setState(() => _audio = audio);
      }
    } catch (_) {
      try {
        await _recorder?.cancel();
      } catch (_) {}
      if (mounted) setState(() => _error = supportText(context, 'audioError'));
    } finally {
      if (mounted) {
        setState(() {
          _recording = false;
          _voiceBusy = false;
        });
      }
    }
  }

  final _controller = TextEditingController();
  final _phoneController = TextEditingController();
  final _scrollController = ScrollController();
  bool _sending = false;
  bool _preparingImage = false;
  Uint8List? _image;
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
    WidgetsBinding.instance.removeObserver(this);
    _recordingTimer?.cancel();
    unawaited(_recorder?.dispose().catchError((Object _) {}));
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
    final messageText = text.isNotEmpty
        ? text
        : _audio != null
            ? supportText(context, 'audioMessage')
            : _image != null
                ? supportText(context, 'imageMessage')
                : '';
    final outgoingText = _showOptionalPhone && phone.isNotEmpty
        ? '${supportText(context, 'phoneMessageLabel')}: $phone\n\n$messageText'
        : messageText;
    if (_sending ||
        _preparingImage ||
        _recording ||
        _voiceBusy ||
        (text.isEmpty && _image == null && _audio == null) ||
        outgoingText.isEmpty ||
        outgoingText.length > 1000) {
      return;
    }
    setState(() {
      _sending = true;
      _error = null;
    });
    try {
      SupportAudioPlayer.active.value = null;
      if (_audio != null) {
        await widget.onSendAudio!(outgoingText, _audio!);
      } else {
        await widget.onSend(outgoingText, _image);
      }
      if (mounted) {
        _controller.clear();
        _phoneController.clear();
        setState(() {
          _image = null;
          _audio = null;
          _firstMessageSent = true;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _error = supportText(context, 'sendError'));
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  Future<void> _pickImage() async {
    if (_sending ||
        _preparingImage ||
        _recording ||
        _voiceBusy ||
        _audio != null) {
      return;
    }
    setState(() {
      _preparingImage = true;
      _error = null;
    });
    try {
      final image = await pickPreparedPrivateImage(pickImage: widget.pickImage);
      if (mounted && image != null) setState(() => _image = image);
    } catch (_) {
      if (mounted) setState(() => _error = supportText(context, 'imageError'));
    } finally {
      if (mounted) setState(() => _preparingImage = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final tokens = theme.designToken;
    return Column(
      children: [
        if (MediaQuery.viewInsetsOf(context).bottom == 0 &&
            MediaQuery.sizeOf(context).height >= 500)
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
                border:
                    Border.all(color: theme.alternate.withValues(alpha: .35)),
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
                itemBuilder: (context, index) => IgnorePointer(
                    ignoring: _recording || _voiceBusy,
                    child: _MessageBubble(
                      message: messages[index],
                      loadImage: widget.loadImage,
                      loadAudio: widget.loadAudio,
                    )),
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
                      enabled: !_sending && !_recording && !_voiceBusy,
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
                  if (_recording) ...[
                    Row(children: [
                      Icon(Icons.mic_rounded, color: theme.error),
                      SizedBox(width: tokens.spacing.sm),
                      Expanded(
                          child: Text(
                              '${supportText(context, 'recording')} ${supportAudioTime(_recordingWatch.elapsed)} / 0:30',
                              style: theme.bodyMedium)),
                      IconButton(
                          key: const ValueKey('support-cancel-recording'),
                          tooltip: supportText(context, 'removeAudio'),
                          onPressed: _voiceBusy
                              ? null
                              : () => _finishVoice(discard: true),
                          icon: Icon(Icons.delete_outline_rounded,
                              color: theme.secondaryText)),
                      IconButton(
                          key: const ValueKey('support-stop-recording'),
                          tooltip: supportText(context, 'stopAudio'),
                          onPressed: _voiceBusy ? null : _finishVoice,
                          icon: Icon(Icons.stop_circle_outlined,
                              color: theme.primary)),
                    ]),
                    SizedBox(height: tokens.spacing.sm),
                  ],
                  if (_audio != null) ...[
                    Row(children: [
                      Expanded(
                          child: IgnorePointer(
                              ignoring: _sending,
                              child: SupportAudioPlayer(
                                  key: ObjectKey(_audio),
                                  load: () async => _audio!))),
                      IconButton(
                          key: const ValueKey('support-remove-audio'),
                          tooltip: supportText(context, 'removeAudio'),
                          onPressed: _sending
                              ? null
                              : () => setState(() => _audio = null),
                          icon: Icon(Icons.delete_outline_rounded,
                              color: theme.secondaryText)),
                    ]),
                    SizedBox(height: tokens.spacing.sm),
                  ],
                  if (_image != null) ...[
                    _SelectedImagePreview(
                      bytes: _image!,
                      onRemove:
                          _sending ? null : () => setState(() => _image = null),
                    ),
                    SizedBox(height: tokens.spacing.sm),
                  ],
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Semantics(
                        button: true,
                        label: supportText(context, 'attachImage'),
                        child: IconButton(
                          key: const ValueKey('support-attach-image-button'),
                          onPressed: _sending ||
                                  _preparingImage ||
                                  _recording ||
                                  _voiceBusy ||
                                  _audio != null
                              ? null
                              : _pickImage,
                          tooltip: supportText(context, 'attachImage'),
                          style: IconButton.styleFrom(
                            foregroundColor: theme.primary,
                            disabledForegroundColor:
                                theme.secondaryText.withValues(alpha: .45),
                            minimumSize: const Size(48, 48),
                          ),
                          icon: _preparingImage
                              ? SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: theme.primary,
                                  ),
                                )
                              : const Icon(Icons.attach_file_rounded),
                        ),
                      ),
                      SizedBox(width: tokens.spacing.sm),
                      Expanded(
                        child: TextField(
                          key: const ValueKey('support-message-field'),
                          controller: _controller,
                          enabled: !_sending && !_recording && !_voiceBusy,
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
                      if (widget.onSendAudio != null)
                        Tooltip(
                            excludeFromSemantics: true,
                            message: supportText(context, 'recordAudio'),
                            child: Semantics(
                                button: true,
                                label: supportText(context, 'recordAudio'),
                                child: FlutterFlowIconButton(
                                  key: const ValueKey('support-record-audio'),
                                  buttonSize: 48,
                                  borderRadius: tokens.radius.full,
                                  icon: Icon(Icons.mic_none_rounded,
                                      color: theme.primary),
                                  disabledIconColor: theme.secondaryText
                                      .withValues(alpha: .45),
                                  onPressed: _sending ||
                                          _recording ||
                                          _voiceBusy ||
                                          _preparingImage ||
                                          _image != null ||
                                          _audio != null
                                      ? null
                                      : _startVoice,
                                ))),
                      Semantics(
                        button: true,
                        label:
                            supportText(context, _sending ? 'sending' : 'send'),
                        child: IconButton.filled(
                          key: const ValueKey('support-send-button'),
                          onPressed: _sending ||
                                  _recording ||
                                  _voiceBusy ||
                                  _preparingImage
                              ? null
                              : _send,
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
  const _MessageBubble(
      {required this.message, required this.loadImage, this.loadAudio});

  final SupportMessage message;
  final LoadSupportImage? loadImage;
  final Future<SupportAudio> Function(String messageId)? loadAudio;

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
            if (message.hasAudio) ...[
              SupportAudioPlayer(
                key: ValueKey('support-audio-${message.id}'),
                onPrimary: !fromAdmin,
                load: () =>
                    loadAudio?.call(message.id) ??
                    Future.error(const FormatException('audio-unavailable')),
              ),
              SizedBox(height: tokens.spacing.sm),
            ],
            if (message.hasImage) ...[
              _SupportMessageImage(
                key: ValueKey('support-image-${message.id}'),
                messageId: message.id,
                loadImage: loadImage,
              ),
              SizedBox(height: tokens.spacing.sm),
            ],
            if (!message.hasAudio || !isSupportAudioPlaceholder(message.text))
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

class _SelectedImagePreview extends StatelessWidget {
  const _SelectedImagePreview({required this.bytes, required this.onRemove});

  final Uint8List bytes;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final tokens = theme.designToken;
    return Align(
      alignment: Alignment.centerLeft,
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(tokens.radius.md),
            child: Image.memory(
              bytes,
              key: const ValueKey('support-selected-image'),
              width: 144,
              height: 112,
              fit: BoxFit.cover,
              semanticLabel: supportText(context, 'selectedImage'),
            ),
          ),
          Positioned(
            top: tokens.spacing.xs,
            right: tokens.spacing.xs,
            child: IconButton.filled(
              key: const ValueKey('support-remove-image-button'),
              onPressed: onRemove,
              tooltip: supportText(context, 'removeImage'),
              style: IconButton.styleFrom(
                backgroundColor: theme.secondaryBackground,
                foregroundColor: theme.primaryText,
                minimumSize: const Size(40, 40),
              ),
              icon: const Icon(Icons.close_rounded, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}

class _SupportMessageImage extends StatefulWidget {
  const _SupportMessageImage({
    super.key,
    required this.messageId,
    required this.loadImage,
  });

  final String messageId;
  final LoadSupportImage? loadImage;

  @override
  State<_SupportMessageImage> createState() => _SupportMessageImageState();
}

class _SupportMessageImageState extends State<_SupportMessageImage> {
  late Future<Uint8List> _image = _load();

  Future<Uint8List> _load() =>
      widget.loadImage?.call(widget.messageId) ??
      Future<Uint8List>.error(const FormatException('image-unavailable'));

  @override
  void didUpdateWidget(covariant _SupportMessageImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.messageId != oldWidget.messageId ||
        widget.loadImage != oldWidget.loadImage) {
      _image = _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final tokens = theme.designToken;
    return FutureBuilder<Uint8List>(
      future: _image,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.broken_image_outlined, size: 20, color: theme.error),
              SizedBox(width: tokens.spacing.xs),
              Flexible(
                child: Text(supportText(context, 'imageLoadError'),
                    style: theme.bodySmall.override(color: theme.error)),
              ),
            ],
          );
        }
        if (!snapshot.hasData) {
          return SizedBox(
            width: 48,
            height: 48,
            child: Padding(
              padding: EdgeInsets.all(tokens.spacing.sm),
              child: CircularProgressIndicator(
                  strokeWidth: 2, color: theme.primary),
            ),
          );
        }
        final bytes = snapshot.data!;
        return Semantics(
          button: true,
          label: supportText(context, 'openImage'),
          child: InkWell(
            onTap: () => _showSupportImage(context, bytes),
            borderRadius: BorderRadius.circular(tokens.radius.sm),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(tokens.radius.sm),
              child: Image.memory(
                bytes,
                width: 260,
                height: 220,
                fit: BoxFit.cover,
                semanticLabel: supportText(context, 'messageImage'),
              ),
            ),
          ),
        );
      },
    );
  }
}

Future<void> _showSupportImage(BuildContext context, Uint8List bytes) =>
    showDialog<void>(
      context: context,
      builder: (context) {
        final theme = FlutterFlowTheme.of(context);
        return AlertDialog(
          backgroundColor: theme.secondaryBackground,
          content: SizedBox(
            width: 760,
            child: InteractiveViewer(
              minScale: 1,
              maxScale: 5,
              child: Image.memory(
                bytes,
                fit: BoxFit.contain,
                semanticLabel: supportText(context, 'messageImage'),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(supportText(context, 'close')),
            ),
          ],
        );
      },
    );

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
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(spacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 44, color: theme.primary),
              SizedBox(height: spacing.md),
              Text(title,
                  textAlign: TextAlign.center, style: theme.titleMedium),
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
      ),
    );
  }
}
