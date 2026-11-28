import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:choloto/components/illustrated_page_header.dart';
import 'package:choloto/flutter_flow/flutter_flow_theme.dart';
import 'package:choloto/flutter_flow/internationalization.dart';
import 'package:choloto/main.dart';
import 'package:choloto/tchala/tchala_data_repository.dart';
import 'package:choloto/tchala/saints_calendar.dart';
import 'package:choloto/tchala/tchala_widget.dart';
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

const _exportDir = String.fromEnvironment('TCHALA_VISUAL_DIR');
const _interFont = String.fromEnvironment('TCHALA_INTER_FONT');

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

Widget _app({
  bool openSaints = false,
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
      home: NavBarPage(
          initialPage: 'Tchala',
          page: TchalaWidget(
              openSaints: openSaints, today: DateTime(2026, 11, 24))),
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

// The catalogue future can already be cached by another route. Let its real
// microtasks and the first frame complete before settling the loading spinner.
Future<void> _settlePage(WidgetTester tester) async {
  await tester.pump();
  await tester.runAsync(() => Future<void>.delayed(Duration.zero));
  await tester.pumpAndSettle();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setupFirebaseCoreMocks();
  setUpAll(() async {
    await Firebase.initializeApp();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMessageHandler(
      'dev.flutter.pigeon.firebase_analytics_platform_interface.FirebaseAnalyticsHostApi.logEvent',
      (_) async => const StandardMessageCodec().encodeMessage([null]),
    );
    await _loadFonts();
    await tchalaDataRepository.reload();
  });

  final tabBar = find.byType(TabBar);
  final search = find.byType(TextField);
  const sizes = [Size(320, 568), Size(390, 844), Size(1440, 900)];
  for (final lang in ['fr', 'en', 'cr']) {
    for (final system in Brightness.values) {
      for (final size in sizes) {
        final variant = '$lang-${system.name}-${size.width.toInt()}';
        testWidgets('symbols and calendar $variant', (tester) async {
          _setViewport(tester, size, system);
          final key = GlobalKey();
          await tester.pumpWidget(
              RepaintBoundary(key: key, child: _app(language: lang)));
          await _settlePage(tester);
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

          expect(Theme.of(tester.element(tabBar)).brightness, Brightness.dark);
          expect(tester.widget<TabBar>(tabBar).controller!.index, 0);
          final primary =
              {'fr': 'Achat', 'cr': 'Achte', 'en': 'Purchase'}[lang]!;
          expect(find.text(primary), findsWidgets);
          if (size.width < 767) {
            expect(
                tester
                    .widget<BottomNavigationBar>(
                        find.byType(BottomNavigationBar))
                    .currentIndex,
                3);
          } else {
            expect(find.byKey(const ValueKey('desktop-tab-Tchala')),
                findsOneWidget);
          }
          if (_exportDir.isNotEmpty) {
            await _savePreview(tester, key, 'symboles-$variant');
          }
          await tester.tap(
              find.descendant(of: tabBar, matching: find.byType(Tab)).last);
          await tester.pumpAndSettle();
          expect(tester.widget<TabBar>(tabBar).controller!.index, 1);
          expect(find.byKey(const ValueKey('saints-focus')), findsOneWidget);
          if (_exportDir.isNotEmpty) {
            await _savePreview(tester, key, 'saints-$variant');
          }
          expect(tester.takeException(), isNull);
        });
      }
    }
  }

  testWidgets(
      'Saints opens on the current month, browses, and searches across the year',
      (tester) async {
    _setViewport(tester, const Size(390, 844), Brightness.dark);
    await tester.pumpWidget(_app(openSaints: true));
    await _settlePage(tester);
    expect(tester.widget<TabBar>(tabBar).controller!.index, 1);
    final picker = find.byKey(const ValueKey('saints-month-picker'));
    final next = find.byKey(const ValueKey('saints-next-month'));
    await tester.ensureVisible(next);
    await tester.tap(next);
    await tester.pumpAndSettle();
    expect(find.textContaining('écembre'), findsWidgets);
    final today = find.byKey(const ValueKey('saints-today'));
    await tester.ensureVisible(today);
    await tester.tap(today);
    await tester.pumpAndSettle();
    expect(find.textContaining('ovembre'), findsWidgets);
    await tester.ensureVisible(picker);
    await tester.tap(picker);
    await tester.pumpAndSettle();
    final january = find.widgetWithText(PopupMenuItem<int>, 'Janvier');
    await tester.ensureVisible(january);
    await tester.tap(january);
    await tester.pumpAndSettle();
    expect(find.text('Janvier 2026'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('saints-previous-month')));
    await tester.pumpAndSettle();
    expect(find.text('Décembre 2025'), findsOneWidget);
    await tester.enterText(search, 'cecile');
    await tester.pumpAndSettle();
    expect(find.textContaining('Cécile'), findsWidgets);
    await tester.enterText(search, '!!!!xyz');
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('saints-no-results')), findsOneWidget);
    await tester.enterText(search, '');
    await tester.pumpAndSettle();
    expect(find.text('Décembre 2025'), findsOneWidget);
    await tester.tap(today);
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('saints-focus')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('a phone keyboard leaves matching symbols visible',
      (tester) async {
    _setViewport(tester, const Size(320, 568), Brightness.dark);
    addTearDown(tester.view.resetViewInsets);
    await tester.pumpWidget(_app());
    await _settlePage(tester);
    await tester.showKeyboard(search);
    tester.view.viewInsets =
        FakeViewPadding(bottom: 250 * tester.view.devicePixelRatio);
    await tester.enterText(search, 'Purchase');
    await tester.pumpAndSettle();
    final purchase = find.text('Achat').hitTestable();
    expect(purchase, findsOneWidget);
    expect(tester.getBottomLeft(purchase).dy, lessThan(568 - 250));
    expect(tester.takeException(), isNull);
  });

  testWidgets('large text keeps both tabs and symbol search usable at 320',
      (tester) async {
    _setViewport(tester, const Size(320, 568), Brightness.light);
    await tester.pumpWidget(_app(language: 'cr', textScale: 2));
    await _settlePage(tester);
    await tester.enterText(search, 'Purchase');
    await tester.pumpAndSettle();
    expect(find.text('Achte'), findsOneWidget);
    await tester
        .tap(find.descendant(of: tabBar, matching: find.byType(Tab)).last);
    await tester.pumpAndSettle();
    expect(tester.widget<TextField>(search).controller!.text, isEmpty);
    expect(find.byKey(const ValueKey('saints-focus')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  testWidgets(
      'annual feast days handle the year boundary, leap day and shared dates',
      (tester) async {
    _setViewport(tester, const Size(390, 844), Brightness.dark);
    const catalogue = [
      SaintMonth(name: 'Janvier', monthNumber: 1, saints: [
        SaintEntry(name: 'Premier', date: '2025-01-01'),
        SaintEntry(name: 'Deuxième', date: '2025-01-01'),
      ]),
      SaintMonth(name: 'Février', monthNumber: 2, saints: [
        SaintEntry(name: 'Fête du 28', date: '2025-02-28'),
        SaintEntry(
            name: 'Auguste Chapdelaine',
            creoleName: 'Ogis Chapdelaine',
            date: '2024-02-29'),
      ]),
    ];
    Future<void> open(DateTime now, String query) async {
      await tester.pumpWidget(MaterialApp(
        locale: const Locale('fr'),
        supportedLocales: const [Locale('fr')],
        localizationsDelegates: const [
          FFLocalizationsDelegate(),
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        theme: DarkModeTheme().materialTheme,
        home: Scaffold(
            body: SaintsCalendar(months: catalogue, today: now, query: query)),
      ));
      await tester.pumpAndSettle();
    }

    final spotlight = find.byKey(const ValueKey('saints-focus'));
    await open(DateTime(2026, 12, 31), '');
    expect(
        find.descendant(
            of: spotlight, matching: find.text('Prochaine célébration')),
        findsOneWidget);
    for (final name in ['Premier', 'Deuxième']) {
      expect(find.descendant(of: spotlight, matching: find.text(name)),
          findsOneWidget);
    }
    await open(DateTime(2027, 1, 1), '01/01');
    expect(find.text('Premier'), findsOneWidget);
    expect(find.text('Deuxième'), findsOneWidget);
    expect(find.text('01'), findsOneWidget);
    await open(DateTime(2027, 2, 28), '');
    expect(find.text('29'), findsNothing);
    for (final name in ['Fête du 28', 'Auguste Chapdelaine']) {
      expect(find.descendant(of: spotlight, matching: find.text(name)),
          findsOneWidget);
    }
    await open(DateTime(2027, 2, 28), '28/02/2027');
    expect(find.text('28'), findsOneWidget);
    expect(find.text('Auguste Chapdelaine'), findsOneWidget);
    expect(find.text('Fête du 28'), findsOneWidget);
    await open(DateTime(2028, 2, 29), '');
    expect(find.descendant(of: spotlight, matching: find.text('Aujourd’hui')),
        findsOneWidget);
    expect(
        find.descendant(
            of: spotlight, matching: find.text('Auguste Chapdelaine')),
        findsOneWidget);
    expect(find.descendant(of: spotlight, matching: find.text('Fête du 28')),
        findsNothing);
    await open(DateTime(2028, 2, 29), '2024-02-29');
    expect(find.text('Février 2024'), findsOneWidget);
    expect(find.text('Auguste Chapdelaine'), findsOneWidget);
    await open(DateTime(2028, 2, 29), '2027-02-29');
    expect(find.byKey(const ValueKey('saints-no-results')), findsOneWidget);
    await open(DateTime(2028, 2, 29), '28 février 2027');
    expect(find.text('Février 2027'), findsOneWidget);
    expect(find.text('Auguste Chapdelaine'), findsOneWidget);
    for (final query in ['saint Auguste', 'St. Chapdelaine', 'Sen Ogis']) {
      await open(DateTime(2028, 2, 29), query);
      expect(find.text('Auguste Chapdelaine'), findsOneWidget);
    }
    expect(tester.takeException(), isNull);
  });
}
