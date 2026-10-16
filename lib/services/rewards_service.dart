import 'package:flutter/foundation.dart';
import '../game/puzzle.dart';
import 'coins_service.dart';
import 'storage_service.dart';

/// Result of a daily-login check.
class DailyReward {
  /// 1-based consecutive login day (1 = first day of the streak).
  final int streakDay;

  /// Coins granted for this day.
  final int coins;

  const DailyReward({required this.streakDay, required this.coins});
}

/// A play-streak milestone: consecutive days on which the player completed
/// at least one puzzle.
class Milestone {
  final int day;
  final int coins;
  final String badgeKey;

  const Milestone({
    required this.day,
    required this.coins,
    required this.badgeKey,
  });
}

/// Daily login rewards, consecutive play-day streaks, streak milestones and
/// the local-only weekly tournament. Everything is persisted in
/// shared_preferences; no network calls.
///
/// PARENT WIRING:
///   - On app open (e.g. home_screen initState):
///       `final reward = await RewardsService.instance.checkDailyReward();`
///       if (reward != null) → show the daily-reward dialog.
///   - On every puzzle completion (win or loss):
///       `await RewardsService.instance.recordPlayDay();`
///       `final m = await RewardsService.instance.pendingMilestone();`
///       if (m != null) → show the milestone dialog.
///   - On every puzzle win (for the weekly tournament):
///       `await RewardsService.instance.recordTourneyWin();`
class RewardsService extends ChangeNotifier {
  RewardsService._();
  static final RewardsService instance = RewardsService._();

  static const _loginKey = 'wd_last_login';
  static const _loginStreakKey = 'wd_login_streak';

  static const _playLastKey = 'wd_play_last';
  static const _playStreakKey = 'wd_play_streak';
  static const _milestonesKey = 'wd_milestones_claimed';

  static const _tourneyBestKey = 'wd_tourney_best';
  static String _tourneyKeyFor(DateTime d) => 'wd_tourney_${weekKey(d)}';

  // -----------------------------------------------------------------
  // Daily login reward
  // -----------------------------------------------------------------

  /// Day 1..7+ → coins. Day 7 and beyond is capped at 50.
  static int loginRewardForDay(int day) {
    if (day <= 1) return 10;
    if (day == 2) return 15;
    if (day == 3) return 20;
    if (day == 4) return 25;
    if (day == 5) return 30;
    if (day == 6) return 40;
    return 50;
  }

  /// Checks whether a new calendar day has started since the last app open.
  /// If so, advances the consecutive-login streak (reset when the gap is more
  /// than one day), grants the day's coins immediately, persists everything
  /// and returns the reward so the caller can show a dialog. Returns null when
  /// today's reward was already claimed. Idempotent and safe to call often.
  Future<DailyReward?> checkDailyReward() async {
    final prefs = StorageService.instance;
    final today = Puzzle.dateKey(DateTime.now());
    if (prefs.getString(_loginKey) == today) return null;

    final yesterday = Puzzle.dateKey(
        DateTime.now().subtract(const Duration(days: 1)));
    var streak = prefs.getInt(_loginStreakKey) ?? 0;
    streak = (prefs.getString(_loginKey) == yesterday) ? streak + 1 : 1;

    final coins = loginRewardForDay(streak);
    await prefs.setInt(_loginStreakKey, streak);
    await prefs.setString(_loginKey, today);
    await CoinsService.instance.addCoins(coins, reason: 'daily_login');
    _notify();
    return DailyReward(streakDay: streak, coins: coins);
  }

  int get loginStreak => StorageService.instance.getInt(_loginStreakKey) ?? 0;

  // -----------------------------------------------------------------
  // Consecutive play-day streak + milestones
  // -----------------------------------------------------------------

  /// A play day = a calendar day on which the player completed at least one
  /// puzzle. Self-healing: a streak with a gap older than yesterday reads 0
  /// until the player plays again.
  int get playStreak {
    final prefs = StorageService.instance;
    final last = prefs.getString(_playLastKey);
    if (last == null || last.isEmpty) return 0;
    final today = Puzzle.dateKey(DateTime.now());
    if (last == today) return prefs.getInt(_playStreakKey) ?? 0;
    final yesterday = Puzzle.dateKey(
        DateTime.now().subtract(const Duration(days: 1)));
    return last == yesterday ? (prefs.getInt(_playStreakKey) ?? 0) : 0;
  }

  /// Records that the player completed a puzzle today. Parent calls this once
  /// per puzzle completion (win or loss). Idempotent within a day.
  Future<void> recordPlayDay() async {
    final prefs = StorageService.instance;
    final today = Puzzle.dateKey(DateTime.now());
    if (prefs.getString(_playLastKey) == today) return;

    final yesterday = Puzzle.dateKey(
        DateTime.now().subtract(const Duration(days: 1)));
    final previous = prefs.getInt(_playStreakKey) ?? 0;
    final streak =
        (prefs.getString(_playLastKey) == yesterday) ? previous + 1 : 1;
    await prefs.setInt(_playStreakKey, streak);
    await prefs.setString(_playLastKey, today);
    _notify();
  }

  static const _milestones = <Milestone>[
    Milestone(day: 7, coins: 50, badgeKey: 'achWeekWarrior'),
    Milestone(day: 14, coins: 120, badgeKey: 'achWeekWarrior'),
    Milestone(day: 30, coins: 300, badgeKey: 'achMonthLegend'),
  ];

  Set<int> _claimedMilestones() {
    final raw = StorageService.instance.getJson(_milestonesKey);
    if (raw == null) return <int>{};
    final list = raw['claimed'] as List?;
    if (list == null) return <int>{};
    return list.map((e) => (e as num).toInt()).toSet();
  }

  Future<void> _markMilestoneClaimed(int day) async {
    final claimed = _claimedMilestones()..add(day);
    await StorageService.instance.setJson(
        _milestonesKey, {'claimed': claimed.toList()});
  }

  /// Returns the first unclaimed streak milestone the player has reached,
  /// grants its bonus coins, marks it claimed and returns it so the caller
  /// can show a dialog. Returns null when nothing is pending. Safe to call
  /// repeatedly — each milestone is granted exactly once.
  Future<Milestone?> pendingMilestone() async {
    final streak = playStreak;
    final claimed = _claimedMilestones();
    for (final m in _milestones) {
      if (streak >= m.day && !claimed.contains(m.day)) {
        await _markMilestoneClaimed(m.day);
        await CoinsService.instance
            .addCoins(m.coins, reason: 'streak_milestone_${m.day}d');
        _notify();
        return m;
      }
    }
    return null;
  }

  // -----------------------------------------------------------------
  // Weekly tournament (LOCAL-ONLY for now; future Supabase global sync)
  // -----------------------------------------------------------------
  //
  // Wins are bucketed per calendar week. The week key is the date of the
  // week's Monday (e.g. "2026-10-12"), so weeks reset on Monday. When the
  // future global leaderboard lands, `recordTourneyWin()` is the single call
  // site to also sync the win to Supabase.

  /// Week key = date key of the week's Monday (local time). Resets every
  /// Monday.
  static String weekKey(DateTime d) {
    final monday = d.subtract(Duration(days: d.weekday - 1));
    return Puzzle.dateKey(monday);
  }

  /// Records one win for the current calendar week and updates the all-time
  /// best week. Parent calls this on every puzzle win.
  Future<void> recordTourneyWin() async {
    final prefs = StorageService.instance;
    final key = _tourneyKeyFor(DateTime.now());
    final wins = (prefs.getInt(key) ?? 0) + 1;
    await prefs.setInt(key, wins);
    final best = prefs.getInt(_tourneyBestKey) ?? 0;
    if (wins > best) await prefs.setInt(_tourneyBestKey, wins);
    _notify();
  }

  /// Wins recorded in the current calendar week (Monday reset).
  int currentWeekWins() =>
      StorageService.instance.getInt(_tourneyKeyFor(DateTime.now())) ?? 0;

  /// Most wins recorded in any single week.
  int bestWeekEver() => StorageService.instance.getInt(_tourneyBestKey) ?? 0;

  /// Flavor rank tier: 0 = Bronze (<3), 1 = Silver (<7), 2 = Gold (<12),
  /// 3 = Diamond (12+).
  static int rankTier(int wins) {
    if (wins >= 12) return 3;
    if (wins >= 7) return 2;
    if (wins >= 3) return 1;
    return 0;
  }

  /// Wins still needed to reach the next tier (0 when already Diamond).
  static int winsToNextTier(int wins) {
    if (wins >= 12) return 0;
    if (wins >= 7) return 12 - wins;
    if (wins >= 3) return 7 - wins;
    return 3 - wins;
  }

  void _notify() {
    Future.microtask(() {
      try {
        notifyListeners();
      } catch (_) {}
    });
  }
}
