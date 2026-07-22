// ignore_for_file: unnecessary_getters_setters

import 'package:cloud_firestore/cloud_firestore.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';
import '/backend/schema/enums/enums.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class BetaFeaturesStruct extends FFFirebaseStruct {
  BetaFeaturesStruct({
    bool? stories,
    bool? statsBingo,
    FirestoreUtilData firestoreUtilData = const FirestoreUtilData(),
  })  : _stories = stories,
        _statsBingo = statsBingo,
        super(firestoreUtilData);

  // "stories" field.
  bool? _stories;
  bool get stories => _stories ?? false;
  set stories(bool? val) => _stories = val;

  bool hasStories() => _stories != null;

  // "statsBingo" field.
  bool? _statsBingo;
  bool get statsBingo => _statsBingo ?? false;
  set statsBingo(bool? val) => _statsBingo = val;

  bool hasStatsBingo() => _statsBingo != null;

  static BetaFeaturesStruct fromMap(Map<String, dynamic> data) =>
      BetaFeaturesStruct(
        stories: data['stories'] as bool?,
        statsBingo: data['statsBingo'] as bool?,
      );

  static BetaFeaturesStruct? maybeFromMap(dynamic data) => data is Map
      ? BetaFeaturesStruct.fromMap(data.cast<String, dynamic>())
      : null;

  Map<String, dynamic> toMap() => {
        'stories': _stories,
        'statsBingo': _statsBingo,
      }.withoutNulls;

  @override
  Map<String, dynamic> toSerializableMap() => {
        'stories': serializeParam(
          _stories,
          ParamType.bool,
        ),
        'statsBingo': serializeParam(
          _statsBingo,
          ParamType.bool,
        ),
      }.withoutNulls;

  static BetaFeaturesStruct fromSerializableMap(Map<String, dynamic> data) =>
      BetaFeaturesStruct(
        stories: deserializeParam(
          data['stories'],
          ParamType.bool,
          false,
        ),
        statsBingo: deserializeParam(
          data['statsBingo'],
          ParamType.bool,
          false,
        ),
      );

  @override
  String toString() => 'BetaFeaturesStruct(${toMap()})';

  @override
  bool operator ==(Object other) {
    return other is BetaFeaturesStruct &&
        stories == other.stories &&
        statsBingo == other.statsBingo;
  }

  @override
  int get hashCode => const ListEquality().hash([stories, statsBingo]);
}

BetaFeaturesStruct createBetaFeaturesStruct({
  bool? stories,
  bool? statsBingo,
  Map<String, dynamic> fieldValues = const {},
  bool clearUnsetFields = true,
  bool create = false,
  bool delete = false,
}) =>
    BetaFeaturesStruct(
      stories: stories,
      statsBingo: statsBingo,
      firestoreUtilData: FirestoreUtilData(
        clearUnsetFields: clearUnsetFields,
        create: create,
        delete: delete,
        fieldValues: fieldValues,
      ),
    );

BetaFeaturesStruct? updateBetaFeaturesStruct(
  BetaFeaturesStruct? betaFeatures, {
  bool clearUnsetFields = true,
  bool create = false,
}) =>
    betaFeatures
      ?..firestoreUtilData = FirestoreUtilData(
        clearUnsetFields: clearUnsetFields,
        create: create,
      );

void addBetaFeaturesStructData(
  Map<String, dynamic> firestoreData,
  BetaFeaturesStruct? betaFeatures,
  String fieldName, [
  bool forFieldValue = false,
]) {
  firestoreData.remove(fieldName);
  if (betaFeatures == null) {
    return;
  }
  if (betaFeatures.firestoreUtilData.delete) {
    firestoreData[fieldName] = FieldValue.delete();
    return;
  }
  final clearFields =
      !forFieldValue && betaFeatures.firestoreUtilData.clearUnsetFields;
  if (clearFields) {
    firestoreData[fieldName] = <String, dynamic>{};
  }
  final betaFeaturesData =
      getBetaFeaturesFirestoreData(betaFeatures, forFieldValue);
  final nestedData =
      betaFeaturesData.map((k, v) => MapEntry('$fieldName.$k', v));

  final mergeFields = betaFeatures.firestoreUtilData.create || clearFields;
  firestoreData
      .addAll(mergeFields ? mergeNestedFields(nestedData) : nestedData);
}

Map<String, dynamic> getBetaFeaturesFirestoreData(
  BetaFeaturesStruct? betaFeatures, [
  bool forFieldValue = false,
]) {
  if (betaFeatures == null) {
    return {};
  }
  final firestoreData = mapToFirestore(betaFeatures.toMap());

  // Add any Firestore field values
  mapToFirestore(betaFeatures.firestoreUtilData.fieldValues)
      .forEach((k, v) => firestoreData[k] = v);

  return forFieldValue ? mergeNestedFields(firestoreData) : firestoreData;
}

List<Map<String, dynamic>> getBetaFeaturesListFirestoreData(
  List<BetaFeaturesStruct>? betaFeaturess,
) =>
    betaFeaturess?.map((e) => getBetaFeaturesFirestoreData(e, true)).toList() ??
    [];
