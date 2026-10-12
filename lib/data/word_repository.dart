import 'dart:math';
import '../config/app_config.dart';
import '../game/lang_utils.dart';
import '../game/puzzle.dart';
import '../l10n/strings.dart';
import '../data/arabic_answers.dart';
import '../data/arabic_guesses.dart';
import '../data/english_answers.dart';
import '../data/english_guesses.dart';
import '../data/spanish_answers.dart';
import '../data/spanish_guesses.dart';
import '../data/urdu_answers.dart';
import '../data/urdu_guesses.dart';
import '../services/remote_content_service.dart';

/// Central access to the word lists, split by puzzle language.
///
/// When the admin panel has published word lists to Firestore, the remote
/// lists replace the bundled ones (only if the cloud collection is
/// non-empty); otherwise the bundled lists below are used.

/// Central access to the word lists, split by puzzle language.
class WordRepository {
  final AppLang lang;
  WordRepository(this.lang);

  List<String> get answers =>
      RemoteContentService.instance.remoteAnswers(lang) ??
      switch (lang) {
        AppLang.en => kEnglishAnswers,
        AppLang.ur => kUrduAnswers,
        AppLang.ar => kArabicAnswers,
        AppLang.es => kSpanishAnswers,
      };

  List<String> get validGuesses =>
      RemoteContentService.instance.remoteGuesses(lang) ??
      switch (lang) {
        AppLang.en => kEnglishGuesses,
        AppLang.ur => kUrduGuesses,
        AppLang.ar => kArabicGuesses,
        AppLang.es => kSpanishGuesses,
      };

  late final Set<String> _guessSet = validGuesses.toSet();

  /// The daily answer for [date] (defaults to today).
  String dailyAnswer([DateTime? date]) =>
      Puzzle.dailyAnswer(answers, date ?? DateTime.now());

  /// The daily answer for [date] and [slot] (0-4). Defaults to today.
  String dailyAnswerForSlot(int slot, [DateTime? date]) =>
      Puzzle.dailyAnswerForSlot(answers, date ?? DateTime.now(), slot);

  /// A random answer for practice mode.
  String randomAnswer([Random? rng]) =>
      answers[(rng ?? Random()).nextInt(answers.length)];

  /// True when [guess] is an acceptable guess (right length + in list).
  /// Latin languages are case-insensitive; Urdu and Arabic guesses are
  /// normalized first.
  bool isValidGuess(String guess) {
    final g = lang.normalizeWord(guess);
    if (g.runes.length != AppConfig.wordLength) return false;
    return _guessSet.contains(g);
  }

  /// Splits a guess into letters for the evaluator.
  List<String> lettersOf(String guess) => lang.splitLetters(guess);

  /// Splits an answer into letters for the evaluator.
  List<String> answerLetters(String answer) => lang.splitLetters(answer);
}
