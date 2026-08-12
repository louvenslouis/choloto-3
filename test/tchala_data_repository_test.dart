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
    expect(
      data.saintMonths.expand((month) => month.saints),
      hasLength(264),
    );
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
