const _accents = {
  'a': 'àáâäãåāăạảấầẩẫậắằẳẵặ',
  'c': 'çćč',
  'd': 'đ',
  'e': 'èéêëēėẹẻẽếềểễệ',
  'i': 'ìíîïīỉịĩ',
  'n': 'ñń',
  'o': 'òóôöõøōơọỏốồổỗộớờởỡợ',
  'u': 'ùúûüūưụủũứừửữự',
  'y': 'ýÿỳỵỷỹ',
};

final _foldedLetters = {
  for (final entry in _accents.entries)
    for (final letter in entry.value.split('')) letter: entry.key,
  'œ': 'oe',
  'æ': 'ae',
};
final _accentPattern = RegExp('[${_foldedLetters.keys.join()}]');
final _combiningMarks = RegExp(r'[\u0300-\u036f]');
final _wordBreaks = RegExp(r"[-‐‑–'’\s]+");

/// Normalize names from the French, English and Haitian Creole catalogues.
String normalizeTchalaSearch(String value) => value
    .toLowerCase()
    .replaceAllMapped(_accentPattern, (m) => _foldedLetters[m[0]]!)
    .replaceAll(_combiningMarks, '')
    .replaceAll(_wordBreaks, ' ')
    .trim();
