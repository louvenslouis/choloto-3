import 'dart:io';
import 'dart:convert';
import 'dart:ui' as ui;
import 'package:choloto/app_state.dart';
import 'package:choloto/components/vip_prediction_header.dart';
import 'package:choloto/components/vip_page_header.dart';
import 'package:choloto/components/vip_motion.dart';
import 'package:choloto/components/vip_casino_card.dart';
import 'package:choloto/flutter_flow/flutter_flow_theme.dart';
import 'package:choloto/flutter_flow/internationalization.dart';
import 'package:choloto/vip/vip/vip_widget.dart';
import 'package:choloto/vip/universal_v_i_p/universal_v_i_p_widget.dart';
import 'package:choloto/vip/v_i_pboloto/v_i_pboloto_widget.dart';
import 'package:choloto/main.dart';
import 'package:firebase_core/firebase_core.dart';
// ignore: depend_on_referenced_packages
import 'package:firebase_core_platform_interface/test.dart';
// ignore: depend_on_referenced_packages
import 'package:firebase_auth_platform_interface/firebase_auth_platform_interface.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
// ignore: implementation_imports
import 'package:google_fonts/src/google_fonts_base.dart' as font_testing;

class _PreviewAuth extends FirebaseAuthPlatform {
  @override
  FirebaseAuthPlatform delegateFor(
          {required FirebaseApp app, Persistence? persistence}) =>
      this;
  @override
  FirebaseAuthPlatform setInitialValues(
          {Object? currentUser, String? languageCode}) =>
      this;
  @override
  Stream<UserPlatform?> authStateChanges() => const Stream.empty();
}

class _TestFontManifest extends Fake implements AssetManifest {
  @override
  List<String> listAssets() => [
        '__test_fonts/Inter-Regular.ttf',
        '__test_fonts/Inter-Light.ttf',
        '__test_fonts/Inter-Medium.ttf',
        '__test_fonts/Inter-Black.ttf',
        '__test_fonts/Inter-SemiBold.ttf',
        '__test_fonts/Inter-Bold.ttf',
      ];
}

// Exercises the real guest VIP page and prediction widgets with local fixtures.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setupFirebaseCoreMocks();

  const exportDirectory = String.fromEnvironment('VIP_VISUAL_DIR');
  const interFont = String.fromEnvironment('VIP_INTER_FONT');

  setUpAll(() async {
    await Firebase.initializeApp();
    FirebaseAuthPlatform.instance = _PreviewAuth();
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
  });

  for (final language in ['fr', 'en', 'cr']) {
    for (final brightness in [Brightness.dark, Brightness.light]) {
      testWidgets(
          'account header $language $brightness enlarged text and profile',
          (tester) async {
        tester.view.physicalSize = const Size(320, 568);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        var profileOpened = false;
        await tester.pumpWidget(MaterialApp(
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
          theme: ThemeData(brightness: brightness),
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaler: const TextScaler.linear(2),
              disableAnimations: true,
            ),
            child: child!,
          ),
          home: Builder(
              builder: (context) => Scaffold(
                    appBar: PreferredSize(
                      preferredSize:
                          Size.fromHeight(VipPageHeader.heightFor(context)),
                      child: VipPageHeader(
                        avatar: const Icon(Icons.person_rounded),
                        onProfile: () => profileOpened = true,
                      ),
                    ),
                    body: const SizedBox(key: ValueKey('header-body')),
                  )),
        ));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        final subtitle =
            find.text(FFLocalizations(Locale(language)).getText('pubct0u4'));
        expect(
            tester.getBottomLeft(subtitle).dy,
            lessThanOrEqualTo(tester
                .getTopLeft(find.byKey(const ValueKey('header-body')))
                .dy));
        final profile = find.byType(InkWell);
        expect(tester.getSize(profile).shortestSide, greaterThanOrEqualTo(48));
        await tester.tap(profile);
        expect(profileOpened, isTrue);
      });
    }
  }

  for (final brightness in [Brightness.dark, Brightness.light]) {
    for (final percentage in [null, '100%']) {
      testWidgets(
          'prediction header $brightness $percentage with enlarged text',
          (tester) async {
        tester.view.physicalSize = const Size(320, 568);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        await tester.pumpWidget(MaterialApp(
          theme: ThemeData(brightness: brightness),
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(textScaler: const TextScaler.linear(1.5)),
            child: child!,
          ),
          home: Scaffold(
              body: VipPredictionHeader(
            label: 'Probabilité : mercredi 30 septembre 2026 Soir',
            percentage: percentage,
          )),
        ));
        await tester.pump();
        expect(tester.takeException(), isNull);
        expect(find.text('Probabilité : mercredi 30 septembre 2026 Soir'),
            findsOneWidget);
        expect(find.byType(VipCasinoPlaque),
            percentage == null ? findsNothing : findsOneWidget);
        if (percentage != null) expect(find.text(percentage), findsOneWidget);
      });
    }
  }

  for (final language in ['fr', 'en', 'cr']) {
    for (final brightness in [Brightness.dark, Brightness.light]) {
      for (final width in [320.0, 390.0, 1280.0]) {
        for (final member in [false, true]) {
          testWidgets(
              'VIP ${member ? "cards" : "page"} $language ${brightness.name} $width',
              (tester) async {
            tester.view.physicalSize =
                Size(width, width == 320 ? 568 : (width == 390 ? 844 : 1000));
            tester.view.devicePixelRatio = 1;
            addTearDown(tester.view.resetPhysicalSize);
            addTearDown(tester.view.resetDevicePixelRatio);
            FFAppState.reset();
            final captureKey = GlobalKey();
            await tester.pumpWidget(ChangeNotifierProvider.value(
              value: FFAppState(),
              child: RepaintBoundary(
                  key: captureKey,
                  child: MaterialApp(
                    debugShowCheckedModeBanner: false,
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
                    theme: ThemeData(
                        brightness: brightness,
                        useMaterial3: false,
                        fontFamily: exportDirectory.isEmpty ? null : 'Inter'),
                    home: NavBarPage(
                        initialPage: 'VIP',
                        page: member
                            ? Builder(
                                builder: (context) => Scaffold(
                                    backgroundColor:
                                        FlutterFlowTheme.of(context)
                                            .primaryBackground,
                                    body: SingleChildScrollView(
                                        child: Column(children: [
                                      VipPredictionHeader(
                                        label:
                                            '${FFLocalizations.of(context).getText('vipproblb')}: ${switch (language) {
                                          'en' => 'Monday, September 7 Evening',
                                          'cr' => 'Lendi 7 septanm Aswè',
                                          _ => 'lundi 7 septembre Soir',
                                        }}',
                                        percentage: '85%',
                                      ).vipEntrance(delayMs: 80),
                                      GridView.count(
                                          shrinkWrap: true,
                                          physics:
                                              const NeverScrollableScrollPhysics(),
                                          crossAxisCount: 2,
                                          children: [
                                            UniversalVIPWidget(
                                                name: 'FAVORI',
                                                chiffre: ['12'],
                                                icon: Icon(Icons.star)),
                                            UniversalVIPWidget(
                                                name: 'SOUTNI',
                                                chiffre: ['34', '56'],
                                                icon: Icon(Icons.favorite)),
                                            VIPbolotoWidget(
                                                name: 'BOLOTO',
                                                chiffre: ['12', '34']),
                                            UniversalVIPWidget(
                                                name: 'MARIAGE',
                                                chiffre: ['12 x 34'],
                                                icon: Icon(Icons.link)),
                                            UniversalVIPWidget(
                                                name: '3 CHIFFRES',
                                                chiffre: ['123'],
                                                icon: Icon(Icons.looks_3)),
                                            UniversalVIPWidget(
                                                name: '4 CHIFFRES',
                                                chiffre: ['1234'],
                                                icon: Icon(Icons.looks_4)),
                                            UniversalVIPWidget(
                                                name: 'EXTRA',
                                                chiffre: [],
                                                icon: Icon(Icons.auto_awesome)),
                                          ]
                                              .asMap()
                                              .entries
                                              .map((entry) => entry.value
                                                  .vipEntrance(
                                                      delayMs:
                                                          125 + entry.key * 45))
                                              .toList()),
                                    ]))))
                            : const VipWidget()),
                  )),
            ));
            await tester.runAsync(() async {
              await Future<void>.delayed(Duration.zero);
            });
            await tester.pump();
            final entrances = find.descendant(
              of: find.byType(VipEntrance),
              matching: find.byType(FadeTransition),
            );
            expect(entrances, findsWidgets);
            await tester.pump(const Duration(milliseconds: 180));
            expect(
                tester
                    .widgetList<FadeTransition>(entrances)
                    .any((fade) => fade.opacity.value < 1),
                isTrue);
            await tester.pump(const Duration(seconds: 6));
            await tester.pump(const Duration(milliseconds: 400));
            expect(tester.takeException(), isNull);
            expect(
                tester
                    .widgetList<FadeTransition>(entrances)
                    .every((fade) => fade.opacity.value == 1),
                isTrue);
            if (!member) {
              final strings = FFLocalizations(Locale(language));
              expect(find.text(strings.getText('gfj3b9xn')), findsOneWidget);
              expect(find.text(strings.getText('c8ki06qv')), findsOneWidget);
              expect(find.text(strings.getText('i0zhxntw')), findsOneWidget);
              expect(
                  tester.getTopLeft(find.text(strings.getText('c8ki06qv'))).dy,
                  lessThan(tester
                      .getTopLeft(find.text(strings.getText('99kfebqb')))
                      .dy));
            } else {
              expect(tester.getTopLeft(find.text('FAVORI')).dx,
                  lessThan(tester.getTopLeft(find.text('SOUTNI')).dx));
              expect(find.text('12 x 34'), findsOneWidget);
              expect(find.byType(VipCasinoCard), findsWidgets);
              expect(find.byType(VipCasinoPlaque), findsWidgets);
              expect(find.byType(VipCasinoChip), findsNWidgets(2));
              expect(find.byType(VipPredictionHeader), findsOneWidget);
              expect(find.text('85%'), findsOneWidget);
              expect(tester.getBottomLeft(find.byType(VipPredictionHeader)).dy,
                  lessThanOrEqualTo(tester.getTopLeft(find.text('FAVORI')).dy));
              // The casino finish must keep the two-column card footprints.
              final left = tester.getRect(find.ancestor(
                  of: find.text('FAVORI'),
                  matching: find.byType(VipCasinoCard)));
              final right = tester.getRect(find.ancestor(
                  of: find.text('SOUTNI'),
                  matching: find.byType(VipCasinoCard)));
              expect(left.top, right.top);
              expect(left.width, right.width);
              expect(left.right, lessThanOrEqualTo(right.left));
            }
            if (exportDirectory.isNotEmpty) {
              final boundary = captureKey.currentContext!.findRenderObject()!
                  as RenderRepaintBoundary;
              final picture =
                  (await tester.runAsync(() => boundary.toImage()))!;
              final bytes = await tester.runAsync(
                  () => picture.toByteData(format: ui.ImageByteFormat.png));
              await tester.runAsync(() async {
                final file = File(
                    '$exportDirectory/${member ? "cards" : "page"}-$language-${brightness.name}-${width.toInt()}.png');
                await file.parent.create(recursive: true);
                await file.writeAsBytes(bytes!.buffer.asUint8List());
              });
              picture.dispose();
            }
            if (!member) {
              // The existing action stays reachable on the shortest viewport.
              final action = find
                  .text(FFLocalizations(Locale(language)).getText('i0zhxntw'));
              await tester.ensureVisible(action);
              await tester.pump();
              expect(tester.getCenter(action).dy,
                  lessThan(tester.view.physicalSize.height));
              expect(tester.takeException(), isNull);
            }
            await tester.pumpWidget(const SizedBox.shrink());
          });
        }
      }
    }
  }
}
