import 'package:choloto/flutter_flow/internationalization.dart';
import 'package:choloto/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _navigationApp({
  required Locale locale,
  required ThemeMode themeMode,
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
    home: NavBarPage(
      initialPage: 'VIP',
      page: const ColoredBox(
        key: ValueKey('navigation-test-page'),
        color: Colors.transparent,
      ),
    ),
  );
}

Future<void> _pumpAtSize(
  WidgetTester tester, {
  required Size size,
  Locale locale = const Locale('fr'),
  ThemeMode themeMode = ThemeMode.dark,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    _navigationApp(locale: locale, themeMode: themeMode),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('keeps bottom navigation on a small phone', (tester) async {
    await _pumpAtSize(tester, size: const Size(320, 568));

    expect(
      find.byKey(const ValueKey('primary-bottom-navigation')),
      findsOneWidget,
    );
    expect(find.byType(NavigationRail), findsNothing);
    expect(
      tester
          .widget<BottomNavigationBar>(find.byType(BottomNavigationBar))
          .currentIndex,
      2,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('keeps bottom navigation on tablet portrait', (tester) async {
    await _pumpAtSize(tester, size: const Size(600, 900));

    expect(
      find.byKey(const ValueKey('primary-bottom-navigation')),
      findsOneWidget,
    );
    expect(find.byType(NavigationRail), findsNothing);
    expect(tester.takeException(), isNull);
  });

  for (final locale in const [Locale('fr'), Locale('en'), Locale('cr')]) {
    for (final themeMode in const [ThemeMode.dark, ThemeMode.light]) {
      testWidgets(
        'uses a compact tablet-landscape menu in ${locale.languageCode} '
        'and ${themeMode.name} mode',
        (tester) async {
          await _pumpAtSize(
            tester,
            size: const Size(800, 600),
            locale: locale,
            themeMode: themeMode,
          );

          final rail = tester.widget<NavigationRail>(
            find.byKey(const ValueKey('primary-navigation-rail')),
          );

          expect(find.byType(BottomNavigationBar), findsNothing);
          expect(rail.extended, isFalse);
          expect(rail.labelType, NavigationRailLabelType.all);
          expect(rail.selectedIndex, 2);
          expect(rail.destinations, hasLength(4));
          expect(
            find.byKey(const ValueKey('primary-navigation-logo')),
            findsOneWidget,
          );
          expect(tester.takeException(), isNull);
        },
      );

      testWidgets(
        'uses an extended desktop menu in ${locale.languageCode} '
        'and ${themeMode.name} mode',
        (tester) async {
          await _pumpAtSize(
            tester,
            size: const Size(1440, 900),
            locale: locale,
            themeMode: themeMode,
          );

          final rail = tester.widget<NavigationRail>(
            find.byKey(const ValueKey('primary-navigation-rail')),
          );
          final localizations = FFLocalizations(locale);

          expect(find.byType(BottomNavigationBar), findsNothing);
          expect(rail.extended, isTrue);
          expect(rail.labelType, NavigationRailLabelType.none);
          expect(rail.selectedIndex, 2);
          expect(
            find.text(localizations.getText('uer2q4no')),
            findsOneWidget,
          );
          expect(
            find.text(localizations.getText('wakkucok')),
            findsOneWidget,
          );
          expect(
            find.text(localizations.getText('xj2saev3')),
            findsOneWidget,
          );
          expect(
            find.text(localizations.getText('14smzvpm')),
            findsOneWidget,
          );
          expect(tester.takeException(), isNull);
        },
      );
    }
  }
}
