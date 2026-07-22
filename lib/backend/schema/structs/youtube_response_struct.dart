// ignore_for_file: unnecessary_getters_setters

import 'package:cloud_firestore/cloud_firestore.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';
import '/backend/schema/enums/enums.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

/// DSL struct YoutubeResponse
class YoutubeResponseStruct extends FFFirebaseStruct {
  YoutubeResponseStruct({
    /// YoutubeResponse.items
    List<YoutubeItemStruct>? items,
    FirestoreUtilData firestoreUtilData = const FirestoreUtilData(),
  })  : _items = items,
        super(firestoreUtilData);

  // "items" field.
  List<YoutubeItemStruct>? _items;
  List<YoutubeItemStruct> get items => _items ?? const [];
  set items(List<YoutubeItemStruct>? val) => _items = val;

  void updateItems(Function(List<YoutubeItemStruct>) updateFn) {
    updateFn(_items ??= []);
  }

  bool hasItems() => _items != null;

  static YoutubeResponseStruct fromMap(Map<String, dynamic> data) =>
      YoutubeResponseStruct(
        items: getStructList(
          data['items'],
          YoutubeItemStruct.fromMap,
        ),
      );

  static YoutubeResponseStruct? maybeFromMap(dynamic data) => data is Map
      ? YoutubeResponseStruct.fromMap(data.cast<String, dynamic>())
      : null;

  Map<String, dynamic> toMap() => {
        'items': _items?.map((e) => e.toMap()).toList(),
      }.withoutNulls;

  @override
  Map<String, dynamic> toSerializableMap() => {
        'items': serializeParam(
          _items,
          ParamType.DataStruct,
          isList: true,
        ),
      }.withoutNulls;

  static YoutubeResponseStruct fromSerializableMap(Map<String, dynamic> data) =>
      YoutubeResponseStruct(
        items: deserializeStructParam<YoutubeItemStruct>(
          data['items'],
          ParamType.DataStruct,
          true,
          structBuilder: YoutubeItemStruct.fromSerializableMap,
        ),
      );

  @override
  String toString() => 'YoutubeResponseStruct(${toMap()})';

  @override
  bool operator ==(Object other) {
    const listEquality = ListEquality();
    return other is YoutubeResponseStruct &&
        listEquality.equals(items, other.items);
  }

  @override
  int get hashCode => const ListEquality().hash([items]);
}

YoutubeResponseStruct createYoutubeResponseStruct({
  Map<String, dynamic> fieldValues = const {},
  bool clearUnsetFields = true,
  bool create = false,
  bool delete = false,
}) =>
    YoutubeResponseStruct(
      firestoreUtilData: FirestoreUtilData(
        clearUnsetFields: clearUnsetFields,
        create: create,
        delete: delete,
        fieldValues: fieldValues,
      ),
    );

YoutubeResponseStruct? updateYoutubeResponseStruct(
  YoutubeResponseStruct? youtubeResponse, {
  bool clearUnsetFields = true,
  bool create = false,
}) =>
    youtubeResponse
      ?..firestoreUtilData = FirestoreUtilData(
        clearUnsetFields: clearUnsetFields,
        create: create,
      );

void addYoutubeResponseStructData(
  Map<String, dynamic> firestoreData,
  YoutubeResponseStruct? youtubeResponse,
  String fieldName, [
  bool forFieldValue = false,
]) {
  firestoreData.remove(fieldName);
  if (youtubeResponse == null) {
    return;
  }
  if (youtubeResponse.firestoreUtilData.delete) {
    firestoreData[fieldName] = FieldValue.delete();
    return;
  }
  final clearFields =
      !forFieldValue && youtubeResponse.firestoreUtilData.clearUnsetFields;
  if (clearFields) {
    firestoreData[fieldName] = <String, dynamic>{};
  }
  final youtubeResponseData =
      getYoutubeResponseFirestoreData(youtubeResponse, forFieldValue);
  final nestedData =
      youtubeResponseData.map((k, v) => MapEntry('$fieldName.$k', v));

  final mergeFields = youtubeResponse.firestoreUtilData.create || clearFields;
  firestoreData
      .addAll(mergeFields ? mergeNestedFields(nestedData) : nestedData);
}

Map<String, dynamic> getYoutubeResponseFirestoreData(
  YoutubeResponseStruct? youtubeResponse, [
  bool forFieldValue = false,
]) {
  if (youtubeResponse == null) {
    return {};
  }
  final firestoreData = mapToFirestore(youtubeResponse.toMap());

  // Add any Firestore field values
  mapToFirestore(youtubeResponse.firestoreUtilData.fieldValues)
      .forEach((k, v) => firestoreData[k] = v);

  return forFieldValue ? mergeNestedFields(firestoreData) : firestoreData;
}

List<Map<String, dynamic>> getYoutubeResponseListFirestoreData(
  List<YoutubeResponseStruct>? youtubeResponses,
) =>
    youtubeResponses
        ?.map((e) => getYoutubeResponseFirestoreData(e, true))
        .toList() ??
    [];
