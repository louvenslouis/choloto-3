import 'package:choloto/auth/firebase_auth/sign_in_profile.dart';
import 'package:choloto/auth/phone_number.dart';
import 'package:choloto/flutter_flow/internationalization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _Credential {
  const _Credential(this.userId);

  final String? userId;
}

void main() {
  group('phone number normalization', () {
    test('adds Haiti country code to local numbers', () {
      expect(normalizePhoneNumber('37 00 00 00'), '+50937000000');
      expect(normalizePhoneNumber('509-37-00-00-00'), '+50937000000');
    });

    test('keeps valid international numbers', () {
      expect(normalizePhoneNumber('+1 (305) 555-0123'), '+13055550123');
      expect(normalizePhoneNumber('00 33 6 12 34 56 78'), '+33612345678');
    });

    test('rejects incomplete or malformed numbers', () {
      expect(normalizePhoneNumber('1234'), isNull);
      expect(normalizePhoneNumber('+050937000000'), isNull);
      expect(normalizePhoneNumber('not-a-number'), isNull);
    });
  });

  test('phone authentication analytics event respects Firebase limits', () {
    expect(phoneAuthButtonAnalyticsEvent.length, lessThanOrEqualTo(40));
  });

  test('authentication completes the canonical profile before returning',
      () async {
    final operations = <String>[];
    const credential = _Credential('phone-user-uid');

    final result = await signInAndEnsureUserProfile<_Credential, String>(
      authenticate: () async {
        operations.add('authenticate');
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
      ['authenticate', 'ensure:/user/phone-user-uid'],
    );
  });

  test('phone authentication text is available in all supported languages', () {
    const keys = [
      'phone_continue',
      'phone_sign_in_title',
      'phone_number_description',
      'phone_number_label',
      'phone_send_code',
      'phone_code_description',
      'phone_code_label',
      'phone_verify_code',
      'phone_change_number',
      'phone_resend_code',
      'phone_invalid_number',
      'phone_invalid_code',
      'phone_close',
      'phone_sms_notice',
    ];

    for (final language in FFLocalizations.languages()) {
      final localizations = FFLocalizations(Locale(language));
      for (final key in keys) {
        expect(localizations.getText(key).trim(), isNotEmpty);
      }
    }
  });
}
