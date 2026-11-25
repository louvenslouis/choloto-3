@TestOn('browser')
library;

import 'dart:async';
import 'dart:convert';

import 'package:choloto/services/push_notification_service.dart';
import 'package:cloud_firestore_platform_interface/cloud_firestore_platform_interface.dart';
import 'package:firebase_auth_platform_interface/firebase_auth_platform_interface.dart';
import 'package:firebase_core/firebase_core.dart';
// ignore: depend_on_referenced_packages
import 'package:firebase_core_platform_interface/firebase_core_platform_interface.dart';
// ignore: depend_on_referenced_packages
import 'package:firebase_messaging_platform_interface/firebase_messaging_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:shared_preferences/shared_preferences.dart';
// ignore: depend_on_referenced_packages
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
// ignore: depend_on_referenced_packages
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

class _Core extends FirebasePlatform {
  @override
  FirebaseAppPlatform app([String name = '[DEFAULT]']) => FirebaseAppPlatform(
      name,
      const FirebaseOptions(
        apiKey: 'demo',
        appId: 'demo',
        messagingSenderId: 'demo',
        projectId: 'demo-choloto',
      ));
}

class _User extends Fake
    with MockPlatformInterfaceMixin
    implements UserPlatform {
  _User(this.uid);
  @override
  final String uid;
  @override
  bool get isAnonymous => false;
}

class _Auth extends FirebaseAuthPlatform {
  @override
  UserPlatform? currentUser;
  @override
  Stream<UserPlatform?> authStateChanges() => Stream.value(currentUser);
  @override
  FirebaseAuthPlatform delegateFor({required FirebaseApp app}) => this;
  @override
  FirebaseAuthPlatform setInitialValues(
          {PigeonUserDetails? currentUser, String? languageCode}) =>
      this;
}

class _Settings extends Fake implements NotificationSettings {
  @override
  final AuthorizationStatus authorizationStatus;
  _Settings(this.authorizationStatus);
}

class _MemberStore extends FirebaseFirestorePlatform {
  final writes = <String, Map<String, dynamic>>{};
  @override
  FirebaseFirestorePlatform delegateFor(
          {required FirebaseApp app, required String databaseId}) =>
      this;
  @override
  CollectionReferencePlatform collection(String path) =>
      _Collection(this, path);
  @override
  DocumentReferencePlatform doc(String path) => _Document(this, path);
}

class _Collection extends CollectionReferencePlatform {
  _Collection(super.firestore, super.path);
  @override
  DocumentReferencePlatform doc([String? id]) => firestore.doc('$path/$id');
}

class _Document extends DocumentReferencePlatform {
  _Document(super.firestore, super.path);
  @override
  Future<void> set(Map<String, dynamic> data, [SetOptions? options]) async {
    (firestore as _MemberStore).writes[path] = data;
  }
}

class _Timestamps extends FieldValueFactoryPlatform {
  @override
  Object serverTimestamp() => 'server-timestamp';
}

class _Messaging extends FirebaseMessagingPlatform {
  int settingsReads = 0;
  int revocations = 0;
  int generation = 0;
  int requests = 0;
  int tokenReads = 0;
  bool failDeleteOnce = false;
  AuthorizationStatus permission = AuthorizationStatus.denied;
  final refreshes = StreamController<String>.broadcast();
  @override
  Stream<String> get onTokenRefresh => refreshes.stream;
  @override
  Future<String?> getToken({String? vapidKey}) async {
    tokenReads++;
    return 'browser-$generation';
  }

  @override
  Future<NotificationSettings> requestPermission(
      {bool alert = true,
      bool announcement = false,
      bool badge = true,
      bool carPlay = false,
      bool criticalAlert = false,
      bool provisional = false,
      bool sound = true,
      bool providesAppNotificationSettings = false}) async {
    requests++;
    return _Settings(permission);
  }

  @override
  FirebaseMessagingPlatform delegateFor({required FirebaseApp app}) => this;
  @override
  FirebaseMessagingPlatform setInitialValues({bool? isAutoInitEnabled}) => this;
  @override
  Future<bool> isSupported() async => true;
  @override
  Future<RemoteMessage?> getInitialMessage() async => null;
  @override
  Future<void> deleteToken() async {
    if (failDeleteOnce) {
      failDeleteOnce = false;
      throw StateError('test offline');
    }
    revocations++;
    generation++;
  }

  @override
  Future<NotificationSettings> getNotificationSettings() async {
    settingsReads++;
    return _Settings(permission);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final auth = _Auth();
  final messaging = _Messaging();
  final store = _MemberStore();
  final requests = <Map<String, dynamic>>[];
  late PushNotificationService service;
  var acknowledge = true;
  PushNotificationService newService() =>
      PushNotificationService.withClient(MockClient((request) async {
        expect(request.url.toString(),
            'https://northamerica-northeast1-demo-choloto.cloudfunctions.net/registerGuestBingoPush');
        expect(request.method, 'POST');
        expect(request.headers['Content-Type'], startsWith('application/json'));
        requests.add(jsonDecode(request.body)['data'] as Map<String, dynamic>);
        return http.Response(
            jsonEncode({
              'result': {'registered': acknowledge}
            }),
            200);
      }));
  setUpAll(() {
    FirebasePlatform.instance = _Core();
    FirebaseFirestorePlatform.instance = store;
    FieldValueFactoryPlatform.instance = _Timestamps();
    FirebaseAuthPlatform.instance = auth;
    FirebaseMessagingPlatform.instance = messaging;
  });
  setUp(() {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
    auth.currentUser = null;
    messaging
      ..permission = AuthorizationStatus.denied
      ..settingsReads = 0
      ..revocations = 0
      ..requests = 0
      ..generation = 0
      ..tokenReads = 0;
    store.writes.clear();
    requests.clear();
    acknowledge = true;
    service = newService();
  });
  tearDown(() => service.dispose());
  test(
      'disabling survives sign-out and a different account in the same browser',
      () async {
    auth.currentUser = _User('first');
    final prefs = SharedPreferencesAsync();
    await prefs.remove('webPushDisabled');
    final shown = <RemoteMessage>[];
    await service.initialize(onOpen: (_) {}, onForeground: shown.add);
    expect(messaging.settingsReads, 1);
    const message =
        RemoteMessage(data: {'type': 'new_croix', 'eventId': 'one'});
    FirebaseMessagingPlatform.onMessage.add(message);
    FirebaseMessagingPlatform.onMessage.add(message);
    await Future<void>.delayed(Duration.zero);
    expect(shown, [message]);
    expect(await service.disable(), isTrue);
    expect(messaging.revocations, 1);
    expect(await SharedPreferencesAsync().getBool('webPushDisabled'), isTrue);
    for (final user in [null, _User('second'), _User('first')]) {
      auth.currentUser = user;
      await service.syncAuthorizedSubscription();
      expect(service.enabled, isFalse);
      expect(messaging.settingsReads, 1);
    }
    await prefs.remove('webPushDisabled');
    await service.syncAuthorizedSubscription();
    expect(messaging.settingsReads, 2);
  });

  test(
      'guest consent, restart, refresh, language change and opt-out follow one browser token',
      () async {
    messaging.permission = AuthorizationStatus.authorized;
    await service.initialize(onOpen: (_) {}, onForeground: (_) {});
    expect(requests, isEmpty);
    expect(messaging.tokenReads, 0);
    expect(await service.enable(), isTrue);
    expect(auth.currentUser, isNull);
    // The unmarked token may have belonged to a member running the old app.
    expect(messaging.revocations, 1);
    expect(requests, [
      {'token': 'browser-1', 'locale': 'fr'}
    ]);
    expect(messaging.requests, 1);
    service.dispose();
    service = newService();
    await service.initialize(onOpen: (_) {}, onForeground: (_) {});
    expect(service.enabled, isTrue);
    expect(requests, hasLength(1));
    messaging.generation++;
    messaging.refreshes.add('browser-2');
    await Future<void>.delayed(Duration.zero);
    await service.syncAuthorizedSubscription();
    expect(requests, hasLength(2));
    expect(requests.last, {'token': 'browser-2', 'locale': 'fr'});
    service.setLanguageCode('cr');
    await service.syncAuthorizedSubscription();
    expect(requests, hasLength(3));
    expect(requests.last, {'token': 'browser-3', 'locale': 'cr'});
    expect(messaging.revocations, 2);
    expect(await service.disable(), isTrue);
    expect(messaging.revocations, 3);
    service.dispose();
    service = newService();
    await service.initialize(onOpen: (_) {}, onForeground: (_) {});
    expect(service.enabled, isFalse);
    expect(requests, hasLength(3));
    expect(messaging.requests, 1);
  });

  test(
      'denied permission never registers and an unacknowledged guest registration retries',
      () async {
    await service.initialize(onOpen: (_) {}, onForeground: (_) {});
    expect(await service.enable(), isFalse);
    expect(service.status, PushNotificationStatus.permissionDenied);
    expect(requests, isEmpty);
    messaging.permission = AuthorizationStatus.authorized;
    acknowledge = false;
    expect(await service.enable(), isFalse);
    expect(service.enabled, isFalse);
    expect(service.status, PushNotificationStatus.activationFailed);
    expect(requests, hasLength(1));
    acknowledge = true;
    await service.syncAuthorizedSubscription();
    expect(service.enabled, isTrue);
    expect(requests, [requests.first, requests.first]);
    auth.currentUser = _User('member');
    await service.syncAuthorizedSubscription();
    expect(messaging.revocations, 2);
    expect(service.enabled, isTrue);
    expect(store.writes.keys.single, startsWith('user/member/webPushTokens/'));
    expect(store.writes.values.single['token'], 'browser-2');
    expect(requests, hasLength(2));
    auth.currentUser = null;
    await service.syncAuthorizedSubscription();
    expect(messaging.revocations, 3);
    expect(requests.last, {'token': 'browser-3', 'locale': 'fr'});
  });

  test('guest opt-out retries an offline revocation after restarting',
      () async {
    messaging.permission = AuthorizationStatus.authorized;
    await service.initialize(onOpen: (_) {}, onForeground: (_) {});
    expect(await service.enable(), isTrue);
    messaging.failDeleteOnce = true;
    expect(await service.disable(), isFalse);
    expect(service.enabled, isTrue);
    expect(service.status, PushNotificationStatus.deactivationFailed);
    service.dispose();
    service = newService();
    await service.initialize(onOpen: (_) {}, onForeground: (_) {});
    expect(service.enabled, isFalse);
    expect(messaging.revocations, 2);
    expect(requests, hasLength(1));
    await service.syncAuthorizedSubscription();
    expect(messaging.revocations, 2);
    expect(requests, hasLength(1));
  });

  test('simultaneous guest registrations in one browser subscribe once',
      () async {
    messaging.permission = AuthorizationStatus.authorized;
    final second = newService();
    addTearDown(second.dispose);
    await Future.wait([
      service.initialize(onOpen: (_) {}, onForeground: (_) {}),
      second.initialize(onOpen: (_) {}, onForeground: (_) {}),
    ]);
    expect(await Future.wait([service.enable(), second.enable()]), [true, true]);
    expect(messaging.revocations, 1);
    expect(requests, [
      {'token': 'browser-1', 'locale': 'fr'}
    ]);
  });
}
