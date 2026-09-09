import 'dart:convert';
import 'dart:typed_data';

import 'package:choloto/payments/payment_request.dart';
import 'package:choloto/support/support_conversation.dart';
import 'package:choloto/support/support_guest_session.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/memory_firestore.dart';

void main() {
  const guestId = '123e4567-e89b-42d3-a456-426614174000';

  test('guest support id is private, valid and persisted without auth',
      () async {
    SharedPreferences.setMockInitialValues({});
    final first = await GuestSupportSession.loadOrCreateId();
    final restored = await GuestSupportSession.loadOrCreateId();

    expect(GuestSupportSession.isValidId(first), isTrue);
    expect(restored, first);
    expect(GuestSupportSession.isValidId('member'), isFalse);
  });

  test('guest sends and retries a first message without a user profile',
      () async {
    final db = MemoryFirestore();
    final repository = SupportConversationRepository(firestore: db);

    await repository.sendGuestMessage(
      guestId: guestId,
      text: ' Téléphone: +50937000000\n\nJe veux m’abonner. ',
      messageId: 'guest-m1',
    );

    expect(db.reads, [
      'support_conversations/$guestId',
      'support_conversations/$guestId/messages/guest-m1',
    ]);
    expect(
      db.rows['support_conversations/$guestId'],
      containsPair('guest_access', true),
    );
    expect(
      db.rows['support_conversations/$guestId/messages/guest-m1']?['text'],
      'Téléphone: +50937000000\n\nJe veux m’abonner.',
    );

    await repository.sendGuestMessage(
      guestId: guestId,
      text: 'Téléphone: +50937000000\n\nJe veux m’abonner.',
      messageId: 'guest-m1',
    );
    expect(
      db.rows.keys.where((path) => path.contains('/messages/')),
      ['support_conversations/$guestId/messages/guest-m1'],
    );
  });

  test('guest rejects malformed capability ids', () async {
    final repository =
        SupportConversationRepository(firestore: MemoryFirestore());
    await expectLater(
      repository.sendGuestMessage(
        guestId: 'not-private',
        text: 'Bonjour',
      ),
      throwsArgumentError,
    );
  });

  test('first message reads absence/profile and writes one atomic conversation',
      () async {
    final db = MemoryFirestore();
    db.rows['user/member'] = {
      'email': 'member@example.test',
    };
    final repository = SupportConversationRepository(firestore: db);

    await repository.sendUserMessage(
      userUid: 'member',
      userEmail: ' member@example.test ',
      userDisplayName: ' Member ',
      text: ' Comment puis-je payer ? ',
      messageId: 'm1',
    );

    expect(db.reads, [
      'support_conversations/member',
      'support_conversations/member/messages/m1',
      'user/member'
    ]);
    expect(db.rows['support_conversations/member'],
        containsPair('topic', 'subscription'));
    expect(db.rows['support_conversations/member'],
        containsPair('last_message', 'Comment puis-je payer ?'));
    expect(db.rows['support_conversations/member'],
        containsPair('last_message_id', 'm1'));
    expect(db.rows['support_conversations/member'],
        containsPair('last_sender_role', 'user'));
    expect(db.rows['support_conversations/member/messages/m1'], {
      'sender_uid': 'member',
      'sender_role': 'user',
      'text': 'Comment puis-je payer ?',
      'created_at': isNotNull,
    });
  });

  test('following messages preserve identity metadata and update the summary',
      () async {
    final db = MemoryFirestore();
    db.rows['support_conversations/member'] = {
      'user_uid': 'member',
      'user_email': 'original@example.test',
      'user_display_name': 'Original',
      'topic': 'subscription',
      'status': 'open',
      'created_at': DateTime(2026),
      'updated_at': DateTime(2026),
      'last_message': 'Premier',
      'last_message_id': 'm1',
      'last_sender_role': 'admin',
    };
    final repository = SupportConversationRepository(firestore: db);

    await repository.sendUserMessage(
      userUid: 'member',
      userEmail: 'changed@example.test',
      userDisplayName: 'Changed',
      text: ' Merci ',
      messageId: 'm2',
    );

    expect(db.reads, [
      'support_conversations/member',
      'support_conversations/member/messages/m2'
    ]);
    expect(db.rows['support_conversations/member']!['user_email'],
        'original@example.test');
    expect(
        db.rows['support_conversations/member']!['created_at'], DateTime(2026));
    expect(db.rows['support_conversations/member']!['last_message'], 'Merci');
    expect(
        db.rows['support_conversations/member/messages/m2']!['text'], 'Merci');

    await repository.sendUserMessage(
      userUid: 'member',
      text: 'Merci',
      messageId: 'm2',
    );
    expect(
      db.rows.keys.where((path) => path.contains('/messages/')),
      ['support_conversations/member/messages/m2'],
    );
  });

  test('image is committed with its message and an exact retry is idempotent',
      () async {
    final db = MemoryFirestore();
    db.rows['support_conversations/member'] = {
      'user_uid': 'member',
      'topic': 'subscription',
      'status': 'open',
      'created_at': DateTime(2026),
      'updated_at': DateTime(2026),
      'last_message': 'Premier',
      'last_message_id': 'm1',
      'last_sender_role': 'admin',
    };
    final repository = SupportConversationRepository(firestore: db);
    final image = Uint8List.fromList([255, 216, 255, 217]);

    Future<void> send() => repository.sendUserMessage(
          userUid: 'member',
          text: 'Photo',
          image: image,
          messageId: 'm-image',
        );
    await send();

    expect(db.reads, [
      'support_conversations/member',
      'support_conversations/member/messages/m-image',
      'support_conversations/member/messages/m-image/attachments/image',
    ]);
    expect(db.rows['support_conversations/member/messages/m-image'], {
      'sender_uid': 'member',
      'sender_role': 'user',
      'text': 'Photo',
      'attachment_type': 'image',
      'created_at': isNotNull,
    });
    expect(
      db.rows[
          'support_conversations/member/messages/m-image/attachments/image'],
      {
        'base64': base64Encode(image),
        'mime_type': 'image/jpeg',
        'byte_length': image.length,
      },
    );

    await send();
    expect(
      db.rows.keys.where((path) => path.endsWith('/attachments/image')),
      hasLength(1),
    );
  });

  test('missing phone is allowed but invalid messages and owners are refused',
      () async {
    final db = MemoryFirestore();
    final repository = SupportConversationRepository(firestore: db);

    await expectLater(
      repository.sendUserMessage(
          userUid: 'member', text: 'Bonjour', messageId: 'm1'),
      throwsStateError,
    );
    expect(db.rows, isEmpty);

    db.rows['user/member'] = {'email': 'member@example.test'};
    await repository.sendUserMessage(
      userUid: 'member',
      text: 'Bonjour',
      messageId: 'm1',
    );
    expect(
      db.rows['support_conversations/member/messages/m1']?['text'],
      'Bonjour',
    );

    await expectLater(
      repository.sendUserMessage(userUid: 'member', text: ' ', messageId: 'm2'),
      throwsArgumentError,
    );
    await expectLater(
      repository.sendUserMessage(
        userUid: 'member',
        text: 'Photo',
        image: Uint8List(maxProofBytes + 1),
        messageId: 'm-image-too-large',
      ),
      throwsArgumentError,
    );
    db.rows['support_conversations/other'] = {'user_uid': 'foreign'};
    await expectLater(
      repository.sendUserMessage(
          userUid: 'other', text: 'Bonjour', messageId: 'm2'),
      throwsStateError,
    );
    expect(
      db.rows.keys.toSet(),
      {
        'user/member',
        'support_conversations/member',
        'support_conversations/member/messages/m1',
        'support_conversations/other',
      },
    );
  });
}
