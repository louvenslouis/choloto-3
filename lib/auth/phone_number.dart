const phoneAuthButtonAnalyticsEvent = 'WELCOME_PHONE_AUTH_BTN_ON_TAP';

String? normalizePhoneNumber(String input) {
  var normalized = input.trim().replaceAll(RegExp(r'[\s().-]'), '');

  if (normalized.startsWith('00')) {
    normalized = '+${normalized.substring(2)}';
  } else if (RegExp(r'^\d{8}$').hasMatch(normalized)) {
    normalized = '+509$normalized';
  } else if (RegExp(r'^509\d{8}$').hasMatch(normalized)) {
    normalized = '+$normalized';
  }

  return RegExp(r'^\+[1-9]\d{7,14}$').hasMatch(normalized) ? normalized : null;
}
