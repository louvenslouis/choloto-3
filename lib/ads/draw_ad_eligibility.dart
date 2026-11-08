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

typedef DrawAdAccount = ({String? freeUid, bool checking});

Stream<DrawAdAccount> watchDrawAdAccount() =>
    FirebaseAuth.instance.authStateChanges().switchMap<DrawAdAccount>((user) {
      const checking = (freeUid: null, checking: true);
      if (user == null || user.isAnonymous) {
        return Stream.value((freeUid: null, checking: false));
      }
      return FirebaseFirestore.instance
          .collection('user')
          .doc(user.uid)
          .snapshots(includeMetadataChanges: true)
          .map<DrawAdAccount>((profile) {
        if (profile.metadata.isFromCache || profile.metadata.hasPendingWrites) {
          return checking;
        }
        final free = isConfirmedFreeProfile(
          uid: user.uid,
          data: profile.data(),
          fromCache: profile.metadata.isFromCache,
          pendingWrites: profile.metadata.hasPendingWrites,
          now: DateTime.now(),
        );
        return (freeUid: free ? user.uid : null, checking: false);
      }).startWith(checking);
    }).distinct();

Stream<String?> watchFreeDrawAccount() =>
    watchDrawAdAccount().map((account) => account.freeUid).distinct();
