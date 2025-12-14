import 'package:flutter/material.dart';

// Singleton para gerenciar o estado do tema globalmente
class ThemeController extends ChangeNotifier {
  // Instância única
  static final ThemeController instance = ThemeController._();

  // Construtor privado
  ThemeController._();

  // Estado inicial (Pode ser alterado para ThemeMode.system se preferir)
  ThemeMode _themeMode = ThemeMode.light;

  ThemeMode get themeMode => _themeMode;

  bool get isDarkMode => _themeMode == ThemeMode.dark;

  void toggleTheme() {
    _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  // Opcional: Método para definir modo específico
  void setTheme(ThemeMode mode) {
    _themeMode = mode;
    notifyListeners();
  }
}
