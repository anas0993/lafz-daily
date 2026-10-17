import 'package:flutter/foundation.dart';
import 'storage_service.dart';

/// Difficulty tiers for the Classic puzzle mode (WS4, v4.1).
enum DifficultyLevel { easy, normal, hard }

/// Owns the difficulty setting, the Wordle-style hard-mode toggle, and the
/// deterministic word-pool partitioning used by the daily puzzle picker.
///
/// No new word lists are shipped. Instead, [poolFor] partitions any answer
/// list on the fly using a letter-rarity heuristic (documented below), so
/// every language (en/ur/ar/es) gets level-appropriate pools automatically.
class DifficultyService extends ChangeNotifier {
  DifficultyService._();
  static final DifficultyService instance = DifficultyService._();

  static const _kLevel = 'difficulty_level';
  static const _kHardMode = 'difficulty_hard_mode';

  bool _inited = false;
  DifficultyLevel _level = DifficultyLevel.normal;
  bool _hardMode = false;

  Future<void> init() async {
    if (_inited) return;
    await StorageService.instance.init();
    final idx = StorageService.instance.getInt(_kLevel);
    if (idx != null &&
        idx >= 0 &&
        idx < DifficultyLevel.values.length) {
      _level = DifficultyLevel.values[idx];
    }
    _hardMode = StorageService.instance.getBool(_kHardMode) ?? false;
    _inited = true;
  }

  DifficultyLevel get level => _level;

  Future<void> setLevel(DifficultyLevel l) async {
    await init();
    if (_level == l) return;
    _level = l;
    await StorageService.instance.setInt(_kLevel, l.index);
    notifyListeners();
  }

  bool get hardMode => _hardMode;

  Future<void> setHardMode(bool v) async {
    await init();
    if (_hardMode == v) return;
    _hardMode = v;
    await StorageService.instance.setBool(_kHardMode, v);
    notifyListeners();
  }

  /// Free hints per puzzle: 2 normally, 1 when playing hard.
  int get freeHints => _level == DifficultyLevel.hard ? 1 : 2;

  /// Partitions [answers] into the pool for the current difficulty level.
  ///
  /// ## Heuristic (deterministic, language-agnostic)
  /// 1. Count how often each *character* appears across the whole list
  ///    (per distinct letter per word, so 'APPLE' counts P only once).
  /// 2. Score each word as the sum over its distinct letters of
  ///    `totalWords / letterFrequency` — rare letters raise the score.
  /// 3. Sort words by score ascending (stable by index, so the result is
  ///    fully deterministic) and take:
  ///    * the easiest 40% for [DifficultyLevel.easy],
  ///    * the full list for [DifficultyLevel.normal],
  ///    * the hardest 40% for [DifficultyLevel.hard].
  ///
  /// The middle 20% is never used directly: it acts as a buffer band so the
  /// easy and hard pools feel clearly different instead of overlapping at
  /// the boundary. 'normal' keeps the entire list so the classic daily
  /// experience is unchanged.
  ///
  /// Returns the words in deterministic (score) order, safe to pass
  /// straight into [Puzzle.dailyAnswerForSlot].
  List<String> poolFor(List<String> answers) {
    if (_level == DifficultyLevel.normal || answers.isEmpty) {
      return List<String>.of(answers);
    }
    final n = answers.length;

    // 1. Letter frequencies (per distinct letter per word).
    final freq = <String, int>{};
    for (final word in answers) {
      for (final ch in word.split('').toSet()) {
        freq[ch] = (freq[ch] ?? 0) + 1;
      }
    }

    // 2. Rarity score per word.
    final indexed = List.generate(n, (i) => i);
    final score = <int, double>{};
    for (final i in indexed) {
      double s = 0;
      for (final ch in answers[i].split('').toSet()) {
        final f = freq[ch] ?? 1;
        s += n / f;
      }
      score[i] = s;
    }

    // 3. Sort ascending by score; stable by original index.
    indexed.sort((a, b) {
      final c = score[a]!.compareTo(score[b]!);
      return c != 0 ? c : a.compareTo(b);
    });

    if (_level == DifficultyLevel.easy) {
      return indexed.take((n * 0.40).round().clamp(1, n)).map((i) => answers[i]).toList();
    }
    // hard
    final start = (n * 0.60).round().clamp(0, n - 1);
    return indexed.skip(start).map((i) => answers[i]).toList();
  }

  /// Wordle hard-mode check.
  ///
  /// [fixedPositions]: position → letter revealed green in a previous guess
  /// (must stay in that position). [mustInclude]: letters revealed yellow in
  /// a previous guess (must appear somewhere in the guess).
  ///
  /// Returns an l10n key for the violation message, or null when the guess
  /// is legal. Callers look the key up in their own strings map.
  String? hardModeViolation({
    required String guess,
    required Map<int, String> fixedPositions,
    required Set<String> mustInclude,
  }) {
    final letters = guess.split('');
    for (final entry in fixedPositions.entries) {
      final pos = entry.key;
      if (pos < 0 || pos >= letters.length || letters[pos] != entry.value) {
        return 'hardModeGreen';
      }
    }
    for (final letter in mustInclude) {
      if (!letters.contains(letter)) return 'hardModeYellow';
    }
    return null;
  }
}
