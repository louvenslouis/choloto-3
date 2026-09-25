import 'dart:io';
import 'dart:convert';
import 'dart:ui' as ui;
import 'package:choloto/backend/schema/resultats_record.dart';
import 'package:choloto/tirages/new_yorkk/new_yorkk_widget.dart';
import 'package:choloto/tirages/fl/fl_widget.dart';
import 'package:choloto/flutter_flow/flutter_flow_theme.dart';
import 'package:choloto/flutter_flow/internationalization.dart';
import 'package:firebase_core/firebase_core.dart';
// ignore: depend_on_referenced_packages
import 'package:firebase_core_platform_interface/test.dart';
import 'support/memory_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
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

  const exportDirectory = String.fromEnvironment('LOTTERY_VISUAL_DIR');
  const interFont = String.fromEnvironment('LOTTERY_INTER_FONT');

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

  const assets = {
    'ny': 'New_york',
    'fl': 'Florida',
    'tx': 'Texas',
    'md': 'Maryland',
    'ga': 'Georgia',
    'tn': 'Tennessee',
    'pa': 'Pennsylvania',
    'nj': 'NewJersey',
  };
  testWidgets('new lottery assets have transparent backgrounds',
      (tester) async {
    await tester.runAsync(() async {
      for (final entry
          in assets.entries.where((e) => e.key != 'ny' && e.key != 'fl')) {
        final data = await rootBundle.load('assets/images/${entry.value}.png');
        final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
        final frame = await codec.getNextFrame();
        final image = frame.image;
        expect(image.width, 600);
        expect(image.height, 450);
        final pixels =
            (await image.toByteData(format: ui.ImageByteFormat.rawRgba))!;
        for (final offset in [0, 599, 449 * 600, 450 * 600 - 1]) {
          expect(pixels.getUint8(offset * 4 + 3), 0, reason: entry.value);
        }
        image.dispose();
        codec.dispose();
      }
    });
  });

  for (final language in ['fr', 'en', 'cr']) {
    for (final brightness in Brightness.values) {
      for (final width in [360.0, 1440.0]) {
        testWidgets('lottery logos $language ${brightness.name} $width',
            (tester) async {
          tester.view.physicalSize = Size(width, 568);
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);
          for (final entry in assets.entries) {
            final captureKey = GlobalKey();
            final record = ResultatsRecord.getDocumentFromData({
              'date': DateTime(2026, 9, 24, 12),
              'periode': 'Midi',
              'tirage': entry.key,
              'numeros': ['12', '34', '56'],
            }, MemoryReference('resultats/fixture-${entry.key}'));
            await tester.pumpWidget(MaterialApp(
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
              theme: ThemeData(brightness: brightness),
              home: Builder(
                  builder: (context) => Scaffold(
                        backgroundColor:
                            FlutterFlowTheme.of(context).primaryBackground,
                        body: Align(
                            alignment: Alignment.topCenter,
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: RepaintBoundary(
                                  key: captureKey,
                                  child: entry.key == 'fl'
                                      ? FlWidget(infos: record)
                                      : NewYorkkWidget(
                                          key: ValueKey(entry.key),
                                          infos: record)),
                            )),
                      )),
            ));
            await tester.pumpAndSettle();
            await tester.runAsync(() async {
              for (final element in find.byType(Image).evaluate()) {
                await precacheImage((element.widget as Image).image, element);
              }
            });
            await tester.pumpAndSettle();
            final image = tester.widget<Image>(find.byType(Image).first);
            expect((image.image as AssetImage).assetName,
                'assets/images/${entry.value}.png');
            expect(tester.takeException(), isNull);
            expect(find.text('12'), findsOneWidget);
            if (exportDirectory.isNotEmpty) {
              await tester.runAsync(() async {
                final boundary = captureKey.currentContext!.findRenderObject()!
                    as RenderRepaintBoundary;
                final capture = await boundary.toImage();
                final bytes =
                    await capture.toByteData(format: ui.ImageByteFormat.png);
                await Directory(exportDirectory).create(recursive: true);
                await File(
                        '$exportDirectory/$language-${brightness.name}-${width.toInt()}-${entry.key}.png')
                    .writeAsBytes(bytes!.buffer.asUint8List());
                capture.dispose();
              });
            }
          }
        });
      }
    }
  }
}
