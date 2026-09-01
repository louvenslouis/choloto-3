import '/app_state.dart';
import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import 'package:uuid/uuid.dart';

const bingoCommentMaxLength = 500;
const _bingoCommentDocumentPrefix = 'comment_';
const _uuid = Uuid();

class BingoCommentStatus {
  const BingoCommentStatus({
    this.commentId = '',
    required this.adminLiked,
    required this.adminLikedAt,
    required this.adminReply,
    required this.adminReplyAt,
  });

  final String commentId;
  final bool adminLiked;
  final DateTime? adminLikedAt;
  final String adminReply;
  final DateTime? adminReplyAt;

  bool get hasAdminReply => adminReply.isNotEmpty;
  bool get hasAdminInteraction => adminLiked || hasAdminReply;
}

class BingoPublicComment {
  const BingoPublicComment({
    required this.id,
    required this.userId,
    required this.text,
    required this.createdAt,
    required this.updatedAt,
    required this.adminLiked,
    required this.adminReply,
    required this.adminReplyAt,
    required this.likeCount,
    required this.likedByCurrentUser,
  });

  final String id;
  final String userId;
  final String text;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final bool adminLiked;
  final String adminReply;
  final DateTime? adminReplyAt;
  final int likeCount;
  final bool likedByCurrentUser;

  bool get hasAdminReply => adminReply.isNotEmpty;

  bool isOwnedBy(String viewerUserId) =>
      viewerUserId.isNotEmpty && userId == viewerUserId;
}

BingoPublicComment? parseBingoPublicComment({
  required String id,
  required Map<String, dynamic> data,
  int likeCount = 0,
  bool likedByCurrentUser = false,
}) {
  final text = data['text'] is String ? (data['text'] as String).trim() : '';
  if (text.isEmpty) return null;
  return BingoPublicComment(
    id: id,
    userId: data['user'] is String ? (data['user'] as String).trim() : '',
    text: text,
    createdAt: _dateTimeValue(data['createdAt']),
    updatedAt: _dateTimeValue(data['updatedAt']),
    adminLiked: data['adminLiked'] == true,
    adminReply: data['adminReply'] is String
        ? (data['adminReply'] as String).trim()
        : '',
    adminReplyAt: _dateTimeValue(data['adminReplyAt']),
    likeCount: likeCount,
    likedByCurrentUser: likedByCurrentUser,
  );
}

BingoCommentStatus parseBingoCommentStatus(Map<String, dynamic> data) {
  return BingoCommentStatus(
    commentId: data['__documentId'] is String
        ? (data['__documentId'] as String).trim()
        : '',
    adminLiked: data['adminLiked'] == true,
    adminLikedAt: _dateTimeValue(data['adminLikedAt']),
    adminReply: data['adminReply'] is String
        ? (data['adminReply'] as String).trim()
        : '',
    adminReplyAt: _dateTimeValue(data['adminReplyAt']),
  );
}

BingoCommentStatus? latestBingoCommentStatus(
  Iterable<Map<String, dynamic>> comments,
) {
  Map<String, dynamic>? latestComment;
  DateTime? latestActivityAt;

  for (final comment in comments) {
    final activityAt = _latestDateTimeValue([
      comment['adminReplyAt'],
      comment['adminLikedAt'],
      comment['updatedAt'],
      comment['createdAt'],
    ]);
    if (latestComment == null ||
        (activityAt != null &&
            (latestActivityAt == null ||
                activityAt.isAfter(latestActivityAt)))) {
      latestComment = comment;
      latestActivityAt = activityAt;
    }
  }

  return latestComment == null ? null : parseBingoCommentStatus(latestComment);
}

String createBingoCommentDocumentId() =>
    '$_bingoCommentDocumentPrefix${_uuid.v4()}';

class BingoCommentUnavailableException implements Exception {
  const BingoCommentUnavailableException();
}

class BingoCommentValidationException implements Exception {
  const BingoCommentValidationException();
}

String normalizeBingoComment(String value) {
  final normalized = value.trim();
  if (normalized.isEmpty || normalized.length > bingoCommentMaxLength) {
    throw const BingoCommentValidationException();
  }
  return normalized;
}

Future<void> saveCurrentBingoComment(String value) async {
  return saveBingoComment(
    value,
    bingoReference: FFAppState().bingo.doc,
  );
}

Future<BingoCommentStatus?> loadBingoCommentStatus({
  required DocumentReference? bingoReference,
}) async {
  if (bingoReference == null || currentUserUid.isEmpty) return null;

  final snapshot = await bingoReference
      .collection('comments')
      .where('user', isEqualTo: currentUserUid)
      .get();
  return latestBingoCommentStatus(
    snapshot.docs.map(
      (document) => <String, dynamic>{
        '__documentId': document.id,
        ...document.data(),
      },
    ),
  );
}

Future<int> loadBingoCommentCount({
  required DocumentReference? bingoReference,
}) async {
  if (bingoReference == null) return 0;
  final snapshot =
      await bingoReference.collection('comments').count().get();
  return snapshot.count ?? 0;
}

Future<List<BingoPublicComment>> loadPublicBingoComments({
  required DocumentReference? bingoReference,
}) async {
  if (bingoReference == null) return const [];

  final commentsSnapshot = await bingoReference
      .collection('comments')
      .orderBy('updatedAt', descending: true)
      .get();
  final userId = currentUserUid;
  final comments = await Future.wait(
    commentsSnapshot.docs.map((document) async {
      final likes = document.reference.collection('likes');
      final values = await Future.wait<dynamic>([
        likes.count().get(),
        if (userId.isNotEmpty) likes.doc(userId).get(),
      ]);
      final likeCount = (values.first as AggregateQuerySnapshot).count ?? 0;
      final likedByCurrentUser = userId.isNotEmpty &&
          values.length > 1 &&
          (values[1] as DocumentSnapshot).exists;
      return parseBingoPublicComment(
        id: document.id,
        data: document.data(),
        likeCount: likeCount,
        likedByCurrentUser: likedByCurrentUser,
      );
    }),
  );
  return comments.whereType<BingoPublicComment>().toList(growable: false);
}

Future<void> togglePublicBingoCommentLike({
  required DocumentReference? bingoReference,
  required String commentId,
}) async {
  if (bingoReference == null || currentUserUid.isEmpty) {
    throw const BingoCommentUnavailableException();
  }

  final likeReference = bingoReference
      .collection('comments')
      .doc(commentId)
      .collection('likes')
      .doc(currentUserUid);
  final existingLike = await likeReference.get();
  if (existingLike.exists) {
    await likeReference.delete();
    return;
  }
  await likeReference.set({'createdAt': FieldValue.serverTimestamp()});
}

Future<void> deleteBingoComment({
  required DocumentReference? bingoReference,
  required String commentId,
}) async {
  if (bingoReference == null || currentUserUid.isEmpty || commentId.isEmpty) {
    throw const BingoCommentUnavailableException();
  }

  final commentReference = bingoReference.collection('comments').doc(commentId);
  final snapshot = await commentReference.get();
  final data = snapshot.data();
  if (!snapshot.exists || data == null || data['user'] != currentUserUid) {
    throw const BingoCommentUnavailableException();
  }

  await commentReference.delete();
}

Future<void> saveBingoComment(
  String value, {
  required DocumentReference? bingoReference,
}) async {
  final comment = normalizeBingoComment(value);

  if (bingoReference == null ||
      currentUserReference == null ||
      currentUserUid.isEmpty) {
    throw const BingoCommentUnavailableException();
  }

  final commentReference =
      bingoReference.collection('comments').doc(createBingoCommentDocumentId());
  final serverTimestamp = FieldValue.serverTimestamp();

  await commentReference.set({
    'user': currentUserUid,
    'text': comment,
    'createdAt': serverTimestamp,
    'updatedAt': serverTimestamp,
  });
}

DateTime? _dateTimeValue(dynamic value) {
  if (value is Timestamp) return value.toDate();
  return value is DateTime ? value : null;
}

DateTime? _latestDateTimeValue(Iterable<dynamic> values) {
  DateTime? latest;
  for (final value in values) {
    final dateTime = _dateTimeValue(value);
    if (dateTime != null && (latest == null || dateTime.isAfter(latest))) {
      latest = dateTime;
    }
  }
  return latest;
}
