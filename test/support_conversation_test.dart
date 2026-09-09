import 'package:choloto/support/support_conversation.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/memory_firestore.dart';

void main() {
  test('first message reads absence/profile and writes one atomic conversation',
      () async {
    final db = MemoryFirestore();
    db.rows['user/member'] = {
      'email': 'member@example.test',
      'phone_number': '+50937000000',
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

  test('invalid message, missing profile and mismatched owner write nothing',
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
    await expectLater(
      repository.sendUserMessage(
          userUid: 'member', text: 'Bonjour', messageId: 'm1'),
      throwsA(
        isA<StateError>().having(
          (error) => error.message,
          'message',
          'support-phone-required',
        ),
      ),
    );
    expect(db.rows.keys, ['user/member']);

    await expectLater(
      repository.sendUserMessage(userUid: 'member', text: ' ', messageId: 'm1'),
      throwsArgumentError,
    );
    db.rows['support_conversations/member'] = {'user_uid': 'foreign'};
    await expectLater(
      repository.sendUserMessage(
          userUid: 'member', text: 'Bonjour', messageId: 'm2'),
      throwsStateError,
    );
    expect(
      db.rows.keys.toSet(),
      {'user/member', 'support_conversations/member'},
    );
  });
}
