const bingoValueIconAssets = <String, String>{
  '1er lot': 'assets/images/game-2.png',
  '2e lot': 'assets/images/bingo-prize-2.png',
  '3e lot': 'assets/images/bingo-prize-3.png',
  '2 lots': 'assets/images/bingo-two-prizes.png',
  'loto 3': 'assets/images/bingo-loto-3.png',
  'loto 4': 'assets/images/bingo-loto-4.png',
  '2 kabès': 'assets/images/bingo-two-kabes.png',
  'mariage': 'assets/images/bingo-mariage.png',
  'boloto': 'assets/images/bingo-boloto.png',
};

String? bingoValueIconAsset(String value) {
  final normalizedValue = value.trim().toLowerCase();

  return bingoValueIconAssets[normalizedValue] ??
      switch (normalizedValue) {
        '2eme lot' || '2ème lot' => bingoValueIconAssets['2e lot'],
        '3eme lot' || '3ème lot' => bingoValueIconAssets['3e lot'],
        '2 kabes' => bingoValueIconAssets['2 kabès'],
        _ => null,
      };
}
