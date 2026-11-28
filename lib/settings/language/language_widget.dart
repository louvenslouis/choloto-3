import 'package:flutter/material.dart';

import '/flutter_flow/flutter_flow_util.dart';
import '/settings/parametres/settings_choice_sheet.dart';
export 'language_model.dart';

class LanguageWidget extends StatelessWidget {
  const LanguageWidget({super.key});

  static const names = {
    'fr': 'settings_language_fr',
    'en': 'settings_language_en',
    'cr': 'settings_language_cr',
  };

  @override
  Widget build(BuildContext context) {
    final strings = FFLocalizations.of(context);
    return SettingsChoiceSheet<String>(
      title: strings.getText('9w72tojm'),
      selected: strings.languageCode,
      options: names.map((code, key) => MapEntry(code, strings.getText(key))),
      onSelected: (code) {
        setAppLanguage(context, code);
        Navigator.pop(context);
      },
    );
  }
}
