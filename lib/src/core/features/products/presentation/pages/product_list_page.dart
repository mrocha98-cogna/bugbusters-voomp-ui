import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:voomp_sellers_rebranding/src/core/common/widgets/max_width_container.dart';
import 'package:voomp_sellers_rebranding/src/core/features/products/data/models/product_model.dart';
import 'package:voomp_sellers_rebranding/src/core/features/products/data/repositories/product_repository.dart';
import 'package:voomp_sellers_rebranding/src/core/features/products/presentation/widgets/product_image_handler.dart';
import 'package:voomp_sellers_rebranding/src/core/features/products/services/product_service.dart';
import 'package:voomp_sellers_rebranding/src/core/network/api_endpoints.dart';
import 'package:voomp_sellers_rebranding/src/core/network/voomp_api_client.dart';
import 'package:voomp_sellers_rebranding/src/core/theme/app_colors.dart';
import 'package:http/http.dart' as http;

class ProductListPage extends StatefulWidget {
  const ProductListPage({super.key});

  @override
  State<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  late final ProductService _productService;
  List<ProductModel> _products = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // Instanciação simples (ajuste conforme sua arquitetura)
    final client = VoompApiClient(client: http.Client(), baseUrl: ApiEndpoints.apiVoompBaseUrl);
    final repo = ProductRepository(client);
    _productService = ProductService(repo);

    _loadProducts();
  }

  Future<void> _loadProducts() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final products = await _productService.fetchProducts();
      setState(() {
        _products = products;
        _isLoading = false;
      });
    } catch (e) {
      print(e);
      setState(() {
        _isLoading = false;
        _errorMessage = 'Erro ao carregar produtos. Tente novamente.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: MaxWidthContainer(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isMobile = constraints.maxWidth < 600;

                    // 1. Botão Voltar
                    final backButton = OutlinedButton.icon(
                      onPressed: () => context.go('/home'),
                      style: OutlinedButton.styleFrom( // Mudei para OutlinedButton.styleFrom para combinar com o widget
                        backgroundColor: AppPalette.white,
                        foregroundColor: AppPalette.orange500,
                        side: const BorderSide(color: AppPalette.neutral300), // Adicionei borda para ficar visível no fundo branco
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      icon: const Icon(Icons.arrow_back, size: 18, color: AppPalette.orange500),
                      label: const Text(
                        "voltar",
                        style: TextStyle(fontWeight: FontWeight.bold, color: AppPalette.orange500),
                      ),
                    );

                    // 2. Título e Subtítulo
                    final titleSection = Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Meus Produtos",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Gerencie seu catálogo",
                          style: TextStyle(
                            fontSize: 14,
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                      ],
                    );

                    // 3. Botão Novo Produto
                    final newButton = ElevatedButton.icon(
                      onPressed: () => context.go('/create-product'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppPalette.orange500,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      icon: const Icon(Icons.add, size: 18, color: AppPalette.surfaceText),
                      label: const Text(
                        "Novo Produto",
                        style: TextStyle(fontWeight: FontWeight.bold, color: AppPalette.surfaceText),
                      ),
                    );

                    // LÓGICA DE EXIBIÇÃO
                    if (isMobile) {
                      // Layout Mobile: Coluna
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Linha com os botões de ação nas extremidades
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              backButton,
                              // No mobile, podemos simplificar o botão "Novo" ou deixá-lo aqui
                              newButton,
                            ],
                          ),
                          const SizedBox(height: 24),
                          // Título abaixo dos botões
                          titleSection,
                        ],
                      );
                    } else {
                      // Layout Desktop: Linha única (Original)
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          backButton,
                          titleSection,
                          newButton,
                        ],
                      );
                    }
                  },
                ),
                const SizedBox(height: 32),
                TextField(
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search, color: AppPalette.neutral500),
                    hintText: "Buscar por nome do produto...",
                    hintStyle: const TextStyle(color: AppPalette.neutral500),
                    filled: true,
                    fillColor: theme.cardColor,
                    contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: AppPalette.neutral300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: AppPalette.neutral300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: AppPalette.orange500),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: _products.isEmpty
                      ? _buildEmptyState(theme)
                      : LayoutBuilder(
                    builder: (context, constraints) {
                      // Grid Responsivo:
                      // Mobile: 1 coluna
                      // Tablet: 2 colunas
                      // Desktop: 3 ou 4 colunas
                      int crossAxisCount = 1;
                      if (constraints.maxWidth > 600) crossAxisCount = 2;
                      if (constraints.maxWidth > 900) crossAxisCount = 3;
                      if (constraints.maxWidth > 1200) crossAxisCount = 4;

                      return GridView.builder(
                        itemCount: _products.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 0.85, // Proporção do card
                        ),
                        itemBuilder: (context, index) {
                          return _ProductCard(
                            product: _products[index],
                            theme: theme,
                            isDark: isDark,
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inventory_2_outlined, size: 64, color: AppPalette.neutral300),
          const SizedBox(height: 16),
          Text(
            "Você ainda não tem produtos",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Crie seu primeiro produto para começar a vender",
            style: TextStyle(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final ProductModel product; // Mudou de Map para ProductModel
  final ThemeData theme;
  final bool isDark;

  const _ProductCard({required this.product, required this.theme, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final bool isActive = product.status == 'Ativo';

    return InkWell(
      onTap: () => context.push(
        '/product-details/${product.id}',
        extra: product,
      ),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(color: AppPalette.neutral300.withOpacity(0.5)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ProductImageHandler(
              imageUrl: product.imageUrl, // Passa a URL vinda da API
              height: 140, // Defina a altura que você quer no card
            ),
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Badge de Tipo
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppPalette.orange500.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            product.type != null ? product.type!.label.toUpperCase() : '',
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: AppPalette.orange500,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          product.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 4),
                        // Preço
                        Text(
                          "R\$ ${product.price}",
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppPalette.orange500,
                          ),
                        ),
                      ],
                    ),

                    // Rodapé do Card (Status e Vendas)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isActive ? Colors.green : Colors.grey,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              product.status,
                              style: TextStyle(
                                fontSize: 12,
                                color: theme.colorScheme.onSurface.withOpacity(0.6),
                              ),
                            ),
                          ],
                        ),
                        // if (isActive)
                        //   Text(
                        //     "${product['sales']} vendas",
                        //     style: TextStyle(
                        //       fontSize: 12,
                        //       fontWeight: FontWeight.bold,
                        //       color: theme.colorScheme.onSurface.withOpacity(0.6),
                        //     ),
                        //   ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}