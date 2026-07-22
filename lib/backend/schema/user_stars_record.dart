import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';
import '/backend/schema/enums/enums.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class UserStarsRecord extends FirestoreRecord {
  UserStarsRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "stars" field.
  List<StarsStruct>? _stars;
  List<StarsStruct> get stars => _stars ?? const [];
  bool hasStars() => _stars != null;

  DocumentReference get parentReference => reference.parent.parent!;

  void _initializeFields() {
    _stars = getStructList(
      snapshotData['stars'],
      StarsStruct.fromMap,
    );
  }

  static Query<Map<String, dynamic>> collection([DocumentReference? parent]) =>
      parent != null
          ? parent.collection('userStars')
          : FirebaseFirestore.instance.collectionGroup('userStars');

  static DocumentReference createDoc(DocumentReference parent, {String? id}) =>
      parent.collection('userStars').doc(id);

  static Stream<UserStarsRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => UserStarsRecord.fromSnapshot(s));

  static Future<UserStarsRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => UserStarsRecord.fromSnapshot(s));

  static UserStarsRecord fromSnapshot(DocumentSnapshot snapshot) =>
      UserStarsRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static UserStarsRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      UserStarsRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'UserStarsRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is UserStarsRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createUserStarsRecordData() {
  final firestoreData = mapToFirestore(
    <String, dynamic>{}.withoutNulls,
  );

  return firestoreData;
}

class UserStarsRecordDocumentEquality implements Equality<UserStarsRecord> {
  const UserStarsRecordDocumentEquality();

  @override
  bool equals(UserStarsRecord? e1, UserStarsRecord? e2) {
    const listEquality = ListEquality();
    return listEquality.equals(e1?.stars, e2?.stars);
  }

  @override
  int hash(UserStarsRecord? e) => const ListEquality().hash([e?.stars]);

  @override
  bool isValidKey(Object? o) => o is UserStarsRecord;
}
