import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:voomp_sellers_rebranding/src/core/theme/app_colors.dart';

class CreateProductPage extends StatefulWidget {
  const CreateProductPage({super.key});

  @override
  State<CreateProductPage> createState() => _CreateProductPageState();
}

class _CreateProductPageState extends State<CreateProductPage> {
  int _currentStep = 0;
  String? _selectedProductType;
  String? _selectedCategory;
  String _productTitle = '';
  String _productDescription = '';
  String _salesPage = '';

  // Lista de passos do header
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
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
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
          onCategorySelected: (category) => setState(() => _selectedCategory = category),
          onContinue: _selectedCategory != null ? _nextStep : null,
          onBack: _prevStep,
        );
      case 2:
        return _StepDetailsCard(
          initialTitle: _productTitle,
          initialDescription: _productDescription,
          initialSalesPage: _salesPage,
          onTitleChanged: (val) => setState(() => _productTitle = val),
          onDescriptionChanged: (val) => setState(() => _productDescription = val),
          onSalesPageChanged: (val) => setState(() => _salesPage = val),
          onContinue: (_productTitle.isNotEmpty && _productDescription.isNotEmpty)
              ? _nextStep
              : null,
          onBack: _prevStep,
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
    final double progressValue =
        currentStep / 5;

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
              separatorBuilder: (context, index) =>
                  _buildConnector(index <= currentStep, steps[index].state == _StepState.completed),
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
      color: isCompleted ? AppPalette.success500 : isActive ? AppPalette.orange500 : AppPalette.neutral300,
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

    if(step.state == _StepState.completed) {
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
              color: step.state == _StepState.completed ? Colors.transparent : AppPalette.orange400.withOpacity(0.5),
              borderRadius: BorderRadius.circular(8),
              border: step.state == _StepState.completed ? Border.all(color: AppPalette.success500, width: 2) : null,
            ),
            child: Icon(
              step.state == _StepState.completed ? Icons.check : step.icon,
              color: step.state == _StepState.completed ? AppPalette.success500 : isCurrent ? AppPalette.orange700 : AppPalette.white,
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
              color: step.state == _StepState.completed ? AppPalette.success500 : AppPalette.orange500.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }
}

class _StepCategoryCard extends StatefulWidget {
  final String? selectedCategory;
  final Function(String) onCategorySelected;
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
  final String? selectedType;
  final Function(String) onTypeSelected;
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

    // Opções de tipos de produto
    final options = [
      {
        "icon": Icons.laptop_mac,
        "label": "Curso Livre\n(Infoproduto)",
        "id": "course",
      },
      {"icon": Icons.menu_book, "label": "Ebook", "id": "ebook"},
      {"icon": Icons.school, "label": "Curso de Extensão", "id": "extension"},
      {
        "icon": Icons.workspace_premium,
        "label": "Pós-Graduação",
        "id": "postgrad",
      },
      {"icon": Icons.more_horiz, "label": "Outros", "id": "others"},
    ];

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
              // Simples lógica responsiva: se tela pequena (mobile), usa wrap ou grid de 2. Se grande, linha inteira.
              // Aqui usarei Wrap para fluidez
              return Wrap(
                spacing: 16,
                runSpacing: 16,
                alignment: WrapAlignment.center,
                children: options.map((opt) {
                  final isSelected = selectedType == opt['id'];
                  return InkWell(
                    onTap: () => onTypeSelected(opt['id'] as String),
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
                            opt['icon'] as IconData,
                            color: isSelected
                                ? AppPalette.orange500
                                : AppPalette.orange500,
                            // Ícone sempre laranja na imagem
                            size: 28,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            opt['label'] as String,
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
                  color: theme.colorScheme.primary,
                ),
                label: Text(
                  "Voltar",
                  style: TextStyle(
                    color: theme.colorScheme.primary,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: AppPalette.orange500),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
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
                    Text("Continuar", style: TextStyle(color: AppPalette.surfaceText),),
                    SizedBox(width: 8), // Espaçamento entre texto e ícone
                    Icon(Icons.arrow_forward, color: AppPalette.surfaceText, size: 16),
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

  // Lista completa de categorias baseada na imagem enviada
  final List<String> _allCategories = [
    "Apps & Software",
    "Marketplace",
    "Infoproduto",
    "Cursos",
    "Saúde e Esportes",
    "Finanças e Investimentos",
    "Relacionamentos",
    "Negócios e Carreira",
    "Espiritualidade",
    "Sexualidade",
    "Entretenimento",
    "Culinária e Gastronomia",
    "Idiomas",
    "Direito",
    "Literatura",
    "Casa e Construção",
    "Desenvolvimento Pessoal",
    "Moda e Beleza",
    "Animais e Plantas",
    "Educacional",
    "Hobbies",
    "Design",
    "Internet",
    "Ecologia e Meio Ambiente",
    "Música e Artes",
    "Tecnologia da Informação",
    "Empreendedorismo Digital",
    "Outros",
  ];

  List<String> _filteredCategories = [];

  @override
  void initState() {
    super.initState();
    _filteredCategories = _allCategories;
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
      _filteredCategories = _allCategories
          .where((cat) => cat.toLowerCase().contains(query))
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
              prefixIcon: const Icon(Icons.search, color: AppPalette.neutral500),
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
              color: isDark ? Colors.grey[900] : Colors.white, // Fundo branco/escuro para a lista
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppPalette.neutral100),
            ),
            child: Scrollbar(
              thumbVisibility: true,
              child: ListView.separated(
                padding: EdgeInsets.zero,
                itemCount: _filteredCategories.length,
                separatorBuilder: (context, index) => const Divider(
                  height: 1,
                  color: AppPalette.neutral200,
                ),
                itemBuilder: (context, index) {
                  final category = _filteredCategories[index];
                  final isSelected = widget.selectedCategory == category;

                  return Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => widget.onCategorySelected(category),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        child: Row(
                          children: [
                            // Custom Radio Button Visual
                            Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isSelected ? AppPalette.orange500 : AppPalette.neutral500,
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
                                category,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
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
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
                    Text("Continuar", style: TextStyle(fontWeight: FontWeight.bold)),
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
  final ValueChanged<String> onTitleChanged;
  final ValueChanged<String> onDescriptionChanged;
  final ValueChanged<String> onSalesPageChanged;
  final VoidCallback? onContinue;
  final VoidCallback? onBack;

  const _StepDetailsCard({
    required this.initialTitle,
    required this.initialDescription,
    required this.initialSalesPage,
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
          LayoutBuilder(builder: (context, constraints) {
            // Se tiver espaço suficiente (ex: tablet/web), coloca lado a lado
            // Caso contrário (mobile), empilha.
            if (constraints.maxWidth > 700) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 250,
                    child: _buildImageUploadArea(theme),
                  ),
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
          }),

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
                      borderRadius: BorderRadius.circular(8)),
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
                    Text("Continuar",
                        style: TextStyle(fontWeight: FontWeight.bold)),
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

  // Widget da Área de Upload
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
        // Container tracejado (Simulado com borda pontilhada customizada ou simples dashed effect)
        // Para simplificar sem pacote externo, usaremos um Container com borda cinza clara
        // Se quiser tracejado real, precisa do pacote `dotted_border` ou CustomPainter.
        // Vou usar um estilo clean que remete ao design.
        Container(
          height: 180,
          width: double.infinity,
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: AppPalette.neutral300,
              style: BorderStyle.solid, // Flutter nativo não tem dashed border fácil no Container
              width: 1,
            ),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                // Lógica de upload de imagem
              },
              borderRadius: BorderRadius.circular(8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppPalette.orange500.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.add_photo_alternate_outlined,
                        color: AppPalette.orange500, size: 32),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Clique ou arraste uma imagem",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "PNG, JPG",
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.colorScheme.onSurface.withOpacity(0.5),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
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
          decoration: _inputDecoration("Ex: Curso de Marketing Digital 2.0", theme),
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
              theme
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
              const Icon(Icons.auto_awesome, size: 12, color: AppPalette.neutral500),
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
        )
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

class _ProductStepData {
  final IconData icon;
  final String title;
  _StepState state;

  _ProductStepData(this.icon, this.title, this.state);
}

enum _StepState { completed, current, locked }