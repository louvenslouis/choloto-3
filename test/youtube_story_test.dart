import 'package:cached_network_image/cached_network_image.dart';
import 'package:choloto/backend/schema/structs/youtube_item_struct.dart';
import 'package:choloto/flutter_flow/internationalization.dart';
import 'package:choloto/stories/story_viewer_shell.dart';
import 'package:choloto/youtube/youtube_feed_service.dart';
import 'package:choloto/youtube/youtube_story.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

YoutubeItemStruct _video({
  required String title,
  required DateTime publishedAt,
}) {
  final id = title.toLowerCase().replaceAll(' ', '-');
  return YoutubeItemStruct(
    title: title,
    link: 'https://www.youtube.com/watch?v=$id',
    thumbnail: 'https://i.ytimg.com/vi/$id/hqdefault.jpg',
    pubDate: publishedAt.toIso8601String(),
  );
}

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
    home: Scaffold(body: child),
  );
}

void main() {
  test('YouTube stories contain only publications from the last 24 hours', () {
    final now = DateTime.utc(2026, 8, 23, 18);
    final mostRecent = _video(
      title: 'Most recent',
      publishedAt: now.subtract(const Duration(minutes: 5)),
    );
    final lessRecent = _video(
      title: 'Less recent',
      publishedAt: now.subtract(const Duration(hours: 12)),
    );
    final boundary = _video(
      title: 'Boundary',
      publishedAt: now.subtract(youtubeStoryWindow),
    );
    final tooOld = _video(
      title: 'Too old',
      publishedAt: now.subtract(
        youtubeStoryWindow + const Duration(milliseconds: 1),
      ),
    );
    final future = _video(
      title: 'Future',
      publishedAt: now.add(const Duration(seconds: 1)),
    );
    final invalid = YoutubeItemStruct(
      title: 'Invalid',
      link: 'https://www.youtube.com/watch?v=invalid',
      thumbnail: 'https://i.ytimg.com/vi/invalid/hqdefault.jpg',
      pubDate: 'not-a-date',
    );

    final result = youtubeVideosPublishedWithin(
      [lessRecent, future, tooOld, boundary, invalid, mostRecent],
      now: now,
    );

    expect(
      result.map((video) => video.title),
      ['Most recent', 'Less recent', 'Boundary'],
    );
  });

  test('YouTube story copy is available in every supported language', () {
    const keys = [
      'youtube_story_label',
      'youtube_story_open',
      'youtube_story_previous',
      'youtube_story_next',
      'youtube_story_close',
      'youtube_story_thumbnail',
      'ytwatch1',
    ];

    for (final language in FFLocalizations.languages()) {
      final localizations = FFLocalizations(Locale(language));
      for (final key in keys) {
        expect(localizations.getText(key).trim(), isNotEmpty);
        expect(localizations.getText(key), isNot(key));
      }
    }
  });

  for (final locale in const [Locale('fr'), Locale('en'), Locale('cr')]) {
    for (final themeMode in const [ThemeMode.dark, ThemeMode.light]) {
      testWidgets(
        'YouTube story bubble renders ${locale.languageCode} on mobile in ${themeMode.name} mode',
        (tester) async {
          tester.view.physicalSize = const Size(320, 568);
          tester.view.devicePixelRatio = 1.0;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);

          final video = _video(
            title: 'Nouvelle vidéo CHOLOTO',
            publishedAt: DateTime.now().subtract(const Duration(hours: 1)),
          );

          await tester.pumpWidget(
            _app(
              locale: locale,
              themeMode: themeMode,
              child: Align(
                alignment: Alignment.topLeft,
                child: YoutubeStoryButton(video: video, onTap: () {}),
              ),
            ),
          );
          await tester.pump();

          expect(
            find.byKey(const ValueKey('youtube-story-button')),
            findsOneWidget,
          );
          expect(
            find.text(
              FFLocalizations(locale).getText('youtube_story_label'),
            ),
            findsOneWidget,
          );
          final thumbnail = tester.widget<CachedNetworkImage>(
            find.byKey(const ValueKey('youtube-story-thumbnail')),
          );
          expect(thumbnail.imageUrl, video.thumbnail);
          expect(
            tester.getSize(find.byKey(const ValueKey('youtube-story-circle'))),
            const Size.square(72.0),
          );
          expect(tester.takeException(), isNull);
        },
      );
    }
  }

  testWidgets('YouTube bubble keeps its size and exposes the story count',
      (tester) async {
    final video = _video(
      title: 'Trois nouvelles vidéos',
      publishedAt: DateTime.now(),
    );
    await tester.pumpWidget(
      _app(
        locale: const Locale('fr'),
        themeMode: ThemeMode.dark,
        child: Align(
          alignment: Alignment.topLeft,
          child: YoutubeStoryButton(
            video: video,
            viewed: true,
            storyCount: 3,
            onTap: () {},
          ),
        ),
      ),
    );
    await tester.pump();

    expect(
      tester.getSize(find.byKey(const ValueKey('youtube-story-circle'))),
      const Size.square(72.0),
    );
    expect(find.byKey(const ValueKey('youtube-story-count')), findsOneWidget);
    expect(find.text('3'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('youtube-story-label')),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('YouTube story viewer navigates recent videos on mobile',
      (tester) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    var closed = false;
    final now = DateTime.now();
    final videos = [
      _video(
        title: 'Première vidéo',
        publishedAt: now.subtract(const Duration(minutes: 10)),
      ),
      _video(
        title:
            'Deuxième vidéo avec un titre assez long pour vérifier la mise en page',
        publishedAt: now.subtract(const Duration(hours: 2)),
      ),
    ];

    await tester.pumpWidget(
      _app(
        locale: const Locale('fr'),
        themeMode: ThemeMode.dark,
        child: YoutubeStoryViewer(
          videos: videos,
          onClose: () => closed = true,
          storyDuration: const Duration(hours: 1),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Première vidéo'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('youtube-story-progress')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('youtube-story-published-age')),
      findsOneWidget,
    );
    expect(
      tester.getSize(find.byKey(const ValueKey('youtube-story-viewer'))),
      const Size(320.0, 568.0),
    );
    expect(tester.takeException(), isNull);

    final firstThumbnailRect = tester.getRect(
      find.byKey(const ValueKey('youtube-story-viewer-thumbnail-0')),
    );
    await tester.tapAt(Offset(
      firstThumbnailRect.left + (firstThumbnailRect.width * 0.75),
      firstThumbnailRect.center.dy,
    ));
    await tester.pump();

    expect(find.text('Première vidéo'), findsNothing);
    expect(find.text(videos.last.title), findsOneWidget);
    expect(
      find.byKey(const ValueKey('youtube-story-viewer-thumbnail-1')),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);

    final secondThumbnailRect = tester.getRect(
      find.byKey(const ValueKey('youtube-story-viewer-thumbnail-1')),
    );
    await tester.tapAt(Offset(
      secondThumbnailRect.left + (secondThumbnailRect.width * 0.25),
      secondThumbnailRect.center.dy,
    ));
    await tester.pump();

    expect(find.text('Première vidéo'), findsOneWidget);
    expect(find.text(videos.last.title), findsNothing);
    expect(tester.takeException(), isNull);

    await tester.tap(find.byKey(const ValueKey('youtube-story-close-button')));
    await tester.pump();

    expect(closed, isTrue);
    expect(tester.takeException(), isNull);
  });

  testWidgets('only the yellow button opens the current YouTube video',
      (tester) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final video = _video(
      title: 'Vidéo cliquable',
      publishedAt: DateTime.now().subtract(const Duration(minutes: 15)),
    );
    final openedVideos = <YoutubeItemStruct>[];

    await tester.pumpWidget(
      _app(
        locale: const Locale('fr'),
        themeMode: ThemeMode.dark,
        child: YoutubeStoryViewer(
          videos: [video],
          onClose: () {},
          onOpenVideo: (selectedVideo) async {
            openedVideos.add(selectedVideo);
          },
          storyDuration: const Duration(hours: 1),
        ),
      ),
    );
    await tester.pump();

    await tester.tapAt(
      tester.getCenter(
        find.byKey(const ValueKey('youtube-story-viewer-thumbnail-0')),
      ),
    );
    await tester.pump();
    expect(openedVideos, isEmpty);
    expect(find.byIcon(Icons.play_arrow_rounded), findsNothing);

    await tester.tap(
      find.byKey(const ValueKey('youtube-story-watch-button')),
    );
    await tester.pump();
    expect(openedVideos, [video]);
    expect(tester.takeException(), isNull);
  });

  testWidgets('YouTube viewer supports swipe and keyboard navigation',
      (tester) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    var closed = false;
    final now = DateTime.now();
    final videos = [
      _video(
        title: 'Navigation une',
        publishedAt: now.subtract(const Duration(minutes: 5)),
      ),
      _video(
        title: 'Navigation deux',
        publishedAt: now.subtract(const Duration(minutes: 10)),
      ),
    ];

    await tester.pumpWidget(
      _app(
        locale: const Locale('fr'),
        themeMode: ThemeMode.dark,
        child: YoutubeStoryViewer(
          videos: videos,
          storyDuration: const Duration(hours: 1),
          onClose: () => closed = true,
        ),
      ),
    );
    await tester.pump();

    await tester.fling(
      find.byKey(const ValueKey('youtube-story-viewer')),
      const Offset(-240.0, 0.0),
      1000.0,
    );
    await tester.pump();
    expect(find.text('Navigation deux'), findsOneWidget);

    await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
    await tester.pump();
    expect(find.text('Navigation une'), findsOneWidget);

    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.pump();
    expect(find.text('Navigation deux'), findsOneWidget);

    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pump();
    expect(closed, isTrue);
    expect(tester.takeException(), isNull);
  });

  testWidgets('holding a Story pauses it until the pointer is released',
      (tester) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    var pauseCount = 0;
    var resumeCount = 0;

    await tester.pumpWidget(
      _app(
        locale: const Locale('fr'),
        themeMode: ThemeMode.dark,
        child: StoryViewerShell(
          frameKey: const ValueKey('hold-story-frame'),
          keyPrefix: 'hold',
          title: 'CHOLOTO',
          avatar: const SizedBox.shrink(),
          storyCount: 1,
          currentStoryIndex: 0,
          progressAnimation: const AlwaysStoppedAnimation<double>(0.5),
          onPreviousStory: () {},
          onNextStory: () {},
          onClose: () {},
          onPause: () => pauseCount += 1,
          onResume: () => resumeCount += 1,
          previousLabel: 'Précédent',
          nextLabel: 'Suivant',
          closeLabel: 'Fermer',
          child: const ColoredBox(color: Colors.transparent),
        ),
      ),
    );
    await tester.pump();

    final gesture = await tester.startGesture(
      tester.getCenter(find.byKey(const ValueKey('hold-story-frame'))),
    );
    await tester.pump(const Duration(milliseconds: 600));
    expect(pauseCount, 1);
    expect(resumeCount, 0);

    await gesture.up();
    await tester.pump();
    expect(resumeCount, 1);
    expect(tester.takeException(), isNull);
  });

  testWidgets('YouTube story viewer keeps a portrait frame on the Web',
      (tester) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      _app(
        locale: const Locale('cr'),
        themeMode: ThemeMode.light,
        child: YoutubeStoryViewer(
          videos: [
            _video(
              title: 'Videyo CHOLOTO',
              publishedAt: DateTime.now().subtract(const Duration(hours: 3)),
            ),
          ],
          onClose: () {},
          storyDuration: const Duration(hours: 1),
        ),
      ),
    );
    await tester.pump();

    final viewerSize =
        tester.getSize(find.byKey(const ValueKey('youtube-story-viewer')));
    expect(viewerSize.height, 800.0);
    expect(
      viewerSize.width / viewerSize.height,
      closeTo(youtubeStoryAspectRatio, 0.001),
    );
    expect(find.text('Videyo CHOLOTO'), findsOneWidget);
    expect(
      find.text(FFLocalizations(const Locale('cr')).getText('ytwatch1')),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });
}
