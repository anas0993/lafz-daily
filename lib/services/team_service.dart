import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Local-only team/clan service (Workstream 5: Social).
///
/// All data lives in SharedPreferences; nothing leaves the device.
/// NOTE: server sync via Supabase comes later; local-only for now.
///
/// Documented preference keys:
///   'wd_team_name'     — String, team display name (null = no team).
///   'wd_team_wins'     — int, total team wins (default 0).
///   'wd_team_messages' — JSON list of up to 50 {name, text, ts} entries.
class TeamService extends ChangeNotifier {
  TeamService._();
  static final TeamService instance = TeamService._();

  static const String kTeamNameKey = 'wd_team_name';
  static const String kTeamWinsKey = 'wd_team_wins';
  static const String kTeamMessagesKey = 'wd_team_messages';

  /// Max messages kept on the team board (oldest are trimmed).
  static const int kMessageCap = 50;

  String? _teamName;
  int _teamWins = 0;
  final List<TeamMessage> _messages = [];
  bool _loaded = false;

  String? get teamName => _teamName;
  bool get inTeam => _teamName != null;
  int get teamWins => _teamWins;
  List<TeamMessage> get messages => List.unmodifiable(_messages);

  Future<SharedPreferences> _prefs() => SharedPreferences.getInstance();

  /// Loads persisted state. Call once at app start (safe to call again).
  Future<void> init() async {
    if (_loaded) return;
    final p = await _prefs();
    _teamName = p.getString(kTeamNameKey);
    _teamWins = p.getInt(kTeamWinsKey) ?? 0;
    final raw = p.getString(kTeamMessagesKey);
    if (raw != null && raw.isNotEmpty) {
      try {
        final list = jsonDecode(raw) as List;
        _messages
          ..clear()
          ..addAll(list.whereType<Map<String, dynamic>>().map(
              TeamMessage.fromJson));
      } catch (_) {
        // Corrupt payload: start with an empty board rather than crash.
        _messages.clear();
      }
    }
    _loaded = true;
    notifyListeners();
  }

  /// Creates a team with the given [name]. Returns false if already in one.
  Future<bool> createTeam(String name) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty || inTeam) return false;
    final p = await _prefs();
    await p.setString(kTeamNameKey, trimmed);
    _teamName = trimmed;
    notifyListeners();
    return true;
  }

  /// Joins a team by name (local-only: behaves like create for now).
  /// NOTE: server sync via Supabase comes later; local-only for now.
  Future<bool> joinTeam(String name) => createTeam(name);

  /// Records one team win (e.g. when a team member wins a puzzle).
  /// NOTE: server sync via Supabase comes later; local-only for now.
  Future<void> recordTeamWin() async {
    if (!inTeam) return;
    _teamWins++;
    await (await _prefs()).setInt(kTeamWinsKey, _teamWins);
    notifyListeners();
  }

  /// Appends a message to the team board (cap [kMessageCap], oldest dropped).
  Future<void> postMessage(String name, String text) async {
    final n = name.trim();
    final t = text.trim();
    if (n.isEmpty || t.isEmpty || !inTeam) return;
    _messages.add(TeamMessage(
      name: n,
      text: t,
      timestamp: DateTime.now().millisecondsSinceEpoch,
    ));
    if (_messages.length > kMessageCap) {
      _messages.removeRange(0, _messages.length - kMessageCap);
    }
    await (await _prefs()).setString(
      kTeamMessagesKey,
      jsonEncode(_messages.map((m) => m.toJson()).toList()),
    );
    notifyListeners();
  }

  /// Leaves the team; wins and messages are cleared locally.
  /// NOTE: server sync via Supabase comes later; local-only for now.
  Future<void> leaveTeam() async {
    final p = await _prefs();
    await p.remove(kTeamNameKey);
    await p.remove(kTeamWinsKey);
    await p.remove(kTeamMessagesKey);
    _teamName = null;
    _teamWins = 0;
    _messages.clear();
    notifyListeners();
  }
}

/// A single team board message.
class TeamMessage {
  TeamMessage({required this.name, required this.text, required this.timestamp});

  final String name;
  final String text;
  final int timestamp;

  TeamMessage.fromJson(Map<String, dynamic> j)
      : name = (j['name'] as String?) ?? '',
        text = (j['text'] as String?) ?? '',
        timestamp = (j['ts'] as num?)?.toInt() ?? 0;

  Map<String, dynamic> toJson() => {'name': name, 'text': text, 'ts': timestamp};
}
