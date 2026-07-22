import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';
import '/backend/schema/enums/enums.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class SettingsRecord extends FirestoreRecord {
  SettingsRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "betaFeatures" field.
  BetaFeaturesStruct? _betaFeatures;
  BetaFeaturesStruct get betaFeatures => _betaFeatures ?? BetaFeaturesStruct();
  bool hasBetaFeatures() => _betaFeatures != null;

  void _initializeFields() {
    _betaFeatures = snapshotData['betaFeatures'] is BetaFeaturesStruct
        ? snapshotData['betaFeatures']
        : BetaFeaturesStruct.maybeFromMap(snapshotData['betaFeatures']);
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('settings');

  static Stream<SettingsRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => SettingsRecord.fromSnapshot(s));

  static Future<SettingsRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => SettingsRecord.fromSnapshot(s));

  static SettingsRecord fromSnapshot(DocumentSnapshot snapshot) =>
      SettingsRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static SettingsRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      SettingsRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'SettingsRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is SettingsRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createSettingsRecordData({
  BetaFeaturesStruct? betaFeatures,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'betaFeatures': BetaFeaturesStruct().toMap(),
    }.withoutNulls,
  );

  // Handle nested data for "betaFeatures" field.
  addBetaFeaturesStructData(firestoreData, betaFeatures, 'betaFeatures');

  return firestoreData;
}

class SettingsRecordDocumentEquality implements Equality<SettingsRecord> {
  const SettingsRecordDocumentEquality();

  @override
  bool equals(SettingsRecord? e1, SettingsRecord? e2) {
    return e1?.betaFeatures == e2?.betaFeatures;
  }

  @override
  int hash(SettingsRecord? e) => const ListEquality().hash([e?.betaFeatures]);

  @override
  bool isValidKey(Object? o) => o is SettingsRecord;
}
