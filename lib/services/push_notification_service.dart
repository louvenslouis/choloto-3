import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'push_registration_lock.dart'
    if (dart.library.js_interop) 'push_registration_lock_web.dart';

enum PushNotificationStatus {
  unsupported,
  initializationFailed,
  synchronizationFailed,
  permissionDenied,
  enabled,
  activationFailed,
  disabled,
  deactivationFailed,
}

/// Resolves only known destinations and rechecks private recipients on tap.
String? webPushRoute(Map<String, dynamic> data,
    {required String? signedInUid}) {
  switch (data['type']) {
    case 'new_prediction':
      return '/vip';
    case 'new_croix':
      return '/croix';
    case 'new_bingo':
      final id = data['bingoId'];
      if (id is! String || id.trim().isEmpty || id.contains('/')) return null;
      return Uri(path: '/home', queryParameters: {'bingoId': id}).toString();
    case 'assistant_reply':
    case 'account_activated':
      if (signedInUid == null ||
          signedInUid.isEmpty ||
          data['recipientUid'] != signedInUid) {
        return null;
      }
      return data['type'] == 'assistant_reply'
          ? '/customerservice'
          : '/upgrade';
    default:
      return null;
  }
}

/// Manages notifications for the Flutter Web application.
///
/// Permission is requested only from [enable], which must be called from a
/// user action. On later visits an already-authorized browser is synchronized
/// automatically without showing another permission prompt.
class PushNotificationService extends ChangeNotifier {
  PushNotificationService._() : _client = http.Client();

  @visibleForTesting
  PushNotificationService.withClient(this._client);

  final http.Client _client;

  static final PushNotificationService instance = PushNotificationService._();

  static const String _optOutKey = 'webPushDisabled';
  static const String _ownerKey = 'webPushOwnerUid';
  static const String _guestLocaleKey = 'webPushGuestLocale';
  static const String _guestConsentKey = 'webPushGuestConsent';
  static const String _confirmedGuestTokenKey = 'webPushConfirmedGuestToken';
  // Public browser key generated for the Firebase project choloto-6aa5b.
  // It is intentionally bundled in the Web client and is not a secret.
  static const String _vapidKey = String.fromEnvironment(
    'CHOLOTO_WEB_PUSH_VAPID_KEY',
    defaultValue:
        'BGuDQSOZ80wL1DkqkIu5UBq0_fuia9ji3RR6HspwG-j0qkgv3Ax9o5hwZr2cWA2KzUljewAgew31DeYM3Mz6IgM',
  );

  StreamSubscription<RemoteMessage>? _foregroundSubscription;
  StreamSubscription<RemoteMessage>? _openedAppSubscription;
  StreamSubscription<String>? _refreshSubscription;
  Future<void>? _initialAuthState;
  DocumentReference<Map<String, dynamic>>? _tokenDocument;
  Future<void> _subscriptionOperation = Future.value();
  final _foregroundEvents = <String>{};
  bool _initialized = false;
  bool _supported = false;
  bool _enabled = false;
  bool _busy = false;
  String _languageCode = 'fr';
  PushNotificationStatus? _status;

  bool get supported => _supported;
  bool get enabled => _enabled;
  bool get busy => _busy;
  PushNotificationStatus? get status => _status;

  String? get _signedInUid => FirebaseAuth.instance.currentUser?.uid;

  String? routeFor(RemoteMessage message) {
    final user = FirebaseAuth.instance.currentUser;
    return webPushRoute(message.data,
        signedInUid: user == null || user.isAnonymous ? null : user.uid);
  }

  // Keep startup, account changes and switch operations ordered in this tab.
  Future<void> _inOrder(Future<void> Function() operation) {
    final next =
        _subscriptionOperation.then((_) => withPushRegistrationLock(operation));
    _subscriptionOperation = next.catchError((Object _) {});
    return next;
  }

  void setLanguageCode(String? languageCode) {
    final normalized =
        const {'fr', 'en', 'cr'}.contains(languageCode) ? languageCode! : 'fr';
    if (_languageCode == normalized) {
      return;
    }
    _languageCode = normalized;
    if (_initialized && _supported) {
      unawaited(syncAuthorizedSubscription());
    }
  }

  Future<void> initialize({
    required void Function(RemoteMessage) onOpen,
    required void Function(RemoteMessage) onForeground,
  }) async {
    if (_initialized || !kIsWeb) {
      return;
    }
    _initialized = true;

    try {
      _supported = await FirebaseMessaging.instance.isSupported();
      if (!_supported) {
        _status = PushNotificationStatus.unsupported;
        notifyListeners();
        return;
      }

      _foregroundSubscription = FirebaseMessaging.onMessage.listen((message) {
        if (routeFor(message) == null) return;
        final eventId = message.data['eventId'];
        if (eventId is String && eventId.isNotEmpty) {
          final key = '${message.data['type']}:$eventId';
          if (!_foregroundEvents.add(key)) return;
          if (_foregroundEvents.length > 128) {
            _foregroundEvents.remove(_foregroundEvents.first);
          }
        }
        onForeground(message);
      });
      _openedAppSubscription =
          FirebaseMessaging.onMessageOpenedApp.listen(onOpen);
      _refreshSubscription = FirebaseMessaging.instance.onTokenRefresh
          .listen((_) => unawaited(syncAuthorizedSubscription()));

      await syncAuthorizedSubscription();

      final initialMessage =
          await FirebaseMessaging.instance.getInitialMessage();
      if (initialMessage != null) {
        onOpen(initialMessage);
      }
    } catch (error) {
      _status = PushNotificationStatus.initializationFailed;
      debugPrint('Web push initialization failed: $error');
      notifyListeners();
    }
  }

  /// Registers the current browser when permission was already granted.
  Future<void> syncAuthorizedSubscription() async {
    if (!kIsWeb || !_initialized || !_supported) {
      return;
    }

    var revokingOptOut = false;
    try {
      await _inOrder(() async {
        // During a cold start, wait for Firebase to restore a member session
        // before interpreting a null currentUser as a visitor.
        await (_initialAuthState ??=
            FirebaseAuth.instance.authStateChanges().first.then<void>((_) {}));
        final prefs = SharedPreferencesAsync();
        final uid = _signedInUid;
        final guestConsent = await prefs.getBool(_guestConsentKey) == true;
        final optedOut = await prefs.getBool(_optOutKey) == true;
        if ((uid != null || guestConsent) && !optedOut) {
          final settings =
              await FirebaseMessaging.instance.getNotificationSettings();
          if (_isAccepted(settings.authorizationStatus)) {
            await _registerCurrentBrowser(uid, prefs);
            return;
          }
        }
        final hadOwner = await prefs.getString(_ownerKey) != null;
        revokingOptOut = optedOut &&
            (hadOwner || await prefs.getString(_guestLocaleKey) != null);
        if (revokingOptOut || uid == null && hadOwner) {
          await _revokeAddress(prefs);
        }
        _tokenDocument = null;
        _enabled = false;
        _status = null;
        notifyListeners();
      });
    } catch (error) {
      _enabled = revokingOptOut;
      _status = revokingOptOut
          ? PushNotificationStatus.deactivationFailed
          : PushNotificationStatus.synchronizationFailed;
      debugPrint('Web push synchronization failed: $error');
      notifyListeners();
    }
  }

  /// Visitors explicitly opt in to BINGO. Members receive the account feed.
  Future<bool> enable() async {
    if (!kIsWeb || !_supported || _busy) {
      return false;
    }

    _setBusy(true);
    try {
      final settings = await FirebaseMessaging.instance.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
      if (!_isAccepted(settings.authorizationStatus)) {
        _enabled = false;
        _status = PushNotificationStatus.permissionDenied;
        return false;
      }

      await _inOrder(() async {
        final prefs = SharedPreferencesAsync();
        final uid = _signedInUid;
        if (uid == null) await prefs.setBool(_guestConsentKey, true);
        await prefs.setBool(_optOutKey, false);
        await _registerCurrentBrowser(uid, prefs);
      });
      _status = PushNotificationStatus.enabled;
      return true;
    } catch (error) {
      _enabled = false;
      _status = PushNotificationStatus.activationFailed;
      debugPrint('Web push activation failed: $error');
      return false;
    } finally {
      _setBusy(false);
    }
  }

  /// Stops FCM delivery for this browser. Browser permission remains under the
  /// user's control and can still be revoked in the browser settings.
  Future<bool> disable() async {
    if (!kIsWeb || _busy) {
      return false;
    }

    _setBusy(true);
    try {
      await _inOrder(() async {
        final prefs = SharedPreferencesAsync();
        await prefs.setBool(_optOutKey, true);
        await prefs.remove(_guestConsentKey);
        try {
          if (_tokenDocument?.parent.parent?.id == _signedInUid) {
            await _tokenDocument?.delete();
          }
        } finally {
          await _revokeAddress(prefs);
        }
        _tokenDocument = null;
        _enabled = false;
      });
      _status = PushNotificationStatus.disabled;
      return true;
    } catch (error) {
      _status = PushNotificationStatus.deactivationFailed;
      debugPrint('Web push deactivation failed: $error');
      return false;
    } finally {
      _setBusy(false);
    }
  }

  Future<void> _registerCurrentBrowser(
      String? uid, SharedPreferencesAsync prefs) async {
    final locale = _languageCode;
    final previousOwner = await prefs.getString(_ownerKey);
    final guestLocale = await prefs.getString(_guestLocaleKey);
    if (previousOwner != uid || (uid == null && guestLocale != locale)) {
      // Unmarked tokens may belong to an older member client. Never reuse
      // them for a guest topic or reuse a guest token for a different locale.
      await _revokeAddress(prefs);
    }
    final token = await FirebaseMessaging.instance.getToken(
      vapidKey: _vapidKey,
    );
    if (token == null || token.isEmpty) {
      throw StateError('Firebase did not return a web push token.');
    }

    if (_signedInUid != uid) {
      throw StateError('The account changed during push registration.');
    }
    if (uid == null) {
      // Mark the audience before sending: a lost response can still mean
      // that the server subscribed this token.
      await prefs.setString(_guestLocaleKey, locale);
      if (await prefs.getString(_confirmedGuestTokenKey) != token) {
        final project = Firebase.app().options.projectId;
        final response = await _client
            .post(
              Uri.https('northamerica-northeast1-$project.cloudfunctions.net',
                  '/registerGuestBingoPush'),
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode({
                'data': {'token': token, 'locale': locale}
              }),
            )
            .timeout(const Duration(seconds: 20));
        if (response.statusCode != 200 ||
            jsonDecode(response.body)?['result']?['registered'] != true) {
          throw StateError('Guest BINGO registration was not confirmed.');
        }
        await prefs.setString(_confirmedGuestTokenKey, token);
      }
    } else {
      await prefs.setString(_ownerKey, uid);
      final tokenId = base64Url.encode(utf8.encode(token)).replaceAll('=', '');
      final document = FirebaseFirestore.instance
          .collection('user')
          .doc(uid)
          .collection('webPushTokens')
          .doc(tokenId);
      await document.set({
        'token': token,
        'userId': uid,
        'locale': locale,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      _tokenDocument = document;
    }
    _enabled = _signedInUid == uid;
    _status = null;
    notifyListeners();
  }

  Future<void> _revokeAddress(SharedPreferencesAsync prefs) async {
    await FirebaseMessaging.instance.deleteToken();
    await prefs.remove(_confirmedGuestTokenKey);
    await prefs.remove(_ownerKey);
    await prefs.remove(_guestLocaleKey);
    _tokenDocument = null;
  }

  bool _isAccepted(AuthorizationStatus status) =>
      status == AuthorizationStatus.authorized ||
      status == AuthorizationStatus.provisional;

  void _setBusy(bool value) {
    _busy = value;
    notifyListeners();
  }

  @override
  void dispose() {
    unawaited(_foregroundSubscription?.cancel());
    unawaited(_openedAppSubscription?.cancel());
    unawaited(_refreshSubscription?.cancel());
    _client.close();
    super.dispose();
  }
}
