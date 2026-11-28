import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:choloto/components/illustrated_page_header.dart';
import 'package:choloto/backend/schema/resultats_record.dart';
import 'package:choloto/flutter_flow/flutter_flow_theme.dart';
import 'package:choloto/flutter_flow/internationalization.dart';
import 'package:choloto/main.dart';
import 'package:choloto/tirages/tirages/tirages_widget.dart';
// ignore: depend_on_referenced_packages
import 'package:firebase_auth_platform_interface/firebase_auth_platform_interface.dart';
import 'package:firebase_core/firebase_core.dart';
// ignore: depend_on_referenced_packages
import 'package:firebase_core_platform_interface/test.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
// google_fonts provides a replaceable font manifest for offline widget tests.
// ignore: implementation_imports
import 'package:google_fonts/src/google_fonts_base.dart' as font_testing;

import 'support/memory_firestore.dart';

const _exportDir = String.fromEnvironment('TIRAGES_VISUAL_DIR');
const _interFont = String.fromEnvironment('TIRAGES_INTER_FONT');

// The real ad banner checks the signed-in account before it reserves space.
class _SignedOutAuth extends FirebaseAuthPlatform {
  @override
  FirebaseAuthPlatform delegateFor(
          {required FirebaseApp app, Persistence? persistence}) =>
      this;
  @override
  FirebaseAuthPlatform setInitialValues(
          {Object? currentUser, String? languageCode}) =>
      this;
  @override
  Stream<UserPlatform?> authStateChanges() => Stream.value(null);
}

class _TestFonts extends Fake implements AssetManifest {
  @override
  List<String> listAssets() => [
        for (final weight in [
          'Regular',
          'Medium',
          'SemiBold',
          'Bold',
          'ExtraBold'
        ])
          '__test_fonts/Inter-$weight.ttf',
      ];
}

Future<void> _loadFonts() async {
  const titleFont =
      'assets/fonts/GoogleSansFlex-VariableFont_GRAD,ROND,opsz,slnt,wdth,wght.ttf';
  final interBytes = _interFont.isEmpty
      ? await rootBundle.load(titleFont)
      : ByteData.sublistView(await File(_interFont).readAsBytes());
  font_testing.assetManifest = _TestFonts();
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMessageHandler('flutter/assets', (message) async {
    final path = utf8.decode(message!.buffer.asUint8List());
    if (path.startsWith('__test_fonts/')) return interBytes;
    return ByteData.sublistView(
        File('build/unit_test_assets/$path').readAsBytesSync());
  });
  for (final entry in {
    'Google sans flex': titleFont,
    'MaterialIcons': 'fonts/MaterialIcons-Regular.otf',
    'packages/font_awesome_flutter/FontAwesomeSolid':
        'packages/font_awesome_flutter/lib/fonts/fa-solid-900.ttf',
    'packages/font_awesome_flutter/FontAwesomeRegular':
        'packages/font_awesome_flutter/lib/fonts/fa-regular-400.ttf',
  }.entries) {
    await (FontLoader(entry.key)..addFont(rootBundle.load(entry.value))).load();
  }
  if (_interFont.isNotEmpty) {
    for (final family in ['Inter', 'Inter_regular']) {
      await (FontLoader(family)..addFont(Future.value(interBytes))).load();
    }
  }
}

ResultatsRecord _draw(
    String market, int day, int hour, String period, List<String> numbers) {
  return ResultatsRecord.getDocumentFromData({
    'date': DateTime(2026, 11, day, hour),
    'periode': period,
    'tirage': market,
    'numeros': numbers,
  }, MemoryReference('resultats/demo-$market-$day-$hour'));
}

// Local example results in the same descending order as the paginated feed.
final _results = [
  _draw('ny', 24, 21, 'Soir', ['427', '18', '64']),
  _draw('fl', 24, 20, 'Soir', ['516', '23', '09', '32']),
  _draw('tx', 24, 13, 'Midi', ['305', '41', '72']),
  _draw('ga', 24, 12, 'Midi', ['849', '25', '16']),
  _draw('pa', 23, 21, 'Soir', ['263', '87', '65']),
  _draw('nj', 23, 20, 'Soir', ['490', '51', '79']),
  _draw('md', 23, 13, 'Midi', ['154', '69', '04']),
  _draw('tn', 23, 12, 'Midi', ['872', '36', '95']),
  _draw('fl', 22, 20, 'Soir', ['390', '26', '58', '70']),
];

Future<void> _noAction() async {}

Widget _app({
  required Widget page,
  String language = 'fr',
  double textScale = 1,
}) =>
    MaterialApp(
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
      debugShowCheckedModeBanner: false,
      theme: DarkModeTheme().materialTheme,
      themeMode: ThemeMode.dark,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context)
            .copyWith(textScaler: TextScaler.linear(textScale)),
        child: child!,
      ),
      home:
          NavBarPage(key: ObjectKey(page), initialPage: 'Tirages', page: page),
    );

TiragesView _page({
  List<ResultatsRecord>? results,
  bool loading = false,
  bool loadFailed = false,
  bool hasMore = true,
  bool loadingMore = false,
  Future<void> Function() onRefresh = _noAction,
  Future<void> Function() onLoadMore = _noAction,
}) =>
    TiragesView(
      results: results ?? _results,
      loading: loading,
      loadFailed: loadFailed,
      hasMore: hasMore,
      loadingMore: loadingMore,
      onRefresh: onRefresh,
      onLoadMore: onLoadMore,
    );

void _setViewport(WidgetTester tester, Size viewport, Brightness system) {
  final ratio = _exportDir.isEmpty ? 1.0 : 2.0;
  tester.view.devicePixelRatio = ratio;
  tester.view.physicalSize = viewport * ratio;
  tester.view.padding = FakeViewPadding(
    top: viewport.width < 600 ? 24 * ratio : 0,
    bottom: viewport.width == 390 ? 24 * ratio : 0,
  );
  tester.binding.platformDispatcher.platformBrightnessTestValue = system;
  addTearDown(
      tester.binding.platformDispatcher.clearPlatformBrightnessTestValue);
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetPadding);
}

Future<void> _savePreview(
    WidgetTester tester, GlobalKey boundaryKey, String name) async {
  await tester.runAsync(() async {
    final images = find.byType(Image).evaluate();
    await Future.wait(images.map(
        (element) => precacheImage((element.widget as Image).image, element)));
  });
  await tester.pumpAndSettle();
  await tester.runAsync(() async {
    final boundary = boundaryKey.currentContext!.findRenderObject()!
        as RenderRepaintBoundary;
    final image =
        await boundary.toImage(pixelRatio: tester.view.devicePixelRatio);
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    await Directory(_exportDir).create(recursive: true);
    await File('$_exportDir/$name.png')
        .writeAsBytes(bytes!.buffer.asUint8List());
    image.dispose();
  });
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setupFirebaseCoreMocks();
  setUpAll(() async {
    await Firebase.initializeApp();
    FirebaseAuthPlatform.instance = _SignedOutAuth();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMessageHandler(
      'dev.flutter.pigeon.firebase_analytics_platform_interface.FirebaseAnalyticsHostApi.logEvent',
      (_) async => const StandardMessageCodec().encodeMessage([null]),
    );
    await _loadFonts();
  });
  const viewports = [
    Size(320, 568),
    Size(390, 844),
    Size(810, 1080),
    Size(1440, 900),
  ];
  for (final language in ['fr', 'en', 'cr']) {
    for (final brightness in Brightness.values) {
      for (final size in viewports) {
        final name = '$language-${brightness.name}-${size.width.toInt()}';
        testWidgets('draw history $name', (tester) async {
          _setViewport(tester, size, brightness);
          final key = GlobalKey();
          await tester.pumpWidget(RepaintBoundary(
            key: key,
            child: _app(page: _page(), language: language),
          ));
          await tester.pumpAndSettle();
          final strings = FFLocalizations(Locale(language));
          final view = find.byType(TiragesView);
          final header = find.byType(IllustratedPageHeader);
          final surface = find.descendant(
              of: header,
              matching: find.byWidgetPredicate(
                (w) =>
                    w is DecoratedBox &&
                    w.decoration ==
                        DarkModeTheme().designToken.background.pageHeader(),
              ));
          expect(tester.getSize(surface).width, size.width);

          expect(Theme.of(tester.element(view)).brightness, Brightness.dark);
          if (size.width < 767) {
            expect(
                tester
                    .widget<BottomNavigationBar>(
                        find.byType(BottomNavigationBar))
                    .currentIndex,
                1);
          } else {
            expect(find.byKey(const ValueKey('tirages-desktop-navigation')),
                findsOneWidget);
          }
          expect(
              find.descendant(
                  of: view, matching: find.text(strings.getText('hfwdp6xo'))),
              findsOneWidget);
          expect(find.text('427'), findsOneWidget);
          expect(find.text('09'), findsOneWidget);
          expect(find.text('32'), findsOneWidget);
          expect(find.textContaining(RegExp(r'24.+2026')), findsOneWidget);
          final firstMarket = tester.getCenter(find.text('427'));
          final secondMarket = tester.getCenter(find.text('516'));
          if (size.width == 1440) {
            expect(secondMarket.dy, closeTo(firstMarket.dy, 1));
            expect(secondMarket.dx, greaterThan(firstMarket.dx));
          } else if (size.width < 767) {
            expect(secondMarket.dy, greaterThan(firstMarket.dy));
          }
          if (_exportDir.isNotEmpty) await _savePreview(tester, key, name);
          expect(tester.takeException(), isNull);
        });
      }
    }
  }

  testWidgets('refresh and pagination stay reachable with large text',
      (tester) async {
    _setViewport(tester, const Size(320, 568), Brightness.light);
    var refreshes = 0;
    var pages = 0;
    await tester.pumpWidget(_app(
      language: 'cr',
      textScale: 2,
      page: _page(
        onRefresh: () async {
          refreshes++;
        },
        onLoadMore: () async {
          pages++;
        },
      ),
    ));
    await tester.pumpAndSettle();
    final refresh = find.byKey(const ValueKey('tirages-refresh'));
    expect(refresh.hitTestable(), findsOneWidget);
    expect(tester.getSize(refresh).shortestSide, greaterThanOrEqualTo(48));
    await tester.tap(refresh);
    await tester.pumpAndSettle();
    expect(refreshes, 1);
    final more = find.byKey(const ValueKey('tirages-load-more'));
    await tester.scrollUntilVisible(more.hitTestable(), 280,
        scrollable: find
            .descendant(
                of: find.byType(TiragesView), matching: find.byType(Scrollable))
            .first);
    await tester.pumpAndSettle();
    expect(more.hitTestable(), findsOneWidget);
    await tester.tap(more);
    await tester.pumpAndSettle();
    expect(pages, 1);
    expect(tester.takeException(), isNull);
  });

  testWidgets('pull to refresh and the end of pagination', (tester) async {
    _setViewport(tester, const Size(390, 844), Brightness.dark);
    var calls = 0;
    await tester.pumpWidget(_app(
        page: _page(
      hasMore: false,
      onRefresh: () async {
        calls++;
      },
    )));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('tirages-load-more')), findsNothing);
    await tester.drag(find.byType(CustomScrollView), const Offset(0, 400));
    await tester.pumpAndSettle();
    expect(calls, 1);
  });

  testWidgets('loading, empty and retry states are distinct', (tester) async {
    _setViewport(tester, const Size(390, 844), Brightness.dark);
    await tester.pumpWidget(_app(page: _page(results: [], loading: true)));
    await tester.pump();
    expect(find.byKey(const ValueKey('tirages-loading')), findsOneWidget);
    expect(find.byKey(const ValueKey('tirages-load-more')), findsNothing);
    await tester.pumpWidget(_app(page: _page(results: [])));
    await tester.pumpAndSettle();
    expect(
        find.text('Aucun tirage disponible pour le moment.'), findsOneWidget);
    var calls = 0;
    await tester.pumpWidget(_app(
        page: _page(
      results: [],
      loadFailed: true,
      onRefresh: () async {
        calls++;
      },
    )));
    await tester.pumpAndSettle();
    expect(find.text('Impossible de charger les tirages.'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('tirages-retry')));
    await tester.pumpAndSettle();
    expect(calls, 1);
    expect(tester.takeException(), isNull);
  });
}
