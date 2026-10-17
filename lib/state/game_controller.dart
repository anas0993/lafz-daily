import 'dart:math';

import 'package:flutter/foundation.dart';
import '../config/app_config.dart';
import '../data/word_repository.dart';
import '../game/evaluator.dart';
import '../game/lang_utils.dart';
import '../game/puzzle.dart';
import '../l10n/strings.dart';
import '../services/ads_service.dart';
import '../services/billing_service.dart';
import '../services/difficulty_service.dart';
import '../services/game_settings.dart';
import '../services/remote_content_service.dart';
import '../services/share_service.dart';
import '../services/stats_service.dart';
import '../services/storage_service.dart';

enum GameMode { daily, practice, challenge }

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
    this.challengeAnswer, // required when mode == GameMode.challenge
  })  : _date = date ?? DateTime.now(),
        _answer = mode == GameMode.daily
            ? repo.dailyAnswerForSlot(slot, date ?? DateTime.now())
            : mode == GameMode.challenge
                ? challengeAnswer!
                : repo.randomAnswer() {
    _answerLetters = repo.answerLetters(_answer);
    _loadSaved();
  }

  final WordRepository repo;
  final GameMode mode;
  final DateTime _date;

  /// Daily puzzle slot 0..(puzzlesPerDay-1). Ignored in practice mode.
  final int slot;

  /// Custom answer for 1v1 challenge games (mode == GameMode.challenge).
  /// Treated like practice for persistence/stats (no save, non-daily stats).
  final String? challengeAnswer;

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
  // v4.1 WS2: _abandoned is set by abandon() (skip booster) — the puzzle
  // counts as played-not-won.
  bool _abandoned = false;
  bool get isLost =>
      !isWon && (rows.length >= AppConfig.maxAttempts || _abandoned);
  bool get isFinished => isWon || isLost;

  /// v4.1 WS2: abandon the current puzzle (skip booster). Counts as
  /// played-not-won: stats record a loss, the daily slot is marked done,
  /// and the result dialog shows the answer.
  Future<void> abandon() async {
    if (isFinished) return;
    _abandoned = true;
    _toast = null;
    notifyListeners();
    await _save();
    await _onFinished();
  }

  String? _toast;
  String? get toast => _toast;

  // ---------------------------------------------------------- storage --
  String get _saveKey =>
      'game_${repo.lang.name}_${mode.name}_${mode == GameMode.daily ? dateKey : (mode == GameMode.challenge ? _practiceId : _answer)}';

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
    // Hint-locked tiles occupy slots, so fewer typed letters fit.
    if (l.splitLetters(current).length >= _maxLen - hintLocks.length) return;
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

  /// Counts invalid-word submits (guess not in the word list). The game
  /// screen watches this to play the shake + red-flash feedback.
  int _invalidSubmits = 0;
  int get invalidSubmits => _invalidSubmits;

  /// Submits the current guess. Returns a toast message key on invalid input.
  Future<void> submit(S s) async {
    if (isFinished) return;
    // Merge hint-locked letters with typed letters (spaces = empty slots).
    final guess = repo.lang.normalizeWord(currentRow).replaceAll(' ', '');
    if (guess.runes.length < AppConfig.wordLength) {
      _toast = s.get('notEnough');
      notifyListeners();
      return;
    }
    if (!repo.isValidGuess(guess)) {
      _toast = s.get('notInList');
      _invalidSubmits++;
      notifyListeners();
      return;
    }
    // v4.1 WS2: hard mode enforced from the difficulty service
    // (DifficultySelector) or the legacy settings toggle. The service's
    // hardModeViolation returns an l10n key ('hardModeGreen' /
    // 'hardModeYellow'); a non-null key rejects the guess with that message.
    if (GameSettings.instance.hardMode ||
        DifficultyService.instance.hardMode) {
      final violation = DifficultyService.instance.hardModeViolation(
        guess: guess,
        fixedPositions: _fixedPositions(),
        mustInclude: _mustIncludeLetters(),
      );
      if (violation != null) {
        _toast = s.get(violation);
        notifyListeners();
        return;
      }
    }
    rows.add(guess);
    final ev = evaluateGuess(_split(guess), _answerLetters);
    evaluations.add(ev);
    current = '';
    hintLocks.clear();
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

  /// Positions revealed green in previous guesses (must stay put).
  Map<int, String> _fixedPositions() {
    final map = <int, String>{};
    for (var r = 0; r < rows.length; r++) {
      final letters = _split(rows[r]);
      for (var i = 0; i < letters.length; i++) {
        if (evaluations[r][i] == LetterState.correct) map[i] = letters[i];
      }
    }
    return map;
  }

  /// Letters revealed yellow in previous guesses (must be included).
  Set<String> _mustIncludeLetters() {
    final set = <String>{};
    for (var r = 0; r < rows.length; r++) {
      final letters = _split(rows[r]);
      for (var i = 0; i < letters.length; i++) {
        if (evaluations[r][i] == LetterState.present) set.add(letters[i]);
      }
    }
    return set;
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

  // EARNING DISABLED (interim no-rewards build): cash rewards removed so the
  // app can ship on a personal Play Console account. The PointsService code
  // is kept intact for re-enabling after the organization-account transfer.

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
      // Stats failed - continue anyway
    }
    // EARNING DISABLED (interim build): no cash rewards credited.
    notifyListeners();
    // Interstitial: at most once/day, only after the daily puzzle ends,
    // never in the middle of a game. Practice mode never triggers it.
    if (mode == GameMode.daily && !BillingService.instance.isPro.value) {
      await Future.delayed(const Duration(milliseconds: 600));
      await AdsService.instance.maybeShowInterstitial();
    }
  }

  // ------------------------------------------------------------- hint ---
  // WORKSTREAM 2 (GAMEPLAY): free-hint system.
  //
  // Every puzzle grants 2 free hints, persisted per puzzle (key includes
  // language + mode + date/slot for daily, unique id for practice).
  // A hint reveals ONE correct letter in a RANDOM unrevealed position of
  // the current row and locks that tile: typing fills around it and
  // backspace can't remove it.
  // Free hints are consumed first; the banked pool (rewarded ads, and
  // later coin purchases via addHints) is consumed afterwards.
  static const int freeHintsPerPuzzle = 2;

  int _freeHints = 0; // free hints left for THIS puzzle
  int get freeHintsLeft => _freeHints;

  int _hints = 0; // banked hints (rewarded ads / future coin purchases)

  /// Total usable hints right now (free + banked). Shown as 💡×N.
  int get hints => _freeHints + _hints;

  /// Locked positions in the current row: position -> correct letter.
  final Map<int, String> hintLocks = {};

  /// Unique id so every practice game gets its own free-hint budget.
  final String _practiceId = DateTime.now().microsecondsSinceEpoch.toString();

  String get _freeHintKey {
    final scope = mode == GameMode.daily ? dateKey : '${_answer}_$_practiceId';
    return 'hint_free_${repo.lang.name}_${mode.name}_$scope';
  }

  /// The current row as shown on the board: hint-locked letters fixed in
  /// place, typed letters filling the unlocked slots, spaces elsewhere.
  String get currentRow {
    if (hintLocks.isEmpty) return current;
    final typed = _split(current);
    final out = List<String>.filled(AppConfig.wordLength, ' ');
    for (final e in hintLocks.entries) {
      if (e.key >= 0 && e.key < out.length) out[e.key] = e.value;
    }
    var ti = 0;
    for (var i = 0; i < out.length && ti < typed.length; i++) {
      if (out[i] == ' ') {
        out[i] = typed[ti];
        ti++;
      }
    }
    return out.join();
  }

  Future<void> loadHints() async {
    final store = StorageService.instance;
    final today = Puzzle.dateKey(DateTime.now());
    if (store.getString('hint_day') != today) {
      await store.setString('hint_day', today);
      await store.setInt('hints_banked',
          RemoteContentService.instance.effectiveFreeHintsPerDay);
    }
    _hints = store.getInt('hints_banked') ?? 0;
    _freeHints = store.getInt(_freeHintKey) ?? freeHintsPerPuzzle;
    notifyListeners();
  }

  Future<void> _setHints(int v) async {
    _hints = v;
    await StorageService.instance.setInt('hints_banked', v);
    notifyListeners();
  }

  Future<void> _setFreeHints(int v) async {
    _freeHints = v;
    await StorageService.instance.setInt(_freeHintKey, v);
    notifyListeners();
  }

  /// Adds [n] hints to the banked pool.
  /// PARENT HOOK: coin-purchased hints should call this.
  Future<void> addHints(int n) async {
    if (n <= 0) return;
    await _setHints(_hints + n);
  }

  /// Reveals one correct letter in a random unrevealed position of the
  /// current row and locks that tile. Typed letters are cleared so the
  /// revealed letter stands alone as the row's anchor. Consumes a free
  /// hint first, then a banked hint. Returns false when no hint could
  /// be applied.
  Future<bool> useHint() async {
    if (isFinished) return false;
    if (_freeHints <= 0 && _hints <= 0) return false;
    final rowLetters = _split(currentRow);
    final candidates = <int>[];
    for (var i = 0; i < _answerLetters.length; i++) {
      final have = i < rowLetters.length ? rowLetters[i] : ' ';
      if (have != _answerLetters[i] && !hintLocks.containsKey(i)) {
        candidates.add(i);
      }
    }
    if (candidates.isEmpty) return false;
    final pos = candidates[Random().nextInt(candidates.length)];
    hintLocks[pos] = _answerLetters[pos];
    current = '';
    _toast = null;
    if (_freeHints > 0) {
      await _setFreeHints(_freeHints - 1);
    } else {
      await _setHints(_hints - 1);
    }
    return true;
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
