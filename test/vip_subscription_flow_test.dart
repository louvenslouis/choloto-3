import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:choloto/flutter_flow/internationalization.dart';
import 'package:choloto/flutter_flow/flutter_flow_theme.dart';
import 'package:choloto/payments/payment_requests_widget.dart';
import 'package:choloto/payments/vip_payment_options.dart';
import 'package:choloto/settings/devenir_v_i_p/devenir_v_i_p_widget.dart';
import 'package:choloto/support/support_bot.dart';
import 'package:firebase_core/firebase_core.dart';
// ignore: depend_on_referenced_packages
import 'package:firebase_core_platform_interface/test.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
// ignore: implementation_imports
import 'package:google_fonts/src/google_fonts_base.dart' as font_testing;

class _TestFontManifest extends Fake implements AssetManifest {
  @override
  List<String> listAssets() => [
        '__test_fonts/Inter-Regular.ttf',
        '__test_fonts/Inter-Light.ttf',
        '__test_fonts/Inter-Medium.ttf',
        '__test_fonts/Inter-Black.ttf',
        '__test_fonts/Inter-SemiBold.ttf',
      ];
}

Widget localizedApp(Widget child,
    {required String language, required bool dark}) {
  return MaterialApp(
    locale: Locale(language),
    supportedLocales: const [Locale('fr'), Locale('en'), Locale('cr')],
    localizationsDelegates: const [
      FFLocalizationsDelegate(),
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
      FallbackMaterialLocalizationDelegate(),
      FallbackCupertinoLocalizationDelegate(),
    ],
    theme: ThemeData(brightness: dark ? Brightness.dark : Brightness.light),
    home: Scaffold(
      body: SingleChildScrollView(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: child,
            ),
          ),
        ),
      ),
    ),
  );
}

SupportBotConfig prices({int amount = 250000, bool enabled = true}) =>
    SupportBotConfig(
      enabled: true,
      greeting: 'VIP',
      nodes: const [],
      paymentMethods: [
        SupportBotPayment(
          id: 'moncash',
          name: 'MonCash',
          currency: 'HTG',
          amountMinor: amount,
          months: 3,
          account: '50912345678',
          recipient: 'CHOLOTO',
          enabled: enabled,
        ),
        const SupportBotPayment(
          id: 'natcash',
          name: 'NatCash',
          currency: 'HTG',
          amountMinor: 100000,
          months: 1,
          account: '50998765432',
          recipient: 'CHOLOTO',
          enabled: false,
        ),
      ],
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setupFirebaseCoreMocks();
  setUpAll(() async {
    await Firebase.initializeApp();
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    messenger.setMockMessageHandler(
      'dev.flutter.pigeon.firebase_analytics_platform_interface.FirebaseAnalyticsHostApi.logEvent',
      (_) async => const StandardMessageCodec().encodeMessage([null]),
    );
    if (const bool.fromEnvironment('CAPTURE_VIP_UI')) {
      final inter = ByteData.sublistView(
          await File('/tmp/choloto-inter.ttf').readAsBytes());
      font_testing.assetManifest = _TestFontManifest();
      messenger.setMockMessageHandler('flutter/assets', (message) async {
        final path = utf8.decode(message!.buffer.asUint8List());
        if (path.startsWith('__test_fonts/')) return inter;
        return ByteData.sublistView(
            File('build/unit_test_assets/$path').readAsBytesSync());
      });
      await (FontLoader('Google sans flex')
            ..addFont(rootBundle.load(
                'assets/fonts/GoogleSansFlex-VariableFont_GRAD,ROND,opsz,slnt,wdth,wght.ttf')))
          .load();
      await (FontLoader('MaterialIcons')
            ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf')))
          .load();
    }
  });

  for (final language in ['fr', 'en', 'cr']) {
    for (final dark in [false, true]) {
      for (final width in [320.0, 1280.0]) {
        testWidgets('dashboard prices fit $language dark=$dark width=$width',
            (tester) async {
          tester.view.physicalSize = Size(width, 900);
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);
          await tester.pumpWidget(localizedApp(
            RepaintBoundary(
              key: const ValueKey('vip-options-preview'),
              child: Builder(
                builder: (context) => ColoredBox(
                  color: FlutterFlowTheme.of(context).primaryBackground,
                  child: VipPaymentOptions(config: Stream.value(prices())),
                ),
              ),
            ),
            language: language,
            dark: dark,
          ));
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
          expect(find.text('MonCash'), findsOneWidget);
          expect(find.text('NatCash'), findsNothing);
          expect(find.textContaining('2500.00 HTG'), findsOneWidget);
          expect(find.textContaining('50912345678'), findsOneWidget);
          expect(find.textContaining('CHOLOTO'), findsOneWidget);
          expect(find.textContaining('3 '), findsOneWidget);
          if (const bool.fromEnvironment('CAPTURE_VIP_UI') &&
              language == 'fr' &&
              (width == 320 || width == 1280)) {
            final boundary = tester.renderObject<RenderRepaintBoundary>(
              find.byKey(const ValueKey('vip-options-preview')),
            );
            await tester.runAsync(() async {
              final image = await boundary.toImage(pixelRatio: 1);
              final data =
                  await image.toByteData(format: ui.ImageByteFormat.png);
              await File('/tmp/choloto-vip-options-$dark-${width.toInt()}.png')
                  .writeAsBytes(data!.buffer.asUint8List());
              image.dispose();
            });
          }
        });
      }
    }
  }

  testWidgets('prices update and disabled methods disappear', (tester) async {
    final controller = StreamController<SupportBotConfig>();
    addTearDown(controller.close);
    var contacts = 0;
    await tester.pumpWidget(localizedApp(
      VipPaymentOptions(
        config: controller.stream,
        onContact: () => contacts++,
      ),
      language: 'fr',
      dark: true,
    ));
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    controller.add(prices());
    await tester.pumpAndSettle();
    expect(find.textContaining('2500.00 HTG'), findsOneWidget);
    controller.add(prices(amount: 300000));
    await tester.pumpAndSettle();
    expect(find.textContaining('3000.00 HTG'), findsOneWidget);
    expect(find.textContaining('2500.00 HTG'), findsNothing);
    controller.add(prices(enabled: false));
    await tester.pumpAndSettle();
    expect(find.text('MonCash'), findsNothing);
    expect(find.textContaining('indisponible'), findsOneWidget);
    await tester.tap(find.text('Parler à l’équipe'));
    expect(contacts, 1);
    controller.addError(StateError('offline'));
    await tester.pumpAndSettle();
    expect(find.textContaining('indisponible'), findsOneWidget);
    expect(find.textContaining('offline'), findsNothing);
  });

  testWidgets('Devenir VIP opens the native subscription route',
      (tester) async {
    final router = GoRouter(routes: [
      GoRoute(
        path: '/',
        builder: (_, __) => const Scaffold(
          body: SingleChildScrollView(child: DevenirVIPWidget()),
        ),
      ),
      GoRoute(
        name: PaymentRequestsWidget.routeName,
        path: PaymentRequestsWidget.routePath,
        builder: (_, __) => const Scaffold(body: Text('native-subscription')),
      ),
    ]);
    addTearDown(router.dispose);
    await tester.pumpWidget(MaterialApp.router(
      routerConfig: router,
      locale: const Locale('fr'),
      supportedLocales: const [Locale('fr'), Locale('en'), Locale('cr')],
      localizationsDelegates: const [
        FFLocalizationsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        FallbackMaterialLocalizationDelegate(),
        FallbackCupertinoLocalizationDelegate(),
      ],
    ));
    await tester.ensureVisible(find.byKey(const ValueKey('become-vip-button')));
    await tester.tap(find.byKey(const ValueKey('become-vip-button')));
    await tester.pumpAndSettle();
    expect(find.text('native-subscription'), findsOneWidget);
  });
}
