/// Arabic text normalization.
///
/// Arabic is typed with several look-alike code points (e.g. أ vs ا,
/// ة vs ه, ى vs ي, ؤ vs و, ئ vs ي). The bundled word lists use one
/// canonical form, so both the lists and every player guess are normalized
/// with [normalizeArabic] before comparing. Tashkeel (diacritics),
/// tatweel and hamza carriers are stripped or canonicalized so they never
/// affect word length or matching.
String normalizeArabic(String input) {
  final sb = StringBuffer();
  for (final cp in input.runes) {
    // Strip tashkeel / diacritics and tatweel.
    if (cp >= 0x064B && cp <= 0x0652) continue;
    if (cp == 0x0670 || cp == 0x0640 || cp == 0x0654 || cp == 0x0655) continue;
    // Canonicalize hamza/alef variants to plain alef.
    if (cp == 0x0623 || cp == 0x0625 || cp == 0x0622) {
      sb.writeCharCode(0x0627);
      continue; // أ إ آ -> ا (Alef)
    }
    if (cp == 0x0629) {
      sb.writeCharCode(0x0647);
      continue; // ة -> ه (Teh Marbuta -> Heh)
    }
    if (cp == 0x0649) {
      sb.writeCharCode(0x064A);
      continue; // ى -> ي (Alef Maksura -> Yeh)
    }
    if (cp == 0x0624) {
      sb.writeCharCode(0x0648);
      continue; // ؤ -> و (Waw with Hamza -> Waw)
    }
    if (cp == 0x0626) {
      sb.writeCharCode(0x064A);
      continue; // ئ -> ي (Yeh with Hamza -> Yeh)
    }
    sb.writeCharCode(cp);
  }
  return sb.toString();
}

/// Number of Arabic letters (runes after normalization).
int arabicLength(String input) => normalizeArabic(input).runes.length;

/// Splits normalized text into individual letter strings.
List<String> arabicLetters(String input) =>
    normalizeArabic(input).runes.map((c) => String.fromCharCode(c)).toList();
