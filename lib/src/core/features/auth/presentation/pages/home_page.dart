import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:voomp_sellers_rebranding/src/core/database/database_helper.dart';
import 'package:voomp_sellers_rebranding/src/core/features/account/presentation/pages/my_account_page.dart';
import 'package:voomp_sellers_rebranding/src/core/features/auth/services/auth_service.dart';
import 'package:voomp_sellers_rebranding/src/core/features/dashboard/presentation/pages/overview_dashboard_page.dart';
import 'package:voomp_sellers_rebranding/src/core/features/finance/presentation/pages/financial_statement_page.dart';
import 'package:voomp_sellers_rebranding/src/core/features/model/user.dart';
import 'package:voomp_sellers_rebranding/src/core/features/products/presentation/pages/product_list_page.dart';
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

  @override
  void initState() {
    super.initState();
    _loadUser();
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
        _user = extra;
        _isLoading = false; // Carregamento concluído
      });
    }
  }

  void _onItemTapped(int index) {
    if (index == 2) return;

    setState(() {
      _selectedIndex = index;
    });
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
    final List<Widget> pages = [
      OverviewDashboardPage(userName: _user.name ?? ''),
      // DashboardContent(userName: _user.name),
      const ProductListPage(),                            // Index 1: Produtos
      const SizedBox(),                                   // Index 2: Placeholder do FAB (se houver)
      const FinancialStatementPage(),                     // Index 3: Financeiro
      const MyAccountPage(),                              // Index 4: <--- ADICIONE AQUI (Minha Conta)
    ];

    final isMobile = MediaQuery.of(context).size.width < 900;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Sidebar (Apenas Desktop)
            if (!isMobile)
              _SidebarMenu(
                selectedIndex: _selectedIndex,
                onItemSelected: _onItemTapped,
              ),

            // Área de Conteúdo
            Expanded(child: pages[_selectedIndex]),
          ],
        ),
      ),
      floatingActionButton: isMobile
          ? FloatingActionButton(
              onPressed: () {
                context.go('/create-product');
              },
              backgroundColor: AppPalette.orange500,
              shape: const CircleBorder(),
              child: const Icon(Icons.add, color: Colors.white, size: 32),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: isMobile
          ? BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed, // Importante para mais de 3 itens
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
          // --- NOVO ITEM ---
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

class DashboardContent extends StatelessWidget {
  final String userName;

  const DashboardContent({super.key, required this.userName});

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 900;
    final padding = isDesktop ? 40.0 : 20.0;
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(padding, padding, padding, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Text(
            "Olá, $userName",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onBackground,
            ),
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
          const _WhatsAppNotificationCard(),
          const SizedBox(height: 24),
          const _OnboardingStepsCard(),
          const SizedBox(height: 24),

          if (!isDesktop) ...[
            const _IdentityValidationCard(),
            const SizedBox(height: 24),
            const _BalanceCard(),
            const SizedBox(height: 24),
            const _SalesCard(isMobile: true),
            const SizedBox(height: 24),
            const _CreditCardRefusals(),
          ] else ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Expanded(flex: 3, child: _IdentityValidationCard()),
                SizedBox(width: 24),
                Expanded(flex: 2, child: _BalanceCard()),
              ],
            ),
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
                        onTap: () async{
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

class _OnboardingStepsCard extends StatelessWidget {
  const _OnboardingStepsCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Definição dos passos
    final steps = [
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
        _StepState.current,
      ),
      _StepData(
        Icons.business,
        "Empresa",
        "Dados da Empresa",
        _StepState.locked,
      ),
      _StepData(
        Icons.inventory_2_outlined,
        "Produto",
        "Primeiro Produto",
        _StepState.locked,
      ),
      _StepData(
        Icons.sell_outlined,
        "Primeira Venda",
        "Vender e Sacar",
        _StepState.locked,
      ),
    ];

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
          // Header do Card
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
                const Text(
                  "20%",
                  style: TextStyle(
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
              "1 de 5 etapas concluídas",
              style: TextStyle(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Barra de Progresso
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: const LinearProgressIndicator(
                value: 0.2,
                minHeight: 8,
                backgroundColor: Color(0xFFE0E0E0),
                color: AppPalette.orange500,
              ),
            ),
          ),
          const SizedBox(height: 32),

          // Lista Horizontal com Scroll
          SizedBox(
            height: 160,
            width: double.infinity,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: steps.length,
              separatorBuilder: (context, index) => _buildConnector(index == 0),
              itemBuilder: (context, index) {
                final step = steps[index];
                return _buildStepCard(
                  context,
                  step.icon,
                  step.title,
                  step.subtitle,
                  step.state,
                  index == 1,
                );
              },
            ),
          ),
        ],
      ),
    );
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

    // Configuração de cores baseada no estado
    switch (state) {
      case _StepState.completed:
        // Estilo Verde (Mantém para "Dados Pessoais")
        bg = isDark ? Colors.green.withOpacity(0.1) : const Color(0xFFE8F5E9);
        border = Colors.transparent;
        content = isDark ? Colors.greenAccent : const Color(0xFF2E7D32);
        iconBg = Colors.transparent;
        break;

      case _StepState.current:
      case _StepState.locked:
        // Estilo Laranja/Bege (Aplica para "Identidade" e todos os outros)
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
              icon,
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
  const _IdentityValidationCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 24,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppPalette.orange500),
                ),
                child: const Center(
                  child: Text(
                    "2",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppPalette.orange500,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Validação de Identidade",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF3E0),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            "Em andamento",
                            style: TextStyle(
                              color: AppPalette.orange500,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Faça a validação dos seus documentos para liberar todas as funcionalidades",
                      style: TextStyle(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          Container(
            padding: const EdgeInsets.all(16),
            width: double.infinity,
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.grey.withOpacity(0.1)
                  : const Color(0xFFFFF3E0).withOpacity(0.5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "O que você precisa:",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 12),
                _item(
                  context,
                  Icons.description_outlined,
                  "Documentação - CPF",
                ),
                const SizedBox(height: 8),
                _item(context, Icons.face, "Selfie - Foto do rosto ao vivo"),
              ],
            ),
          ),
          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            height: 45,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: AppPalette.orange500,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
                elevation: 0,
              ),
              child: const Text(
                "Validar identidade",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _item(BuildContext context, IconData icon, String text) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 16, color: theme.colorScheme.onSurface),
        const SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(fontSize: 13, color: theme.colorScheme.onSurface),
        ),
      ],
    );
  }
}

class _BalanceCard extends StatelessWidget {
  const _BalanceCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Meu Saldo",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const Icon(Icons.credit_card, size: 20, color: Colors.grey),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "R\$ 0,00",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const Icon(
                Icons.visibility_off_outlined,
                color: Colors.grey,
                size: 20,
              ),
            ],
          ),
          const SizedBox(height: 32),

          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.grey.withOpacity(0.1)
                  : const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.shield_outlined,
                  size: 24,
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Complete seu cadastro",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      Text(
                        "Adicione os seus dados bancários para poder sacar",
                        style: TextStyle(
                          fontSize: 10,
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          SizedBox(
            width: double.infinity,
            height: 40,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: isDark
                    ? Colors.grey[800]
                    : const Color(0xFF0F172A),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              child: const Text("Adicionar dados bancários"),
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
              child: const Text("Criar produto +"),
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
          // Logo
          Image.asset(
            'assets/logo.png',
            color: AppPalette.orange500,
            width: 32,
            height: 32,
          ),
          const SizedBox(height: 48),

          // Itens do Menu
          // Index 0: Home / Dashboard
          _iconBtn(context, Icons.home_filled, 0),

          // Index 1: Produtos
          _iconBtn(context, Icons.local_offer_outlined, 1),

          // Index 2: É o FAB (Mobile), pulamos aqui na Sidebar

          // Index 3: Financeiro
          _iconBtn(context, Icons.bar_chart, 3),

          // Index 4: Minha Conta (Adicionado conforme solicitado)
          _iconBtn(context, Icons.person_outline, 4),

          // Ícone de "Lixeira" ou "Arquivados" (Opcional, baseado no seu código antigo)
          // Se não houver página para isso, pode remover ou criar um index 5
          // _iconBtn(context, Icons.delete_outline, 5),

          // Ícone de "Mais opções" (Visual)
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12),
            child: Icon(
              Icons.more_horiz,
              color: theme.iconTheme.color?.withOpacity(0.3),
            ),
          ),

          const Spacer(),

          // Avatar do Usuário
          Padding(
            padding: const EdgeInsets.only(bottom: 32),
            child: InkWell(
              onTap: () => onItemSelected(4), // Clicar no avatar também leva pra conta
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
              ? (isDark ? Colors.white.withOpacity(0.1) : const Color(0xFFFFF3E0))
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
            // --- HEADER CORRIGIDO ---
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

            // ------------------------
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
                  const phoneNumber = "595983639051";
                  const message = "/start";
                  final whatsappUrl = Uri.parse(
                    "https://wa.me/$phoneNumber?text=${Uri.encodeComponent(message)}",
                  );
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
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
