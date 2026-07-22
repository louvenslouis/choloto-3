// ignore_for_file: unnecessary_getters_setters

import 'package:cloud_firestore/cloud_firestore.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';
import '/backend/schema/enums/enums.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

/// DSL struct NewYorkPick3Draw
class NewYorkPick3DrawStruct extends FFFirebaseStruct {
  NewYorkPick3DrawStruct({
    /// NewYorkPick3Draw.draw_date
    String? drawDate,

    /// NewYorkPick3Draw.midday_daily
    String? middayDaily,

    /// NewYorkPick3Draw.evening_daily
    String? eveningDaily,
    FirestoreUtilData firestoreUtilData = const FirestoreUtilData(),
  })  : _drawDate = drawDate,
        _middayDaily = middayDaily,
        _eveningDaily = eveningDaily,
        super(firestoreUtilData);

  // "draw_date" field.
  String? _drawDate;
  String get drawDate => _drawDate ?? '';
  set drawDate(String? val) => _drawDate = val;

  bool hasDrawDate() => _drawDate != null;

  // "midday_daily" field.
  String? _middayDaily;
  String get middayDaily => _middayDaily ?? '';
  set middayDaily(String? val) => _middayDaily = val;

  bool hasMiddayDaily() => _middayDaily != null;

  // "evening_daily" field.
  String? _eveningDaily;
  String get eveningDaily => _eveningDaily ?? '';
  set eveningDaily(String? val) => _eveningDaily = val;

  bool hasEveningDaily() => _eveningDaily != null;

  static NewYorkPick3DrawStruct fromMap(Map<String, dynamic> data) =>
      NewYorkPick3DrawStruct(
        drawDate: data['draw_date'] as String?,
        middayDaily: data['midday_daily'] as String?,
        eveningDaily: data['evening_daily'] as String?,
      );

  static NewYorkPick3DrawStruct? maybeFromMap(dynamic data) => data is Map
      ? NewYorkPick3DrawStruct.fromMap(data.cast<String, dynamic>())
      : null;

  Map<String, dynamic> toMap() => {
        'draw_date': _drawDate,
        'midday_daily': _middayDaily,
        'evening_daily': _eveningDaily,
      }.withoutNulls;

  @override
  Map<String, dynamic> toSerializableMap() => {
        'draw_date': serializeParam(
          _drawDate,
          ParamType.String,
        ),
        'midday_daily': serializeParam(
          _middayDaily,
          ParamType.String,
        ),
        'evening_daily': serializeParam(
          _eveningDaily,
          ParamType.String,
        ),
      }.withoutNulls;

  static NewYorkPick3DrawStruct fromSerializableMap(
          Map<String, dynamic> data) =>
      NewYorkPick3DrawStruct(
        drawDate: deserializeParam(
          data['draw_date'],
          ParamType.String,
          false,
        ),
        middayDaily: deserializeParam(
          data['midday_daily'],
          ParamType.String,
          false,
        ),
        eveningDaily: deserializeParam(
          data['evening_daily'],
          ParamType.String,
          false,
        ),
      );

  @override
  String toString() => 'NewYorkPick3DrawStruct(${toMap()})';

  @override
  bool operator ==(Object other) {
    return other is NewYorkPick3DrawStruct &&
        drawDate == other.drawDate &&
        middayDaily == other.middayDaily &&
        eveningDaily == other.eveningDaily;
  }

  @override
  int get hashCode =>
      const ListEquality().hash([drawDate, middayDaily, eveningDaily]);
}

NewYorkPick3DrawStruct createNewYorkPick3DrawStruct({
  String? drawDate,
  String? middayDaily,
  String? eveningDaily,
  Map<String, dynamic> fieldValues = const {},
  bool clearUnsetFields = true,
  bool create = false,
  bool delete = false,
}) =>
    NewYorkPick3DrawStruct(
      drawDate: drawDate,
      middayDaily: middayDaily,
      eveningDaily: eveningDaily,
      firestoreUtilData: FirestoreUtilData(
        clearUnsetFields: clearUnsetFields,
        create: create,
        delete: delete,
        fieldValues: fieldValues,
      ),
    );

NewYorkPick3DrawStruct? updateNewYorkPick3DrawStruct(
  NewYorkPick3DrawStruct? newYorkPick3Draw, {
  bool clearUnsetFields = true,
  bool create = false,
}) =>
    newYorkPick3Draw
      ?..firestoreUtilData = FirestoreUtilData(
        clearUnsetFields: clearUnsetFields,
        create: create,
      );

void addNewYorkPick3DrawStructData(
  Map<String, dynamic> firestoreData,
  NewYorkPick3DrawStruct? newYorkPick3Draw,
  String fieldName, [
  bool forFieldValue = false,
]) {
  firestoreData.remove(fieldName);
  if (newYorkPick3Draw == null) {
    return;
  }
  if (newYorkPick3Draw.firestoreUtilData.delete) {
    firestoreData[fieldName] = FieldValue.delete();
    return;
  }
  final clearFields =
      !forFieldValue && newYorkPick3Draw.firestoreUtilData.clearUnsetFields;
  if (clearFields) {
    firestoreData[fieldName] = <String, dynamic>{};
  }
  final newYorkPick3DrawData =
      getNewYorkPick3DrawFirestoreData(newYorkPick3Draw, forFieldValue);
  final nestedData =
      newYorkPick3DrawData.map((k, v) => MapEntry('$fieldName.$k', v));

  final mergeFields = newYorkPick3Draw.firestoreUtilData.create || clearFields;
  firestoreData
      .addAll(mergeFields ? mergeNestedFields(nestedData) : nestedData);
}

Map<String, dynamic> getNewYorkPick3DrawFirestoreData(
  NewYorkPick3DrawStruct? newYorkPick3Draw, [
  bool forFieldValue = false,
]) {
  if (newYorkPick3Draw == null) {
    return {};
  }
  final firestoreData = mapToFirestore(newYorkPick3Draw.toMap());

  // Add any Firestore field values
  mapToFirestore(newYorkPick3Draw.firestoreUtilData.fieldValues)
      .forEach((k, v) => firestoreData[k] = v);

  return forFieldValue ? mergeNestedFields(firestoreData) : firestoreData;
}

List<Map<String, dynamic>> getNewYorkPick3DrawListFirestoreData(
  List<NewYorkPick3DrawStruct>? newYorkPick3Draws,
) =>
    newYorkPick3Draws
        ?.map((e) => getNewYorkPick3DrawFirestoreData(e, true))
        .toList() ??
    [];
