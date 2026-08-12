import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

const _tchalaAssetPath = 'assets/jsons/tchala.json';

/// Loads the read-only Tchala catalogue once and keeps the typed result in
/// memory for every subsequent visit to the page.
class TchalaDataRepository {
  TchalaDataRepository({AssetBundle? bundle}) : _bundle = bundle ?? rootBundle;

  final AssetBundle _bundle;
  Future<TchalaData>? _cachedLoad;

  Future<TchalaData> load() => _cachedLoad ??= _loadFromAsset();

  Future<TchalaData> reload() {
    _cachedLoad = _loadFromAsset();
    return _cachedLoad!;
  }

  Future<TchalaData> _loadFromAsset() async {
    // This repository already caches the typed catalogue, so retaining a
    // second copy of the raw JSON string would waste memory.
    final source = await _bundle.loadString(_tchalaAssetPath, cache: false);
    return TchalaData.fromJson(jsonDecode(source));
  }
}

final tchalaDataRepository = TchalaDataRepository();

@immutable
class TchalaData {
  const TchalaData({required this.symbols, required this.saintMonths});

  final List<TchalaEntry> symbols;
  final List<SaintMonth> saintMonths;

  factory TchalaData.fromJson(Object? json) {
    final map = _asMap(json, 'tchala');
    final saintMonthsJson = _asList(map['saint_months'], 'saint_months');
    return TchalaData(
      symbols: List.unmodifiable(
        _asList(map['symbols'], 'symbols').map(TchalaEntry.fromJson),
      ),
      saintMonths: List.unmodifiable(
        List.generate(
          saintMonthsJson.length,
          (index) => SaintMonth.fromJson(
            saintMonthsJson[index],
            fallbackMonthNumber: index + 1,
          ),
        ),
      ),
    );
  }
}

@immutable
class TchalaEntry {
  const TchalaEntry({
    required this.creoleSymbol,
    required this.frenchTranslation,
    required this.englishTranslation,
    required this.associatedNumbers,
  });

  final String creoleSymbol;
  final String frenchTranslation;
  final String englishTranslation;
  final List<int> associatedNumbers;

  factory TchalaEntry.fromJson(Object? json) {
    final map = _asMap(json, 'symbol');
    return TchalaEntry(
      creoleSymbol: _asString(map['symbole_kreyol'], 'symbole_kreyol'),
      frenchTranslation:
          _asString(map['traduction_francais'], 'traduction_francais'),
      englishTranslation:
          _asString(map['traduction_anglais'], 'traduction_anglais'),
      associatedNumbers: List.unmodifiable(
        _asList(map['numeros_associes'], 'numeros_associes')
            .map((value) => _asInt(value, 'numeros_associes')),
      ),
    );
  }
}

@immutable
class SaintMonth {
  const SaintMonth({
    required this.name,
    required this.monthNumber,
    required this.saints,
  });

  final String name;
  final int monthNumber;
  final List<SaintEntry> saints;

  factory SaintMonth.fromJson(
    Object? json, {
    required int fallbackMonthNumber,
  }) {
    final map = _asMap(json, 'saint_month');
    final saints = List<SaintEntry>.unmodifiable(
      _asList(map['saints'], 'saints').map(SaintEntry.fromJson),
    );
    return SaintMonth(
      name: _asString(map['mois'], 'mois'),
      monthNumber: _monthNumberFromSaints(saints) ?? fallbackMonthNumber,
      saints: saints,
    );
  }
}

@immutable
class SaintEntry {
  const SaintEntry({required this.name, required this.date});

  final String name;
  final String date;

  factory SaintEntry.fromJson(Object? json) {
    final map = _asMap(json, 'saint');
    return SaintEntry(
      name: _asString(map['saint'], 'saint'),
      date: _asString(map['date'], 'date'),
    );
  }
}

Map<String, dynamic> _asMap(Object? value, String field) {
  if (value is Map<String, dynamic>) {
    return value;
  }
  throw FormatException('$field must be a JSON object.');
}

List<dynamic> _asList(Object? value, String field) {
  if (value is List<dynamic>) {
    return value;
  }
  throw FormatException('$field must be a JSON array.');
}

String _asString(Object? value, String field) {
  if (value is String) {
    return value;
  }
  throw FormatException('$field must be a string.');
}

int _asInt(Object? value, String field) {
  if (value is int) {
    return value;
  }
  throw FormatException('$field must be an integer.');
}

int? _monthNumberFromSaints(List<SaintEntry> saints) {
  for (final saint in saints) {
    final date = DateTime.tryParse(saint.date);
    if (date != null) {
      return date.month;
    }
  }
  return null;
}
