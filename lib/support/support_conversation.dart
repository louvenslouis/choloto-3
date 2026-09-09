import 'package:cloud_firestore/cloud_firestore.dart';

import 'support_phone_requirement.dart';

DateTime? supportDate(Object? value) => value is Timestamp
    ? value.toDate()
    : value is DateTime
        ? value
        : null;

class SupportConversation {
  const SupportConversation(this.id, this.data);

  final String id;
  final Map<String, dynamic> data;

  String get userUid => data['user_uid'] as String? ?? id;
  String get userEmail => data['user_email'] as String? ?? '';
  String get userDisplayName => data['user_display_name'] as String? ?? '';
  String get lastMessage => data['last_message'] as String? ?? '';
  String get lastSenderRole => data['last_sender_role'] as String? ?? '';
  DateTime? get createdAt => supportDate(data['created_at']);
  DateTime? get updatedAt => supportDate(data['updated_at']);
  bool get waitingForAdmin => lastSenderRole == 'user';
}

class SupportMessage {
  const SupportMessage(this.id, this.data);

  final String id;
  final Map<String, dynamic> data;

  String get senderUid => data['sender_uid'] as String? ?? '';
  String get senderRole => data['sender_role'] as String? ?? '';
  String get text => data['text'] as String? ?? '';
  DateTime? get createdAt => supportDate(data['created_at']);
  bool get sentByAdmin => senderRole == 'admin';
}

class SupportConversationRepository {
  SupportConversationRepository({FirebaseFirestore? firestore})
      : db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore db;

  CollectionReference<Map<String, dynamic>> get conversations =>
      db.collection('support_conversations');

  Stream<SupportConversation?> watchConversation(String userUid) =>
      conversations.doc(userUid).snapshots().map((snapshot) {
        final data = snapshot.data();
        return data == null ? null : SupportConversation(snapshot.id, data);
      });

  Stream<List<SupportMessage>> watchMessages(String userUid) => conversations
      .doc(userUid)
      .collection('messages')
      .snapshots()
      .map((snapshot) => snapshot.docs
          .map((doc) => SupportMessage(doc.id, doc.data()))
          .toList()
        ..sort((a, b) => (a.createdAt ?? DateTime(1970))
            .compareTo(b.createdAt ?? DateTime(1970))));

  /// Sends the summary and immutable message in one transaction. Supplying a
  /// message id is useful for retrying an uncertain acknowledgement and tests.
  Future<void> sendUserMessage({
    required String userUid,
    required String text,
    String userEmail = '',
    String userDisplayName = '',
    String? messageId,
  }) async {
    final normalized = text.trim();
    if (userUid.isEmpty ||
        normalized.isEmpty ||
        normalized.length > 1000 ||
        (messageId != null &&
            (messageId.isEmpty ||
                messageId.length > 128 ||
                messageId.contains('/')))) {
      throw ArgumentError('invalid-support-message');
    }

    final conversationRef = conversations.doc(userUid);
    final resolvedMessageId =
        messageId ?? conversationRef.collection('messages').doc().id;
    final messageRef =
        conversationRef.collection('messages').doc(resolvedMessageId);
    final normalizedEmail = userEmail.trim();
    final normalizedName = userDisplayName.trim();

    await db.runTransaction((transaction) async {
      final conversation = await transaction.get(conversationRef);
      final existingMessage = await transaction.get(messageRef);
      if (existingMessage.exists) {
        final data = existingMessage.data();
        if (data?['sender_uid'] == userUid &&
            data?['sender_role'] == 'user' &&
            data?['text'] == normalized &&
            conversation.data()?['last_message_id'] == resolvedMessageId) {
          return;
        }
        throw StateError('support-message-id');
      }
      if (conversation.exists) {
        if (conversation.data()?['user_uid'] != userUid) {
          throw StateError('support-conversation-owner');
        }
        transaction.update(conversationRef, {
          'status': 'open',
          'updated_at': FieldValue.serverTimestamp(),
          'last_message': normalized,
          'last_message_id': resolvedMessageId,
          'last_sender_role': 'user',
        });
      } else {
        final profile =
            await transaction.get(db.collection('user').doc(userUid));
        if (!profile.exists) {
          throw StateError('profile-missing');
        }
        if (!hasRequiredSupportPhone(profile.data()?['phone_number'])) {
          throw StateError('support-phone-required');
        }
        transaction.set(conversationRef, {
          'user_uid': userUid,
          if (normalizedEmail.isNotEmpty && normalizedEmail.length <= 320)
            'user_email': normalizedEmail,
          if (normalizedName.isNotEmpty && normalizedName.length <= 256)
            'user_display_name': normalizedName,
          'topic': 'subscription',
          'status': 'open',
          'created_at': FieldValue.serverTimestamp(),
          'updated_at': FieldValue.serverTimestamp(),
          'last_message': normalized,
          'last_message_id': resolvedMessageId,
          'last_sender_role': 'user',
        });
      }
      transaction.set(messageRef, {
        'sender_uid': userUid,
        'sender_role': 'user',
        'text': normalized,
        'created_at': FieldValue.serverTimestamp(),
      });
    });
  }
}
