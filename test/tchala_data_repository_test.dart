import 'dart:convert';

import 'package:choloto/tchala/tchala_data_repository.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('loads and validates the bundled Tchala catalogue', () async {
    final data = await TchalaDataRepository().load();

    expect(data.symbols, hasLength(259));
    expect(data.symbols.first.creoleSymbol, 'Achte');
    expect(data.symbols.first.englishTranslation, 'Purchase');
    expect(
      data.symbols.map((symbol) => symbol.englishTranslation),
      everyElement(isNotEmpty),
    );
    expect(data.symbols.first.associatedNumbers, [55, 7, 76, 36]);
    expect(data.saintMonths, hasLength(12));
    expect(
      data.saintMonths.map((month) => month.monthNumber),
      orderedEquals(List.generate(12, (index) => index + 1)),
    );
  });

  test('has named celebrations in all languages for every recurring day',
      () async {
    final data = await TchalaDataRepository().load();
    for (final month in data.saintMonths) {
      final daysInMonth = DateTime.utc(2024, month.monthNumber + 1, 0).day;
      final days = <int>[];
      for (final saint in month.saints) {
        final date = DateTime.parse(saint.date);
        expect(date.month, month.monthNumber);
        expect(date.toIso8601String().split('T').first, saint.date);
        days.add(date.day);
        expect(saint.name.trim(), isNotEmpty);
        expect(saint.englishName?.trim() ?? '', isNotEmpty);
        expect(saint.creoleName?.trim() ?? '', isNotEmpty);
      }
      expect(days, orderedEquals([...days]..sort()));
      expect(days.toSet(), {for (var day = 1; day <= daysInMonth; day++) day});
    }
  });

  test('retains multiple feasts and the Haitian patronal celebration',
      () async {
    final months = (await TchalaDataRepository().load()).saintMonths;
    final november24 = months[10]
        .saints
        .where((saint) => saint.date.endsWith('-11-24'))
        .toList();
    expect(november24.map((s) => s.localizedName('en')), const [
      'Andrew Dũng-Lạc and companions',
      'Flora and Mary of Córdoba',
    ]);
    expect(november24.first.localizedName('cr'),
        'Andre Dũng-Lạc ak konpayon li yo');
    expect(
        months[5]
            .saints
            .where((s) => s.date.endsWith('-06-27'))
            .map((s) => s.localizedName('ht')),
        contains('Manman Pèpetyèl Sekou'));
    final francis =
        months[0].saints.singleWhere((s) => s.name == 'François de Sales');
    expect(francis.date, endsWith('-01-24'));
  });

  test('keeps the original name when reading an older saint record', () {
    final saint =
        SaintEntry.fromJson(const {'saint': 'Blaise', 'date': '2025-02-03'});
    for (final locale in const ['fr', 'en', 'cr']) {
      expect(saint.localizedName(locale), 'Blaise');
    }
  });

  test('caches a single asset load', () async {
    final bundle = _CountingAssetBundle(_minimalDataset);
    final repository = TchalaDataRepository(bundle: bundle);

    final firstLoad = repository.load();
    final secondLoad = repository.load();

    expect(identical(firstLoad, secondLoad), isTrue);
    await Future.wait([firstLoad, secondLoad]);
    expect(bundle.loadCount, 1);
  });

  test('rejects malformed catalogue entries', () {
    expect(
      () => TchalaData.fromJson(const {
        'symbols': [
          {
            'symbole_kreyol': 'Achte',
            'traduction_francais': 'Achat',
            'traduction_anglais': 'Purchase',
            'numeros_associes': ['55'],
          },
        ],
        'saint_months': <Object>[],
      }),
      throwsFormatException,
    );
  });

  test('requires an English translation for every symbol', () {
    expect(
      () => TchalaData.fromJson(const {
        'symbols': [
          {
            'symbole_kreyol': 'Achte',
            'traduction_francais': 'Achat',
            'numeros_associes': [55],
          },
        ],
        'saint_months': <Object>[],
      }),
      throwsFormatException,
    );
  });
}

const _minimalDataset = '''
{
  "symbols": [
    {
      "symbole_kreyol": "Achte",
      "traduction_francais": "Achat",
      "traduction_anglais": "Purchase",
      "numeros_associes": [55]
    }
  ],
  "saint_months": []
}
''';

class _CountingAssetBundle extends CachingAssetBundle {
  _CountingAssetBundle(this.source);

  final String source;
  int loadCount = 0;

  @override
  Future<ByteData> load(String key) async {
    loadCount += 1;
    final bytes = Uint8List.fromList(utf8.encode(source));
    return bytes.buffer.asByteData();
  }
}
