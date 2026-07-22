// ignore_for_file: unnecessary_getters_setters

import 'package:cloud_firestore/cloud_firestore.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';
import '/backend/schema/enums/enums.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class TchalaStruct extends FFFirebaseStruct {
  TchalaStruct({
    String? symboleKreyol,
    String? traductionFrancais,
    List<int>? numerosAssocies,
    FirestoreUtilData firestoreUtilData = const FirestoreUtilData(),
  })  : _symboleKreyol = symboleKreyol,
        _traductionFrancais = traductionFrancais,
        _numerosAssocies = numerosAssocies,
        super(firestoreUtilData);

  // "symbole_kreyol" field.
  String? _symboleKreyol;
  String get symboleKreyol => _symboleKreyol ?? '';
  set symboleKreyol(String? val) => _symboleKreyol = val;

  bool hasSymboleKreyol() => _symboleKreyol != null;

  // "traduction_francais" field.
  String? _traductionFrancais;
  String get traductionFrancais => _traductionFrancais ?? '';
  set traductionFrancais(String? val) => _traductionFrancais = val;

  bool hasTraductionFrancais() => _traductionFrancais != null;

  // "numeros_associes" field.
  List<int>? _numerosAssocies;
  List<int> get numerosAssocies => _numerosAssocies ?? const [];
  set numerosAssocies(List<int>? val) => _numerosAssocies = val;

  void updateNumerosAssocies(Function(List<int>) updateFn) {
    updateFn(_numerosAssocies ??= []);
  }

  bool hasNumerosAssocies() => _numerosAssocies != null;

  static TchalaStruct fromMap(Map<String, dynamic> data) => TchalaStruct(
        symboleKreyol: data['symbole_kreyol'] as String?,
        traductionFrancais: data['traduction_francais'] as String?,
        numerosAssocies: getDataList(data['numeros_associes']),
      );

  static TchalaStruct? maybeFromMap(dynamic data) =>
      data is Map ? TchalaStruct.fromMap(data.cast<String, dynamic>()) : null;

  Map<String, dynamic> toMap() => {
        'symbole_kreyol': _symboleKreyol,
        'traduction_francais': _traductionFrancais,
        'numeros_associes': _numerosAssocies,
      }.withoutNulls;

  @override
  Map<String, dynamic> toSerializableMap() => {
        'symbole_kreyol': serializeParam(
          _symboleKreyol,
          ParamType.String,
        ),
        'traduction_francais': serializeParam(
          _traductionFrancais,
          ParamType.String,
        ),
        'numeros_associes': serializeParam(
          _numerosAssocies,
          ParamType.int,
          isList: true,
        ),
      }.withoutNulls;

  static TchalaStruct fromSerializableMap(Map<String, dynamic> data) =>
      TchalaStruct(
        symboleKreyol: deserializeParam(
          data['symbole_kreyol'],
          ParamType.String,
          false,
        ),
        traductionFrancais: deserializeParam(
          data['traduction_francais'],
          ParamType.String,
          false,
        ),
        numerosAssocies: deserializeParam<int>(
          data['numeros_associes'],
          ParamType.int,
          true,
        ),
      );

  @override
  String toString() => 'TchalaStruct(${toMap()})';

  @override
  bool operator ==(Object other) {
    const listEquality = ListEquality();
    return other is TchalaStruct &&
        symboleKreyol == other.symboleKreyol &&
        traductionFrancais == other.traductionFrancais &&
        listEquality.equals(numerosAssocies, other.numerosAssocies);
  }

  @override
  int get hashCode => const ListEquality()
      .hash([symboleKreyol, traductionFrancais, numerosAssocies]);
}

TchalaStruct createTchalaStruct({
  String? symboleKreyol,
  String? traductionFrancais,
  Map<String, dynamic> fieldValues = const {},
  bool clearUnsetFields = true,
  bool create = false,
  bool delete = false,
}) =>
    TchalaStruct(
      symboleKreyol: symboleKreyol,
      traductionFrancais: traductionFrancais,
      firestoreUtilData: FirestoreUtilData(
        clearUnsetFields: clearUnsetFields,
        create: create,
        delete: delete,
        fieldValues: fieldValues,
      ),
    );

TchalaStruct? updateTchalaStruct(
  TchalaStruct? tchala, {
  bool clearUnsetFields = true,
  bool create = false,
}) =>
    tchala
      ?..firestoreUtilData = FirestoreUtilData(
        clearUnsetFields: clearUnsetFields,
        create: create,
      );

void addTchalaStructData(
  Map<String, dynamic> firestoreData,
  TchalaStruct? tchala,
  String fieldName, [
  bool forFieldValue = false,
]) {
  firestoreData.remove(fieldName);
  if (tchala == null) {
    return;
  }
  if (tchala.firestoreUtilData.delete) {
    firestoreData[fieldName] = FieldValue.delete();
    return;
  }
  final clearFields =
      !forFieldValue && tchala.firestoreUtilData.clearUnsetFields;
  if (clearFields) {
    firestoreData[fieldName] = <String, dynamic>{};
  }
  final tchalaData = getTchalaFirestoreData(tchala, forFieldValue);
  final nestedData = tchalaData.map((k, v) => MapEntry('$fieldName.$k', v));

  final mergeFields = tchala.firestoreUtilData.create || clearFields;
  firestoreData
      .addAll(mergeFields ? mergeNestedFields(nestedData) : nestedData);
}

Map<String, dynamic> getTchalaFirestoreData(
  TchalaStruct? tchala, [
  bool forFieldValue = false,
]) {
  if (tchala == null) {
    return {};
  }
  final firestoreData = mapToFirestore(tchala.toMap());

  // Add any Firestore field values
  mapToFirestore(tchala.firestoreUtilData.fieldValues)
      .forEach((k, v) => firestoreData[k] = v);

  return forFieldValue ? mergeNestedFields(firestoreData) : firestoreData;
}

List<Map<String, dynamic>> getTchalaListFirestoreData(
  List<TchalaStruct>? tchalas,
) =>
    tchalas?.map((e) => getTchalaFirestoreData(e, true)).toList() ?? [];
