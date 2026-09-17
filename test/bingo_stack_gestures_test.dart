import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:choloto/app_state.dart';
import 'package:choloto/autres/bingo/bingo/bingo_dialog.dart';
import 'package:choloto/autres/bingo/bingo/bingo_widget.dart';
import 'package:choloto/autres/bingo/stackbingo/stackbingo_widget.dart';
import 'package:choloto/backend/schema/structs/index.dart';
import 'package:choloto/flutter_flow/internationalization.dart';
import 'package:firebase_core/firebase_core.dart';
// ignore: depend_on_referenced_packages
import 'package:firebase_core_platform_interface/test.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
// ignore: implementation_imports
import 'package:google_fonts/src/google_fonts_base.dart' as font_testing;
import 'package:provider/provider.dart';

class _TestFontManifest extends Fake implements AssetManifest {
  @override
  List<String> listAssets() => [
        '__test_fonts/Inter-Regular.ttf',
        '__test_fonts/Inter-Medium.ttf',
        '__test_fonts/Inter-SemiBold.ttf',
        '__test_fonts/Inter-Bold.ttf',
        '__test_fonts/Raleway-Black.ttf',
        '__test_fonts/ChangaOne-Regular.ttf',
      ];
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setupFirebaseCoreMocks();
  const exportDirectory = String.fromEnvironment('BINGO_STACK_VISUAL_DIR');

  setUpAll(() async {
    await Firebase.initializeApp();
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    messenger.setMockMessageHandler(
      'dev.flutter.pigeon.firebase_analytics_platform_interface.FirebaseAnalyticsHostApi.logEvent',
      (_) async => const StandardMessageCodec().encodeMessage([null]),
    );
    final font = await rootBundle.load(
        'assets/fonts/GoogleSansFlex-VariableFont_GRAD,ROND,opsz,slnt,wdth,wght.ttf');
    font_testing.assetManifest = _TestFontManifest();
    messenger.setMockMessageHandler('flutter/assets', (message) async {
      final path = utf8.decode(message!.buffer.asUint8List());
      if (path.startsWith('__test_fonts/')) return font;
      return ByteData.sublistView(
          File('build/unit_test_assets/$path').readAsBytesSync());
    });
    await (FontLoader('Google sans flex')..addFont(Future.value(font))).load();
    await (FontLoader('MaterialIcons')
          ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf')))
        .load();
    await GoogleFonts.pendingFonts([
      GoogleFonts.inter(),
      GoogleFonts.inter(fontWeight: FontWeight.w500),
      GoogleFonts.inter(fontWeight: FontWeight.w600),
      GoogleFonts.inter(fontWeight: FontWeight.w700),
      GoogleFonts.raleway(fontWeight: FontWeight.w900),
      GoogleFonts.changaOne(),
    ]);
  });

  for (final language in ['fr', 'en', 'cr']) {
    for (final brightness in [Brightness.dark, Brightness.light]) {
      for (final width in [320.0, 1280.0]) {
        testWidgets('real Bingo stack gestures $language $brightness $width',
            (tester) async {
          tester.view.physicalSize = Size(width, 720);
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);
          final captureKey = GlobalKey();
          var previousStories = 0;
          var nextStories = 0;
          final data = [
            for (final number in ['11', '22', '33'])
              DataStackStruct(
                  boul: number,
                  valeur: 'Loto 3',
                  tirage: 'Florida',
                  periode: 'Midi'),
          ];
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
                home: Scaffold(
                  body: BingoStatusFrame(
                    onPreviousStory: () => previousStories++,
                    onNextStory: () => nextStories++,
                    onClose: () {},
                    storyCount: 3,
                    foregroundChild: BingoStackLayer(dataStack: data),
                    child: BingoWidget(dataStack: data, showStackLayer: false),
                  ),
                ),
              ),
            ),
          ));
          await tester
              .runAsync(() async => Future<void>.delayed(Duration.zero));
          await tester.pump();
          await tester.runAsync(() async {
            for (final asset in [
              'assets/images/bg_bingo_-_Moyenne.jpeg',
              'assets/images/bingo-loto-3.png',
              'assets/images/sun.png',
            ]) {
              await precacheImage(AssetImage(asset),
                  tester.element(find.byType(StackbingoWidget)));
            }
          });
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 950));
          final swiper = tester.widget<CardSwiper>(find.byType(CardSwiper));
          expect(swiper.padding,
              const EdgeInsets.symmetric(horizontal: 20, vertical: 25));
          final cards = find.descendant(
              of: find.byType(CardSwiper), matching: find.byType(Card));
          void expectFront(String number) {
            expect(find.descendant(of: cards.last, matching: find.text(number)),
                findsOneWidget);
          }

          expectFront('11');
          if (exportDirectory.isNotEmpty) {
            final boundary = captureKey.currentContext!.findRenderObject()!
                as RenderRepaintBoundary;
            final picture = (await tester.runAsync(() => boundary.toImage()))!;
            final bytes = await tester.runAsync(
                () => picture.toByteData(format: ui.ImageByteFormat.png));
            await tester.runAsync(() async {
              final file = File(
                  '$exportDirectory/$language-${brightness.name}-${width.toInt()}.png');
              await file.parent.create(recursive: true);
              await file.writeAsBytes(bytes!.buffer.asUint8List());
            });
            picture.dispose();
          }

          final zone = tester.getRect(find.byType(StackbingoWidget));
          // Include the padding and exposed rear cards, not only the front card.
          final starts = [
            Offset(zone.center.dx, zone.top + 8),
            Offset(zone.center.dx, zone.bottom - 8),
            Offset(zone.left + 8, zone.center.dy),
            Offset(zone.right - 8, zone.center.dy),
            zone.center,
          ];
          for (var i = 0; i < starts.length; i++) {
            await tester.dragFrom(starts[i], Offset(i.isEven ? 44 : -44, 5));
            await tester.pump();
            await tester.pump(const Duration(milliseconds: 250));
            await tester.pump();
            expectFront(['22', '33', '11'][i % 3]);
            expect(previousStories, 0);
            expect(nextStories, 0);
          }

          // Taps and vertical motions in the pile must not advance a story.
          await tester.tapAt(zone.center);
          await tester.dragFrom(zone.center, const Offset(8, 2));
          await tester.dragFrom(zone.center, const Offset(0, 40));
          await tester.pump();
          expectFront('33');
          expect(previousStories, 0);
          expect(nextStories, 0);

          // Automatic rotation must not race a held/cancelled manual swipe.
          final heldSwipe = await tester.startGesture(zone.center);
          await heldSwipe.moveBy(const Offset(30, 0));
          await tester.pump(const Duration(seconds: 3));
          expectFront('33');
          await heldSwipe.cancel();
          await tester.pump();
          expectFront('33');

          final frame =
              tester.getRect(find.byKey(const ValueKey('bingo-status-frame')));
          final left = Offset(frame.left + 40, frame.top + 160);
          final right = Offset(frame.right - 40, frame.top + 160);
          await tester.tapAt(left);
          await tester.tapAt(right);
          await tester.flingFrom(left, const Offset(150, 0), 1000);
          await tester.flingFrom(right, const Offset(-150, 0), 1000);
          await tester.pump();
          expect(previousStories, 2);
          expect(nextStories, 2);
          expect(tester.takeException(), isNull);
          await tester.pumpWidget(const SizedBox.shrink());
          await tester.pump(const Duration(seconds: 3));
        });
      }
    }
  }
}
