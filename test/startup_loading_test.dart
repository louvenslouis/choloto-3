import 'package:choloto/auth/base_auth_user_provider.dart';
import 'package:choloto/flutter_flow/nav/nav.dart';
import 'package:flutter_test/flutter_test.dart';

class _TestAuthUser extends BaseAuthUser {
  _TestAuthUser({
    required this.loggedIn,
    this.isAnonymous = false,
    String? uid,
  }) : _authUserInfo = AuthUserInfo(uid: uid);

  @override
  final bool loggedIn;

  @override
  final bool isAnonymous;

  final AuthUserInfo _authUserInfo;

  @override
  AuthUserInfo get authUserInfo => _authUserInfo;

  @override
  bool get emailVerified => false;

  @override
  Future<void> delete() async {}

  @override
  Future<void> sendEmailVerification() async {}

  @override
  Future<void> updateEmail(String email) async {}

  @override
  Future<void> updatePassword(String newPassword) async {}
}

void main() {
  test('reveals home as soon as a restored authenticated session arrives', () {
    final notifier = AppStateNotifier.createForTesting();
    var notificationCount = 0;
    notifier.addListener(() => notificationCount += 1);

    expect(notifier.loading, isTrue);

    notifier.update(_TestAuthUser(loggedIn: true, uid: 'existing-user'));

    expect(notifier.loading, isFalse);
    expect(notifier.loggedIn, isTrue);
    expect(notifier.initiallyLoggedIn, isTrue);
    expect(notificationCount, 1);
  });

  test('reveals authentication only after the signed-out state resolves', () {
    final notifier = AppStateNotifier.createForTesting();

    expect(notifier.loading, isTrue);

    notifier.update(_TestAuthUser(loggedIn: false));

    expect(notifier.loading, isFalse);
    expect(notifier.loggedIn, isFalse);
    expect(notifier.initiallyLoggedIn, isFalse);
  });

  test('anonymous support session does not unlock the member application', () {
    final notifier = AppStateNotifier.createForTesting();

    notifier.update(
      _TestAuthUser(
        loggedIn: true,
        isAnonymous: true,
        uid: 'anonymous-support-guest',
      ),
    );

    expect(notifier.loading, isFalse);
    expect(notifier.loggedIn, isFalse);
    expect(notifier.initiallyLoggedIn, isFalse);
  });

  test('anonymous support identity remains a private Firebase session', () {
    final previousUser = currentUser;
    addTearDown(() => currentUser = previousUser);
    currentUser = _TestAuthUser(
      loggedIn: true,
      isAnonymous: true,
      uid: 'anonymous-support-guest',
    );

    expect(hasFirebaseSession, isTrue);
    expect(currentUserIsAnonymous, isTrue);
    expect(loggedIn, isFalse);
  });
}
