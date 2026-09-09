import 'dart:typed_data';

import 'package:choloto/flutter_flow/internationalization.dart';
import 'package:choloto/support/subscription_support_card.dart';
import 'package:choloto/support/support_chat_view.dart';
import 'package:choloto/support/support_conversation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;

Widget localizedApp({
  required Locale locale,
  required Brightness brightness,
  required Widget child,
}) =>
    MaterialApp(
      locale: locale,
      supportedLocales: const [Locale('fr'), Locale('en'), Locale('cr')],
      localizationsDelegates: const [
        FFLocalizationsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        FallbackMaterialLocalizationDelegate(),
        FallbackCupertinoLocalizationDelegate(),
      ],
      theme: ThemeData(brightness: brightness),
      home: Scaffold(body: child),
    );

void main() {
  for (final locale in const [Locale('fr'), Locale('en'), Locale('cr')]) {
    for (final brightness in Brightness.values) {
      testWidgets(
          'subscription support card fits ${locale.languageCode} ${brightness.name}',
          (tester) async {
        tester.view.physicalSize = const Size(320, 640);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        await tester.pumpWidget(localizedApp(
          locale: locale,
          brightness: brightness,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [SubscriptionSupportCard(onOpen: () {})],
          ),
        ));
        await tester.pumpAndSettle();
        expect(find.byKey(const ValueKey('subscription-support-card')),
            findsOneWidget);
        expect(find.byKey(const ValueKey('open-subscription-support')),
            findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    }
  }

  for (final locale in const [Locale('fr'), Locale('en'), Locale('cr')]) {
    for (final width in const [320.0, 1280.0]) {
      testWidgets('chat fits ${locale.languageCode} at ${width.toInt()} pixels',
          (tester) async {
        tester.view.physicalSize = Size(width, 720);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        await tester.pumpWidget(localizedApp(
          locale: locale,
          brightness: width == 320 ? Brightness.dark : Brightness.light,
          child: SupportChatView(
            messages: Stream.value(const []),
            onSend: (_, __) async {},
          ),
        ));
        await tester.pumpAndSettle();
        expect(find.byKey(const ValueKey('support-message-field')),
            findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    }
  }

  testWidgets('chat displays both roles and sends a trimmed message',
      (tester) async {
    String? sent;
    final messages = [
      SupportMessage('u1', {
        'sender_uid': 'member',
        'sender_role': 'user',
        'text': 'Bonjour',
        'created_at': DateTime(2026, 9, 6, 10),
      }),
      SupportMessage('a1', {
        'sender_uid': 'admin',
        'sender_role': 'admin',
        'text': 'Bonjour, comment pouvons-nous aider ?',
        'created_at': DateTime(2026, 9, 6, 10, 5),
      }),
    ];
    await tester.pumpWidget(localizedApp(
      locale: const Locale('fr'),
      brightness: Brightness.dark,
      child: SupportChatView(
        messages: Stream.value(messages),
        onSend: (value, _) async => sent = value,
      ),
    ));
    await tester.pumpAndSettle();

    expect(find.text('Bonjour'), findsOneWidget);
    expect(find.text('Bonjour, comment pouvons-nous aider ?'), findsOneWidget);
    await tester.enterText(
        find.byKey(const ValueKey('support-message-field')), '  MonCash  ');
    await tester.tap(find.byKey(const ValueKey('support-send-button')));
    await tester.pump();
    expect(sent, 'MonCash');
  });

  testWidgets('guest optional phone is included only in the first chat message',
      (tester) async {
    String? sent;
    await tester.pumpWidget(localizedApp(
      locale: const Locale('fr'),
      brightness: Brightness.dark,
      child: SupportChatView(
        messages: Stream.value(const []),
        showOptionalPhoneOnFirstMessage: true,
        onSend: (value, _) async => sent = value,
      ),
    ));
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('support-optional-phone-field')),
      findsOneWidget,
    );
    await tester.enterText(
      find.byKey(const ValueKey('support-optional-phone-field')),
      '+509 37 00 00 00',
    );
    await tester.enterText(
      find.byKey(const ValueKey('support-message-field')),
      'Je veux m’abonner',
    );
    await tester.tap(find.byKey(const ValueKey('support-send-button')));
    await tester.pump();

    expect(sent, 'Téléphone: +509 37 00 00 00\n\nJe veux m’abonner');
    expect(
      find.byKey(const ValueKey('support-optional-phone-field')),
      findsNothing,
    );
  });

  testWidgets('guest can send the first message without a phone',
      (tester) async {
    String? sent;
    await tester.pumpWidget(localizedApp(
      locale: const Locale('cr'),
      brightness: Brightness.light,
      child: SupportChatView(
        messages: Stream.value(const []),
        showOptionalPhoneOnFirstMessage: true,
        onSend: (value, _) async => sent = value,
      ),
    ));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const ValueKey('support-message-field')),
      'Mwen bezwen èd',
    );
    await tester.tap(find.byKey(const ValueKey('support-send-button')));
    await tester.pump();

    expect(sent, 'Mwen bezwen èd');
  });

  testWidgets('chat has localized empty and connection error states',
      (tester) async {
    await tester.pumpWidget(localizedApp(
      locale: const Locale('en'),
      brightness: Brightness.light,
      child: SupportChatView(
        messages: Stream.value(const []),
        onSend: (_, __) async {},
      ),
    ));
    await tester.pumpAndSettle();
    expect(find.text('Start the conversation'), findsOneWidget);

    await tester.pumpWidget(localizedApp(
      locale: const Locale('cr'),
      brightness: Brightness.light,
      child: SupportChatView(
        messages: Stream.error(StateError('offline')),
        onSend: (_, __) async {},
      ),
    ));
    await tester.pump();
    expect(find.textContaining('Nou pa ka chaje'), findsOneWidget);
  });

  testWidgets('paperclip prepares, previews and sends an image without text',
      (tester) async {
    String? sentText;
    Uint8List? sentImage;
    final source = img.encodePng(img.Image(width: 40, height: 30));
    await tester.pumpWidget(localizedApp(
      locale: const Locale('fr'),
      brightness: Brightness.dark,
      child: SupportChatView(
        messages: Stream.value(const []),
        pickImage: () async => source,
        onSend: (text, image) async {
          sentText = text;
          sentImage = image;
        },
      ),
    ));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('support-attach-image-button')),
        findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('support-attach-image-button')));
    await tester.runAsync(() async {
      await Future<void>.delayed(const Duration(milliseconds: 300));
    });
    await tester.pumpAndSettle();

    expect(
        find.byKey(const ValueKey('support-selected-image')), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('support-send-button')));
    await tester.pumpAndSettle();

    expect(sentText, 'Photo');
    expect(sentImage, isNotNull);
    expect(img.decodeJpg(sentImage!), isNotNull);
    expect(find.byKey(const ValueKey('support-selected-image')), findsNothing);
  });

  testWidgets('chat renders an attached image from the private loader',
      (tester) async {
    final encoded =
        Uint8List.fromList(img.encodeJpg(img.Image(width: 32, height: 24)));
    await tester.pumpWidget(localizedApp(
      locale: const Locale('en'),
      brightness: Brightness.light,
      child: SupportChatView(
        messages: Stream.value([
          SupportMessage('image-1', {
            'sender_uid': 'member',
            'sender_role': 'user',
            'text': 'Photo',
            'attachment_type': 'image',
            'created_at': DateTime(2026, 9, 8),
          }),
        ]),
        loadImage: (messageId) async {
          expect(messageId, 'image-1');
          return encoded;
        },
        onSend: (_, __) async {},
      ),
    ));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('support-image-image-1')), findsOneWidget);
    expect(find.text('Photo'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
