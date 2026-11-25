// Test stand-ins for the Firestore document returned by a public Bingo link.
// ignore_for_file: subtype_of_sealed_class, must_be_immutable

import 'package:choloto/autres/bingo/bingo/bingo_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:choloto/services/push_notification_service.dart';
import 'package:flutter_test/flutter_test.dart';

class _BingoReference extends Fake implements DocumentReference<Object?> {
  Map<String, dynamic>? fields;
  @override
  String get path => 'bingo/published';
  @override
  Future<DocumentSnapshot<Object?>> get([GetOptions? options]) async {
    expect(options?.source, Source.server);
    return _Snapshot(this);
  }
}

class _Snapshot extends Fake implements DocumentSnapshot<Object?> {
  _Snapshot(this.reference);
  @override
  final _BingoReference reference;
  @override
  bool get exists => reference.fields != null;
  @override
  Map<String, dynamic>? data() => reference.fields;
}

void main() {
  test('published VIP payloads and Croix open the existing screens', () {
    expect(webPushRoute({'type': 'new_prediction'}, signedInUid: null), '/vip');
    expect(webPushRoute({'type': 'new_croix'}, signedInUid: 'owner'), '/croix');
    expect(webPushRoute({'route': 'vip'}, signedInUid: 'owner'), isNull);
    expect(webPushRoute({'type': 'unknown'}, signedInUid: 'owner'), isNull);
  });

  test('public Bingo links carry only their encoded document ID to Home', () {
    const id = 'public 1?&autre=#';
    final route =
        webPushRoute({'type': 'new_bingo', 'bingoId': id}, signedInUid: null);
    expect(Uri.parse(route!).path, '/home');
    expect(Uri.parse(route).queryParameters, {'bingoId': id});
    for (final invalid in [null, '', '  ', 'other/document', 42]) {
      expect(
          webPushRoute({'type': 'new_bingo', 'bingoId': invalid},
              signedInUid: null),
          isNull);
    }
  });

  test(
      'Bingo links reopen an active publication and skip missing or expired records',
      () async {
    final ref = _BingoReference();
    expect(await readActiveBingoForNotification(ref), isNull);
    final now = DateTime.now();
    ref.fields = {
      'date': Timestamp.fromDate(now.subtract(const Duration(hours: 1))),
      'expiration': Timestamp.fromDate(now.add(const Duration(hours: 1))),
    };
    final record = await readActiveBingoForNotification(ref);
    expect(record?.reference, same(ref));
    ref.fields!['expiration'] =
        Timestamp.fromDate(now.subtract(const Duration(minutes: 1)));
    expect(await readActiveBingoForNotification(ref), isNull);
    ref.fields!.remove('expiration');
    expect(await readActiveBingoForNotification(ref), isNull);
  });

  test('foreground notifications and their actions require the active owner',
      () {
    for (final (type, path) in [
      ('assistant_reply', '/customerservice'),
      ('account_activated', '/upgrade'),
    ]) {
      final data = {
        'type': type,
        'recipientUid': 'owner',
        'route': '/elsewhere'
      };
      expect(webPushRoute(data, signedInUid: 'owner'), path);
      expect(webPushRoute(data, signedInUid: 'other'), isNull);
      expect(webPushRoute(data, signedInUid: null), isNull);
      expect(webPushRoute({'type': type}, signedInUid: 'owner'), isNull);
    }
  });
}
