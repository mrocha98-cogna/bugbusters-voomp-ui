import 'package:http/http.dart' as http;

class VoompApiClient {
  final http.Client client;
  final String baseUrl;

  VoompApiClient({required this.client, required this.baseUrl});

  Future<http.Response> get(String endpoint) async {
    final url = Uri.parse('$baseUrl$endpoint');
    // Esta API pode exigir uma API-KEY diferente no header
    return await client.get(url, headers: {'X-Api-Key': 'SUA_KEY_AQUI'});
  }

  Future<http.Response> post(String endpoint, {Object? body}) async {
    final url = Uri.parse('$baseUrl$endpoint');
    return await client.post(
        url,
        body: body,
        headers: {
          'Content-Type': 'application/json', // Essencial para enviar JSON
          'Accept': 'application/json',
        }
    );
  }
}