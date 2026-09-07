import 'dart:io';
import 'dart:convert';
import 'dart:ui' as ui;

import 'package:choloto/components/home_feature_card.dart';
import 'package:choloto/components/home_header_actions.dart';
import 'package:choloto/app_state.dart';
import 'package:choloto/backend/schema/resultats_record.dart';
import 'package:choloto/components/tirages_home_widget.dart';
import 'package:choloto/components/home_stories_rail.dart';
import 'package:firebase_core/firebase_core.dart';
// Firebase's test helper stubs the native platform; no backend is contacted.
// ignore: depend_on_referenced_packages
import 'package:firebase_core_platform_interface/test.dart';
import 'support/memory_firestore.dart';
import 'package:choloto/flutter_flow/flutter_flow_theme.dart';
import 'package:choloto/flutter_flow/internationalization.dart';
import 'package:choloto/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
// The package exposes this manifest override specifically for offline tests.
// ignore: implementation_imports
import 'package:google_fonts/src/google_fonts_base.dart' as font_testing;

class _TestFontManifest extends Fake implements AssetManifest {
  @override
  List<String> listAssets() => [
        '__test_fonts/Inter-Regular.ttf',
        '__test_fonts/Inter-SemiBold.ttf',
        '__test_fonts/Inter-Bold.ttf',
      ];
}

// Uses the real draw widgets with local cached fixtures, without contacting Firebase.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setupFirebaseCoreMocks();

  const exportDirectory = String.fromEnvironment('HOME_VISUAL_DIR');
  const interFont = String.fromEnvironment('HOME_INTER_FONT');

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
  });

  setUp(() async {
    FFAppState.reset();
    ResultatsRecord record(String market) =>
        ResultatsRecord.getDocumentFromData({
          'date': DateTime(2026, 9, 7, 12),
          'periode': 'Midi',
          'tirage': market,
          'numeros': ['12', '34', '56'],
        }, MemoryReference('resultats/fixture-$market'));
    await FFAppState().newYorkTirage(requestFn: () async => [record('ny')]);
    await FFAppState().floridaTirage(requestFn: () async => [record('fl')]);
  });

  for (final language in ['fr', 'en', 'cr']) {
    for (final brightness in Brightness.values) {
      for (final width in [320.0, 390.0, 1440.0]) {
        testWidgets('home presentation $language ${brightness.name} $width',
            (tester) async {
          tester.view.physicalSize =
              Size(width, width == 320 ? 568 : (width == 390 ? 844 : 900));
          tester.view.devicePixelRatio = 1;
          tester.view.padding = FakeViewPadding(
            top: width < 600 ? 24 : 0,
            bottom: width == 390 ? 24 : 0,
          );
          addTearDown(tester.view.resetPadding);
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);
          final captureKey = GlobalKey();
          await tester.pumpWidget(RepaintBoundary(
            key: captureKey,
            child: MaterialApp(
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
              debugShowCheckedModeBanner: false,
              theme: ThemeData(
                  brightness: brightness,
                  useMaterial3: false,
                  fontFamily: exportDirectory.isEmpty ? null : 'Inter'),
              home: NavBarPage(
                initialPage: 'Home',
                page: Builder(builder: (context) {
                  final theme = FlutterFlowTheme.of(context);
                  final strings = FFLocalizations.of(context);
                  final spacing = theme.designToken.spacing;
                  HomeFeatureCard card(HomeFeatureTone tone) {
                    final (title, description, asset) = switch (tone) {
                      HomeFeatureTone.vip => (
                          'covzb0rd',
                          'uvl7vow9',
                          'vip_membership_3d_v2.png'
                        ),
                      HomeFeatureTone.chance => (
                          'afym167o',
                          'pqih1sxe',
                          'lucky_cross_3d_x.png'
                        ),
                      HomeFeatureTone.video => (
                          'fkwji2m2',
                          'gcjztr88',
                          'video_play_3d_v2.png'
                        ),
                    };
                    return HomeFeatureCard(
                      semanticId: tone.name,
                      title: strings.getText(title),
                      description: strings.getText(description),
                      assetPath: 'assets/images/home/$asset',
                      tone: tone,
                      onTap: () {},
                    );
                  }

                  return Scaffold(
                    backgroundColor: theme.primaryBackground,
                    appBar: AppBar(
                      backgroundColor: theme.primaryBackground,
                      elevation: 0,
                      toolbarHeight: 64,
                      title: Text('CHOLOTO', style: theme.titleLarge),
                      actions: [
                        HomeHeaderActions(
                          onAchievements: () async {},
                          onSettings: () async {},
                        ),
                        SizedBox(width: spacing.sm),
                      ],
                    ),
                    floatingActionButton:
                        HomeSupportFab(onSupport: () async {}),
                    body: SingleChildScrollView(
                      padding: EdgeInsets.fromLTRB(
                          spacing.md, spacing.sm, spacing.md, spacing.xl * 3),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 1120),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              HomeFeatureSection(
                                stories: width < 600
                                    ? HomeStoriesRail(
                                        stories: const [],
                                        loading: true,
                                        loadFailed: false,
                                        onRetry: () {},
                                      )
                                    : null,
                                vipCard: card(HomeFeatureTone.vip),
                                chanceCard: card(HomeFeatureTone.chance),
                                videoCard: card(HomeFeatureTone.video),
                                draws: const TiragesHomeWidget(),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ));
          await tester.runAsync(() async {
            await Future<void>.delayed(Duration.zero);
          });
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 800));
          await tester.runAsync(() async {
            for (final element in find.byType(Image).evaluate()) {
              await precacheImage((element.widget as Image).image, element);
            }
          });
          await tester.runAsync(() async {
            await Future<void>.delayed(Duration.zero);
          });
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 800));
          expect(find.text('À la une'), findsNothing);
          final draws = find.byKey(const ValueKey('home-draws-gradient-card'));
          final bottomNav =
              find.byKey(const ValueKey('primary-bottom-navigation'));
          final bottom = width < 600
              ? tester.getTopLeft(bottomNav).dy
              : tester.view.physicalSize.height;
          expect(tester.getBottomRight(draws).dy, lessThanOrEqualTo(bottom),
              reason:
                  'Draw results must fit before scrolling at normal text size.');
          expect(find.text('12'), findsWidgets);
          final fab =
              tester.getRect(find.byKey(const ValueKey('home-support-button')));
          final numbers = find.text('56').hitTestable();
          expect(numbers, findsOneWidget);
          expect(fab.overlaps(tester.getRect(numbers)), isFalse,
              reason: 'The support FAB must not cover lottery numbers.');
          expect(tester.takeException(), isNull);
          if (exportDirectory.isNotEmpty) {
            await tester.runAsync(() async {
              final boundary = captureKey.currentContext!.findRenderObject()!
                  as RenderRepaintBoundary;
              final image = await boundary.toImage();
              final bytes =
                  await image.toByteData(format: ui.ImageByteFormat.png);
              await Directory(exportDirectory).create(recursive: true);
              await File(
                      '$exportDirectory/$language-${brightness.name}-${width.toInt()}.png')
                  .writeAsBytes(bytes!.buffer.asUint8List());
              image.dispose();
            });
          }
        });
      }
    }
  }
}
