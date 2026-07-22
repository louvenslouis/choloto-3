import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';
import '/backend/schema/enums/enums.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class YoutubeLinksRecord extends FirestoreRecord {
  YoutubeLinksRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "date" field.
  DateTime? _date;
  DateTime? get date => _date;
  bool hasDate() => _date != null;

  // "caption" field.
  String? _caption;
  String get caption => _caption ?? '';
  bool hasCaption() => _caption != null;

  // "link" field.
  String? _link;
  String get link => _link ?? '';
  bool hasLink() => _link != null;

  // "id" field.
  String? _id;
  String get id => _id ?? '';
  bool hasId() => _id != null;

  // "expiration" field.
  DateTime? _expiration;
  DateTime? get expiration => _expiration;
  bool hasExpiration() => _expiration != null;

  void _initializeFields() {
    _date = snapshotData['date'] as DateTime?;
    _caption = snapshotData['caption'] as String?;
    _link = snapshotData['link'] as String?;
    _id = snapshotData['id'] as String?;
    _expiration = snapshotData['expiration'] as DateTime?;
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('youtubeLinks');

  static Stream<YoutubeLinksRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => YoutubeLinksRecord.fromSnapshot(s));

  static Future<YoutubeLinksRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => YoutubeLinksRecord.fromSnapshot(s));

  static YoutubeLinksRecord fromSnapshot(DocumentSnapshot snapshot) =>
      YoutubeLinksRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static YoutubeLinksRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      YoutubeLinksRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'YoutubeLinksRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is YoutubeLinksRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createYoutubeLinksRecordData({
  DateTime? date,
  String? caption,
  String? link,
  String? id,
  DateTime? expiration,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'date': date,
      'caption': caption,
      'link': link,
      'id': id,
      'expiration': expiration,
    }.withoutNulls,
  );

  return firestoreData;
}

class YoutubeLinksRecordDocumentEquality
    implements Equality<YoutubeLinksRecord> {
  const YoutubeLinksRecordDocumentEquality();

  @override
  bool equals(YoutubeLinksRecord? e1, YoutubeLinksRecord? e2) {
    return e1?.date == e2?.date &&
        e1?.caption == e2?.caption &&
        e1?.link == e2?.link &&
        e1?.id == e2?.id &&
        e1?.expiration == e2?.expiration;
  }

  @override
  int hash(YoutubeLinksRecord? e) => const ListEquality()
      .hash([e?.date, e?.caption, e?.link, e?.id, e?.expiration]);

  @override
  bool isValidKey(Object? o) => o is YoutubeLinksRecord;
}
