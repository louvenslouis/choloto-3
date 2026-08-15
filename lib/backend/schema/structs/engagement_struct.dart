// ignore_for_file: unnecessary_getters_setters

import 'package:cloud_firestore/cloud_firestore.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';
import '/flutter_flow/flutter_flow_util.dart';

class EngagementStruct extends FFFirebaseStruct {
  EngagementStruct({
    int? currentStreak,
    int? longestStreak,
    int? totalActiveDays,
    String? lastActiveDay,
    DateTime? lastActiveAt,
    List<String>? recentActiveDays,
    int? timeZoneOffsetMinutes,
    FirestoreUtilData firestoreUtilData = const FirestoreUtilData(),
  })  : _currentStreak = currentStreak,
        _longestStreak = longestStreak,
        _totalActiveDays = totalActiveDays,
        _lastActiveDay = lastActiveDay,
        _lastActiveAt = lastActiveAt,
        _recentActiveDays = recentActiveDays,
        _timeZoneOffsetMinutes = timeZoneOffsetMinutes,
        super(firestoreUtilData);

  int? _currentStreak;
  int get currentStreak => _currentStreak ?? 0;
  set currentStreak(int? value) => _currentStreak = value;
  bool hasCurrentStreak() => _currentStreak != null;

  int? _longestStreak;
  int get longestStreak => _longestStreak ?? 0;
  set longestStreak(int? value) => _longestStreak = value;
  bool hasLongestStreak() => _longestStreak != null;

  int? _totalActiveDays;
  int get totalActiveDays => _totalActiveDays ?? 0;
  set totalActiveDays(int? value) => _totalActiveDays = value;
  bool hasTotalActiveDays() => _totalActiveDays != null;

  String? _lastActiveDay;
  String get lastActiveDay => _lastActiveDay ?? '';
  set lastActiveDay(String? value) => _lastActiveDay = value;
  bool hasLastActiveDay() => _lastActiveDay != null;

  DateTime? _lastActiveAt;
  DateTime? get lastActiveAt => _lastActiveAt;
  set lastActiveAt(DateTime? value) => _lastActiveAt = value;
  bool hasLastActiveAt() => _lastActiveAt != null;

  List<String>? _recentActiveDays;
  List<String> get recentActiveDays => _recentActiveDays ?? const [];
  set recentActiveDays(List<String>? value) => _recentActiveDays = value;
  void updateRecentActiveDays(Function(List<String>) updateFn) =>
      updateFn(_recentActiveDays ??= []);
  bool hasRecentActiveDays() => _recentActiveDays != null;

  int? _timeZoneOffsetMinutes;
  int get timeZoneOffsetMinutes => _timeZoneOffsetMinutes ?? 0;
  set timeZoneOffsetMinutes(int? value) => _timeZoneOffsetMinutes = value;
  bool hasTimeZoneOffsetMinutes() => _timeZoneOffsetMinutes != null;

  static EngagementStruct fromMap(Map<String, dynamic> data) =>
      EngagementStruct(
        currentStreak: castToType<int>(data['currentStreak']),
        longestStreak: castToType<int>(data['longestStreak']),
        totalActiveDays: castToType<int>(data['totalActiveDays']),
        lastActiveDay: data['lastActiveDay'] as String?,
        lastActiveAt: data['lastActiveAt'] as DateTime?,
        recentActiveDays: getDataList(data['recentActiveDays']),
        timeZoneOffsetMinutes: castToType<int>(data['timeZoneOffsetMinutes']),
      );

  static EngagementStruct? maybeFromMap(dynamic data) => data is Map
      ? EngagementStruct.fromMap(data.cast<String, dynamic>())
      : null;

  Map<String, dynamic> toMap() => {
        'currentStreak': _currentStreak,
        'longestStreak': _longestStreak,
        'totalActiveDays': _totalActiveDays,
        'lastActiveDay': _lastActiveDay,
        'lastActiveAt': _lastActiveAt,
        'recentActiveDays': _recentActiveDays,
        'timeZoneOffsetMinutes': _timeZoneOffsetMinutes,
      }.withoutNulls;

  @override
  Map<String, dynamic> toSerializableMap() => {
        'currentStreak': serializeParam(_currentStreak, ParamType.int),
        'longestStreak': serializeParam(_longestStreak, ParamType.int),
        'totalActiveDays': serializeParam(_totalActiveDays, ParamType.int),
        'lastActiveDay': serializeParam(_lastActiveDay, ParamType.String),
        'lastActiveAt': serializeParam(_lastActiveAt, ParamType.DateTime),
        'recentActiveDays':
            serializeParam(_recentActiveDays, ParamType.String, isList: true),
        'timeZoneOffsetMinutes':
            serializeParam(_timeZoneOffsetMinutes, ParamType.int),
      }.withoutNulls;

  static EngagementStruct fromSerializableMap(Map<String, dynamic> data) =>
      EngagementStruct(
        currentStreak:
            deserializeParam(data['currentStreak'], ParamType.int, false),
        longestStreak:
            deserializeParam(data['longestStreak'], ParamType.int, false),
        totalActiveDays:
            deserializeParam(data['totalActiveDays'], ParamType.int, false),
        lastActiveDay:
            deserializeParam(data['lastActiveDay'], ParamType.String, false),
        lastActiveAt:
            deserializeParam(data['lastActiveAt'], ParamType.DateTime, false),
        recentActiveDays: deserializeParam<String>(
          data['recentActiveDays'],
          ParamType.String,
          true,
        ),
        timeZoneOffsetMinutes: deserializeParam(
          data['timeZoneOffsetMinutes'],
          ParamType.int,
          false,
        ),
      );

  @override
  String toString() => 'EngagementStruct(${toMap()})';

  @override
  bool operator ==(Object other) =>
      other is EngagementStruct &&
      currentStreak == other.currentStreak &&
      longestStreak == other.longestStreak &&
      totalActiveDays == other.totalActiveDays &&
      lastActiveDay == other.lastActiveDay &&
      lastActiveAt == other.lastActiveAt &&
      const ListEquality<String>()
          .equals(recentActiveDays, other.recentActiveDays) &&
      timeZoneOffsetMinutes == other.timeZoneOffsetMinutes;

  @override
  int get hashCode => const ListEquality<Object?>().hash([
        currentStreak,
        longestStreak,
        totalActiveDays,
        lastActiveDay,
        lastActiveAt,
        recentActiveDays,
        timeZoneOffsetMinutes,
      ]);
}

void addEngagementStructData(
  Map<String, dynamic> firestoreData,
  EngagementStruct? engagement,
  String fieldName, [
  bool forFieldValue = false,
]) {
  firestoreData.remove(fieldName);
  if (engagement == null) {
    return;
  }
  if (engagement.firestoreUtilData.delete) {
    firestoreData[fieldName] = FieldValue.delete();
    return;
  }

  final clearFields =
      !forFieldValue && engagement.firestoreUtilData.clearUnsetFields;
  if (clearFields) {
    firestoreData[fieldName] = <String, dynamic>{};
  }
  final engagementData = getEngagementFirestoreData(engagement, forFieldValue);
  final nestedData =
      engagementData.map((key, value) => MapEntry('$fieldName.$key', value));
  final mergeFields = engagement.firestoreUtilData.create || clearFields;
  firestoreData
      .addAll(mergeFields ? mergeNestedFields(nestedData) : nestedData);
}

Map<String, dynamic> getEngagementFirestoreData(
  EngagementStruct? engagement, [
  bool forFieldValue = false,
]) {
  if (engagement == null) {
    return {};
  }
  final firestoreData = mapToFirestore(engagement.toMap());
  mapToFirestore(engagement.firestoreUtilData.fieldValues)
      .forEach((key, value) => firestoreData[key] = value);
  return forFieldValue ? mergeNestedFields(firestoreData) : firestoreData;
}
