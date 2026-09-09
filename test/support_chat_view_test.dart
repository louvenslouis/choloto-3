import 'package:choloto/flutter_flow/internationalization.dart';
import 'package:choloto/support/subscription_support_card.dart';
import 'package:choloto/support/support_chat_view.dart';
import 'package:choloto/support/support_conversation.dart';
import 'package:choloto/support/support_phone_gate.dart';
import 'package:choloto/support/support_phone_requirement.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

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
  test('support access requires a valid profile phone number', () {
    expect(
      resolveSupportAccess(
        hasAuthenticatedSession: false,
        userUid: '',
        profilePhoneNumber: null,
      ),
      SupportAccessState.signedOut,
    );
    expect(
      resolveSupportAccess(
        hasAuthenticatedSession: true,
        userUid: 'member',
        profilePhoneNumber: '',
      ),
      SupportAccessState.phoneRequired,
    );
    expect(
      resolveSupportAccess(
        hasAuthenticatedSession: true,
        userUid: 'member',
        profilePhoneNumber: '123',
      ),
      SupportAccessState.phoneRequired,
    );
    expect(
      resolveSupportAccess(
        hasAuthenticatedSession: true,
        userUid: 'member',
        profilePhoneNumber: '+509 37 00 00 00',
      ),
      SupportAccessState.ready,
    );
  });

  const phoneActions = {
    'fr': 'Ajouter mon numéro',
    'en': 'Add my phone number',
    'cr': 'Ajoute nimewo mwen',
  };
  for (final locale in const [Locale('fr'), Locale('en'), Locale('cr')]) {
    for (final variant in const [
      (320.0, Brightness.dark),
      (1280.0, Brightness.light),
    ]) {
      testWidgets(
        'phone gate fits ${locale.languageCode} at ${variant.$1.toInt()} px',
        (tester) async {
          tester.view.physicalSize = Size(variant.$1, 720);
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);
          var opened = false;

          await tester.pumpWidget(
            localizedApp(
              locale: locale,
              brightness: variant.$2,
              child: SupportPhoneGate(
                onAddPhone: () async {
                  opened = true;
                },
              ),
            ),
          );
          await tester.pumpAndSettle();

          expect(find.byKey(const ValueKey('support-phone-gate')), findsOne);
          expect(find.text(phoneActions[locale.languageCode]!), findsOneWidget);
          await tester.tap(
            find.byKey(const ValueKey('support-add-phone-button')),
          );
          await tester.pump();
          expect(opened, isTrue);
          expect(tester.takeException(), isNull);
        },
      );
    }
  }

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
            onSend: (_) async {},
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
        onSend: (value) async => sent = value,
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

  testWidgets('chat has localized empty and connection error states',
      (tester) async {
    await tester.pumpWidget(localizedApp(
      locale: const Locale('en'),
      brightness: Brightness.light,
      child: SupportChatView(
        messages: Stream.value(const []),
        onSend: (_) async {},
      ),
    ));
    await tester.pumpAndSettle();
    expect(find.text('Start the conversation'), findsOneWidget);

    await tester.pumpWidget(localizedApp(
      locale: const Locale('cr'),
      brightness: Brightness.light,
      child: SupportChatView(
        messages: Stream.error(StateError('offline')),
        onSend: (_) async {},
      ),
    ));
    await tester.pump();
    expect(find.textContaining('Nou pa ka chaje'), findsOneWidget);
  });
}
