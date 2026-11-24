import 'package:choloto/components/home_header_actions.dart';
import 'package:choloto/flutter_flow/internationalization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _app({
  required Locale locale,
  required ThemeMode themeMode,
  required HomeHeaderActions actions,
  required HomeSupportFab support,
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
      floatingActionButton: support,
      appBar: AppBar(
        title: const Text('CHOLOTO'),
        actions: [actions, const SizedBox(width: 8.0)],
      ),
    ),
  );
}

void main() {
  const supportLabels = {
    'fr': 'Chat service client',
    'en': 'Customer support chat',
    'cr': 'Chat sèvis kliyan',
  };

  for (final locale in const [Locale('fr'), Locale('en'), Locale('cr')]) {
    for (final variant in const [
      (Size(320.0, 568.0), ThemeMode.dark),
      (Size(1280.0, 800.0), ThemeMode.light),
    ]) {
      testWidgets(
        'home support is a floating action in ${locale.languageCode} at '
        '${variant.$1.width.toInt()} px ${variant.$2.name}',
        (tester) async {
          tester.view.physicalSize = variant.$1;
          tester.view.devicePixelRatio = 1.0;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);

          var supportOpened = false;
          await tester.pumpWidget(
            _app(
              locale: locale,
              themeMode: variant.$2,
              support:
                  HomeSupportFab(onSupport: () async => supportOpened = true),
              actions: HomeHeaderActions(
                onAchievements: () async {},
                onSettings: () async {},
              ),
            ),
          );
          await tester.pumpAndSettle();

          expect(find.byKey(const ValueKey('home-header-actions')), findsOne);
          expect(find.byType(IconButton), findsNWidgets(2));
          expect(
            find.byTooltip(supportLabels[locale.languageCode]!),
            findsOneWidget,
          );
          expect(find.byIcon(Icons.support_agent_rounded), findsOneWidget);
          final support = find.byKey(const ValueKey('home-support-button'));
          expect(find.descendant(of: find.byType(AppBar), matching: support),
              findsNothing);
          expect(find.byType(FloatingActionButton), findsOneWidget);
          expect(tester.getBottomRight(support).dx, lessThan(variant.$1.width));
          expect(tester.getTopLeft(support).dy,
              greaterThan(variant.$1.height / 2));

          await tester.tap(
            find.byKey(const ValueKey('home-support-button')),
          );
          await tester.pump();

          expect(supportOpened, isTrue);
          expect(tester.takeException(), isNull);
        },
      );
    }
  }

  testWidgets('home support shows the pending message badge and can shake',
      (tester) async {
    var opened = false;
    Widget scene(int count) => _app(
          locale: const Locale('fr'),
          themeMode: ThemeMode.dark,
          support: HomeSupportFab(
            messageCount: count,
            shakeTrigger: count > 0 ? 1 : 0,
            onSupport: () async => opened = true,
          ),
          actions: HomeHeaderActions(
            onAchievements: () async {},
            onSettings: () async {},
          ),
        );
    final badge = find.byKey(const ValueKey('home-support-message-count'));
    await tester.pumpWidget(scene(0));
    expect(badge, findsNothing);
    await tester.pumpWidget(scene(3));
    expect(badge, findsOneWidget);
    expect(find.text('3'), findsOneWidget);
    expect(find.byTooltip('Chat service client. 3 nouveaux messages'),
        findsOneWidget);
    await tester.tapAt(tester.getBottomLeft(badge) + const Offset(3, -3));
    expect(opened, isTrue);
    await tester.pump(const Duration(milliseconds: 620));
    await tester.pumpWidget(scene(104));
    expect(find.text('99+'), findsOneWidget);
    await tester.pumpWidget(scene(0));
    expect(badge, findsNothing);
    expect(tester.takeException(), isNull);
  });
}
