// ignore_for_file: unnecessary_getters_setters

import 'package:cloud_firestore/cloud_firestore.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';
import '/backend/schema/enums/enums.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

/// DSL struct FloridaDrawNumber
class FloridaDrawNumberStruct extends FFFirebaseStruct {
  FloridaDrawNumberStruct({
    /// FloridaDrawNumber.NumberPick
    int? numberPick,

    /// FloridaDrawNumber.NumberType
    String? numberType,
    FirestoreUtilData firestoreUtilData = const FirestoreUtilData(),
  })  : _numberPick = numberPick,
        _numberType = numberType,
        super(firestoreUtilData);

  // "NumberPick" field.
  int? _numberPick;
  int get numberPick => _numberPick ?? 0;
  set numberPick(int? val) => _numberPick = val;

  void incrementNumberPick(int amount) => numberPick = numberPick + amount;

  bool hasNumberPick() => _numberPick != null;

  // "NumberType" field.
  String? _numberType;
  String get numberType => _numberType ?? '';
  set numberType(String? val) => _numberType = val;

  bool hasNumberType() => _numberType != null;

  static FloridaDrawNumberStruct fromMap(Map<String, dynamic> data) =>
      FloridaDrawNumberStruct(
        numberPick: castToType<int>(data['NumberPick']),
        numberType: data['NumberType'] as String?,
      );

  static FloridaDrawNumberStruct? maybeFromMap(dynamic data) => data is Map
      ? FloridaDrawNumberStruct.fromMap(data.cast<String, dynamic>())
      : null;

  Map<String, dynamic> toMap() => {
        'NumberPick': _numberPick,
        'NumberType': _numberType,
      }.withoutNulls;

  @override
  Map<String, dynamic> toSerializableMap() => {
        'NumberPick': serializeParam(
          _numberPick,
          ParamType.int,
        ),
        'NumberType': serializeParam(
          _numberType,
          ParamType.String,
        ),
      }.withoutNulls;

  static FloridaDrawNumberStruct fromSerializableMap(
          Map<String, dynamic> data) =>
      FloridaDrawNumberStruct(
        numberPick: deserializeParam(
          data['NumberPick'],
          ParamType.int,
          false,
        ),
        numberType: deserializeParam(
          data['NumberType'],
          ParamType.String,
          false,
        ),
      );

  @override
  String toString() => 'FloridaDrawNumberStruct(${toMap()})';

  @override
  bool operator ==(Object other) {
    return other is FloridaDrawNumberStruct &&
        numberPick == other.numberPick &&
        numberType == other.numberType;
  }

  @override
  int get hashCode => const ListEquality().hash([numberPick, numberType]);
}

FloridaDrawNumberStruct createFloridaDrawNumberStruct({
  int? numberPick,
  String? numberType,
  Map<String, dynamic> fieldValues = const {},
  bool clearUnsetFields = true,
  bool create = false,
  bool delete = false,
}) =>
    FloridaDrawNumberStruct(
      numberPick: numberPick,
      numberType: numberType,
      firestoreUtilData: FirestoreUtilData(
        clearUnsetFields: clearUnsetFields,
        create: create,
        delete: delete,
        fieldValues: fieldValues,
      ),
    );

FloridaDrawNumberStruct? updateFloridaDrawNumberStruct(
  FloridaDrawNumberStruct? floridaDrawNumber, {
  bool clearUnsetFields = true,
  bool create = false,
}) =>
    floridaDrawNumber
      ?..firestoreUtilData = FirestoreUtilData(
        clearUnsetFields: clearUnsetFields,
        create: create,
      );

void addFloridaDrawNumberStructData(
  Map<String, dynamic> firestoreData,
  FloridaDrawNumberStruct? floridaDrawNumber,
  String fieldName, [
  bool forFieldValue = false,
]) {
  firestoreData.remove(fieldName);
  if (floridaDrawNumber == null) {
    return;
  }
  if (floridaDrawNumber.firestoreUtilData.delete) {
    firestoreData[fieldName] = FieldValue.delete();
    return;
  }
  final clearFields =
      !forFieldValue && floridaDrawNumber.firestoreUtilData.clearUnsetFields;
  if (clearFields) {
    firestoreData[fieldName] = <String, dynamic>{};
  }
  final floridaDrawNumberData =
      getFloridaDrawNumberFirestoreData(floridaDrawNumber, forFieldValue);
  final nestedData =
      floridaDrawNumberData.map((k, v) => MapEntry('$fieldName.$k', v));

  final mergeFields = floridaDrawNumber.firestoreUtilData.create || clearFields;
  firestoreData
      .addAll(mergeFields ? mergeNestedFields(nestedData) : nestedData);
}

Map<String, dynamic> getFloridaDrawNumberFirestoreData(
  FloridaDrawNumberStruct? floridaDrawNumber, [
  bool forFieldValue = false,
]) {
  if (floridaDrawNumber == null) {
    return {};
  }
  final firestoreData = mapToFirestore(floridaDrawNumber.toMap());

  // Add any Firestore field values
  mapToFirestore(floridaDrawNumber.firestoreUtilData.fieldValues)
      .forEach((k, v) => firestoreData[k] = v);

  return forFieldValue ? mergeNestedFields(firestoreData) : firestoreData;
}

List<Map<String, dynamic>> getFloridaDrawNumberListFirestoreData(
  List<FloridaDrawNumberStruct>? floridaDrawNumbers,
) =>
    floridaDrawNumbers
        ?.map((e) => getFloridaDrawNumberFirestoreData(e, true))
        .toList() ??
    [];
