import 'package:choloto/components/welcome_widget.dart';
import 'package:choloto/flutter_flow/internationalization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _onboardingApp({
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
    home: const Scaffold(body: SafeArea(child: WelcomeWidget())),
  );
}

void main() {
  const onboardingKeys = [
    'onboarding_eyebrow',
    'onboarding_title',
    'onboarding_description',
    'onboarding_feature_results',
    'onboarding_feature_tchala',
    'onboarding_feature_vip',
    'onboarding_continue_title',
    'onboarding_logo_label',
  ];

  test('onboarding copy is available in every supported language', () {
    for (final language in FFLocalizations.languages()) {
      final localizations = FFLocalizations(Locale(language));
      for (final key in onboardingKeys) {
        expect(
          localizations.getText(key).trim(),
          isNotEmpty,
          reason: 'Missing $language onboarding translation for $key',
        );
      }
    }
  });

  for (final locale in const [Locale('fr'), Locale('en'), Locale('cr')]) {
    for (final themeMode in const [ThemeMode.dark, ThemeMode.light]) {
      testWidgets(
        'onboarding renders ${locale.languageCode} on a small mobile in ${themeMode.name} mode',
        (tester) async {
          tester.view.physicalSize = const Size(320, 568);
          tester.view.devicePixelRatio = 1.0;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);

          await tester.pumpWidget(
            _onboardingApp(locale: locale, themeMode: themeMode),
          );
          await tester.pumpAndSettle();

          final localizations = FFLocalizations(locale);
          expect(
            find.text(localizations.getText('onboarding_title')),
            findsOneWidget,
          );
          expect(
            find.byKey(const ValueKey('onboarding-hero')),
            findsOneWidget,
          );
          expect(
            find.byKey(const ValueKey('onboarding-copy-overlay')),
            findsOneWidget,
          );
          expect(find.byType(BackdropFilter), findsOneWidget);
          expect(find.byType(SingleChildScrollView), findsNothing);
          expect(
            find.byKey(const ValueKey('onboarding-google-button')),
            findsOneWidget,
          );
          expect(
            find.byKey(const ValueKey('onboarding-email-button')),
            findsOneWidget,
          );
          expect(
            find.byKey(const ValueKey('onboarding-guest-button')),
            findsOneWidget,
          );
          final guestButtonRect = tester.getRect(
            find.byKey(const ValueKey('onboarding-guest-button')),
          );
          expect(guestButtonRect.top, greaterThanOrEqualTo(0.0));
          expect(guestButtonRect.bottom, lessThanOrEqualTo(568.0));
          expect(tester.takeException(), isNull);
        },
      );
    }
  }

  for (final themeMode in const [ThemeMode.dark, ThemeMode.light]) {
    testWidgets(
      'onboarding uses the split web layout in ${themeMode.name} mode',
      (tester) async {
        tester.view.physicalSize = const Size(1280, 800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(
          _onboardingApp(
            locale: const Locale('fr'),
            themeMode: themeMode,
          ),
        );
        await tester.pumpAndSettle();

        expect(
          find.byKey(const ValueKey('onboarding-wide-panel')),
          findsOneWidget,
        );
        expect(
          find.byKey(const ValueKey('onboarding-hero')),
          findsOneWidget,
        );
        expect(
          find.byKey(const ValueKey('onboarding-content')),
          findsOneWidget,
        );
        expect(find.byType(SingleChildScrollView), findsNothing);
        final panelRect = tester.getRect(
          find.byKey(const ValueKey('onboarding-wide-panel')),
        );
        expect(panelRect.top, greaterThanOrEqualTo(0.0));
        expect(panelRect.bottom, lessThanOrEqualTo(800.0));
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets('onboarding fits a phone landscape viewport without scrolling',
      (tester) async {
    tester.view.physicalSize = const Size(568, 320);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      _onboardingApp(
        locale: const Locale('fr'),
        themeMode: ThemeMode.dark,
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('onboarding-wide-panel')),
      findsOneWidget,
    );
    expect(find.byType(SingleChildScrollView), findsNothing);
    final guestButtonRect = tester.getRect(
      find.byKey(const ValueKey('onboarding-guest-button')),
    );
    expect(guestButtonRect.top, greaterThanOrEqualTo(0.0));
    expect(guestButtonRect.bottom, lessThanOrEqualTo(320.0));
    expect(tester.takeException(), isNull);
  });
}
