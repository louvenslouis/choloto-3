import 'package:choloto/components/rappel_fin_abonnement_widget.dart';
import 'package:choloto/flutter_flow/internationalization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _app({
  required Locale locale,
  required ThemeMode themeMode,
  VoidCallback? onRenew,
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
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: RappelFinAbonnementWidget(
            expiration: DateTime(2026, 8, 25, 12),
            onRenew: onRenew ?? () {},
            onDismiss: () {},
          ),
        ),
      ),
    ),
  );
}

void main() {
  group('subscription expiration reminder window', () {
    final now = DateTime.utc(2026, 8, 23, 12);

    test('includes an active subscription expiring in exactly two days', () {
      expect(
        shouldShowSubscriptionExpirationReminder(
          expiration: now.add(const Duration(days: 2)),
          now: now,
        ),
        isTrue,
      );
    });

    test('includes an active subscription expiring in less than two days', () {
      expect(
        shouldShowSubscriptionExpirationReminder(
          expiration: now.add(const Duration(hours: 12)),
          now: now,
        ),
        isTrue,
      );
    });

    test('excludes dates beyond the two-day window', () {
      expect(
        shouldShowSubscriptionExpirationReminder(
          expiration: now.add(const Duration(days: 2, milliseconds: 1)),
          now: now,
        ),
        isFalse,
      );
    });

    test('excludes missing, current, and expired dates', () {
      expect(
        shouldShowSubscriptionExpirationReminder(
          expiration: null,
          now: now,
        ),
        isFalse,
      );
      expect(
        shouldShowSubscriptionExpirationReminder(
          expiration: now,
          now: now,
        ),
        isFalse,
      );
      expect(
        shouldShowSubscriptionExpirationReminder(
          expiration: now.subtract(const Duration(seconds: 1)),
          now: now,
        ),
        isFalse,
      );
    });
  });

  for (final locale in const [Locale('fr'), Locale('en'), Locale('cr')]) {
    for (final themeMode in const [ThemeMode.dark, ThemeMode.light]) {
      testWidgets(
        'reminder fits a small ${themeMode.name} screen in ${locale.languageCode}',
        (tester) async {
          tester.view.physicalSize = const Size(320, 568);
          tester.view.devicePixelRatio = 1.0;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);

          await tester.pumpWidget(
            _app(locale: locale, themeMode: themeMode),
          );
          await tester.pumpAndSettle();

          final localizations = FFLocalizations(locale);
          expect(
            find.text(
              localizations.getText(
                'subscription_expiration_reminder_title',
              ),
            ),
            findsOneWidget,
          );
          expect(
            find.byKey(const ValueKey('subscription-reminder-renew')),
            findsOneWidget,
          );
          expect(
            find.byKey(const ValueKey('subscription-reminder-later')),
            findsOneWidget,
          );
          expect(tester.takeException(), isNull);
        },
      );
    }
  }

  testWidgets('renew action remains available on a wide web viewport',
      (tester) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    var renewTapped = false;

    await tester.pumpWidget(
      _app(
        locale: const Locale('fr'),
        themeMode: ThemeMode.dark,
        onRenew: () => renewTapped = true,
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(const ValueKey('subscription-reminder-renew')),
    );
    await tester.pump();

    expect(renewTapped, isTrue);
    expect(tester.takeException(), isNull);
  });

  testWidgets('long Creole content remains scrollable in phone landscape',
      (tester) async {
    tester.view.physicalSize = const Size(568, 320);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      _app(
        locale: const Locale('cr'),
        themeMode: ThemeMode.light,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(SingleChildScrollView), findsOneWidget);
    expect(
      find.byKey(const ValueKey('subscription-reminder-renew')),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });
}
