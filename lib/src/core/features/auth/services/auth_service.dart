import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:voomp_sellers_rebranding/src/core/enums/goal.dart';
import 'package:voomp_sellers_rebranding/src/core/enums/how_knew.dart';
import 'package:voomp_sellers_rebranding/src/core/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:voomp_sellers_rebranding/src/core/features/model/user.dart';
import 'package:voomp_sellers_rebranding/src/core/network/api_endpoints.dart';
import 'package:voomp_sellers_rebranding/src/core/network/voomp_api_client.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;

  AuthService._internal() {
    final httpClient = http.Client();
    final voompClient = VoompApiClient(
        client: httpClient,
        baseUrl: ApiEndpoints.apiVoompBaseUrl
    );

    _authRepo = AuthRepositoryImpl(voompClient);
  }

  late final AuthRepositoryImpl _authRepo;

  Future<User?> login(String email, String password) async {
    try {
      // 1. Tenta logar na API real
      final user = await _authRepo.login(
          email: email,
          password: password
      );

      return user;
    } catch (e) {
      return null;
    }
  }

  Future<bool> registerUser({
    required String name,
    required String email,
    required String password,
    required String cpf,
    required String phone,
    required bool alreadySellOnline,
    required String goal, // Recebe o texto da UI: "Vender meus produtos"
    required String howKnew, // Recebe o texto da UI: "Amigo ou colega"
  }) async {
    // 1. Mapeia o texto da UI para o valor do Enum esperado pela API
    final String? goalApiValue = _getGoalApiValue(goal);
    final String? howKnewApiValue = _getHowKnewApiValue(howKnew);

    // 2. Chama a API via Repositório com os valores convertidos
    var result = await _authRepo.signUp(
      name: name,
      email: email,
      password: password,
      cpf: cpf,
      phone: phone,
      howKnew: howKnewApiValue, // Usa o valor do enum
      alreadySellOnline: alreadySellOnline,
      goal: goalApiValue, // Usa o valor do enum
    );

    return result;
  }

  String? _getGoalApiValue(String uiValue) {
    switch (uiValue) {
      case "sell":
        return Goal.sell.name;
      case "affiliate":
        return Goal.affiliate.name; // Retorna "affiliate"
      default:
        return null; // Valor padrão "notInformed"
    }
  }

  String? _getHowKnewApiValue(String uiValue) {
    switch (uiValue) {
      case "Amigo ou colega":
        return HowKnew.friend.name;
      case "Anúncio":
        return HowKnew.ad.name;
      case "Artigo ou post de blog":
        return HowKnew.articleOrBlog.name;
      case "Evento ou feira":
        return HowKnew.eventOrWorkshop.name;
      case "Podcast ou vídeo":
        return HowKnew.podcastOrVideo.name;
      case "Post nas redes sociais":
        return HowKnew.socialMediaPost.name;
      case "Pesquisa online":
        return HowKnew.webSearch.name;
      case "Colaborador cogna":
        return HowKnew.cognaEmployee.name;
      case "Outros":
        return HowKnew.other.name;
      default:
        return null;
    }
  }

  Future<bool> sendVerificationCode(String email) async {
    try {
      await _authRepo.generateVerificationCode(email);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> validateVerificationCode(String email, String code) async {
    try {
      return _authRepo.verifyCode(email, code);
    } catch (e) {
      return false;
    }
  }
}
