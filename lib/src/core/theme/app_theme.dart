import 'package:flutter/material.dart';

class AppTheme {
  // Cores da Voomp
  static const Color primaryOrange = Color(0xFFFE8700);
  static const Color darkBlue = Color(0xFF1E2A45);

  // -- LIGHT THEME --
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: const Color(0xFFF5F5F5),
    colorScheme: const ColorScheme.light(
      primary: primaryOrange,
      secondary: darkBlue,
      surface: Colors.white,
      onSurface: Colors.black87,
      surfaceContainerHighest: Color(0xFFEEEEEE), // Cinza claro para fundos de inputs/barras
      outline: Colors.grey,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
    ),
    // cardTheme: CardTheme(
    //   color: Colors.white,
    //   elevation: 0,
    //   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    // ),
    // Estilo dos Inputs
    inputDecorationTheme: InputDecorationTheme(
      fillColor: Colors.white,
      filled: true,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFDDDDDD)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: primaryOrange),
      ),
    ),
  );

  // -- DARK THEME --
  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: const Color(0xFF121212), // Fundo escuro padrão
    colorScheme: const ColorScheme.dark(
      primary: primaryOrange,
      secondary: Color(0xFF64B5F6),
      surface: Color(0xFF1E1E1E), // Cards escuros
      onSurface: Color(0xFFE0E0E0), // Texto claro
      surfaceContainerHighest: Color(0xFF2C2C2C), // Inputs/Barras
      outline: Colors.grey,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF1E1E1E),
      foregroundColor: Colors.white,
    ),
    // cardTheme: CardTheme(
    //   color: const Color(0xFF1E1E1E),
    //   elevation: 0,
    //   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    // ),
    inputDecorationTheme: InputDecorationTheme(
      fillColor: const Color(0xFF2C2C2C),
      filled: true,
      hintStyle: TextStyle(color: Colors.grey[600]),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFF444444)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: primaryOrange),
      ),
    ),
  );
}
