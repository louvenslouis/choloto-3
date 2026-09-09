import 'dart:convert';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';

import '/payments/payment_request.dart' show maxProofBytes;
import 'support_guest_session.dart';

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
  bool get hasImage => data['attachment_type'] == 'image';
  DateTime? get createdAt => supportDate(data['created_at']);
  bool get sentByAdmin => senderRole == 'admin';
}

class SupportConversationRepository {
  SupportConversationRepository({FirebaseFirestore? firestore})
      : db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore db;

  CollectionReference<Map<String, dynamic>> get conversations =>
      db.collection('support_conversations');

  DocumentReference<Map<String, dynamic>> guestConversation(String guestId) =>
      conversations.doc(guestId);

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

  Stream<List<SupportMessage>> watchGuestMessages(String guestId) {
    if (!GuestSupportSession.isValidId(guestId)) {
      return Stream.error(ArgumentError('invalid-support-guest'));
    }
    return guestConversation(guestId).collection('messages').snapshots().map(
        (snapshot) => snapshot.docs
            .map((doc) => SupportMessage(doc.id, doc.data()))
            .toList()
          ..sort((a, b) => (a.createdAt ?? DateTime(1970))
              .compareTo(b.createdAt ?? DateTime(1970))));
  }

  Future<Uint8List> loadMessageImage({
    required String conversationId,
    required String messageId,
  }) async {
    final snapshot = await conversations
        .doc(conversationId)
        .collection('messages')
        .doc(messageId)
        .collection('attachments')
        .doc('image')
        .get();
    final data = snapshot.data();
    if (data == null ||
        data['base64'] is! String ||
        (data['base64'] as String).length > 800000) {
      throw const FormatException('support-image-unavailable');
    }
    final bytes = base64Decode(data['base64'] as String);
    if (bytes.isEmpty || bytes.length > maxProofBytes) {
      throw const FormatException('invalid-support-image');
    }
    return bytes;
  }

  Future<void> sendGuestMessage({
    required String guestId,
    required String text,
    Uint8List? image,
    String? messageId,
  }) async {
    if (!GuestSupportSession.isValidId(guestId)) {
      throw ArgumentError('invalid-support-guest');
    }
    final normalized = text.trim();
    if (normalized.isEmpty ||
        normalized.length > 1000 ||
        (image != null && (image.isEmpty || image.length > maxProofBytes)) ||
        (messageId != null &&
            (messageId.isEmpty ||
                messageId.length > 128 ||
                messageId.contains('/')))) {
      throw ArgumentError('invalid-support-message');
    }

    final conversationRef = guestConversation(guestId);
    final resolvedMessageId =
        messageId ?? conversationRef.collection('messages').doc().id;
    final messageRef =
        conversationRef.collection('messages').doc(resolvedMessageId);
    final imageRef = messageRef.collection('attachments').doc('image');

    await db.runTransaction((transaction) async {
      final conversation = await transaction.get(conversationRef);
      final existingMessage = await transaction.get(messageRef);
      final existingImage =
          image == null ? null : await transaction.get(imageRef);
      if (existingMessage.exists) {
        final data = existingMessage.data();
        if (data?['sender_uid'] == guestId &&
            data?['sender_role'] == 'user' &&
            data?['text'] == normalized &&
            ((image == null && data?['attachment_type'] == null) ||
                (image != null &&
                    data?['attachment_type'] == 'image' &&
                    existingImage?.data()?['base64'] == base64Encode(image))) &&
            conversation.data()?['last_message_id'] == resolvedMessageId) {
          return;
        }
        throw StateError('support-message-id');
      }
      if (conversation.exists) {
        if (conversation.data()?['user_uid'] != guestId ||
            conversation.data()?['guest_access'] != true) {
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
        transaction.set(conversationRef, {
          'user_uid': guestId,
          'guest_access': true,
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
        'sender_uid': guestId,
        'sender_role': 'user',
        'text': normalized,
        if (image != null) 'attachment_type': 'image',
        'created_at': FieldValue.serverTimestamp(),
      });
      if (image != null) {
        transaction.set(imageRef, {
          'base64': base64Encode(image),
          'mime_type': 'image/jpeg',
          'byte_length': image.length,
        });
      }
    });
  }

  /// Sends the summary and immutable message in one transaction. Supplying a
  /// message id is useful for retrying an uncertain acknowledgement and tests.
  Future<void> sendUserMessage({
    required String userUid,
    required String text,
    Uint8List? image,
    String userEmail = '',
    String userDisplayName = '',
    String? messageId,
  }) async {
    final normalized = text.trim();
    if (userUid.isEmpty ||
        normalized.isEmpty ||
        normalized.length > 1000 ||
        (image != null && (image.isEmpty || image.length > maxProofBytes)) ||
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
    final imageRef = messageRef.collection('attachments').doc('image');
    final normalizedEmail = userEmail.trim();
    final normalizedName = userDisplayName.trim();

    await db.runTransaction((transaction) async {
      final conversation = await transaction.get(conversationRef);
      final existingMessage = await transaction.get(messageRef);
      final existingImage =
          image == null ? null : await transaction.get(imageRef);
      if (existingMessage.exists) {
        final data = existingMessage.data();
        if (data?['sender_uid'] == userUid &&
            data?['sender_role'] == 'user' &&
            data?['text'] == normalized &&
            ((image == null && data?['attachment_type'] == null) ||
                (image != null &&
                    data?['attachment_type'] == 'image' &&
                    existingImage?.data()?['base64'] == base64Encode(image))) &&
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
        if (image != null) 'attachment_type': 'image',
        'created_at': FieldValue.serverTimestamp(),
      });
      if (image != null) {
        transaction.set(imageRef, {
          'base64': base64Encode(image),
          'mime_type': 'image/jpeg',
          'byte_length': image.length,
        });
      }
    });
  }
}
