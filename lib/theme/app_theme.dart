import 'package:flutter/material.dart';

class AppTheme {
  static const _seedColor = Colors.deepOrange;

  static ThemeData light = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: _seedColor,
      brightness: Brightness.light,
    ),
  );

  static ThemeData dark = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: _seedColor,
      brightness: Brightness.dark,
    ),
  );

  /// Background color for a tile of the given [value], distinct per power of
  /// two so the board is readable at a glance.
  static Color tileColor(int value, Brightness brightness) {
    final map = brightness == Brightness.dark
        ? _darkTileColors
        : _lightTileColors;
    return map[value] ?? map.values.last;
  }

  static Color tileTextColor(int value) {
    return value <= 4 ? const Color(0xFF3F3A36) : Colors.white;
  }

  static const _lightTileColors = <int, Color>{
    2: Color(0xFFE8D4BE),
    4: Color(0xFFE3C08E),
    8: Color(0xFFF2B179),
    16: Color(0xFFF59563),
    32: Color(0xFFF67C5F),
    64: Color(0xFFF65E3B),
    128: Color(0xFFEDCF72),
    256: Color(0xFFEDCC61),
    512: Color(0xFFEDC850),
    1024: Color(0xFFEDC53F),
    2048: Color(0xFFEDC22E),
  };

  static const _darkTileColors = <int, Color>{
    2: Color(0xFFEFE6D8),
    4: Color(0xFFE9D6A6),
    8: Color(0xFFB9722E),
    16: Color(0xFFC77A34),
    32: Color(0xFFD9653F),
    64: Color(0xFFE04F2B),
    128: Color(0xFFB89A3E),
    256: Color(0xFFC2A63A),
    512: Color(0xFFCBB234),
    1024: Color(0xFFD4BE2E),
    2048: Color(0xFFDFCA26),
  };
}
