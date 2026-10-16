import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// 1v1 friend challenges, fully local (no server).
///
/// A challenge is a custom 5-letter word chosen by one player. It is encoded
/// into a short shareable code; the friend pastes the code into the app to
/// play the same word. Results (guesses used) are stored locally so the
/// creator can later compare.
///
/// Code format: base64url of `wd1:<WORD>` (uppercase, padding stripped).
/// For robustness, a bare uppercase 5-letter word is also accepted as a code.
class ChallengeService {
  ChallengeService._();
  static final ChallengeService instance = ChallengeService._();

  static const _outgoingKey = 'challenges_outgoing_v1';
  static const _incomingKey = 'challenges_incoming_v1';

  static final _letter = RegExp(r'\p{L}', unicode: true);

  /// True when [word] is exactly 5 letters (any script) after trimming.
  static bool isValidWord(String word) {
    final w = word.trim();
    if (w.runes.length != 5) return false;
    return w.runes.every((r) => _letter.hasMatch(String.fromCharCode(r)));
  }

  /// Encodes a valid 5-letter [word] into a shareable code.
  /// Callers should check [isValidWord] first; throws [ArgumentError] on
  /// invalid input.
  String createChallenge(String word) {
    final w = word.trim().toUpperCase();
    if (!isValidWord(w)) {
      throw ArgumentError('Challenge word must be exactly 5 letters');
    }
    final raw = utf8.encode('wd1:$w');
    return base64Url.encode(raw).replaceAll('=', '');
  }

  /// Decodes a challenge code back to the word, or null when the code is
  /// invalid. Never throws.
  String? decodeChallenge(String code) {
    final c = code.trim();
    if (c.isEmpty) return null;
    // Accept a bare uppercase word directly (e.g. typed by hand).
    if (isValidWord(c)) return c.toUpperCase();
    try {
      var padded = c;
      while (padded.length % 4 != 0) {
        padded += '=';
      }
      final decoded = utf8.decode(base64Url.decode(padded));
      if (!decoded.startsWith('wd1:')) return null;
      final word = decoded.substring(4).toUpperCase();
      return isValidWord(word) ? word : null;
    } catch (_) {
      return null;
    }
  }

  // ------------------------------------------------------------ storage --

  Map<String, dynamic> _outgoing = {}; // code -> {word, guesses, createdAt}
  Map<String, String> _incoming = {}; // code -> word
  bool _loaded = false;

  Future<void> _ensureLoaded() async {
    if (_loaded) return;
    final prefs = await SharedPreferences.getInstance();
    final out = prefs.getString(_outgoingKey);
    if (out != null) {
      try {
        _outgoing = Map<String, dynamic>.from(jsonDecode(out) as Map);
      } catch (_) {
        _outgoing = {};
      }
    }
    final inc = prefs.getString(_incomingKey);
    if (inc != null) {
      try {
        _incoming = Map<String, String>.from(jsonDecode(inc) as Map);
      } catch (_) {
        _incoming = {};
      }
    }
    _loaded = true;
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_outgoingKey, jsonEncode(_outgoing));
    await prefs.setString(_incomingKey, jsonEncode(_incoming));
  }

  /// Records a challenge created by this device.
  Future<void> saveOutgoing(String code, String word) async {
    await _ensureLoaded();
    _outgoing[code] = {
      'word': word.toUpperCase(),
      'guesses': null,
      'createdAt': DateTime.now().toIso8601String(),
    };
    await _persist();
  }

  /// Records a challenge code joined on this device.
  Future<void> saveIncoming(String code, String word) async {
    await _ensureLoaded();
    _incoming[code] = word.toUpperCase();
    await _persist();
  }

  /// Stores the number of guesses used to finish the challenge identified
  /// by [code] (creator's own result, or the joiner's result — whichever the
  /// caller is reporting).
  Future<void> saveResult(String code, int guesses) async {
    await _ensureLoaded();
    final entry = _outgoing[code];
    if (entry is Map) {
      entry['guesses'] = guesses;
      await _persist();
    }
  }

  /// Returns the stored guess count for [code], or null when unknown.
  Future<int?> getResult(String code) async {
    await _ensureLoaded();
    final entry = _outgoing[code];
    if (entry is Map && entry['guesses'] is int) {
      return entry['guesses'] as int;
    }
    return null;
  }
}
