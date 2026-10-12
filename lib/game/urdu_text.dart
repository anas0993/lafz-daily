/// Urdu text normalization.
///
/// Urdu is typed with several look-alike code points (e.g. ي vs ی,
/// ك vs ک, ہ vs ہ). The bundled word lists use one canonical form, so both
/// the lists and every player guess are normalized with [normalizeUrdu]
/// before comparing. Tashkeel (diacritics) are stripped so they never
/// affect word length or matching.
String normalizeUrdu(String input) {
  final sb = StringBuffer();
  for (final cp in input.runes) {
    // Strip tashkeel / diacritics and tatweel.
    if (cp >= 0x064B && cp <= 0x0652) continue;
    if (cp == 0x0670 || cp == 0x0640 || cp == 0x0654 || cp == 0x0655) continue;
    // Canonicalize common variants.
    if (cp == 0x064A) {
      sb.writeCharCode(0x06CC);
      continue; // ي -> ی (Farsi Yeh)
    }
    if (cp == 0x0643) {
      sb.writeCharCode(0x06A9);
      continue; // ك -> ک (Keheh)
    }
    if (cp == 0x0647) {
      sb.writeCharCode(0x06C1);
      continue; // ہ -> ہ (Heh Goal)
    }
    sb.writeCharCode(cp);
  }
  return sb.toString();
}

/// Number of Urdu letters (runes after normalization).
int urduLength(String input) => normalizeUrdu(input).runes.length;

/// Splits normalized text into individual letter strings.
List<String> urduLetters(String input) =>
    normalizeUrdu(input).runes.map((c) => String.fromCharCode(c)).toList();
