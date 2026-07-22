// ignore_for_file: unnecessary_getters_setters

import 'package:cloud_firestore/cloud_firestore.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';
import '/backend/schema/enums/enums.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class BingoStruct extends FFFirebaseStruct {
  BingoStruct({
    DateTime? date,
    bool? vue,
    DocumentReference? doc,
    bool? gagner,
    DocumentReference? refGain,
    List<DataStackStruct>? dataStack,
    DateTime? expiration,
    FirestoreUtilData firestoreUtilData = const FirestoreUtilData(),
  })  : _date = date,
        _vue = vue,
        _doc = doc,
        _gagner = gagner,
        _refGain = refGain,
        _dataStack = dataStack,
        _expiration = expiration,
        super(firestoreUtilData);

  // "date" field.
  DateTime? _date;
  DateTime? get date => _date;
  set date(DateTime? val) => _date = val;

  bool hasDate() => _date != null;

  // "vue" field.
  bool? _vue;
  bool get vue => _vue ?? false;
  set vue(bool? val) => _vue = val;

  bool hasVue() => _vue != null;

  // "doc" field.
  DocumentReference? _doc;
  DocumentReference? get doc => _doc;
  set doc(DocumentReference? val) => _doc = val;

  bool hasDoc() => _doc != null;

  // "gagner" field.
  bool? _gagner;
  bool get gagner => _gagner ?? false;
  set gagner(bool? val) => _gagner = val;

  bool hasGagner() => _gagner != null;

  // "refGain" field.
  DocumentReference? _refGain;
  DocumentReference? get refGain => _refGain;
  set refGain(DocumentReference? val) => _refGain = val;

  bool hasRefGain() => _refGain != null;

  // "dataStack" field.
  List<DataStackStruct>? _dataStack;
  List<DataStackStruct> get dataStack => _dataStack ?? const [];
  set dataStack(List<DataStackStruct>? val) => _dataStack = val;

  void updateDataStack(Function(List<DataStackStruct>) updateFn) {
    updateFn(_dataStack ??= []);
  }

  bool hasDataStack() => _dataStack != null;

  // "expiration" field.
  DateTime? _expiration;
  DateTime? get expiration => _expiration;
  set expiration(DateTime? val) => _expiration = val;

  bool hasExpiration() => _expiration != null;

  static BingoStruct fromMap(Map<String, dynamic> data) => BingoStruct(
        date: data['date'] as DateTime?,
        vue: data['vue'] as bool?,
        doc: data['doc'] as DocumentReference?,
        gagner: data['gagner'] as bool?,
        refGain: data['refGain'] as DocumentReference?,
        dataStack: getStructList(
          data['dataStack'],
          DataStackStruct.fromMap,
        ),
        expiration: data['expiration'] as DateTime?,
      );

  static BingoStruct? maybeFromMap(dynamic data) =>
      data is Map ? BingoStruct.fromMap(data.cast<String, dynamic>()) : null;

  Map<String, dynamic> toMap() => {
        'date': _date,
        'vue': _vue,
        'doc': _doc,
        'gagner': _gagner,
        'refGain': _refGain,
        'dataStack': _dataStack?.map((e) => e.toMap()).toList(),
        'expiration': _expiration,
      }.withoutNulls;

  @override
  Map<String, dynamic> toSerializableMap() => {
        'date': serializeParam(
          _date,
          ParamType.DateTime,
        ),
        'vue': serializeParam(
          _vue,
          ParamType.bool,
        ),
        'doc': serializeParam(
          _doc,
          ParamType.DocumentReference,
        ),
        'gagner': serializeParam(
          _gagner,
          ParamType.bool,
        ),
        'refGain': serializeParam(
          _refGain,
          ParamType.DocumentReference,
        ),
        'dataStack': serializeParam(
          _dataStack,
          ParamType.DataStruct,
          isList: true,
        ),
        'expiration': serializeParam(
          _expiration,
          ParamType.DateTime,
        ),
      }.withoutNulls;

  static BingoStruct fromSerializableMap(Map<String, dynamic> data) =>
      BingoStruct(
        date: deserializeParam(
          data['date'],
          ParamType.DateTime,
          false,
        ),
        vue: deserializeParam(
          data['vue'],
          ParamType.bool,
          false,
        ),
        doc: deserializeParam(
          data['doc'],
          ParamType.DocumentReference,
          false,
          collectionNamePath: ['bingo'],
        ),
        gagner: deserializeParam(
          data['gagner'],
          ParamType.bool,
          false,
        ),
        refGain: deserializeParam(
          data['refGain'],
          ParamType.DocumentReference,
          false,
          collectionNamePath: ['bingo', 'bingostats'],
        ),
        dataStack: deserializeStructParam<DataStackStruct>(
          data['dataStack'],
          ParamType.DataStruct,
          true,
          structBuilder: DataStackStruct.fromSerializableMap,
        ),
        expiration: deserializeParam(
          data['expiration'],
          ParamType.DateTime,
          false,
        ),
      );

  @override
  String toString() => 'BingoStruct(${toMap()})';

  @override
  bool operator ==(Object other) {
    const listEquality = ListEquality();
    return other is BingoStruct &&
        date == other.date &&
        vue == other.vue &&
        doc == other.doc &&
        gagner == other.gagner &&
        refGain == other.refGain &&
        listEquality.equals(dataStack, other.dataStack) &&
        expiration == other.expiration;
  }

  @override
  int get hashCode => const ListEquality()
      .hash([date, vue, doc, gagner, refGain, dataStack, expiration]);
}

BingoStruct createBingoStruct({
  DateTime? date,
  bool? vue,
  DocumentReference? doc,
  bool? gagner,
  DocumentReference? refGain,
  DateTime? expiration,
  Map<String, dynamic> fieldValues = const {},
  bool clearUnsetFields = true,
  bool create = false,
  bool delete = false,
}) =>
    BingoStruct(
      date: date,
      vue: vue,
      doc: doc,
      gagner: gagner,
      refGain: refGain,
      expiration: expiration,
      firestoreUtilData: FirestoreUtilData(
        clearUnsetFields: clearUnsetFields,
        create: create,
        delete: delete,
        fieldValues: fieldValues,
      ),
    );

BingoStruct? updateBingoStruct(
  BingoStruct? bingo, {
  bool clearUnsetFields = true,
  bool create = false,
}) =>
    bingo
      ?..firestoreUtilData = FirestoreUtilData(
        clearUnsetFields: clearUnsetFields,
        create: create,
      );

void addBingoStructData(
  Map<String, dynamic> firestoreData,
  BingoStruct? bingo,
  String fieldName, [
  bool forFieldValue = false,
]) {
  firestoreData.remove(fieldName);
  if (bingo == null) {
    return;
  }
  if (bingo.firestoreUtilData.delete) {
    firestoreData[fieldName] = FieldValue.delete();
    return;
  }
  final clearFields =
      !forFieldValue && bingo.firestoreUtilData.clearUnsetFields;
  if (clearFields) {
    firestoreData[fieldName] = <String, dynamic>{};
  }
  final bingoData = getBingoFirestoreData(bingo, forFieldValue);
  final nestedData = bingoData.map((k, v) => MapEntry('$fieldName.$k', v));

  final mergeFields = bingo.firestoreUtilData.create || clearFields;
  firestoreData
      .addAll(mergeFields ? mergeNestedFields(nestedData) : nestedData);
}

Map<String, dynamic> getBingoFirestoreData(
  BingoStruct? bingo, [
  bool forFieldValue = false,
]) {
  if (bingo == null) {
    return {};
  }
  final firestoreData = mapToFirestore(bingo.toMap());

  // Add any Firestore field values
  mapToFirestore(bingo.firestoreUtilData.fieldValues)
      .forEach((k, v) => firestoreData[k] = v);

  return forFieldValue ? mergeNestedFields(firestoreData) : firestoreData;
}

List<Map<String, dynamic>> getBingoListFirestoreData(
  List<BingoStruct>? bingos,
) =>
    bingos?.map((e) => getBingoFirestoreData(e, true)).toList() ?? [];
