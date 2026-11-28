import 'package:choloto/autres/calendrier/calendrier/calendrier_widget.dart';
import 'package:choloto/backend/schema/bingo_record.dart';
import 'package:choloto/components/draw_result_chip.dart';
import 'package:choloto/flutter_flow/flutter_flow_theme.dart';
import 'package:choloto/flutter_flow/internationalization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/memory_firestore.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    await (FontLoader('Google sans flex')
          ..addFont(rootBundle.load(
              'assets/fonts/GoogleSansFlex-VariableFont_GRAD,ROND,opsz,slnt,wdth,wght.ttf')))
        .load();
  });
  for (final locale in ['fr', 'en', 'cr']) {
    for (final brightness in Brightness.values) {
      for (final size in [const Size(320, 568), const Size(1440, 900)]) {
        testWidgets('Bingo calendar $locale ${brightness.name} ${size.width}',
            (tester) async {
          tester.view.devicePixelRatio = 1;
          tester.view.physicalSize = size;
          tester.platformDispatcher.platformBrightnessTestValue = brightness;
          addTearDown(tester.view.resetDevicePixelRatio);
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(
              tester.platformDispatcher.clearPlatformBrightnessTestValue);

          final now = DateTime.now();
          final stream = Stream.value([
            BingoRecord.getDocumentFromData({
              'date': DateTime(now.year, now.month, 2),
              'dataStack': [
                {'boul': '07', 'tirage': 'New York'},
                {'boul': '23', 'tirage': 'Floride'},
              ],
            }, MemoryReference('bingo/day-2')),
          ]);
          await tester.pumpWidget(MaterialApp(
            theme: ThemeData.dark(),
            locale: Locale(locale),
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
              body: Padding(
                padding: const EdgeInsets.fromLTRB(6, 6, 6, 0),
                child: CalendrierWidget(watchMonth: (_, __) => stream),
              ),
            ),
          ));
          await tester.pumpAndSettle();

          final grid = tester
              .widget<GridView>(find.byType(GridView))
              .gridDelegate as SliverGridDelegateWithFixedCrossAxisCount;
          expect(grid.crossAxisCount, 7);
          expect(grid.crossAxisSpacing, 5);
          expect(grid.mainAxisSpacing, 5);
          expect(grid.childAspectRatio, .76);

          final theme = DarkModeTheme();
          Finder day(int number) =>
              find.byKey(ValueKey('calendar-day-$number'));
          BoxDecoration surface(int number) => tester
              .widget<Ink>(
                find.descendant(of: day(number), matching: find.byType(Ink)),
              )
              .decoration! as BoxDecoration;

          expect(surface(2).gradient, theme.designToken.home.membership);
          expect(surface(1).color, theme.designToken.background.home);
          expect(find.text('×2'), findsOneWidget);
          await tester.tap(day(1));
          await tester.pumpAndSettle();
          expect(find.byType(DrawResultChip), findsNothing);
          await tester.tap(day(2));
          await tester.pumpAndSettle();
          expect(tester.getSize(find.byType(DrawResultChip).first),
              const Size.square(48));
          expect(find.text('07'), findsOneWidget);
          expect(find.widgetWithText(DrawResultChip, '23'), findsOneWidget);
          expect(tester.takeException(), isNull);
        });
      }
    }
  }
}
