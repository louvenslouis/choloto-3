// ignore_for_file: unnecessary_getters_setters

import 'package:cloud_firestore/cloud_firestore.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';
import '/backend/schema/enums/enums.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

/// DSL struct FloridaPick4Draw
class FloridaPick4DrawStruct extends FFFirebaseStruct {
  FloridaPick4DrawStruct({
    /// FloridaPick4Draw.Id
    String? id,

    /// FloridaPick4Draw.GameName
    String? gameName,

    /// FloridaPick4Draw.DrawDate
    String? drawDate,

    /// FloridaPick4Draw.DrawType
    String? drawType,

    /// FloridaPick4Draw.DrawNumbers
    List<FloridaDrawNumberStruct>? drawNumbers,
    FirestoreUtilData firestoreUtilData = const FirestoreUtilData(),
  })  : _id = id,
        _gameName = gameName,
        _drawDate = drawDate,
        _drawType = drawType,
        _drawNumbers = drawNumbers,
        super(firestoreUtilData);

  // "Id" field.
  String? _id;
  String get id => _id ?? '';
  set id(String? val) => _id = val;

  bool hasId() => _id != null;

  // "GameName" field.
  String? _gameName;
  String get gameName => _gameName ?? '';
  set gameName(String? val) => _gameName = val;

  bool hasGameName() => _gameName != null;

  // "DrawDate" field.
  String? _drawDate;
  String get drawDate => _drawDate ?? '';
  set drawDate(String? val) => _drawDate = val;

  bool hasDrawDate() => _drawDate != null;

  // "DrawType" field.
  String? _drawType;
  String get drawType => _drawType ?? '';
  set drawType(String? val) => _drawType = val;

  bool hasDrawType() => _drawType != null;

  // "DrawNumbers" field.
  List<FloridaDrawNumberStruct>? _drawNumbers;
  List<FloridaDrawNumberStruct> get drawNumbers => _drawNumbers ?? const [];
  set drawNumbers(List<FloridaDrawNumberStruct>? val) => _drawNumbers = val;

  void updateDrawNumbers(Function(List<FloridaDrawNumberStruct>) updateFn) {
    updateFn(_drawNumbers ??= []);
  }

  bool hasDrawNumbers() => _drawNumbers != null;

  static FloridaPick4DrawStruct fromMap(Map<String, dynamic> data) =>
      FloridaPick4DrawStruct(
        id: data['Id'] as String?,
        gameName: data['GameName'] as String?,
        drawDate: data['DrawDate'] as String?,
        drawType: data['DrawType'] as String?,
        drawNumbers: getStructList(
          data['DrawNumbers'],
          FloridaDrawNumberStruct.fromMap,
        ),
      );

  static FloridaPick4DrawStruct? maybeFromMap(dynamic data) => data is Map
      ? FloridaPick4DrawStruct.fromMap(data.cast<String, dynamic>())
      : null;

  Map<String, dynamic> toMap() => {
        'Id': _id,
        'GameName': _gameName,
        'DrawDate': _drawDate,
        'DrawType': _drawType,
        'DrawNumbers': _drawNumbers?.map((e) => e.toMap()).toList(),
      }.withoutNulls;

  @override
  Map<String, dynamic> toSerializableMap() => {
        'Id': serializeParam(
          _id,
          ParamType.String,
        ),
        'GameName': serializeParam(
          _gameName,
          ParamType.String,
        ),
        'DrawDate': serializeParam(
          _drawDate,
          ParamType.String,
        ),
        'DrawType': serializeParam(
          _drawType,
          ParamType.String,
        ),
        'DrawNumbers': serializeParam(
          _drawNumbers,
          ParamType.DataStruct,
          isList: true,
        ),
      }.withoutNulls;

  static FloridaPick4DrawStruct fromSerializableMap(
          Map<String, dynamic> data) =>
      FloridaPick4DrawStruct(
        id: deserializeParam(
          data['Id'],
          ParamType.String,
          false,
        ),
        gameName: deserializeParam(
          data['GameName'],
          ParamType.String,
          false,
        ),
        drawDate: deserializeParam(
          data['DrawDate'],
          ParamType.String,
          false,
        ),
        drawType: deserializeParam(
          data['DrawType'],
          ParamType.String,
          false,
        ),
        drawNumbers: deserializeStructParam<FloridaDrawNumberStruct>(
          data['DrawNumbers'],
          ParamType.DataStruct,
          true,
          structBuilder: FloridaDrawNumberStruct.fromSerializableMap,
        ),
      );

  @override
  String toString() => 'FloridaPick4DrawStruct(${toMap()})';

  @override
  bool operator ==(Object other) {
    const listEquality = ListEquality();
    return other is FloridaPick4DrawStruct &&
        id == other.id &&
        gameName == other.gameName &&
        drawDate == other.drawDate &&
        drawType == other.drawType &&
        listEquality.equals(drawNumbers, other.drawNumbers);
  }

  @override
  int get hashCode => const ListEquality()
      .hash([id, gameName, drawDate, drawType, drawNumbers]);
}

FloridaPick4DrawStruct createFloridaPick4DrawStruct({
  String? id,
  String? gameName,
  String? drawDate,
  String? drawType,
  Map<String, dynamic> fieldValues = const {},
  bool clearUnsetFields = true,
  bool create = false,
  bool delete = false,
}) =>
    FloridaPick4DrawStruct(
      id: id,
      gameName: gameName,
      drawDate: drawDate,
      drawType: drawType,
      firestoreUtilData: FirestoreUtilData(
        clearUnsetFields: clearUnsetFields,
        create: create,
        delete: delete,
        fieldValues: fieldValues,
      ),
    );

FloridaPick4DrawStruct? updateFloridaPick4DrawStruct(
  FloridaPick4DrawStruct? floridaPick4Draw, {
  bool clearUnsetFields = true,
  bool create = false,
}) =>
    floridaPick4Draw
      ?..firestoreUtilData = FirestoreUtilData(
        clearUnsetFields: clearUnsetFields,
        create: create,
      );

void addFloridaPick4DrawStructData(
  Map<String, dynamic> firestoreData,
  FloridaPick4DrawStruct? floridaPick4Draw,
  String fieldName, [
  bool forFieldValue = false,
]) {
  firestoreData.remove(fieldName);
  if (floridaPick4Draw == null) {
    return;
  }
  if (floridaPick4Draw.firestoreUtilData.delete) {
    firestoreData[fieldName] = FieldValue.delete();
    return;
  }
  final clearFields =
      !forFieldValue && floridaPick4Draw.firestoreUtilData.clearUnsetFields;
  if (clearFields) {
    firestoreData[fieldName] = <String, dynamic>{};
  }
  final floridaPick4DrawData =
      getFloridaPick4DrawFirestoreData(floridaPick4Draw, forFieldValue);
  final nestedData =
      floridaPick4DrawData.map((k, v) => MapEntry('$fieldName.$k', v));

  final mergeFields = floridaPick4Draw.firestoreUtilData.create || clearFields;
  firestoreData
      .addAll(mergeFields ? mergeNestedFields(nestedData) : nestedData);
}

Map<String, dynamic> getFloridaPick4DrawFirestoreData(
  FloridaPick4DrawStruct? floridaPick4Draw, [
  bool forFieldValue = false,
]) {
  if (floridaPick4Draw == null) {
    return {};
  }
  final firestoreData = mapToFirestore(floridaPick4Draw.toMap());

  // Add any Firestore field values
  mapToFirestore(floridaPick4Draw.firestoreUtilData.fieldValues)
      .forEach((k, v) => firestoreData[k] = v);

  return forFieldValue ? mergeNestedFields(firestoreData) : firestoreData;
}

List<Map<String, dynamic>> getFloridaPick4DrawListFirestoreData(
  List<FloridaPick4DrawStruct>? floridaPick4Draws,
) =>
    floridaPick4Draws
        ?.map((e) => getFloridaPick4DrawFirestoreData(e, true))
        .toList() ??
    [];
