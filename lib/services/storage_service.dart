import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Thin wrapper around SharedPreferences with JSON helpers.
class StorageService {
  StorageService._();
  static final StorageService instance = StorageService._();

  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  SharedPreferences get prefs {
    final p = _prefs;
    if (p == null) throw StateError('StorageService not initialized');
    return p;
  }

  Future<bool> setString(String key, String value) =>
      prefs.setString(key, value);
  String? getString(String key) => prefs.getString(key);

  Future<bool> setInt(String key, int value) => prefs.setInt(key, value);
  int? getInt(String key) => prefs.getInt(key);

  Future<bool> setBool(String key, bool value) => prefs.setBool(key, value);
  bool? getBool(String key) => prefs.getBool(key);

  Future<bool> setJson(String key, Map<String, dynamic> value) =>
      prefs.setString(key, jsonEncode(value));
  Map<String, dynamic>? getJson(String key) {
    final raw = prefs.getString(key);
    if (raw == null) return null;
    return jsonDecode(raw) as Map<String, dynamic>;
  }

  Future<bool> remove(String key) => prefs.remove(key);
}
