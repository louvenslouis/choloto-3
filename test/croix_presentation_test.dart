import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:choloto/backend/schema/croix_record.dart';
import 'package:choloto/components/cross_poster_heading.dart';
import 'package:choloto/components/cross_widget.dart';
import 'package:choloto/croix/croix_widget.dart';
import 'package:choloto/flutter_flow/flutter_flow_theme.dart';
import 'package:choloto/flutter_flow/internationalization.dart';
import 'package:firebase_core/firebase_core.dart';
// ignore: depend_on_referenced_packages
import 'package:firebase_core_platform_interface/test.dart';
import 'package:flutter/foundation.dart' show listEquals;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
// ignore: implementation_imports
import 'package:google_fonts/src/google_fonts_base.dart' as font_testing;
import 'package:image/image.dart' as image;
// ignore: depend_on_referenced_packages
import 'package:share_plus_platform_interface/share_plus_platform_interface.dart';

import 'support/memory_firestore.dart';

const _output = String.fromEnvironment('CROIX_VISUAL_DIR');
const _interDirectory = String.fromEnvironment('CROIX_INTER_DIR');
const _headingFont =
    'assets/fonts/GoogleSansFlex-VariableFont_GRAD,ROND,opsz,slnt,wdth,wght.ttf';
const _localizations = <LocalizationsDelegate<dynamic>>[
  FFLocalizationsDelegate(),
  GlobalMaterialLocalizations.delegate,
  GlobalWidgetsLocalizations.delegate,
  GlobalCupertinoLocalizations.delegate,
  FallbackMaterialLocalizationDelegate(),
  FallbackCupertinoLocalizationDelegate(),
];
const _numbers = [
  '07',
  '14',
  '26',
  '31',
  'CENTRE',
  '45',
  '58',
  '63',
  '80',
  'EXTRA'
];

class _PresentationBinding extends AutomatedTestWidgetsFlutterBinding {
  @override
  bool get disableShadows => false;
}

class _Fonts extends Fake implements AssetManifest {
  @override
  List<String> listAssets() => [
        for (final weight in [
          'Light',
          'Regular',
          'Medium',
          'SemiBold',
          'Bold',
          'ExtraBold',
          'Black'
        ])
          '__test_fonts/Inter-$weight.ttf',
      ];
}

class _ShareSheet extends SharePlatform {
  final captures = <Uint8List>[];
  String? subject;
  Rect? origin;

  @override
  Future<ShareResult> shareXFiles(List<XFile> files,
      {String? subject,
      String? text,
      Rect? sharePositionOrigin,
      List<String>? fileNameOverrides}) async {
    expect(fileNameOverrides, ['croix-de-la-chance.jpg']);
    expect(files.single.mimeType, 'image/jpeg');
    this.subject = subject;
    origin = sharePositionOrigin;
    captures.add(await files.single.readAsBytes());
    return const ShareResult('', ShareResultStatus.success);
  }
}

// Independently delay the real image that must be present in the shared JPEG.
// A separate bundle also prevents other tests' decoded images from skipping it.
class _DelayedArtwork extends CachingAssetBundle {
  final ready = Completer<void>();
  bool requested = false;

  @override
  Future<ByteData> load(String key) async {
    if (key == CrossWidget.artworkAsset) {
      requested = true;
      await ready.future;
    }
    return rootBundle.load(key);
  }
}

CroixRecord _record(List<String> numbers, {DateTime? date}) =>
    CroixRecord.getDocumentFromData({
      if (date != null) 'date': date,
      'numeros': numbers,
    }, MemoryReference('croix/published'));

Widget _screen(Stream<List<CroixRecord>> records,
        {String language = 'fr',
        double scale = 1,
        GlobalKey? captureKey,
        AssetBundle? assets}) =>
    MaterialApp(
      debugShowCheckedModeBanner: false,
      supportedLocales: const [Locale('fr'), Locale('en'), Locale('cr')],
      locale: Locale(language),
      localizationsDelegates: _localizations,
      theme: DarkModeTheme().materialTheme,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context)
            .copyWith(textScaler: TextScaler.linear(scale)),
        child: RepaintBoundary(key: captureKey, child: child!),
      ),
      home: DefaultAssetBundle(
        bundle: assets ?? rootBundle,
        child: CroixWidget(records: records),
      ),
    );

void _viewport(WidgetTester tester, Size size, Brightness system) {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = size;
  tester.view.padding = FakeViewPadding(
      top: size.width < 600 ? 24 : 0, bottom: size.width == 390 ? 24 : 0);
  tester.binding.platformDispatcher.platformBrightnessTestValue = system;
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetPadding);
  addTearDown(
      tester.binding.platformDispatcher.clearPlatformBrightnessTestValue);
}

Finder _slot(int index) => find.byKey(ValueKey('croix-slot-$index'));
final _waveTrigger = find.byKey(const ValueKey('croix-wave-trigger'));
final _waveRing = find.byKey(const ValueKey('croix-wave-ring'));

void _expectFooter(image.Image jpeg, int top, double scale) {
  final background = jpeg.getPixel(2, (top + jpeg.height) ~/ 2);
  final paper = Color.fromARGB(
          255, background.r.toInt(), background.g.toInt(), background.b.toInt())
      .computeLuminance();
  expect(paper, lessThan(.05),
      reason: 'The export footer uses a dark background');

  Rect? lettering;
  var samples = 0;
  var dark = 0;
  for (var y = top + 2; y < jpeg.height - 2; y += 2) {
    for (var x = 2; x < jpeg.width - 2; x += 2) {
      final p = jpeg.getPixel(x, y);
      final ink = Color.fromARGB(255, p.r.toInt(), p.g.toInt(), p.b.toInt())
          .computeLuminance();
      samples++;
      if (ink < .07) dark++;
      if ((ink + .05) / (paper + .05) >= 4.5) {
        final point = Rect.fromLTWH(x.toDouble(), y.toDouble(), 1, 1);
        lettering = lettering?.expandToInclude(point) ?? point;
      }
    }
  }
  expect(dark / samples, greaterThan(.75));
  expect(lettering, isNotNull,
      reason: 'The exported footer has legible light lettering');
  final text = lettering!;
  expect(text.center.dx, closeTo(jpeg.width / 2, 3 * scale));
  expect(text.width / scale, greaterThan(60));
  expect(text.height / scale, greaterThan(7));
  expect(text.top, greaterThan(top + 2 * scale));
  expect(text.bottom, lessThan(jpeg.height - 2 * scale));
}

void _expectSharedPoster(WidgetTester tester, Uint8List jpegBytes) {
  final emblem = find.descendant(of: _slot(4), matching: find.byType(Image));
  final artwork = tester.widget<Image>(emblem);
  expect(artwork.image,
      const AssetImage('assets/images/home/lucky_cross_3d_x.png'));
  expect(artwork.color, isNull);
  expect(find.ancestor(of: emblem, matching: find.byType(ColorFiltered)),
      findsNothing);

  final jpeg = image.decodeJpg(jpegBytes)!;
  final poster = tester.getRect(find.byType(CrossWidget));
  final scale = jpeg.width / poster.width;
  final cardHeight = (poster.height * scale).ceil();
  _expectFooter(jpeg, cardHeight, scale);
  final labels = find.descendant(
      of: find.byType(CrossPosterHeading), matching: find.byType(Text));
  final captions = [
    for (var i = 0; i < labels.evaluate().length; i++)
      (
        bounds: tester.getRect(labels.at(i)).shift(-poster.topLeft),
        ink: tester.widget<Text>(labels.at(i)).style!.color!,
        contrasts: <double>[],
      ),
  ];
  var samples = 0;
  var yellow = 0;
  // Sample the entire exported card so a yellow border or emblem alone cannot pass.
  for (var y = 5; y < cardHeight; y += 11) {
    for (var x = 5; x < jpeg.width; x += 11) {
      samples++;
      final p = jpeg.getPixel(x, y);
      final color = Color.fromARGB(255, p.r.toInt(), p.g.toInt(), p.b.toInt());
      final hsv = HSVColor.fromColor(color);
      if (hsv.hue < 40 ||
          hsv.hue > 70 ||
          hsv.saturation < .30 ||
          hsv.value < .40) {
        continue;
      }
      yellow++;
      for (final caption in captions) {
        if (caption.bounds.contains(Offset(x / scale, y / scale))) {
          final paper = color.computeLuminance();
          final ink = Color.alphaBlend(caption.ink, color).computeLuminance();
          final ratio = (paper + .05) / (ink + .05);
          caption.contrasts.add(ratio >= 1 ? ratio : 1 / ratio);
        }
      }
    }
  }
  expect(yellow / samples, greaterThan(.50),
      reason: 'Yellow covers most of the shared card');
  for (final caption in captions) {
    // Ignore the JPEG fringes of dark glyphs when sampling their backdrop.
    final contrasts = caption.contrasts..sort();
    expect(contrasts, isNotEmpty);
    expect(contrasts[contrasts.length ~/ 10], greaterThanOrEqualTo(4.5),
        reason: 'Each heading remains legible on the yellow material');
  }
}

void _expectCompleteText(WidgetTester tester, Finder label) {
  final paragraph = tester.renderObject<RenderParagraph>(label);
  expect(paragraph.didExceedMaxLines, isFalse);
  final lastCharacter = paragraph.text.toPlainText().length - 1;
  final glyph = paragraph.getBoxesForSelection(TextSelection(
      baseOffset: lastCharacter, extentOffset: lastCharacter + 1));
  expect(glyph, isNotEmpty);
  final textBounds = (Offset.zero & paragraph.size).inflate(1);
  expect(textBounds.contains(glyph.last.toRect().center), isTrue);
}

Future<void> _export(WidgetTester tester, GlobalKey key, String name) async {
  await tester.runAsync(() async {
    final boundary =
        key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    final picture = await boundary.toImage();
    try {
      final bytes = await picture.toByteData(format: ui.ImageByteFormat.png);
      final file = File('$_output/$name.png');
      await file.parent.create(recursive: true);
      await file.writeAsBytes(Uint8List.sublistView(bytes!));
    } finally {
      picture.dispose();
    }
  });
}

void main() {
  _PresentationBinding();
  setupFirebaseCoreMocks();
  setUpAll(() async {
    await Firebase.initializeApp();
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    messenger.setMockMessageHandler(
      'dev.flutter.pigeon.firebase_analytics_platform_interface.FirebaseAnalyticsHostApi.logEvent',
      (_) async => const StandardMessageCodec().encodeMessage([null]),
    );
    final bundledFont = await rootBundle.load(_headingFont);
    font_testing.assetManifest = _Fonts();
    messenger.setMockMessageHandler('flutter/assets', (message) async {
      final path = utf8.decode(Uint8List.sublistView(message!));
      if (path.startsWith('__test_fonts/')) {
        final variant = File('$_interDirectory/${path.split('/').last}');
        if (_interDirectory.isNotEmpty && variant.existsSync()) {
          return ByteData.sublistView(variant.readAsBytesSync());
        }
        return bundledFont;
      }
      return ByteData.sublistView(
          File('build/unit_test_assets/$path').readAsBytesSync());
    });
    await (FontLoader('Google sans flex')..addFont(Future.value(bundledFont)))
        .load();
    await (FontLoader('MaterialIcons')
          ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf')))
        .load();
  });

  final published = _record(_numbers, date: DateTime(2026, 11, 25));
  testWidgets(
      'The wave reaches adjacent values before the corners, settles and replays',
      (tester) async {
    _viewport(tester, const Size(390, 844), Brightness.dark);
    final key = GlobalKey();
    await tester
        .pumpWidget(_screen(Stream.value([published]), captureKey: key));
    await tester.pumpAndSettle();
    final context = tester.element(_waveTrigger);
    await tester.runAsync(() => Future.wait([
          precacheImage(const AssetImage(CrossWidget.artworkAsset), context),
          precacheImage(const AssetImage(CrossWidget.textureAsset), context),
        ]));
    await tester.pumpAndSettle();
    final origin = tester.getCenter(_waveTrigger);
    const adjacent = [1, 3, 5, 7];
    const corners = [0, 2, 6, 8];
    Offset position(int slot) => tester.getCenter(find.text(_numbers[slot]));
    final rest = {
      for (final slot in [...adjacent, ...corners]) slot: position(slot)
    };
    void expectAtRest(Iterable<int> slots) {
      for (final slot in slots) {
        expect((position(slot) - rest[slot]!).distance, lessThan(.1));
      }
    }

    void expectPushed(Iterable<int> slots) {
      for (final slot in slots) {
        expect((position(slot) - origin).distance,
            greaterThan((rest[slot]! - origin).distance + .75),
            reason: 'Published value ${_numbers[slot]} moves away from the X');
      }
    }

    expect(_waveRing, findsNothing);
    if (_output.isNotEmpty) await _export(tester, key, 'frames/000');
    await tester.tap(_waveTrigger);
    await tester.pump();
    var elapsed = 0;
    final timings = {
      120,
      230,
      400,
      860,
      if (_output.isNotEmpty)
        for (var t = 40; t <= 840; t += 40) t,
    }.toList()
      ..sort();
    for (final t in timings) {
      await tester.pump(Duration(milliseconds: t - elapsed));
      elapsed = t;
      if (t == 120) {
        expect(_waveRing, findsOneWidget);
        expectAtRest(rest.keys);
      } else if (t == 230) {
        expectPushed(adjacent);
        expectAtRest(corners);
      } else if (t == 400) {
        expectPushed(corners);
      }
      if (_output.isNotEmpty) {
        await _export(tester, key, 'frames/${t.toString().padLeft(3, '0')}');
      }
    }
    expectAtRest(rest.keys);
    expect(tester.getCenter(_waveTrigger), origin);
    await tester.tap(_waveTrigger);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 230));
    expectPushed(adjacent);
    await tester.tap(_waveTrigger);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 120));
    expect(_waveRing, findsOneWidget);
    expectAtRest(rest.keys);
    await tester.pump(const Duration(milliseconds: 110));
    expectPushed(adjacent);
    await tester.pumpAndSettle();
    expect(_waveRing, findsNothing);
    expectAtRest(rest.keys);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
      'An incomplete board keeps its empty slots, and respects reduced motion',
      (tester) async {
    _viewport(tester, const Size(390, 844), Brightness.dark);
    final sparse = _record(['', '14', ' ', '', 'HIDDEN', '45']);
    await tester.pumpWidget(_screen(Stream.value([sparse])));
    await tester.pumpAndSettle();
    final first = find.text('14');
    final idle = tester.getCenter(first);
    await tester.tap(_waveTrigger);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 230));
    expect((tester.getCenter(first) - idle).distance, greaterThan(.75));
    for (final i in [0, 2, 3, 6, 7, 8]) {
      expect(find.descendant(of: _slot(i), matching: find.byType(Text)),
          findsNothing);
    }
    expect(find.text('HIDDEN'), findsNothing);
    await tester.pumpAndSettle();
    final dispatcher = tester.binding.platformDispatcher;
    dispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(disableAnimations: true);
    addTearDown(dispatcher.clearAccessibilityFeaturesTestValue);
    await tester.pump();
    await tester.tap(_waveTrigger);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 230));
    expect(_waveRing, findsNothing);
    expect(tester.getCenter(first), idle);
    expect(tester.takeException(), isNull);
  });
  testWidgets('Back exits direct and pushed visits to Croix', (tester) async {
    final router = GoRouter(initialLocation: '/croix', routes: [
      GoRoute(path: '/', builder: (_, __) => const SizedBox(key: Key('home'))),
      GoRoute(
          path: '/previous',
          builder: (_, __) => const SizedBox(key: Key('previous'))),
      GoRoute(
          path: '/croix',
          builder: (_, __) => CroixWidget(records: Stream.value([published]))),
    ]);
    addTearDown(router.dispose);
    await tester.pumpWidget(MaterialApp.router(
      routerConfig: router,
      locale: const Locale('fr'),
      supportedLocales: const [Locale('fr')],
      localizationsDelegates: _localizations,
      theme: DarkModeTheme().materialTheme,
    ));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Retour'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('home')), findsOneWidget);
    router.go('/previous');
    await tester.pumpAndSettle();
    router.push('/croix');
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Retour'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('previous')), findsOneWidget);
  });
  for (final language in FFLocalizations.languages()) {
    for (final system in Brightness.values) {
      for (final size in [
        const Size(320, 640),
        const Size(390, 844),
        const Size(1440, 900)
      ]) {
        final scale = size.width == 320 ? 2.0 : 1.0;
        testWidgets(
            'Board preserves its nine positions in $language at ${size.width} / ${system.name} / $scale×',
            (tester) async {
          _viewport(tester, size, system);
          final key = GlobalKey();
          await tester.pumpWidget(_screen(Stream.value([published]),
              language: language, scale: scale, captureKey: key));
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
          final board = find.byType(CrossWidget);
          expect(board, findsOneWidget);
          final context = tester.element(board);
          expect(Theme.of(context).brightness, Brightness.dark);
          final loc = FFLocalizations.of(context);
          final title = loc.getText('63dg2p5g');
          final titleLabel =
              find.descendant(of: board, matching: find.text(title));
          final date = {
            'fr': 'mercredi 25 novembre 2026',
            'en': 'Wednesday, November 25, 2026',
            'cr': 'mèkredi 25 novanm 2026',
          }[language]!;
          final dateLabel =
              find.descendant(of: board, matching: find.text(date));
          expect(
              find.bySemanticsLabel({
                'fr': 'Animer la croix',
                'en': 'Animate the cross',
                'cr': 'Anime kwa a',
              }[language]!),
              findsOneWidget);
          final shareLabel = find.text({
            'fr': 'Partager le visuel',
            'en': 'Share image',
            'cr': 'Pataje imaj la',
          }[language]!);
          for (final label in [titleLabel, dateLabel, shareLabel]) {
            expect(label, findsOneWidget);
            _expectCompleteText(tester, label);
          }
          expect(tester.getRect(titleLabel).bottom,
              lessThanOrEqualTo(tester.getRect(dateLabel).top));
          expect(tester.getRect(dateLabel).bottom,
              lessThan(tester.getRect(_slot(0)).top));
          final share = find.byTooltip(loc.getText('croixsharetitle'));
          expect(share, findsOneWidget);
          final button = tester.widget<ElevatedButton>(find.descendant(
              of: share, matching: find.bySubtype<ElevatedButton>()));
          final theme = FlutterFlowTheme.of(context);
          expect(button.style!.backgroundColor!.resolve({}), theme.primary);
          expect(button.style!.foregroundColor!.resolve({}), theme.onPrimary);
          expect(loc.getText('croix_share_domain'), 'app.choloto.com');
          expect(find.text('app.choloto.com', findRichText: true), findsNothing,
              reason: 'The address belongs to the exported image');
          final boardRegion = tester.getRect(board);
          for (final label in [titleLabel, dateLabel]) {
            expect(
                tester.getCenter(label).dx, closeTo(boardRegion.center.dx, 1));
          }
          expect(tester.getRect(shareLabel).top,
              greaterThanOrEqualTo(boardRegion.bottom));
          expect(tester.getSize(share).height, greaterThanOrEqualTo(48));
          expect(boardRegion.left, greaterThanOrEqualTo(0));
          expect(boardRegion.right, lessThanOrEqualTo(size.width));
          expect(find.text('CENTRE'), findsNothing);
          expect(find.text('EXTRA'), findsNothing);
          final cells = <Rect>[];
          for (var i = 0; i < 9; i++) {
            final cell = _slot(i);
            final rect = tester.getRect(cell);
            expect(boardRegion.contains(rect.center), isTrue);
            if (i % 3 > 0) {
              expect(rect.center.dx, greaterThan(cells.last.center.dx));
              expect(rect.center.dy, closeTo(cells.last.center.dy, 1));
            }
            if (i >= 3) {
              expect(rect.center.dy, greaterThan(cells[i - 3].center.dy));
              expect(rect.center.dx, closeTo(cells[i - 3].center.dx, 1));
            }
            if (i != 4) {
              final number =
                  find.descendant(of: cell, matching: find.text(_numbers[i]));
              expect(number, findsOneWidget);
              expect(rect.contains(tester.getCenter(number)), isTrue);
            }
            cells.add(rect);
          }
          if (_output.isNotEmpty &&
              language == 'fr' &&
              system == Brightness.dark &&
              size.width != 320) {
            await tester.runAsync(() async {
              await Future.wait(find.byType(Image).evaluate().map((element) =>
                  precacheImage((element.widget as Image).image, element)));
            });
            await tester.pumpAndSettle();
            await _export(
                tester, key, size.width == 390 ? 'croix-mobile' : 'croix-web');
          }
        });
      }
    }
  }

  testWidgets(
      'Live stream preserves empty positions and clears a withdrawn or failed publication',
      (tester) async {
    _viewport(tester, const Size(320, 640), Brightness.dark);
    final records = StreamController<List<CroixRecord>>.broadcast();
    addTearDown(records.close);
    await tester.pumpWidget(_screen(records.stream, scale: 2));
    await tester.pump();
    final loc = FFLocalizations.of(tester.element(find.byType(CroixWidget)));
    final share = find.byTooltip(loc.getText('croixsharetitle'));
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(share, findsNothing);
    records.add([]);
    await tester.pumpAndSettle();
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.byType(CrossWidget), findsNothing);
    expect(find.text(loc.getText('croix_empty')), findsOneWidget);
    expect(share, findsNothing);
    records.add([
      _record(['00', '', '05', '12345 67890'])
    ]);
    await tester.pumpAndSettle();
    final board = find.byType(CrossWidget);
    final undatedTitle = find.descendant(
        of: board, matching: find.text(loc.getText('63dg2p5g')));
    expect(undatedTitle, findsOneWidget);
    _expectCompleteText(tester, undatedTitle);
    expect(
        find.descendant(
            of: find.byType(CrossPosterHeading), matching: find.byType(Text)),
        findsOneWidget);
    expect(find.descendant(of: _slot(0), matching: find.text('00')),
        findsOneWidget);
    expect(find.descendant(of: _slot(2), matching: find.text('05')),
        findsOneWidget);
    expect(find.descendant(of: _slot(3), matching: find.text('12345 67890')),
        findsOneWidget);
    expect(find.descendant(of: _slot(1), matching: find.byType(Text)),
        findsNothing);
    for (var i = 0; i < 9; i++) {
      expect(_slot(i), findsOneWidget);
    }
    records.addError(StateError('internal test sentinel'));
    await tester.pumpAndSettle();
    expect(find.byType(CrossWidget), findsNothing);
    expect(find.text(loc.getText('croix_unavailable')), findsOneWidget);
    expect(find.text(loc.getText('viphstrty')), findsOneWidget);
    expect(share, findsNothing);
    expect(find.textContaining('internal test sentinel'), findsNothing);
    await tester.tap(find.text(loc.getText('viphstrty')));
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    records.add([published]);
    await tester.pumpAndSettle();
    expect(find.text('07'), findsOneWidget);
    records.add([]);
    await tester.pumpAndSettle();
    expect(find.text('07'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
      'One native tap shares even before the JPEG is ready and always uses the current board',
      (tester) async {
    final sheet = _ShareSheet();
    final previous = SharePlatform.instance;
    SharePlatform.instance = sheet;
    addTearDown(() => SharePlatform.instance = previous);
    _viewport(tester, const Size(390, 844), Brightness.dark);
    final records = StreamController<List<CroixRecord>>();
    addTearDown(records.close);
    final artwork = _DelayedArtwork();
    await tester.pumpWidget(_screen(records.stream, assets: artwork));
    records.add([published]);
    await tester.pump();
    await tester.pump();

    Future<void> share(int previousCount) async {
      final shareButton = find.byTooltip('Partager la Croix de la Chance');
      await tester.ensureVisible(shareButton);
      await tester.tap(shareButton);
      await tester.pump();
      if (previousCount == 0) {
        expect(artwork.requested, isTrue);
        expect(sheet.captures, isEmpty);
        artwork.ready.complete();
      }
      // Real rasterization completes outside the widget test's fake clock.
      for (var attempt = 0;
          attempt < 90 && sheet.captures.length == previousCount;
          attempt++) {
        await tester.runAsync(
            () => Future<void>.delayed(const Duration(milliseconds: 12)));
        await tester.pump(const Duration(milliseconds: 16));
      }
      expect(sheet.captures, hasLength(previousCount + 1));
      final jpeg = image.JpegDecoder().startDecode(sheet.captures.last)!;
      final board = tester.getSize(find.byType(CrossWidget));
      expect(jpeg.width, closeTo(board.width * 3, 1));
      expect((jpeg.height - (board.height * 3).ceil()) / 3,
          inInclusiveRange(32, 48),
          reason: 'The address fits in an additional band below the full card');
      expect(sheet.subject, 'Partager la Croix de la Chance');
      expect(sheet.origin!.isEmpty, isFalse);
    }

    final number = find.text('14');
    final restingPosition = tester.getCenter(number);
    await tester.tap(_waveTrigger);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 230));
    expect((tester.getCenter(number) - restingPosition).distance,
        greaterThan(.75));
    await share(0);
    expect(tester.getCenter(number), restingPosition);
    _expectSharedPoster(tester, sheet.captures.single);
    if (_output.isNotEmpty) {
      await tester.runAsync(() async {
        await Directory(_output).create(recursive: true);
        await File('$_output/croix-partage.jpg')
            .writeAsBytes(sheet.captures.single);
      });
    }
    // Withdraw and republish the same values to take an independent, idle
    // capture at the original size. The cold share must be identical to it.
    records.add([]);
    await tester.pumpAndSettle();
    records.add([published]);
    await tester.pumpAndSettle();
    await share(1);
    expect(listEquals(sheet.captures[0], sheet.captures[1]), isTrue,
        reason: 'Sharing during the wave must deliver the unanimated poster');

    tester.view.physicalSize = const Size(320, 640);
    await tester.pumpAndSettle();
    await share(2);
    expect(sheet.captures[1], isNot(orderedEquals(sheet.captures[2])));
    records.add([
      _record(['99', ..._numbers.skip(1)], date: published.date)
    ]);
    await tester.pumpAndSettle();
    await share(3);
    expect(sheet.captures[3], isNot(orderedEquals(sheet.captures[2])));
    expect(tester.takeException(), isNull);
  });
}
