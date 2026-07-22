// ignore_for_file: unnecessary_getters_setters

import 'package:cloud_firestore/cloud_firestore.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';
import '/backend/schema/enums/enums.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class Prediction2Struct extends FFFirebaseStruct {
  Prediction2Struct({
    String? prediction,
    List<String>? stars,
    FirestoreUtilData firestoreUtilData = const FirestoreUtilData(),
  })  : _prediction = prediction,
        _stars = stars,
        super(firestoreUtilData);

  // "prediction" field.
  String? _prediction;
  String get prediction => _prediction ?? '';
  set prediction(String? val) => _prediction = val;

  bool hasPrediction() => _prediction != null;

  // "stars" field.
  List<String>? _stars;
  List<String> get stars => _stars ?? const [];
  set stars(List<String>? val) => _stars = val;

  void updateStars(Function(List<String>) updateFn) {
    updateFn(_stars ??= []);
  }

  bool hasStars() => _stars != null;

  static Prediction2Struct fromMap(Map<String, dynamic> data) =>
      Prediction2Struct(
        prediction: data['prediction'] as String?,
        stars: getDataList(data['stars']),
      );

  static Prediction2Struct? maybeFromMap(dynamic data) => data is Map
      ? Prediction2Struct.fromMap(data.cast<String, dynamic>())
      : null;

  Map<String, dynamic> toMap() => {
        'prediction': _prediction,
        'stars': _stars,
      }.withoutNulls;

  @override
  Map<String, dynamic> toSerializableMap() => {
        'prediction': serializeParam(
          _prediction,
          ParamType.String,
        ),
        'stars': serializeParam(
          _stars,
          ParamType.String,
          isList: true,
        ),
      }.withoutNulls;

  static Prediction2Struct fromSerializableMap(Map<String, dynamic> data) =>
      Prediction2Struct(
        prediction: deserializeParam(
          data['prediction'],
          ParamType.String,
          false,
        ),
        stars: deserializeParam<String>(
          data['stars'],
          ParamType.String,
          true,
        ),
      );

  @override
  String toString() => 'Prediction2Struct(${toMap()})';

  @override
  bool operator ==(Object other) {
    const listEquality = ListEquality();
    return other is Prediction2Struct &&
        prediction == other.prediction &&
        listEquality.equals(stars, other.stars);
  }

  @override
  int get hashCode => const ListEquality().hash([prediction, stars]);
}

Prediction2Struct createPrediction2Struct({
  String? prediction,
  Map<String, dynamic> fieldValues = const {},
  bool clearUnsetFields = true,
  bool create = false,
  bool delete = false,
}) =>
    Prediction2Struct(
      prediction: prediction,
      firestoreUtilData: FirestoreUtilData(
        clearUnsetFields: clearUnsetFields,
        create: create,
        delete: delete,
        fieldValues: fieldValues,
      ),
    );

Prediction2Struct? updatePrediction2Struct(
  Prediction2Struct? prediction2, {
  bool clearUnsetFields = true,
  bool create = false,
}) =>
    prediction2
      ?..firestoreUtilData = FirestoreUtilData(
        clearUnsetFields: clearUnsetFields,
        create: create,
      );

void addPrediction2StructData(
  Map<String, dynamic> firestoreData,
  Prediction2Struct? prediction2,
  String fieldName, [
  bool forFieldValue = false,
]) {
  firestoreData.remove(fieldName);
  if (prediction2 == null) {
    return;
  }
  if (prediction2.firestoreUtilData.delete) {
    firestoreData[fieldName] = FieldValue.delete();
    return;
  }
  final clearFields =
      !forFieldValue && prediction2.firestoreUtilData.clearUnsetFields;
  if (clearFields) {
    firestoreData[fieldName] = <String, dynamic>{};
  }
  final prediction2Data =
      getPrediction2FirestoreData(prediction2, forFieldValue);
  final nestedData =
      prediction2Data.map((k, v) => MapEntry('$fieldName.$k', v));

  final mergeFields = prediction2.firestoreUtilData.create || clearFields;
  firestoreData
      .addAll(mergeFields ? mergeNestedFields(nestedData) : nestedData);
}

Map<String, dynamic> getPrediction2FirestoreData(
  Prediction2Struct? prediction2, [
  bool forFieldValue = false,
]) {
  if (prediction2 == null) {
    return {};
  }
  final firestoreData = mapToFirestore(prediction2.toMap());

  // Add any Firestore field values
  mapToFirestore(prediction2.firestoreUtilData.fieldValues)
      .forEach((k, v) => firestoreData[k] = v);

  return forFieldValue ? mergeNestedFields(firestoreData) : firestoreData;
}

List<Map<String, dynamic>> getPrediction2ListFirestoreData(
  List<Prediction2Struct>? prediction2s,
) =>
    prediction2s?.map((e) => getPrediction2FirestoreData(e, true)).toList() ??
    [];
