import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../data/word_repository.dart';
import '../game/lang_utils.dart';
import '../game/puzzle.dart';
import '../l10n/strings.dart';
import '../main.dart';
import '../services/ads_service.dart';
import '../services/achievements_service.dart';
import '../services/coins_service.dart';
import '../services/rewards_service.dart';
import '../services/share_service.dart';
import '../services/stats_service.dart';
import '../services/team_service.dart';
import '../state/game_controller.dart';
import '../widgets/ad_slot.dart';
import '../widgets/animated_background.dart';
import '../widgets/confetti_celebration.dart';
import '../widgets/game_board.dart';
import '../widgets/game_keyboard.dart';
import '../widgets/tutorial_overlay.dart';
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
    return ChangeNotifierProvider(
      create: (_) {
        final c = GameController(
          repo: WordRepository(appState.lang),
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
        onPressed: enabled ? () => _onHint(context, game) : null,
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

  Future<void> _onHint(BuildContext context, GameController game) async {
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
}
