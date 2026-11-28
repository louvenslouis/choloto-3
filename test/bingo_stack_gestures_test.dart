import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:choloto/app_state.dart';
import 'package:choloto/autres/bingo/bingo/bingo_dialog.dart';
import 'package:choloto/autres/bingo/bingo/bingo_widget.dart';
import 'package:choloto/autres/bingo/stackbingo/bingo_story_result_ticket.dart';
import 'package:choloto/autres/bingo/stackbingo/stackbingo_widget.dart';
import 'package:choloto/backend/schema/structs/index.dart';
import 'package:choloto/flutter_flow/flutter_flow_theme.dart';
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
      ];
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setupFirebaseCoreMocks();
  const exportDirectory = String.fromEnvironment('BINGO_STACK_VISUAL_DIR');

  const interFontPath = String.fromEnvironment('BINGO_INTER_FONT');

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
    final interFont = interFontPath.isEmpty
        ? font
        : ByteData.sublistView(await File(interFontPath).readAsBytes());
    font_testing.assetManifest = _TestFontManifest();
    messenger.setMockMessageHandler('flutter/assets', (message) async {
      final path = utf8.decode(message!.buffer.asUint8List());
      if (path.startsWith('__test_fonts/')) return interFont;
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
    ]);
  });

  testWidgets('an empty publication keeps its artwork without a result',
      (tester) async {
    await tester.pumpWidget(ChangeNotifierProvider.value(
      value: FFAppState(),
      child: const MaterialApp(
        supportedLocales: [Locale('en')],
        localizationsDelegates: [FFLocalizationsDelegate()],
        home: Scaffold(body: Center(child: BingoWidget(dataStack: []))),
      ),
    ));
    await tester.pump();
    expect(find.byType(BingoStoryResultTicket), findsNothing);
    expect(find.byType(CardSwiper), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('a single Boloto keeps its full value at 200% text scale',
      (tester) async {
    final entry = DataStackStruct(
      boul: '68-12-34',
      valeur: 'BOLOTO',
      tirage: 'NEW YORK',
      periode: 'Soir',
    );
    await tester.pumpWidget(MaterialApp(
      supportedLocales: const [Locale('en')],
      localizationsDelegates: const [FFLocalizationsDelegate()],
      home: Scaffold(
        body: MediaQuery(
          data: const MediaQueryData(textScaler: TextScaler.linear(2)),
          child: Center(
            child: SizedBox.square(
              dimension: 292,
              child: BingoStoryResultTicket(entry: entry, count: 1),
            ),
          ),
        ),
      ),
    ));
    await tester.pump();
    final ticket = find.byType(BingoStoryResultTicket);
    final value = find.text(entry.boul, findRichText: true);
    expect(value, findsWidgets);
    expect(find.byKey(const ValueKey('bingo-story-stacked')), findsOneWidget);
    expect(find.text('×1'), findsNothing);
    expect(find.bySemanticsLabel(RegExp('68-12-34.*BOLOTO.*NEW YORK')),
        findsOneWidget);
    final hit = tester.getRect(value.first);
    final frame = tester.getRect(ticket);
    expect(
        frame.contains(hit.topLeft) && frame.contains(hit.bottomRight), isTrue);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
      'reduced motion stops automatic rotation and preserves manual swipes',
      (tester) async {
    final entries = [DataStackStruct(boul: '27'), DataStackStruct(boul: '107')];
    Future<void> setMotion(bool reduced) => tester.pumpWidget(MaterialApp(
          supportedLocales: const [Locale('en')],
          localizationsDelegates: const [FFLocalizationsDelegate()],
          home: Scaffold(
            body: Center(
              child: SizedBox.square(
                dimension: 320,
                child: MediaQuery(
                  data: MediaQueryData(disableAnimations: reduced),
                  child: StackbingoWidget(dataStack: entries),
                ),
              ),
            ),
          ),
        ));
    String front() => tester
        .widget<BingoStoryResultTicket>(
            find.byType(BingoStoryResultTicket).last)
        .entry
        .boul;
    await setMotion(true);
    await tester.pump(const Duration(seconds: 4));
    expect(front(), '27');
    final card = tester.getRect(find.byType(StackbingoWidget));
    await tester.dragFrom(Offset(card.center.dx, card.top + card.height * .75),
        const Offset(60, 0));
    await tester.pump();
    await tester.pump();
    expect(front(), '107');
    await tester.pump(const Duration(seconds: 4));
    expect(front(), '107');
    await setMotion(false);
    expect(front(), '107');
    await tester.pump(const Duration(seconds: 3));
    await tester.pump(const Duration(milliseconds: 250));
    await tester.pump();
    expect(front(), '27');
    await tester.pumpWidget(const SizedBox());
    expect(tester.takeException(), isNull);
  });

  testWidgets('opening another publication restarts its own ticket pile',
      (tester) async {
    final stories = [
      for (final values in [
        ['27', '107'],
        ['09•30', '68-12-34'],
        ['00X96']
      ])
        BingoStatusItem(dataStack: [
          for (final value in values) DataStackStruct(boul: value)
        ]),
    ];
    await tester.pumpWidget(ChangeNotifierProvider.value(
      value: FFAppState(),
      child: MaterialApp(
        supportedLocales: const [Locale('en')],
        localizationsDelegates: const [FFLocalizationsDelegate()],
        home: Scaffold(
          body: Builder(
              builder: (context) => TextButton(
                    onPressed: () => showBingoDialog<void>(
                        context: context, stories: stories),
                    child: const Text('Open'),
                  )),
        ),
      ),
    ));
    await tester.tap(find.text('Open'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    final tickets = find.byType(BingoStoryResultTicket);
    String front() =>
        tester.widget<BingoStoryResultTicket>(tickets.last).entry.boul;
    expect(front(), '27');
    final square = tester.getRect(find.byType(StackbingoWidget));
    await tester.dragFrom(
        Offset(square.center.dx, square.top + square.height * .75),
        const Offset(-60, 0));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump();
    expect(front(), '107');
    final next = Offset(square.right - 40, square.top + square.height * .25);
    await tester.tapAt(next);
    await tester.pump();
    expect(front(), '09•30');
    await tester.tapAt(next);
    await tester.pump();
    expect(front(), '00X96');
    expect(find.text('×1'), findsNothing);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 3));
    expect(tester.takeException(), isNull);
  });

  for (final language in ['fr', 'en', 'cr']) {
    for (final brightness in [Brightness.dark, Brightness.light]) {
      for (final width in [320.0, 1280.0]) {
        testWidgets('real Bingo stack gestures $language $brightness $width',
            (tester) async {
          tester.binding.platformDispatcher.platformBrightnessTestValue =
              brightness;
          addTearDown(tester
              .binding.platformDispatcher.clearPlatformBrightnessTestValue);
          tester.view.physicalSize = Size(width, 720);
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);
          final captureKey = GlobalKey();
          var previousStories = 0;
          var nextStories = 0;
          final data = [
            DataStackStruct(
                boul: '107',
                valeur: 'LOTO 3',
                tirage: 'GEORGIA',
                periode: 'Midi'),
            DataStackStruct(
                boul: '09•30',
                valeur: '2 lots',
                tirage: 'FLORIDA',
                periode: 'Soir'),
            DataStackStruct(
                boul: '00X96',
                valeur: 'MARIAGE',
                tirage: 'FLORIDA',
                periode: 'Midi'),
            DataStackStruct(
                boul: '68-12-34',
                valeur: 'BOLOTO',
                tirage: 'NEW YORK',
                periode: 'Soir'),
          ];
          await tester.pumpWidget(ChangeNotifierProvider.value(
            value: FFAppState(),
            child: RepaintBoundary(
              key: captureKey,
              child: MaterialApp(
                debugShowCheckedModeBanner: false,
                theme: DarkModeTheme().materialTheme,
                themeMode: ThemeMode.dark,
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
              'assets/images/bingo/story_backdrop.webp',
              'assets/images/bingo/story_ticket.webp',
            ]) {
              await precacheImage(AssetImage(asset),
                  tester.element(find.byType(StackbingoWidget)));
            }
          });
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 950));
          final cards = find.descendant(
              of: find.byType(CardSwiper),
              matching: find.byType(BingoStoryResultTicket));
          void expectFront(DataStackStruct entry) {
            expect(tester.widget<BingoStoryResultTicket>(cards.last).entry,
                same(entry));
            final layoutKey = entry.boul == '107'
                ? 'bingo-story-inline'
                : 'bingo-story-stacked';
            expect(
                find.descendant(
                    of: cards.last, matching: find.byKey(ValueKey(layoutKey))),
                findsOneWidget);
            expect(
                find.descendant(
                    of: cards.last,
                    matching: find.text(entry.boul, findRichText: true)),
                findsWidgets);
          }

          Future<void> exportFrame(String number) async {
            if (exportDirectory.isEmpty) return;
            final boundary = captureKey.currentContext!.findRenderObject()!
                as RenderRepaintBoundary;
            final picture =
                (await tester.runAsync(() => boundary.toImage(pixelRatio: 2)))!;
            final bytes = await tester.runAsync(
                () => picture.toByteData(format: ui.ImageByteFormat.png));
            await tester.runAsync(() async {
              final file = File(
                  '$exportDirectory/$language-${brightness.name}-${width.toInt()}-$number.png');
              await file.parent.create(recursive: true);
              await file.writeAsBytes(bytes!.buffer.asUint8List());
            });
            picture.dispose();
          }

          expectFront(data.first);
          await exportFrame(data.first.boul);
          final card = tester.getRect(find.byType(StackbingoWidget));
          final zone = Rect.fromLTRB(card.left, card.top + card.height * .58,
              card.right, card.top + card.height * .92);
          // Drag both the face and the exposed layers of the physical ticket.
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
            final front = data[(i + 1) % data.length];
            expectFront(front);
            if (i < data.length - 1) await exportFrame(front.boul);
            expect(previousStories, 0);
            expect(nextStories, 0);
          }

          // Taps and vertical motions in the pile must not advance a story.
          await tester.tapAt(zone.center);
          await tester.dragFrom(zone.center, const Offset(8, 2));
          await tester.dragFrom(zone.center, const Offset(0, 40));
          await tester.pump();
          expectFront(data[1]);
          expect(previousStories, 0);
          expect(nextStories, 0);

          // Automatic rotation must not race a held/cancelled manual swipe.
          final heldSwipe = await tester.startGesture(zone.center);
          await heldSwipe.moveBy(const Offset(30, 0));
          await tester.pump(const Duration(seconds: 3));
          expectFront(data[1]);
          await heldSwipe.cancel();
          await tester.pump();
          expectFront(data[1]);

          // The artwork above the ticket still belongs to Story navigation.
          final left = Offset(card.left + 40, card.top + card.height * .25);
          final right = Offset(card.right - 40, left.dy);
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
