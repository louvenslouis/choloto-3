const emailAuthButtonAnalyticsEvent = 'WELCOME_EMAIL_AUTH_BTN_ON_TAP';

final _emailPattern = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');

String? normalizeEmailAddress(String input) {
  final email = input.trim();
  return _emailPattern.hasMatch(email) ? email : null;
}
