import '../l10n/strings.dart';
import 'arabic_text.dart';
import 'urdu_text.dart';

/// Per-language behavior shared by the game logic, widgets and services.
///
/// RTL scripts (Urdu, Arabic) and Latin scripts (English, Spanish) need
/// different text direction, keyboard layouts and display casing, while
/// each language has its own word normalization. Adding a new language
/// should extend [AppLang] and update this extension rather than
/// sprinkling `lang == AppLang.en ? ... : ...` ternaries around.
extension AppLangX on AppLang {
  /// True for right-to-left scripts (Urdu, Arabic).
  bool get isRtl => this == AppLang.ur || this == AppLang.ar;

  /// True for Latin-script languages (English, Spanish).
  bool get isLatin => this == AppLang.en || this == AppLang.es;

  /// Normalizes a word for comparison against the bundled lists.
  /// Latin languages are case-folded; Urdu and Arabic each strip
  /// diacritics and canonicalize look-alike code points.
  String normalizeWord(String w) => switch (this) {
        AppLang.en || AppLang.es => w.toLowerCase(),
        AppLang.ur => normalizeUrdu(w),
        AppLang.ar => normalizeArabic(w),
      };

  /// Splits a (possibly unnormalized) word into letter strings for the
  /// evaluator, board and keyboard.
  List<String> splitLetters(String w) =>
      normalizeWord(w).runes.map((c) => String.fromCharCode(c)).toList();
}

/// Parses a persisted language code (e.g. from shared preferences) into an
/// [AppLang]; unknown codes fall back to English.
AppLang appLangFromCode(String code) =>
    AppLang.values.firstWhere((l) => l.name == code, orElse: () => AppLang.en);
