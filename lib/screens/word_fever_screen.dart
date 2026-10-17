import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../config/app_config.dart';
import '../data/word_repository.dart';
import '../game/evaluator.dart';
import '../game/lang_utils.dart';
import '../l10n/strings.dart';
import '../main.dart';
import '../services/booster_service.dart';
import '../services/coins_service.dart';
import '../services/storage_service.dart';
import '../widgets/animated_background.dart';
import '../widgets/game_keyboard.dart';
import '../widgets/wood_theme.dart';

/// WS5 (v4.1): WORD FEVER — a 60-second timed sprint. Solve as many
/// 5-letter words as possible (6 guesses per word, classic rules).
///
/// Score = words solved. Best score persists under 'word_fever_best'.
/// The Skip button consumes a Skip booster (purchasable with virtual
/// coins when the inventory is empty).
class WordFeverScreen extends StatefulWidget {
  const WordFeverScreen({super.key});

  @override
  State<WordFeverScreen> createState() => _WordFeverScreenState();
}

class _WordFeverScreenState extends State<WordFeverScreen> {
  static const _roundSeconds = 60;
  static const _maxGuesses = 6;

  final _rng = Random();
  final _booster = BoosterService.instance;

  late final AppLang _lang;
  late final S _s;
  late final WordRepository _repo;

  String _answer = '';
  final List<String> _guesses = [];
  final List<List<LetterState>> _evals = [];
  String _current = '';
  Map<String, LetterState> _keyStates = {};

  int _score = 0;
  int _best = 0;
  int _secondsLeft = _roundSeconds;
  bool _over = false;
  String? _message;

  Timer? _timer;

  String _tr(String key, [Map<String, String>? args]) {
    var text = S(_lang).get(key);
    args?.forEach((k, v) => text = text.replaceAll('{$k}', v));
    return text;
  }

  @override
  void initState() {
    super.initState();
    _lang = context.read<AppState>().lang;
    _s = S(_lang);
    _repo = WordRepository(_lang);
    _best = StorageService.instance.getInt('word_fever_best') ?? 0;
    _booster.init();
    _newWord(first: true);
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _tick() {
    if (!mounted || _over) return;
    if (_secondsLeft <= 1) {
      setState(() {
        _secondsLeft = 0;
        _over = true;
      });
      _timer?.cancel();
      _finish();
    } else {
      setState(() => _secondsLeft--);
    }
  }

  void _newWord({bool first = false}) {
    var next = _repo.randomAnswer(_rng);
    var guard = 0;
    while (!first && next == _answer && guard++ < 10) {
      next = _repo.randomAnswer(_rng);
    }
    _answer = next;
    _guesses.clear();
    _evals.clear();
    _current = '';
    _keyStates = {};
    if (!first && mounted) setState(() => _message = null);
  }

  void _onKey(String k) {
    if (_over) return;
    const n = AppConfig.wordLength;
    if (_lang.splitLetters(_current).length >= n) return;
    setState(() => _current += k);
    HapticFeedback.selectionClick();
  }

  void _onBackspace() {
    if (_over || _current.isEmpty) return;
    final letters = _lang.splitLetters(_current);
    setState(() => _current = letters.sublist(0, letters.length - 1).join());
  }

  Future<void> _onEnter() async {
    if (_over) return;
    const n = AppConfig.wordLength;
    if (_lang.splitLetters(_current).length < n) {
      _toast(_s.get('notEnough'));
      return;
    }
    if (!_repo.isValidGuess(_current)) {
      _toast(_s.get('notInList'));
      HapticFeedback.vibrate();
      return;
    }
    final guess = _current;
    final guessLetters = _repo.lettersOf(guess);
    final answerLetters = _repo.answerLetters(_answer);
    final eval = evaluateGuess(guessLetters, answerLetters);
    HapticFeedback.lightImpact();
    setState(() {
      _guesses.add(guess);
      _evals.add(eval);
      _current = '';
      for (var i = 0; i < guessLetters.length; i++) {
        final key = _lang.normalizeWord(guessLetters[i]);
        _keyStates[key] = mergeState(_keyStates[key] ?? LetterState.unknown, eval[i]);
      }
    });

    if (eval.every((e) => e == LetterState.correct)) {
      _score++;
      await CoinsService.instance.addCoins(5, reason: 'word_fever_win');
      if (!mounted) return;
      _toast(_tr('wfSolved'));
      _newWord();
      return;
    }
    if (_guesses.length >= _maxGuesses) {
      if (!mounted) return;
      _toast(_tr('wfOutOfGuesses', {'w': _answer}));
      _newWord();
    }
  }

  /// Skips the current word: consumes a Skip booster. When none are left,
  /// offers to buy one with coins; reports insufficient coins otherwise.
  Future<void> _onSkip() async {
    if (_over) return;
    setState(() => _message = null);
    if (_booster.skipCount > 0) {
      _booster.useSkip();
      _newWord();
      return;
    }
    if (!mounted) return;
    final msg = _tr('wfNoSkips');
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            '$msg — ${_tr('wfBuySkip', {'n': '${_booster.skipCost}'})}'),
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: _tr('wfBuy'),
          onPressed: _buyAndSkip,
        ),
      ),
    );
  }

  Future<void> _buyAndSkip() async {
    final bought = await _booster.buySkip();
    if (!mounted) return;
    if (bought) {
      _booster.useSkip();
      setState(() => _newWord());
    } else {
      _toast(_tr('wfNotEnoughCoins'));
    }
  }

  void _toast(String message) {
    if (!mounted) return;
    setState(() => _message = message);
  }

  Future<void> _finish() async {
    final isNewBest = _score > _best;
    if (isNewBest) {
      _best = _score;
      await StorageService.instance.setInt('word_fever_best', _best);
    }
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: WoodTheme.cream,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: WoodTheme.gold, width: 2),
        ),
        title: Text(
          _tr('wfTimeUp'),
          textAlign: TextAlign.center,
          style: const TextStyle(
              color: WoodTheme.bark, fontWeight: FontWeight.w800),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isNewBest)
              Text(
                _tr('wfNewBest'),
                style: const TextStyle(
                  color: WoodTheme.gold,
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                ),
              ),
            const SizedBox(height: 8),
            Text(
              '$_score',
              style: const TextStyle(
                fontSize: 56,
                fontWeight: FontWeight.w900,
                color: WoodTheme.emerald,
              ),
            ),
            Text(
              _tr('wfWordsSolved'),
              style: const TextStyle(color: WoodTheme.wood, fontSize: 14),
            ),
            const SizedBox(height: 4),
            Text(
              '${_tr('wfBest')}: $_best',
              style: const TextStyle(
                  color: WoodTheme.bark,
                  fontWeight: FontWeight.w700,
                  fontSize: 16),
            ),
          ],
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.of(context).pop();
            },
            child: Text(_tr('wfGoHome'),
                style: const TextStyle(color: WoodTheme.wood)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: WoodTheme.emerald,
              foregroundColor: WoodTheme.cream,
            ),
            onPressed: () {
              Navigator.of(ctx).pop();
              _restart();
            },
            child: Text(_tr('wfPlayAgain')),
          ),
        ],
      ),
    );
  }

  void _restart() {
    _timer?.cancel();
    setState(() {
      _score = 0;
      _secondsLeft = _roundSeconds;
      _over = false;
      _message = null;
    });
    _newWord(first: true);
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  Color _tileColor(LetterState st, bool filled) {
    return switch (st) {
      LetterState.correct => WoodTheme.emerald,
      LetterState.present => WoodTheme.gold,
      LetterState.absent => const Color(0xFF6D4C41),
      LetterState.unknown =>
        filled ? WoodTheme.cream : WoodTheme.creamDeep,
    };
  }

  Color _tileFg(LetterState st) => st == LetterState.unknown
      ? WoodTheme.bark
      : (st == LetterState.present ? WoodTheme.bark : Colors.white);

  Widget _buildBoard(double tile) {
    final rtl = _lang.isRtl;
    const n = AppConfig.wordLength;
    final cur = _lang.splitLetters(_current);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var r = 0; r < _maxGuesses; r++)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 2.5),
            child: Directionality(
              textDirection: rtl ? TextDirection.rtl : TextDirection.ltr,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (var c = 0; c < n; c++)
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 2.5),
                      width: tile,
                      height: tile,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: r < _guesses.length
                            ? _tileColor(_evals[r][c], true)
                            : _tileColor(LetterState.unknown,
                                r == _guesses.length && c < cur.length),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: r < _guesses.length
                              ? WoodTheme.gold
                              : WoodTheme.woodLight.withValues(alpha: 0.5),
                          width: r < _guesses.length ? 1.5 : 1,
                        ),
                      ),
                      child: Text(
                        r < _guesses.length
                            ? _repo.lettersOf(_guesses[r])[c]
                            : (r == _guesses.length && c < cur.length
                                ? cur[c]
                                : ''),
                        style: TextStyle(
                          fontSize: tile * 0.42,
                          fontWeight: FontWeight.w800,
                          color: r < _guesses.length
                              ? _tileFg(_evals[r][c])
                              : WoodTheme.bark,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final lowTime = _secondsLeft <= 10;
    final screenW = MediaQuery.sizeOf(context).width;
    final tile = ((screenW - 72) / AppConfig.wordLength).clamp(36.0, 54.0);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: WoodTheme.emerald,
        foregroundColor: WoodTheme.cream,
        leading: const BackButton(color: WoodTheme.cream),
        title: Text(_tr('wfTitle'),
            style: const TextStyle(fontWeight: FontWeight.w800)),
        centerTitle: true,
      ),
      body: AnimatedBackground(
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 8),
              // Score / timer / best header.
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _statChip(_tr('wfScore'), '$_score'),
                    Column(
                      children: [
                        Text(
                          '$_secondsLeft',
                          style: TextStyle(
                            fontSize: 44,
                            fontWeight: FontWeight.w900,
                            color: lowTime ? Colors.red.shade700 : WoodTheme.emerald,
                          ),
                        ),
                        Text(
                          _tr('wfSubtitle'),
                          style: const TextStyle(
                              fontSize: 11,
                              color: WoodTheme.wood,
                              fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 2),
                        SizedBox(
                          width: 150,
                          child: LinearProgressIndicator(
                            value: _secondsLeft / _roundSeconds,
                            backgroundColor:
                                WoodTheme.woodLight.withValues(alpha: 0.25),
                            valueColor: AlwaysStoppedAnimation<Color>(
                                lowTime ? Colors.red.shade700 : WoodTheme.gold),
                            minHeight: 6,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ],
                    ),
                    _statChip(_tr('wfBest'), '$_best'),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              // Skip button.
              Center(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: WoodTheme.wood,
                    foregroundColor: WoodTheme.cream,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                  ),
                  onPressed: _over ? null : _onSkip,
                  icon: const Icon(Icons.fast_forward, size: 18),
                  label: Text(
                      '${_tr('wfSkip')} (${_booster.skipCount})',
                      style:
                          const TextStyle(fontWeight: FontWeight.w700)),
                ),
              ),
              const SizedBox(height: 6),
              // Transient message line.
              SizedBox(
                height: 22,
                child: _message == null
                    ? Text(_tr('wfTapToStart'),
                        style: const TextStyle(
                            fontSize: 12,
                            color: WoodTheme.wood,
                            fontWeight: FontWeight.w600))
                    : Text(_message!,
                        style: const TextStyle(
                            fontSize: 13,
                            color: WoodTheme.bark,
                            fontWeight: FontWeight.w700)),
              ),
              const SizedBox(height: 4),
              // Guess board.
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    child: _buildBoard(tile),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              // Keyboard.
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: GameKeyboard(
                  lang: _lang,
                  keyStates: _keyStates,
                  onKey: _onKey,
                  onEnter: _onEnter,
                  onBackspace: _onBackspace,
                  s: _s,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statChip(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: WoodTheme.cream,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: WoodTheme.gold, width: 1.5),
        boxShadow: const [
          BoxShadow(
              color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 10,
                  color: WoodTheme.wood,
                  fontWeight: FontWeight.w700)),
          Text(value,
              style: const TextStyle(
                  fontSize: 22,
                  color: WoodTheme.bark,
                  fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }
}
