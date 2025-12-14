import 'dart:async';
import 'package:flutter/foundation.dart';

// Simulação de serviço de autenticação
class AuthService {
  // Singleton para manter estado em memória durante o teste
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  String? _currentUser;

  Future<bool> login(String email, String password) async {
    // Simula delay de rede
    await Future.delayed(const Duration(milliseconds: 1500));

    // Login "Fake": Aceita qualquer senha maior que 3 digitos
    if (password.length > 3) {
      _currentUser = "Ana Carolina"; // Nome fixo do design ou extraído do email
      return true;
    }
    return false;
  }

  Future<void> registerUser({
    required String name,
    required String email,
    required String password,
    required String cpf,
    required String phone,
  }) async {
    await Future.delayed(const Duration(milliseconds: 1500));
    _currentUser = name;
    // Aqui você salvaria no backend/firebase
    debugPrint("Usuário registrado: $name, $email");
  }

  Future<String?> getUserName() async {
    return _currentUser ?? "Vendedor";
  }

  void logout() {
    _currentUser = null;
  }
}
