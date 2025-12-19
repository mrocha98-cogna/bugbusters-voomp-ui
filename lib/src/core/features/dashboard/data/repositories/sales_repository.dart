import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:voomp_sellers_rebranding/src/core/database/database_helper.dart';
import 'package:voomp_sellers_rebranding/src/core/features/model/SalesStatistics.dart';
import 'package:voomp_sellers_rebranding/src/core/network/api_endpoints.dart';

class SalesRepository {

  Future<double> getSalesTotal() async {
    var token = await DatabaseHelper.instance.getAccessToken();
    final url = Uri.parse('${ApiEndpoints.apiVoompBaseUrl}${ApiEndpoints.salesTotal}');

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

        final double total = double.tryParse(data['total'].toString()) ?? 0;

        return total;
      } else {
        throw Exception('Falha ao buscar total de vendas. Código: ${response.statusCode}');
      }
    } catch (e) {
      print('Erro ao buscar total de vendas: $e');
      throw Exception('Não foi possível conectar ao servidor. Verifique sua conexão e tente novamente.');
    }
  }

  Future<double> getSalesRevenue() async {
    var token = await DatabaseHelper.instance.getAccessToken();
    final url = Uri.parse('${ApiEndpoints.apiVoompBaseUrl}${ApiEndpoints.salesRevenue}');

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

        final double revenue = double.tryParse(data['revenue'].toString()) ?? 0;

        return revenue;
      } else {
        throw Exception('Falha ao buscar receita de vendas. Código: ${response.statusCode}');
      }
    } catch (e) {
      print('Erro ao buscar receita de vendas: $e');
      throw Exception('Não foi possível conectar ao servidor. Verifique sua conexão e tente novamente.');
    }
  }

  Future<SalesStatistics> getSalesStatistics() async {
    var token = await DatabaseHelper.instance.getAccessToken();
    final url = Uri.parse('${ApiEndpoints.apiVoompBaseUrl}${ApiEndpoints.salesStatistics}');

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

        return SalesStatistics.fromJson(data);

      } else {
        throw Exception('Falha ao buscar estatísticas de vendas. Código: ${response.statusCode}');
      }
    } catch (e) {
      print('Erro ao buscar estatísticas de vendas: $e');
      throw Exception('Não foi possível conectar ao servidor. Verifique sua conexão e tente novamente.');
    }
  }
}
