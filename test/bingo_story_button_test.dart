import 'package:choloto/autres/bingo/bingo/bingo_dialog.dart';
import 'package:choloto/autres/bingo/bingo/bingo_comment_service.dart';
import 'package:choloto/autres/bingo/bingo/bingo_reaction_service.dart';
import 'package:choloto/autres/bingo/bingo/bingo_story_button.dart';
import 'package:choloto/flutter_flow/flutter_flow_icon_button.dart';
import 'package:choloto/flutter_flow/flutter_flow_theme.dart';
import 'package:choloto/flutter_flow/flutter_flow_util.dart';
import 'package:choloto/flutter_flow/internationalization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:webviewx_plus/webviewx_plus.dart';

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
      isBingoStoryCollectionAvailable(
        viewed: true,
        activeStoryCount: 3,
      ),
      isTrue,
    );
    expect(
      isBingoStoryCollectionAvailable(
        viewed: true,
        activeStoryCount: 0,
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
      expect(
        localizations.getText('bingo_story_previous').trim(),
        isNotEmpty,
      );
      expect(
        localizations.getText('bingo_story_next').trim(),
        isNotEmpty,
      );
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
      expect(
        localizations.getText('bingo_story_comment_liked').trim(),
        isNotEmpty,
      );
      expect(
        localizations.getText('bingo_story_comment_reply_label').trim(),
        isNotEmpty,
      );
    }
  });

  test('Bingo comment status maps the CHOLOTO like and reply', () {
    final repliedAt = DateTime(2026, 8, 24, 10, 30);
    final status = parseBingoCommentStatus({
      'adminLiked': true,
      'adminLikedAt': repliedAt,
      'adminReply': '  Merci pour votre message !  ',
      'adminReplyAt': repliedAt,
    });

    expect(status.adminLiked, isTrue);
    expect(status.adminLikedAt, repliedAt);
    expect(status.adminReply, 'Merci pour votre message !');
    expect(status.adminReplyAt, repliedAt);
    expect(status.hasAdminReply, isTrue);
    expect(status.hasAdminInteraction, isTrue);
  });

  test('public Bingo comments expose content without an author profile', () {
    final comment = parseBingoPublicComment(
      id: 'private-user-id',
      data: {
        'user': 'private-user-id',
        'text': '  Bravo CHOLOTO !  ',
        'adminReply': 'Merci !',
      },
      likeCount: 4,
      likedByCurrentUser: true,
    );

    expect(comment, isNotNull);
    expect(comment!.id, 'private-user-id');
    expect(comment.text, 'Bravo CHOLOTO !');
    expect(comment.adminReply, 'Merci !');
    expect(comment.likeCount, 4);
    expect(comment.likedByCurrentUser, isTrue);
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
                  onViewComments: () {},
                  commentController: commentController,
                  onCommentSubmitted: (comment) => submittedComment = comment,
                  commentFeedback: FFLocalizations(locale)
                      .getText('bingo_story_comment_success'),
                  commentStatus: const BingoCommentStatus(
                    adminLiked: true,
                    adminLikedAt: null,
                    adminReply: 'Merci pour votre message !',
                    adminReplyAt: null,
                  ),
                  storyCount: 3,
                  currentStoryIndex: 1,
                  progressAnimation: const AlwaysStoppedAnimation<double>(0.5),
                  onPreviousStory: () {},
                  onNextStory: () {},
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
            find.byKey(const ValueKey('bingo-story-progress')),
            findsOneWidget,
          );
          expect(
            find.byKey(const ValueKey('bingo-story-previous-area')),
            findsOneWidget,
          );
          expect(
            find.byKey(const ValueKey('bingo-story-next-area')),
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
          expect(
            find.byKey(const ValueKey('bingo-story-comment-success')),
            findsOneWidget,
          );
          expect(
            find.byKey(const ValueKey('bingo-story-admin-interaction')),
            findsOneWidget,
          );
          expect(
            find.text(
              FFLocalizations(locale).getText('bingo_story_comment_liked'),
            ),
            findsOneWidget,
          );
          expect(
            find.text(
              FFLocalizations(locale)
                  .getText('bingo_story_comment_reply_label'),
            ),
            findsOneWidget,
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
          final commentsButton = tester.widget<FlutterFlowIconButton>(
            find.byKey(const ValueKey('bingo-story-comments-open')),
          );
          final dislikeButton = tester.widget<FlutterFlowIconButton>(
            find.byKey(const ValueKey('bingo-story-dislike')),
          );
          final storyTheme = FlutterFlowTheme.of(
            tester.element(find.byKey(const ValueKey('bingo-story-like'))),
          );
          expect(likeButton.buttonSize, 48.0);
          expect(commentsButton.buttonSize, 48.0);
          expect(dislikeButton.buttonSize, 48.0);
          expect(
            likeButton.fillColor,
            storyTheme.primary.withValues(alpha: 0.16),
          );
          expect(
            commentsButton.fillColor,
            storyTheme.secondaryBackground.withValues(alpha: 0.48),
          );
          expect((likeButton.icon as Icon).size, 20.0);
          expect((commentsButton.icon as Icon).size, 20.0);
          expect((dislikeButton.icon as Icon).size, 20.0);

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
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

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

    expect(
      find.byKey(const ValueKey('bingo-story-close-button')),
      findsOneWidget,
    );
    await tester.tap(find.byKey(const ValueKey('bingo-story-close-button')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('bingo-status-dialog')), findsNothing);
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
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

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

  testWidgets(
      'Bingo statuses expose progress and navigate right, left, and after 45 seconds',
      (tester) async {
    tester.view.physicalSize = const Size(360, 800);
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
                stories: const [
                  BingoStatusItem(
                    content: Text(
                      'Premier Bingo',
                      key: ValueKey('first-bingo-status'),
                    ),
                  ),
                  BingoStatusItem(
                    content: Text(
                      'Deuxième Bingo',
                      key: ValueKey('second-bingo-status'),
                    ),
                  ),
                  BingoStatusItem(
                    content: Text(
                      'Troisième Bingo',
                      key: ValueKey('third-bingo-status'),
                    ),
                  ),
                ],
              ),
              child: const Text('Ouvrir les statuts'),
            ),
          ),
        ),
      ),
    );

    expect(bingoStatusDuration, const Duration(seconds: 45));

    await tester.tap(find.text('Ouvrir les statuts'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byKey(const ValueKey('first-bingo-status')), findsOneWidget);
    expect(
      find.byKey(const ValueKey('bingo-story-progress')),
      findsOneWidget,
    );
    for (var index = 0; index < 3; index++) {
      expect(
        find.byKey(ValueKey('bingo-story-progress-track-$index')),
        findsOneWidget,
      );
    }

    await tester.tap(
      find.byKey(const ValueKey('bingo-story-next-area')),
    );
    await tester.pump();
    expect(find.byKey(const ValueKey('second-bingo-status')), findsOneWidget);

    await tester.tap(
      find.byKey(const ValueKey('bingo-story-previous-area')),
    );
    await tester.pump();
    expect(find.byKey(const ValueKey('first-bingo-status')), findsOneWidget);

    await tester.tap(
      find.byKey(const ValueKey('bingo-story-next-area')),
    );
    await tester.pump();
    await tester.pump(const Duration(seconds: 44));
    expect(find.byKey(const ValueKey('second-bingo-status')), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 1100));
    await tester.pump();
    expect(find.byKey(const ValueKey('third-bingo-status')), findsOneWidget);
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

  testWidgets(
      'a successful Story comment is confirmed inline and clears the field',
      (tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    String? submittedComment;

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
                  key: ValueKey('comment-feedback-bingo-content'),
                ),
                storyDuration: const Duration(minutes: 1),
                commentSubmitter: (comment, _) async {
                  submittedComment = comment;
                },
              ),
              child: const Text('Commenter le Bingo'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Commenter le Bingo'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(
      find.byKey(const ValueKey('bingo-story-comments-open')),
      findsOneWidget,
    );
    await tester.tap(
      find.byKey(const ValueKey('bingo-story-comment-field')),
    );
    await tester.enterText(
      find.byKey(const ValueKey('bingo-story-comment-field')),
      'Mwen te genyen avèk nou',
    );
    await tester.pump();
    await tester.tap(
      find.byKey(const ValueKey('bingo-story-comment-send')),
    );
    await tester.pump();
    await tester.pump();

    expect(submittedComment, 'Mwen te genyen avèk nou');
    final commentField = tester.widget<TextField>(
      find.byKey(const ValueKey('bingo-story-comment-field')),
    );
    expect(commentField.controller?.text, isEmpty);
    expect(
      find.byKey(const ValueKey('bingo-story-comment-success')),
      findsOneWidget,
    );
    expect(
      find.text(
        FFLocalizations(const Locale('fr'))
            .getText('bingo_story_comment_success'),
      ),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);

    await tester.tap(find.byKey(const ValueKey('bingo-story-close-button')));
    await tester.pumpAndSettle();
  });

  testWidgets('a failed Story comment remains editable and shows its error',
      (tester) async {
    tester.view.physicalSize = const Size(360, 800);
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
                content: const SizedBox(),
                storyDuration: const Duration(minutes: 1),
                commentSubmitter: (_, __) async {
                  throw StateError('Firebase unavailable');
                },
              ),
              child: const Text('Ouvrir le commentaire'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Ouvrir le commentaire'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.enterText(
      find.byKey(const ValueKey('bingo-story-comment-field')),
      'Gardez mon commentaire',
    );
    await tester.pump();
    await tester.tap(
      find.byKey(const ValueKey('bingo-story-comment-send')),
    );
    await tester.pump();
    await tester.pump();

    final commentField = tester.widget<TextField>(
      find.byKey(const ValueKey('bingo-story-comment-field')),
    );
    expect(commentField.controller?.text, 'Gardez mon commentaire');
    expect(
      find.byKey(const ValueKey('bingo-story-comment-error')),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);

    await tester.tap(find.byKey(const ValueKey('bingo-story-close-button')));
    await tester.pumpAndSettle();
  });

  testWidgets('Web desktop comment uses a native browser input',
      (tester) async {
    tester.view.physicalSize = const Size(1280, 720);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final commentController = TextEditingController();
    addTearDown(commentController.dispose);
    String? submittedComment;

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
        home: Scaffold(
          body: BingoStatusFrame(
            commentController: commentController,
            onCommentSubmitted: (comment) => submittedComment = comment,
            child: const SizedBox(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final commentFieldFinder =
        find.byKey(const ValueKey('bingo-story-comment-field'));
    expect(commentFieldFinder, findsOneWidget);

    if (kIsWeb) {
      expect(find.byType(HtmlElementView), findsOneWidget);
      expect(find.byType(TextField), findsNothing);
      expect(tester.getSize(commentFieldFinder).height, 48.0);
      expect(tester.takeException(), isNull);
      return;
    } else {
      await tester.tap(commentFieldFinder);
      await tester.pump();
      expect(
        tester.widget<TextField>(commentFieldFinder).focusNode?.hasFocus,
        isTrue,
      );
      expect(tester.testTextInput.isVisible, isTrue);
      tester.testTextInput.enterText('Clavier physique Web éà 123');
      await tester.pump();
      expect(commentController.text, 'Clavier physique Web éà 123');
      await tester.testTextInput.receiveAction(TextInputAction.send);
    }
    await tester.pump();
    expect(submittedComment, 'Clavier physique Web éà 123');
    expect(tester.takeException(), isNull);
  });

  testWidgets('Web mobile comment uses a direct HTML touch target',
      (tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetViewInsets);

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
                content: const SizedBox(),
                storyDuration: const Duration(seconds: 1),
                commentSubmitter: (_, __) async {},
              ),
              child: const Text('Saisir un commentaire'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Saisir un commentaire'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    final commentFieldFinder =
        find.byKey(const ValueKey('bingo-story-comment-field'));
    expect(commentFieldFinder, findsOneWidget);

    if (kIsWeb) {
      expect(find.byType(HtmlElementView), findsOneWidget);
      expect(find.byType(TextField), findsNothing);
      expect(tester.getSize(commentFieldFinder).height, 48.0);
    } else {
      await tester.tap(commentFieldFinder);
      await tester.pump();
      expect(
        tester.widget<TextField>(commentFieldFinder).focusNode?.hasFocus,
        isTrue,
      );
      expect(tester.testTextInput.isVisible, isTrue);
      tester.testTextInput.enterText('Saisie Web éà 123');
      await tester.pump();
      expect(
        tester.widget<TextField>(commentFieldFinder).controller?.text,
        'Saisie Web éà 123',
      );
      tester.testTextInput.hide();
      await tester.pump();
      expect(tester.testTextInput.isVisible, isFalse);
      await tester.tap(commentFieldFinder);
      await tester.pump();
      expect(tester.testTextInput.isVisible, isTrue);
    }

    tester.view.viewInsets = const FakeViewPadding(bottom: 300.0);
    await tester.pump();
    expect(
      tester
          .getRect(find.byKey(const ValueKey('bingo-story-comment-field')))
          .bottom,
      lessThanOrEqualTo(500.0),
    );

    expect(tester.takeException(), isNull);

    await tester.tap(find.byKey(const ValueKey('bingo-story-close-button')));
    await tester.pumpAndSettle();
  });

  testWidgets('Web mobile comment has no hidden WebView interceptor',
      (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final commentController = TextEditingController();
    addTearDown(commentController.dispose);

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
        home: Scaffold(
          body: BingoStatusFrame(
            commentController: commentController,
            onCommentSubmitted: (_) {},
            child: const SizedBox(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(WebViewAware), findsNothing);
  });
}
