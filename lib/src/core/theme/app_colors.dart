import 'package:flutter/material.dart';

// ==========================================
// 1. PALETA PRIMITIVA (Definição dos Tons)
// ==========================================
class AppPalette {
  // --- BRAND PRIMARY (Laranja) ---
  static const Color orange900 = Color(0xFF6B3000);
  static const Color orange800 = Color(0xFF9E4800);
  static const Color orange700 = Color(0xFFCC5D00);
  static const Color orange500 = Color(0xFFFE8700); // COR PRINCIPAL
  static const Color orange400 = Color(0xFFFF9E33);
  static const Color orange300 = Color(0xFFFFB666);
  static const Color orange100 = Color(0xFFFFF0E6); // Fundo claro (Surface/Highlight)
  static const Color orange50 = Color(0xFFFFFAF5);

  // --- BRAND SECONDARY (Azul) ---
  static const Color blue900 = Color(0xFF0D1626); // Quase preto
  static const Color blue800 = Color(0xFF152238);
  static const Color blue700 = Color(0xFF1E2A45); // COR SECUNDÁRIA (Textos/Botões)
  static const Color blue500 = Color(0xFF2E457A);
  static const Color blue300 = Color(0xFF64B5F6);
  static const Color blue100 = Color(0xFFE3F2FD);
  static const Color blue50 = Color(0xFFF5F9FF);

  // --- NEUTRALS (Escala de Cinza) ---
  static const Color neutral900 = Color(0xFF121212); // Preto Absoluto (Dark Bg)
  static const Color neutral800 = Color(0xFF212121); // Card Dark
  static const Color neutral700 = Color(0xFF424242);
  static const Color neutral600 = Color(0xFF616161);
  static const Color neutral500 = Color(0xFF9E9E9E); // Disabled / Placeholder
  static const Color neutral400 = Color(0xFFBDBDBD); // Bordas
  static const Color neutral300 = Color(0xFFE0E0E0);
  static const Color neutral200 = Color(0xFFEEEEEE); // Fundo Inputs
  static const Color neutral100 = Color(0xFFF5F5F5); // Fundo Light
  static const Color white = Color(0xFFFFFFFF);

  // --- FEEDBACK / ALERTS ---
  static const Color error500 = Color(0xFFD32F2F);
  static const Color error100 = Color(0xFFFFEBEE);

  static const Color success500 = Color(0xFF388E3C);
  static const Color success100 = Color(0xFFE8F5E9);

  static const Color warning500 = Color(0xFFFBC02D);
  static const Color warning100 = Color(0xFFFFFDE7);

  static const Color info500 = Color(0xFF512DA8);
  static const Color info100 = Color(0xFFEDE7F6);
}

// ==========================================
// 2. TOKENS SEMÂNTICOS (Uso no App)
// ==========================================
class AppColors {
  // Brand
  static const Color primary = AppPalette.orange500;
  static const Color primaryDark = AppPalette.orange700;
  static const Color primaryLight = AppPalette.orange100;

  static const Color secondary = AppPalette.blue700;
  static const Color secondaryDark = AppPalette.blue900;

  // Text Colors
  static const Color textPrimaryLight = AppPalette.blue700;
  static const Color textSecondaryLight = AppPalette.neutral600;

  static const Color textPrimaryDark = AppPalette.white;
  static const Color textSecondaryDark = AppPalette.neutral400;

  // Backgrounds
  static const Color backgroundLight = AppPalette.neutral100;
  static const Color surfaceLight = AppPalette.white;

  static const Color backgroundDark = AppPalette.neutral900;
  static const Color surfaceDark = AppPalette.neutral800;
}
