import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart'; // Adicione ao pubspec.yaml se não tiver: intl: ^0.18.0
import 'package:provider/provider.dart'; // Assumindo uso de Provider, ou acesse seu repository como preferir
import 'package:url_launcher/url_launcher.dart';
import 'package:voomp_sellers_rebranding/src/core/common/widgets/max_width_container.dart';
import 'package:voomp_sellers_rebranding/src/core/features/products/data/models/product_model.dart';
import 'package:voomp_sellers_rebranding/src/core/features/products/data/repositories/product_repository.dart';
import 'package:voomp_sellers_rebranding/src/core/theme/app_colors.dart';

class ProductDetailsPage extends StatefulWidget {
  final String productId;
  final ProductModel? product;

  const ProductDetailsPage({
    super.key,
    required this.productId,
    this.product,
  });

  @override
  State<ProductDetailsPage> createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends State<ProductDetailsPage> {
  late Future<ProductModel?> _productFuture;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    // Se o produto já veio preenchido da tela anterior, usamos ele diretamente
    if (widget.product != null) {
      _productFuture = Future.value(widget.product);
    } else {
      final repository = context.read<ProductRepository>();
      _productFuture = repository.getProductById(widget.productId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    var localProduct = widget.product!;


    final currencyFormat = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    final formattedPrice = currencyFormat.format(localProduct.price);


    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: MaxWidthContainer(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- HEADER ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton.icon(
                      onPressed: () {
                        if(context.canPop()){
                          context.pop();
                        }else{
                          context.go('/home');
                        }
                      },
                      icon: const Icon(
                        Icons.arrow_back,
                        size: 16,
                        color: AppPalette.orange500,
                      ),
                      label: const Text(
                        "Voltar",
                        style: TextStyle(
                          color: AppPalette.orange500,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        alignment: Alignment.centerLeft,
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        // Navegar para edição passando o objeto
                        // context.push('/edit-product', extra: product);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppPalette.orange500,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                      ),
                      icon: const Icon(
                        Icons.edit,
                        size: 16,
                        color: AppPalette.surfaceText,
                      ),
                      label: const Text(
                        "Editar produto",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppPalette.surfaceText,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // --- CONTEÚDO (Grid Responsivo) ---
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isDesktop = constraints.maxWidth > 900;

                    // Widgets extraídos para reutilização no if/else
                    final imageCard = _ProductImageCard(
                      imageUrl: localProduct.imageUrl,
                    );
                    final priceCard = _PriceCard(
                      price: formattedPrice,
                      billingType:
                          localProduct.billingType != null
                              ?localProduct.billingType!.label
                        : '', // Usa o Enum convertido ou string
                    );
                    // Ajuste a data conforme seu model
                    // final dateCard = _InfoCard(icon: Icons.calendar_today, label: "Criado em", value: formattedDate, theme: theme);

                    final titleCard = _TitleCard(
                      title: localProduct.title,
                      website: localProduct.website,
                    );
                    final descCard = _DescriptionCard(
                      description: localProduct.description ?? '',
                    );

                    final categoryCard = _InfoCard(
                      icon: Icons.category_outlined,
                      label: "Categoria",
                      value:
                          localProduct.category != null
                              ? localProduct.category!.label
                              : '',
                      theme: theme,
                    );

                    final warrantyCard = _InfoCard(
                      icon: Icons.verified_user_outlined,
                      label: "Garantia",
                      value: "${localProduct.warrantyInDays} dias",
                      theme: theme,
                    );

                    if (isDesktop) {
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Coluna Esquerda
                          Expanded(
                            flex: 4,
                            child: Column(
                              children: [
                                imageCard,
                                const SizedBox(height: 24),
                                priceCard,
                                const SizedBox(height: 24),
                                // dateCard,
                              ],
                            ),
                          ),
                          const SizedBox(width: 24),
                          // Coluna Direita
                          Expanded(
                            flex: 6,
                            child: Column(
                              children: [
                                titleCard,
                                const SizedBox(height: 24),
                                descCard,
                                const SizedBox(height: 24),
                                Row(
                                  children: [
                                    Expanded(child: categoryCard),
                                    const SizedBox(width: 24),
                                    Expanded(child: warrantyCard),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    } else {
                      // Mobile
                      return Column(
                        children: [
                          imageCard,
                          const SizedBox(height: 24),
                          titleCard,
                          const SizedBox(height: 24),
                          descCard,
                          const SizedBox(height: 24),
                          priceCard,
                          const SizedBox(height: 24),
                          Row(
                            children: [
                              Expanded(child: categoryCard),
                              const SizedBox(width: 16),
                              Expanded(child: warrantyCard),
                            ],
                          ),
                          // const SizedBox(height: 24),
                          // dateCard,
                        ],
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BaseCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const _BaseCard({
    required this.child,
    this.padding = const EdgeInsets.all(24),
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: padding,
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
      ),
      child: child,
    );
  }
}

class _ProductImageCard extends StatelessWidget {
  final String? imageUrl; // Pode ser nulo
  const _ProductImageCard({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return _BaseCard(
      padding: const EdgeInsets.all(12),
      child: AspectRatio(
        aspectRatio: 1,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: (imageUrl != null && imageUrl!.isNotEmpty)
              ? Image.network(
                  imageUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      _buildPlaceholder(),
                )
              : _buildPlaceholder(),
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: Colors.grey[200],
      child: const Icon(
        Icons.image_not_supported,
        size: 50,
        color: Colors.grey,
      ),
    );
  }
}

class _TitleCard extends StatelessWidget {
  final String title;
  final String? website; // Link da página de vendas

  const _TitleCard({required this.title, this.website});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return _BaseCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          if (website != null && website!.isNotEmpty) ...[
            const SizedBox(height: 16),
            InkWell(
              onTap: () {
                launchUrl(Uri.https(website!));
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(
                    Icons.open_in_new,
                    size: 16,
                    color: AppPalette.orange500,
                  ),
                  SizedBox(width: 8),
                  Text(
                    "Visitar página de vendas",
                    style: TextStyle(
                      color: AppPalette.orange500,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _DescriptionCard extends StatelessWidget {
  final String description;

  const _DescriptionCard({required this.description});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return _BaseCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppPalette.orange500.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(
                  Icons.description,
                  size: 18,
                  color: AppPalette.orange500,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                "Descrição",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            description.isEmpty ? "Sem descrição." : description,
            style: TextStyle(
              fontSize: 14,
              height: 1.6,
              color: theme.colorScheme.onSurface.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }
}

class _PriceCard extends StatelessWidget {
  final String price;
  final String billingType;

  const _PriceCard({required this.price, required this.billingType});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Ajuste visual do tipo de cobrança
    String typeLabel = "Cobrança Única";
    if (billingType.toLowerCase().contains('sub') ||
        billingType.toLowerCase().contains('assinatura')) {
      typeLabel = "Assinatura / Recorrente";
    }

    return _BaseCard(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
      child: Column(
        children: [
          Text(
            "Preço",
            style: TextStyle(
              fontSize: 14,
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            price,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: AppPalette.orange500,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            typeLabel,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final ThemeData theme;

  const _InfoCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return _BaseCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: AppPalette.orange500),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              color: theme.colorScheme.onSurface.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }
}
