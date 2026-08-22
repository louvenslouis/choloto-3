import '/app_state.dart';
import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';

const bingoCommentMaxLength = 500;

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
  final comment = normalizeBingoComment(value);
  final bingoReference = FFAppState().bingo.doc;

  if (bingoReference == null ||
      currentUserReference == null ||
      currentUserUid.isEmpty) {
    throw const BingoCommentUnavailableException();
  }

  final commentReference =
      bingoReference.collection('comments').doc(currentUserUid);
  final existingComment = await commentReference.get();
  final serverTimestamp = FieldValue.serverTimestamp();

  if (existingComment.exists) {
    await commentReference.update({
      'text': comment,
      'updatedAt': serverTimestamp,
    });
    return;
  }

  await commentReference.set({
    'user': currentUserUid,
    'text': comment,
    'createdAt': serverTimestamp,
    'updatedAt': serverTimestamp,
  });
}
