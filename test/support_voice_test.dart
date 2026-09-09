import 'dart:async';
import 'dart:typed_data';
import 'package:audioplayers/audioplayers.dart';
import 'package:choloto/support/support_audio.dart';
import 'package:choloto/support/support_audio_player.dart';
import 'package:choloto/support/support_chat_view.dart';
import 'package:choloto/support/support_conversation.dart';
import 'package:choloto/support/support_voice_recorder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'support_chat_view_test.dart' show localizedApp;
import 'support/memory_firestore.dart';

class FakeVoiceRecorder implements SupportVoiceRecorder {
  int starts = 0, stops = 0, cancels = 0, disposals = 0;
  bool denied = false;
  Completer<void>? startWait;
  @override
  Future<void> start(void Function() onLimit) async {
    starts++;
    if (denied) throw MicrophonePermissionDenied();
    await startWait?.future;
  }

  @override
  Future<SupportAudio> stop() async {
    stops++;
    return SupportAudio.fromPcm(Uint8List(16000));
  }

  @override
  Future<void> cancel() async {
    cancels++;
  }

  @override
  Future<void> dispose() async {
    disposals++;
  }
}

class FakeAudioPlayer extends Fake implements AudioPlayer {
  final positions = StreamController<Duration>.broadcast();
  final completions = StreamController<void>.broadcast();
  int plays = 0, pauses = 0, disposals = 0;
  @override
  Stream<Duration> get onPositionChanged => positions.stream;
  @override
  Stream<void> get onPlayerComplete => completions.stream;
  @override
  Stream<AudioEvent> get eventStream => const Stream.empty();
  @override
  Future<void> play(Source source,
      {double? volume,
      double? balance,
      AudioContext? ctx,
      Duration? position,
      PlayerMode? mode}) async {
    expect(source, isA<BytesSource>());
    expect((source as BytesSource).mimeType, 'audio/wav');
    plays++;
  }

  @override
  Future<void> pause() async {
    pauses++;
  }

  @override
  Future<void> dispose() async {
    disposals++;
  }
}

void main() {
  test('WAV/Base64 roundtrip and invalid audio validation', () {
    final audio = SupportAudio.fromPcm(Uint8List(16000));
    expect(audio.durationMs, 1000);
    expect(SupportAudio.fromData(audio.toData()).bytes, audio.bytes);
    expect(
        () => SupportAudio.fromPcm(Uint8List(480002)), throwsFormatException);
    expect(() => SupportAudio.fromPcm(Uint8List(0)), throwsFormatException);
    expect(() => SupportAudio.fromData({...audio.toData(), 'duration_ms': 2}),
        throwsFormatException);
    expect(
        () => SupportAudio.fromData(
            {...audio.toData(), 'mime_type': 'text/html'}),
        throwsFormatException);
    expect(() => SupportAudio.fromData({...audio.toData(), 'byte_length': 20}),
        throwsFormatException);
    expect(() => SupportAudio.fromData(null), throwsFormatException);
    final corrupt = Uint8List.fromList(audio.bytes)..[0] = 0;
    expect(() => SupportAudio(corrupt, 1000), throwsFormatException);
    expect(SupportAudio.fromPcm(Uint8List(480000)).durationMs, 30000);
  });

  for (final guest in [false, true]) {
    test('first voice transaction + exact retry, guest=$guest', () async {
      final db = MemoryFirestore();
      final repo = SupportConversationRepository(firestore: db);
      final uid = guest ? '00b18a16-4935-4de7-9bc5-dfa33bc8a644' : 'member';
      if (!guest) db.rows['user/$uid'] = {'email': 'historical@example.test'};
      final audio = SupportAudio.fromPcm(Uint8List(16000));
      Future<void> send(SupportAudio value) => guest
          ? repo.sendGuestMessage(
              guestId: uid,
              text: 'Note vocale',
              audio: value,
              messageId: 'voice')
          : repo.sendUserMessage(
              userUid: uid,
              text: 'Note vocale',
              audio: value,
              messageId: 'voice');
      await send(audio);
      final base = 'support_conversations/$uid';
      expect(db.reads, [
        base,
        '$base/messages/voice',
        '$base/messages/voice/attachments/audio',
        if (!guest) 'user/$uid'
      ]);
      expect(db.rows['$base/messages/voice']!['attachment_type'], 'audio');
      expect(db.rows['$base/messages/voice/attachments/audio'], audio.toData());
      expect(db.rows[base]!['last_message'], 'Note vocale');
      await send(audio);
      db.rows[base]!['last_message_id'] = 'admin-followup';
      await send(audio);
      expect(db.rows.keys.where((p) => p.contains('/messages/')), hasLength(2));
      await expectLater(
          send(SupportAudio.fromPcm(Uint8List(32000))), throwsStateError);
      await expectLater(
          repo.sendUserMessage(
              userUid: uid, text: 'both', image: Uint8List(4), audio: audio),
          throwsArgumentError);
    });
  }

  Future<void> mount(WidgetTester tester, FakeVoiceRecorder recorder,
      {Future<void> Function(String, SupportAudio)? send,
      Locale locale = const Locale('fr'),
      Brightness brightness = Brightness.dark}) async {
    await tester.pumpWidget(localizedApp(
        locale: locale,
        brightness: brightness,
        child: SupportChatView(
          messages: Stream.value(const []),
          recorderFactory: () => recorder,
          onSend: (_, __) async {},
          onSendAudio: send ?? (_, __) async {},
        )));
    await tester.pumpAndSettle();
  }

  for (final locale in ['fr', 'en', 'cr']) {
    for (final brightness in Brightness.values) {
      for (final width in [320.0, 1280.0]) {
        testWidgets('voice record/preview fits $locale $brightness $width',
            (tester) async {
          tester.view.physicalSize = Size(width, 800);
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);
          final recorder = FakeVoiceRecorder();
          await mount(tester, recorder,
              locale: Locale(locale), brightness: brightness);
          await tester.tap(find.byKey(const ValueKey('support-record-audio')));
          await tester.pump();
          expect(find.byKey(const ValueKey('support-stop-recording')),
              findsOneWidget);
          expect(
              tester
                  .widget<IconButton>(
                      find.byKey(const ValueKey('support-send-button')))
                  .onPressed,
              isNull);
          expect(tester.takeException(), isNull);
          await tester
              .tap(find.byKey(const ValueKey('support-stop-recording')));
          await tester.pumpAndSettle();
          expect(find.byType(SupportAudioPlayer), findsOneWidget);
          expect(tester.takeException(), isNull);
          await tester.pumpWidget(const SizedBox());
          await tester.pump();
        });
      }
    }
  }

  testWidgets('voice-only send failure preserves draft for retry',
      (tester) async {
    final recorder = FakeVoiceRecorder();
    int attempts = 0;
    await mount(tester, recorder, send: (text, audio) async {
      expect(text, 'Note vocale');
      expect(audio.durationMs, 1000);
      if (++attempts == 1) throw StateError('offline');
    });
    await tester.tap(find.byKey(const ValueKey('support-record-audio')));
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('support-stop-recording')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('support-send-button')));
    await tester.pumpAndSettle();
    expect(find.textContaining('Message non envoyé'), findsOneWidget);
    expect(find.byType(SupportAudioPlayer), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('support-send-button')));
    await tester.pumpAndSettle();
    expect(attempts, 2);
    expect(find.byType(SupportAudioPlayer), findsNothing);
  });

  testWidgets('cancel, background stop, remove and microphone denial',
      (tester) async {
    final recorder = FakeVoiceRecorder();
    await mount(tester, recorder);
    await tester.tap(find.byKey(const ValueKey('support-record-audio')));
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('support-cancel-recording')));
    await tester.pumpAndSettle();
    expect(recorder.cancels, 1);
    expect(find.byType(SupportAudioPlayer), findsNothing);
    await tester.tap(find.byKey(const ValueKey('support-record-audio')));
    await tester.pump();
    // Trigger lifecycle stop rather than relying on real Stopwatch in fake time.
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    await tester.pumpAndSettle();
    expect(recorder.stops, 1);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.tap(find.byKey(const ValueKey('support-remove-audio')));
    await tester.pumpAndSettle();
    recorder.denied = true;
    await tester.tap(find.byKey(const ValueKey('support-record-audio')));
    await tester.pumpAndSettle();
    expect(find.textContaining('Autorisez le microphone'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
    await tester.pump();
    expect(recorder.disposals, 1);
  });

  testWidgets('audio load failure is localized and can be retried',
      (tester) async {
    int loads = 0;
    await tester.pumpWidget(localizedApp(
        locale: const Locale('en'),
        brightness: Brightness.light,
        child: SupportAudioPlayer(load: () async {
          loads++;
          throw StateError('offline');
        })));
    await tester.tap(find.byKey(const ValueKey('support-audio-play')));
    await tester.pumpAndSettle();
    expect(find.textContaining('Unable to play'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('support-audio-play')));
    await tester.pumpAndSettle();
    expect(loads, 2);
  });
  testWidgets('play/pause, progress, completion and single active audio',
      (tester) async {
    final first = FakeAudioPlayer(), second = FakeAudioPlayer();
    final audio = SupportAudio.fromPcm(Uint8List(16000));
    await tester.pumpWidget(localizedApp(
        locale: const Locale('fr'),
        brightness: Brightness.dark,
        child: Column(children: [
          SupportAudioPlayer(
              load: () async => audio, playerFactory: () => first),
          SupportAudioPlayer(
              load: () async => audio, playerFactory: () => second),
        ])));
    final buttons = find.byKey(const ValueKey('support-audio-play'));
    await tester.tap(buttons.at(0));
    await tester.pumpAndSettle();
    expect(first.plays, 1);
    first.positions.add(const Duration(milliseconds: 500));
    await tester.pump();
    await tester.pump();
    expect(
        tester
            .widget<LinearProgressIndicator>(
                find.byType(LinearProgressIndicator).first)
            .value,
        .5);
    await tester.tap(buttons.at(1));
    await tester.pumpAndSettle();
    expect(first.pauses, 1);
    expect(second.plays, 1);
    await tester.tap(buttons.at(1));
    await tester.pumpAndSettle();
    expect(second.pauses, 1);
    await tester.tap(buttons.at(1));
    await tester.pumpAndSettle();
    second.completions.add(null);
    await tester.pump();
    await tester.pump();
    expect(find.byIcon(Icons.pause_rounded), findsNothing);
    await tester.pumpWidget(const SizedBox());
    await tester.pump();
    expect(first.disposals, 1);
    expect(second.disposals, 1);
  });
}
