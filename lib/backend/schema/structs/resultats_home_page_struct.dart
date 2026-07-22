// ignore_for_file: unnecessary_getters_setters

import 'package:cloud_firestore/cloud_firestore.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';
import '/backend/schema/enums/enums.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class ResultatsHomePageStruct extends FFFirebaseStruct {
  ResultatsHomePageStruct({
    DateTime? temps,
    List<String>? numero,
    String? periode,
    String? tirage,
    int? expiration,
    FirestoreUtilData firestoreUtilData = const FirestoreUtilData(),
  })  : _temps = temps,
        _numero = numero,
        _periode = periode,
        _tirage = tirage,
        _expiration = expiration,
        super(firestoreUtilData);

  // "temps" field.
  DateTime? _temps;
  DateTime? get temps => _temps;
  set temps(DateTime? val) => _temps = val;

  bool hasTemps() => _temps != null;

  // "numero" field.
  List<String>? _numero;
  List<String> get numero => _numero ?? const [];
  set numero(List<String>? val) => _numero = val;

  void updateNumero(Function(List<String>) updateFn) {
    updateFn(_numero ??= []);
  }

  bool hasNumero() => _numero != null;

  // "periode" field.
  String? _periode;
  String get periode => _periode ?? '';
  set periode(String? val) => _periode = val;

  bool hasPeriode() => _periode != null;

  // "tirage" field.
  String? _tirage;
  String get tirage => _tirage ?? '';
  set tirage(String? val) => _tirage = val;

  bool hasTirage() => _tirage != null;

  // "expiration" field.
  int? _expiration;
  int get expiration => _expiration ?? 18;
  set expiration(int? val) => _expiration = val;

  void incrementExpiration(int amount) => expiration = expiration + amount;

  bool hasExpiration() => _expiration != null;

  static ResultatsHomePageStruct fromMap(Map<String, dynamic> data) =>
      ResultatsHomePageStruct(
        temps: data['temps'] as DateTime?,
        numero: getDataList(data['numero']),
        periode: data['periode'] as String?,
        tirage: data['tirage'] as String?,
        expiration: castToType<int>(data['expiration']),
      );

  static ResultatsHomePageStruct? maybeFromMap(dynamic data) => data is Map
      ? ResultatsHomePageStruct.fromMap(data.cast<String, dynamic>())
      : null;

  Map<String, dynamic> toMap() => {
        'temps': _temps,
        'numero': _numero,
        'periode': _periode,
        'tirage': _tirage,
        'expiration': _expiration,
      }.withoutNulls;

  @override
  Map<String, dynamic> toSerializableMap() => {
        'temps': serializeParam(
          _temps,
          ParamType.DateTime,
        ),
        'numero': serializeParam(
          _numero,
          ParamType.String,
          isList: true,
        ),
        'periode': serializeParam(
          _periode,
          ParamType.String,
        ),
        'tirage': serializeParam(
          _tirage,
          ParamType.String,
        ),
        'expiration': serializeParam(
          _expiration,
          ParamType.int,
        ),
      }.withoutNulls;

  static ResultatsHomePageStruct fromSerializableMap(
          Map<String, dynamic> data) =>
      ResultatsHomePageStruct(
        temps: deserializeParam(
          data['temps'],
          ParamType.DateTime,
          false,
        ),
        numero: deserializeParam<String>(
          data['numero'],
          ParamType.String,
          true,
        ),
        periode: deserializeParam(
          data['periode'],
          ParamType.String,
          false,
        ),
        tirage: deserializeParam(
          data['tirage'],
          ParamType.String,
          false,
        ),
        expiration: deserializeParam(
          data['expiration'],
          ParamType.int,
          false,
        ),
      );

  @override
  String toString() => 'ResultatsHomePageStruct(${toMap()})';

  @override
  bool operator ==(Object other) {
    const listEquality = ListEquality();
    return other is ResultatsHomePageStruct &&
        temps == other.temps &&
        listEquality.equals(numero, other.numero) &&
        periode == other.periode &&
        tirage == other.tirage &&
        expiration == other.expiration;
  }

  @override
  int get hashCode =>
      const ListEquality().hash([temps, numero, periode, tirage, expiration]);
}

ResultatsHomePageStruct createResultatsHomePageStruct({
  DateTime? temps,
  String? periode,
  String? tirage,
  int? expiration,
  Map<String, dynamic> fieldValues = const {},
  bool clearUnsetFields = true,
  bool create = false,
  bool delete = false,
}) =>
    ResultatsHomePageStruct(
      temps: temps,
      periode: periode,
      tirage: tirage,
      expiration: expiration,
      firestoreUtilData: FirestoreUtilData(
        clearUnsetFields: clearUnsetFields,
        create: create,
        delete: delete,
        fieldValues: fieldValues,
      ),
    );

ResultatsHomePageStruct? updateResultatsHomePageStruct(
  ResultatsHomePageStruct? resultatsHomePage, {
  bool clearUnsetFields = true,
  bool create = false,
}) =>
    resultatsHomePage
      ?..firestoreUtilData = FirestoreUtilData(
        clearUnsetFields: clearUnsetFields,
        create: create,
      );

void addResultatsHomePageStructData(
  Map<String, dynamic> firestoreData,
  ResultatsHomePageStruct? resultatsHomePage,
  String fieldName, [
  bool forFieldValue = false,
]) {
  firestoreData.remove(fieldName);
  if (resultatsHomePage == null) {
    return;
  }
  if (resultatsHomePage.firestoreUtilData.delete) {
    firestoreData[fieldName] = FieldValue.delete();
    return;
  }
  final clearFields =
      !forFieldValue && resultatsHomePage.firestoreUtilData.clearUnsetFields;
  if (clearFields) {
    firestoreData[fieldName] = <String, dynamic>{};
  }
  final resultatsHomePageData =
      getResultatsHomePageFirestoreData(resultatsHomePage, forFieldValue);
  final nestedData =
      resultatsHomePageData.map((k, v) => MapEntry('$fieldName.$k', v));

  final mergeFields = resultatsHomePage.firestoreUtilData.create || clearFields;
  firestoreData
      .addAll(mergeFields ? mergeNestedFields(nestedData) : nestedData);
}

Map<String, dynamic> getResultatsHomePageFirestoreData(
  ResultatsHomePageStruct? resultatsHomePage, [
  bool forFieldValue = false,
]) {
  if (resultatsHomePage == null) {
    return {};
  }
  final firestoreData = mapToFirestore(resultatsHomePage.toMap());

  // Add any Firestore field values
  mapToFirestore(resultatsHomePage.firestoreUtilData.fieldValues)
      .forEach((k, v) => firestoreData[k] = v);

  return forFieldValue ? mergeNestedFields(firestoreData) : firestoreData;
}

List<Map<String, dynamic>> getResultatsHomePageListFirestoreData(
  List<ResultatsHomePageStruct>? resultatsHomePages,
) =>
    resultatsHomePages
        ?.map((e) => getResultatsHomePageFirestoreData(e, true))
        .toList() ??
    [];
