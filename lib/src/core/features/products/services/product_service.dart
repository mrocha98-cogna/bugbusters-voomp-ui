
import 'package:image_picker/image_picker.dart';
import 'package:voomp_sellers_rebranding/src/core/features/products/data/models/product_model.dart';
import 'package:voomp_sellers_rebranding/src/core/features/products/data/repositories/product_repository.dart';

class ProductService {
  final ProductRepository _repository;

  ProductService(this._repository);

  Future<List<ProductModel>> fetchProducts() async {
    return await _repository.getProducts();
  }

  Future<bool> createProduct(ProductModel product, {XFile? imageFile}) async {
    return await _repository.createProduct(product, imageFile: imageFile);
  }
}
