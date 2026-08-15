import 'package:choloto/accomplissements/achievement_progress.dart';
import 'package:choloto/accomplissements/achievements_tab_widget.dart';
import 'package:choloto/flutter_flow/internationalization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _app({
  required Widget child,
  Locale locale = const Locale('fr'),
  ThemeMode themeMode = ThemeMode.dark,
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
    theme: ThemeData(
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: Color(0xFFEDB900),
        onPrimary: Color(0xFF000000),
      ),
    ),
    darkTheme: ThemeData(
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFFEDB900),
        onPrimary: Color(0xFF000000),
      ),
    ),
    themeMode: themeMode,
    home: Scaffold(body: SafeArea(child: child)),
  );
}

const _snapshot = AchievementSnapshot(
  currentStreak: 4,
  longestStreak: 7,
  totalActiveDays: 12,
  recentActiveDays: [
    '2026-08-10',
    '2026-08-11',
    '2026-08-12',
    '2026-08-13',
    '2026-08-14',
  ],
  reportedWins: 5,
  reportedMisses: 3,
  memberDays: 40,
  hasCompleteProfile: true,
);

void main() {
  for (final locale in const [Locale('fr'), Locale('en'), Locale('cr')]) {
    for (final themeMode in const [ThemeMode.dark, ThemeMode.light]) {
      testWidgets(
          'renders ${locale.languageCode} in ${themeMode.name} mode without overflow',
          (tester) async {
        tester.view.physicalSize = const Size(360, 740);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(
          _app(
            locale: locale,
            themeMode: themeMode,
            child: AchievementDashboard(
              snapshot: _snapshot,
              now: DateTime(2026, 8, 14),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(
            find.byKey(const ValueKey('current-streak-value')), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    }
  }

  testWidgets('renders and scrolls without overflow on a small dark mobile',
      (tester) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      _app(
        child: AchievementDashboard(
          snapshot: _snapshot,
          now: DateTime(2026, 8, 14),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('current-streak-value')), findsOneWidget);
    expect(find.text('jours d’affilée'), findsOneWidget);
    expect(find.byKey(const ValueKey('achievement-streak_7')), findsOneWidget);
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('achievement-profile_complete')),
      500,
      scrollable: find.descendant(
        of: find.byKey(const ValueKey('achievements-scroll-view')),
        matching: find.byType(Scrollable),
      ),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('uses four badge columns on a wide light web viewport',
      (tester) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      _app(
        locale: const Locale('en'),
        themeMode: ThemeMode.light,
        child: AchievementDashboard(
          snapshot: _snapshot,
          now: DateTime(2026, 8, 14),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final firstRow = ['streak_3', 'streak_7', 'streak_14', 'streak_30']
        .map((id) =>
            tester.getTopLeft(find.byKey(ValueKey('achievement-$id'))).dy)
        .toSet();
    expect(firstRow.length, 1);
    expect(find.text('days in a row'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('supports Creole and exposes locked badge semantics',
      (tester) async {
    final semantics = tester.ensureSemantics();

    await tester.pumpWidget(
      _app(
        locale: const Locale('cr'),
        child: AchievementDashboard(
          snapshot: const AchievementSnapshot(
            currentStreak: 1,
            longestStreak: 1,
          ),
          now: DateTime(2026, 8, 14),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Seri ou genyen kounye a'), findsOneWidget);
    final badgeSemantics = tester.getSemantics(
      find
          .ancestor(
            of: find.byKey(const ValueKey('achievement-streak_3')),
            matching: find.byType(Semantics),
          )
          .first,
    );
    expect(badgeSemantics.label, 'Etensèl');
    expect(badgeSemantics.value, contains('Bloke'));
    expect(badgeSemantics.value, contains('1'));
    expect(badgeSemantics.value, contains('3'));
    expect(tester.takeException(), isNull);
    semantics.dispose();
  });

  testWidgets('renders localized guest and error states', (tester) async {
    await tester.pumpWidget(
      _app(
        locale: const Locale('en'),
        child: const AchievementAccessState(
          icon: Icons.cloud_off_outlined,
          titleKey: 'ach_error_title',
          descriptionKey: 'ach_error_desc',
        ),
      ),
    );

    expect(find.text('Your achievements are unavailable'), findsOneWidget);
    expect(find.byIcon(Icons.cloud_off_outlined), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
