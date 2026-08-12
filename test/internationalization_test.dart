import 'package:choloto/flutter_flow/internationalization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('every translation has non-empty French, English, and Creole text', () {
    expect(kTranslationsMap, isNotEmpty);

    for (final entry in kTranslationsMap.entries) {
      for (final language in FFLocalizations.languages()) {
        expect(
          entry.value[language]?.trim(),
          isNotEmpty,
          reason: 'Missing $language translation for ${entry.key}',
        );
      }
    }
  });

  test('runtime lookup returns the requested language', () {
    expect(
        FFLocalizations(const Locale('fr')).getText('oadu0jrq'), 'Paramètres');
    expect(FFLocalizations(const Locale('en')).getText('oadu0jrq'), 'Settings');
    expect(FFLocalizations(const Locale('cr')).getText('oadu0jrq'), 'Paramèt');
  });

  test('unknown keys remain visible for diagnosis instead of becoming blank',
      () {
    expect(
      FFLocalizations(const Locale('en')).getText('missing-key'),
      'missing-key',
    );
  });
}
