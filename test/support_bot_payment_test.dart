import 'dart:async';
import 'package:choloto/support/support_bot.dart';
import 'package:choloto/support/support_bot_view.dart';
import 'package:choloto/support/support_chat_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'support_chat_view_test.dart' show localizedApp;

SupportBotConfig configuration(
        {int revision = 1, int amount = 250000, bool enabled = true}) =>
    SupportBotConfig(
        enabled: true,
        greeting: 'Choisir',
        revision: revision,
        nodes: const [
          SupportBotNode(
              id: 'pay',
              parent: '',
              label: 'MonCash',
              answer: 'Envoyez le reçu après le paiement.',
              paymentMethodId: 'moncash',
              requestImage: true)
        ],
        paymentMethods: [
          SupportBotPayment(
              id: 'moncash',
              name: 'MonCash',
              currency: 'HTG',
              amountMinor: amount,
              months: 1,
              account: 'test-account',
              recipient: 'Test beneficiary',
              enabled: enabled)
        ]);

void main() {
  testWidgets('chat routes proof button to the existing payment workflow',
      (tester) async {
    var payments = 0, images = 0, chatMessages = 0;
    await tester.pumpWidget(localizedApp(
        locale: const Locale('fr'),
        brightness: Brightness.light,
        child: Scaffold(
            body: SupportChatView(
                messages: Stream.value(const []),
                botConfig: Stream.value(configuration()),
                botPath: ['pay'],
                onPaymentProof: () => payments++,
                pickImage: () async {
                  images++;
                  return null;
                },
                onSend: (_, image) async {
                  chatMessages++;
                }))));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const ValueKey('bot-image')));
    await tester.tap(find.byKey(const ValueKey('bot-image')));
    await tester.pumpAndSettle();
    expect(payments, 1);
    expect(images, 0);
    expect(chatMessages, 0);
  });

  testWidgets('linked payment stays gated and published changes reach the bot',
      (tester) async {
    final stream = StreamController<SupportBotConfig>();
    addTearDown(stream.close);
    final path = ['pay'];
    var imagePicks = 0;
    var paymentProofOpens = 0;
    Widget view(bool signedIn) => localizedApp(
        locale: const Locale('fr'),
        brightness: Brightness.light,
        child: Scaffold(
            body: SingleChildScrollView(
                child: SupportBotView(
                    config: stream.stream,
                    path: path,
                    isSignedIn: signedIn,
                    onSignIn: () {},
                    onRequestImage: () => imagePicks++,
                    onPaymentProof: () => paymentProofOpens++,
                    onContact: (_) async {}))));
    await tester.pumpWidget(view(false));
    stream.add(configuration());
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('bot-payment-details')), findsNothing);
    expect(find.text('Se connecter'), findsOneWidget);
    await tester.pumpWidget(view(true));
    await tester.pumpAndSettle();
    expect(find.text('Prix: 2500.00 HTG'), findsOneWidget);
    expect(find.text('Compte: test-account'), findsOneWidget);
    expect(find.text('Bénéficiaire: Test beneficiary'), findsOneWidget);
    expect(find.byKey(const ValueKey('bot-image')), findsOneWidget);
    expect(find.text('Envoyer la preuve de paiement'), findsOneWidget);
    await tester.ensureVisible(find.byKey(const ValueKey('bot-image')));
    await tester.tap(find.byKey(const ValueKey('bot-image')));
    expect(paymentProofOpens, 1);
    expect(imagePicks, 0);
    stream.add(configuration(revision: 2, amount: 300000));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('bot-choice-pay')));
    await tester.pump();
    await tester.tap(find.text('Continuer'));
    await tester.pumpAndSettle();
    expect(find.text('Prix: 3000.00 HTG'), findsOneWidget);
    expect(find.text('Prix: 2500.00 HTG'), findsNothing);
    stream.add(configuration(revision: 3, enabled: false));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('bot-choice-pay')));
    await tester.pump();
    await tester.tap(find.text('Continuer'));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('bot-payment-details')), findsNothing);
    expect(find.byKey(const ValueKey('bot-image')), findsNothing);
    expect(find.textContaining('Ce moyen de paiement est indisponible.'),
        findsOneWidget);
  });
}
