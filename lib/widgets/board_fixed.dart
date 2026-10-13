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
      // Wooden theme - warm natural wood colors
      LetterState.correct =>
        colorBlind ? const Color(0xFF8D6E63) : const Color(0xFF5D4037), // Rich dark wood
      LetterState.present =>
        colorBlind ? const Color(0xFFBCAAA4) : const Color(0xFFA1887F), // Warm medium wood
      LetterState.absent => const Color(0xFF4E342E), // Dark weathered wood
      LetterState.unknown =>
        filled ? const Color(0xFFD7CCC8) : const Color(0xFFEFEBE9), // Light natural wood
    };
  }

  Color _fg(BuildContext context) {
    if (state == LetterState.unknown) {
      return const Color(0xFF3E2723); // Dark wood text on light wood
    }
    return const Color(0xFFFFF8E1); // Cream text on dark wood
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isRevealed = state != LetterState.unknown;
    return Container(
      width: 60,
      height: 60,
      margin: const EdgeInsets.symmetric(horizontal: 3),
      decoration: BoxDecoration(
        color: _bg(context),
        border: Border.all(
          color: state == LetterState.unknown
              ? (filled ? scheme.outline : scheme.outlineVariant)
              : Colors.transparent,
          width: 2,
        ),
        borderRadius: BorderRadius.circular(10),
        // Premium shadow for revealed tiles
        boxShadow: isRevealed
            ? [
                BoxShadow(
                  color: _bg(context).withOpacity(0.4),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ]
            : null,
      ),
      alignment: Alignment.center,
      child: Text(
        lang.isLatin ? letter.toUpperCase() : letter,
        style: TextStyle(
          fontSize: lang.isLatin ? 32 : 34,
          fontWeight: FontWeight.w800,
          color: _fg(context),
          // Better letter rendering
          letterSpacing: 0.5,
          shadows: isRevealed
              ? [
                  const Shadow(
                    color: Colors.black26,
                    offset: Offset(0, 1),
                    blurRadius: 2,
                  ),
                ]
              : null,
        ),
      ),
    );
  }
}
