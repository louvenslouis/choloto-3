import 'package:flutter/material.dart';
import 'flutter_flow/request_manager.dart';
import '/backend/backend.dart';
import '/backend/schema/structs/index.dart';
import '/backend/schema/enums/enums.dart';
import '/backend/api_requests/api_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'flutter_flow/flutter_flow_util.dart';
import 'dart:convert';

class FFAppState extends ChangeNotifier {
  static FFAppState _instance = FFAppState._internal();

  factory FFAppState() {
    return _instance;
  }

  FFAppState._internal();

  static void reset() {
    _instance = FFAppState._internal();
  }

  Future initializePersistedState() async {
    prefs = await SharedPreferences.getInstance();
    _safeInit(() {
      if (prefs.containsKey('ff_okay')) {
        try {
          _okay = jsonDecode(prefs.getString('ff_okay') ?? '');
        } catch (e) {
          print("Can't decode persisted json. Error: $e.");
        }
      }
    });
    _safeInit(() {
      _subscriber = prefs.containsKey('ff_subscriber')
          ? DateTime.fromMillisecondsSinceEpoch(prefs.getInt('ff_subscriber')!)
          : _subscriber;
    });
    _safeInit(() {
      _user = prefs.getString('ff_user') ?? _user;
    });
    _safeInit(() {
      if (prefs.containsKey('ff_bingo')) {
        try {
          final serializedData = prefs.getString('ff_bingo') ?? '{}';
          _bingo = BingoStruct.fromSerializableMap(jsonDecode(serializedData));
        } catch (e) {
          print("Can't decode persisted data type. Error: $e.");
        }
      }
    });
    _safeInit(() {
      _haiti = prefs
              .getStringList('ff_haiti')
              ?.map((x) => DateTime.fromMillisecondsSinceEpoch(int.parse(x)))
              .toList() ??
          _haiti;
    });
    _safeInit(() {
      if (prefs.containsKey('ff_betaFeatures')) {
        try {
          final serializedData = prefs.getString('ff_betaFeatures') ?? '{}';
          _betaFeatures = BetaFeaturesStruct.fromSerializableMap(
              jsonDecode(serializedData));
        } catch (e) {
          print("Can't decode persisted data type. Error: $e.");
        }
      }
    });
  }

  void update(VoidCallback callback) {
    callback();
    notifyListeners();
  }

  late SharedPreferences prefs;

  dynamic _okay;
  dynamic get okay => _okay;
  set okay(dynamic value) {
    _okay = value;
    prefs.setString('ff_okay', jsonEncode(value));
  }

  DateTime? _subscriber;
  DateTime? get subscriber => _subscriber;
  set subscriber(DateTime? value) {
    _subscriber = value;
    value != null
        ? prefs.setInt('ff_subscriber', value.millisecondsSinceEpoch)
        : prefs.remove('ff_subscriber');
  }

  String _user = 'Invité';
  String get user => _user;
  set user(String value) {
    _user = value;
    prefs.setString('ff_user', value);
  }

  BingoStruct _bingo = BingoStruct();
  BingoStruct get bingo => _bingo;
  set bingo(BingoStruct value) {
    _bingo = value;
    prefs.setString('ff_bingo', value.serialize());
  }

  void updateBingoStruct(Function(BingoStruct) updateFn) {
    updateFn(_bingo);
    prefs.setString('ff_bingo', _bingo.serialize());
  }

  List<DateTime> _haiti = [
    DateTime.fromMillisecondsSinceEpoch(1781323200000),
    DateTime.fromMillisecondsSinceEpoch(1781150400000),
    DateTime.fromMillisecondsSinceEpoch(1781841600000),
    DateTime.fromMillisecondsSinceEpoch(1782273600000)
  ];
  List<DateTime> get haiti => _haiti;
  set haiti(List<DateTime> value) {
    _haiti = value;
    prefs.setStringList('ff_haiti',
        value.map((x) => x.millisecondsSinceEpoch.toString()).toList());
  }

  void addToHaiti(DateTime value) {
    haiti.add(value);
    prefs.setStringList('ff_haiti',
        _haiti.map((x) => x.millisecondsSinceEpoch.toString()).toList());
  }

  void removeFromHaiti(DateTime value) {
    haiti.remove(value);
    prefs.setStringList('ff_haiti',
        _haiti.map((x) => x.millisecondsSinceEpoch.toString()).toList());
  }

  void removeAtIndexFromHaiti(int index) {
    haiti.removeAt(index);
    prefs.setStringList('ff_haiti',
        _haiti.map((x) => x.millisecondsSinceEpoch.toString()).toList());
  }

  void updateHaitiAtIndex(
    int index,
    DateTime Function(DateTime) updateFn,
  ) {
    haiti[index] = updateFn(_haiti[index]);
    prefs.setStringList('ff_haiti',
        _haiti.map((x) => x.millisecondsSinceEpoch.toString()).toList());
  }

  void insertAtIndexInHaiti(int index, DateTime value) {
    haiti.insert(index, value);
    prefs.setStringList('ff_haiti',
        _haiti.map((x) => x.millisecondsSinceEpoch.toString()).toList());
  }

  List<StoriesStruct> _stories = [];
  List<StoriesStruct> get stories => _stories;
  set stories(List<StoriesStruct> value) {
    _stories = value;
  }

  void addToStories(StoriesStruct value) {
    stories.add(value);
  }

  void removeFromStories(StoriesStruct value) {
    stories.remove(value);
  }

  void removeAtIndexFromStories(int index) {
    stories.removeAt(index);
  }

  void updateStoriesAtIndex(
    int index,
    StoriesStruct Function(StoriesStruct) updateFn,
  ) {
    stories[index] = updateFn(_stories[index]);
  }

  void insertAtIndexInStories(int index, StoriesStruct value) {
    stories.insert(index, value);
  }

  BetaFeaturesStruct _betaFeatures = BetaFeaturesStruct.fromSerializableMap(
      jsonDecode('{\"stories\":\"false\"}'));
  BetaFeaturesStruct get betaFeatures => _betaFeatures;
  set betaFeatures(BetaFeaturesStruct value) {
    _betaFeatures = value;
    prefs.setString('ff_betaFeatures', value.serialize());
  }

  void updateBetaFeaturesStruct(Function(BetaFeaturesStruct) updateFn) {
    updateFn(_betaFeatures);
    prefs.setString('ff_betaFeatures', _betaFeatures.serialize());
  }

  final _newYorkTirageManager = FutureRequestManager<List<ResultatsRecord>>();
  Future<List<ResultatsRecord>> newYorkTirage({
    String? uniqueQueryKey,
    bool? overrideCache,
    required Future<List<ResultatsRecord>> Function() requestFn,
  }) =>
      _newYorkTirageManager.performRequest(
        uniqueQueryKey: uniqueQueryKey,
        overrideCache: overrideCache,
        requestFn: requestFn,
      );
  void clearNewYorkTirageCache() => _newYorkTirageManager.clear();
  void clearNewYorkTirageCacheKey(String? uniqueKey) =>
      _newYorkTirageManager.clearRequest(uniqueKey);

  final _floridaTirageManager = FutureRequestManager<List<ResultatsRecord>>();
  Future<List<ResultatsRecord>> floridaTirage({
    String? uniqueQueryKey,
    bool? overrideCache,
    required Future<List<ResultatsRecord>> Function() requestFn,
  }) =>
      _floridaTirageManager.performRequest(
        uniqueQueryKey: uniqueQueryKey,
        overrideCache: overrideCache,
        requestFn: requestFn,
      );
  void clearFloridaTirageCache() => _floridaTirageManager.clear();
  void clearFloridaTirageCacheKey(String? uniqueKey) =>
      _floridaTirageManager.clearRequest(uniqueKey);
}

void _safeInit(Function() initializeField) {
  try {
    initializeField();
  } catch (_) {}
}

Future _safeInitAsync(Function() initializeField) async {
  try {
    await initializeField();
  } catch (_) {}
}
