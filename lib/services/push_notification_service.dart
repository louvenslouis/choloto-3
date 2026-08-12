import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

enum PushNotificationStatus {
  unsupported,
  initializationFailed,
  synchronizationFailed,
  signInRequired,
  permissionDenied,
  enabled,
  activationFailed,
  disabled,
  deactivationFailed,
}

/// Manages prediction notifications for the Flutter Web application only.
///
/// Permission is requested only from [enable], which must be called from a
/// user action. On later visits an already-authorized browser is synchronized
/// automatically without showing another permission prompt.
class PushNotificationService extends ChangeNotifier {
  PushNotificationService._();

  static final PushNotificationService instance = PushNotificationService._();

  static const String _predictionType = 'new_prediction';
  // Public browser key generated for the Firebase project choloto-6aa5b.
  // It is intentionally bundled in the Web client and is not a secret.
  static const String _vapidKey = String.fromEnvironment(
    'CHOLOTO_WEB_PUSH_VAPID_KEY',
    defaultValue:
        'BGuDQSOZ80wL1DkqkIu5UBq0_fuia9ji3RR6HspwG-j0qkgv3Ax9o5hwZr2cWA2KzUljewAgew31DeYM3Mz6IgM',
  );

  StreamSubscription<RemoteMessage>? _foregroundSubscription;
  StreamSubscription<RemoteMessage>? _openedAppSubscription;
  DocumentReference<Map<String, dynamic>>? _tokenDocument;
  void Function()? _onOpenPrediction;
  void Function(String title, String body)? _onForegroundPrediction;
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

  void setLanguageCode(String? languageCode) {
    final normalized =
        const {'fr', 'en', 'cr'}.contains(languageCode) ? languageCode! : 'fr';
    if (_languageCode == normalized) {
      return;
    }
    _languageCode = normalized;
    if (_tokenDocument != null) {
      unawaited(_updateRegisteredLanguage());
    }
  }

  Future<void> initialize({
    required void Function() onOpenPrediction,
    required void Function(String title, String body) onForegroundPrediction,
  }) async {
    _onOpenPrediction = onOpenPrediction;
    _onForegroundPrediction = onForegroundPrediction;

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

      _foregroundSubscription =
          FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
      _openedAppSubscription =
          FirebaseMessaging.onMessageOpenedApp.listen(_handleRemoteOpen);

      await syncAuthorizedSubscription();

      final initialMessage =
          await FirebaseMessaging.instance.getInitialMessage();
      if (initialMessage != null) {
        _handleRemoteOpen(initialMessage);
      }
    } catch (error) {
      _status = PushNotificationStatus.initializationFailed;
      debugPrint('Web push initialization failed: $error');
      notifyListeners();
    }
  }

  /// Registers the current browser when permission was already granted.
  Future<void> syncAuthorizedSubscription() async {
    if (!kIsWeb || !_initialized || !_supported || _busy) {
      return;
    }

    try {
      final settings =
          await FirebaseMessaging.instance.getNotificationSettings();
      if (_isAccepted(settings.authorizationStatus) &&
          FirebaseAuth.instance.currentUser != null) {
        await _registerCurrentBrowser();
      }
    } catch (error) {
      _status = PushNotificationStatus.synchronizationFailed;
      debugPrint('Web push synchronization failed: $error');
      notifyListeners();
    }
  }

  /// Requests browser permission and subscribes this signed-in browser.
  Future<bool> enable() async {
    if (!kIsWeb || !_supported || _busy) {
      return false;
    }

    _setBusy(true);
    try {
      if (FirebaseAuth.instance.currentUser == null) {
        _status = PushNotificationStatus.signInRequired;
        return false;
      }

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

      await _registerCurrentBrowser();
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
      await _tokenDocument?.delete();
      await FirebaseMessaging.instance.deleteToken();
      _tokenDocument = null;
      _enabled = false;
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

  Future<void> _registerCurrentBrowser() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return;
    }

    final token = await FirebaseMessaging.instance.getToken(
      vapidKey: _vapidKey,
    );
    if (token == null || token.isEmpty) {
      throw StateError('Firebase did not return a web push token.');
    }

    final tokenId = base64Url.encode(utf8.encode(token)).replaceAll('=', '');
    _tokenDocument = FirebaseFirestore.instance
        .collection('user')
        .doc(user.uid)
        .collection('webPushTokens')
        .doc(tokenId);

    await _tokenDocument!.set({
      'token': token,
      'userId': user.uid,
      'locale': _languageCode,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    _enabled = true;
    _status = null;
    notifyListeners();
  }

  Future<void> _updateRegisteredLanguage() async {
    try {
      await _tokenDocument?.update({
        'locale': _languageCode,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (error) {
      debugPrint('Web push locale synchronization failed: $error');
    }
  }

  bool _isAccepted(AuthorizationStatus status) =>
      status == AuthorizationStatus.authorized ||
      status == AuthorizationStatus.provisional;

  void _handleForegroundMessage(RemoteMessage message) {
    if (message.data['type'] != _predictionType) {
      return;
    }
    _onForegroundPrediction?.call(
      message.data['title'] ?? '',
      message.data['body'] ?? '',
    );
  }

  void _handleRemoteOpen(RemoteMessage message) {
    if (message.data['type'] == _predictionType) {
      _onOpenPrediction?.call();
    }
  }

  void _setBusy(bool value) {
    _busy = value;
    notifyListeners();
  }

  @override
  void dispose() {
    unawaited(_foregroundSubscription?.cancel());
    unawaited(_openedAppSubscription?.cancel());
    super.dispose();
  }
}
