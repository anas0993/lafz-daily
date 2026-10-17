import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../data/word_repository.dart';
import '../game/lang_utils.dart';
import '../l10n/strings.dart';
import '../main.dart';
import '../services/achievements_service.dart';
import '../services/coins_service.dart';
import '../services/storage_service.dart';
import '../widgets/ad_slot.dart';
import '../widgets/animated_background.dart';
import '../widgets/confetti_celebration.dart';
import '../widgets/wood_theme.dart';

/// Scramble mode: a random 5-letter answer word is shuffled and the player
/// taps the tray letters to rebuild it in the slots.
///
/// WORKSTREAM 2 (GAMEPLAY) — new screen. No new pubspec dependencies:
/// animations use AnimationController, haptics use HapticFeedback, and the
/// win celebration reuses [ConfettiCelebration].
class ScrambleScreen extends StatelessWidget {
  const ScrambleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _ScrambleView();
  }
}

class _ScrambleView extends StatefulWidget {
  const _ScrambleView();

  @override
  State<_ScrambleView> createState() => _ScrambleViewState();
}

class _ScrambleViewState extends State<_ScrambleView>
    with TickerProviderStateMixin {
  final _rng = Random();

  late final AppLang _lang;
  late final WordRepository _repo;
  late String _answer;
  late List<String> _tray; // shuffled letters
  late List<bool> _trayUsed;
  List<String?> _slots = List<String?>.filled(5, null);

  int _wins = 0;
  bool _won = false;
  String? _messageKey; // 'scrambleHelp' | 'scrambleWrong' | 'scrambleWin'

  late final AnimationController _shakeController;
  late final Animation<double> _shakeOffset;
  late final AnimationController _glowController;

  @override
  void initState() {
    super.initState();
    _lang = context.read<AppState>().lang;
    _repo = WordRepository(_lang);
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
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _newWord(first: true);
    _loadWins();
  }

  @override
  void dispose() {
    _shakeController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  Future<void> _loadWins() async {
    _wins = StorageService.instance.getInt('scramble_wins_total') ?? 0;
    if (mounted) setState(() {});
  }

  /// Picks a new random answer and shuffles its letters (never leaving the
  /// tray in the solved order).
  void _newWord({bool first = false}) {
    var answer = _repo.randomAnswer(_rng);
    if (!first) {
      var guard = 0;
      while (answer == _answer && guard++ < 10) {
        answer = _repo.randomAnswer(_rng);
      }
    }
    _answer = answer;
    final letters = _repo.answerLetters(_answer);
    var shuffled = List<String>.from(letters)..shuffle(_rng);
    var guard = 0;
    while (_sameOrder(shuffled, letters) && guard++ < 10) {
      shuffled = List<String>.from(letters)..shuffle(_rng);
    }
    _tray = shuffled;
    _trayUsed = List<bool>.filled(_tray.length, false);
    _slots = List<String?>.filled(5, null);
    _won = false;
    _messageKey = 'scrambleHelp';
    _glowController.stop();
    _glowController.reset();
    if (!first && mounted) setState(() {});
  }

  bool _sameOrder(List<String> a, List<String> b) {
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  bool get _complete => _slots.every((s) => s != null);

  void _tapTray(int i) {
    if (_won || _trayUsed[i]) return;
    final slot = _slots.indexWhere((s) => s == null);
    if (slot == -1) return;
    setState(() {
      _slots[slot] = _tray[i];
      _trayUsed[i] = true;
      _messageKey = null;
    });
    HapticFeedback.lightImpact();
  }

  void _tapSlot(int j) {
    final letter = _slots[j];
    if (_won || letter == null) return;
    // Free the first used tray tile holding this letter.
    var freed = -1;
    for (var i = 0; i < _tray.length; i++) {
      if (_trayUsed[i] && _tray[i] == letter) {
        freed = i;
        break;
      }
    }
    if (freed == -1) return;
    setState(() {
      _slots[j] = null;
      _trayUsed[freed] = false;
    });
    HapticFeedback.lightImpact();
  }

  void _check() {
    if (!_complete || _won) return;
    final guess = _slots.map((s) => s ?? '').join();
    if (guess == _answer) {
      _win();
    } else {
      _wrong();
    }
  }

  Future<void> _win() async {
    _won = true;
    _messageKey = 'scrambleWin';
    _wins++;
    await StorageService.instance.setInt('scramble_wins_total', _wins);
    // v4 wiring: coins + scramble achievements (best-effort).
    try {
      await CoinsService.instance.addCoins(15, reason: 'scramble_win');
      final newOnes =
          await AchievementsService.instance.checkScrambleUnlocks(_wins);
      if (newOnes.isNotEmpty && mounted) {
        final s = context.read<AppState>().s;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                '🏆 ${s.get(newOnes.first.titleKey)}! +${newOnes.first.coins} ${s.get('coinsLabel')}'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (_) {/* ignore */}
    if (!mounted) return;
    HapticFeedback.heavyImpact();
    _glowController.repeat();
    setState(() {});
  }

  void _wrong() {
    _messageKey = 'scrambleWrong';
    HapticFeedback.vibrate();
    _shakeController.forward(from: 0);
    // Clear the slots for a retry once the shake finishes.
    Future.delayed(const Duration(milliseconds: 480), () {
      if (!mounted || _won) return;
      setState(() {
        _slots = List<String?>.filled(5, null);
        _trayUsed = List<bool>.filled(_tray.length, false);
      });
    });
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>().s;
    final scheme = Theme.of(context).colorScheme;
    final rtl = _lang.isRtl;

    return Scaffold(
      appBar: AppBar(
        title: Text(s.get('scramble')),
        backgroundColor: WoodTheme.emerald,
        foregroundColor: WoodTheme.cream,
      ),
      body: AnimatedBackground(
        child: SafeArea(
          child: Stack(
          children: [
            Column(
              children: [
                const SizedBox(height: 8),
                // Scramble wins counter.
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: scheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: WoodTheme.gold.withValues(alpha: 0.5)),
                  ),
                  child: Text(
                    '🏆 ×$_wins  •  ${s.get('scrambleWins')}',
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w700),
                  ),
                ),
                const SizedBox(height: 20),
                // Answer slots (shake on wrong, green glow on win).
                AnimatedBuilder(
                  animation:
                      Listenable.merge([_shakeController, _glowController]),
                  builder: (context, child) {
                    final flash =
                        sin(_shakeController.value * pi).clamp(0.0, 1.0);
                    final glow =
                        sin(_glowController.value * pi).clamp(0.0, 1.0);
                    return Transform.translate(
                      offset: Offset(_shakeOffset.value, 0),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          color: flash > 0.01
                              ? Colors.red.withValues(alpha: 0.18 * flash)
                              : null,
                          boxShadow: _won
                              ? [
                                  BoxShadow(
                                    color: WoodTheme.emerald.withValues(
                                        alpha: 0.3 + 0.45 * glow),
                                    blurRadius: 16 + 24 * glow,
                                    spreadRadius: 2,
                                  ),
                                ]
                              : null,
                        ),
                        child: child,
                      ),
                    );
                  },
                  child: Directionality(
                    textDirection:
                        rtl ? TextDirection.rtl : TextDirection.ltr,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        for (var j = 0; j < 5; j++)
                          _SlotTile(
                            letter: _slots[j],
                            lang: _lang,
                            filled: _slots[j] != null,
                            won: _won,
                            onTap: () => _tapSlot(j),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // Status / feedback message.
                SizedBox(
                  height: 28,
                  child: _messageKey == null
                      ? const SizedBox.shrink()
                      : Text(
                          s.get(_messageKey!),
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: _messageKey == 'scrambleWin'
                                ? WoodTheme.emerald
                                : _messageKey == 'scrambleWrong'
                                    ? Colors.red
                                    : scheme.onSurfaceVariant,
                          ),
                        ),
                ),
                const SizedBox(height: 8),
                // Letter tray.
                Directionality(
                  textDirection: rtl ? TextDirection.rtl : TextDirection.ltr,
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      for (var i = 0; i < _tray.length; i++)
                        _TrayTile(
                          letter: _tray[i],
                          lang: _lang,
                          used: _trayUsed[i],
                          onTap: () => _tapTray(i),
                        ),
                    ],
                  ),
                ),
                const Spacer(),
                // Check + New word buttons.
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    children: [
                      Expanded(
                        child: FilledButton(
                          onPressed: _complete && !_won ? _check : null,
                          child: Text(s.get('scrambleCheck'),
                              style:
                                  const TextStyle(fontWeight: FontWeight.w800)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _newWord(),
                          icon: const Icon(Icons.refresh_rounded, size: 18),
                          label: Text(s.get('scrambleNewWord')),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                // v4: ad placement slot (banner).
                const AdSlot(slotName: 'scramble_bottom'),
                const SizedBox(height: 4),
              ],
            ),
            // Win celebration.
            if (_won) const ConfettiCelebration(),
          ],
        ),
        ),
      ),
    );
  }
}

/// One answer slot. Tapping a filled slot sends its letter back to the tray.
class _SlotTile extends StatelessWidget {
  const _SlotTile({
    required this.letter,
    required this.lang,
    required this.filled,
    required this.won,
    required this.onTap,
  });

  final String? letter;
  final AppLang lang;
  final bool filled;
  final bool won;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 58,
        height: 58,
        margin: const EdgeInsets.symmetric(horizontal: 3),
        decoration: BoxDecoration(
          color: won
              ? WoodTheme.emerald
              : filled
                  ? scheme.primaryContainer
                  : scheme.surfaceContainerHighest,
          border: Border.all(
            color: won
                ? Colors.transparent
                : filled
                    ? scheme.primary
                    : scheme.outlineVariant,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        alignment: Alignment.center,
        child: Text(
          letter == null ? '' : (lang.isLatin ? letter!.toUpperCase() : letter!),
          style: TextStyle(
            fontSize: lang.isLatin ? 30 : 32,
            fontWeight: FontWeight.w800,
            color: won
                ? Colors.white
                : filled
                    ? scheme.onPrimaryContainer
                    : scheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

/// One tappable tray letter.
class _TrayTile extends StatelessWidget {
  const _TrayTile({
    required this.letter,
    required this.lang,
    required this.used,
    required this.onTap,
  });

  final String letter;
  final AppLang lang;
  final bool used;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: used ? null : onTap,
      child: Opacity(
        opacity: used ? 0.25 : 1.0,
        child: Container(
          width: 58,
          height: 58,
          decoration: BoxDecoration(
            color: used ? scheme.surfaceContainerHighest : WoodTheme.wood,
            borderRadius: BorderRadius.circular(10),
            boxShadow: used
                ? null
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.25),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
          ),
          alignment: Alignment.center,
          child: Text(
            lang.isLatin ? letter.toUpperCase() : letter,
            style: const TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
