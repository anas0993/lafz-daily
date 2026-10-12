import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart' hide AppState;
import 'package:provider/provider.dart';
import '../data/word_repository.dart';
import '../game/lang_utils.dart';
import '../game/puzzle.dart';
import '../l10n/strings.dart';
import '../main.dart';
import '../services/ads_service.dart';
import '../services/billing_service.dart';
import '../services/share_service.dart';
import '../services/stats_service.dart';
import '../state/game_controller.dart';
import '../widgets/game_board.dart';
import '../widgets/game_keyboard.dart';
import 'stats_screen.dart';

/// Game screen. Use the named constructors:
///   GameScreen.daily()            — today's puzzle
///   GameScreen.dailyAt(date)      — archive puzzle (Pro)
///   GameScreen.practice()         — unlimited random words
class GameScreen extends StatelessWidget {
  final GameMode mode;
  final DateTime? date;

  const GameScreen.daily({super.key})
      : mode = GameMode.daily,
        date = null;
  const GameScreen.dailyAt(this.date, {super.key}) : mode = GameMode.daily;
  const GameScreen.practice({super.key})
      : mode = GameMode.practice,
        date = null;

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    return ChangeNotifierProvider(
      create: (_) {
        final c = GameController(
          repo: WordRepository(appState.lang),
          mode: mode,
          date: date,
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

class _GameViewState extends State<_GameView> {
  BannerAd? _bannerAd;
  bool _dialogShown = false;

  @override
  void initState() {
    super.initState();
    if (!BillingService.instance.isPro.value) {
      _bannerAd = AdsService.instance.createBanner();
    }
    BillingService.instance.isPro.addListener(_onProChanged);
  }

  void _onProChanged() {
    if (BillingService.instance.isPro.value && mounted) {
      setState(() {
        _bannerAd?.dispose();
        _bannerAd = null;
      });
    }
  }

  @override
  void dispose() {
    BillingService.instance.isPro.removeListener(_onProChanged);
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final s = appState.s;
    final game = context.watch<GameController>();
    final mode = game.mode;

    // Show the result dialog once when the game finishes.
    if (game.isFinished && !_dialogShown) {
      _dialogShown = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _showResultDialog(context, game, s);
      });
    }

    final title = mode == GameMode.daily
        ? s.puzzleTag(game.puzzleNumber)
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
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: GameBoard(
                    rows: game.rows,
                    evaluations: game.evaluations,
                    current: game.current,
                    lang: appState.lang,
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 28,
              child: Center(
                child: game.toast == null
                    ? const SizedBox.shrink()
                    : Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 5),
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(game.toast!,
                            style:
                                const TextStyle(fontWeight: FontWeight.w600)),
                      ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
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
            if (_bannerAd != null)
              SizedBox(
                width: _bannerAd!.size.width.toDouble(),
                height: _bannerAd!.size.height.toDouble(),
                child: AdWidget(ad: _bannerAd!),
              ),
          ],
        ),
      ),
    );
  }

  void _showResultDialog(
      BuildContext context, GameController game, S s) {
    final appState = context.read<AppState>();
    final stats = StatsService.instance.get(appState.lang);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
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
            if (game.mode == GameMode.daily) ...[
              const SizedBox(height: 8),
              Text(
                  '${s.get('nextIn')}: ${Puzzle.countdownText(Puzzle.timeUntilNext())}'),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              await ShareService.share(game.shareText(s));
            },
            child: Text(s.get('share')),
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
    );
  }
}

/// Hint button with remaining-count badge. Pro users still get the daily
/// free hint; rewarded ads are hidden for Pro (extra hints unlimited? no —
/// Pro simply removes ads, hints still limited to keep game balance).
class _HintButton extends StatefulWidget {
  const _HintButton({required this.s});
  final S s;
  @override
  State<_HintButton> createState() => _HintButtonState();
}

class _HintButtonState extends State<_HintButton> {
  bool _busy = false;

  @override
  Widget build(BuildContext context) {
    final game = context.watch<GameController>();
    final isPro = BillingService.instance.isPro.value;
    return Stack(
      alignment: Alignment.topRight,
      children: [
        IconButton(
          tooltip: widget.s.get('hint'),
          icon: const Icon(Icons.lightbulb_outline_rounded),
          onPressed: game.isFinished || _busy
              ? null
              : () => _onHint(context, game, isPro),
        ),
        if (game.hints > 0)
          Container(
            margin: const EdgeInsets.only(top: 6, right: 6),
            padding:
                const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text('${game.hints}',
                style: const TextStyle(
                    fontSize: 10,
                    color: Colors.white,
                    fontWeight: FontWeight.w700)),
          ),
      ],
    );
  }

  Future<void> _onHint(
      BuildContext context, GameController game, bool isPro) async {
    final s = widget.s;
    if (game.hints > 0) {
      final ok = await game.useHint();
      if (!ok && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(s.get('notEnough'))),
        );
      }
      return;
    }
    // No hints left: offer rewarded ad (free users only).
    if (isPro) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(s.get('noHints'))),
        );
      }
      return;
    }
    final want = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(s.get('hint')),
        content: Text(s.get('watchAdHint')),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: Text(s.get('cancel'))),
          FilledButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: Text(s.get('ok'))),
        ],
      ),
    );
    if (want != true || !context.mounted) return;
    setState(() => _busy = true);
    if (!AdsService.instance.rewardedReady && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(s.get('adLoading'))),
      );
      await Future.delayed(const Duration(seconds: 2));
    }
    final earned = await game.earnHintViaAd();
    if (!mounted) return;
    setState(() => _busy = false);
    if (earned) {
      await game.useHint();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(s.get('hintRevealed'))),
        );
      }
    } else if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(s.get('adNotReady'))),
      );
    }
  }
}
