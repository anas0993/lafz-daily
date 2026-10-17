import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../data/word_repository.dart';
import '../game/en_definitions.dart';
import '../game/evaluator.dart';
import '../game/lang_utils.dart';
import '../game/puzzle.dart';
import '../l10n/strings.dart';
import '../main.dart';
import '../services/ads_service.dart';
import '../services/achievements_service.dart';
import '../services/booster_service.dart';
import '../services/coins_service.dart';
import '../services/difficulty_service.dart';
import '../services/rewards_service.dart';
import '../services/share_service.dart';
import '../services/stats_service.dart';
import '../services/team_service.dart';
import '../state/game_controller.dart';
import '../widgets/ad_slot.dart';
import '../widgets/animated_background.dart';
import '../widgets/boosters_row.dart';
import '../widgets/confetti_celebration.dart';
import '../widgets/difficulty_selector.dart';
import '../widgets/game_board.dart';
import '../widgets/game_keyboard.dart';
import '../widgets/tutorial_overlay.dart';
import '../widgets/wood_theme.dart';
import 'stats_screen.dart';

/// Game screen. Use the named constructors:
///   GameScreen.daily()            — today's puzzle (slot 0..4, five a day)
///   GameScreen.dailyAt(date)      — archive puzzle (Pro)
///   GameScreen.practice()         — unlimited random words (no earnings)
///   GameScreen.challenge(word)    — 1v1 friend challenge with a custom word
class GameScreen extends StatelessWidget {
  final GameMode mode;
  final DateTime? date;
  final int slot;
  final String? challengeWord;

  const GameScreen.daily({super.key, this.slot = 0})
      : mode = GameMode.daily,
        date = null,
        challengeWord = null;
  const GameScreen.dailyAt(this.date, {super.key, this.slot = 0})
      : mode = GameMode.daily,
        challengeWord = null;
  const GameScreen.practice({super.key})
      : mode = GameMode.practice,
        date = null,
        slot = 0,
        challengeWord = null;
  const GameScreen.challenge(this.challengeWord, {super.key})
      : mode = GameMode.challenge,
        date = null,
        slot = 0;

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    // v4.1 WS2: the answer pool is filtered by the selected difficulty
    // (DifficultyService.instance.poolFor) via _DifficultyRepo below.
    DifficultyService.instance.init();
    return ChangeNotifierProvider(
      create: (_) {
        final c = GameController(
          repo: _DifficultyRepo(appState.lang),
          mode: mode,
          date: date,
          slot: slot,
          challengeAnswer: challengeWord,
        );
        c.loadHints();
        return c;
      },
      child: const _GameView(),
    );
  }
}

/// v4.1 WS2: [WordRepository] whose answer list is filtered through
/// `DifficultyService.instance.poolFor` — easy/hard pick from their
/// partitions, normal keeps the full list. Guesses stay unfiltered.
class _DifficultyRepo extends WordRepository {
  _DifficultyRepo(super.lang);

  @override
  List<String> get answers =>
      DifficultyService.instance.poolFor(super.answers);
}

class _GameView extends StatefulWidget {
  const _GameView();
  @override
  State<_GameView> createState() => _GameViewState();
}

class _GameViewState extends State<_GameView> with TickerProviderStateMixin {
  bool _dialogShown = false;

  // WORKSTREAM 2 (GAMEPLAY): feedback animations.
  // _shakeController drives the invalid-word board shake + red flash.
  // _winController drives the green glow pulse on wins.
  late final AnimationController _shakeController;
  late final Animation<double> _shakeOffset;
  late final AnimationController _winController;
  int _lastInvalidCount = 0;
  int _lastRowCount = 0;
  bool _winAnimStarted = false;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
    _shakeOffset = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: -12.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -12.0, end: 10.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 10.0, end: -6.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -6.0, end: 4.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 4.0, end: 0.0), weight: 1),
    ]).animate(_shakeController);
    _winController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1300),
    );
    // Sync feedback trackers with any restored game so a finished game
    // loaded from storage doesn't replay win/invalid animations on open.
    final game = context.read<GameController>();
    _lastRowCount = game.rows.length;
    _lastInvalidCount = game.invalidSubmits;
    // v4: first-time tutorial overlay (shows once ever).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final appState = context.read<AppState>();
        TutorialOverlay.maybeShow(context, appState.s);
      }
    });
  }

  @override
  void dispose() {
    _shakeController.dispose();
    _winController.dispose();
    super.dispose();
  }

  /// Invalid word: board shake + red flash + haptic + error sound.
  void _playInvalidFeedback() {
    if (!mounted) return;
    HapticFeedback.vibrate();
    SystemSound.play(SystemSoundType.alert);
    _shakeController.forward(from: 0);
  }

  /// Correct guess: green glow pulse + confetti + haptic.
  void _playWinFeedback() {
    if (!mounted || _winAnimStarted) return;
    _winAnimStarted = true;
    HapticFeedback.heavyImpact();
    _winController.forward(from: 0);
  }

  /// v4.1 WS2: dart booster — calls
  /// `BoosterService.instance.dartTargets` with the current answer and the
  /// letters already marked absent, greys those letters out on the
  /// keyboard, consumes one dart. When the inventory is empty the player
  /// can buy one for [BoosterService.dartCost] coins.
  Future<void> _onDart(GameController game, S s) async {
    if (game.isFinished) return;
    final svc = BoosterService.instance;
    if (svc.dartCount <= 0) {
      if (!mounted) return;
      final bought = await _offerBuy(
        s,
        message: s.get('noDarts'),
        cost: svc.dartCost,
        buy: svc.buyDart,
      );
      if (bought) {
        setState(() {});
        await _onDart(game, s);
      }
      return;
    }
    final lang = context.read<AppState>().lang;
    final alreadyAbsent = <String>{};
    for (final e in game.keyStates.entries) {
      if (e.value == LetterState.absent) alreadyAbsent.add(e.key);
    }
    final targets = svc.dartTargets(
      answer: game.answer,
      alreadyMarkedAbsent: alreadyAbsent,
      alphabet: _boosterAlphabet(game, lang),
    );
    for (final t in targets) {
      game.keyStates[t] = mergeState(
        game.keyStates[t] ?? LetterState.unknown,
        LetterState.absent,
      );
    }
    svc.useDart();
    setState(() {});
    HapticFeedback.lightImpact();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(s.get('dartUsed')),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  /// Alphabet for [BoosterService.dartTargets]: A–Z for Latin languages,
  /// otherwise the distinct letters of the current language's guess list
  /// (mirrors the keyboard's character set).
  List<String> _boosterAlphabet(GameController game, AppLang lang) {
    // Lowercase for Latin: keyStates keys and answers are normalized to
    // lowercase (see AppLang.normalizeWord), so dartTargets' comparisons
    // must use the same case.
    if (lang.isLatin) return 'abcdefghijklmnopqrstuvwxyz'.split('');
    final set = <String>{};
    for (final w in game.repo.validGuesses) {
      set.addAll(lang.splitLetters(w));
    }
    return set.toList();
  }

  /// Offers to buy a booster when the inventory is empty. Returns true
  /// when a purchase completed.
  Future<bool> _offerBuy(
    S s, {
    required String message,
    required int cost,
    required Future<bool> Function() buy,
  }) async {
    final buyIt = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: WoodTheme.cream,
        title: Text(
          message,
          style: const TextStyle(color: WoodTheme.woodDark, fontSize: 17),
        ),
        content: Text(
          '${s.get('buyFor')} $cost 🪙',
          style: const TextStyle(color: WoodTheme.wood),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(s.get('cancel')),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: WoodTheme.emerald,
              foregroundColor: WoodTheme.cream,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(s.get('buy')),
          ),
        ],
      ),
    );
    if (buyIt != true) return false;
    final ok = await buy();
    if (!mounted) return false;
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(s.get('notEnoughCoins')),
          duration: const Duration(seconds: 1),
        ),
      );
    }
    return ok;
  }

  /// v4.1 WS2: skip booster — confirms, consumes one skip via
  /// `BoosterService.instance.useSkip()`, then abandons the puzzle, which
  /// counts as played-not-won (`GameController.abandon`). When the
  /// inventory is empty the player can buy one for
  /// [BoosterService.skipCost] coins.
  Future<void> _onSkip(GameController game, S s) async {
    if (game.isFinished) return;
    final svc = BoosterService.instance;
    if (svc.skipCount <= 0) {
      if (!mounted) return;
      final bought = await _offerBuy(
        s,
        message: s.get('noSkips'),
        cost: svc.skipCost,
        buy: svc.buySkip,
      );
      if (bought) setState(() {});
      return;
    }
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: WoodTheme.cream,
        title: Text(
          s.get('skipTitle'),
          style: const TextStyle(color: WoodTheme.woodDark),
        ),
        content: Text(
          s.get('skipMsg'),
          style: const TextStyle(color: WoodTheme.wood),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(s.get('cancel')),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: WoodTheme.wood,
              foregroundColor: WoodTheme.cream,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(s.get('skipYes')),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    svc.useSkip();
    HapticFeedback.lightImpact();
    // Abandon → played-not-won: stats record a loss, the daily slot is
    // marked done, and the standard result dialog appears with the answer.
    await game.abandon();
    if (!mounted) return;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final s = appState.s;
    final game = context.watch<GameController>();
    final mode = game.mode;

    // WORKSTREAM 2 (GAMEPLAY): feedback triggers.
    if (game.invalidSubmits > _lastInvalidCount) {
      _lastInvalidCount = game.invalidSubmits;
      WidgetsBinding.instance.addPostFrameCallback((_) => _playInvalidFeedback());
    }
    if (game.rows.length > _lastRowCount) {
      _lastRowCount = game.rows.length;
      if (game.isWon) {
        WidgetsBinding.instance.addPostFrameCallback((_) => _playWinFeedback());
      }
    }

    // Show the result dialog once when the game finishes. On wins the
    // dialog waits ~1.5s so the glow + confetti celebration plays first.
    if (game.isFinished && !_dialogShown) {
      _dialogShown = true;
      if (game.isWon) {
        Future.delayed(const Duration(milliseconds: 1500), () {
          if (context.mounted) _showResultDialog(context, game, s);
        });
      } else {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _showResultDialog(context, game, s);
        });
      }
    }

    final title = mode == GameMode.daily
        ? '${s.puzzleTag(game.puzzleNumber)} • ${game.slot + 1}/${Puzzle.puzzlesPerDay}'
        : mode == GameMode.challenge
            ? s.get('challengeTitle')
            : s.get('practiceMode');

    return Scaffold(
      appBar: AppBar(
        title: Text(title, style: const TextStyle(fontSize: 18)),
        actions: [
          _HintButton(s: s),
          IconButton(
            tooltip: s.get('stats'),
            icon: const Icon(Icons.bar_chart_rounded),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const StatsScreen()),
            ),
          ),
        ],
      ),
      // v4: animated wooden-luxury background behind the game.
      body: AnimatedBackground(
        child: SafeArea(
        child: Column(
          children: [
            // v4.1 WS2: difficulty control — slim expandable bar.
            _DifficultyBar(onChanged: () { /* refresh puzzle */ }),
            SizedBox(
              height: 44,
              child: Center(
                child: game.toast == null
                    ? const SizedBox.shrink()
                    : Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 9),
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(game.toast!,
                            style: const TextStyle(
                                fontWeight: FontWeight.w700, fontSize: 17)),
                      ),
              ),
            ),
            // WORKSTREAM 2 (GAMEPLAY): board with feedback overlays —
            // horizontal shake + red flash on invalid words, green glow
            // pulse + confetti on wins.
            Expanded(
              child: Stack(
                children: [
                  SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: AnimatedBuilder(
                        animation: Listenable.merge(
                            [_shakeController, _winController]),
                        builder: (context, child) {
                          final glowT =
                              sin(_winController.value * pi).clamp(0.0, 1.0);
                          return Transform.translate(
                            offset: Offset(_shakeOffset.value, 0),
                            child: Container(
                              decoration: game.isWon
                                  ? BoxDecoration(
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.green.withValues(
                                              alpha: 0.25 + 0.45 * glowT),
                                          blurRadius: 18 + 26 * glowT,
                                          spreadRadius: 2,
                                        ),
                                      ],
                                    )
                                  : null,
                              child: child,
                            ),
                          );
                        },
                        child: GameBoard(
                          rows: game.rows,
                          evaluations: game.evaluations,
                          current: game.currentRow,
                          lang: appState.lang,
                        ),
                      ),
                    ),
                  ),
                  // Brief red tint on invalid-word submits.
                  AnimatedBuilder(
                    animation: _shakeController,
                    builder: (context, _) {
                      final o = sin(_shakeController.value * pi)
                          .clamp(0.0, 1.0);
                      if (o <= 0.01) return const SizedBox.shrink();
                      return Positioned.fill(
                        child: IgnorePointer(
                          child: Container(
                            color:
                                Colors.red.withValues(alpha: 0.22 * o),
                          ),
                        ),
                      );
                    },
                  ),
                  // Confetti rains on the board on wins (the result dialog
                  // shows it again as before).
                  if (game.isWon) const ConfettiCelebration(),
                ],
              ),
            ),
            // v4.1 WS2: big rounded SUBMIT pill — same behavior as the
            // keyboard's enter key, just prominent like the reference app.
            _SubmitPill(
              s: s,
              enabled: !game.isFinished && game.currentRow.isNotEmpty,
              onSubmit: () {
                HapticFeedback.lightImpact();
                game.submit(s);
              },
            ),
            // v4.1 WS2: booster pills (hint / dart / skip) above keyboard.
            BoostersRow(
              hints: game.hints,
              darts: BoosterService.instance.dartCount,
              skips: BoosterService.instance.skipCount,
              onHint: () => useHintFlow(context, game, s),
              onDart: () => _onDart(game, s),
              onSkip: () => _onSkip(game, s),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 6),
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xFF1B2A4A).withValues(alpha: 0.95),
                    const Color(0xFF0D1B2E).withValues(alpha: 0.98),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFF2E7D32).withValues(alpha: 0.3),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: GameKeyboard(
                lang: appState.lang,
                keyStates: game.keyStates,
                s: s,
                onKey: game.typeLetter,
                onEnter: () => game.submit(s),
                onBackspace: game.backspace,
              ),
            ),
            const SizedBox(height: 4),
            // v4: ad placement slot (banner).
            const AdSlot(slotName: 'game_bottom'),
            const SizedBox(height: 4),
            AdsService.instance.createBanner(),
          ],
        ),
        ),
      ),
    );
  }

  Future<void> _showResultDialog(
      BuildContext context, GameController game, S s) async {
    final appState = context.read<AppState>();
    final stats = StatsService.instance.get(appState.lang);

    // v4 wiring: virtual coins, weekly tournament, play-day streak,
    // milestones, achievements, team wins. All best-effort — rewards must
    // never break the result dialog.
    List<AchievementDef> newAchievements = const [];
    Milestone? milestone;
    try {
      if (game.isWon) {
        await CoinsService.instance.addCoins(10, reason: 'puzzle_win');
        await RewardsService.instance.recordTourneyWin();
        await TeamService.instance.recordTeamWin();
        newAchievements = await AchievementsService.instance.unlockWinRelated(
          totalWins: StatsService.instance.get(appState.lang).wins,
          guesses: game.rows.length,
        );
      }
      await RewardsService.instance.recordPlayDay();
      milestone = await RewardsService.instance.pendingMilestone();
      final streakOnes = await AchievementsService.instance
          .checkStreakUnlocks(RewardsService.instance.playStreak);
      newAchievements = [...newAchievements, ...streakOnes];
    } catch (_) {/* ignore */}

    if (!context.mounted) return;
    // v4.1 WS2: word meaning on wins. lib/game/en_definitions.dart exposes
    // the `enDefinitions` map (uppercase keys); null for non-English or
    // missing words → the row is hidden entirely.
    final meaning = game.isWon
        ? enDefinitions[game.answer.toUpperCase()]
        : null;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Stack(
        children: [
          AlertDialog(
        title: Text(game.isWon ? s.get('youWon') : s.get('youLost')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!game.isWon)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  '${s.get('answerWas')}: ${appState.lang.isLatin ? game.answer.toUpperCase() : game.answer}',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            // v4.1 WS2: 📖 meaning row on wins — hidden entirely when null.
            if (meaning != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  '📖 $meaning',
                  style: const TextStyle(fontStyle: FontStyle.italic),
                ),
              ),
            Text(
                '${s.get('curStreak')}: ${stats.currentStreak}   •   ${s.get('played')}: ${stats.played}'),
            // v4: milestone + newly unlocked achievements.
            if (milestone != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  '🎉 ${s.get('milestoneReached')} +${milestone.coins} ${s.get('coinsLabel')}',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            for (final a in newAchievements)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  '🏆 ${s.get(a.titleKey)}! +${a.coins} ${s.get('coinsLabel')}',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            // EARNING DISABLED (interim build): no reward message shown.
            if (game.mode == GameMode.practice && game.isWon) ...[
              const SizedBox(height: 8),
              Text(s.get('practiceEarnsNothing'),
                  style: const TextStyle(fontSize: 13)),
            ],
            if (game.mode == GameMode.daily) ...[
              const SizedBox(height: 8),
              Text(
                  '${s.get('nextIn')}: ${Puzzle.countdownText(Puzzle.timeUntilNext())}'),
            ],
            // v4: ad placement slot (banner).
            const AdSlot(slotName: 'gameover_dialog'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              // v4: share with clipboard + confirmation snackbar.
              await ShareService.shareWithFeedback(ctx, game.shareText(s));
            },
            child: Text(s.get('share')),
          ),
          if (game.mode == GameMode.daily &&
              game.slot + 1 < Puzzle.puzzlesPerDay)
            FilledButton.tonal(
              onPressed: () {
                Navigator.of(ctx).pop();
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                      builder: (_) =>
                          GameScreen.daily(slot: game.slot + 1)),
                );
              },
              child: Text(s.get('nextPuzzle')),
            ),
          if (game.mode == GameMode.practice)
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                      builder: (_) => const GameScreen.practice()),
                );
              },
              child: Text(s.get('practice')),
            ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(s.get('ok')),
          ),
        ],
          ),
          // Confetti rains on wins!
          if (game.isWon) const ConfettiCelebration(),
        ],
      ),
    );
  }
}

/// v4.1 WS2: slim expandable difficulty bar. Tapping the header reveals
/// the full [DifficultySelector] (segmented Easy/Normal/Hard + hard-mode
/// switch); [onChanged] fires after every change so the host screen can
/// refresh its puzzle.
class _DifficultyBar extends StatefulWidget {
  const _DifficultyBar({required this.onChanged});
  final VoidCallback onChanged;
  @override
  State<_DifficultyBar> createState() => _DifficultyBarState();
}

class _DifficultyBarState extends State<_DifficultyBar> {
  bool _expanded = false;

  String _levelLabel(DifficultyLevel l, S s) => switch (l) {
        DifficultyLevel.easy => s.get('easy'),
        DifficultyLevel.normal => s.get('normal'),
        DifficultyLevel.hard => s.get('hard'),
      };

  @override
  Widget build(BuildContext context) {
    final s = context.read<AppState>().s;
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 6, 12, 0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () => setState(() => _expanded = !_expanded),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: WoodTheme.woodDark.withValues(alpha: 0.85),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: WoodTheme.gold, width: 1),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.tune_rounded,
                      color: WoodTheme.gold, size: 16),
                  const SizedBox(width: 6),
                  ListenableBuilder(
                    listenable: DifficultyService.instance,
                    builder: (context, _) => Text(
                      '${s.get('difficulty')}: ${_levelLabel(DifficultyService.instance.level, s)}',
                      style: const TextStyle(
                        color: WoodTheme.cream,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    _expanded
                        ? Icons.expand_less_rounded
                        : Icons.expand_more_rounded,
                    color: WoodTheme.goldSoft,
                    size: 18,
                  ),
                ],
              ),
            ),
          ),
          if (_expanded)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: DifficultySelector(onChanged: () {
                widget.onChanged();
                setState(() {});
              }),
            ),
        ],
      ),
    );
  }
}

/// v4.1 WS2: big rounded SUBMIT pill — wired to the EXISTING submit/enter
/// handler (`GameController.submit`), same behavior as the keyboard's
/// enter key, just prominent like the reference app.
class _SubmitPill extends StatelessWidget {
  const _SubmitPill({
    required this.s,
    required this.enabled,
    required this.onSubmit,
  });

  final S s;
  final bool enabled;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 4),
      child: Opacity(
        opacity: enabled ? 1.0 : 0.45,
        child: InkWell(
          borderRadius: BorderRadius.circular(28),
          onTap: enabled ? onSubmit : null,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  WoodTheme.lighten(WoodTheme.emerald, 0.12),
                  WoodTheme.emerald,
                  WoodTheme.emeraldDeep,
                ],
              ),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: WoodTheme.gold, width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.30),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Text(
                s.get('submit'),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: WoodTheme.cream,
                  letterSpacing: 3,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Hint flow shared by the app-bar hint button and the BoostersRow hint
/// pill. Preserves the existing behavior: 2 free hints per puzzle first,
/// afterwards 1 hint = 20 coins.
Future<void> useHintFlow(
    BuildContext context, GameController game, S s) async {
  // v4: 2 free hints per puzzle first; afterwards 1 hint = 20 coins.
  if (game.freeHintsLeft <= 0) {
    final coins = CoinsService.instance;
    if (coins.balance >= 20) {
      final spent = await coins.spendCoins(20);
      if (spent) game.addHints(1);
    } else {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(s.get('notEnoughCoins')),
          duration: const Duration(seconds: 1),
        ),
      );
      return;
    }
  }
  final ok = await game.useHint();
  if (!context.mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(ok ? s.get('hintRevealed') : s.get('noHints')),
      duration: const Duration(seconds: 1),
    ),
  );
}

/// Hint button showing remaining hints as 💡×N. Disabled at 0.
/// WORKSTREAM 2 (GAMEPLAY): free-hint system — 2 free hints per puzzle;
/// tap reveals one correct letter in a random unrevealed position and
/// locks that tile.
class _HintButton extends StatelessWidget {
  const _HintButton({required this.s});
  final S s;

  @override
  Widget build(BuildContext context) {
    final game = context.watch<GameController>();
    final n = game.hints;
    final enabled = n > 0 && !game.isFinished;
    return Padding(
      padding: const EdgeInsets.only(right: 2),
      child: TextButton(
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        onPressed: enabled ? () => useHintFlow(context, game, s) : null,
        child: Text(
          '💡×$n',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: enabled ? null : Theme.of(context).disabledColor,
          ),
        ),
      ),
    );
  }
}
