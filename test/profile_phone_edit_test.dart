import 'package:choloto/flutter_flow/internationalization.dart';
import 'package:choloto/settings/profil/edit_profil_texts/edit_profil_texts_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _app({
  required Locale locale,
  required ThemeMode themeMode,
  String initialValue = '',
  ProfilePhoneSave? onPhoneSaved,
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
      body: EditProfilTextsWidget(
        champ: 3,
        initialValue: initialValue,
        onPhoneSaved: onPhoneSaved ?? (_) async {},
      ),
    ),
  );
}

void main() {
  const profilePhoneKeys = [
    'profile_phone_label',
    'profile_phone_add',
    'profile_phone_edit',
    'profile_phone_hint',
    'profile_phone_required',
    'profile_save_error',
  ];

  test('phone profile copy is available in every supported language', () {
    for (final language in FFLocalizations.languages()) {
      final localizations = FFLocalizations(Locale(language));
      for (final key in profilePhoneKeys) {
        expect(
          localizations.getText(key).trim(),
          isNotEmpty,
          reason: 'Missing $language phone profile translation for $key',
        );
      }
    }
  });

  testWidgets('prefills the existing profile phone number', (tester) async {
    await tester.pumpWidget(
      _app(
        locale: const Locale('fr'),
        themeMode: ThemeMode.dark,
        initialValue: '+50937000000',
      ),
    );

    final field = tester.widget<TextField>(
      find.byKey(const ValueKey('profile-phone-field')),
    );
    expect(field.controller?.text, '+50937000000');
    expect(field.keyboardType, TextInputType.phone);
  });

  testWidgets('requires a phone number before saving', (tester) async {
    var saveCount = 0;
    await tester.pumpWidget(
      _app(
        locale: const Locale('fr'),
        themeMode: ThemeMode.dark,
        onPhoneSaved: (_) async => saveCount++,
      ),
    );

    await tester.tap(find.byKey(const ValueKey('profile-save-button')));
    await tester.pump();

    expect(saveCount, 0);
    expect(
      find.text(
        FFLocalizations(const Locale('fr')).getText('profile_phone_required'),
      ),
      findsOneWidget,
    );
  });

  testWidgets('rejects an invalid phone number', (tester) async {
    var saveCount = 0;
    await tester.pumpWidget(
      _app(
        locale: const Locale('en'),
        themeMode: ThemeMode.light,
        onPhoneSaved: (_) async => saveCount++,
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const ValueKey('profile-phone-field')),
      '123',
    );
    await tester.tap(find.byKey(const ValueKey('profile-save-button')));
    await tester.pump();

    expect(saveCount, 0);
    expect(
      find.text(
        FFLocalizations(const Locale('en'))
            .getText('registration_phone_invalid'),
      ),
      findsOneWidget,
    );
  });

  testWidgets('normalizes and saves a valid phone number', (tester) async {
    String? savedPhoneNumber;
    await tester.pumpWidget(
      _app(
        locale: const Locale('cr'),
        themeMode: ThemeMode.dark,
        onPhoneSaved: (phoneNumber) async {
          savedPhoneNumber = phoneNumber;
        },
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const ValueKey('profile-phone-field')),
      '+509 (37) 00-00-00',
    );
    await tester.tap(find.byKey(const ValueKey('profile-save-button')));
    await tester.pumpAndSettle();

    expect(savedPhoneNumber, '+50937000000');
    expect(tester.takeException(), isNull);
  });

  testWidgets('keeps the editor open and explains a save failure',
      (tester) async {
    await tester.pumpWidget(
      _app(
        locale: const Locale('fr'),
        themeMode: ThemeMode.dark,
        onPhoneSaved: (_) => Future<void>.error(Exception('offline')),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const ValueKey('profile-phone-field')),
      '+50937000000',
    );
    await tester.tap(find.byKey(const ValueKey('profile-save-button')));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('profile-phone-field')), findsOneWidget);
    expect(
      find.text(
        FFLocalizations(const Locale('fr')).getText('profile_save_error'),
      ),
      findsOneWidget,
    );
  });

  for (final locale in const [Locale('fr'), Locale('en'), Locale('cr')]) {
    for (final themeMode in const [ThemeMode.dark, ThemeMode.light]) {
      testWidgets(
        'phone editor renders ${locale.languageCode} on mobile in ${themeMode.name} mode',
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
            find.text(
              FFLocalizations(locale).getText('profile_phone_label'),
            ),
            findsNWidgets(2),
          );
          expect(
            find.byKey(const ValueKey('profile-save-button')),
            findsOneWidget,
          );
          expect(tester.takeException(), isNull);
        },
      );
    }
  }

  testWidgets('phone editor stays constrained on web', (tester) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      _app(locale: const Locale('fr'), themeMode: ThemeMode.light),
    );
    await tester.pumpAndSettle();

    expect(
      tester.getSize(find.byKey(const ValueKey('profile-phone-field'))).width,
      lessThanOrEqualTo(560.0),
    );
    expect(tester.takeException(), isNull);
  });
}
