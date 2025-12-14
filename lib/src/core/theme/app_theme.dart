import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {

  // -- LIGHT THEME CONFIG --
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,

    // Cores Principais
    colorScheme: const ColorScheme.light(
      primary: AppPalette.orange500,
      onPrimary: Colors.white,

      secondary: AppPalette.blue700,
      onSecondary: Colors.white,

      surface: AppPalette.white,
      onSurface: AppPalette.blue700, // Texto padrão escuro (Azul Marinho)

      // Cores de Erro/Sucesso
      error: AppPalette.error500,

      // Cores de Container (Fundos sutis)
      surfaceContainerHighest: AppPalette.neutral200, // Inputs/Barras
      outline: AppPalette.neutral400, // Bordas
    ),

    scaffoldBackgroundColor: AppPalette.neutral100, // #F5F5F5

    // AppBar
    appBarTheme: const AppBarTheme(
      backgroundColor: AppPalette.white,
      foregroundColor: AppPalette.blue700,
      elevation: 0,
    ),

    // Cards
    cardTheme: CardThemeData(
      color: AppPalette.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide.none,
      ),
    ),

    // Botões (Elevated)
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppPalette.orange500,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),

    // Inputs (TextField)
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppPalette.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppPalette.neutral300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppPalette.orange500),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppPalette.error500),
      ),
    ),
  );

  // -- DARK THEME CONFIG --
  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,

    colorScheme: const ColorScheme.dark(
      primary: AppPalette.orange500, // Mantém laranja como destaque
      onPrimary: Colors.white,

      secondary: AppPalette.blue300, // Azul mais claro para contraste no escuro
      onSecondary: AppPalette.blue900,

      surface: AppPalette.neutral800, // #212121
      onSurface: AppPalette.white, // Texto branco

      error: AppPalette.error500,

      surfaceContainerHighest: AppPalette.neutral700, // Inputs mais claros que o fundo
      outline: AppPalette.neutral600,
    ),

    scaffoldBackgroundColor: AppPalette.neutral900, // #121212

    appBarTheme: const AppBarTheme(
      backgroundColor: AppPalette.neutral800,
      foregroundColor: Colors.white,
      elevation: 0,
    ),

    cardTheme: CardThemeData(
      color: AppPalette.neutral800,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppPalette.orange500,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppPalette.neutral800,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppPalette.neutral700),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppPalette.orange500),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppPalette.error500),
      ),
    ),
  );
}
