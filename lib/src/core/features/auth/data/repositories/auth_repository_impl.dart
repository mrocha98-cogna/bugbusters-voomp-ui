import 'dart:convert';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:voomp_sellers_rebranding/src/core/database/database_helper.dart';
import 'package:voomp_sellers_rebranding/src/core/features/auth/data/dto/sign_up_request_dto.dart';
import 'package:voomp_sellers_rebranding/src/core/features/model/user.dart';
import 'package:voomp_sellers_rebranding/src/core/network/api_endpoints.dart';
import 'package:voomp_sellers_rebranding/src/core/network/voomp_api_client.dart';

class AuthRepositoryImpl {
  final VoompApiClient _voompApiClient;

  AuthRepositoryImpl(this._voompApiClient);

  Future<bool> signUp({
    required String name,
    required String email,
    required String password,
    required String cpf,
    required String phone,
    // Parâmetros opcionais ou obrigatórios do onboarding
    String? howKnew,
    bool alreadySellOnline = true,
    String? goal,
  }) async {

    // 1. Monta o objeto DTO
    final requestBody = SignUpRequestDto(
      email: email,
      name: name,
      cpf: cpf,
      phoneNumber: phone,
      password: password,
      onboarding: OnboardingDto(
        howKnew: howKnew,
        alreadySellOnline: alreadySellOnline,
        goal: goal,
      ),
    );

    try {
      // 2. Faz a chamada POST usando o endpoint definido
      final response = await _voompApiClient.post(
        ApiEndpoints.signUp, // '/api/v1/auth/sign-up'
        body: jsonEncode(requestBody.toJson()),
      );

      // 3. Valida a resposta
      if (response.statusCode == 200 || response.statusCode == 201) {
        // Sucesso!
        // Se a API retornar um token ou usuário criado, você pode processar aqui.
        // ex: return User.fromJson(jsonDecode(response.body));
        return true;
      } else {
        // Trata erros de API (400, 500, etc)
        // O ideal é ter uma classe customizada de exceção
        throw Exception('Falha ao cadastrar: ${response.body}');
      }
    } catch (e) {
      // Repassa o erro para ser tratado na UI (Toast/Snackbar)
      rethrow;
    }
  }

  Future<User> login({required String email, required String password}) async {
    try {
      final response = await _voompApiClient.post(
        ApiEndpoints.login,
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = jsonDecode(response.body);

        // 1. Verifica se o token veio na resposta (geralmente em 'accessToken' ou 'token')
        final String token = data['accessToken'];

        if (token.isNotEmpty) {
          await DatabaseHelper.instance.saveToken(token);
          Map<String, dynamic> decodedToken = JwtDecoder.decode(token);

          // 3. Mapeia os dados do token para o objeto User
          // NOTA: Ajuste as chaves ('sub', 'name', etc) conforme o seu JWT real
          return User(
            id: decodedToken['sub'] != null ? decodedToken['sub'].toString() : '',
            name: decodedToken['name'] ?? '',
            email: decodedToken['email'] ?? email, // Usa o e-mail do input se não vier no token
            password: password, // Geralmente não vem no token, mantemos a do input para salvar localmente se necessário
            cpf: decodedToken['cpf'] ?? '',
            phone: decodedToken['phoneNumber'] ?? decodedToken['phone'] ?? '',
            userOnboardingId: decodedToken['onboardingId'] ?? '',
          );
        } else {
          throw Exception('Token de acesso não encontrado na resposta.');
        }
      } else {
        throw Exception('Credenciais inválidas ou erro no servidor: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> generateVerificationCode(String email) async {
    try {
      final response = await _voompApiClient.post(
        ApiEndpoints.generationCode,
        body: jsonEncode({'email': email}),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        // Sucesso: O código foi enviado para o e-mail
        return;
      }
      else {
        throw Exception('Falha ao gerar código: ${response.body}');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> verifyCode(String email, String code) async {
    try {
      final response = await _voompApiClient.post(
        "${ApiEndpoints.generationCodeUse}/$code",
        body: jsonEncode({'email': email}),
      );

      // print(response.body);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return true;
      } else {
        throw Exception('Código inválido ou expirado.');
      }
    } catch (e) {
      return false;
    }
  }
}
