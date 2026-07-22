// ignore_for_file: unnecessary_getters_setters

import 'package:cloud_firestore/cloud_firestore.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';
import '/backend/schema/enums/enums.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class StoriesStruct extends FFFirebaseStruct {
  StoriesStruct({
    DocumentReference? bingo,
    DocumentReference? youtubeLinks,
    String? id,
    bool? vue,
    DateTime? expiration,
    String? postText,
    FirestoreUtilData firestoreUtilData = const FirestoreUtilData(),
  })  : _bingo = bingo,
        _youtubeLinks = youtubeLinks,
        _id = id,
        _vue = vue,
        _expiration = expiration,
        _postText = postText,
        super(firestoreUtilData);

  // "bingo" field.
  DocumentReference? _bingo;
  DocumentReference? get bingo => _bingo;
  set bingo(DocumentReference? val) => _bingo = val;

  bool hasBingo() => _bingo != null;

  // "youtubeLinks" field.
  DocumentReference? _youtubeLinks;
  DocumentReference? get youtubeLinks => _youtubeLinks;
  set youtubeLinks(DocumentReference? val) => _youtubeLinks = val;

  bool hasYoutubeLinks() => _youtubeLinks != null;

  // "id" field.
  String? _id;
  String get id => _id ?? '';
  set id(String? val) => _id = val;

  bool hasId() => _id != null;

  // "vue" field.
  bool? _vue;
  bool get vue => _vue ?? false;
  set vue(bool? val) => _vue = val;

  bool hasVue() => _vue != null;

  // "expiration" field.
  DateTime? _expiration;
  DateTime? get expiration => _expiration;
  set expiration(DateTime? val) => _expiration = val;

  bool hasExpiration() => _expiration != null;

  // "postText" field.
  String? _postText;
  String get postText => _postText ?? '';
  set postText(String? val) => _postText = val;

  bool hasPostText() => _postText != null;

  static StoriesStruct fromMap(Map<String, dynamic> data) => StoriesStruct(
        bingo: data['bingo'] as DocumentReference?,
        youtubeLinks: data['youtubeLinks'] as DocumentReference?,
        id: data['id'] as String?,
        vue: data['vue'] as bool?,
        expiration: data['expiration'] as DateTime?,
        postText: data['postText'] as String?,
      );

  static StoriesStruct? maybeFromMap(dynamic data) =>
      data is Map ? StoriesStruct.fromMap(data.cast<String, dynamic>()) : null;

  Map<String, dynamic> toMap() => {
        'bingo': _bingo,
        'youtubeLinks': _youtubeLinks,
        'id': _id,
        'vue': _vue,
        'expiration': _expiration,
        'postText': _postText,
      }.withoutNulls;

  @override
  Map<String, dynamic> toSerializableMap() => {
        'bingo': serializeParam(
          _bingo,
          ParamType.DocumentReference,
        ),
        'youtubeLinks': serializeParam(
          _youtubeLinks,
          ParamType.DocumentReference,
        ),
        'id': serializeParam(
          _id,
          ParamType.String,
        ),
        'vue': serializeParam(
          _vue,
          ParamType.bool,
        ),
        'expiration': serializeParam(
          _expiration,
          ParamType.DateTime,
        ),
        'postText': serializeParam(
          _postText,
          ParamType.String,
        ),
      }.withoutNulls;

  static StoriesStruct fromSerializableMap(Map<String, dynamic> data) =>
      StoriesStruct(
        bingo: deserializeParam(
          data['bingo'],
          ParamType.DocumentReference,
          false,
          collectionNamePath: ['bingo'],
        ),
        youtubeLinks: deserializeParam(
          data['youtubeLinks'],
          ParamType.DocumentReference,
          false,
          collectionNamePath: ['youtubeLinks'],
        ),
        id: deserializeParam(
          data['id'],
          ParamType.String,
          false,
        ),
        vue: deserializeParam(
          data['vue'],
          ParamType.bool,
          false,
        ),
        expiration: deserializeParam(
          data['expiration'],
          ParamType.DateTime,
          false,
        ),
        postText: deserializeParam(
          data['postText'],
          ParamType.String,
          false,
        ),
      );

  @override
  String toString() => 'StoriesStruct(${toMap()})';

  @override
  bool operator ==(Object other) {
    return other is StoriesStruct &&
        bingo == other.bingo &&
        youtubeLinks == other.youtubeLinks &&
        id == other.id &&
        vue == other.vue &&
        expiration == other.expiration &&
        postText == other.postText;
  }

  @override
  int get hashCode => const ListEquality()
      .hash([bingo, youtubeLinks, id, vue, expiration, postText]);
}

StoriesStruct createStoriesStruct({
  DocumentReference? bingo,
  DocumentReference? youtubeLinks,
  String? id,
  bool? vue,
  DateTime? expiration,
  String? postText,
  Map<String, dynamic> fieldValues = const {},
  bool clearUnsetFields = true,
  bool create = false,
  bool delete = false,
}) =>
    StoriesStruct(
      bingo: bingo,
      youtubeLinks: youtubeLinks,
      id: id,
      vue: vue,
      expiration: expiration,
      postText: postText,
      firestoreUtilData: FirestoreUtilData(
        clearUnsetFields: clearUnsetFields,
        create: create,
        delete: delete,
        fieldValues: fieldValues,
      ),
    );

StoriesStruct? updateStoriesStruct(
  StoriesStruct? stories, {
  bool clearUnsetFields = true,
  bool create = false,
}) =>
    stories
      ?..firestoreUtilData = FirestoreUtilData(
        clearUnsetFields: clearUnsetFields,
        create: create,
      );

void addStoriesStructData(
  Map<String, dynamic> firestoreData,
  StoriesStruct? stories,
  String fieldName, [
  bool forFieldValue = false,
]) {
  firestoreData.remove(fieldName);
  if (stories == null) {
    return;
  }
  if (stories.firestoreUtilData.delete) {
    firestoreData[fieldName] = FieldValue.delete();
    return;
  }
  final clearFields =
      !forFieldValue && stories.firestoreUtilData.clearUnsetFields;
  if (clearFields) {
    firestoreData[fieldName] = <String, dynamic>{};
  }
  final storiesData = getStoriesFirestoreData(stories, forFieldValue);
  final nestedData = storiesData.map((k, v) => MapEntry('$fieldName.$k', v));

  final mergeFields = stories.firestoreUtilData.create || clearFields;
  firestoreData
      .addAll(mergeFields ? mergeNestedFields(nestedData) : nestedData);
}

Map<String, dynamic> getStoriesFirestoreData(
  StoriesStruct? stories, [
  bool forFieldValue = false,
]) {
  if (stories == null) {
    return {};
  }
  final firestoreData = mapToFirestore(stories.toMap());

  // Add any Firestore field values
  mapToFirestore(stories.firestoreUtilData.fieldValues)
      .forEach((k, v) => firestoreData[k] = v);

  return forFieldValue ? mergeNestedFields(firestoreData) : firestoreData;
}

List<Map<String, dynamic>> getStoriesListFirestoreData(
  List<StoriesStruct>? storiess,
) =>
    storiess?.map((e) => getStoriesFirestoreData(e, true)).toList() ?? [];
