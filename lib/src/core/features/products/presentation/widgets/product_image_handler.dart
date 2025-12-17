import 'package:flutter/material.dart';
import 'package:voomp_sellers_rebranding/src/core/theme/app_colors.dart'; // Ajuste o import conforme seu projeto

class ProductImageHandler extends StatelessWidget {
  final String? imageUrl;
  final double height;
  final double width;

  const ProductImageHandler({
    super.key,
    required this.imageUrl,
    this.height = 150, // Altura padrão do card
    this.width = double.infinity,
  });

  @override
  Widget build(BuildContext context) {
    // 1. Verifica se a URL é nula ou vazia
    if (imageUrl == null || imageUrl!.isEmpty) {
      return _buildPlaceholder();
    }

    return Image.network(
      imageUrl!,
      height: height,
      width: width,
      fit: BoxFit.cover,

      // 2. Loading: Mostra um shimmer ou spinner enquanto carrega
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          height: height,
          width: width,
          color: Colors.grey[200],
          child: const Center(
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppPalette.orange500,
            ),
          ),
        );
      },

      // 3. Erro: Se a URL existir mas der 404 ou erro de rede
      errorBuilder: (context, error, stackTrace) {
        return _buildPlaceholder(isError: true);
      },
    );
  }

  // Widget visual para quando não tem imagem ou deu erro
  Widget _buildPlaceholder({bool isError = false}) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8), // Ajuste conforme o raio do seu card
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isError ? Icons.broken_image_outlined : Icons.image_not_supported_outlined,
            color: Colors.grey[400],
            size: 32,
          ),
          const SizedBox(height: 8),
          Text(
            isError ? "Imagem indisponível" : "Sem imagem",
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
