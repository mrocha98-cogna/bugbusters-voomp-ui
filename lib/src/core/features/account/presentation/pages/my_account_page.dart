import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:voomp_sellers_rebranding/src/core/common/widgets/max_width_container.dart';
import 'package:voomp_sellers_rebranding/src/core/database/database_helper.dart';
import 'package:voomp_sellers_rebranding/src/core/features/model/user.dart';
import 'package:voomp_sellers_rebranding/src/core/theme/app_colors.dart';

import '../../../settings/data/repositories/settings_repository.dart';

class MyAccountPage extends StatefulWidget {
  const MyAccountPage({super.key});

  @override
  State<MyAccountPage> createState() => _MyAccountPageState();
}

class _MyAccountPageState extends State<MyAccountPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedTabIndex = 0;
  late bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUser();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _selectedTabIndex = _tabController.index;
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadUser() async {
    final token = await DatabaseHelper.instance.getAccessToken();

    if (token == null) {
      if (mounted) context.go('/login');
      return;
    }

    final decodedToken = JwtDecoder.decode(token);

    var extra = User(
      id: decodedToken['sub'] != null ? decodedToken['sub'].toString() : '',
      name: decodedToken['name'] ?? '',
      email: decodedToken['email'] ?? '',
      password: '',
      cpf: decodedToken['cpf'] ?? '',
      phone: decodedToken['phoneNumber'] ?? decodedToken['phone'] ?? '',
      userOnboardingId: decodedToken['onboardingId'] ?? '',
    );

    if (mounted) {
      setState(() {
        // _user = extra;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: AppPalette.orange500),
        ),
      );
    }

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
                if(context.canPop())
                  TextButton.icon(
                  onPressed: () => context.pop(),
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
                const SizedBox(height: 16),

                // 2. Título Principal
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    "Minha Conta",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // 3. Abas Personalizadas
                _CustomTabBar(
                  selectedIndex: _selectedTabIndex,
                  onTap: (index) => _tabController.animateTo(index),
                ),
                const SizedBox(height: 24),
                // ...
                if (_selectedTabIndex == 0)
                  const _PersonalDataTabContent()
                else if (_selectedTabIndex == 1)
                  const _CompanyDataTabContent()
                else if (_selectedTabIndex == 2) // <--- ADICIONE ISSO
                  const _SupportDataTabContent()
                else if (_selectedTabIndex == 3) // <--- ADICIONE ISSO
                  const _BankingDataTabContent()
                else
                  Center(
                    child: Text(
                      "Conteúdo da aba ${_selectedTabIndex + 1}",
                      style: TextStyle(color: theme.colorScheme.onSurface),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PersonalDataTabContent extends StatelessWidget {
  const _PersonalDataTabContent();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Card de Verificação
        const _IdentityVerificationCard(),
        const SizedBox(height: 24),

        // Card Dados Pessoais
        const _PersonalDataFormCard(),
        const SizedBox(height: 24),

        // Card Endereço
        const _AddressFormCard(),
        const SizedBox(height: 24),

        // Card Segurança
        const _SecurityCard(),
        const SizedBox(height: 32),

        // Botão Salvar Global
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: AppPalette.orange500,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              "Salvar",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppPalette.surfaceText,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _CustomTabBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTap;

  const _CustomTabBar({required this.selectedIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    // Definimos o breakpoint para mobile
    final isMobile = MediaQuery.of(context).size.width < 700;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Lista de abas para facilitar a geração
    final tabs = [
      {'index': 0, 'icon': Icons.person, 'label': "Dados Pessoais"},
      {'index': 1, 'icon': Icons.business, 'label': "Dados da Empresa"},
      {'index': 2, 'icon': Icons.support_agent, 'label': "Dados de Suporte"},
      {'index': 3, 'icon': Icons.attach_money, 'label': "Dados Bancários"},
    ];

    if (isMobile) {
      // --- LAYOUT MOBILE (Wrap / Grid) ---
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Wrap(
          spacing: 8, // Espaço horizontal entre os botões
          runSpacing: 12, // Espaço vertical entre as linhas
          alignment: WrapAlignment.center, // Centraliza os botões
          children: tabs.map((tab) {
            final index = tab['index'] as int;
            final isSelected = selectedIndex == index;

            return InkWell(
              onTap: () => onTap(index),
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  // Fundo: Laranja claro se selecionado, Cinza bem claro se não (ou transparente no dark)
                  color: isSelected
                      ? AppPalette.orange500.withOpacity(0.1)
                      : (isDark ? Colors.white10 : Colors.grey[100]),

                  // Borda: Laranja se selecionado, transparente se não
                  border: Border.all(
                      color: isSelected ? AppPalette.orange500 : Colors.transparent,
                      width: 1.5
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min, // Ocupa apenas o necessário
                  children: [
                    Icon(
                      tab['icon'] as IconData,
                      size: 18,
                      color: isSelected
                          ? AppPalette.orange500
                          : (isDark ? Colors.white70 : Colors.grey[600]),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      tab['label'] as String,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected
                            ? AppPalette.orange500
                            : (isDark ? Colors.white70 : Colors.grey[600]),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      );
    }

    // --- LAYOUT DESKTOP (Horizontal com linha inferior) ---
    else {
      return Row(
        children: [
          _buildDesktopTabItem(0, Icons.person, "Dados Pessoais"),
          const SizedBox(width: 16),
          _buildDesktopTabItem(1, Icons.business, "Dados da Empresa"),
          const SizedBox(width: 16),
          _buildDesktopTabItem(2, Icons.support_agent, "Dados de Suporte"),
          const SizedBox(width: 16),
          _buildDesktopTabItem(3, Icons.attach_money, "Dados Bancários"),
        ],
      );
    }
  }

  // Widget auxiliar exclusivo para o estilo Desktop (Linha inferior)
  Widget _buildDesktopTabItem(int index, IconData icon, String label) {
    final isSelected = selectedIndex == index;
    return InkWell(
      onTap: () => onTap(index),
      borderRadius: BorderRadius.circular(4),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          border: isSelected
              ? const Border(bottom: BorderSide(color: AppPalette.orange500, width: 2))
              : null,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? AppPalette.orange500 : Colors.grey,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? AppPalette.orange500 : Colors.grey,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _IdentityVerificationCard extends StatefulWidget {
  const _IdentityVerificationCard();

  @override
  State<_IdentityVerificationCard> createState() =>
      _IdentityVerificationCardState();
}

class _IdentityVerificationCardState extends State<_IdentityVerificationCard> {
  late bool _isVerified = false;

  @override
  void initState() {
    super.initState();
    loadVerificationStatus();
  }

  Future<void> loadVerificationStatus() async {
    final SettingsRepository _settingsRepository = SettingsRepository();
    var result = await _settingsRepository.getUserPendingSteps();
    setState(() {
      _isVerified = result.hasIdentityValidated;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // A UI agora é construída com base no estado _isVerified
    return _isVerified
        ? _buildVerifiedState(theme, isDark) // Mostra o card de "Concluído"
        : _buildPendingState(theme, isDark);  // Mostra o card "Pendente"
  }

  // --- WIDGET PARA O ESTADO PENDENTE (O QUE JÁ EXISTE) ---
  Widget _buildPendingState(ThemeData theme, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Verificação
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppPalette.orange500.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.shield_outlined, color: Colors.black87),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Verificação de identidade",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        // Chip "Pendente"
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF3E0),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppPalette.orange500.withOpacity(0.3),
                            ),
                          ),
                          child: const Row(
                            children: [
                              Icon(
                                Icons.access_time,
                                size: 12,
                                color: AppPalette.orange500,
                              ),
                              SizedBox(width: 4),
                              Text(
                                "Pendente",
                                style: TextStyle(
                                  fontSize: 10,
                                  color: AppPalette.orange500,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Para começar a vender e receber seus pagamentos com segurança, você precisa verificar sua identidade.",
                      style: TextStyle(
                        fontSize: 12,
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Banner de Ação
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF3E0).withOpacity(isDark ? 0.1 : 1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isSmall = constraints.maxWidth < 600;

                final content = [
                  Expanded(
                    flex: isSmall ? 0 : 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.check_circle_outline,
                              color: AppPalette.orange500,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              "Complete sua verificação de identidade agora",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.only(left: 28.0),
                          child: Text(
                            "É rápido, seguro e necessário para desbloquear todas as funcionalidades de vendedor",
                            style: TextStyle(
                              fontSize: 12,
                              color: theme.colorScheme.onSurface.withOpacity(
                                0.8,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isSmall) const SizedBox(height: 16),
                  if (!isSmall) const SizedBox(width: 16),

                  SizedBox(
                    width: isSmall ? double.infinity : null,
                    child: ElevatedButton(
                      onPressed: () async{
                        final SettingsRepository _settingsRepository = SettingsRepository(); // Instancia o repositório
                        var result = await _settingsRepository.patchUserPendingSteps();

                        if(result){
                          setState(() {
                            _isVerified = true;
                          });
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppPalette.orange500,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        "Verificar Identidade",
                        style: TextStyle(color: AppPalette.surfaceText),
                      ),
                    ),
                  ),
                ];

                if (isSmall) return Column(children: content);
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: content,
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                Icons.timer_outlined,
                size: 14,
                color: theme.colorScheme.onSurface.withOpacity(0.5),
              ),
              const SizedBox(width: 4),
              Text(
                "O processo leva menos de 5 min",
                style: TextStyle(
                  fontSize: 11,
                  color: theme.colorScheme.onSurface.withOpacity(0.5),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVerifiedState(ThemeData theme, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Ícone verde
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.verified_user_outlined, // Ícone de verificado
              color: Colors.green,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          // Textos
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Verificação de identidade",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Identidade verificada com sucesso!",
                  style: TextStyle(
                    fontSize: 12,
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Chip "Concluído"
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.check_circle,
                  size: 14,
                  color: Colors.green,
                ),
                SizedBox(width: 6),
                Text(
                  "Concluído",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PersonalDataFormCard extends StatelessWidget {
  const _PersonalDataFormCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDesktop = MediaQuery.of(context).size.width > 900;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Dados Pessoais",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 24),

          // Layout Flexível: Form na Esquerda, Foto na Direita (Desktop) ou Empilhado (Mobile)
          LayoutBuilder(
            builder: (context, constraints) {
              if (isDesktop) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 2, child: _buildFormFields(context)),
                    const SizedBox(width: 40),
                    Expanded(flex: 1, child: _buildPhotoUpload(context)),
                  ],
                );
              } else {
                return Column(
                  children: [
                    _buildPhotoUpload(context),
                    // Foto primeiro no mobile? Ou depois? Segui o layout que sugere lado a lado, mas no mobile foto em cima é comum.
                    const SizedBox(height: 24),
                    _buildFormFields(context),
                  ],
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFormFields(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _CustomTextField(
                label: "Nome Completo",
                hint: "Descreva sua mensagem",
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _CustomTextField(
                label: "Telefone",
                hint: "(31) 00000-0000",
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _CustomTextField(label: "RG", hint: "0000000"),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _CustomTextField(
                label: "E-mail",
                hint: "email@email.com",
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _CustomTextField(label: "CPF", hint: "123.123.123-12"),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPhotoUpload(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Foto de Perfil",
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 140,
          width: double.infinity,
          decoration: BoxDecoration(
            color: isDark ? Colors.white10 : const Color(0xFFFAFAFA),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Colors.grey[300]!,
              style: BorderStyle.solid,
            ), // Tracejado não é nativo simples, usando sólido cinza
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppPalette.orange500.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.add_photo_alternate_outlined,
                  color: AppPalette.orange500,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                "Clique ou arraste uma imagem",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "PNG, JPG",
                style: TextStyle(
                  fontSize: 10,
                  color: theme.colorScheme.onSurface.withOpacity(0.5),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _AddressFormCard extends StatelessWidget {
  const _AddressFormCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Seu Endereço",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 24),

          Row(
            children: [
              const Expanded(
                flex: 1,
                child: _CustomTextField(label: "CEP", hint: "Digito o CEP"),
              ),
              const SizedBox(width: 16),
              const Expanded(
                flex: 2,
                child: _CustomTextField(label: "Endereço", hint: "Endereço"),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Expanded(
                child: _CustomTextField(
                  label: "Número",
                  hint: "123.123.123-12",
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: _CustomTextField(
                  label: "Bairro",
                  hint: "123.123.123-12",
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Expanded(
                child: _CustomTextField(
                  label: "Estado",
                  hint: "email@email.com",
                ),
              ),
              // Label do layout parece erro de copy, mantive
              const SizedBox(width: 16),
              const Expanded(
                child: _CustomTextField(label: "Cidade", hint: "0000000"),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SecurityCard extends StatelessWidget {
  const _SecurityCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Segurança",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: 150,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0D1B2A), // Azul escuro
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text("Alterar Senha"),
            ),
          ),
        ],
      ),
    );
  }
}

class _CustomTextField extends StatelessWidget {
  final String label;
  final String hint;
  final String? helperText;

  const _CustomTextField({
    required this.label,
    required this.hint,
    this.helperText,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface.withOpacity(0.8),
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          style: TextStyle(fontSize: 13, color: theme.colorScheme.onSurface),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: theme.colorScheme.onSurface.withOpacity(0.3),
            ),
            filled: true,
            fillColor: isDark ? Colors.white10 : Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: BorderSide(
                color: isDark ? Colors.white24 : Colors.grey[300]!,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: const BorderSide(color: AppPalette.orange500),
            ),
            helperText: helperText,
            helperStyle: TextStyle(
              fontSize: 10,
              color: theme.colorScheme.onSurface.withOpacity(0.4),
            ),
          ),
        ),
      ],
    );
  }
}

class _CompanyDataTabContent extends StatelessWidget {
  const _CompanyDataTabContent();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Card Dados da Empresa
        const _CompanyInfoFormCard(),
        const SizedBox(height: 24),

        // Card Endereço da Empresa
        const _CompanyAddressFormCard(),
        const SizedBox(height: 32),

        // Botão Salvar Global
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: AppPalette.orange500,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              "Salvar",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppPalette.surfaceText,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _CompanyInfoFormCard extends StatelessWidget {
  const _CompanyInfoFormCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDesktop = MediaQuery.of(context).size.width > 900;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Dados da Empresa",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 24),

          LayoutBuilder(
            builder: (context, constraints) {
              if (isDesktop) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 2, child: _buildFormFields(context)),
                    const SizedBox(width: 40),
                    Expanded(flex: 1, child: _buildContractUpload(context)),
                  ],
                );
              } else {
                return Column(
                  children: [
                    _buildFormFields(context),
                    const SizedBox(height: 24),
                    _buildContractUpload(context),
                  ],
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFormFields(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _CustomTextField(
                label: "Razão Social",
                hint: "Digite a razão social",
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _CustomTextField(
                label: "Nome Fantasia",
                hint: "Digite o nome fantasia da empresa",
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _CustomTextField(label: "CNPJ", hint: "0000000"),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _CustomTextField(
                label: "Telefone",
                hint: "(31) 00000-0000",
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildContractUpload(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Contrato Social",
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          "Insira aqui o Contrato Social para validação da formalização da sua empresa",
          style: TextStyle(
            fontSize: 10,
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          height: 140,
          width: double.infinity,
          decoration: BoxDecoration(
            color: isDark ? Colors.white10 : const Color(0xFFFAFAFA),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Colors.grey[300]!,
              style: BorderStyle.solid,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppPalette.orange500.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.attach_file,
                  color: AppPalette.orange500,
                ), // Ícone de clipe ou documento
              ),
              const SizedBox(height: 12),
              Text(
                "Clique ou arraste seu Contrato\nSocial",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "PDF",
                style: TextStyle(
                  fontSize: 10,
                  color: theme.colorScheme.onSurface.withOpacity(0.5),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CompanyAddressFormCard extends StatelessWidget {
  const _CompanyAddressFormCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Endereço da Empresa",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 24),

          Row(
            children: [
              const Expanded(
                flex: 1,
                child: _CustomTextField(
                  label: "CEP da Empresa",
                  hint: "Digito o CEP",
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                flex: 2,
                child: _CustomTextField(label: "Endereço", hint: "Endereço"),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Expanded(
                child: _CustomTextField(
                  label: "Número",
                  hint: "123.123.123-12",
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: _CustomTextField(
                  label: "Bairro",
                  hint: "123.123.123-12",
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Expanded(
                child: _CustomTextField(
                  label: "Estado",
                  hint: "email@email.com",
                ),
              ),
              // Mantido placeholder do design
              const SizedBox(width: 16),
              const Expanded(
                child: _CustomTextField(label: "Cidade", hint: "0000000"),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SupportDataTabContent extends StatelessWidget {
  const _SupportDataTabContent();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Card Dados de Suporte
        const _SupportInfoFormCard(),
        const SizedBox(height: 32),

        // Botão Salvar Global
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: AppPalette.orange500,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              "Salvar",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppPalette.surfaceText,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SupportInfoFormCard extends StatelessWidget {
  const _SupportInfoFormCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Dados do Suporte",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 24),

          // Linha com os dois campos
          Row(
            children: [
              Expanded(
                child: _CustomTextField(
                  label: "E-mail de suporte",
                  hint: "Digite o e-mail",
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _CustomTextField(
                  label: "Telefone de suporte",
                  hint: "(31) 99999-9999",
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BankingDataTabContent extends StatefulWidget {
  const _BankingDataTabContent();

  @override
  State<_BankingDataTabContent> createState() => _BankingDataTabContentState();
}

class _BankingDataTabContentState extends State<_BankingDataTabContent> {
  String? _selectedMethod;
  bool _isChangingMethod = false; // <--- NOVA VARIÁVEL DE ESTADO

  void _selectMethod(String method) {
    setState(() {
      _selectedMethod = method;
      // Quando seleciona um novo, o aviso some (se quiser manter até salvar, remova essa linha)
      _isChangingMethod = false;
    });
  }

  void _resetSelection() {
    setState(() {
      _selectedMethod = null;
      _isChangingMethod = true; // <--- ATIVA O MODO DE ALTERAÇÃO (MOSTRA BANNER)
    });
  }

  // Caso o usuário cancele a edição do formulário, voltamos para a seleção
  // mas aqui decidimos se mostramos o banner ou não. Geralmente cancelar volta ao estado inicial.
  void _cancelForm() {
    setState(() {
      _selectedMethod = null;
      // Se cancelar o form, mantemos o aviso ou resetamos?
      // Pela lógica de "voltar para a primeira exibição", talvez sem banner.
      // Mas se "Alterar Método" foi clicado antes, faz sentido manter o banner na seleção.
      // Vamos assumir que cancelar volta para a seleção com o banner ainda visível.
      _isChangingMethod = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDesktop = MediaQuery.of(context).size.width > 900;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header com Botão "Alterar Método" se algo estiver selecionado
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Dados de Recebimento",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              if (_selectedMethod != null)
                OutlinedButton(
                  onPressed: _resetSelection,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppPalette.orange500),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                  ),
                  child: const Text(
                    "Alterar Método",
                    style: TextStyle(
                      color: AppPalette.orange500,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 24),

          // LÓGICA DE EXIBIÇÃO
          if (_selectedMethod == null)
            _buildSelectionView(isDesktop, theme) // Passando theme
          else if (_selectedMethod == 'pix')
            _buildPixForm(theme)
          else
            _buildBankForm(theme),
        ],
      ),
    );
  }

  Widget _buildSelectionView(bool isDesktop, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        // --- NOVO BANNER DE ALERTA ---
        if (_isChangingMethod) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(bottom: 24),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF9C4), // Amarelo claro
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              children: [
                const Icon(Icons.warning_rounded, size: 20, color: Colors.black87),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    "Ao alterar o método de recebimento, seus dados atuais serão substituídos.",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.black87.withOpacity(0.8),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
        // -----------------------------

        LayoutBuilder(
          builder: (context, constraints) {
            if (isDesktop) {
              return Row(
                children: [
                  Expanded(
                    child: _PaymentMethodCard(
                      icon: Icons.smartphone,
                      title: "Receber Via PIX",
                      description:
                      "Receba seus pagamentos instantaneamente com sua chave PIX",
                      onTap: () => _selectMethod('pix'),
                    ),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: _PaymentMethodCard(
                      icon: Icons.account_balance,
                      title: "Receber Via Conta Bancária",
                      description:
                      "Receba seus pagamentos via transferência bancária tradicional (TED/DOC)",
                      onTap: () => _selectMethod('bank'),
                    ),
                  ),
                ],
              );
            } else {
              return Column(
                children: [
                  _PaymentMethodCard(
                    icon: Icons.smartphone,
                    title: "Receber Via PIX",
                    description:
                    "Receba seus pagamentos instantaneamente com sua chave PIX",
                    onTap: () => _selectMethod('pix'),
                  ),
                  const SizedBox(height: 16),
                  _PaymentMethodCard(
                    icon: Icons.account_balance,
                    title: "Receber Via Conta Bancária",
                    description:
                    "Receba seus pagamentos via transferência bancária tradicional (TED/DOC)",
                    onTap: () => _selectMethod('bank'),
                  ),
                ],
              );
            }
          },
        ),
      ],
    );
  }

  Widget _buildPixForm(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Card Resumo do Método Selecionado
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[200]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppPalette.orange500.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.smartphone, size: 24, color: Colors.black87),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Receber Via PIX",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: theme.colorScheme.onSurface),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Receba seus pagamentos instantaneamente com sua chave PIX",
                      style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurface.withOpacity(0.6)),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Campos do Formulário
        LayoutBuilder(builder: (context, constraints) {
          final isSmall = constraints.maxWidth < 800;

          if(isSmall) {
            return Column(
              children: const [
                _CustomTextField(label: "Nome Completo", hint: "Digite seu nome"),
                SizedBox(height: 16),
                _CustomDropdownField(label: "Tipo de Chave Pix", hint: "Selecione o tipo"),
                SizedBox(height: 16),
                _CustomTextField(label: "Chave Pix", hint: "Digite sua chave"),
              ],
            );
          }

          return Row(
            children: const [
              Expanded(child: _CustomTextField(label: "Nome Completo", hint: "Digite seu nome")),
              SizedBox(width: 16),
              Expanded(child: _CustomDropdownField(label: "Tipo de Chave Pix", hint: "Selecione o tipo")),
              SizedBox(width: 16),
              Expanded(child: _CustomTextField(label: "Chave Pix", hint: "Digite sua chave")),
            ],
          );
        }),

        const SizedBox(height: 32),

        // Botões de Ação
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton(
              onPressed: _cancelForm, // Voltar para seleção
              child: const Text(
                "Cancelar",
                style: TextStyle(color: AppPalette.orange500, fontWeight: FontWeight.bold),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                // Lógica de salvar
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppPalette.orange500,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              ),
              child: const Text("Salvar Chave Pix", style: TextStyle(fontWeight: FontWeight.bold, color: AppPalette.surfaceText)),
            ),
          ],
        )
      ],
    );
  }

  Widget _buildBankForm(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Card Resumo
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[200]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppPalette.orange500.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.account_balance,
                    size: 24, color: Colors.black87),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Receber Via Conta Bancária",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: theme.colorScheme.onSurface),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Receba seus pagamentos via transferência bancária tradicional (TED/DOC)",
                      style: TextStyle(
                          fontSize: 12,
                          color: theme.colorScheme.onSurface.withOpacity(0.6)),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Campos do Formulário
        LayoutBuilder(builder: (context, constraints) {
          final isSmall = constraints.maxWidth < 800;

          if (isSmall) {
            return Column(
              children: const [
                _CustomTextField(
                    label: "Nome Completo", hint: "Digite seu nome"),
                SizedBox(height: 16),
                _CustomTextField(
                    label: "CPF/CNPJ", hint: "123.123.123-12"),
                SizedBox(height: 16),
                _CustomDropdownField(
                    label: "Banco", hint: "Selecione seu banco"),
                SizedBox(height: 16),
                _CustomDropdownField(
                    label: "Tipo de Conta", hint: "Selecione o tipo de conta"),
                SizedBox(height: 16),
                _CustomTextField(
                    label: "Agência", hint: "Digite o número da agência"),
                SizedBox(height: 16),
                _CustomTextField(
                    label: "Conta", hint: "Digite o número da conta"),
                SizedBox(height: 16),
                _CustomTextField(label: "Dígito", hint: "Número"),
              ],
            );
          }

          return Column(
            children: [
              Row(
                children: const [
                  Expanded(
                    child: _CustomTextField(
                        label: "Nome Completo", hint: "Digite seu nome"),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: _CustomTextField(
                        label: "CPF/CNPJ", hint: "123.123.123-12"),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: const [
                  Expanded(
                    child: _CustomDropdownField(
                        label: "Banco", hint: "Selecione seu banco"),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: _CustomDropdownField(
                        label: "Tipo de Conta",
                        hint: "Selecione o tipo de conta"),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: const [
                  Expanded(
                    flex: 2,
                    child: _CustomTextField(
                        label: "Agência", hint: "Digite o número da agência"),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    flex: 3,
                    child: _CustomTextField(
                        label: "Conta", hint: "Digite o número da conta"),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    flex: 1,
                    child: _CustomTextField(label: "Dígito", hint: "Número"),
                  ),
                ],
              ),
            ],
          );
        }),

        const SizedBox(height: 32),

        // Botões de Ação
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton(
              onPressed: _cancelForm, // Volta para seleção
              child: const Text(
                "Cancelar",
                style: TextStyle(
                    color: AppPalette.orange500, fontWeight: FontWeight.bold),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                // Lógica de salvar
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppPalette.orange500,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                padding:
                const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              ),
              child: const Text("Salvar Dados",
                  style: TextStyle(fontWeight: FontWeight.bold, color: AppPalette.surfaceText)),
            ),
          ],
        )
      ],
    );
  }
}

class _CustomDropdownField extends StatelessWidget {
  final String label;
  final String hint;

  const _CustomDropdownField({required this.label, required this.hint});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface.withOpacity(0.8),
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: isDark ? Colors.white10 : Colors.white,
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(6),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              hint: Text(
                hint,
                style: TextStyle(
                  fontSize: 13,
                  color: theme.colorScheme.onSurface.withOpacity(0.3),
                ),
              ),
              items: const [],
              onChanged: (_) {},
            ),
          ),
        ),
      ],
    );
  }
}

class _PaymentMethodCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onTap; // Adicionado callback

  const _PaymentMethodCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey[200]!.withOpacity(isDark ? 0.1 : 1),
        ),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Ícone Grande com Fundo
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppPalette.orange500.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 48, color: Colors.black87),
          ),
          const SizedBox(height: 24),

          // Título
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),

          // Descrição
          Text(
            description,
            style: TextStyle(
              fontSize: 13,
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),

          // Link de Ação
          InkWell(
            onTap: onTap, // Usa o callback passado
            borderRadius: BorderRadius.circular(4),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Text(
                    "Selecionar",
                    style: TextStyle(
                      color: AppPalette.orange500,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(width: 8),
                  Icon(
                    Icons.arrow_forward,
                    size: 16,
                    color: AppPalette.orange500,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
