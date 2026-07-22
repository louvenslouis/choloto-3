// ignore_for_file: unnecessary_getters_setters

import 'package:cloud_firestore/cloud_firestore.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';
import '/backend/schema/enums/enums.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class SaintsStruct extends FFFirebaseStruct {
  SaintsStruct({
    String? saint,
    String? date,
    FirestoreUtilData firestoreUtilData = const FirestoreUtilData(),
  })  : _saint = saint,
        _date = date,
        super(firestoreUtilData);

  // "saint" field.
  String? _saint;
  String get saint => _saint ?? '';
  set saint(String? val) => _saint = val;

  bool hasSaint() => _saint != null;

  // "date" field.
  String? _date;
  String get date => _date ?? '';
  set date(String? val) => _date = val;

  bool hasDate() => _date != null;

  static SaintsStruct fromMap(Map<String, dynamic> data) => SaintsStruct(
        saint: data['saint'] as String?,
        date: data['date'] as String?,
      );

  static SaintsStruct? maybeFromMap(dynamic data) =>
      data is Map ? SaintsStruct.fromMap(data.cast<String, dynamic>()) : null;

  Map<String, dynamic> toMap() => {
        'saint': _saint,
        'date': _date,
      }.withoutNulls;

  @override
  Map<String, dynamic> toSerializableMap() => {
        'saint': serializeParam(
          _saint,
          ParamType.String,
        ),
        'date': serializeParam(
          _date,
          ParamType.String,
        ),
      }.withoutNulls;

  static SaintsStruct fromSerializableMap(Map<String, dynamic> data) =>
      SaintsStruct(
        saint: deserializeParam(
          data['saint'],
          ParamType.String,
          false,
        ),
        date: deserializeParam(
          data['date'],
          ParamType.String,
          false,
        ),
      );

  @override
  String toString() => 'SaintsStruct(${toMap()})';

  @override
  bool operator ==(Object other) {
    return other is SaintsStruct && saint == other.saint && date == other.date;
  }

  @override
  int get hashCode => const ListEquality().hash([saint, date]);
}

SaintsStruct createSaintsStruct({
  String? saint,
  String? date,
  Map<String, dynamic> fieldValues = const {},
  bool clearUnsetFields = true,
  bool create = false,
  bool delete = false,
}) =>
    SaintsStruct(
      saint: saint,
      date: date,
      firestoreUtilData: FirestoreUtilData(
        clearUnsetFields: clearUnsetFields,
        create: create,
        delete: delete,
        fieldValues: fieldValues,
      ),
    );

SaintsStruct? updateSaintsStruct(
  SaintsStruct? saints, {
  bool clearUnsetFields = true,
  bool create = false,
}) =>
    saints
      ?..firestoreUtilData = FirestoreUtilData(
        clearUnsetFields: clearUnsetFields,
        create: create,
      );

void addSaintsStructData(
  Map<String, dynamic> firestoreData,
  SaintsStruct? saints,
  String fieldName, [
  bool forFieldValue = false,
]) {
  firestoreData.remove(fieldName);
  if (saints == null) {
    return;
  }
  if (saints.firestoreUtilData.delete) {
    firestoreData[fieldName] = FieldValue.delete();
    return;
  }
  final clearFields =
      !forFieldValue && saints.firestoreUtilData.clearUnsetFields;
  if (clearFields) {
    firestoreData[fieldName] = <String, dynamic>{};
  }
  final saintsData = getSaintsFirestoreData(saints, forFieldValue);
  final nestedData = saintsData.map((k, v) => MapEntry('$fieldName.$k', v));

  final mergeFields = saints.firestoreUtilData.create || clearFields;
  firestoreData
      .addAll(mergeFields ? mergeNestedFields(nestedData) : nestedData);
}

Map<String, dynamic> getSaintsFirestoreData(
  SaintsStruct? saints, [
  bool forFieldValue = false,
]) {
  if (saints == null) {
    return {};
  }
  final firestoreData = mapToFirestore(saints.toMap());

  // Add any Firestore field values
  mapToFirestore(saints.firestoreUtilData.fieldValues)
      .forEach((k, v) => firestoreData[k] = v);

  return forFieldValue ? mergeNestedFields(firestoreData) : firestoreData;
}

List<Map<String, dynamic>> getSaintsListFirestoreData(
  List<SaintsStruct>? saintss,
) =>
    saintss?.map((e) => getSaintsFirestoreData(e, true)).toList() ?? [];
