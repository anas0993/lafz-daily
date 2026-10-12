import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import '../game/evaluator.dart';
import '../l10n/strings.dart';

/// Builds the emoji-square share text (Wordle-style, original branding).
class ShareService {
  static String _square(LetterState s) => switch (s) {
        LetterState.correct => '🟩',
        LetterState.present => '🟨',
        _ => '⬛',
      };

  static String buildText({
    required S s,
    required int puzzleNumber,
    required bool won,
    required int attempts, // attempts used (1..6) when won
    required List<List<LetterState>> rows,
  }) {
    final tag = s.puzzleTag(puzzleNumber);
    final score = won ? '$attempts/6' : 'X/6';
    final buf = StringBuffer('$tag  $score\n');
    for (final row in rows) {
      for (final st in row) {
        buf.write(_square(st));
      }
      buf.writeln();
    }
    return buf.toString();
  }

  static Future<void> share(String text) => Share.share(text);

  static Future<void> copy(String text) =>
      Clipboard.setData(ClipboardData(text: text));
}
