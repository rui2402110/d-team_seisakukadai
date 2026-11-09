import 'package:flutter/material.dart';

/// デモ(common.css の :root)と同じ配色
class KakkoColors {
  static const ink = Color(0xFF2B2016); // 背景
  static const inkSoft = Color(0xFF3A2C1D); // カードの背景
  static const inkLine = Color(0x1AF3E6D2); // 枠線(rgba(243,230,210,0.10))
  static const fieldFill = Color(0x0FF3E6D2); // 入力欄の背景(0.06)
  static const paperText = Color(0xFFF4EAD9); // 文字
  static const muted = Color(0xFFB6A289); // 薄い文字
  static const accent = Color(0xFFE07B2E); // オレンジ
  static const accentDisabled = Color(0x99E07B2E);
  static const errorText = Color(0xFFE58B7D);
  static const errorBorder = Color(0xFFD46A5A);
  static const errorFill = Color(0x2ED46A5A);
}

/// デモと同じダークブラウンのテーマ(今は認証画面だけに適用)
ThemeData kakkoTheme() {
  final base = ThemeData(brightness: Brightness.dark, useMaterial3: true);
  return base.copyWith(
    scaffoldBackgroundColor: KakkoColors.ink,
    colorScheme: const ColorScheme.dark(
      primary: KakkoColors.accent,
      onPrimary: KakkoColors.ink,
      surface: KakkoColors.ink,
      onSurface: KakkoColors.paperText,
      error: KakkoColors.errorText,
    ),
    textTheme: base.textTheme.apply(
      bodyColor: KakkoColors.paperText,
      displayColor: KakkoColors.paperText,
    ),
  );
}
