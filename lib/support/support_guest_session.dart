import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class GuestSupportSession {
  GuestSupportSession._();

  static const _storageKey = 'support_guest_conversation_id';
  static const _uuid = Uuid();

  static bool isValidId(String value) => RegExp(
        r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
      ).hasMatch(value);

  static Future<String> loadOrCreateId() async {
    try {
      final preferences = await SharedPreferences.getInstance();
      final existing = preferences.getString(_storageKey);
      if (existing != null && isValidId(existing)) {
        return existing;
      }
      final created = _uuid.v4();
      await preferences.setString(_storageKey, created);
      return created;
    } catch (_) {
      // Private browsing can block local storage. The chat still works for the
      // current page, but the conversation cannot be restored after closing it.
      return _uuid.v4();
    }
  }
}
