import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart';
// ignore: implementation_imports
import 'package:google_fonts/src/google_fonts_base.dart' as font_testing;
import 'package:image/image.dart' as img;
import 'package:choloto/support/support_bot.dart';
import 'package:choloto/support/support_bot_view.dart';
import 'package:choloto/support/support_chat_view.dart';
import 'package:choloto/support/support_conversation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'support_chat_view_test.dart' show localizedApp;

const config = SupportBotConfig(enabled: true, greeting: 'Bonjour', nodes: [
  SupportBotNode(
      id: 'vip', parent: '', label: 'VIP', answer: 'Choisir le pays'),
  SupportBotNode(
      id: 'haiti', parent: 'vip', label: 'Ayiti', answer: 'Paiement mobile'),
  SupportBotNode(
      id: 'renew', parent: '', label: 'Renouveler', answer: 'Renouvellement'),
]);
Widget app(Stream<SupportBotConfig> stream,
        Future<void> Function(String) contact) =>
    localizedApp(
        locale: const Locale('fr'),
        brightness: Brightness.light,
        child: Scaffold(
            body: SingleChildScrollView(
                child: SupportBotView(config: stream, onContact: contact))));

class _BotTestFonts extends Fake implements AssetManifest {
  @override
  List<String> listAssets() => ['__bot_test_fonts/Inter-Regular.ttf'];
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    final font = await rootBundle.load(
        'assets/fonts/GoogleSansFlex-VariableFont_GRAD,ROND,opsz,slnt,wdth,wght.ttf');
    font_testing.assetManifest = _BotTestFonts();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMessageHandler('flutter/assets', (message) async {
      final path = utf8.decode(message!.buffer.asUint8List());
      if (path.startsWith('__bot_test_fonts/')) return font;
      return ByteData.sublistView(
          File('build/unit_test_assets/$path').readAsBytesSync());
    });
  });
  testWidgets(
      'protected image step requires a real sign in and resumes after auth',
      (tester) async {
    final path = <String>[];
    var signIns = 0;
    var images = 0;
    const protected =
        SupportBotConfig(enabled: true, greeting: 'Bonjour', nodes: [
      SupportBotNode(
          id: 'receipt',
          parent: '',
          label: 'Reçu',
          answer: 'Envoyer le reçu',
          requiresAuth: true,
          requestImage: true)
    ]);
    final stream = Stream.value(protected);
    Widget view(bool signedIn) => localizedApp(
        locale: const Locale('fr'),
        brightness: Brightness.light,
        child: Scaffold(
            body: SupportBotView(
                config: stream,
                path: path,
                isSignedIn: signedIn,
                onSignIn: () => signIns++,
                onRequestImage: () => images++,
                onContact: (_) async {})));
    await tester.pumpWidget(view(false));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Reçu'));
    await tester.pump();
    await tester.tap(find.text('Continuer'));
    await tester.pumpAndSettle();
    expect(find.text('Envoyer le reçu'), findsNothing);
    expect(find.byKey(const ValueKey('bot-image')), findsNothing);
    await tester.tap(find.text('Se connecter'));
    expect(signIns, 1);
    await tester.pumpWidget(view(true));
    await tester.pumpAndSettle();
    expect(find.text('Envoyer le reçu'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('bot-image')));
    expect(images, 1);
  });
  testWidgets('image acknowledgement follows successful send only',
      (tester) async {
    var fail = true;
    final source = img.encodePng(img.Image(width: 40, height: 30));
    await tester.pumpWidget(localizedApp(
        locale: const Locale('fr'),
        brightness: Brightness.light,
        child: Scaffold(
            body: SupportChatView(
                messages: Stream.value(const []),
                botConfig: Stream.value(config),
                pickImage: () async => source,
                onSend: (_, image) async {
                  if (fail) throw StateError('offline');
                }))));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('support-attach-image-button')));
    await tester.runAsync(() async {
      await Future<void>.delayed(const Duration(milliseconds: 300));
    });
    await tester.pumpAndSettle();
    expect(find.textContaining('Image envoyée.'), findsNothing);
    await tester.tap(find.byKey(const ValueKey('support-send-button')));
    await tester.pumpAndSettle();
    expect(find.textContaining('Image envoyée.'), findsNothing);
    expect(
        find.byKey(const ValueKey('support-selected-image')), findsOneWidget);
    fail = false;
    await tester.tap(find.byKey(const ValueKey('support-send-button')));
    await tester.pumpAndSettle();
    expect(find.textContaining('Image envoyée.'), findsOneWidget);
    expect(find.byKey(const ValueKey('support-selected-image')), findsNothing);
  });
  testWidgets(
      'received image waiting state survives reload until a human replies',
      (tester) async {
    final messages = StreamController<List<SupportMessage>>();
    addTearDown(messages.close);
    const receipt = SupportMessage('receipt',
        {'text': 'Photo', 'attachment_type': 'image', 'sender_role': 'user'});
    await tester.pumpWidget(localizedApp(
        locale: const Locale('fr'),
        brightness: Brightness.light,
        child: Scaffold(
            body: SupportChatView(
                messages: messages.stream,
                botConfig: Stream.value(config),
                onSend: (_, image) async {}))));
    messages.add([receipt]);
    await tester.pumpAndSettle();
    expect(find.textContaining('Image envoyée.'), findsOneWidget);
    messages.add([
      receipt,
      const SupportMessage('human',
          {'text': 'Nous vérifions votre reçu', 'sender_role': 'admin'})
    ]);
    await tester.pumpAndSettle();
    expect(find.textContaining('Image envoyée.'), findsNothing);
    expect(find.text('Nous vérifions votre reçu'), findsOneWidget);
  });

  testWidgets(
      'bot fits narrow chat and retains handoff state when a message arrives',
      (tester) async {
    tester.view.physicalSize = const Size(320, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final messages = StreamController<List<SupportMessage>>();
    addTearDown(messages.close);
    await tester.pumpWidget(localizedApp(
        locale: const Locale('fr'),
        brightness: Brightness.dark,
        child: Scaffold(
            body: SupportChatView(
                messages: messages.stream,
                botConfig: Stream.value(config),
                onSend: (text, image) async {
                  messages.add([
                    SupportMessage(
                        'handoff', {'text': text, 'sender_role': 'user'})
                  ]);
                }))));
    messages.add([]);
    await tester.pumpAndSettle();
    await tester.tap(find.text('VIP'));
    await tester.pump();
    await tester.ensureVisible(find.byKey(const ValueKey('bot-continue')));
    await tester.tap(find.byKey(const ValueKey('bot-continue')));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const ValueKey('bot-contact')));
    await tester.tap(find.byKey(const ValueKey('bot-contact')));
    await tester.pumpAndSettle();
    expect(find.text('Demande envoyée à l’équipe.'), findsOneWidget);
    expect(find.textContaining('Mwen bezwen pale ak ekip'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
      'exclusive checkbox choices navigate, return and send context once',
      (tester) async {
    final sent = <String>[];
    await tester.pumpWidget(app(Stream.value(config), (text) async {
      sent.add(text);
    }));
    await tester.pumpAndSettle();
    expect(
        tester
            .widget<FilledButton>(find.byKey(const ValueKey('bot-continue')))
            .onPressed,
        isNull);
    await tester.tap(find.text('Renouveler'));
    await tester.pump();
    await tester.tap(find.text('VIP'));
    await tester.pump();
    expect(
        tester
            .widget<CheckboxListTile>(
                find.byKey(const ValueKey('bot-choice-renew')))
            .value,
        false);
    await tester.tap(find.text('Continuer'));
    await tester.pumpAndSettle();
    expect(find.text('Choisir le pays'), findsOneWidget);
    await tester.tap(find.text('Ayiti'));
    await tester.pump();
    await tester.tap(find.text('Continuer'));
    await tester.pumpAndSettle();
    expect(find.text('Paiement mobile'), findsOneWidget);
    await tester.tap(find.text('Retour'));
    await tester.pumpAndSettle();
    expect(find.text('Choisir le pays'), findsOneWidget);
    await tester.tap(find.text('Parler à l’équipe'));
    await tester.pumpAndSettle();
    expect(sent.single, contains('VIP'));
    expect(find.text('Demande envoyée à l’équipe.'), findsOneWidget);
    expect(find.text('Parler à l’équipe'), findsNothing);
  });
  testWidgets('publication resets obsolete path and disabling hides bot',
      (tester) async {
    final stream = StreamController<SupportBotConfig>();
    addTearDown(stream.close);
    await tester.pumpWidget(app(stream.stream, (_) async {}));
    stream.add(config);
    await tester.pumpAndSettle();
    await tester.tap(find.text('VIP'));
    await tester.pump();
    await tester.tap(find.text('Continuer'));
    await tester.pumpAndSettle();
    stream.add(const SupportBotConfig(
        enabled: true,
        greeting: 'Nouvelle question',
        nodes: [
          SupportBotNode(
              id: 'new', parent: '', label: 'Nouveau', answer: 'Réponse')
        ],
        revision: 1));
    await tester.pumpAndSettle();
    expect(find.text('Nouvelle question'), findsOneWidget);
    expect(find.text('Choisir le pays'), findsNothing);
    stream.add(const SupportBotConfig(
        enabled: false, greeting: 'Bonjour', nodes: [], revision: 2));
    await tester.pumpAndSettle();
    expect(find.text('Assistant CHOLOTO'), findsNothing);
  });
  testWidgets(
      'configuration and send failures preserve human fallback and retry',
      (tester) async {
    var calls = 0;
    await tester.pumpWidget(app(Stream.error(StateError('offline')), (_) async {
      if (++calls == 1) throw StateError('offline');
    }));
    await tester.pumpAndSettle();
    expect(find.text('Assistant indisponible. Vous pouvez écrire à l’équipe.'),
        findsOneWidget);
    await tester.tap(find.text('Parler à l’équipe'));
    await tester.pumpAndSettle();
    expect(find.text('Envoi impossible. Réessayez.'), findsOneWidget);
    await tester.tap(find.text('Parler à l’équipe'));
    await tester.pumpAndSettle();
    expect(calls, 2);
    expect(find.text('Demande envoyée à l’équipe.'), findsOneWidget);
  });
}
