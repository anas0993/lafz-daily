import 'package:flutter/material.dart';

/// Wooden-luxury palette shared across workstreams (workstream 1:
/// quality / UI overhaul).
///
/// Static consts only, so any workstream can reuse them without
/// instantiating anything:
///   emerald #0B6B3A — primary brand green (matches the new ThemeData seed)
///   gold    #D4AF37 — accents, correct-tile borders
///   cream   #FFF8E7 — light surfaces, keyboard keys
///   wood    #8B5E34 / #5C3D1E — warm browns for tiles and text
class WoodTheme {
  const WoodTheme._();

  static const Color emerald = Color(0xFF0B6B3A);
  static const Color emeraldDeep = Color(0xFF07522C);
  static const Color gold = Color(0xFFD4AF37);
  static const Color goldSoft = Color(0xFFE9CE7A);
  static const Color cream = Color(0xFFFFF8E7);
  static const Color creamDeep = Color(0xFFF3E5C3);
  static const Color woodLight = Color(0xFF8B5E34);
  static const Color wood = Color(0xFF6B4423);
  static const Color woodDark = Color(0xFF5C3D1E);
  static const Color bark = Color(0xFF3E2723);

  /// Blend [c] toward white by [amount] (0..1).
  static Color lighten(Color c, [double amount = 0.14]) {
    assert(amount >= 0 && amount <= 1);
    return Color.lerp(c, Colors.white, amount)!;
  }

  /// Blend [c] toward black by [amount] (0..1).
  static Color darken(Color c, [double amount = 0.18]) {
    assert(amount >= 0 && amount <= 1);
    return Color.lerp(c, Colors.black, amount)!;
  }
}
