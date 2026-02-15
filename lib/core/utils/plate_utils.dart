const arToLatinMap = <String, String>{
  'ا': 'A', 'ب': 'B', 'ح': 'J', 'د': 'D', 'ر': 'R', 'س': 'S', 'ص': 'X',
  'ط': 'T', 'ع': 'E', 'ق': 'G', 'ك': 'K', 'ل': 'L', 'م': 'Z', 'ن': 'N',
  'ه': 'H', 'و': 'U', 'ى': 'V',
};

final latinToArMap = <String, String>{
  for (final entry in arToLatinMap.entries) entry.value: entry.key,
};

const _hindiDigits = '٠١٢٣٤٥٦٧٨٩';

String toHindiDigits(String str) {
  return str.replaceAllMapped(RegExp(r'[0-9]'), (m) {
    return _hindiDigits[int.parse(m.group(0)!)];
  });
}

const _arabicIndicMap = <String, String>{
  '٠': '0', '١': '1', '٢': '2', '٣': '3', '٤': '4',
  '٥': '5', '٦': '6', '٧': '7', '٨': '8', '٩': '9',
};

String normalizePlateLetters(String raw) {
  final allowedLatin = latinToArMap.keys.toSet();
  final chars = raw.toUpperCase().replaceAll(RegExp(r'\s'), '').split('');
  final mapped = chars.map((char) {
    if (arToLatinMap.containsKey(char)) return arToLatinMap[char]!;
    return allowedLatin.contains(char) ? char : '';
  }).join('');
  return mapped.length > 3 ? mapped.substring(0, 3) : mapped;
}

String normalizePlateDigits(String raw) {
  final result = raw.split('').map((char) {
    return _arabicIndicMap[char] ?? char;
  }).join('').replaceAll(RegExp(r'\D'), '');
  return result.length > 4 ? result.substring(0, 4) : result;
}

String formatPlate(String digits, String letters) {
  final cleanLetters = normalizePlateLetters(letters);
  return '$digits-$cleanLetters';
}

String toArabicLetters(String latinLetters) {
  return latinLetters
      .toUpperCase()
      .split('')
      .map((letter) => latinToArMap[letter] ?? '')
      .join('');
}

({
  String digits,
  String letters,
  String hindiDigits,
  String arabicLetters,
}) parsePlate(String plate) {
  final parts = plate.trim().split(RegExp(r'[-_\s]+'));
  final rawDigits = parts.isNotEmpty ? normalizePlateDigits(parts[0]) : '';
  final rawLetters = parts.length > 1 ? normalizePlateLetters(parts[1]) : '';
  // Format like Saudi plate: 4 digits, 3 letters (padded for consistent display)
  final digits = rawDigits.length > 4 ? rawDigits.substring(0, 4) : rawDigits.padLeft(4, '0');
  final letters = rawLetters.length > 3 ? rawLetters.substring(0, 3).toUpperCase() : rawLetters.toUpperCase().padRight(3, ' ');
  return (
    digits: digits,
    letters: letters,
    hindiDigits: toHindiDigits(digits),
    arabicLetters: letters
        .replaceAll(' ', '')
        .split('')
        .map((l) => latinToArMap[l] ?? l)
        .join(' '),
  );
}
