import 'package:voomp_sellers_rebranding/src/core/features/products/data/models/product_enums.dart';

class ProductModel {
  final String id;
  final String title;
  final double price;
  final String status;
  final ProductType? type;
  final String? imageUrl;
  final int sales;
  final String? description;
  final String? website;
  final ProductCategory? category;
  final ProductBillingType? billingType;
  final int? warrantyInDays;

  ProductModel({
    required this.id,
    required this.title,
    required this.price,
    required this.status,
    required this.type,
    this.imageUrl,
    required this.sales,
    this.description,
    this.website,
    this.category,
    this.billingType,
    this.warrantyInDays,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id']?.toString() ?? '',
      category: json['category'] != null ? ProductCategory.values.byName('${json['category']}') : null,
      title: json['title'] ?? 'Sem título',
      description: json['description'] ?? 'Sem descrição',
      website: json['website'] ?? '',
      warrantyInDays: int.tryParse(json['warrantyInDays']?.toString() ?? '0') ?? 0,
      price: json['price'] != null ? double.parse(json['price'].toString()) : 0,
      billingType: json['billingType'] != null ? ProductBillingType.values.byName('${json['billingType']}') : null,
      imageUrl: json['coverUrl'], // Ajuste a chave conforme seu backend ('image', 'cover', etc)
      type: json['type'] != null ? ProductType.values.byName('${json['type']}') : null,
      sales: int.tryParse(json['sales']?.toString() ?? '0') ?? 0,
      status: json['status'] ?? 'Ativo',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "type": type?.name.toString(),
      "category": category?.name.toString(),
      'title': title,
      'description': description,
      "website": website,
      "warrantyInDays": warrantyInDays,
      'price': price,
      "billingType": billingType?.name.toString(),
      'cover': imageUrl,
    };
  }
}
