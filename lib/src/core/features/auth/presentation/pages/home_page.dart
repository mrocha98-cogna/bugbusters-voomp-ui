import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:voomp_sellers_rebranding/src/core/common/widgets/max_width_container.dart';
import 'package:voomp_sellers_rebranding/src/core/database/database_helper.dart';
import 'package:voomp_sellers_rebranding/src/core/features/account/presentation/pages/my_account_page.dart';
import 'package:voomp_sellers_rebranding/src/core/features/auth/services/auth_service.dart';
import 'package:voomp_sellers_rebranding/src/core/features/dashboard/presentation/pages/overview_dashboard_page.dart';
import 'package:voomp_sellers_rebranding/src/core/features/finance/presentation/pages/financial_statement_page.dart';
import 'package:voomp_sellers_rebranding/src/core/features/model/PendingSteps.dart';
import 'package:voomp_sellers_rebranding/src/core/features/model/user.dart';
import 'package:voomp_sellers_rebranding/src/core/features/products/presentation/pages/product_list_page.dart';
import 'package:voomp_sellers_rebranding/src/core/features/settings/data/repositories/settings_repository.dart';
import 'package:voomp_sellers_rebranding/src/core/theme/app_colors.dart';
import 'package:voomp_sellers_rebranding/src/core/theme/theme_controller.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  late User _user;
  bool _isLoading = true;
  late PendingSteps _userPendingSteps;
  late List<Widget> _pages = [];
  late List<_StepData> _steps = [];
  int _currentStepIndex = 1;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  void _advanceToNextStep() async {
    setState(() {
      _isLoading = true;
    });

    final SettingsRepository _settingsRepository = SettingsRepository();

    if (_currentStepIndex == 1) {
      context.push('/account/0').then((value) {
        _loadUser();
      });
    } else if (_currentStepIndex == 2) {
      var result = await _settingsRepository.postUserBusinessData();
      if (result) {
        _currentStepIndex++;
      }
    } else if (_currentStepIndex == 3) {
      context.push('/create-product').then((value) {
        _loadUser();
      });
    } else if (_currentStepIndex < _steps.length - 1) {
      _currentStepIndex++;
    }

    _loadUser();
  }

  Future<bool> _configureSteps(SettingsRepository _settingsRepository) async{
    var _pendingSteps = await _settingsRepository.getUserPendingSteps();

    var _identityStatus = _pendingSteps.hasIdentityValidated
        ? _StepState.completed
        : _StepState.current;

    if (_identityStatus == _StepState.current) {
      _currentStepIndex = 1;
    }

    var _businessStatus = _pendingSteps.hasBusinessData
        ? _StepState.completed
        : _pendingSteps.hasIdentityValidated
        ? _StepState.current
        : _StepState.locked;

    if (_businessStatus == _StepState.current) {
      _currentStepIndex = 2;
    }

    var _productStatus = _pendingSteps.hasProducts
        ? _StepState.completed
        : _pendingSteps.hasBusinessData
        ? _StepState.current
        : _StepState.locked;

    if (_productStatus == _StepState.current) {
      _currentStepIndex = 3;
    }

    var _salesStatus = _pendingSteps.hasSales
        ? _StepState.completed
        : _pendingSteps.hasProducts
        ? _StepState.current
        : _StepState.locked;

    if (_salesStatus == _StepState.current) {
      _currentStepIndex = 4;
    }

    if (_salesStatus == _StepState.completed) {
      _currentStepIndex = 5;
    }

    _steps = [
      _StepData(
        Icons.check,
        "Dados Pessoais",
        "Suas informações",
        _StepState.completed,
      ),
      _StepData(
        Icons.shield_outlined,
        "Identidade",
        "Validação",
        _identityStatus,
      ),
      _StepData(
        Icons.business_center_outlined,
        "Empresa",
        "Dados da Empresa",
        _businessStatus,
      ),
      _StepData(
        Icons.inventory_2_outlined,
        "Produto",
        "Primeiro Produto",
        _productStatus,
      ),
      _StepData(
        Icons.sell_outlined,
        "Primeira Venda",
        "Vender e Sacar",
        _salesStatus,
      ),
    ];

    return true;
  }

  void _loadUser() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }
    final token = await DatabaseHelper.instance.getAccessToken();

    if (token == null) {
      if (mounted) context.go('/login');
      return;
    }

    final decodedToken = JwtDecoder.decode(token);

    _user = User(
      id: decodedToken['sub'] != null ? decodedToken['sub'].toString() : '',
      name: decodedToken['name'] ?? '',
      email: decodedToken['email'] ?? '',
      password: '',
      cpf: decodedToken['cpf'] ?? '',
      phone: decodedToken['phoneNumber'] ?? decodedToken['phone'] ?? '',
      userOnboardingId: decodedToken['onboardingId'] ?? '',
    );

    final SettingsRepository _settingsRepository = SettingsRepository();
    _userPendingSteps = await _settingsRepository.getUserPendingSteps();
    _userPendingSteps.hasWhatsappNotification = await _settingsRepository
        .getWhatsappUserStatus();

    var resultSteps = await _configureSteps(_settingsRepository);

    if (mounted && resultSteps) {
      _pages = [
        _userPendingSteps.hasSales
          ? OverviewDashboardPage()
          : DashboardContent(
          showWhatsappCard: !_userPendingSteps.hasWhatsappNotification,
          userName: _user.name,
          onBackButtonPressed: _loadUser,
          currentStepIndex: _currentStepIndex,
          advanceToNextStep: _advanceToNextStep,
          steps: _steps,
        ),
        const ProductListPage(),
        ProfileTab(userName: _user.name, email: _user.email),
        const FinancialStatementPage(),
        const MyAccountPage(tabIndex: 0),
      ];

      setState(() {
        _isLoading = false;
      });
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 900;
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: AppPalette.orange500),
        ),
      );
    }

    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isMobile)
              _SidebarMenu(
                selectedIndex: _selectedIndex,
                onItemSelected: _onItemTapped,
              ),

            // Área de Conteúdo
            Expanded(child: _pages[_selectedIndex]),
          ],
        ),
      ),
      floatingActionButton: isMobile
          ? FloatingActionButton(
              onPressed: () {
                _onItemTapped(2);
              },
              backgroundColor: AppPalette.orange500,
              shape: const CircleBorder(),
              child: const Icon(Icons.settings, color: Colors.white, size: 32),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: isMobile
          ? BottomNavigationBar(
              currentIndex: _selectedIndex,
              onTap: _onItemTapped,
              type: BottomNavigationBarType.fixed,
              // Importante para mais de 3 itens
              selectedItemColor: AppPalette.orange500,
              unselectedItemColor: Colors.grey,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home_outlined),
                  activeIcon: Icon(Icons.home),
                  label: 'Início',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.local_offer_outlined),
                  activeIcon: Icon(Icons.local_offer),
                  label: 'Produtos',
                ),
                BottomNavigationBarItem(
                  icon: SizedBox.shrink(), // Espaço para o FAB central
                  label: '',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.attach_money),
                  label: 'Financeiro',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person_outline),
                  activeIcon: Icon(Icons.person),
                  label: 'Conta',
                ),
              ],
            )
          : null,
    );
  }
}

class DashboardContent extends StatefulWidget {
  final VoidCallback onBackButtonPressed;
  final VoidCallback advanceToNextStep;
  final List<_StepData> steps;
  final int currentStepIndex;
  final bool showWhatsappCard;
  final String userName;

  const DashboardContent({
    super.key,
    required this.showWhatsappCard,
    required this.userName,
    required this.onBackButtonPressed,
    required this.advanceToNextStep,
    required this.currentStepIndex,
    required this.steps
  });

  @override
  State<DashboardContent> createState() => _DashboardContentState();
}

class _DashboardContentState extends State<DashboardContent> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 900;
    final padding = isDesktop ? 40.0 : 20.0;
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(padding, padding, padding, 100),
      child: MaxWidthContainer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Olá, ${widget.userName}",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              "Estamos muito felizes de te receber aqui. Te desejamos boas vendas!",
              style: TextStyle(
                color: theme.colorScheme.onBackground.withOpacity(0.6),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 32),
            if (widget.showWhatsappCard) const _WhatsAppNotificationCard(),
            const SizedBox(height: 24),
            OnboardingStepsCard(
              onBackButtonPressed: widget.onBackButtonPressed,
              steps: widget.steps,
              advanceToNextStep: widget.advanceToNextStep,
              currentStepIndex: widget.currentStepIndex,
            ),
            if (!isDesktop) ...[
              const SizedBox(height: 24),
              const _SalesCard(isMobile: true),
              const SizedBox(height: 24),
              const _CreditCardRefusals(),
            ] else ...[
              const SizedBox(height: 24),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Expanded(flex: 3, child: _SalesCard(isMobile: false)),
                  SizedBox(width: 24),
                  Expanded(flex: 2, child: _CreditCardRefusals()),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class ProfileTab extends StatelessWidget {
  final String userName;
  final String email;

  const ProfileTab({super.key, required this.userName, required this.email});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Usamos AnimatedBuilder para ouvir mudanças no ThemeController
    return AnimatedBuilder(
      animation: ThemeController.instance,
      builder: (context, child) {
        final isDark = ThemeController.instance.themeMode == ThemeMode.dark;

        return Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 600),
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const SizedBox(height: 40),
                CircleAvatar(
                  radius: 50,
                  backgroundColor: AppPalette.orange500.withOpacity(0.2),
                  child: Text(
                    userName.isNotEmpty
                        ? userName.substring(0, 2).toUpperCase()
                        : "AA",
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: AppPalette.orange500,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  userName,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onBackground,
                  ),
                ),
                Text(
                  email,
                  style: TextStyle(
                    color: theme.colorScheme.onBackground.withOpacity(0.6),
                  ),
                ),
                const SizedBox(height: 40),

                Container(
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
                      ListTile(
                        leading: Icon(
                          isDark ? Icons.dark_mode : Icons.light_mode,
                          color: AppPalette.orange500,
                        ),
                        title: Text(
                          "Modo Escuro",
                          style: TextStyle(color: theme.colorScheme.onSurface),
                        ),
                        trailing: Switch(
                          value: isDark,
                          activeColor: AppPalette.orange500,
                          onChanged: (value) {
                            ThemeController.instance.toggleTheme();
                          },
                        ),
                      ),
                      Divider(height: 1, color: theme.dividerColor),
                      ListTile(
                        leading: const Icon(Icons.logout, color: Colors.red),
                        title: const Text(
                          "Sair da conta",
                          style: TextStyle(color: Colors.red),
                        ),
                        onTap: () async {
                          await DatabaseHelper.instance.clearSession();
                          context.go('/login');
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class OnboardingStepsCard extends StatefulWidget {
  final VoidCallback onBackButtonPressed;
  final VoidCallback advanceToNextStep;
  final List<_StepData> steps;
  final int currentStepIndex;

  const OnboardingStepsCard({super.key, required this.onBackButtonPressed, required this.steps, required this.currentStepIndex, required this.advanceToNextStep});

  @override
  State<OnboardingStepsCard> createState() => _OnboardingStepsCardState();
}

class _OnboardingStepsCardState extends State<OnboardingStepsCard> {
  late List<_StepData> _steps;
  late int _currentStepIndex;

  @override
  void initState() {
    super.initState();

    _currentStepIndex = widget.currentStepIndex;
    _steps = widget.steps;
  }

  @override
  void didUpdateWidget(covariant OnboardingStepsCard oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.currentStepIndex != oldWidget.currentStepIndex) {
      setState(() {
        _currentStepIndex = widget.currentStepIndex;
      });
    }
    // Atualiza a lista de steps também, se ela mudar
    if (widget.steps != oldWidget.steps) {
      setState(() {
        _steps = widget.steps;
      });
    }
  }

  _StepState _getStepState(int index) {
    if (index < _currentStepIndex) return _StepState.completed;
    if (index == _currentStepIndex) return _StepState.current;
    return _StepState.locked;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progress = (widget.currentStepIndex) / (widget.steps.length);
    final progressPercentage = (progress * 100).clamp(0, 100).toInt();

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Complete seu cadastro",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                Text(
                  "$progressPercentage%", // Porcentagem dinâmica
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                    color: AppPalette.orange500,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: Text(
              "${widget.currentStepIndex} de ${widget.steps.length} etapas concluídas",
              // Texto dinâmico
              style: TextStyle(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress, // Valor dinâmico
                minHeight: 8,
                backgroundColor: const Color(0xFFE0E0E0),
                color: AppPalette.orange500,
              ),
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            height: 160,
            width: double.infinity,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: widget.steps.length,
              separatorBuilder: (context, index) =>
                  _buildConnector(index < widget.currentStepIndex),
              itemBuilder: (context, index) {
                final step = widget.steps[index];
                return _buildStepCard(
                  context,
                  step.icon,
                  step.title,
                  step.subtitle,
                  _getStepState(index),
                  // Usa a função para obter o estado dinâmico
                  index == widget.currentStepIndex,
                );
              },
            ),
          ),
          const SizedBox(height: 24),
          _buildCurrentStepActionCard(),
        ],
      ),
    );
  }

  Widget _buildCurrentStepActionCard() {
    switch (widget.currentStepIndex) {
      case 1:
        return _IdentityValidationCard(onValidate: widget.advanceToNextStep);
      case 2:
        return _CompanyDataCard(onContinue: widget.advanceToNextStep);
      case 3:
        return _CreateProductCard(onCreate: widget.advanceToNextStep);
      case 4:
        return _FirstSaleCard(
          onSell: () {
            /* Lógica final */
          },
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildConnector(bool isNext) {
    return Container(
      width: 20,
      height: 0,
      margin: const EdgeInsets.only(top: 78, bottom: 78),
      color: isNext ? AppPalette.orange400 : AppPalette.neutral200,
    );
  }

  Widget _buildStepCard(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
    _StepState state,
    bool isNext,
  ) {
    Color bg, border, content, iconBg;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    switch (state) {
      case _StepState.completed:
        bg = isDark ? Colors.green.withOpacity(0.1) : const Color(0xFFE8F5E9);
        border = Colors.transparent;
        content = isDark ? Colors.greenAccent : const Color(0xFF2E7D32);
        iconBg = Colors.transparent;
        break;

      case _StepState.current:
      case _StepState.locked:
        bg = isDark ? Colors.orange.withOpacity(0.1) : const Color(0xFFFFF3E0);
        border = AppPalette.orange500;
        content = AppPalette.orange500;
        iconBg = AppPalette.orange400.withOpacity(0.4);
        break;
    }

    final double contentOpacity = 1.0;

    return Container(
      width: 160,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isNext ? border : Colors.transparent,
          width: state == _StepState.current ? 2 : 1.5,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              // ALTERAÇÃO 1: Mudança de shape circular para quadrado com bordas arredondadas
              borderRadius: BorderRadius.circular(12),
              color: state == _StepState.completed
                  ? Color(0xFF2E7D32).withOpacity(0.1)
                  : iconBg,
              border: Border.all(
                color: state == _StepState.completed
                    ? content.withOpacity(contentOpacity)
                    : Colors.transparent,
                width: 2,
              ),
            ),
            child: Icon(
              state == _StepState.completed ? Icons.check : icon,
              size: 32,
              // ALTERAÇÃO 2: Ícone preto (Colors.black) ao invés de seguir a cor do conteúdo
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: content.withOpacity(contentOpacity),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              color: content.withOpacity(contentOpacity * 0.8),
            ),
          ),
        ],
      ),
    );
  }
}

class _StepData {
  final IconData icon;
  final String title;
  final String subtitle;
  final _StepState state;

  _StepData(this.icon, this.title, this.subtitle, this.state);
}

enum _StepState { completed, current, locked }

class _IdentityValidationCard extends StatelessWidget {
  final VoidCallback onValidate; // Callback para ser chamado no onPressed

  const _IdentityValidationCard({required this.onValidate});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isMobile = MediaQuery.of(context).size.width < 900;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E1), // Fundo laranja claro
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFFE0B2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if(!isMobile)...[
            Row(
              children: [
                const CircleAvatar(
                  backgroundColor: AppPalette.orange500,
                  foregroundColor: Colors.white,
                  radius: 12,
                  child: Text("2", style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 8),
                Text(
                  "Validação de Identidade",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const Spacer(),
                const Chip(
                  label: Text("Em andamento"),
                  backgroundColor: Color(0xFFFFF3E0),
                  labelStyle: TextStyle(
                    color: AppPalette.orange500,
                    fontSize: 12,
                  ),
                  padding: EdgeInsets.zero,
                ),
              ],
            ),
          ]
          else...[
            Row(
              children: [
                const CircleAvatar(
                  backgroundColor: AppPalette.orange500,
                  foregroundColor: Colors.white,
                  radius: 12,
                  child: Text("2", style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 8),
                Text(
                  "Validação de Identidade",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const Spacer(),
              ],
            ),
            const Chip(
              label: Text("Em andamento"),
              backgroundColor: Color(0xFFFFF3E0),
              labelStyle: TextStyle(
                color: AppPalette.orange500,
                fontSize: 12,
              ),
              padding: EdgeInsets.zero,
            ),
          ],
          const SizedBox(height: 16),
          Text(
            "Para sua segurança, precisamos validar sua identidade. Isso leva menos de 5 minutos.",
            style: TextStyle(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 16),
          // O BOTÃO AGORA CHAMA O CALLBACK
          ElevatedButton(
            onPressed: onValidate,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppPalette.orange500,
              foregroundColor: Colors.white,
            ),
            child: const Text(
              "Validar Identidade",
              style: TextStyle(color: AppPalette.surfaceText),
            ),
          ),
        ],
      ),
    );
  }
}

class _SalesCard extends StatelessWidget {
  final bool isMobile;

  const _SalesCard({this.isMobile = false});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: isMobile
          ? Column(
              children: [
                _buildLeftContent(context),
                const Divider(height: 48),
                _buildRightContent(context),
              ],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 3, child: _buildLeftContent(context)),
                Container(
                  width: 1,
                  color: theme.dividerColor,
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  height: 250,
                ),
                Expanded(flex: 2, child: _buildRightContent(context)),
              ],
            ),
    );
  }

  Widget _buildLeftContent(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Vendas",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 32),
        Center(
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSurface.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.sell_outlined,
                  size: 32,
                  color: theme.colorScheme.onSurface.withOpacity(0.5),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                "Nenhuma venda ainda",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "Crie seu primeiro produto para começar a vender e acompanhar suas vendas aqui",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  foregroundColor: theme.colorScheme.onSurface,
                  side: BorderSide(color: theme.dividerColor),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                child: const Text("Ver tutorial"),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      Theme.of(context).brightness == Brightness.dark
                      ? Colors.grey[800]
                      : const Color(0xFF0F172A),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                child: const Text("Criar produto +"),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRightContent(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            _badge(context, "Hoje", true),
            const SizedBox(width: 4),
            _badge(context, "30 dias", false),
          ],
        ),
        const SizedBox(height: 32),
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            "R\$ 0,00",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            "Vendas de hoje",
            style: TextStyle(
              fontSize: 10,
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ),
        const SizedBox(height: 24),
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            "R\$ 0,00",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            "Últimos 30 dias",
            style: TextStyle(
              fontSize: 10,
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ),
      ],
    );
  }

  Widget _badge(BuildContext context, String text, bool active) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: active
            ? theme.colorScheme.onSurface.withOpacity(0.2)
            : theme.colorScheme.onSurface.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          fontWeight: active ? FontWeight.bold : FontWeight.normal,
          color: theme.colorScheme.onSurface,
        ),
      ),
    );
  }
}

class _CreditCardRefusals extends StatelessWidget {
  const _CreditCardRefusals();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Recusas do cartão de crédito",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: theme.colorScheme.onSurface,
            ),
          ),
          Text(
            "Últimos 7 dias",
            style: TextStyle(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 24),
          Center(
            child: SizedBox(
              height: 100,
              width: 100,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CircularProgressIndicator(
                    value: 1,
                    color: theme.colorScheme.onSurface.withOpacity(0.1),
                    strokeWidth: 8,
                  ),
                  Text(
                    "0%",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Center(
            child: Text(
              "Crie um produto e comece a vendê-lo.",
              style: TextStyle(
                fontSize: 10,
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 40,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: AppPalette.orange500,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              child: const Text(
                "Criar produto +",
                style: TextStyle(color: AppPalette.surfaceText),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SidebarMenu extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;

  const _SidebarMenu({
    required this.selectedIndex,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: 80, // Largura padrão confortável para sidebar
      color: theme.cardColor,
      child: Column(
        children: [
          const SizedBox(height: 32),
          Image.asset(
            'assets/logo.png',
            color: AppPalette.orange500,
            width: 32,
            height: 32,
          ),
          const SizedBox(height: 48),
          _iconBtn(context, Icons.home_filled, 0),
          _iconBtn(context, Icons.local_offer_outlined, 1),
          _iconBtn(context, Icons.bar_chart, 3),
          _iconBtn(context, Icons.person_outline, 4),
          _iconBtn(context, Icons.settings, 2),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.only(bottom: 32),
            child: InkWell(
              onTap: () => onItemSelected(4),
              // Clicar no avatar também leva pra conta
              child: CircleAvatar(
                backgroundColor: const Color(0xFFFFF3E0),
                radius: 20,
                child: Text(
                  "AA",
                  style: TextStyle(
                    color: Colors.brown[800],
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _iconBtn(BuildContext context, IconData icon, int index) {
    final isSelected = selectedIndex == index;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return InkWell(
      onTap: () => onItemSelected(index),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          // Fundo ativo sutil (Laranja claro no light, Branco transp. no dark)
          color: isSelected
              ? (isDark
                    ? Colors.white.withOpacity(0.1)
                    : const Color(0xFFFFF3E0))
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          size: 24,
          // Cor ativa (Laranja no light, Branco no dark) vs Cinza inativo
          color: isSelected
              ? (isDark ? Colors.white : Colors.black87)
              : theme.iconTheme.color?.withOpacity(0.4),
        ),
      ),
    );
  }
}

class _WhatsAppNotificationCard extends StatelessWidget {
  const _WhatsAppNotificationCard();

  @override
  Widget build(BuildContext context) {
    // Cores específicas baseadas na imagem (Verde claro e escuro)
    const backgroundColor = Color(0xFFE8F5E9); // Verde bem claro
    const borderColor = Color(0xFFC8E6C9); // Borda verde clara
    const iconColor = Color(0xFF2E7D32); // Verde escuro ícone
    const textColor = Color(0xFF1B5E20); // Verde escuro texto

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          const Icon(FontAwesomeIcons.whatsapp, color: iconColor, size: 28),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              "As notificações de mensagem estão desativadas. Se deseja receber mensagens sobre suas vendas ative agora",
              style: TextStyle(
                color: textColor.withOpacity(0.8),
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ),
          const SizedBox(width: 16),
          TextButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => const _WhatsAppDialog(),
              );
            },
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: const Size(50, 30),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text(
              "Ativar",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: iconColor,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WhatsAppDialog extends StatelessWidget {
  const _WhatsAppDialog();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.all(16),
      // Adiciona margem externa segura no mobile
      child: Container(
        width: 400, // Mantém largura máxima para desktop
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              // Alinha ao topo caso quebre linha
              children: [
                // Usamos Expanded aqui para o texto ocupar só o espaço disponível
                const Expanded(
                  child: Row(
                    children: [
                      Icon(
                        FontAwesomeIcons.whatsapp,
                        color: Color(0xFF2E7D32),
                        size: 20,
                      ),
                      SizedBox(width: 8),
                      // Flexible permite que o texto quebre linha se precisar
                      Flexible(
                        child: Text(
                          "Mensagens no WhatsApp",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                          // Garante que não estoure, mas sim vá para linha de baixo ou reticências
                          overflow: TextOverflow.visible,
                        ),
                      ),
                    ],
                  ),
                ),
                // Botão fechar mantém seu tamanho fixo
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close, size: 20, color: Colors.grey),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  // Remove padding extra do IconButton
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),

            const SizedBox(height: 16),

            const Text(
              "Por aqui, vamos te manter por dentro de tudo que importa para vender mais: atualizações sobre suas vendas, desempenho do seu produto, novos leads e insights estratégicos para impulsionar seus resultados.",
              style: TextStyle(
                color: Color(0xFF616161),
                fontSize: 14,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),

            Center(
              child: SizedBox(
                width: 300,
                child: Stack(
                  alignment: Alignment.center,
                  children: [Image.asset('assets/conversa.png')],
                ),
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              "Caso mude de ideia, você pode desativar a qualquer momento enviando /STOP para o número do WhatsApp.",
              style: TextStyle(color: Color(0xFF757575), fontSize: 12),
            ),
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              height: 45,
              child: ElevatedButton(
                onPressed: () async {
                  final SettingsRepository _settingsRepository =
                      SettingsRepository();
                  final whatsappLink = await _settingsRepository
                      .getWhatsappLink();
                  final whatsappUrl = Uri.parse(whatsappLink);
                  try {
                    await launchUrl(
                      whatsappUrl,
                      mode: LaunchMode.externalApplication,
                    );
                  } catch (e) {
                    debugPrint("Erro ao abrir WhatsApp: $e");
                  }

                  if (context.mounted) {
                    Navigator.of(context).pop();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1B5E20),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  "Ativar",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CompanyDataCard extends StatelessWidget {
  final VoidCallback onContinue;

  const _CompanyDataCard({required this.onContinue});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E1), // Fundo laranja claro
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFFE0B2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(
                backgroundColor: AppPalette.orange500,
                foregroundColor: Colors.white,
                radius: 12,
                child: Text("3", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 8),
              Text(
                "Dados da empresa",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const Spacer(),
              const Chip(
                label: Text("Em andamento"),
                backgroundColor: Color(0xFFFFF3E0),
                labelStyle: TextStyle(
                  color: AppPalette.orange500,
                  fontSize: 12,
                ),
                padding: EdgeInsets.zero,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            "Preencha os dados da sua empresa, caso você tenha.",
            style: TextStyle(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            "Para saques acima de R\$ 2.000,00 mensal cadastre uma empresa (CNPJ). O que você precisa:",
            style: TextStyle(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 12),
          const _InfoRow(
            icon: Icons.description_outlined,
            text: "Contrato Social",
          ),
          const SizedBox(height: 8),
          const _InfoRow(icon: Icons.badge_outlined, text: "CNPJ"),
          const SizedBox(height: 24),
          Text(
            "Se não pretende sacar mais de R\$ 2.000 mensais, você pode pular essa etapa e continuar como pessoa física.",
            style: TextStyle(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onContinue, // <--- CHAMA A FUNÇÃO DE AVANÇAR
                  style: OutlinedButton.styleFrom(
                    foregroundColor: theme.colorScheme.onSurface,
                    side: BorderSide(color: theme.dividerColor),
                  ),
                  child: const Text("Continuar como Pessoa Física"),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: onContinue, // <--- CHAMA A FUNÇÃO DE AVANÇAR
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppPalette.orange500,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text(
                    "Preencher dados",
                    style: TextStyle(color: AppPalette.surfaceText),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(
            fontSize: 12,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
          ),
        ),
      ],
    );
  }
}

class _CreateProductCard extends StatelessWidget {
  final VoidCallback onCreate;

  const _CreateProductCard({required this.onCreate});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E1), // Fundo laranja claro
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFFE0B2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(
                backgroundColor: AppPalette.orange500,
                foregroundColor: Colors.white,
                radius: 12,
                child: Text("4", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 8),
              Text(
                "Criar Produto",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const Spacer(),
              const Chip(
                label: Text("Em andamento"),
                backgroundColor: Color(0xFFFFF3E0),
                labelStyle: TextStyle(
                  color: AppPalette.orange500,
                  fontSize: 12,
                ),
                padding: EdgeInsets.zero,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            "Crie um produto e comece a vender.",
            style: TextStyle(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            "O que você precisa:",
            style: TextStyle(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 12),
          const _InfoRow(icon: Icons.title, text: "Nome do Produto"),
          const SizedBox(height: 8),
          const _InfoRow(icon: Icons.image_outlined, text: "Imagem do Produto"),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onCreate, // <--- CHAMA A FUNÇÃO DE AVANÇAR
              style: ElevatedButton.styleFrom(
                backgroundColor: AppPalette.orange500,
                foregroundColor: Colors.white,
              ),
              child: const Text(
                "Criar Produto",
                style: TextStyle(color: AppPalette.surfaceText),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FirstSaleCard extends StatelessWidget {
  final VoidCallback onSell;

  const _FirstSaleCard({required this.onSell});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E1), // Fundo laranja claro
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFFE0B2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(
                backgroundColor: AppPalette.orange500,
                foregroundColor: Colors.white,
                radius: 12,
                child: Text("5", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 8),
              Text(
                "Primeira Venda",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const Spacer(),
              const Chip(
                label: Text("Em andamento"),
                backgroundColor: Color(0xFFFFF3E0),
                labelStyle: TextStyle(
                  color: AppPalette.orange500,
                  fontSize: 12,
                ),
                padding: EdgeInsets.zero,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            "Realize sua primeira venda para completar o cadastro e ter acesso a todos os recursos.",
            style: TextStyle(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          // Pode adicionar mais informações ou um botão se necessário
        ],
      ),
    );
  }
}
