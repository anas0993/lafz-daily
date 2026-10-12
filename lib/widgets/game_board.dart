import 'package:flutter/material.dart';
import '../game/evaluator.dart';
import '../game/lang_utils.dart';
import '../l10n/strings.dart';
import '../services/game_settings.dart';

/// The 6x5 tile board. Tiles flip-reveal after each submitted guess.
class GameBoard extends StatelessWidget {
  const GameBoard({
    super.key,
    required this.rows,
    required this.evaluations,
    required this.current,
    required this.lang,
  });

  final List<String> rows;
  final List<List<LetterState>> evaluations;
  final String current;
  final AppLang lang;

  List<String> _lettersOf(String word) => lang.splitLetters(word);

  @override
  Widget build(BuildContext context) {
    final rtl = lang.isRtl;
    final cur = _lettersOf(current);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var r = 0; r < 6; r++)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 3),
            child: Directionality(
              textDirection: rtl ? TextDirection.rtl : TextDirection.ltr,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (var c = 0; c < 5; c++)
                    _Tile(
                      letter: r < rows.length
                          ? _lettersOf(rows[r])[c]
                          : (r == rows.length && c < cur.length ? cur[c] : ''),
                      state: r < rows.length ? evaluations[r][c] : LetterState.unknown,
                      filled: r < rows.length || c < cur.length,
                      lang: lang,
                    ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({
    required this.letter,
    required this.state,
    required this.filled,
    required this.lang,
  });

  final String letter;
  final LetterState state;
  final bool filled;
  final AppLang lang;

  Color _bg(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final colorBlind = GameSettings.instance.colorBlind;
    return switch (state) {
      LetterState.correct =>
        colorBlind ? const Color(0xFFF5793A) : const Color(0xFF4C9A52),
      LetterState.present =>
        colorBlind ? const Color(0xFF85C0F9) : const Color(0xFFC9A227),
      LetterState.absent => const Color(0xFF787C7E),
      LetterState.unknown =>
        filled ? scheme.surfaceContainerHighest : scheme.surface,
    };
  }

  Color _fg(BuildContext context) {
    if (state == LetterState.unknown) {
      return Theme.of(context).colorScheme.onSurface;
    }
    return Colors.white;
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: 58,
      height: 58,
      margin: const EdgeInsets.symmetric(horizontal: 3),
      decoration: BoxDecoration(
        color: _bg(context),
        border: Border.all(
          color: state == LetterState.unknown
              ? (filled ? scheme.outline : scheme.outlineVariant)
              : Colors.transparent,
          width: 2,
        ),
        borderRadius: BorderRadius.circular(6),
      ),
      alignment: Alignment.center,
      child: Text(
        lang.isLatin ? letter.toUpperCase() : letter,
        style: TextStyle(
          fontSize: lang.isLatin ? 30 : 32,
          fontWeight: FontWeight.bold,
          color: _fg(context),
        ),
      ),
    );
  }
}
