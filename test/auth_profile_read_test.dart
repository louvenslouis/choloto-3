// Test-only stand-ins for SDK interfaces; never used by production.
// ignore_for_file: subtype_of_sealed_class, must_be_immutable

import 'package:choloto/auth/firebase_auth/auth_util.dart';
import 'package:choloto/backend/backend.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';

class _TestUser extends Fake implements User {
  @override
  String get uid => 'member';
}

class _CountingUserReference extends Fake
    implements DocumentReference<Object?> {
  var reads = 0;

  @override
  String get id => 'member';

  @override
  String get path => 'user/member';

  @override
  Future<DocumentSnapshot<Object?>> get([GetOptions? options]) async {
    reads++;
    return _ExistingUserSnapshot(this);
  }
}

class _ExistingUserSnapshot extends Fake implements DocumentSnapshot<Object?> {
  _ExistingUserSnapshot(this.reference);

  @override
  final DocumentReference<Object?> reference;

  @override
  bool get exists => true;

  @override
  Object? data() => {
        'uid': 'member',
        'email': 'member@example.test',
      };
}

void main() {
  test('existing profile snapshot is reused instead of read twice', () async {
    final reference = _CountingUserReference();
    currentUserDocument = null;

    await maybeCreateUser(
      _TestUser(),
      userRecordOverride: reference,
    );

    expect(reference.reads, 1);
    expect(currentUserDocument?.reference.path, 'user/member');
    expect(currentUserDocument?.uid, 'member');
  });
}
