import 'package:http/http.dart' as http;
import 'package:voomp_sellers_rebranding/src/core/database/database_helper.dart';

class VoompApiClient {
  final http.Client client;
  final String baseUrl;

  VoompApiClient({required this.client, required this.baseUrl});

  Future<http.Response> get(String endpoint) async {
    final token =  await DatabaseHelper.instance.getAccessToken();
    final url = Uri.parse('$baseUrl$endpoint');
    return await client.get(url,headers: {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    },
    );
  }

  Future<http.Response> post(String endpoint, {Object? body}) async {
    final token =  await DatabaseHelper.instance.getAccessToken();
    final url = Uri.parse('$baseUrl$endpoint');
    return await client.post(
        url,
        body: body,
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );
  }
}