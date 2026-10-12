import '../game/puzzle.dart';
import '../l10n/strings.dart';
import 'storage_service.dart';

/// Per-language statistics, persisted locally as JSON.
///
/// Streaks only count daily puzzles. Practice games count toward
/// played/wins but never affect the streak.
class Stats {
  int played = 0;
  int wins = 0;
  int currentStreak = 0;
  int maxStreak = 0;
  List<int> distribution = List.filled(6, 0); // wins by guess count 1..6
  String lastPlayedDate = ''; // dateKey of last daily game

  Stats();

  Stats.fromJson(Map<String, dynamic> j) {
    played = (j['played'] as num?)?.toInt() ?? 0;
    wins = (j['wins'] as num?)?.toInt() ?? 0;
    currentStreak = (j['currentStreak'] as num?)?.toInt() ?? 0;
    maxStreak = (j['maxStreak'] as num?)?.toInt() ?? 0;
    final d = j['distribution'] as List?;
    if (d != null && d.length == 6) {
      distribution = d.map((e) => (e as num).toInt()).toList();
    }
    lastPlayedDate = (j['lastPlayedDate'] as String?) ?? '';
  }

  Map<String, dynamic> toJson() => {
        'played': played,
        'wins': wins,
        'currentStreak': currentStreak,
        'maxStreak': maxStreak,
        'distribution': distribution,
        'lastPlayedDate': lastPlayedDate,
      };

  double get winPct => played == 0 ? 0 : wins / played * 100;
}

class StatsService {
  StatsService._();
  static final StatsService instance = StatsService._();

  final _cache = <AppLang, Stats>{};

  String _key(AppLang lang) => 'stats_${lang.name}';

  Stats get(AppLang lang) {
    return _cache.putIfAbsent(lang, () {
      final j = StorageService.instance.getJson(_key(lang));
      return j == null ? Stats() : Stats.fromJson(j);
    });
  }

  Future<void> _save(AppLang lang) =>
      StorageService.instance.setJson(_key(lang), get(lang).toJson());

  /// Records a finished game.
  /// [isDaily]: daily puzzles count toward played/wins; only *today's*
  /// puzzle affects the streak (archive replays don't).
  /// [dateKey]: the puzzle's calendar date key.
  Future<void> recordGame({
    required AppLang lang,
    required bool won,
    required int guesses, // 1..6, meaningful when won
    required bool isDaily,
    String? dateKey,
  }) async {
    final s = get(lang);
    s.played++;
    if (won) {
      s.wins++;
      if (guesses >= 1 && guesses <= 6) s.distribution[guesses - 1]++;
    }
    if (isDaily && dateKey != null) {
      final todayKey = Puzzle.dateKey(DateTime.now());
      if (dateKey == todayKey) {
        final yesterdayKey = Puzzle.dateKey(
            DateTime.now().subtract(const Duration(days: 1)));
        if (s.lastPlayedDate == yesterdayKey || s.lastPlayedDate.isEmpty) {
          // Consecutive day (or first ever game).
          s.currentStreak = won ? s.currentStreak + 1 : 0;
        } else if (s.lastPlayedDate != todayKey) {
          // Missed at least one day: streak restarts.
          s.currentStreak = won ? 1 : 0;
        }
        // Replaying today's puzzle: streak unchanged.
        if (s.currentStreak > s.maxStreak) s.maxStreak = s.currentStreak;
        s.lastPlayedDate = todayKey;
      }
      // Archive dates: played/wins counted above, streak untouched.
    }
    await _save(lang);
  }
}
