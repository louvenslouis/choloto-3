import 'dart:io';
import 'dart:convert';
import 'dart:ui' as ui;
import 'package:choloto/app_state.dart';
import 'package:choloto/auth/base_auth_user_provider.dart';
import 'package:choloto/autres/bingo/bingo_card_v_i_p/bingo_card_v_i_p_widget.dart';
import 'package:choloto/autres/bingo/stackbingo/stackbingo_widget.dart';
import 'package:choloto/components/vip_prediction_header.dart';
import 'package:choloto/flutter_flow/flutter_flow_theme.dart';
import 'package:choloto/flutter_flow/internationalization.dart';
import 'package:firebase_core/firebase_core.dart';
// ignore: depend_on_referenced_packages
import 'package:firebase_core_platform_interface/test.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
// ignore: implementation_imports
import 'package:google_fonts/src/google_fonts_base.dart' as font_testing;

class _SignedInUser extends Fake implements BaseAuthUser {
  @override
  bool get loggedIn => true;
}

class _TestFontManifest extends Fake implements AssetManifest {
  @override
  List<String> listAssets() => [
        '__test_fonts/Inter-Regular.ttf',
        '__test_fonts/Raleway-Black.ttf',
        '__test_fonts/ChangaOne-Regular.ttf',
        '__test_fonts/Inter-Light.ttf',
        '__test_fonts/Inter-Medium.ttf',
        '__test_fonts/Inter-Black.ttf',
        '__test_fonts/Inter-SemiBold.ttf',
        '__test_fonts/Inter-Bold.ttf',
      ];
}

// Verifies the VIP-only compact entry and its expand/collapse interaction.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setupFirebaseCoreMocks();

  const exportDirectory = String.fromEnvironment('BINGO_VIP_VISUAL_DIR');
  const interFont = String.fromEnvironment('VIP_INTER_FONT');

  setUpAll(() async {
    await Firebase.initializeApp();
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    messenger.setMockMessageHandler(
      'dev.flutter.pigeon.firebase_analytics_platform_interface.FirebaseAnalyticsHostApi.logEvent',
      (_) async => const StandardMessageCodec().encodeMessage([null]),
    );
    final fontBytes = interFont.isNotEmpty
        ? ByteData.sublistView(await File(interFont).readAsBytes())
        : await rootBundle.load(
            'assets/fonts/GoogleSansFlex-VariableFont_GRAD,ROND,opsz,slnt,wdth,wght.ttf');
    font_testing.assetManifest = _TestFontManifest();
    messenger.setMockMessageHandler('flutter/assets', (message) async {
      final path = utf8.decode(message!.buffer.asUint8List());
      if (path.startsWith('__test_fonts/')) return fontBytes;
      return ByteData.sublistView(
          File('build/unit_test_assets/$path').readAsBytesSync());
    });
    final titleLoader = FontLoader('Google sans flex')
      ..addFont(rootBundle.load(
        'assets/fonts/GoogleSansFlex-VariableFont_GRAD,ROND,opsz,slnt,wdth,wght.ttf',
      ));
    await titleLoader.load();
    await (FontLoader('MaterialIcons')
          ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf')))
        .load();
    await (FontLoader('packages/font_awesome_flutter/FontAwesomeSolid')
          ..addFont(rootBundle.load(
            'packages/font_awesome_flutter/lib/fonts/fa-solid-900.ttf',
          )))
        .load();
    await (FontLoader('packages/font_awesome_flutter/FontAwesomeRegular')
          ..addFont(rootBundle.load(
            'packages/font_awesome_flutter/lib/fonts/fa-regular-400.ttf',
          )))
        .load();
    if (interFont.isNotEmpty) {
      for (final family in ['Inter', 'Inter_regular']) {
        await (FontLoader(family)
              ..addFont(File(interFont).readAsBytes().then(
                    (bytes) => ByteData.sublistView(bytes),
                  )))
            .load();
      }
    }
    await GoogleFonts.pendingFonts([
      for (final weight in [
        FontWeight.w400,
        FontWeight.w500,
        FontWeight.w600,
        FontWeight.w700
      ])
        GoogleFonts.inter(fontWeight: weight),
      GoogleFonts.raleway(fontWeight: FontWeight.w900),
      GoogleFonts.changaOne(),
    ]);
    messenger.setMockMessageHandler(
      'dev.flutter.pigeon.cloud_firestore_platform_interface.FirebaseFirestoreHostApi.querySnapshot',
      (_) async =>
          const StandardMessageCodec().encodeMessage(['bingo-vip-test']),
    );
    messenger.setMockMethodCallHandler(
      const MethodChannel(
          'plugins.flutter.io/firebase_firestore/query/bingo-vip-test'),
      (_) async => null,
    );
  });

  for (final language in ['fr', 'en', 'cr']) {
    for (final brightness in [Brightness.dark, Brightness.light]) {
      for (final width in [320.0, 1280.0]) {
        testWidgets('VIP Bingo $language $brightness $width', (tester) async {
          tester.view.physicalSize = Size(width, 720);
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);
          currentUser = _SignedInUser();
          addTearDown(() => currentUser = null);
          FFAppState.reset();
          final captureKey = GlobalKey();
          final strings = FFLocalizations(Locale(language));
          await tester.pumpWidget(ChangeNotifierProvider.value(
            value: FFAppState(),
            child: RepaintBoundary(
              key: captureKey,
              child: MaterialApp(
                debugShowCheckedModeBanner: false,
                theme: ThemeData(brightness: brightness),
                locale: Locale(language),
                supportedLocales: const [
                  Locale('fr'),
                  Locale('en'),
                  Locale('cr')
                ],
                localizationsDelegates: const [
                  FFLocalizationsDelegate(),
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                  FallbackMaterialLocalizationDelegate(),
                  FallbackCupertinoLocalizationDelegate(),
                ],
                home: Builder(
                    builder: (context) => Scaffold(
                          backgroundColor:
                              FlutterFlowTheme.of(context).primaryBackground,
                          body: SingleChildScrollView(
                              child: Column(children: [
                            const BingoCardVIPWidget(),
                            VipPredictionHeader(
                              label: strings.getText('vipproblb'),
                              percentage: '85%',
                            ),
                          ])),
                        )),
              ),
            ),
          ));
          await tester
              .runAsync(() async => Future<void>.delayed(Duration.zero));
          await tester.pump();
          await tester.runAsync(() => precacheImage(
                const AssetImage('assets/images/bingo-2.png'),
                tester.element(find.byType(BingoCardVIPWidget)),
              ));
          await tester.pump();
          final theme = brightness == Brightness.dark
              ? DarkModeTheme()
              : LightModeTheme();
          for (final label in ['bingo_story_label', 'bngexpand']) {
            final color = tester
                .widget<Text>(find.text(strings.getText(label)))
                .style!
                .color!;
            final foreground =
                Color.alphaBlend(color, theme.secondaryBackground)
                    .computeLuminance();
            final background = theme.secondaryBackground.computeLuminance();
            final contrast = foreground > background
                ? (foreground + 0.05) / (background + 0.05)
                : (background + 0.05) / (foreground + 0.05);
            expect(contrast, greaterThanOrEqualTo(4.5));
          }
          expect(find.byType(StackbingoWidget), findsNothing);
          expect(tester.getSize(find.byType(BingoCardVIPWidget)).height,
              lessThanOrEqualTo(64));
          expect(find.text(strings.getText('bngexpand')), findsOneWidget);
          expect(tester.takeException(), isNull);

          Future<void> capture(String state) async {
            if (exportDirectory.isEmpty) return;
            final boundary = captureKey.currentContext!.findRenderObject()!
                as RenderRepaintBoundary;
            final picture = (await tester.runAsync(() => boundary.toImage()))!;
            final bytes = await tester.runAsync(
                () => picture.toByteData(format: ui.ImageByteFormat.png));
            await tester.runAsync(() async {
              final file = File(
                  '$exportDirectory/$language-${brightness.name}-${width.toInt()}-$state.png');
              await file.parent.create(recursive: true);
              await file.writeAsBytes(bytes!.buffer.asUint8List());
            });
            picture.dispose();
          }

          await capture('collapsed');
          // The whole header, including its logo, opens the details.
          await tester.tapAt(tester.getCenter(find.byType(Image).first));
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 250));
          expect(find.byType(StackbingoWidget), findsOneWidget);
          expect(find.text(strings.getText('ch00aogu')), findsOneWidget);
          expect(find.text(strings.getText('ksh6eozy')), findsOneWidget);
          expect(find.text(strings.getText('7ccuyv05')), findsOneWidget);
          // Feed the existing Firestore stream a local result fixture.
          tester.binding.defaultBinaryMessenger.handlePlatformMessage(
            'plugins.flutter.io/firebase_firestore/query/bingo-vip-test',
            const StandardMethodCodec().encodeSuccessEnvelope([
              [
                [
                  'bingo/test',
                  {
                    'dataStack': [
                      {
                        'boul': '12',
                        'valeur': '1er lot',
                        'tirage': 'Florida',
                        'periode': 'Soir'
                      }
                    ]
                  },
                  [false, false]
                ]
              ],
              [],
              [false, false],
            ]),
            (_) {},
          );
          await tester.pump();
          await tester
              .runAsync(() async => Future<void>.delayed(Duration.zero));
          await tester.pump(const Duration(seconds: 1));
          expect(find.text('12'), findsOneWidget);
          expect(tester.takeException(), isNull);
          await capture('expanded');
          await tester.tap(find.text(strings.getText('bngreduce')));
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 250));
          expect(find.byType(StackbingoWidget), findsNothing);
          expect(tester.getSize(find.byType(BingoCardVIPWidget)).height,
              lessThanOrEqualTo(64));
          expect(tester.takeException(), isNull);
          await tester.pumpWidget(const SizedBox.shrink());
        });
      }
    }
  }
}
