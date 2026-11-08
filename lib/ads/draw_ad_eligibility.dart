import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rxdart/rxdart.dart';

bool isConfirmedFreeProfile({
  required String uid,
  required Map<String, dynamic>? data,
  required bool fromCache,
  required bool pendingWrites,
  required DateTime now,
}) {
  if (fromCache || pendingWrites || data == null) return false;
  if (data.containsKey('uid') && data['uid'] != uid) return false;
  final end = data['end_sub'];
  return end is Timestamp && end.toDate().isBefore(now);
}

Stream<String?> watchFreeDrawAccount() =>
    FirebaseAuth.instance.authStateChanges().switchMap<String?>((user) {
      if (user == null || user.isAnonymous) return Stream.value(null);
      return FirebaseFirestore.instance
          .collection('user')
          .doc(user.uid)
          .snapshots(includeMetadataChanges: true)
          .map<String?>((profile) => isConfirmedFreeProfile(
                uid: user.uid,
                data: profile.data(),
                fromCache: profile.metadata.isFromCache,
                pendingWrites: profile.metadata.hasPendingWrites,
                now: DateTime.now(),
              )
                  ? user.uid
                  : null)
          .startWith(null);
    }).distinct();
