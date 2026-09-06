import 'dart:convert';
import 'dart:typed_data';
import 'package:choloto/payments/payment_request.dart';
import 'package:flutter_test/flutter_test.dart';
import 'support/memory_firestore.dart';

void main() {
  test(
      'submission reads absence/profile before atomically writing and survives retry',
      () async {
    final db = MemoryFirestore();
    db.rows['user/member'] = {'email': 'member@example.test'};
    final repository = PaymentRequestRepository(firestore: db);
    final proof = Uint8List.fromList([255, 216, 255, 217]);
    Future<void> submit() => repository.submit(
        id: 'r1', userUid: 'member', proof: proof, note: ' note ');
    await submit();
    expect(db.reads, ['payment_requests/r1', 'user/member']);
    expect(db.rows['payment_requests/r1']!['note'], 'note');
    for (final field in [
      'amount',
      'currency',
      'payment_method',
      'payment_reference'
    ]) {
      expect(db.rows['payment_requests/r1']!.containsKey(field), isFalse);
    }
    expect(db.rows['payment_requests/r1']!['status'], 'pending');
    expect(db.rows['payment_requests/r1/evidence/image']!['base64'],
        base64Encode(proof));
    expect(db.rows['user/member']!.containsKey('end_sub'), isFalse);
    await submit();
    expect(db.rows.length, 3,
        reason: 'retry reuses request, no orphan or duplicate');
    db.rows['payment_requests/r1']!['user_uid'] = 'foreign';
    await expectLater(submit(), throwsStateError);
  });
  test('missing profile and invalid input leave no partial upload', () async {
    final db = MemoryFirestore();
    final repository = PaymentRequestRepository(firestore: db);
    Future<void> submit({String userUid = 'member'}) => repository.submit(
        id: 'r1',
        userUid: userUid,
        proof: Uint8List.fromList([255, 216, 255, 217]),
        note: '');
    await expectLater(submit(), throwsStateError);
    expect(db.rows, isEmpty);
    await expectLater(submit(userUid: ''), throwsArgumentError);
    expect(db.rows, isEmpty);
  });
}
