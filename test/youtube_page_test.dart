import 'dart:async';

import 'package:choloto/backend/schema/structs/youtube_item_struct.dart';
import 'package:choloto/flutter_flow/flutter_flow_theme.dart';
import 'package:choloto/flutter_flow/internationalization.dart';
import 'package:choloto/youtube/youtube_widget.dart';
import 'package:firebase_core/firebase_core.dart';
// ignore: depend_on_referenced_packages
import 'package:firebase_core_platform_interface/test.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

// ignore: depend_on_referenced_packages
import 'package:url_launcher_platform_interface/url_launcher_platform_interface.dart';

class _VideoLauncher extends UrlLauncherPlatform {
  @override
  Null get linkDelegate => null;

  final opened = <String>[];

  @override
  Future<bool> launchUrl(String url, LaunchOptions options) async {
    opened.add(url);
    return true;
  }
}

final _videos = List.generate(
    7,
    (i) => YoutubeItemStruct(
          title: 'Vidéo ${i + 1}',
          link: 'https://www.youtube.com/watch?v=$i',
          pubDate: '2026-11-27',
        ));

Future<void> _show(
  WidgetTester tester,
  YoutubeWidget page, {
  String language = 'fr',
  double width = 320,
  Brightness system = Brightness.dark,
  double textScale = 1,
}) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = Size(width, width < 600 ? 640 : 900);
  tester.platformDispatcher.platformBrightnessTestValue = system;
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
  await tester.pumpWidget(MaterialApp(
    theme: DarkModeTheme().materialTheme,
    home: page,
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
    builder: (context, child) => MediaQuery(
      data: MediaQuery.of(context)
          .copyWith(textScaler: TextScaler.linear(textScale)),
      child: child!,
    ),
  ));
  await tester.pump();
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
  });
  for (final language in ['fr', 'en', 'cr']) {
    for (final system in Brightness.values) {
      for (final width in [320.0, 800.0, 1440.0]) {
        testWidgets('YouTube $language ${system.name} $width', (tester) async {
          await _show(
              tester,
              YoutubeWidget(
                  loadVideos: ({required fallbackTitle}) async => _videos),
              language: language,
              width: width,
              system: system);
          await tester.pumpAndSettle();
          final header = find.byType(PinnedHeaderSliver);
          expect(find.descendant(of: header, matching: find.byType(Image)),
              findsNothing);
          expect(
              find.text(FFLocalizations(Locale(language)).getText('ytchnbtn')),
              findsNothing);
          final first = tester.getTopLeft(find.text(_videos.first.title));
          final second = tester.getTopLeft(find.text(_videos[1].title));
          if (width == 320) {
            expect(second.dy, greaterThan(first.dy));
          } else {
            expect(second.dy, first.dy);
            expect(second.dx, greaterThan(first.dx));
            final third = tester.getTopLeft(find.text(_videos[2].title));
            expect(third.dy,
                width == 800 ? greaterThan(first.dy) : equals(first.dy));
          }
          await tester.scrollUntilVisible(find.text(_videos.last.title), 250,
              scrollable: find.byType(Scrollable).first);
          expect(find.byType(BackButton).hitTestable(), findsOneWidget);
          expect(tester.takeException(), isNull);
        });
      }
    }
  }

  testWidgets('cards open the selected video', (tester) async {
    final previous = UrlLauncherPlatform.instance;
    final launcher = _VideoLauncher();
    UrlLauncherPlatform.instance = launcher;
    addTearDown(() => UrlLauncherPlatform.instance = previous);
    await _show(tester,
        YoutubeWidget(loadVideos: ({required fallbackTitle}) async => _videos));
    await tester.pumpAndSettle();
    await tester.tap(find.text(_videos[1].title));
    expect(launcher.opened, [
      _videos[1].link,
    ]);
  });

  testWidgets('loading, retry, empty feed and failed refresh with saved videos',
      (tester) async {
    var pending = Completer<List<YoutubeItemStruct>>();
    final page =
        YoutubeWidget(loadVideos: ({required fallbackTitle}) => pending.future);
    await _show(tester, page, textScale: 1.6);
    final t = FFLocalizations(const Locale('fr')).getText;
    expect(find.text(t('ytloading')), findsOneWidget);
    pending.completeError(StateError('offline'));
    await tester.pump();
    await tester.pumpAndSettle();
    expect(find.text(t('yterrttl')), findsOneWidget);
    Future<void> reload(String action, List<YoutubeItemStruct> result) async {
      pending = Completer();
      await tester.dragUntilVisible(find.text(t(action)).hitTestable(),
          find.byType(CustomScrollView), const Offset(0, -140));
      await tester.tap(find.text(t(action)));
      pending.complete(result);
      await tester.pump();
      await tester.pumpAndSettle();
    }

    await reload('ytretry1', []);
    expect(find.text(t('ytemptyt')), findsOneWidget);
    await reload('ytretry1', _videos);
    expect(find.text(_videos.first.title), findsOneWidget);
    pending = Completer();
    tester
        .state<ScrollableState>(find.byType(Scrollable).first)
        .position
        .jumpTo(0);
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.refresh_rounded));
    pending.completeError(StateError('offline'));
    await tester.pump();
    await tester.pumpAndSettle();
    final notice = find.text(t('ytrefrer'), skipOffstage: false);
    await tester.ensureVisible(notice);
    await tester.pumpAndSettle();
    expect(notice.hitTestable(), findsOneWidget);
    await tester
        .ensureVisible(find.text(_videos.first.title, skipOffstage: false));
    await tester.pumpAndSettle();
    expect(find.text(_videos.first.title), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
