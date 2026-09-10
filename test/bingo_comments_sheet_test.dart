import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:choloto/autres/bingo/bingo/bingo_comment_service.dart';
import 'package:choloto/autres/bingo/bingo/bingo_public_comments_sheet.dart';
import 'package:choloto/flutter_flow/flutter_flow_theme.dart';
import 'package:choloto/flutter_flow/internationalization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
// The font manifest override keeps visual checks offline.
// ignore: implementation_imports
import 'package:google_fonts/src/google_fonts_base.dart' as font_testing;

class _FontManifest extends Fake implements AssetManifest {
  @override
  List<String> listAssets() => [
        '__test_fonts/Inter-Regular.ttf',
        '__test_fonts/Inter-SemiBold.ttf',
        '__test_fonts/Inter-Bold.ttf'
      ];
}

final _captureKey = GlobalKey();
const _exportDirectory = String.fromEnvironment('COMMENTS_VISUAL_DIR');

Widget _app({
  required TextEditingController controller,
  String language = 'fr',
  Brightness brightness = Brightness.dark,
  required Future<List<BingoPublicComment>> Function() loader,
  required BingoPublicCommentSubmitter submitter,
  bool canComment = true,
  double textScale = 1,
}) =>
    RepaintBoundary(
        key: _captureKey,
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          locale: Locale(language),
          supportedLocales: const [Locale('fr'), Locale('en'), Locale('cr')],
          localizationsDelegates: const [
            FFLocalizationsDelegate(),
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            FallbackMaterialLocalizationDelegate(),
            FallbackCupertinoLocalizationDelegate()
          ],
          theme: ThemeData(brightness: brightness),
          builder: (context, child) => MediaQuery(
              data: MediaQuery.of(context)
                  .copyWith(textScaler: TextScaler.linear(textScale)),
              child: child!),
          home: Builder(
              builder: (context) => Scaffold(
                    backgroundColor:
                        FlutterFlowTheme.of(context).primaryBackground,
                    body: Center(
                        child: TextButton(
                            onPressed: () => showBingoPublicCommentsSheet(
                                  context: context,
                                  bingoReference: null,
                                  controller: controller,
                                  onSubmitted: submitter,
                                  commentsLoader: loader,
                                  canComment: canComment,
                                ),
                            child: const Text('Open'))),
                  )),
        ));

List<BingoPublicComment> _comments() => [
      for (var i = 0; i < 8; i++)
        BingoPublicComment(
          id: 'comment-$i',
          userId: 'member-$i',
          text: i == 0
              ? 'Mwen te genyen avèk nou! Mèsi CHOLOTO.'
              : 'Merci pour les numéros et les conseils. Bonne chance à toute la communauté !',
          createdAt: DateTime(2026, 9, 10, 9, i),
          updatedAt: null,
          adminLiked: i == 0,
          adminReply: i == 0
              ? 'Bravo pour votre gain ! Merci de partager ce moment avec nous.'
              : '',
          adminReplyAt: null,
          likeCount: i == 0 ? 12 : 2,
          likedByCurrentUser: i == 0,
        ),
    ];

Future<void> _capture(WidgetTester tester, String name) async {
  if (_exportDirectory.isEmpty) return;
  await tester.runAsync(() async {
    final boundary = _captureKey.currentContext!.findRenderObject()!
        as RenderRepaintBoundary;
    final image = await boundary.toImage();
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    await Directory(_exportDirectory).create(recursive: true);
    await File('$_exportDirectory/$name.png')
        .writeAsBytes(bytes!.buffer.asUint8List());
    image.dispose();
  });
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    final bytes = await rootBundle.load(
        'assets/fonts/GoogleSansFlex-VariableFont_GRAD,ROND,opsz,slnt,wdth,wght.ttf');
    font_testing.assetManifest = _FontManifest();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMessageHandler('flutter/assets', (message) async {
      final path = utf8.decode(message!.buffer.asUint8List());
      if (path.startsWith('__test_fonts/')) return bytes;
      return ByteData.sublistView(
          File('build/unit_test_assets/$path').readAsBytesSync());
    });
    for (final family in [
      'Inter',
      'Inter_regular',
      'Inter_500',
      'Inter_600',
      'Inter_700'
    ]) {
      await (FontLoader(family)..addFont(Future.value(bytes))).load();
    }
    await (FontLoader('Google sans flex')..addFont(Future.value(bytes))).load();
    await (FontLoader('MaterialIcons')
          ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf')))
        .load();
  });

  for (final language in ['fr', 'en', 'cr']) {
    for (final brightness in Brightness.values) {
      for (final size in [const Size(320, 640), const Size(1024, 768)]) {
        testWidgets('comments $language ${brightness.name} $size with keyboard',
            (tester) async {
          tester.view.physicalSize = size;
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);
          addTearDown(tester.view.resetViewInsets);
          final controller = TextEditingController();
          await tester.pumpWidget(_app(
              controller: controller,
              language: language,
              brightness: brightness,
              loader: () async => _comments(),
              submitter: (_) async => true));
          await tester.pumpAndSettle();
          await tester.tap(find.text('Open'));
          await tester.pumpAndSettle();
          final sheet = find.byKey(const ValueKey('bingo-comment-sheet'));
          expect(tester.getSize(sheet).width, lessThanOrEqualTo(640));
          expect(
              find.text(FFLocalizations(Locale(language))
                  .getText('bingo_story_comment_reply_label')),
              findsOneWidget);
          expect(tester.takeException(), isNull);
          final name = '$language-${brightness.name}-${size.width.toInt()}';
          await _capture(tester, name);
          await tester.enterText(
              find.byKey(const ValueKey('bingo-story-comment-field')),
              'Bravo CHOLOTO');
          expect(find.byKey(const ValueKey('bingo-story-comment-send')),
              findsNothing);
          tester.view.viewInsets = const FakeViewPadding(bottom: 280);
          await tester.pumpAndSettle();
          final send = find.byKey(const ValueKey('bingo-comment-sheet-submit'));
          expect(tester.getSize(send), const Size.square(48));
          expect(tester.getRect(send).bottom,
              lessThanOrEqualTo(size.height - 280));
          expect(tester.takeException(), isNull);
          await _capture(tester, '$name-keyboard');
          await tester.pumpWidget(const SizedBox());
          controller.dispose();
        });
      }
    }
  }

  testWidgets(
      'loading and offline error keep the composer, retry restores empty state',
      (tester) async {
    final controller = TextEditingController();
    final load = Completer<List<BingoPublicComment>>();
    var calls = 0;
    await tester.pumpWidget(_app(
        controller: controller,
        loader: () {
          calls++;
          return calls == 1 ? load.future : Future.value([]);
        },
        submitter: (_) async => true));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Open'));
    await tester.pump(const Duration(seconds: 1));
    expect(
        find.byKey(const ValueKey('bingo-comments-loading')), findsOneWidget);
    load.completeError(StateError('offline'));
    await tester.pumpAndSettle();
    expect(
        find.text(FFLocalizations(const Locale('fr'))
            .getText('bingo_comments_load_error')),
        findsOneWidget);
    await tester.tap(
        find.text(FFLocalizations(const Locale('fr')).getText('story_retry')));
    await tester.pumpAndSettle();
    expect(find.text('Lancez la discussion'), findsOneWidget);
    await _capture(tester, 'empty-dark');
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
    controller.dispose();
  });

  testWidgets(
      'throwing send preserves draft; editing clears stale pending card; retry succeeds',
      (tester) async {
    final controller = TextEditingController();
    final pending = Completer<bool>();
    var calls = 0;
    final saved = <BingoPublicComment>[];
    await tester.pumpWidget(_app(
        controller: controller,
        loader: () async => saved,
        submitter: (text) async {
          calls++;
          if (calls == 1) return pending.future;
          saved.add(_comments().first);
          controller.clear();
          return true;
        }));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    final field = find.byKey(const ValueKey('bingo-story-comment-field'));
    await tester.enterText(field, 'Premier brouillon');
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('bingo-comment-sheet-submit')));
    await tester.pump();
    expect(tester.widget<TextField>(field).readOnly, isTrue);
    expect(calls, 1);
    pending.completeError(StateError('connection lost'));
    await tester.pumpAndSettle();
    expect(controller.text, 'Premier brouillon');
    expect(find.byKey(const ValueKey('bingo-comment-sheet-error')),
        findsOneWidget);
    await _capture(tester, 'send-error-dark');
    await tester.enterText(field, 'Nouveau brouillon');
    await tester.pumpAndSettle();
    expect(
        find.byKey(const ValueKey('bingo-comment-optimistic')), findsNothing);
    expect(
        find.byKey(const ValueKey('bingo-comment-sheet-error')), findsNothing);
    await tester.tap(find.byKey(const ValueKey('bingo-comment-sheet-submit')));
    await tester.pumpAndSettle();
    expect(calls, 2);
    expect(find.byKey(const ValueKey('bingo-comment-sheet-success')),
        findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
    controller.dispose();
  });

  testWidgets('signed-out reader and large text fit small viewport',
      (tester) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final controller = TextEditingController(text: 'Un brouillon');
    var submissions = 0;
    await tester.pumpWidget(_app(
        controller: controller,
        textScale: 1.5,
        canComment: false,
        loader: () async => _comments(),
        submitter: (_) async {
          submissions++;
          return true;
        }));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('bingo-comment-sign-in-message')),
        findsOneWidget);
    expect(
        tester
            .widget<TextField>(
                find.byKey(const ValueKey('bingo-story-comment-field')))
            .readOnly,
        isTrue);
    await tester.tap(find.byKey(const ValueKey('bingo-comment-sheet-submit')));
    expect(submissions, 0);
    expect(tester.takeException(), isNull);
    await _capture(tester, 'signed-out-large-text');
    await tester.pumpWidget(const SizedBox());
    controller.dispose();
  });
}
