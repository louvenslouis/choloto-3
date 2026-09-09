import '/backend/backend.dart'
    show isValidRegistrationPhoneNumber, normalizeRegistrationPhoneNumber;

enum SupportAccessState { signedOut, phoneRequired, ready }

bool hasRequiredSupportPhone(Object? value) {
  if (value is! String) {
    return false;
  }
  final normalized = normalizeRegistrationPhoneNumber(value);
  return normalized.isNotEmpty && isValidRegistrationPhoneNumber(normalized);
}

SupportAccessState resolveSupportAccess({
  required bool hasAuthenticatedSession,
  required String userUid,
  required Object? profilePhoneNumber,
}) {
  if (!hasAuthenticatedSession || userUid.isEmpty) {
    return SupportAccessState.signedOut;
  }
  if (!hasRequiredSupportPhone(profilePhoneNumber)) {
    return SupportAccessState.phoneRequired;
  }
  return SupportAccessState.ready;
}
