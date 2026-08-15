import 'package:choloto/autres/bingo/stackbingo/bingo_value_icon.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('provides an icon for every supported Bingo value', () {
    const supportedValues = [
      '1er lot',
      '2e lot',
      '3e lot',
      '2 lots',
      'LOTO 3',
      'LOTO 4',
      '2 Kabès',
      'MARIAGE',
      'BOLOTO',
    ];

    for (final value in supportedValues) {
      expect(
        bingoValueIconAsset(value),
        isNotNull,
        reason: 'No icon is configured for $value',
      );
    }
  });

  test('supports historical spelling variants and ignores unknown values', () {
    expect(
      bingoValueIconAsset('2ème lot'),
      bingoValueIconAssets['2e lot'],
    );
    expect(
      bingoValueIconAsset('2 Kabes'),
      bingoValueIconAssets['2 kabès'],
    );
    expect(bingoValueIconAsset('valeur inconnue'), isNull);
  });

  test('includes every configured Bingo icon in the asset bundle', () async {
    for (final asset in bingoValueIconAssets.values) {
      final data = await rootBundle.load(asset);
      expect(data.lengthInBytes, greaterThan(0), reason: 'Missing $asset');
    }
  });
}
