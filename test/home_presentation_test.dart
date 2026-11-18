import 'dart:io';
import 'dart:convert';
import 'dart:ui' as ui;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:choloto/autres/bingo/bingo/bingo_story_button.dart';
import 'package:choloto/backend/schema/structs/youtube_item_struct.dart';
import 'package:choloto/components/home_feature_section.dart';
import 'package:choloto/components/home_page_scaffold.dart';
import 'package:choloto/components/home_header_actions.dart';
import 'package:choloto/components/home_stories_rail.dart';
import 'package:choloto/app_state.dart';
import 'package:choloto/backend/schema/resultats_record.dart';
import 'package:choloto/components/tirages_home_widget.dart';
import 'package:firebase_core/firebase_core.dart';
// Firebase's test helper stubs the native platform; no backend is contacted.
// ignore: depend_on_referenced_packages
import 'package:firebase_core_platform_interface/test.dart';
import 'support/memory_firestore.dart';
import 'package:choloto/flutter_flow/flutter_flow_theme.dart';
import 'package:choloto/flutter_flow/internationalization.dart';
import 'package:choloto/main.dart';
import 'package:choloto/youtube/youtube_story.dart';
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
  const thumbnailUrl = 'https://example.invalid/stories/thumbnail.png';
  late ui.Image thumbnail;

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
    final thumbnailBytes =
        await rootBundle.load('assets/images/youtube_-_Moyenne.png');
    final codec = await ui.instantiateImageCodec(
        Uint8List.sublistView(thumbnailBytes),
        targetWidth: 112);
    thumbnail = (await codec.getNextFrame()).image;
    codec.dispose();
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
  tearDownAll(() => thumbnail.dispose());

  setUp(() async {
    FFAppState.reset();
    ResultatsRecord record(String market, List<String> numbers) =>
        ResultatsRecord.getDocumentFromData({
          'date': DateTime(2026, 11, 17, 20),
          'periode': 'Soir',
          'tirage': market,
          'numeros': numbers,
        }, MemoryReference('resultats/fixture-$market'));
    await FFAppState().newYorkTirage(
        requestFn: () async => [
              record('ny', ['427', '18', '64'])
            ]);
    await FFAppState().floridaTirage(
        requestFn: () async => [
              record('fl', ['516', '09', '32'])
            ]);
  });

  for (final language in ['fr', 'en', 'cr']) {
    for (final brightness in Brightness.values) {
      for (final width in [320.0, 390.0, 1440.0]) {
        testWidgets('home presentation $language ${brightness.name} $width',
            (tester) async {
          tester.binding.platformDispatcher.platformBrightnessTestValue =
              brightness;
          addTearDown(tester
              .binding.platformDispatcher.clearPlatformBrightnessTestValue);
          final viewport =
              Size(width, width == 320 ? 568 : (width == 390 ? 844 : 900));
          final pixelRatio = exportDirectory.isEmpty ? 1.0 : 2.0;
          tester.view.devicePixelRatio = pixelRatio;
          tester.view.physicalSize = viewport * pixelRatio;
          tester.view.padding = FakeViewPadding(
            top: width < 600 ? 24 * pixelRatio : 0,
            bottom: width == 390 ? 24 * pixelRatio : 0,
          );
          addTearDown(tester.view.resetPadding);
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);
          // Exercise the real YouTube cover widget with its thumbnail cached locally.
          PaintingBinding.instance.imageCache.putIfAbsent(
            const CachedNetworkImageProvider(thumbnailUrl),
            () => OneFrameImageStreamCompleter(
              Future.value(ImageInfo(image: thumbnail.clone())),
            ),
          );
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
              theme: DarkModeTheme().materialTheme,
              themeMode: ThemeMode.dark,
              home: NavBarPage(
                initialPage: 'Home',
                page: HomePageScaffold(
                  inTabShell: true,
                  support: HomeSupportFab(onSupport: () async {}),
                  buildSections: (supportBesideStories) => [
                    HomeFeatureSection(
                      storyAction: supportBesideStories,
                      stories: HomeStoriesRail(
                        loading: false,
                        loadFailed: false,
                        onRetry: () {},
                        stories: [
                          BingoStoryButton(
                              viewed: false, storyCount: 3, onTap: () {}),
                          YoutubeStoryButton(
                            video: YoutubeItemStruct(
                                title: 'CHOLOTO', thumbnail: thumbnailUrl),
                            viewed: true,
                            onTap: () {},
                          ),
                        ],
                      ),
                      onViewResults: () {},
                      onVip: () {},
                      onChance: () {},
                      onVideo: () {},
                      onStats: () {},
                      onTchala: () {},
                      onHistory: () {},
                      draws: const TiragesHomeWidget(),
                    ),
                  ],
                ),
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
          final homeTheme = DarkModeTheme();
          if (width < 600) {
            expect(
              tester
                  .widget<BottomNavigationBar>(find.byType(BottomNavigationBar))
                  .backgroundColor,
              homeTheme.designToken.background.home,
            );
          }
          final background = tester.widget<DecoratedBox>(
            find.byKey(const ValueKey('home-background-gradient')),
          );
          expect(
            (background.decoration as BoxDecoration).gradient,
            homeTheme.designToken.background.homeGradient,
          );

          final stories = find.byType(HomeStoriesRail);
          final hero = find.byKey(const ValueKey('home-vip-hero'));
          final drawsCard =
              find.byKey(const ValueKey('home-feature-gradient-draws'));
          final draws = find.byKey(const ValueKey('home-draws-gradient-card'));
          expect(find.byType(BingoStoryButton).hitTestable(), findsOneWidget);
          expect(find.byType(YoutubeStoryButton).hitTestable(), findsOneWidget);
          expect(tester.getBottomLeft(stories).dy,
              lessThanOrEqualTo(tester.getTopLeft(hero).dy));
          final strings = FFLocalizations(Locale(language));
          expect(
              find.descendant(
                  of: hero, matching: find.text(strings.getText('covzb0rd'))),
              findsOneWidget);
          expect(find.byKey(const ValueKey('home-open-vip')).hitTestable(),
              findsOneWidget);
          expect(hero.hitTestable(), findsOneWidget);
          expect(tester.getTopLeft(draws).dy,
              greaterThan(tester.getTopLeft(hero).dy));
          if (width > 1000) {
            final support = find.byKey(const ValueKey('home-support-button'));
            expect(support.hitTestable(), findsOneWidget);
            expect(tester.getBottomLeft(support).dy,
                lessThanOrEqualTo(tester.getTopRight(hero).dy));
            expect(tester.getTopLeft(drawsCard).dx,
                greaterThanOrEqualTo(tester.getTopRight(hero).dx));
            expect(tester.getTopLeft(draws).dy - tester.getBottomLeft(hero).dy,
                greaterThanOrEqualTo(homeTheme.designToken.spacing.xl - 0.01));
          } else {
            expect(
                tester.getTopLeft(drawsCard).dy - tester.getBottomLeft(hero).dy,
                closeTo(homeTheme.designToken.spacing.lg, 0.01));
          }
          expect(find.text('427'), findsOneWidget);
          expect(find.text('516'), findsOneWidget);
          expect(tester.takeException(), isNull);
          if (exportDirectory.isNotEmpty) {
            await tester.runAsync(() async {
              final boundary = captureKey.currentContext!.findRenderObject()!
                  as RenderRepaintBoundary;
              final image = await boundary.toImage(pixelRatio: pixelRatio);
              final bytes =
                  await image.toByteData(format: ui.ImageByteFormat.png);
              await Directory(exportDirectory).create(recursive: true);
              await File(
                      '$exportDirectory/$language-${brightness.name}-${width.toInt()}.png')
                  .writeAsBytes(bytes!.buffer.asUint8List());
              image.dispose();
            });
          }
          // On short phones the complete list is one scroll away. Neither row
          // may be covered by the support entry or by the navigation bar.
          final support = find.byKey(const ValueKey('home-support-button'));
          for (final number in ['64', '32']) {
            final chip = find.text(number);
            await tester.ensureVisible(chip);
            await tester.pump();
            expect(chip.hitTestable(), findsOneWidget);
            expect(tester.getRect(support).overlaps(tester.getRect(chip)),
                isFalse);
          }
        });
      }
    }
  }
}
