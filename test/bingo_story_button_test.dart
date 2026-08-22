import 'package:choloto/autres/bingo/bingo/bingo_dialog.dart';
import 'package:choloto/autres/bingo/bingo/bingo_story_button.dart';
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
    }
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
