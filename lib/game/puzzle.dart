import '../config/app_config.dart';

/// Date-deterministic daily puzzle logic.
///
/// The puzzle for any calendar day is derived purely from the date, so every
/// player worldwide gets the same word with no server involved. The puzzle
/// resets at midnight local time.
class Puzzle {
  /// Number of days since the epoch (1-based puzzle number).
  static int dayNumber(DateTime date) {
    final d = DateTime(date.year, date.month, date.day);
    return d.difference(AppConfig.epoch).inDays + 1;
  }

  /// Deterministically picks the answer for [date] from [answers].
  /// Uses a splitmix64-style hash so consecutive days don't get adjacent
  /// words from the list.
  static String dailyAnswer(List<String> answers, DateTime date) =>
      dailyAnswerForSlot(answers, date, 0);

  /// Number of puzzles per day.
  static const int puzzlesPerDay = 5;

  /// Deterministically picks the answer for [date] and [slot] (0-4).
  /// Each slot gets a different word, so every player gets the same 5
  /// words each day with no server involved.
  static String dailyAnswerForSlot(
      List<String> answers, DateTime date, int slot) {
    var z = (dayNumber(date) * puzzlesPerDay + slot) * 0x9E3779B97F4A7C15 +
        0xBF58476D1CE4E5B9;
    z = (z ^ (z >> 30)) * 0xBF58476D1CE4E5B9;
    z = (z ^ (z >> 27)) * 0x94D049BB133111EB;
    z = z ^ (z >> 31);
    final idx = (z.abs() % answers.length).toInt();
    return answers[idx];
  }

  /// Local midnight key used for storage, e.g. "2026-10-11".
  static String dateKey(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';

  /// Time remaining until the next puzzle (local midnight).
  static Duration timeUntilNext() {
    final now = DateTime.now();
    final midnight = DateTime(now.year, now.month, now.day + 1);
    return midnight.difference(now);
  }

  static String countdownText(Duration d) {
    final h = d.inHours.toString().padLeft(2, '0');
    final m = (d.inMinutes % 60).toString().padLeft(2, '0');
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }
}
