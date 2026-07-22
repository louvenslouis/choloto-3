// ignore_for_file: unnecessary_getters_setters

import 'package:cloud_firestore/cloud_firestore.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';
import '/backend/schema/enums/enums.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class UserStatsStruct extends FFFirebaseStruct {
  UserStatsStruct({
    int? bingoGain,
    int? bingoRater,
    FirestoreUtilData firestoreUtilData = const FirestoreUtilData(),
  })  : _bingoGain = bingoGain,
        _bingoRater = bingoRater,
        super(firestoreUtilData);

  // "bingoGain" field.
  int? _bingoGain;
  int get bingoGain => _bingoGain ?? 0;
  set bingoGain(int? val) => _bingoGain = val;

  void incrementBingoGain(int amount) => bingoGain = bingoGain + amount;

  bool hasBingoGain() => _bingoGain != null;

  // "bingoRater" field.
  int? _bingoRater;
  int get bingoRater => _bingoRater ?? 0;
  set bingoRater(int? val) => _bingoRater = val;

  void incrementBingoRater(int amount) => bingoRater = bingoRater + amount;

  bool hasBingoRater() => _bingoRater != null;

  static UserStatsStruct fromMap(Map<String, dynamic> data) => UserStatsStruct(
        bingoGain: castToType<int>(data['bingoGain']),
        bingoRater: castToType<int>(data['bingoRater']),
      );

  static UserStatsStruct? maybeFromMap(dynamic data) => data is Map
      ? UserStatsStruct.fromMap(data.cast<String, dynamic>())
      : null;

  Map<String, dynamic> toMap() => {
        'bingoGain': _bingoGain,
        'bingoRater': _bingoRater,
      }.withoutNulls;

  @override
  Map<String, dynamic> toSerializableMap() => {
        'bingoGain': serializeParam(
          _bingoGain,
          ParamType.int,
        ),
        'bingoRater': serializeParam(
          _bingoRater,
          ParamType.int,
        ),
      }.withoutNulls;

  static UserStatsStruct fromSerializableMap(Map<String, dynamic> data) =>
      UserStatsStruct(
        bingoGain: deserializeParam(
          data['bingoGain'],
          ParamType.int,
          false,
        ),
        bingoRater: deserializeParam(
          data['bingoRater'],
          ParamType.int,
          false,
        ),
      );

  @override
  String toString() => 'UserStatsStruct(${toMap()})';

  @override
  bool operator ==(Object other) {
    return other is UserStatsStruct &&
        bingoGain == other.bingoGain &&
        bingoRater == other.bingoRater;
  }

  @override
  int get hashCode => const ListEquality().hash([bingoGain, bingoRater]);
}

UserStatsStruct createUserStatsStruct({
  int? bingoGain,
  int? bingoRater,
  Map<String, dynamic> fieldValues = const {},
  bool clearUnsetFields = true,
  bool create = false,
  bool delete = false,
}) =>
    UserStatsStruct(
      bingoGain: bingoGain,
      bingoRater: bingoRater,
      firestoreUtilData: FirestoreUtilData(
        clearUnsetFields: clearUnsetFields,
        create: create,
        delete: delete,
        fieldValues: fieldValues,
      ),
    );

UserStatsStruct? updateUserStatsStruct(
  UserStatsStruct? userStats, {
  bool clearUnsetFields = true,
  bool create = false,
}) =>
    userStats
      ?..firestoreUtilData = FirestoreUtilData(
        clearUnsetFields: clearUnsetFields,
        create: create,
      );

void addUserStatsStructData(
  Map<String, dynamic> firestoreData,
  UserStatsStruct? userStats,
  String fieldName, [
  bool forFieldValue = false,
]) {
  firestoreData.remove(fieldName);
  if (userStats == null) {
    return;
  }
  if (userStats.firestoreUtilData.delete) {
    firestoreData[fieldName] = FieldValue.delete();
    return;
  }
  final clearFields =
      !forFieldValue && userStats.firestoreUtilData.clearUnsetFields;
  if (clearFields) {
    firestoreData[fieldName] = <String, dynamic>{};
  }
  final userStatsData = getUserStatsFirestoreData(userStats, forFieldValue);
  final nestedData = userStatsData.map((k, v) => MapEntry('$fieldName.$k', v));

  final mergeFields = userStats.firestoreUtilData.create || clearFields;
  firestoreData
      .addAll(mergeFields ? mergeNestedFields(nestedData) : nestedData);
}

Map<String, dynamic> getUserStatsFirestoreData(
  UserStatsStruct? userStats, [
  bool forFieldValue = false,
]) {
  if (userStats == null) {
    return {};
  }
  final firestoreData = mapToFirestore(userStats.toMap());

  // Add any Firestore field values
  mapToFirestore(userStats.firestoreUtilData.fieldValues)
      .forEach((k, v) => firestoreData[k] = v);

  return forFieldValue ? mergeNestedFields(firestoreData) : firestoreData;
}

List<Map<String, dynamic>> getUserStatsListFirestoreData(
  List<UserStatsStruct>? userStatss,
) =>
    userStatss?.map((e) => getUserStatsFirestoreData(e, true)).toList() ?? [];
