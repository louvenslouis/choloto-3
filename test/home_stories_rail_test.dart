import 'package:choloto/autres/bingo/bingo/bingo_story_button.dart';
import 'package:choloto/backend/schema/structs/index.dart';
import 'package:choloto/components/home_stories_rail.dart';
import 'package:choloto/components/vip_casino_card.dart';
import 'package:choloto/flutter_flow/internationalization.dart';
import 'package:choloto/youtube/youtube_story.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _app({
  required Locale locale,
  required ThemeMode themeMode,
  required Widget child,
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
        child: SizedBox(width: 720.0, child: child),
      ),
    ),
  );
}

void main() {
  testWidgets('reading a story changes its chip rim and preserves both actions',
      (tester) async {
    var bingoTaps = 0;
    var youtubeTaps = 0;
    const locale = Locale('fr');
    final strings = FFLocalizations(locale);
    final video = YoutubeItemStruct(title: 'CHOLOTO');
    for (final viewed in [false, true]) {
      await tester.pumpWidget(_app(
        locale: locale,
        themeMode: ThemeMode.dark,
        child: HomeStoriesRail(
          loading: false,
          loadFailed: false,
          onRetry: () {},
          stories: [
            BingoStoryButton(
                viewed: viewed, storyCount: 2, onTap: () => bingoTaps++),
            YoutubeStoryButton(
                video: video, viewed: !viewed, onTap: () => youtubeTaps++),
          ],
        ),
      ));
      final bingo = find.byType(BingoStoryButton);
      final youtube = find.byType(YoutubeStoryButton);
      expect(find.descendant(of: bingo, matching: find.byType(VipCasinoChip)),
          viewed ? findsNothing : findsOneWidget);
      expect(find.descendant(of: youtube, matching: find.byType(VipCasinoChip)),
          viewed ? findsOneWidget : findsNothing);
      expect(
          tester
              .getSemantics(
                  find.bySemanticsLabel(strings.getText('bingo_story_open')))
              .value,
          '${strings.getText(viewed ? 'home_story_seen' : 'home_story_unseen')}, 2');
      await tester.tap(find.byKey(const ValueKey('bingo-story-button')));
      await tester.tap(find.byKey(const ValueKey('youtube-story-button')));
    }
    expect(bingoTaps, 2);
    expect(youtubeTaps, 2);
    expect(tester.takeException(), isNull);
  });

  for (final locale in const [Locale('fr'), Locale('en'), Locale('cr')]) {
    for (final variant in const [
      (Size(320.0, 568.0), ThemeMode.dark),
      (Size(1280.0, 800.0), ThemeMode.light),
    ]) {
      testWidgets(
        'stories rail renders ${locale.languageCode} at ${variant.$1.width.toInt()} px in ${variant.$2.name}',
        (tester) async {
          tester.view.physicalSize = variant.$1;
          tester.view.devicePixelRatio = 1.0;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);

          await tester.pumpWidget(
            _app(
              locale: locale,
              themeMode: variant.$2,
              child: HomeStoriesRail(
                loading: false,
                loadFailed: false,
                onRetry: () {},
                stories: const [
                  Center(
                    child: SizedBox.square(
                      key: ValueKey('story-bubble-contract'),
                      dimension: 72.0,
                    ),
                  ),
                ],
              ),
            ),
          );
          await tester.pumpAndSettle();

          final railWidth = variant.$1.width < 720.0 ? variant.$1.width : 720.0;
          expect(
            find.text(
              FFLocalizations(locale).getText('home_stories_title'),
            ),
            findsNothing,
          );
          expect(
            tester.getSize(find.byKey(const ValueKey('home-stories-rail'))),
            Size(railWidth, 80.0),
          );
          expect(
            tester.getSize(
              find.byKey(const ValueKey('story-bubble-contract')),
            ),
            const Size.square(72.0),
          );
          expect(
            find.byKey(const ValueKey('home-stories-loading')),
            findsNothing,
          );
          expect(tester.takeException(), isNull);
        },
      );
    }
  }

  testWidgets('stories rail reserves its place while loading', (tester) async {
    tester.view.physicalSize = const Size(320.0, 568.0);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      _app(
        locale: const Locale('fr'),
        themeMode: ThemeMode.dark,
        child: HomeStoriesRail(
          stories: const [],
          loading: true,
          loadFailed: false,
          onRetry: () {},
        ),
      ),
    );

    expect(find.byKey(const ValueKey('home-stories-rail')), findsOneWidget);
    expect(find.byKey(const ValueKey('home-stories-loading')), findsOneWidget);
    expect(find.byKey(const ValueKey('home-stories-title')), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('stories rail exposes a retry action after a load error',
      (tester) async {
    var retried = false;
    await tester.pumpWidget(
      _app(
        locale: const Locale('cr'),
        themeMode: ThemeMode.light,
        child: HomeStoriesRail(
          stories: const [],
          loading: false,
          loadFailed: true,
          onRetry: () => retried = true,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('home-stories-error')), findsOneWidget);
    expect(
      find.text(FFLocalizations(const Locale('cr')).getText('story_retry')),
      findsOneWidget,
    );
    await tester.tap(find.byKey(const ValueKey('home-stories-error')));
    await tester.pump();
    expect(retried, isTrue);
    expect(tester.takeException(), isNull);
  });

  testWidgets('stories rail stays hidden when there is no active story',
      (tester) async {
    await tester.pumpWidget(
      _app(
        locale: const Locale('en'),
        themeMode: ThemeMode.dark,
        child: HomeStoriesRail(
          stories: const [],
          loading: false,
          loadFailed: false,
          onRetry: () {},
        ),
      ),
    );

    expect(find.byKey(const ValueKey('home-stories-rail')), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
