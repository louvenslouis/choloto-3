import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:choloto/flutter_flow/internationalization.dart';
import 'package:choloto/payments/payment_request.dart';
import 'package:choloto/payments/payment_requests_widget.dart';
import 'package:choloto/payments/payment_widgets.dart';
import 'package:choloto/payments/proof_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;

Widget app(Widget child, {String locale = 'fr', bool dark = false}) =>
    MaterialApp(
        locale: Locale(locale),
        supportedLocales: const [Locale('fr'), Locale('en'), Locale('cr')],
        localizationsDelegates: const [
          FFLocalizationsDelegate(),
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          FallbackMaterialLocalizationDelegate(),
          FallbackCupertinoLocalizationDelegate()
        ],
        theme: ThemeData(brightness: dark ? Brightness.dark : Brightness.light),
        home: Scaffold(
            body: SingleChildScrollView(
                child: Center(
                    child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 760),
                        child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: child))))));

Uint8List receiptImage() {
  final image = img.Image(width: 720, height: 1000);
  img.fill(image, color: img.ColorRgb8(245, 245, 240));
  img.drawString(image, 'TRANSFERT MONCASH',
      font: img.arial48, x: 35, y: 80, color: img.ColorRgb8(20, 20, 20));
  img.drawString(image, '2000 GDS / MonCash',
      font: img.arial48, x: 35, y: 180, color: img.ColorRgb8(20, 20, 20));
  img.drawString(image, 'Reference: MC-123456',
      font: img.arial24, x: 35, y: 280, color: img.ColorRgb8(20, 20, 20));
  return img.encodePng(image);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    if (const bool.fromEnvironment('CAPTURE_PAYMENT_UI')) {
      await File('/tmp/choloto-test-receipt.jpg')
          .writeAsBytes(preparePaymentProof(receiptImage()));
      final icons = FontLoader('MaterialIcons')
        ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'));
      await icons.load();
      final title = FontLoader('Google sans flex')
        ..addFont(rootBundle.load(
            'assets/fonts/GoogleSansFlex-VariableFont_GRAD,ROND,opsz,slnt,wdth,wght.ttf'));
      await title.load();
      final data = ByteData.sublistView(
          await File('/tmp/choloto-inter.ttf').readAsBytes());
      for (final family in [
        'Inter',
        'Inter_regular',
        'Inter_medium',
        'Inter_semiBold',
        'Inter_bold'
      ]) {
        final loader = FontLoader(family)..addFont(Future.value(data));
        await loader.load();
      }
    }
  });
  test('proof conversion produces bounded JPEG and rejects invalid content',
      () {
    final encoded = preparePaymentProof(receiptImage());
    expect(encoded.length, lessThanOrEqualTo(maxProofBytes));
    expect(img.decodeJpg(encoded), isNotNull);
    expect(() => preparePaymentProof(Uint8List.fromList([1, 2, 3])),
        throwsFormatException);
    expect(() => preparePaymentProof(Uint8List(12 * 1024 * 1024 + 1)),
        throwsFormatException);
    final big = img.Image(width: 4000, height: 1000);
    final resized = img.decodeJpg(preparePaymentProof(img.encodePng(big)))!;
    expect(resized.width, 1600);
    expect(resized.height, 400);
  });
  test(
      'amount accepts local decimals and rejects nonfinite / zero / excessive values',
      () {
    expect(parsePaymentAmount('2000,50'), 2000.5);
    for (final value in [
      'NaN',
      'Infinity',
      '0',
      '-1',
      '0.001',
      '1000000000',
      'abc'
    ]) {
      expect(parsePaymentAmount(value), isNull, reason: value);
    }
  });
  for (final locale in ['fr', 'en', 'cr']) {
    for (final dark in [false, true]) {
      for (final width in [320.0, 1440.0]) {
        testWidgets('form + decisions $locale dark=$dark width=$width',
            (tester) async {
          tester.view.physicalSize = Size(width, 900);
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);
          await tester.pumpWidget(app(
              RepaintBoundary(
                  key: const ValueKey('capture'),
                  child: Column(children: [
                    PaymentSubmissionForm(onSubmit: (_, __) async {}),
                    for (final status in ['pending', 'approved', 'rejected'])
                      Padding(
                          padding: const EdgeInsets.only(top: 16),
                          child: PaymentRequestCard(
                              request: PaymentRequest('test', {
                                'user_uid': 'user-test',
                                'status': status,
                                if (status == 'rejected')
                                  'rejection_reason':
                                      'Le numéro de transaction est illisible. Veuillez envoyer une nouvelle photo.',
                                if (status == 'approved') ...{
                                  'amount': 2000,
                                  'currency': 'GDS',
                                  'payment_method': 'moncash',
                                  'transaction_id': 'proof_test',
                                  'new_end_sub': DateTime(2026, 10, 5)
                                },
                              }),
                              onOpen: () {})),
                  ])),
              locale: locale,
              dark: dark));
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
          expect(find.byType(TextFormField), findsOneWidget);
          expect(find.byType(DropdownButtonFormField<String>), findsNothing);
          if (const bool.fromEnvironment('CAPTURE_PAYMENT_UI')) {
            final boundary = tester.renderObject<RenderRepaintBoundary>(
                find.byKey(const ValueKey('capture')));
            await tester.runAsync(() async {
              final image = await boundary.toImage(pixelRatio: 1);
              final bytes =
                  await image.toByteData(format: ui.ImageByteFormat.png);
              await File(
                      '/tmp/choloto-proof-$locale-$dark-${width.toInt()}.png')
                  .writeAsBytes(bytes!.buffer.asUint8List());
              image.dispose();
            });
          }
        });
      }
    }
  }
  testWidgets(
      'photo alone, busy protection, failure and retry with optional message',
      (tester) async {
    var calls = 0;
    Completer<void> sending = Completer<void>();
    await tester.pumpWidget(app(PaymentSubmissionForm(
        pickImage: () async => receiptImage(),
        onSubmit: (bytes, note) {
          calls++;
          expect(note, calls == 1 ? '' : 'Transfert envoyé');
          expect(img.decodeJpg(bytes), isNotNull);
          return sending.future;
        })));
    await tester.tap(find.byKey(const ValueKey('send-proof')));
    expect(calls, 0);
    await tester.tap(find.byKey(const ValueKey('choose-proof')));
    await tester.runAsync(() async {
      await Future<void>.delayed(const Duration(seconds: 1));
    });
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const ValueKey('send-proof')));
    await tester.tap(find.byKey(const ValueKey('send-proof')));
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('send-proof')));
    expect(calls, 1);
    sending.completeError(StateError('offline'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Vérifiez votre connexion'), findsOneWidget);
    sending = Completer<void>();
    await tester.enterText(
        find.byKey(const ValueKey('payment-message')), ' Transfert envoyé ');
    await tester.ensureVisible(find.byKey(const ValueKey('send-proof')));
    await tester.tap(find.byKey(const ValueKey('send-proof')));
    await tester.pump();
    expect(calls, 2);
    sending.complete();
    await tester.pumpAndSettle();
    expect(find.text('Photo envoyée.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
