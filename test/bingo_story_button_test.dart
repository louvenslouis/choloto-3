import 'package:choloto/autres/bingo/bingo/bingo_dialog.dart';
import 'package:choloto/autres/bingo/bingo/bingo_comment_service.dart';
import 'package:choloto/autres/bingo/bingo/bingo_reaction_service.dart';
import 'package:choloto/autres/bingo/bingo/bingo_story_button.dart';
import 'package:choloto/flutter_flow/flutter_flow_icon_button.dart';
import 'package:choloto/flutter_flow/flutter_flow_util.dart';
import 'package:choloto/flutter_flow/internationalization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _app({
  required Locale locale,
  required ThemeMode themeMode,
  required VoidCallback onTap,
}) {
  return MaterialApp(
    locale: locale,
    supportedLocales: const [Locale('fr'), Locale('en'), Locale('cr')],
    localizationsDelegates: const [
      FFLocalizationsDelegate(),
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
      FallbackMaterialLocalizationDelegate(),
      FallbackCupertinoLocalizationDelegate(),
    ],
    theme: ThemeData(brightness: Brightness.light),
    darkTheme: ThemeData(brightness: Brightness.dark),
    themeMode: themeMode,
    home: Scaffold(
      body: Align(
        alignment: Alignment.topLeft,
        child: BingoStoryButton(onTap: onTap),
      ),
    ),
  );
}

void main() {
  test('the Bingo story is available only after viewing an active Bingo', () {
    final now = DateTime(2026, 8, 21, 12);
    final activeExpiration = now.add(const Duration(hours: 1));

    expect(
      isBingoStoryAvailable(
        viewed: false,
        bingoDate: now,
        expiration: activeExpiration,
        now: now,
      ),
      isFalse,
    );
    expect(
      isBingoStoryAvailable(
        viewed: true,
        bingoDate: now,
        expiration: activeExpiration,
        now: now,
      ),
      isTrue,
    );
    expect(
      isBingoStoryAvailable(
        viewed: true,
        bingoDate: now,
        expiration: now.subtract(const Duration(seconds: 1)),
        now: now,
      ),
      isFalse,
    );
    expect(
      isBingoStoryAvailable(
        viewed: true,
        bingoDate: null,
        expiration: activeExpiration,
        now: now,
      ),
      isFalse,
    );
  });

  test('Bingo story copy is available in every supported language', () {
    for (final language in FFLocalizations.languages()) {
      final localizations = FFLocalizations(Locale(language));
      expect(localizations.getText('bingo_story_label').trim(), isNotEmpty);
      expect(localizations.getText('bingo_story_open').trim(), isNotEmpty);
      expect(localizations.getText('bingo_story_like').trim(), isNotEmpty);
      expect(localizations.getText('bingo_story_dislike').trim(), isNotEmpty);
      expect(
        localizations.getText('bingo_story_reaction_error').trim(),
        isNotEmpty,
      );
      expect(
        localizations.getText('bingo_story_comment_hint').trim(),
        isNotEmpty,
      );
      expect(
        localizations.getText('bingo_story_comment_send').trim(),
        isNotEmpty,
      );
      expect(
        localizations.getText('bingo_story_comment_success').trim(),
        isNotEmpty,
      );
      expect(
        localizations.getText('bingo_story_comment_error').trim(),
        isNotEmpty,
      );
    }
  });

  test('Bingo comments are trimmed and constrained before upload', () {
    expect(normalizeBingoComment('  Bravo CHOLOTO !  '), 'Bravo CHOLOTO !');
    expect(
      () => normalizeBingoComment('   '),
      throwsA(isA<BingoCommentValidationException>()),
    );
    expect(
      () => normalizeBingoComment(
        List.filled(bingoCommentMaxLength + 1, 'x').join(),
      ),
      throwsA(isA<BingoCommentValidationException>()),
    );
  });

  test('Bingo reaction counter changes preserve the existing fields', () {
    expect(
      bingoReactionCounterDeltas(
        previous: null,
        next: BingoReaction.positive,
      ),
      {'bingoGain': 1},
    );
    expect(
      bingoReactionCounterDeltas(
        previous: BingoReaction.positive,
        next: BingoReaction.negative,
      ),
      {'bingoGain': -1, 'bingoRater': 1},
    );
    expect(
      bingoReactionCounterDeltas(
        previous: BingoReaction.negative,
        next: null,
      ),
      {'bingoRater': -1},
    );
  });

  test('relative publication time is localized in Haitian Creole', () {
    final now = DateTime.now();
    final label = dateTimeFormat(
      'relative',
      now.subtract(const Duration(hours: 2)),
      locale: 'cr',
    );

    expect(label, startsWith('sa gen'));
    expect(label, contains('èdtan'));
  });

  for (final locale in const [Locale('fr'), Locale('en'), Locale('cr')]) {
    for (final themeMode in const [ThemeMode.dark, ThemeMode.light]) {
      testWidgets(
        'Bingo story renders ${locale.languageCode} on mobile in ${themeMode.name} mode',
        (tester) async {
          tester.view.physicalSize = const Size(320, 568);
          tester.view.devicePixelRatio = 1.0;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);

          await tester.pumpWidget(
            _app(locale: locale, themeMode: themeMode, onTap: () {}),
          );
          await tester.pumpAndSettle();

          expect(
            find.byKey(const ValueKey('bingo-story-button')),
            findsOneWidget,
          );
          expect(
            find.text(
              FFLocalizations(locale).getText('bingo_story_label'),
            ),
            findsOneWidget,
          );
          final circleRect = tester.getRect(
            find.byKey(const ValueKey('bingo-story-circle')),
          );
          final labelFinder = find.byKey(const ValueKey('bingo-story-label'));
          final labelRect = tester.getRect(labelFinder);
          final label = tester.widget<Text>(labelFinder);

          expect(circleRect.contains(labelRect.center), isTrue);
          expect(label.style?.fontWeight, FontWeight.bold);
          expect(tester.takeException(), isNull);
        },
      );
    }
  }

  for (final locale in const [Locale('fr'), Locale('en'), Locale('cr')]) {
    for (final themeMode in const [ThemeMode.dark, ThemeMode.light]) {
      testWidgets(
        'Bingo status chrome renders ${locale.languageCode} in ${themeMode.name} mode',
        (tester) async {
          tester.view.physicalSize = const Size(360, 800);
          tester.view.devicePixelRatio = 1.0;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);
          BingoReaction? tappedReaction;
          String? submittedComment;
          final commentController = TextEditingController();
          addTearDown(commentController.dispose);

          await tester.pumpWidget(
            MaterialApp(
              locale: locale,
              supportedLocales: const [
                Locale('fr'),
                Locale('en'),
                Locale('cr'),
              ],
              localizationsDelegates: const [
                FFLocalizationsDelegate(),
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
                FallbackMaterialLocalizationDelegate(),
                FallbackCupertinoLocalizationDelegate(),
              ],
              theme: ThemeData(brightness: Brightness.light),
              darkTheme: ThemeData(brightness: Brightness.dark),
              themeMode: themeMode,
              home: Scaffold(
                body: BingoStatusFrame(
                  publishedAt:
                      DateTime.now().subtract(const Duration(hours: 2)),
                  selectedReaction: BingoReaction.positive,
                  onReaction: (reaction) => tappedReaction = reaction,
                  commentController: commentController,
                  onCommentSubmitted: (comment) => submittedComment = comment,
                  child: const SizedBox(
                    key: ValueKey('status-chrome-bingo-content'),
                  ),
                ),
              ),
            ),
          );
          await tester.pumpAndSettle();

          expect(
            find.byKey(const ValueKey('bingo-story-header')),
            findsOneWidget,
          );
          expect(
            find.text(
              FFLocalizations(locale).getText('bingo_story_label'),
            ),
            findsOneWidget,
          );
          final publicationAge = tester.widget<Text>(
            find.byKey(const ValueKey('bingo-story-published-age')),
          );
          expect(publicationAge.data, isNotEmpty);
          expect(
            find.byKey(const ValueKey('bingo-story-like')),
            findsOneWidget,
          );
          expect(
            find.byKey(const ValueKey('bingo-story-dislike')),
            findsOneWidget,
          );
          final commentField = tester.widget<TextField>(
            find.byKey(const ValueKey('bingo-story-comment-field')),
          );
          expect(
            commentField.decoration?.hintText,
            FFLocalizations(locale).getText('bingo_story_comment_hint'),
          );
          expect(
            find.byKey(const ValueKey('bingo-story-comment-send')),
            findsNothing,
          );

          final reactionRect = tester.getRect(
            find.byKey(const ValueKey('bingo-story-reactions')),
          );
          final commentFieldRect = tester.getRect(
            find.byKey(const ValueKey('bingo-story-comment-field')),
          );
          expect(reactionRect.center.dx, greaterThan(180.0));
          expect(reactionRect.center.dy, greaterThan(400.0));
          expect(
            (reactionRect.center.dy - commentFieldRect.center.dy).abs(),
            lessThan(1.0),
          );

          final likeButton = tester.widget<FlutterFlowIconButton>(
            find.byKey(const ValueKey('bingo-story-like')),
          );
          expect(likeButton.fillColor, isNot(likeButton.disabledColor));

          await tester.tap(
            find.byKey(const ValueKey('bingo-story-dislike')),
          );
          await tester.pump();
          expect(tappedReaction, BingoReaction.negative);

          await tester.tap(
            find.byKey(const ValueKey('bingo-story-comment-field')),
          );
          await tester.enterText(
            find.byKey(const ValueKey('bingo-story-comment-field')),
            'Mwen genyen',
          );
          await tester.pump();
          expect(
            find.byKey(const ValueKey('bingo-story-comment-send')),
            findsOneWidget,
          );
          await tester.tap(
            find.byKey(const ValueKey('bingo-story-comment-send')),
          );
          await tester.pump();
          expect(submittedComment, 'Mwen genyen');
          expect(tester.takeException(), isNull);
        },
      );
    }
  }

  testWidgets('tapping the story can reopen the Bingo dialog on web',
      (tester) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('fr'),
        supportedLocales: const [Locale('fr'), Locale('en'), Locale('cr')],
        localizationsDelegates: const [
          FFLocalizationsDelegate(),
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          FallbackMaterialLocalizationDelegate(),
          FallbackCupertinoLocalizationDelegate(),
        ],
        home: Builder(
          builder: (context) => Scaffold(
            body: BingoStoryButton(
              onTap: () {
                showBingoDialog<void>(
                  context: context,
                  content: const SizedBox(
                    key: ValueKey('reopened-bingo-content'),
                    height: 200.0,
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.byKey(const ValueKey('bingo-story-button')));
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('reopened-bingo-content')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('bingo-story-comment-field')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('bingo-story-reactions')),
      findsOneWidget,
    );
    expect(
      tester.getSize(find.byKey(const ValueKey('bingo-status-dialog'))),
      const Size(1280.0, 800.0),
    );
    final statusFrameSize =
        tester.getSize(find.byKey(const ValueKey('bingo-status-frame')));
    expect(statusFrameSize.height, 800.0);
    expect(
      statusFrameSize.width / statusFrameSize.height,
      closeTo(bingoStatusAspectRatio, 0.001),
    );
    final contentArea = tester.widget<SizedBox>(
      find.byKey(const ValueKey('bingo-status-content-area')),
    );
    expect(contentArea.width, bingoCardPresentationSize.width);
    expect(contentArea.height, bingoCardPresentationSize.height);
    expect(tester.takeException(), isNull);
  });

  testWidgets('the Bingo status fills a portrait 9:16 mobile viewport',
      (tester) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('fr'),
        supportedLocales: const [Locale('fr'), Locale('en'), Locale('cr')],
        localizationsDelegates: const [
          FFLocalizationsDelegate(),
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          FallbackMaterialLocalizationDelegate(),
          FallbackCupertinoLocalizationDelegate(),
        ],
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () => showBingoDialog<void>(
                context: context,
                content: const SizedBox(
                  key: ValueKey('mobile-bingo-status-content'),
                ),
              ),
              child: const Text('Bingo'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Bingo'));
    await tester.pumpAndSettle();

    final dialogSize =
        tester.getSize(find.byKey(const ValueKey('bingo-status-dialog')));
    final statusFrameSize =
        tester.getSize(find.byKey(const ValueKey('bingo-status-frame')));
    expect(dialogSize, const Size(320.0, 568.0));
    expect(statusFrameSize.height, 568.0);
    expect(
      statusFrameSize.width / statusFrameSize.height,
      closeTo(bingoStatusAspectRatio, 0.001),
    );
    expect(
      find.byKey(const ValueKey('mobile-bingo-status-content')),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('the Bingo status also fills a taller modern phone',
      (tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: BingoStatusFrame(
            child: SizedBox(key: ValueKey('tall-mobile-bingo-content')),
          ),
        ),
      ),
    );

    expect(
      tester.getSize(find.byKey(const ValueKey('bingo-status-frame'))),
      const Size(360.0, 800.0),
    );
    expect(
      find.byKey(const ValueKey('tall-mobile-bingo-content')),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });
}
