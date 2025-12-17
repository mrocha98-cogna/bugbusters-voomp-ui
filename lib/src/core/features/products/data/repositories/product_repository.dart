import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:voomp_sellers_rebranding/src/core/database/database_helper.dart';
import 'package:voomp_sellers_rebranding/src/core/features/products/data/models/product_model.dart';
import 'package:voomp_sellers_rebranding/src/core/network/api_endpoints.dart';
import 'package:voomp_sellers_rebranding/src/core/network/voomp_api_client.dart';
import 'package:http/http.dart' as http;

class ProductRepository {
  final VoompApiClient _apiClient;

  ProductRepository(this._apiClient);

  Future<List<ProductModel>> getProducts() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.productsList);

      if (response.statusCode == 200) {
        final decodedResponse = jsonDecode(response.body);

        List<dynamic> list;

        if (decodedResponse is List) {
          list = decodedResponse;
        } else if (decodedResponse is Map<String, dynamic>) {
          list = decodedResponse['items'] ?? []; // <--- AJUSTE 'data' SE NECESSÁRIO
        } else {
          list = [];
        }

        return list
            .map((e) => ProductModel.fromJson(e as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('Falha ao carregar produtos');
      }
    } catch (e) {
      throw Exception('Erro de conexão: $e');
    }
  }

  Future<bool> createProduct(ProductModel product, {XFile? imageFile}) async {
    try {
      final uri = Uri.parse('${_apiClient.baseUrl}${ApiEndpoints.createProduct}');
      var request = http.MultipartRequest('POST', uri);

      final token = await DatabaseHelper.instance.getAccessToken();
      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }

      final data = product.toJson();
      data.forEach((key, value) {
        if (value != null && key != 'imageUrl') {
          request.fields[key] = value.toString();
        }
      });
      if (imageFile != null) {
        if (kIsWeb) {
          final bytes = await imageFile.readAsBytes();
          request.files.add(http.MultipartFile.fromBytes(
            'cover',
            bytes,
            filename: imageFile.name,
            contentType: http.MediaType('image', 'jpeg'),
          ));
        } else {
          request.files.add(await http.MultipartFile.fromPath(
            'cover', // Nome do campo esperado pelo backend
            imageFile.path,
            contentType: http.MediaType('image', 'jpeg'),
          ));
        }
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print('Status: ${response.statusCode}');
      print('Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        throw Exception('Falha ao criar: ${response.body}');
      }
    } catch (e) {
      print('Erro no repositório: $e');
      throw Exception('Erro de conexão ao criar produto.');
    }
  }
}
