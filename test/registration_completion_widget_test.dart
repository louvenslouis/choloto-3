import 'dart:async';

import 'package:choloto/backend/backend.dart';
import 'package:choloto/components/registration_completion_widget.dart';
import 'package:choloto/flutter_flow/internationalization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _app({
  required Locale locale,
  required ThemeMode themeMode,
  RegistrationSubmission? onSubmit,
  ValueChanged<String>? onLanguageSaved,
  VoidCallback? onCompleted,
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
    home: RegistrationCompletionWidget(
      onSubmit: onSubmit,
      onLanguageSaved: onLanguageSaved,
      onCompleted: onCompleted,
    ),
  );
}

void main() {
  const registrationKeys = [
    'registration_eyebrow',
    'registration_title',
    'registration_description',
    'registration_language_label',
    'registration_language_fr',
    'registration_language_en',
    'registration_language_cr',
    'registration_phone_label',
    'registration_phone_hint',
    'registration_validate',
    'registration_phone_invalid',
    'registration_language_required',
    'registration_save_error',
  ];

  test('normalizes and validates supported registration phone numbers', () {
    expect(
      normalizeRegistrationPhoneNumber(' +509 (37) 00-00-00 '),
      '+50937000000',
    );
    expect(isValidRegistrationPhoneNumber('+50937000000'), isTrue);
    expect(isValidRegistrationPhoneNumber('37000000'), isTrue);
    expect(isValidRegistrationPhoneNumber(''), isTrue);
    expect(isValidRegistrationPhoneNumber('123'), isFalse);
    expect(isValidRegistrationPhoneNumber('phone-number'), isFalse);
  });

  test('registration copy is available in every supported language', () {
    for (final language in FFLocalizations.languages()) {
      final localizations = FFLocalizations(Locale(language));
      for (final key in registrationKeys) {
        expect(
          localizations.getText(key).trim(),
          isNotEmpty,
          reason: 'Missing $language registration translation for $key',
        );
      }
    }
  });

  for (final locale in const [Locale('fr'), Locale('en'), Locale('cr')]) {
    for (final themeMode in const [ThemeMode.dark, ThemeMode.light]) {
      testWidgets(
        'registration renders ${locale.languageCode} on mobile in ${themeMode.name} mode',
        (tester) async {
          tester.view.physicalSize = const Size(320, 568);
          tester.view.devicePixelRatio = 1.0;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);

          await tester.pumpWidget(
            _app(locale: locale, themeMode: themeMode),
          );
          await tester.pumpAndSettle();

          expect(
            find.text(FFLocalizations(locale).getText('registration_title')),
            findsOneWidget,
          );
          expect(
            find.byKey(const ValueKey('registration-phone-field')),
            findsOneWidget,
          );
          expect(
            find.byKey(const ValueKey('registration-submit-button')),
            findsOneWidget,
          );
          expect(tester.takeException(), isNull);
        },
      );
    }
  }

  testWidgets('registration fits a web viewport', (tester) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      _app(locale: const Locale('fr'), themeMode: ThemeMode.dark),
    );
    await tester.pumpAndSettle();

    final card = tester.getRect(
      find.byKey(const ValueKey('registration-completion-card')),
    );
    expect(card.width, lessThanOrEqualTo(560.0));
    expect(tester.takeException(), isNull);
  });

  testWidgets('validation requires a valid phone number', (tester) async {
    await tester.pumpWidget(
      _app(locale: const Locale('fr'), themeMode: ThemeMode.dark),
    );
    await tester.enterText(
      find.byKey(const ValueKey('registration-phone-field')),
      '123',
    );
    await tester.tap(find.byKey(const ValueKey('registration-submit-button')));
    await tester.pump();

    expect(
      find.text(
        FFLocalizations(const Locale('fr'))
            .getText('registration_phone_invalid'),
      ),
      findsOneWidget,
    );
  });

  testWidgets('validation can continue without a phone number', (tester) async {
    String? savedPhoneNumber;
    var completed = false;

    await tester.pumpWidget(
      _app(
        locale: const Locale('fr'),
        themeMode: ThemeMode.dark,
        onSubmit: ({
          required phoneNumber,
          required preferredLanguage,
          required device,
        }) async {
          savedPhoneNumber = phoneNumber;
        },
        onCompleted: () => completed = true,
      ),
    );

    await tester.tap(find.byKey(const ValueKey('registration-submit-button')));
    await tester.pumpAndSettle();

    expect(savedPhoneNumber, isEmpty);
    expect(completed, isTrue);
    expect(
      find.byKey(const ValueKey('registration-validation-message')),
      findsNothing,
    );
  });

  testWidgets('validation saves the chosen language before completing',
      (tester) async {
    String? savedPhoneNumber;
    String? savedLanguage;
    String? appliedLanguage;
    var completed = false;

    await tester.pumpWidget(
      _app(
        locale: const Locale('fr'),
        themeMode: ThemeMode.dark,
        onSubmit: ({
          required phoneNumber,
          required preferredLanguage,
          required device,
        }) async {
          savedPhoneNumber = phoneNumber;
          savedLanguage = preferredLanguage;
        },
        onLanguageSaved: (language) => appliedLanguage = language,
        onCompleted: () => completed = true,
      ),
    );

    await tester.tap(find.byKey(const ValueKey('registration-language-en')));
    await tester.enterText(
      find.byKey(const ValueKey('registration-phone-field')),
      '+509 37 00 00 00',
    );
    await tester.tap(find.byKey(const ValueKey('registration-submit-button')));
    await tester.pumpAndSettle();

    expect(savedPhoneNumber, '+50937000000');
    expect(savedLanguage, 'en');
    expect(appliedLanguage, 'en');
    expect(completed, isTrue);
  });

  testWidgets('completion waits for the profile write to finish',
      (tester) async {
    final profileWrite = Completer<void>();
    var completed = false;

    await tester.pumpWidget(
      _app(
        locale: const Locale('fr'),
        themeMode: ThemeMode.dark,
        onSubmit: ({
          required phoneNumber,
          required preferredLanguage,
          required device,
        }) =>
            profileWrite.future,
        onLanguageSaved: (_) {},
        onCompleted: () => completed = true,
      ),
    );
    await tester.enterText(
      find.byKey(const ValueKey('registration-phone-field')),
      '+509 37 00 00 00',
    );
    await tester.tap(find.byKey(const ValueKey('registration-submit-button')));
    await tester.pump();

    expect(completed, isFalse);

    profileWrite.complete();
    await tester.pumpAndSettle();

    expect(completed, isTrue);
  });
}
