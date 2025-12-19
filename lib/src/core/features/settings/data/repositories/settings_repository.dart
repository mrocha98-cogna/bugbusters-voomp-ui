import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:voomp_sellers_rebranding/src/core/database/database_helper.dart';
import 'package:voomp_sellers_rebranding/src/core/features/model/PendingSteps.dart';
import 'package:voomp_sellers_rebranding/src/core/network/api_endpoints.dart';

class SettingsRepository {

  Future<String> getWhatsappLink() async {
    var token = await DatabaseHelper.instance.getAccessToken();
    final url = Uri.parse('${ApiEndpoints.apiVoompBaseUrl}${ApiEndpoints.getWhatsappLink}');

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        final String? whatsAppLink = data['link'];

        if (whatsAppLink != null && whatsAppLink.isNotEmpty) {
          return whatsAppLink;
        } else {
          throw Exception('Número de telefone retornado pela API está nulo ou vazio.');
        }
      } else {
        throw Exception('Falha ao buscar número do bot. Código: ${response.statusCode}');
      }
    } catch (e) {
      print('Erro ao buscar número do bot: $e');
      throw Exception('Não foi possível conectar ao servidor. Verifique sua conexão e tente novamente.');
    }
  }

  Future<bool> getWhatsappUserStatus() async {
    var token = await DatabaseHelper.instance.getAccessToken();
    final url = Uri.parse('${ApiEndpoints.apiVoompBaseUrl}${ApiEndpoints.whatsappUserStatus}');

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        final bool whatsappStatus = data['active'];

        return whatsappStatus;
      } else {
        throw Exception('Falha ao buscar o status do whatsapp. Código: ${response.statusCode}');
      }
    } catch (e) {
      print('Erro ao buscar status do whatsapp: $e');
      throw Exception('Não foi possível conectar ao servidor. Verifique sua conexão e tente novamente.');
    }
  }

  Future<PendingSteps> getUserPendingSteps() async {
    var token = await DatabaseHelper.instance.getAccessToken();
    final url = Uri.parse('${ApiEndpoints.apiVoompBaseUrl}${ApiEndpoints.userPendingSteps}');

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);

        return PendingSteps.fromJson(data);

      } else {
        throw Exception('Falha ao buscar o status do whatsapp. Código: ${response.statusCode}');
      }
    } catch (e) {
      print('Erro ao buscar as pendencias do perfil: $e');
      throw Exception('Não foi possível conectar ao servidor. Verifique sua conexão e tente novamente.');
    }
  }

  Future<bool> patchUserPendingSteps() async {
    var token = await DatabaseHelper.instance.getAccessToken();
    final url = Uri.parse('${ApiEndpoints.apiVoompBaseUrl}${ApiEndpoints.patchUserIdentityValidation}');


    try {
      final response = await http.patch(
        url,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode({"valid": true})
      );

      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (e) {
      print('Erro ao atualizar os dados de identificação: $e');
      throw Exception('Não foi possível conectar ao servidor. Verifique sua conexão e tente novamente.');
    }
  }

  Future<bool> postUserBankingData() async {
    var token = await DatabaseHelper.instance.getAccessToken();
    final url = Uri.parse('${ApiEndpoints.apiVoompBaseUrl}${ApiEndpoints.postUserBankingData}');

    try {
      final response = await http.post(
          url,
          headers: {
            'Content-Type': 'application/json',
            if (token != null) 'Authorization': 'Bearer $token',
          },
      );

      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (e) {
      print('Erro ao atualizar dados bancarios: $e');
      throw Exception('Não foi possível conectar ao servidor. Verifique sua conexão e tente novamente.');
    }
  }

  Future<bool> postUserBusinessData() async {
    var token = await DatabaseHelper.instance.getAccessToken();
    final url = Uri.parse('${ApiEndpoints.apiVoompBaseUrl}${ApiEndpoints.postUserBusinessData}');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (e) {
      print('Erro ao atualizar dados empresariais: $e');
      throw Exception('Não foi possível conectar ao servidor. Verifique sua conexão e tente novamente.');
    }
  }
}
