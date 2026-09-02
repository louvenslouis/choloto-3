import 'package:choloto/components/home_stories_rail.dart';
import 'package:choloto/flutter_flow/internationalization.dart';
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

          expect(
            find.text(
              FFLocalizations(locale).getText('home_stories_title'),
            ),
            findsOneWidget,
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
    expect(find.byKey(const ValueKey('home-stories-title')), findsOneWidget);
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
