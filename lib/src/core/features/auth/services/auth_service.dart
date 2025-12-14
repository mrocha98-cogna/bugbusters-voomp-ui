import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String _userKey = 'registered_user';

  // Salva o usuário (Simulando um cadastro no backend)
  Future<bool> registerUser({
    required String name,
    required String email,
    required String password,
    required String cpf,
    required String phone,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    // Cria um mapa com os dados
    final userData = {
      'name': name,
      'email': email,
      'password': password, // Em um app real, NUNCA salve senha em texto puro!
      'cpf': cpf,
      'phone': phone,
    };

    // Salva como JSON string
    return await prefs.setString(_userKey, jsonEncode(userData));
  }

  // Valida o login (Simulando validação do backend)
  Future<bool> login(String email, String password) async {
    final prefs = await SharedPreferences.getInstance();
    final userString = prefs.getString(_userKey);

    if (userString == null) return false; // Nenhum usuário cadastrado

    final Map<String, dynamic> user = jsonDecode(userString);

    // Verifica se email e senha batem
    return user['email'] == email && user['password'] == password;
  }

  // Recupera o nome do usuário logado (opcional, para a Home)
  Future<String?> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    final userString = prefs.getString(_userKey);
    if (userString == null) return null;
    final Map<String, dynamic> user = jsonDecode(userString);
    return user['name'];
  }
}