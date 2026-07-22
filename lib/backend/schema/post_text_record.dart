import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';
import '/backend/schema/enums/enums.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class PostTextRecord extends FirestoreRecord {
  PostTextRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "date" field.
  DateTime? _date;
  DateTime? get date => _date;
  bool hasDate() => _date != null;

  // "expiration" field.
  DateTime? _expiration;
  DateTime? get expiration => _expiration;
  bool hasExpiration() => _expiration != null;

  // "text" field.
  String? _text;
  String get text => _text ?? '';
  bool hasText() => _text != null;

  // "link" field.
  String? _link;
  String get link => _link ?? '';
  bool hasLink() => _link != null;

  void _initializeFields() {
    _date = snapshotData['date'] as DateTime?;
    _expiration = snapshotData['expiration'] as DateTime?;
    _text = snapshotData['text'] as String?;
    _link = snapshotData['link'] as String?;
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('postText');

  static Stream<PostTextRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => PostTextRecord.fromSnapshot(s));

  static Future<PostTextRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => PostTextRecord.fromSnapshot(s));

  static PostTextRecord fromSnapshot(DocumentSnapshot snapshot) =>
      PostTextRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static PostTextRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      PostTextRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'PostTextRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is PostTextRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createPostTextRecordData({
  DateTime? date,
  DateTime? expiration,
  String? text,
  String? link,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'date': date,
      'expiration': expiration,
      'text': text,
      'link': link,
    }.withoutNulls,
  );

  return firestoreData;
}

class PostTextRecordDocumentEquality implements Equality<PostTextRecord> {
  const PostTextRecordDocumentEquality();

  @override
  bool equals(PostTextRecord? e1, PostTextRecord? e2) {
    return e1?.date == e2?.date &&
        e1?.expiration == e2?.expiration &&
        e1?.text == e2?.text &&
        e1?.link == e2?.link;
  }

  @override
  int hash(PostTextRecord? e) =>
      const ListEquality().hash([e?.date, e?.expiration, e?.text, e?.link]);

  @override
  bool isValidKey(Object? o) => o is PostTextRecord;
}
