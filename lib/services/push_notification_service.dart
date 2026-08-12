import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Configures push notifications announcing newly published predictions.
///
/// The topic payload intentionally contains no prediction numbers so VIP
/// content is never exposed on a locked device. Firestore remains responsible
/// for checking access when the user opens the VIP page.
class PushNotificationService {
  PushNotificationService._();

  static final PushNotificationService instance = PushNotificationService._();

  static const String predictionTopic = 'new_predictions';
  static const String _predictionType = 'new_prediction';
  static const String _localPayload = 'open_vip_prediction';
  static const AndroidNotificationChannel _androidChannel =
      AndroidNotificationChannel(
    'choloto_predictions',
    'Nouvelles prédictions',
    description: 'Alertes lors de la publication de nouvelles prédictions.',
    importance: Importance.high,
  );

  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  StreamSubscription<RemoteMessage>? _foregroundSubscription;
  StreamSubscription<RemoteMessage>? _openedAppSubscription;
  StreamSubscription<String>? _tokenRefreshSubscription;
  void Function()? _onOpenPrediction;
  bool _initialized = false;

  Future<void> initialize({required void Function() onOpenPrediction}) async {
    _onOpenPrediction = onOpenPrediction;

    if (_initialized || kIsWeb || !_isSupportedMobilePlatform) {
      return;
    }
    _initialized = true;

    if (defaultTargetPlatform == TargetPlatform.android) {
      await _initializeAndroidNotifications();
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      await FirebaseMessaging.instance
          .setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
    }

    _foregroundSubscription =
        FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    _openedAppSubscription =
        FirebaseMessaging.onMessageOpenedApp.listen(_handleRemoteOpen);

    await _requestPermissionAndSubscribe();

    final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      _handleRemoteOpen(initialMessage);
    }
  }

  bool get _isSupportedMobilePlatform =>
      defaultTargetPlatform == TargetPlatform.android ||
      defaultTargetPlatform == TargetPlatform.iOS;

  Future<void> _initializeAndroidNotifications() async {
    const initializationSettings = InitializationSettings(
      android: AndroidInitializationSettings('ic_stat_prediction'),
    );

    await _localNotifications.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: (response) {
        if (response.payload == _localPayload) {
          _onOpenPrediction?.call();
        }
      },
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_androidChannel);
  }

  Future<void> _requestPermissionAndSubscribe() async {
    try {
      final settings = await FirebaseMessaging.instance.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
      final accepted =
          settings.authorizationStatus == AuthorizationStatus.authorized ||
              settings.authorizationStatus == AuthorizationStatus.provisional;
      if (accepted) {
        _tokenRefreshSubscription ??=
            FirebaseMessaging.instance.onTokenRefresh.listen((_) {
          unawaited(_subscribeToPredictionTopic());
        });
        await _subscribeToPredictionTopic();
      }
    } catch (error) {
      debugPrint('Push notification registration failed: $error');
    }
  }

  Future<void> _subscribeToPredictionTopic() async {
    try {
      if (defaultTargetPlatform == TargetPlatform.iOS &&
          !await _waitForApplePushToken()) {
        debugPrint('Push registration deferred: APNs token is not ready.');
        return;
      }
      await FirebaseMessaging.instance.subscribeToTopic(predictionTopic);
    } catch (error) {
      debugPrint('Prediction topic subscription failed: $error');
    }
  }

  Future<bool> _waitForApplePushToken() async {
    for (var attempt = 0; attempt < 10; attempt++) {
      if (await FirebaseMessaging.instance.getAPNSToken() != null) {
        return true;
      }
      await Future<void>.delayed(const Duration(milliseconds: 500));
    }
    return false;
  }

  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    if (message.data['type'] != _predictionType ||
        defaultTargetPlatform != TargetPlatform.android) {
      return;
    }

    final remoteNotification = message.notification;
    await _localNotifications.show(
      id: message.messageId?.hashCode ??
          DateTime.now().millisecondsSinceEpoch.remainder(1 << 31),
      title: remoteNotification?.title ?? 'Nouvelle prédiction disponible',
      body: remoteNotification?.body ??
          'Touchez pour consulter la nouvelle prédiction VIP.',
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'choloto_predictions',
          'Nouvelles prédictions',
          channelDescription:
              'Alertes lors de la publication de nouvelles prédictions.',
          importance: Importance.high,
          priority: Priority.high,
          icon: 'ic_stat_prediction',
        ),
      ),
      payload: _localPayload,
    );
  }

  void _handleRemoteOpen(RemoteMessage message) {
    if (message.data['type'] == _predictionType) {
      _onOpenPrediction?.call();
    }
  }

  Future<void> dispose() async {
    await _foregroundSubscription?.cancel();
    await _openedAppSubscription?.cancel();
    await _tokenRefreshSubscription?.cancel();
    _foregroundSubscription = null;
    _openedAppSubscription = null;
    _tokenRefreshSubscription = null;
    _initialized = false;
  }
}
