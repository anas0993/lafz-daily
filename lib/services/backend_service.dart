import 'package:supabase/supabase.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'storage_service.dart';

/// Backend service: Supabase integration for Lafz Daily.
/// Server-side source of truth for balances, premium status, withdrawals.
/// Uses pure-Dart Supabase client (no native plugins = no crash risk).
class BackendService {
  BackendService._();
  static final BackendService instance = BackendService._();

  SupabaseClient? _client;
  bool get isConfigured => _client != null;

  // TODO: Owner sets these in admin panel config, baked into app at build time
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: '',
  );
  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: '',
  );

  Future<void> init() async {
    if (supabaseUrl.isEmpty || supabaseAnonKey.isEmpty) return;
    _client = SupabaseClient(supabaseUrl, supabaseAnonKey);
    await _ensurePlayer();
  }

  /// Device ID: stable per install
  Future<String> _deviceId() async {
    final prefs = await SharedPreferences.getInstance();
    var id = prefs.getString('device_id');
    if (id == null) {
      id = DateTime.now().millisecondsSinceEpoch.toRadixString(36) +
          (100000 + (900000 * (DateTime.now().microsecond % 1000) / 1000).toInt())
              .toString();
      await prefs.setString('device_id', id);
    }
    return id;
  }

  /// Player name (entered by user)
  String? get playerName => StorageService.instance.getString('player_name');
  Future<void> setPlayerName(String name) async {
    await StorageService.instance.setString('player_name', name);
    // Create/update player in backend NOW (not just at init)
    await _ensurePlayer();
  }
  bool get hasPlayerName =>
      playerName != null && playerName!.trim().isNotEmpty;

  /// Ensure player row exists in backend
  Future<void> _ensurePlayer() async {
    if (!isConfigured || !hasPlayerName) return;
    final deviceId = await _deviceId();
    try {
      final existing = await _client!
          .from('players')
          .select('id')
          .eq('device_id', deviceId)
          .maybeSingle();
      if (existing == null) {
        await _client!.from('players').insert({
          'device_id': deviceId,
          'name': playerName!.trim(),
        });
      } else {
        // Update name if changed
        await _client!.from('players').update({
          'name': playerName!.trim(),
          'updated_at': DateTime.now().toIso8601String(),
        }).eq('device_id', deviceId);
      }
    } catch (_) {
      // Offline or backend not ready — app works locally, syncs later
    }
  }

  Future<String?> _playerId() async {
    if (!isConfigured) return null;
    final deviceId = await _deviceId();
    try {
      final row = await _client!
          .from('players')
          .select('id')
          .eq('device_id', deviceId)
          .maybeSingle();
      return row?['id'] as String?;
    } catch (_) {
      return null;
    }
  }

  /// Get server balance
  Future<double?> getServerBalance() async {
    final pid = await _playerId();
    if (pid == null) return null;
    try {
      final row = await _client!
          .from('balances')
          .select('balance')
          .eq('player_id', pid)
          .maybeSingle();
      if (row == null) return 0.0;
      return (row['balance'] as num).toDouble();
    } catch (_) {
      return null;
    }
  }

  /// Report a win to backend (server validates + credits)
  /// Returns the reward credited, or null if offline/failed
  Future<double?> reportWin({
    required String puzzleDate, // YYYY-MM-DD
    required int slot,
    required String lang,
  }) async {
    final pid = await _playerId();
    if (pid == null) return null;
    try {
      // Check if already recorded (prevent duplicates)
      final existing = await _client!
          .from('puzzle_completions')
          .select('id')
          .eq('player_id', pid)
          .eq('puzzle_date', puzzleDate)
          .eq('slot', slot)
          .eq('lang', lang)
          .maybeSingle();
      if (existing != null) return 0.0; // Already recorded

      // Get reward amount from settings
      final settings = await _client!
          .from('app_settings')
          .select('value')
          .eq('key', 'reward_per_win')
          .maybeSingle();
      final reward = double.tryParse(settings?['value'] ?? '0.05') ?? 0.05;

      // Check daily cash win cap (5/day)
      final capRow = await _client!
          .from('app_settings')
          .select('value')
          .eq('key', 'max_cash_wins_per_day')
          .maybeSingle();
      final cap = int.tryParse(capRow?['value'] ?? '5') ?? 5;

      final todayWins = await _client!
          .from('puzzle_completions')
          .select('id')
          .eq('player_id', pid)
          .eq('puzzle_date', puzzleDate)
          .eq('won', true)
          .count(CountOption.exact);

      final count = todayWins.count ?? 0;
      final payable = count < cap ? reward : 0.0;

      // Record completion
      await _client!.from('puzzle_completions').insert({
        'player_id': pid,
        'puzzle_date': puzzleDate,
        'slot': slot,
        'lang': lang,
        'won': true,
        'reward_paid': payable,
      });

      if (payable > 0) {
        // Credit balance (upsert)
        final bal = await _client!
            .from('balances')
            .select('balance,total_earned')
            .eq('player_id', pid)
            .maybeSingle();
        if (bal == null) {
          await _client!.from('balances').insert({
            'player_id': pid,
            'balance': payable,
            'total_earned': payable,
          });
        } else {
          final newBal = (bal['balance'] as num).toDouble() + payable;
          final newTotal = (bal['total_earned'] as num).toDouble() + payable;
          await _client!.from('balances').update({
            'balance': newBal,
            'total_earned': newTotal,
            'updated_at': DateTime.now().toIso8601String(),
          }).eq('player_id', pid);
        }
      }
      return payable;
    } catch (_) {
      return null;
    }
  }

  /// Check premium status from backend
  Future<bool> checkPremium() async {
    final pid = await _playerId();
    if (pid == null) return false;
    try {
      final row = await _client!
          .from('players')
          .select('is_premium,premium_expires_at')
          .eq('id', pid)
          .maybeSingle();
      if (row == null) return false;
      final isPremium = row['is_premium'] as bool? ?? false;
      if (!isPremium) return false;
      final expires = row['premium_expires_at'] as String?;
      if (expires == null) return true; // No expiry = lifetime
      return DateTime.parse(expires).isAfter(DateTime.now());
    } catch (_) {
      return false;
    }
  }

  /// Submit premium application
  Future<bool> applyForPremium({
    required String package, // '3mo' or '6mo'
    required String paymentReference,
    String? paymentMethod,
  }) async {
    final pid = await _playerId();
    if (pid == null) return false;
    try {
      await _client!.from('premium_applications').insert({
        'player_id': pid,
        'package': package,
        'payment_method': paymentMethod,
        'payment_reference': paymentReference,
        'status': 'pending',
      });
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Submit withdrawal request
  Future<bool> requestWithdrawal({
    required double amount,
    required String method,
    required String accountDetails,
  }) async {
    final pid = await _playerId();
    if (pid == null) return false;
    try {
      // Verify balance
      final balance = await getServerBalance();
      if (balance == null || balance < amount) return false;

      await _client!.from('withdrawal_requests').insert({
        'player_id': pid,
        'amount': amount,
        'method': method,
        'account_details': accountDetails,
        'status': 'pending',
      });

      // Save payout details to player profile
      await _client!.from('players').update({
        'payout_method': method,
        'payout_details': accountDetails,
      }).eq('id', pid);

      return true;
    } catch (_) {
      return false;
    }
  }

  /// Get app setting
  Future<String?> getSetting(String key) async {
    if (!isConfigured) return null;
    try {
      final row = await _client!
          .from('app_settings')
          .select('value')
          .eq('key', key)
          .maybeSingle();
      return row?['value'] as String?;
    } catch (_) {
      return null;
    }
  }
}
