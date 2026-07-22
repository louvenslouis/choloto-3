// ignore_for_file: unnecessary_getters_setters

import 'package:cloud_firestore/cloud_firestore.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';
import '/backend/schema/enums/enums.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class LesSaintsStruct extends FFFirebaseStruct {
  LesSaintsStruct({
    String? mois,
    List<SaintsStruct>? saints,
    FirestoreUtilData firestoreUtilData = const FirestoreUtilData(),
  })  : _mois = mois,
        _saints = saints,
        super(firestoreUtilData);

  // "mois" field.
  String? _mois;
  String get mois => _mois ?? '';
  set mois(String? val) => _mois = val;

  bool hasMois() => _mois != null;

  // "saints" field.
  List<SaintsStruct>? _saints;
  List<SaintsStruct> get saints => _saints ?? const [];
  set saints(List<SaintsStruct>? val) => _saints = val;

  void updateSaints(Function(List<SaintsStruct>) updateFn) {
    updateFn(_saints ??= []);
  }

  bool hasSaints() => _saints != null;

  static LesSaintsStruct fromMap(Map<String, dynamic> data) => LesSaintsStruct(
        mois: data['mois'] as String?,
        saints: getStructList(
          data['saints'],
          SaintsStruct.fromMap,
        ),
      );

  static LesSaintsStruct? maybeFromMap(dynamic data) => data is Map
      ? LesSaintsStruct.fromMap(data.cast<String, dynamic>())
      : null;

  Map<String, dynamic> toMap() => {
        'mois': _mois,
        'saints': _saints?.map((e) => e.toMap()).toList(),
      }.withoutNulls;

  @override
  Map<String, dynamic> toSerializableMap() => {
        'mois': serializeParam(
          _mois,
          ParamType.String,
        ),
        'saints': serializeParam(
          _saints,
          ParamType.DataStruct,
          isList: true,
        ),
      }.withoutNulls;

  static LesSaintsStruct fromSerializableMap(Map<String, dynamic> data) =>
      LesSaintsStruct(
        mois: deserializeParam(
          data['mois'],
          ParamType.String,
          false,
        ),
        saints: deserializeStructParam<SaintsStruct>(
          data['saints'],
          ParamType.DataStruct,
          true,
          structBuilder: SaintsStruct.fromSerializableMap,
        ),
      );

  @override
  String toString() => 'LesSaintsStruct(${toMap()})';

  @override
  bool operator ==(Object other) {
    const listEquality = ListEquality();
    return other is LesSaintsStruct &&
        mois == other.mois &&
        listEquality.equals(saints, other.saints);
  }

  @override
  int get hashCode => const ListEquality().hash([mois, saints]);
}

LesSaintsStruct createLesSaintsStruct({
  String? mois,
  Map<String, dynamic> fieldValues = const {},
  bool clearUnsetFields = true,
  bool create = false,
  bool delete = false,
}) =>
    LesSaintsStruct(
      mois: mois,
      firestoreUtilData: FirestoreUtilData(
        clearUnsetFields: clearUnsetFields,
        create: create,
        delete: delete,
        fieldValues: fieldValues,
      ),
    );

LesSaintsStruct? updateLesSaintsStruct(
  LesSaintsStruct? lesSaints, {
  bool clearUnsetFields = true,
  bool create = false,
}) =>
    lesSaints
      ?..firestoreUtilData = FirestoreUtilData(
        clearUnsetFields: clearUnsetFields,
        create: create,
      );

void addLesSaintsStructData(
  Map<String, dynamic> firestoreData,
  LesSaintsStruct? lesSaints,
  String fieldName, [
  bool forFieldValue = false,
]) {
  firestoreData.remove(fieldName);
  if (lesSaints == null) {
    return;
  }
  if (lesSaints.firestoreUtilData.delete) {
    firestoreData[fieldName] = FieldValue.delete();
    return;
  }
  final clearFields =
      !forFieldValue && lesSaints.firestoreUtilData.clearUnsetFields;
  if (clearFields) {
    firestoreData[fieldName] = <String, dynamic>{};
  }
  final lesSaintsData = getLesSaintsFirestoreData(lesSaints, forFieldValue);
  final nestedData = lesSaintsData.map((k, v) => MapEntry('$fieldName.$k', v));

  final mergeFields = lesSaints.firestoreUtilData.create || clearFields;
  firestoreData
      .addAll(mergeFields ? mergeNestedFields(nestedData) : nestedData);
}

Map<String, dynamic> getLesSaintsFirestoreData(
  LesSaintsStruct? lesSaints, [
  bool forFieldValue = false,
]) {
  if (lesSaints == null) {
    return {};
  }
  final firestoreData = mapToFirestore(lesSaints.toMap());

  // Add any Firestore field values
  mapToFirestore(lesSaints.firestoreUtilData.fieldValues)
      .forEach((k, v) => firestoreData[k] = v);

  return forFieldValue ? mergeNestedFields(firestoreData) : firestoreData;
}

List<Map<String, dynamic>> getLesSaintsListFirestoreData(
  List<LesSaintsStruct>? lesSaintss,
) =>
    lesSaintss?.map((e) => getLesSaintsFirestoreData(e, true)).toList() ?? [];
