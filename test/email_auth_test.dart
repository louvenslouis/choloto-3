import 'package:choloto/auth/email_address.dart';
import 'package:choloto/auth/firebase_auth/sign_in_profile.dart';
import 'package:choloto/components/email_auth_sheet.dart';
import 'package:choloto/flutter_flow/internationalization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

class _Credential {
  const _Credential(this.userId);

  final String? userId;
}

Widget _app({
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
    home: Scaffold(
      body: EmailAuthSheet(
        onSignIn: (email, password) async => null,
        onCreateAccount: (email, password) async => null,
        onResetPassword: (_) async {},
      ),
    ),
  );
}

void main() {
  group('email address validation', () {
    test('trims valid email addresses', () {
      expect(normalizeEmailAddress('  membre@choloto.app  '),
          'membre@choloto.app');
      expect(normalizeEmailAddress('personne+vip@example.co'),
          'personne+vip@example.co');
    });

    test('rejects malformed email addresses', () {
      expect(normalizeEmailAddress('membre'), isNull);
      expect(normalizeEmailAddress('membre@choloto'), isNull);
      expect(normalizeEmailAddress('membre @choloto.app'), isNull);
      expect(normalizeEmailAddress(''), isNull);
    });
  });

  test('email authentication analytics event respects Firebase limits', () {
    expect(emailAuthButtonAnalyticsEvent.length, lessThanOrEqualTo(40));
  });

  test('email authentication completes the canonical profile before returning',
      () async {
    final operations = <String>[];
    const credential = _Credential('email-user-uid');

    final result = await signInAndEnsureUserProfile<_Credential, String>(
      authenticate: () async {
        operations.add('authenticate:email');
        return credential;
      },
      userFromCredential: (value) => value.userId,
      ensureUserProfile: (uid) async {
        operations.add('ensure:/user/$uid');
      },
    );

    expect(result, same(credential));
    expect(
      operations,
      ['authenticate:email', 'ensure:/user/email-user-uid'],
    );
  });

  test('email authentication text is available in all supported languages', () {
    const keys = [
      'email_continue',
      'email_sign_in_title',
      'email_sign_in_description',
      'email_create_title',
      'email_create_description',
      'email_label',
      'email_password_label',
      'email_confirm_password_label',
      'email_sign_in',
      'email_create_account',
      'email_create_mode',
      'email_sign_in_mode',
      'email_forgot_password',
      'email_invalid',
      'email_password_too_short',
      'email_password_mismatch',
      'email_show_password',
      'email_hide_password',
      'email_loading',
      'email_close',
    ];

    for (final language in FFLocalizations.languages()) {
      final localizations = FFLocalizations(Locale(language));
      for (final key in keys) {
        expect(localizations.getText(key).trim(), isNotEmpty);
      }
    }
  });

  for (final locale in const [Locale('fr'), Locale('en'), Locale('cr')]) {
    for (final themeMode in const [ThemeMode.dark, ThemeMode.light]) {
      testWidgets(
        'email sheet renders ${locale.languageCode} in ${themeMode.name} mode',
        (tester) async {
          tester.view.physicalSize = const Size(390, 844);
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);

          await tester.pumpWidget(_app(locale: locale, themeMode: themeMode));
          await tester.pumpAndSettle();

          expect(find.byKey(const ValueKey('email-field')), findsOneWidget);
          expect(
            find.byKey(const ValueKey('email-password-field')),
            findsOneWidget,
          );
          expect(
            find.byKey(const ValueKey('email-confirm-password-field')),
            findsOneWidget,
          );
          expect(tester.takeException(), isNull);
        },
      );
    }
  }

  testWidgets('mode selector switches simply between creation and sign-in',
      (tester) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      _app(locale: const Locale('fr'), themeMode: ThemeMode.dark),
    );
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('email-confirm-password-field')),
      findsOneWidget,
    );
    await tester.tap(find.byKey(const ValueKey('email-sign-in-mode')));
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('email-confirm-password-field')),
      findsNothing,
    );
    expect(
      find.byKey(const ValueKey('email-reset-password-button')),
      findsOneWidget,
    );

    await tester.tap(find.byKey(const ValueKey('email-create-mode')));
    await tester.pumpAndSettle();
    expect(
      find.byKey(const ValueKey('email-confirm-password-field')),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });
}
