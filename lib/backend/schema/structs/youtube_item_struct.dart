// ignore_for_file: unnecessary_getters_setters

import 'package:cloud_firestore/cloud_firestore.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';
import '/backend/schema/enums/enums.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

/// DSL struct YoutubeItem
class YoutubeItemStruct extends FFFirebaseStruct {
  YoutubeItemStruct({
    /// YoutubeItem.title
    String? title,

    /// YoutubeItem.link
    String? link,

    /// YoutubeItem.thumbnail
    String? thumbnail,

    /// YoutubeItem.pubDate
    String? pubDate,
    FirestoreUtilData firestoreUtilData = const FirestoreUtilData(),
  })  : _title = title,
        _link = link,
        _thumbnail = thumbnail,
        _pubDate = pubDate,
        super(firestoreUtilData);

  // "title" field.
  String? _title;
  String get title => _title ?? '';
  set title(String? val) => _title = val;

  bool hasTitle() => _title != null;

  // "link" field.
  String? _link;
  String get link => _link ?? '';
  set link(String? val) => _link = val;

  bool hasLink() => _link != null;

  // "thumbnail" field.
  String? _thumbnail;
  String get thumbnail => _thumbnail ?? '';
  set thumbnail(String? val) => _thumbnail = val;

  bool hasThumbnail() => _thumbnail != null;

  // "pubDate" field.
  String? _pubDate;
  String get pubDate => _pubDate ?? '';
  set pubDate(String? val) => _pubDate = val;

  bool hasPubDate() => _pubDate != null;

  static YoutubeItemStruct fromMap(Map<String, dynamic> data) =>
      YoutubeItemStruct(
        title: data['title'] as String?,
        link: data['link'] as String?,
        thumbnail: data['thumbnail'] as String?,
        pubDate: data['pubDate'] as String?,
      );

  static YoutubeItemStruct? maybeFromMap(dynamic data) => data is Map
      ? YoutubeItemStruct.fromMap(data.cast<String, dynamic>())
      : null;

  Map<String, dynamic> toMap() => {
        'title': _title,
        'link': _link,
        'thumbnail': _thumbnail,
        'pubDate': _pubDate,
      }.withoutNulls;

  @override
  Map<String, dynamic> toSerializableMap() => {
        'title': serializeParam(
          _title,
          ParamType.String,
        ),
        'link': serializeParam(
          _link,
          ParamType.String,
        ),
        'thumbnail': serializeParam(
          _thumbnail,
          ParamType.String,
        ),
        'pubDate': serializeParam(
          _pubDate,
          ParamType.String,
        ),
      }.withoutNulls;

  static YoutubeItemStruct fromSerializableMap(Map<String, dynamic> data) =>
      YoutubeItemStruct(
        title: deserializeParam(
          data['title'],
          ParamType.String,
          false,
        ),
        link: deserializeParam(
          data['link'],
          ParamType.String,
          false,
        ),
        thumbnail: deserializeParam(
          data['thumbnail'],
          ParamType.String,
          false,
        ),
        pubDate: deserializeParam(
          data['pubDate'],
          ParamType.String,
          false,
        ),
      );

  @override
  String toString() => 'YoutubeItemStruct(${toMap()})';

  @override
  bool operator ==(Object other) {
    return other is YoutubeItemStruct &&
        title == other.title &&
        link == other.link &&
        thumbnail == other.thumbnail &&
        pubDate == other.pubDate;
  }

  @override
  int get hashCode =>
      const ListEquality().hash([title, link, thumbnail, pubDate]);
}

YoutubeItemStruct createYoutubeItemStruct({
  String? title,
  String? link,
  String? thumbnail,
  String? pubDate,
  Map<String, dynamic> fieldValues = const {},
  bool clearUnsetFields = true,
  bool create = false,
  bool delete = false,
}) =>
    YoutubeItemStruct(
      title: title,
      link: link,
      thumbnail: thumbnail,
      pubDate: pubDate,
      firestoreUtilData: FirestoreUtilData(
        clearUnsetFields: clearUnsetFields,
        create: create,
        delete: delete,
        fieldValues: fieldValues,
      ),
    );

YoutubeItemStruct? updateYoutubeItemStruct(
  YoutubeItemStruct? youtubeItem, {
  bool clearUnsetFields = true,
  bool create = false,
}) =>
    youtubeItem
      ?..firestoreUtilData = FirestoreUtilData(
        clearUnsetFields: clearUnsetFields,
        create: create,
      );

void addYoutubeItemStructData(
  Map<String, dynamic> firestoreData,
  YoutubeItemStruct? youtubeItem,
  String fieldName, [
  bool forFieldValue = false,
]) {
  firestoreData.remove(fieldName);
  if (youtubeItem == null) {
    return;
  }
  if (youtubeItem.firestoreUtilData.delete) {
    firestoreData[fieldName] = FieldValue.delete();
    return;
  }
  final clearFields =
      !forFieldValue && youtubeItem.firestoreUtilData.clearUnsetFields;
  if (clearFields) {
    firestoreData[fieldName] = <String, dynamic>{};
  }
  final youtubeItemData =
      getYoutubeItemFirestoreData(youtubeItem, forFieldValue);
  final nestedData =
      youtubeItemData.map((k, v) => MapEntry('$fieldName.$k', v));

  final mergeFields = youtubeItem.firestoreUtilData.create || clearFields;
  firestoreData
      .addAll(mergeFields ? mergeNestedFields(nestedData) : nestedData);
}

Map<String, dynamic> getYoutubeItemFirestoreData(
  YoutubeItemStruct? youtubeItem, [
  bool forFieldValue = false,
]) {
  if (youtubeItem == null) {
    return {};
  }
  final firestoreData = mapToFirestore(youtubeItem.toMap());

  // Add any Firestore field values
  mapToFirestore(youtubeItem.firestoreUtilData.fieldValues)
      .forEach((k, v) => firestoreData[k] = v);

  return forFieldValue ? mergeNestedFields(firestoreData) : firestoreData;
}

List<Map<String, dynamic>> getYoutubeItemListFirestoreData(
  List<YoutubeItemStruct>? youtubeItems,
) =>
    youtubeItems?.map((e) => getYoutubeItemFirestoreData(e, true)).toList() ??
    [];
