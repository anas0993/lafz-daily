import 'package:flutter/foundation.dart';
import '../config/app_config.dart';
import '../data/word_repository.dart';
import '../game/evaluator.dart';
import '../game/lang_utils.dart';
import '../game/puzzle.dart';
import '../l10n/strings.dart';
import '../services/ads_service.dart';
import '../services/billing_service.dart';
import '../services/game_settings.dart';
import '../services/points_service.dart';
import '../services/remote_content_service.dart';
import '../services/share_service.dart';
import '../services/stats_service.dart';
import '../services/storage_service.dart';

enum GameMode { daily, practice }

/// Holds all mutable state for one game session:
/// board rows, evaluations, keyboard colors, hints, and persistence.
///
/// A [GameController] is created per puzzle: daily (bound to a calendar
/// date AND a slot 0..4 — five puzzles per day) or practice (random word).
/// Finished daily games are saved so the share dialog, stats and countdown
/// survive app restarts. Daily wins credit $0.05 to the points wallet,
/// exactly once per puzzle.
class GameController extends ChangeNotifier {
  GameController({
    required this.repo,
    required this.mode,
    DateTime? date, // only for daily (archive support)
    this.slot = 0, // daily puzzle slot 0..(puzzlesPerDay-1)
  })  : _date = date ?? DateTime.now(),
        _answer = mode == GameMode.daily
            ? repo.dailyAnswerForSlot(slot, date ?? DateTime.now())
            : repo.randomAnswer() {
    _answerLetters = repo.answerLetters(_answer);
    _loadSaved();
  }

  final WordRepository repo;
  final GameMode mode;
  final DateTime _date;

  /// Daily puzzle slot 0..(puzzlesPerDay-1). Ignored in practice mode.
  final int slot;

  late final String _answer;
  late final List<String> _answerLetters;
  String get answer => _answer;
  int get puzzleNumber => Puzzle.dayNumber(_date);

  /// Plain calendar key (for stats/streaks, shared by all 5 daily slots).
  String get calendarDateKey => Puzzle.dateKey(_date);

  /// Slot-specific key (for save games: 5 puzzles never overwrite
  /// each other).
  String get dateKey => '${Puzzle.dateKey(_date)}_$slot';

  final List<String> rows = []; // submitted guesses (normalized)
  final List<List<LetterState>> evaluations = [];
  String current = ''; // in-progress guess (normalized)
  final Map<String, LetterState> keyStates = {};

  bool get isWon =>
      evaluations.isNotEmpty &&
      evaluations.last.every((s) => s == LetterState.correct);
  bool get isLost => !isWon && rows.length >= AppConfig.maxAttempts;
  bool get isFinished => isWon || isLost;

  String? _toast;
  String? get toast => _toast;

  int _hints = 0; // hints banked (free daily + rewarded)
  int get hints => _hints;

  // ---------------------------------------------------------- storage --
  String get _saveKey =>
      'game_${repo.lang.name}_${mode.name}_${mode == GameMode.daily ? dateKey : _answer}';

  /// Save key for a daily puzzle slot (used by the home screen to show
  /// which of today's 5 puzzles are already done).
  static String dailySaveKey(AppLang lang, DateTime date, int slot) =>
      'game_${lang.name}_${GameMode.daily.name}_${Puzzle.dateKey(date)}_$slot';

  /// True when today's puzzle [slot] for [lang] was finished.
  static bool isSlotDoneToday(AppLang lang, int slot) {
    final j = StorageService.instance
        .getJson(dailySaveKey(lang, DateTime.now(), slot));
    return (j?['done'] as bool?) ?? false;
  }

  void _loadSaved() {
    if (mode != GameMode.daily) return;
    final j = StorageService.instance.getJson(_saveKey);
    if (j == null) return;
    try {
      final savedRows = (j['rows'] as List).cast<String>();
      for (final r in savedRows) {
        rows.add(r);
        evaluations.add(evaluateGuess(_split(r), _answerLetters));
      }
      _rebuildKeyStates();
      _finishedNotified = (j['done'] as bool?) ?? false;
    } catch (_) {/* corrupted save: start fresh */}
  }

  Future<void> _save() async {
    if (mode != GameMode.daily) return;
    await StorageService.instance.setJson(_saveKey, {
      'rows': rows,
      'done': isFinished,
      'answer': _answer,
    });
  }

  List<String> _split(String word) => repo.lettersOf(word);

  // ------------------------------------------------------------ input ---
  // Every supported language uses 5-letter words.
  int get _maxLen => AppConfig.wordLength;

  void typeLetter(String letter) {
    if (isFinished) return;
    final l = repo.lang;
    final norm = l.normalizeWord(letter);
    if (l.splitLetters(current).length >= _maxLen) return;
    current = l.normalizeWord(current + norm);
    _toast = null;
    notifyListeners();
  }

  void backspace() {
    if (isFinished || current.isEmpty) return;
    final l = repo.lang;
    if (l.isLatin) {
      current = current.substring(0, current.length - 1);
    } else {
      final rs = l.normalizeWord(current).runes.toList();
      current = String.fromCharCodes(rs.sublist(0, rs.length - 1));
    }
    _toast = null;
    notifyListeners();
  }

  /// Submits the current guess. Returns a toast message key on invalid input.
  Future<void> submit(S s) async {
    if (isFinished) return;
    final guess = repo.lang.normalizeWord(current);
    if (guess.runes.length < AppConfig.wordLength) {
      _toast = s.get('notEnough');
      notifyListeners();
      return;
    }
    if (!repo.isValidGuess(guess)) {
      _toast = s.get('notInList');
      notifyListeners();
      return;
    }
    if (GameSettings.instance.hardMode) {
      final violation = _hardModeViolation(guess);
      if (violation != null) {
        _toast = violation == 'green' ? s.get('hardModeGreen') : s.get('hardModeYellow');
        notifyListeners();
        return;
      }
    }
    rows.add(guess);
    final ev = evaluateGuess(_split(guess), _answerLetters);
    evaluations.add(ev);
    current = '';
    _rebuildKeyStates();
    if (isFinished) {
      // Win/loss get the result dialog; no toast needed.
      _toast = null;
    } else {
      // Explicit feedback after every wrong guess: how many letters are
      // exact vs misplaced, so players always know what happened.
      final correct = ev.where((e) => e == LetterState.correct).length;
      final present = ev.where((e) => e == LetterState.present).length;
      _toast = s.guessFeedback(correct, present);
    }
    notifyListeners();
    await _save();
    if (isFinished) {
      await _onFinished();
    }
  }

  String? _hardModeViolation(String guess) {
    final guessLetters = _split(guess);
    final requiredPositions = <int, String>{};
    final requiredLetters = <String>{};
    for (var r = 0; r < rows.length; r++) {
      final letters = _split(rows[r]);
      for (var i = 0; i < letters.length; i++) {
        if (evaluations[r][i] == LetterState.correct) {
          requiredPositions[i] = letters[i];
        } else if (evaluations[r][i] == LetterState.present) {
          requiredLetters.add(letters[i]);
        }
      }
    }
    for (final e in requiredPositions.entries) {
      if (guessLetters[e.key] != e.value) return 'green';
    }
    for (final letter in requiredLetters) {
      if (!guessLetters.contains(letter)) return 'yellow';
    }
    return null;
  }

  void _rebuildKeyStates() {
    keyStates.clear();
    for (var r = 0; r < rows.length; r++) {
      final letters = _split(rows[r]);
      for (var i = 0; i < letters.length; i++) {
        keyStates[letters[i]] =
            mergeState(keyStates[letters[i]] ?? LetterState.unknown, evaluations[r][i]);
      }
    }
  }

  bool _finishedNotified = false;

  /// True when this win freshly credited $0.05 (used by the result dialog).
  bool _justEarned = false;
  bool get justEarned => _justEarned;

  Future<void> _onFinished() async {
    if (_finishedNotified) return;
    _finishedNotified = true;
    // Defensive: each step isolated so one failure can't block the others
    try {
      await StatsService.instance.recordGame(
        lang: repo.lang,
        won: isWon,
        guesses: rows.length,
        isDaily: mode == GameMode.daily,
        dateKey: mode == GameMode.daily ? calendarDateKey : null,
      );
    } catch (_) {
      // Stats failed - continue to rewards anyway
    }
    // $0.05 per daily win, credited exactly once per puzzle. Practice
    // games never earn (otherwise the reward could be farmed).
    if (mode == GameMode.daily && isWon) {
      try {
        _justEarned = await PointsService.instance.awardDailyWin(_saveKey);
      } catch (_) {
        _justEarned = false;
      }
    }
    notifyListeners();
    // Interstitial: at most once/day, only after the daily puzzle ends,
    // never in the middle of a game. Practice mode never triggers it.
    if (mode == GameMode.daily && !BillingService.instance.isPro.value) {
      await Future.delayed(const Duration(milliseconds: 600));
      await AdsService.instance.maybeShowInterstitial();
    }
  }

  // ------------------------------------------------------------- hint ---
  Future<void> loadHints() async {
    final store = StorageService.instance;
    final today = Puzzle.dateKey(DateTime.now());
    if (store.getString('hint_day') != today) {
      await store.setString('hint_day', today);
      await store.setInt('hints_banked',
          RemoteContentService.instance.effectiveFreeHintsPerDay);
    }
    _hints = store.getInt('hints_banked') ?? 0;
    notifyListeners();
  }

  Future<void> _setHints(int v) async {
    _hints = v;
    await StorageService.instance.setInt('hints_banked', v);
    notifyListeners();
  }

  /// Reveals one correct letter in the current row (first unknown position).
  /// Returns false when no hint could be applied.
  Future<bool> useHint() async {
    if (_hints <= 0 || isFinished) return false;
    final cur = _split(current);
    // Find positions not yet correctly filled in the current row.
    for (var i = 0; i < _answerLetters.length; i++) {
      final already = i < cur.length ? cur[i] : null;
      if (already != _answerLetters[i]) {
        // Fill this position with the correct letter.
        final letters = List<String>.from(cur);
        while (letters.length <= i) {
          letters.add('');
        }
        letters[i] = _answerLetters[i];
        current = letters.join();
        await _setHints(_hints - 1);
        return true;
      }
    }
    return false;
  }

  /// +1 hint after watching a rewarded ad.
  Future<bool> earnHintViaAd() async {
    var granted = false;
    final shown = await AdsService.instance.showRewarded(() async {
      granted = true;
    });
    if (shown && granted) {
      await _setHints(_hints + 1);
      return true;
    }
    return false;
  }

  // ------------------------------------------------------------ share ---
  String shareText(S s) => ShareService.buildText(
        s: s,
        puzzleNumber: puzzleNumber,
        won: isWon,
        attempts: rows.length,
        rows: evaluations,
      );
}
