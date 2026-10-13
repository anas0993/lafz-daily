import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'backend_service.dart';
import 'storage_service.dart';

/// Points wallet: a fixed reward is credited for every daily puzzle win
/// (5 puzzles per day max). Practice games never earn — otherwise the
/// reward could be farmed without limit.
///
/// Balance is stored as integer cents to avoid float rounding errors.
/// Each puzzle can only pay out once (tracked by puzzle key), so replaying
/// or restoring a finished game never double-pays. A lifetime counter is
/// kept so the owner can always see the total payout (their investment).
class PointsService extends ChangeNotifier {
  PointsService._();
  static final PointsService instance = PointsService._();

  /// Reward per daily puzzle win, in cents ($0.05).
  static const int winRewardCents = 5;

  static const _balanceKey = 'points_balance_cents';
  static const _historyKey = 'points_history_json';
  static const _awardedKey = 'points_awarded_keys';
  static const _lifetimeKey = 'points_lifetime_cents';
  static const int _maxHistory = 200;

  int get balanceCents => StorageService.instance.getInt(_balanceKey) ?? 0;

  String get balanceText =>
      '\$${(balanceCents / 100).toStringAsFixed(2)}';

  int get lifetimeCents => StorageService.instance.getInt(_lifetimeKey) ?? 0;

  String get lifetimeText =>
      '\$${(lifetimeCents / 100).toStringAsFixed(2)}';

  /// Credits the win reward for [puzzleKey] (unique per language/day/slot).
  /// Returns true when credited, false if this puzzle already paid out.
  Future<bool> awardDailyWin(String puzzleKey) async {
    final store = StorageService.instance;
    final awarded = _awardedKeys();
    if (awarded.contains(puzzleKey)) return false;
    awarded.add(puzzleKey);
    _pruneAwarded(awarded);
    await store.setString(_awardedKey, awarded.join('|'));
    await store.setInt(_balanceKey, balanceCents + winRewardCents);
    await store.setInt(_lifetimeKey, lifetimeCents + winRewardCents);
    // Sync with backend (fire-and-forget, don't block on failure)
    _syncWinToBackend(puzzleKey);
    final now = DateTime.now();
    final entry = <String, dynamic>{
      'k': puzzleKey,
      'd': '${now.year}-${now.month.toString().padLeft(2, '0')}-'
          '${now.day.toString().padLeft(2, '0')}',
      'c': winRewardCents,
    };
    final hist = history.toList();
    hist.insert(0, entry);
    final trimmed =
        hist.length > _maxHistory ? hist.sublist(0, _maxHistory) : hist;
    await store.setString(_historyKey, jsonEncode(trimmed));
    // Safe async notification (prevents freeze during build)
    Future.microtask(() {
      try { notifyListeners(); } catch (_) {}
    });
    return true;
  }

  /// Parse puzzle key and sync win to backend server.
  /// Key format: "game_<lang>_daily_YYYY-MM-DD_<slot>"
  Future<void> _syncWinToBackend(String puzzleKey) async {
    try {
      final parts = puzzleKey.split('_');
      if (parts.length < 5) return;
      final lang = parts[1];
      final dateStr = '${parts[3]}';
      final slot = int.tryParse(parts[4]) ?? 0;
      await BackendService.instance.reportWin(
        puzzleDate: dateStr,
        slot: slot,
        lang: lang,
      );
    } catch (_) {
      // Backend sync failed - local balance already updated, app keeps working
    }
  }

  Set<String> _awardedKeys() {
    final raw = StorageService.instance.getString(_awardedKey) ?? '';
    if (raw.isEmpty) return <String>{};
    return raw.split('|').toSet();
  }

  /// Drops awarded keys older than 90 days so the stored set stays small.
  /// Puzzle keys embed an ISO date (game_<lang>_daily_YYYY-MM-DD_<slot>).
  void _pruneAwarded(Set<String> keys) {
    if (keys.length < 2000) return;
    final cutoff = DateTime.now().subtract(const Duration(days: 90));
    final cutoffKey =
        '${cutoff.year.toString().padLeft(4, '0')}-'
        '${cutoff.month.toString().padLeft(2, '0')}-'
        '${cutoff.day.toString().padLeft(2, '0')}';
    keys.removeWhere((k) {
      final m = RegExp(r'(\d{4}-\d{2}-\d{2})').firstMatch(k);
      return m != null && m.group(1)!.compareTo(cutoffKey) < 0;
    });
  }

  /// Newest-first earning history.
  List<Map<String, dynamic>> get history {
    final raw = StorageService.instance.getString(_historyKey);
    if (raw == null || raw.isEmpty) return [];
    try {
      return (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
    } catch (_) {
      return [];
    }
  }
}
