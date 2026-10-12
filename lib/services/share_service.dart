import 'package:flutter/services.dart';
import '../game/evaluator.dart';
import '../l10n/strings.dart';

/// Stub: share disabled in the clean build. Copies to clipboard instead.
class ShareService {
  ShareService._();

  static String _square(LetterState s) => switch (s) {
        LetterState.correct => '🟩',
        LetterState.present => '🟨',
        _ => '⬛',
      };

  static String buildText({
    required S s,
    required int puzzleNumber,
    required bool won,
    required int attempts,
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

  static Future<void> share(String text) async {
    await Clipboard.setData(ClipboardData(text: text));
  }
}
