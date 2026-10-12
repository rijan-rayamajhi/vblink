import 'package:flutter/material.dart';

/// Shared colors for the neon-casino look.
class AppColors {
  static const deepPurple = Color(0xFF1A0838);
  static const royalPurple = Color(0xFF3A0F7A);
  static const violet = Color(0xFF7B2FF7);
  static const magenta = Color(0xFFE23BD6);
  static const hotPink = Color(0xFFFF3D9A);
  static const gold = Color(0xFFFFC93C);
  static const goldDeep = Color(0xFFE09A12);
  static const cyan = Color(0xFF3FE0FF);
}

ThemeData buildAppTheme() {
  return ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.deepPurple,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.violet,
      brightness: Brightness.dark,
    ),
  );
}

/// Chunky game text with a dark outline-like shadow so it reads on any art.
class AppText {
  static const _shadows = [
    Shadow(color: Color(0xCC1A0838), offset: Offset(0, 1.5), blurRadius: 2),
  ];

  /// White bold numbers (coin balance, level).
  static TextStyle number(double size) => TextStyle(
    fontSize: size,
    fontWeight: FontWeight.w900,
    color: Colors.white,
    height: 1,
    shadows: _shadows,
  );

  /// Small white uppercase caption.
  static TextStyle label(double size) => TextStyle(
    fontSize: size,
    fontWeight: FontWeight.w900,
    color: Colors.white,
    letterSpacing: 0.5,
    height: 1,
    shadows: _shadows,
  );

  /// Gold amount used for jackpots.
  static TextStyle gold(double size) => TextStyle(
    fontSize: size,
    fontWeight: FontWeight.w900,
    color: AppColors.gold,
    height: 1,
    shadows: const [
      Shadow(color: Color(0xFF7A1050), offset: Offset(0, 2), blurRadius: 1),
      Shadow(color: Color(0x99FFE9A0), blurRadius: 6),
    ],
  );
}
