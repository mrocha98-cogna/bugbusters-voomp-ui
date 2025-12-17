import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:voomp_sellers_rebranding/src/core/common/widgets/max_width_container.dart';
import 'package:voomp_sellers_rebranding/src/core/features/products/data/models/product_enums.dart';
import 'package:voomp_sellers_rebranding/src/core/features/products/data/models/product_model.dart';
import 'package:voomp_sellers_rebranding/src/core/features/products/data/repositories/product_repository.dart';
import 'package:voomp_sellers_rebranding/src/core/features/products/services/product_service.dart';
import 'package:voomp_sellers_rebranding/src/core/network/api_endpoints.dart';
import 'package:voomp_sellers_rebranding/src/core/network/voomp_api_client.dart';
import 'package:voomp_sellers_rebranding/src/core/theme/app_colors.dart';
import 'package:http/http.dart' as http;

class CreateProductPage extends StatefulWidget {
  const CreateProductPage({super.key});

  @override
  State<CreateProductPage> createState() => _CreateProductPageState();
}

class _CreateProductPageState extends State<CreateProductPage> {
  int _currentStep = 0;
  ProductType? _selectedProductType;
  ProductCategory? _selectedCategory;
  String _productTitle = '';
  String _productDescription = '';
  String _website = '';
  ProductBillingType _billingType = ProductBillingType.oneTime;
  double _price = 0.00;
  int _guaranteeDays = 7;
  late final ProductService _productService; // Adicionar
  bool _isSaving = false;
  XFile? _selectedImage;

  final List<_ProductStepData> _steps = [
    _ProductStepData(Icons.laptop_mac, "Tipo de Produto", _StepState.current),
    _ProductStepData(Icons.category_outlined, "Categoria", _StepState.locked),
    _ProductStepData(Icons.edit_note, "Detalhes", _StepState.locked),
    _ProductStepData(Icons.attach_money, "Preço", _StepState.locked),
    _ProductStepData(
      Icons.check_circle_outline,
      "Confirmar",
      _StepState.locked,
    ),
  ];

  @override
  void initState() {
    super.initState();
    final client = VoompApiClient(
      client: http.Client(),
      baseUrl: ApiEndpoints.apiVoompBaseUrl,
    );
    final repo = ProductRepository(client);
    _productService = ProductService(repo);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: MaxWidthContainer(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Botão Voltar (Link simples)
                TextButton.icon(
                  onPressed: () => context.go('/home'),
                  // Ajuste a rota conforme necessário
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

                const SizedBox(height: 24),

                // 2. Card de Progresso (Topo)
                _ProductProgressCard(currentStep: _currentStep, steps: _steps),

                const SizedBox(height: 24),

                // 3. Card de Conteúdo Principal (Step 1: O que você quer vender?)
                _buildCurrentStepContent(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentStepContent() {
    switch (_currentStep) {
      case 0:
        return _StepContentCard(
          selectedType: _selectedProductType,
          onTypeSelected: (type) => setState(() => _selectedProductType = type),
          onContinue: _selectedProductType != null ? _nextStep : null,
          onBack: null, // Primeiro passo não tem "Voltar" interno
        );
      case 1:
        return _StepCategoryCard(
          selectedCategory: _selectedCategory,
          onCategorySelected: (category) =>
              setState(() => _selectedCategory = category),
          onContinue: _selectedCategory != null ? _nextStep : null,
          onBack: _prevStep,
        );
      case 2:
        return _StepDetailsCard(
          initialTitle: _productTitle,
          initialDescription: _productDescription,
          initialSalesPage: _website,
          pickedImage: _selectedImage,
          onImagePicked: (file) => setState(() => _selectedImage = file),
          onTitleChanged: (val) => setState(() => _productTitle = val),
          onDescriptionChanged: (val) =>
              setState(() => _productDescription = val),
          onSalesPageChanged: (val) => setState(() => _website = val),
          onContinue:
              (_productTitle.isNotEmpty && _productDescription.isNotEmpty)
              ? _nextStep
              : null,
          onBack: _prevStep,
        );
      case 3:
        return _StepPriceCard(
          productTitle: _productTitle,
          billingType: _billingType,
          price: _price,
          guaranteeDays: _guaranteeDays,
          onBillingTypeChanged: (val) => setState(() => _billingType = val),
          onPriceChanged: (val) =>
              setState(() => _price = double.tryParse(val) ?? 0.0),
          onGuaranteeChanged: (val) =>
              setState(() => _guaranteeDays = int.tryParse(val) ?? 0),
          onContinue: (_price > 0 && _guaranteeDays != 0) ? _nextStep : null,
          onBack: _prevStep,
        );
      case 4:
        return _StepConfirmationCard(
          productType: _selectedProductType,
          // Valor padrão ou mapa de labels
          category: _selectedCategory,
          title: _productTitle.isEmpty ? 'Sem título' : _productTitle,
          description: _productDescription.isEmpty
              ? 'Sem descrição'
              : _productDescription,
          billingType: _billingType.label,
          price: _price,
          guaranteeDays: _guaranteeDays,
          website: _website,
          onBack: _prevStep,
          onConfirm: _finishCreation,
          pickedImage: _selectedImage,
          isLoading: _isSaving,
        );
      default:
        return const SizedBox.shrink(); // Passos futuros
    }
  }

  void _nextStep() {
    setState(() {
      _steps[_currentStep].state = _StepState.completed;
      _currentStep++;
      if (_currentStep < _steps.length) {
        _steps[_currentStep].state = _StepState.current;
      }
    });
  }

  void _prevStep() {
    setState(() {
      _steps[_currentStep].state = _StepState.locked;
      _currentStep--;
      _steps[_currentStep].state = _StepState.current;
    });
  }

  Future<void> _finishCreation() async {
    setState(() => _isSaving = true);

    // 1. Montar o objeto com os dados coletados nos inputs
    final newProduct = ProductModel(
      id: '',
      title: _productTitle,
      description: _productDescription,
      website: _website,
      price: _price,
      warrantyInDays: _guaranteeDays,
      billingType: _billingType,
      type: _selectedProductType,
      category: _selectedCategory,
      status: 'Ativo',
      sales: 0,
      imageUrl: null,
    );

    try {
      final success = await _productService.createProduct(
        newProduct,
        imageFile: _selectedImage,
      );

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Produto criado com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
        // Redireciona para a lista ou detalhes (se o back retornar o ID, melhor ainda)
        context.go('/products');
      } else {
        throw Exception('Falha desconhecida');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao criar produto: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }
}

class _ProductProgressCard extends StatelessWidget {
  final int currentStep;
  final List<_ProductStepData> steps;

  const _ProductProgressCard({required this.currentStep, required this.steps});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Calcula porcentagem baseada no passo atual
    // Ex: 0 de 5 = 0%, 1 de 5 = 20%
    final double progressValue = currentStep / 5;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 24),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Criar Produto",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              Text(
                '${(progressValue * 100).toString()}%',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                  color: AppPalette.orange500,
                ),
              ),
            ],
          ),
          Text(
            "$currentStep de ${steps.length} etapas concluídas",
            style: TextStyle(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progressValue,
              minHeight: 8,
              backgroundColor: const Color(0xFFE0E0E0),
              color: AppPalette.orange500,
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            height: 120,
            width: double.infinity,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: steps.length,
              separatorBuilder: (context, index) => _buildConnector(
                index <= currentStep,
                steps[index].state == _StepState.completed,
              ),
              itemBuilder: (context, index) {
                return _buildStepItem(
                  context,
                  steps[index],
                  index == currentStep,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConnector(bool isActive, bool isCompleted) {
    return Container(
      width: 24,
      height: 2,
      margin: const EdgeInsets.only(top: 58.5, bottom: 58.5),
      color: isCompleted
          ? AppPalette.success500
          : isActive
          ? AppPalette.orange500
          : AppPalette.neutral300,
    );
  }

  Widget _buildStepItem(
    BuildContext context,
    _ProductStepData step,
    bool isCurrent,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Cores baseadas no estado (Copiando o padrão da Home que ajustamos)
    Color bg = isDark
        ? Colors.orange.withOpacity(0.1)
        : const Color(0xFFFFF3E0);
    Color border = isCurrent ? AppPalette.orange500 : Colors.transparent;
    // Se não for current, usamos um fundo mais neutro se estiver locked
    if (step.state == _StepState.locked) {
      bg = isDark
          ? AppPalette.neutral100.withOpacity(0.1)
          : AppPalette.orange500.withOpacity(0.1);
    }

    if (step.state == _StepState.completed) {
      bg = AppPalette.success500.withOpacity(0.2);
    }

    return Container(
      width: 110,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: border, width: 2),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: step.state == _StepState.completed
                  ? Colors.transparent
                  : AppPalette.orange400.withOpacity(0.5),
              borderRadius: BorderRadius.circular(8),
              border: step.state == _StepState.completed
                  ? Border.all(color: AppPalette.success500, width: 2)
                  : null,
            ),
            child: Icon(
              step.state == _StepState.completed ? Icons.check : step.icon,
              color: step.state == _StepState.completed
                  ? AppPalette.success500
                  : isCurrent
                  ? AppPalette.orange700
                  : AppPalette.white,
              size: 24,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            step.title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
              color: step.state == _StepState.completed
                  ? AppPalette.success500
                  : AppPalette.orange500.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }
}

class _StepCategoryCard extends StatefulWidget {
  final ProductCategory? selectedCategory;
  final Function(ProductCategory?) onCategorySelected;
  final VoidCallback? onContinue;
  final VoidCallback? onBack;

  const _StepCategoryCard({
    required this.selectedCategory,
    required this.onCategorySelected,
    required this.onContinue,
    required this.onBack,
  });

  @override
  State<_StepCategoryCard> createState() => _StepCategoryCardState();
}

class _StepContentCard extends StatelessWidget {
  final ProductType? selectedType;
  final Function(ProductType) onTypeSelected;
  final VoidCallback? onContinue;
  final VoidCallback? onBack;

  const _StepContentCard({
    required this.selectedType,
    required this.onTypeSelected,
    required this.onContinue,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Ajuste as chaves (ProductType.course, etc) conforme os nomes reais do seu Enum
    final Map<ProductType, Map<String, dynamic>> typeOptions = {
      ProductType.infoProduct: {
        "icon": Icons.laptop_mac,
        "label": ProductType.infoProduct.label,
      },
      ProductType.ebook: {"icon": Icons.menu_book, "label": "Ebook"},
      ProductType.extensionCourse: {
        "icon": Icons.school,
        "label": ProductType.extensionCourse.label,
      },
      ProductType.postgraduate: {
        "icon": Icons.workspace_premium,
        "label": ProductType.postgraduate.label,
      },
      ProductType.other: {
        "icon": Icons.more_horiz,
        "label": ProductType.other.label,
      },
    };

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
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
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF3E0),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Text(
              "Etapa 1",
              style: TextStyle(
                color: AppPalette.orange500,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            "O que você quer vender?",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Escolha o tipo de produto que melhor descreve sua oferta",
            style: TextStyle(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),

          const SizedBox(height: 32),

          LayoutBuilder(
            builder: (context, constraints) {
              return Wrap(
                spacing: 16,
                runSpacing: 16,
                alignment: WrapAlignment.center,
                children: typeOptions.entries.map((entry) {
                  final typeEnum = entry.key; // O Enum
                  final data = entry.value; // O Icon e Label

                  final isSelected = selectedType == typeEnum;
                  return InkWell(
                    onTap: () => onTypeSelected(typeEnum),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      width: 140,
                      // Largura fixa dos cards de seleção
                      height: 120,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: theme.cardColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? AppPalette.orange500
                              : AppPalette.neutral300,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            data['icon'] as IconData,
                            color: isSelected
                                ? AppPalette.orange500
                                : AppPalette.orange500,
                            // Ícone sempre laranja na imagem
                            size: 28,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            data['label'] as String,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),

          const SizedBox(height: 48),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              OutlinedButton.icon(
                onPressed: onBack,
                icon: Icon(
                  Icons.arrow_back,
                  size: 16,
                  color: onBack != null
                      ? theme.colorScheme.primary
                      : AppPalette.neutral300,
                ),
                label: Text(
                  "Voltar",
                  style: TextStyle(
                    color: onBack != null
                        ? theme.colorScheme.primary
                        : AppPalette.neutral300,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(
                    color: onBack != null
                        ? theme.colorScheme.primary
                        : AppPalette.neutral300,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: onContinue,
                style: ElevatedButton.styleFrom(
                  backgroundColor: onContinue != null
                      ? AppPalette.orange500
                      : Colors.grey[300],
                  foregroundColor: onContinue != null
                      ? AppPalette.surfaceText
                      : Colors.grey[600],
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                // Usamos uma Row para controlar a ordem: Texto primeiro, depois Ícone
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Text(
                      "Continuar",
                      style: TextStyle(color: AppPalette.surfaceText),
                    ),
                    SizedBox(width: 8), // Espaçamento entre texto e ícone
                    Icon(
                      Icons.arrow_forward,
                      color: AppPalette.surfaceText,
                      size: 16,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StepCategoryCardState extends State<_StepCategoryCard> {
  final TextEditingController _searchController = TextEditingController();

  List<ProductCategory> _filteredCategories = [];

  @override
  void initState() {
    super.initState();
    _filteredCategories = ProductCategory.values;
    _searchController.addListener(_filterList);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterList() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredCategories = ProductCategory.values
          .where((cat) => cat.label.toLowerCase().contains(query))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
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
      child: Column(
        children: [
          // Header da Etapa
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF3E0),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Text(
              "Etapa 2",
              style: TextStyle(
                color: AppPalette.orange500,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            "Qual é a categoria do seu produto?",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Escolha a categoria que melhor se encaixa",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 32),

          // Campo de Busca
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              prefixIcon: const Icon(
                Icons.search,
                color: AppPalette.neutral500,
              ),
              hintText: "Pesquisar pela categoria",
              hintStyle: const TextStyle(color: AppPalette.neutral500),
              contentPadding: const EdgeInsets.symmetric(vertical: 16),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppPalette.neutral300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppPalette.neutral300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppPalette.orange500),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Lista de Categorias (Radio Buttons)
          Container(
            height: 300, // Altura fixa com scroll interno
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[900] : Colors.white,
              // Fundo branco/escuro para a lista
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppPalette.neutral100),
            ),
            child: Scrollbar(
              thumbVisibility: true,
              child: ListView.separated(
                padding: EdgeInsets.zero,
                itemCount: _filteredCategories.length,
                separatorBuilder: (context, index) =>
                    const Divider(height: 1, color: AppPalette.neutral200),
                itemBuilder: (context, index) {
                  final category = _filteredCategories[index];
                  final isSelected = widget.selectedCategory == category;

                  return Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => widget.onCategorySelected(category),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        child: Row(
                          children: [
                            // Custom Radio Button Visual
                            Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isSelected
                                      ? AppPalette.orange500
                                      : AppPalette.neutral500,
                                  width: 2,
                                ),
                              ),
                              child: isSelected
                                  ? Center(
                                      child: Container(
                                        width: 12,
                                        height: 12,
                                        decoration: const BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: AppPalette.orange500,
                                        ),
                                      ),
                                    )
                                  : null,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                category.label,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.w500,
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          const SizedBox(height: 48),

          // Rodapé (Botões Voltar e Continuar)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              OutlinedButton.icon(
                onPressed: widget.onBack,
                icon: Icon(
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
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppPalette.orange500),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: widget.onContinue,
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.onContinue != null
                      ? AppPalette.orange500
                      : Colors.grey[300],
                  foregroundColor: widget.onContinue != null
                      ? AppPalette.surfaceText
                      : Colors.grey[600],
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Text(
                      "Continuar",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppPalette.surfaceText,
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(Icons.arrow_forward, size: 16),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StepDetailsCard extends StatefulWidget {
  final String initialTitle;
  final String initialDescription;
  final String initialSalesPage;
  final XFile? pickedImage;
  final ValueChanged<XFile?> onImagePicked;
  final ValueChanged<String> onTitleChanged;
  final ValueChanged<String> onDescriptionChanged;
  final ValueChanged<String> onSalesPageChanged;
  final VoidCallback? onContinue;
  final VoidCallback? onBack;

  const _StepDetailsCard({
    required this.initialTitle,
    required this.initialDescription,
    required this.initialSalesPage,
    required this.pickedImage,
    required this.onImagePicked,
    required this.onTitleChanged,
    required this.onDescriptionChanged,
    required this.onSalesPageChanged,
    required this.onContinue,
    required this.onBack,
  });

  @override
  State<_StepDetailsCard> createState() => _StepDetailsCardState();
}

class _StepDetailsCardState extends State<_StepDetailsCard> {
  late TextEditingController _titleController;
  late TextEditingController _descController;
  late TextEditingController _salesController;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.initialTitle);
    _descController = TextEditingController(text: widget.initialDescription);
    _salesController = TextEditingController(text: widget.initialSalesPage);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _salesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
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
      child: Column(
        children: [
          // Header da Etapa
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF3E0),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Text(
              "Etapa 3",
              style: TextStyle(
                color: AppPalette.orange500,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            "Conte sobre seu produto",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Adicione as informações principais do seu produto",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 40),

          // Layout Responsivo (Upload + Form)
          LayoutBuilder(
            builder: (context, constraints) {
              // Se tiver espaço suficiente (ex: tablet/web), coloca lado a lado
              // Caso contrário (mobile), empilha.
              if (constraints.maxWidth > 700) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(width: 250, child: _buildImageUploadArea(theme)),
                    const SizedBox(width: 32),
                    Expanded(child: _buildFormFields(theme)),
                  ],
                );
              } else {
                return Column(
                  children: [
                    _buildImageUploadArea(theme),
                    const SizedBox(height: 32),
                    _buildFormFields(theme),
                  ],
                );
              }
            },
          ),

          const SizedBox(height: 48),

          // Rodapé (Botões)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              OutlinedButton.icon(
                onPressed: widget.onBack,
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
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppPalette.orange500),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: widget.onContinue,
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.onContinue != null
                      ? AppPalette.orange500
                      : Colors.grey[300],
                  foregroundColor: widget.onContinue != null
                      ? AppPalette.surfaceText
                      : Colors.grey[600],
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Text(
                      "Continuar",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppPalette.surfaceText,
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(Icons.arrow_forward, size: 16),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildImageUploadArea(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Imagem do Produto",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),

        // MUDANÇA: Usamos GestureDetector no topo para garantir que o toque seja capturado
        GestureDetector(
          onTap: _pickImage,
          child: Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
              // Se tiver imagem, mostra ela no background
              image: widget.pickedImage != null
                  ? DecorationImage(
                      image: kIsWeb
                          ? NetworkImage(widget.pickedImage!.path)
                          : FileImage(File(widget.pickedImage!.path))
                                as ImageProvider,
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            // O conteúdo interno (ícone/texto) deve ignorar toques para não bloquear o GestureDetector pai
            child: widget.pickedImage == null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(
                          Icons.add_photo_alternate_outlined,
                          size: 40,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 8),
                        Text(
                          "Clique para adicionar uma imagem",
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                : Stack(
                    children: [
                      Positioned(
                        top: 8,
                        right: 8,
                        // Botão de remover com GestureDetector próprio
                        child: GestureDetector(
                          onTap: _clearImage,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                              color: Colors.black54,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  Future<void> _pickImage() async {
    print("--- CLICOU NA IMAGEM ---");
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        print("Imagem selecionada: ${image.path}"); // Debug
        widget.onImagePicked(image);
      } else {
        print("Seleção cancelada pelo usuário");
      }
    } catch (e) {
      // Isso vai mostrar o erro real no console
      print('ERRO CRÍTICO AO ABRIR GALERIA: $e');
      debugPrint('Stacktrace: $e');
    }
  }

  void _clearImage() {
    setState(() {
      widget.onImagePicked(null);
    });
  }

  // Widget dos Campos de Texto
  Widget _buildFormFields(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Campo Título
        _buildLabelWithAI("Título do Produto *", theme),
        const SizedBox(height: 8),
        TextFormField(
          controller: _titleController,
          onChanged: widget.onTitleChanged,
          decoration: _inputDecoration(
            "Ex: Curso de Marketing Digital 2.0",
            theme,
          ),
        ),

        const SizedBox(height: 24),

        // Campo Descrição
        _buildLabelWithAI("Descrição do Produto *", theme),
        const SizedBox(height: 8),
        TextFormField(
          controller: _descController,
          onChanged: widget.onDescriptionChanged,
          maxLines: 5,
          decoration: _inputDecoration(
            "Uma breve descrição do produto/serviço, benefícios e etc",
            theme,
          ),
        ),

        const SizedBox(height: 24),

        // Campo Página de Vendas
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Página de Vendas (opcional)",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _salesController,
          onChanged: widget.onSalesPageChanged,
          decoration: _inputDecoration("https://suapagina.com/produto", theme),
        ),
        const SizedBox(height: 8),
        Text(
          "Informe o Instagram, Facebook ou onde será vendido o produto",
          style: TextStyle(
            fontSize: 12,
            color: theme.colorScheme.onSurface.withOpacity(0.5),
          ),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            "3/100", // Contador estático (pode ser dinâmico usando .length)
            style: TextStyle(
              fontSize: 12,
              color: theme.colorScheme.onSurface.withOpacity(0.5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLabelWithAI(String label, ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: theme.colorScheme.onSurface,
          ),
        ),
        // Botão "Melhorar com IA"
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            border: Border.all(color: AppPalette.neutral300),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.auto_awesome,
                size: 12,
                color: AppPalette.neutral500,
              ),
              const SizedBox(width: 4),
              Text(
                "Melhorar com IA",
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration(String hint, ThemeData theme) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: AppPalette.neutral400),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppPalette.neutral300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppPalette.neutral300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppPalette.orange500),
      ),
    );
  }
}

class _StepPriceCard extends StatefulWidget {
  final String productTitle;
  final ProductBillingType? billingType;
  final double price;
  final int guaranteeDays;
  final ValueChanged<ProductBillingType> onBillingTypeChanged;
  final ValueChanged<String> onPriceChanged;
  final ValueChanged<String> onGuaranteeChanged;
  final VoidCallback? onContinue;
  final VoidCallback? onBack;

  const _StepPriceCard({
    required this.productTitle,
    required this.billingType,
    required this.price,
    required this.guaranteeDays,
    required this.onBillingTypeChanged,
    required this.onPriceChanged,
    required this.onGuaranteeChanged,
    required this.onContinue,
    required this.onBack,
  });

  @override
  State<_StepPriceCard> createState() => _StepPriceCardState();
}

class _StepPriceCardState extends State<_StepPriceCard> {
  late TextEditingController _priceController;
  late TextEditingController _guaranteeController;

  @override
  void initState() {
    super.initState();
    _priceController = TextEditingController(text: widget.price.toString());
    _guaranteeController = TextEditingController(
      text: widget.guaranteeDays.toString(),
    );
  }

  @override
  void dispose() {
    _priceController.dispose();
    _guaranteeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
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
      child: Column(
        children: [
          // Header da Etapa
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF3E0),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Text(
              "Etapa 4",
              style: TextStyle(
                color: AppPalette.orange500,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            "Defina o preço e condições",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Configure como seu produto será vendido",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          // Exibe o nome do produto selecionado anteriormente (opcional, conforme imagem "Curso de Gatos")
          if (widget.productTitle.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              widget.productTitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: theme.colorScheme.onSurface.withOpacity(0.8),
              ),
            ),
          ],

          const SizedBox(height: 40),

          // Seção: Tipo de Cobrança
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Tipo de Cobrança *",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildTypeOption(
                label: ProductBillingType.subscription.label,
                value: ProductBillingType.subscription,
                theme: theme,
              ),
              const SizedBox(width: 16),
              _buildTypeOption(
                label: ProductBillingType.oneTime.label,
                value: ProductBillingType.oneTime,
                theme: theme,
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Seção: Preço e Garantia (Lado a lado em telas maiores, ou responsivo)
          LayoutBuilder(
            builder: (context, constraints) {
              // Se tiver pouco espaço (mobile), empilha
              if (constraints.maxWidth < 600) {
                return Column(
                  children: [
                    _buildPriceField(theme),
                    const SizedBox(height: 24),
                    _buildGuaranteeField(theme),
                  ],
                );
              }
              // Se tiver espaço (tablet/web), coloca lado a lado
              else {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _buildPriceField(theme)),
                    const SizedBox(width: 24),
                    Expanded(child: _buildGuaranteeField(theme)),
                  ],
                );
              }
            },
          ),

          const SizedBox(height: 48),

          // Rodapé (Botões)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              OutlinedButton.icon(
                onPressed: widget.onBack,
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
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppPalette.orange500),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: widget.onContinue,
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.onContinue != null
                      ? AppPalette.orange500
                      : Colors.grey[300],
                  foregroundColor: widget.onContinue != null
                      ? AppPalette.orange500
                      : Colors.grey[600],
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Text(
                      "Continuar",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppPalette.surfaceText,
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(
                      Icons.arrow_forward,
                      size: 16,
                      color: AppPalette.surfaceText,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Widget Botão de Seleção (Tipo de Cobrança)
  Widget _buildTypeOption({
    required String label,
    required ProductBillingType value,
    required ThemeData theme,
  }) {
    final isSelected = widget.billingType == value;

    return Expanded(
      child: InkWell(
        onTap: () => widget.onBillingTypeChanged(value),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          height: 60,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            // Fundo Laranja Claro se selecionado, senão cinza claro se inativo?
            // Na imagem: "Assinatura" está laranja claro (selecionado?), "Valor Único" está laranja claro também?
            // Parece que ambos são botões com fundo bege/laranja claro. O selecionado tem texto em negrito.
            color: isSelected ? const Color(0xFFFFF3E0) : theme.cardColor,
            // Ajuste: Selecionado com cor, outro transparente?
            // Vamos seguir um padrão comum: Selecionado = Fundo Laranja Claro + Borda Laranja. Não selecionado = Fundo Cinza Claro.
            borderRadius: BorderRadius.circular(8),
            border: isSelected
                ? Border.all(color: AppPalette.orange500, width: 1)
                : null,
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected
                  ? Colors.black
                  : theme.colorScheme.onSurface.withOpacity(0.7),
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }

  // Widget Campo de Preço
  Widget _buildPriceField(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Preço do Produto *",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _priceController,
          onChanged: widget.onPriceChanged,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: "R\$ 0,00",
            hintStyle: TextStyle(
              color: theme.colorScheme.onSurface.withOpacity(0.4),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppPalette.neutral300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppPalette.neutral300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppPalette.orange500),
            ),
          ),
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          "O valor precisa ser maior ou igual a R\$ 9,00",
          style: TextStyle(
            fontSize: 11,
            color: theme.colorScheme.onSurface.withOpacity(0.5),
          ),
        ),
      ],
    );
  }

  // Widget Campo de Garantia
  Widget _buildGuaranteeField(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Garantia (dias) *",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _guaranteeController,
          onChanged: widget.onGuaranteeChanged,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppPalette.neutral300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppPalette.neutral300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppPalette.orange500),
            ),
          ),
          style: const TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 4),
        Text(
          "Período em que o cliente pode solicitar reembolso",
          style: TextStyle(
            fontSize: 11,
            color: theme.colorScheme.onSurface.withOpacity(0.5),
          ),
        ),
      ],
    );
  }
}

class _StepConfirmationCard extends StatelessWidget {
  final ProductType? productType;
  final ProductCategory? category;
  final String title;
  final String description;
  final String billingType;
  final double price;
  final int guaranteeDays;
  final String website;
  final VoidCallback onBack;
  final VoidCallback onConfirm;
  final XFile? pickedImage;
  final bool isLoading;

  const _StepConfirmationCard({
    required this.productType,
    required this.category,
    required this.title,
    required this.description,
    required this.billingType,
    required this.price,
    required this.guaranteeDays,
    required this.website,
    required this.onBack,
    required this.onConfirm,
    required this.pickedImage,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
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
      child: Column(
        children: [
          // Header da Etapa
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF3E0),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Text(
              "Etapa 5",
              style: TextStyle(
                color: AppPalette.orange500,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            "Confirmação",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Confirme os dados que você preencheu",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 40),

          // --- CARD DE RESUMO ---
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              border: Border.all(color: AppPalette.neutral300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Topo: Imagem, Título e Link
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: theme.scaffoldBackgroundColor,
                        borderRadius: BorderRadius.circular(8),
                        image: pickedImage != null
                            ? DecorationImage(
                                image: kIsWeb
                                    ? NetworkImage(pickedImage!.path)
                                    : FileImage(File(pickedImage!.path))
                                          as ImageProvider,
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: pickedImage == null
                          ? const Center(
                              child: Icon(
                                Icons.inventory_2_outlined, // Ícone de caixa
                                color: AppPalette.orange500,
                                size: 32,
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(width: 16),
                    // Título e Preço
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF3E0),
                              // Laranja bem claro
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Text(
                              "Template", // Exemplo estático ou categoria
                              style: TextStyle(
                                color: Color(0xFF8D6E63),
                                // Marrom/Laranja escuro
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            title,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "R\$ $price",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                              color: AppPalette.orange500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Link Página de Vendas (se houver tela grande)
                  ],
                ),
                if (website.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: () async{
                        await launchUrl(
                          Uri.parse(
                            website.contains('http')
                                ? website
                                : 'https://$website',
                          ),
                          mode: LaunchMode.externalApplication,
                        );
                      }, // Abrir link
                      icon: const Icon(
                        Icons.open_in_new,
                        size: 14,
                        color: AppPalette.orange500,
                      ),
                      label: const Text(
                        "Visitar página de vendas",
                        style: TextStyle(
                          color: AppPalette.orange500,
                          fontSize: 12,
                        ),
                      ),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 24),

                // Grid de Informações (3 boxes)
                LayoutBuilder(
                  builder: (context, constraints) {
                    // Se tela pequena, wrap ou column. Se grande, row.
                    return Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      children: [
                        _buildInfoBox(
                          "Tipo:",
                          "Produto Digital",
                          constraints.maxWidth,
                        ),
                        // Fixo ou dinâmico
                        _buildInfoBox(
                          "Garantia",
                          "$guaranteeDays dias",
                          constraints.maxWidth,
                        ),
                        _buildInfoBox(
                          "Cobrança",
                          billingType,
                          constraints.maxWidth,
                        ),
                      ],
                    );
                  },
                ),

                const SizedBox(height: 24),

                // Descrição Box
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppPalette.orange500.withOpacity(0.5),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Descrição",
                        style: TextStyle(
                          fontSize: 12,
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        description,
                        style: TextStyle(
                          fontSize: 14,
                          color: theme.colorScheme.onSurface,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 48),

          // Rodapé (Botões)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              OutlinedButton.icon(
                onPressed: onBack,
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
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppPalette.orange500),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: onConfirm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppPalette.orange500,
                  foregroundColor: Colors.white,
                  // Botão final laranja e texto branco
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Text(
                            "Continuar",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppPalette.surfaceText,
                            ),
                          ),
                          SizedBox(width: 8),
                          Icon(
                            Icons.arrow_forward,
                            size: 16,
                            color: AppPalette.surfaceText,
                          ),
                        ],
                      ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoBox(String label, String value, double parentWidth) {
    // Tenta dividir em 3 colunas se possível, senão ocupa mais espaço
    double width = (parentWidth - 80) / 3;
    if (width < 100) width = 140; // Mínimo para mobile

    return Container(
      width: width,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppPalette.orange500.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _ProductStepData {
  final IconData icon;
  final String title;
  _StepState state;

  _ProductStepData(this.icon, this.title, this.state);
}

enum _StepState { completed, current, locked }
