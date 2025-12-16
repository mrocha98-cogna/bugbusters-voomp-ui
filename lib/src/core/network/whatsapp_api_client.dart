import 'package:http/http.dart' as http;

class WhatsappApiClient {
  final http.Client client;
  final String baseUrl;

  WhatsappApiClient({required this.client, required this.baseUrl});

  Future<http.Response> get(String endpoint) async {
    final url = Uri.parse('$baseUrl$endpoint');
    // Aqui você adicionaria headers específicos desta API (ex: Bearer Token da Voomp)
    return await client.get(url, headers: {'Content-Type': 'application/json'});
  }

  Future<http.Response> post(String endpoint, {Object? body}) async {
    final url = Uri.parse('$baseUrl$endpoint');
    return await client.post(url, body: body);
  }
}
