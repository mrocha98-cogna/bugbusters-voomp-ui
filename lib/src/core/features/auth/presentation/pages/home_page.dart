import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:voomp_sellers_rebranding/src/core/features/auth/services/auth_service.dart';
import 'package:voomp_sellers_rebranding/src/core/features/model/user.dart';
import 'package:voomp_sellers_rebranding/src/core/theme/app_colors.dart';
import 'package:voomp_sellers_rebranding/src/core/theme/theme_controller.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  late String _userName;
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUser();
    });
  }

  void _loadUser() async {
    final extra = GoRouterState.of(context).extra;

    if (extra != null && extra is User) {
      if (mounted) {
        setState(() {
          _userName = extra.name;
        });
      }
    } else {
      // 2. Se não veio pela rota (ex: login normal), busca do AuthService (SharedPreferences)
      final user = await _authService.getUserInformations();
      if (mounted) {
        setState(() {
          _userName = user.name;
        });
      }
    }
  }

  late final List<Widget> _pages = [
    DashboardContent(userName: _userName), // 0: Home
    const Center(child: Text("Produtos")), // 1
    const SizedBox(), // 2 (FAB placeholder)
    const Center(child: Text("Financeiro")), // 3
    ProfileTab(userName: _userName), // 4: Perfil com Tema
  ];

  void _onItemTapped(int index) {
    if (index == 2) return;
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
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
            Expanded(
              child: _pages[_selectedIndex],
            ),
          ],
        ),
      ),

      // Bottom Nav (Apenas Mobile)
      floatingActionButton: isMobile
          ? FloatingActionButton(
        onPressed: () {},
        backgroundColor: AppPalette.orange500,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white, size: 32),
      )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: isMobile
          ? BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        color: theme.cardColor,
        surfaceTintColor: Colors.transparent,
        elevation: 10,
        shadowColor: Colors.black.withOpacity(0.1),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildBottomNavItem(0, Icons.home_filled),
            _buildBottomNavItem(1, Icons.inventory_2_outlined),
            const SizedBox(width: 48), // Espaço para o FAB
            _buildBottomNavItem(3, Icons.account_balance_wallet_outlined),
            _buildBottomNavItem(4, Icons.person_outline),
          ],
        ),
      )
          : null,
    );
  }

  Widget _buildBottomNavItem(int index, IconData icon) {
    final isSelected = _selectedIndex == index;
    return IconButton(
      icon: Icon(
        icon,
        color: isSelected ? AppPalette.orange500 : AppPalette.neutral400,
      ),
      onPressed: () => _onItemTapped(index),
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
                color: theme.colorScheme.onBackground),
          ),
          const SizedBox(height: 8),
          Text(
            "Estamos muito felizes de te receber aqui. Te desejamos boas vendas!",
            style: TextStyle(color: theme.colorScheme.onBackground.withOpacity(0.6), fontSize: 14),
          ),
          const SizedBox(height: 32),

          // 1. Onboarding Card
          const _OnboardingStepsCard(),
          const SizedBox(height: 24),

          // 2. Layout Responsivo
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
  const ProfileTab({super.key, required this.userName});

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
                    userName.isNotEmpty ? userName.substring(0, 2).toUpperCase() : "AA",
                    style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: AppPalette.orange500
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
                  "vendedor@voomp.com.br",
                  style: TextStyle(color: theme.colorScheme.onBackground.withOpacity(0.6)),
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
                        title: Text("Modo Escuro", style: TextStyle(color: theme.colorScheme.onSurface)),
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
                        title: const Text("Sair da conta", style: TextStyle(color: Colors.red)),
                        onTap: () {
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
      _StepData(Icons.check, "Dados Pessoais", "Suas informações", _StepState.completed),
      _StepData(Icons.shield_outlined, "Identidade", "Validação", _StepState.current),
      _StepData(Icons.business, "Empresa", "Dados da Empresa", _StepState.locked),
      _StepData(Icons.inventory_2_outlined, "Produto", "Primeiro Produto", _StepState.locked),
      _StepData(Icons.sell_outlined, "Primeira Venda", "Vender e Sacar", _StepState.locked),
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
              offset: const Offset(0, 4)),
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
                Text("Complete seu cadastro",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: theme.colorScheme.onSurface)),
                const Text("20%",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                        color: AppPalette.orange500)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: Text("1 de 5 etapas concluídas",
                style: TextStyle(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                    fontSize: 12)),
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
                    context, step.icon, step.title, step.subtitle, step.state, index == 1);
              },
            ),
          )
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

  Widget _buildStepCard(BuildContext context, IconData icon, String title,
      String subtitle, _StepState state, bool isNext) {
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
            color: isNext ? border : Colors.transparent, width: state == _StepState.current ? 2 : 1.5),
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
                      : Colors.transparent, width: 2),
            ),
            child: Icon(icon,
                size: 32,
                // ALTERAÇÃO 2: Ícone preto (Colors.black) ao invés de seguir a cor do conteúdo
                color: Colors.black),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: content.withOpacity(contentOpacity)),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 11,
                color: content.withOpacity(contentOpacity * 0.8)),
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
                width: 24, height: 32,
                decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: AppPalette.orange500)),
                child: const Center(child: Text("2", style: TextStyle(fontWeight: FontWeight.bold, color: AppPalette.orange500))),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Validação de Identidade", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: theme.colorScheme.onSurface)),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                          decoration: BoxDecoration(color: const Color(0xFFFFF3E0), borderRadius: BorderRadius.circular(4)),
                          child: const Text("Em andamento", style: TextStyle(color: AppPalette.orange500, fontSize: 10, fontWeight: FontWeight.bold)),
                        )
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text("Faça a validação dos seus documentos para liberar todas as funcionalidades",
                        style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.6), fontSize: 12)),
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
              color: isDark ? Colors.grey.withOpacity(0.1) : const Color(0xFFFFF3E0).withOpacity(0.5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("O que você precisa:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: theme.colorScheme.onSurface)),
                const SizedBox(height: 12),
                _item(context, Icons.description_outlined, "Documentação - CPF"),
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
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                elevation: 0,
              ),
              child: const Text("Validar identidade", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          )
        ],
      ),
    );
  }

  Widget _item(BuildContext context, IconData icon, String text) {
    final theme = Theme.of(context);
    return Row(children: [
      Icon(icon, size: 16, color: theme.colorScheme.onSurface),
      const SizedBox(width: 8),
      Text(text, style: TextStyle(fontSize: 13, color: theme.colorScheme.onSurface)),
    ]);
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
              Text("Meu Saldo", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: theme.colorScheme.onSurface)),
              const Icon(Icons.credit_card, size: 20, color: Colors.grey),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("R\$ 0,00", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface)),
              const Icon(Icons.visibility_off_outlined, color: Colors.grey, size: 20),
            ],
          ),
          const SizedBox(height: 32),

          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
                color: isDark ? Colors.grey.withOpacity(0.1) : const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(8)
            ),
            child: Row(
              children: [
                Icon(Icons.shield_outlined, size: 24, color: theme.colorScheme.onSurface.withOpacity(0.6)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Complete seu cadastro", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: theme.colorScheme.onSurface)),
                      Text("Adicione os seus dados bancários para poder sacar", style: TextStyle(fontSize: 10, color: theme.colorScheme.onSurface.withOpacity(0.6))),
                    ],
                  ),
                )
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
                backgroundColor: isDark ? Colors.grey[800] : const Color(0xFF0F172A),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
              ),
              child: const Text("Adicionar dados bancários"),
            ),
          )
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
          Container(width: 1, color: theme.dividerColor, margin: const EdgeInsets.symmetric(horizontal: 24), height: 250),
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
        Text("Vendas", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: theme.colorScheme.onSurface)),
        const SizedBox(height: 32),
        Center(
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: theme.colorScheme.onSurface.withOpacity(0.1), shape: BoxShape.circle),
                child: Icon(Icons.sell_outlined, size: 32, color: theme.colorScheme.onSurface.withOpacity(0.5)),
              ),
              const SizedBox(height: 16),
              Text("Nenhuma venda ainda", style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface)),
              const SizedBox(height: 4),
              Text("Crie seu primeiro produto para começar a vender e acompanhar suas vendas aqui",
                  textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurface.withOpacity(0.6))),
            ],
          ),
        ),
        const SizedBox(height: 32),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                  onPressed: (){},
                  style: OutlinedButton.styleFrom(
                      foregroundColor: theme.colorScheme.onSurface,
                      side: BorderSide(color: theme.dividerColor),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4))
                  ),
                  child: const Text("Ver tutorial")
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                  onPressed: (){},
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).brightness == Brightness.dark ? Colors.grey[800] : const Color(0xFF0F172A),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4))
                  ),
                  child: const Text("Criar produto +")
              ),
            ),
          ],
        )
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
        Align(alignment: Alignment.centerRight, child: Text("R\$ 0,00", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: theme.colorScheme.onSurface))),
        Align(alignment: Alignment.centerRight, child: Text("Vendas de hoje", style: TextStyle(fontSize: 10, color: theme.colorScheme.onSurface.withOpacity(0.6)))),
        const SizedBox(height: 24),
        Align(alignment: Alignment.centerRight, child: Text("R\$ 0,00", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: theme.colorScheme.onSurface))),
        Align(alignment: Alignment.centerRight, child: Text("Últimos 30 dias", style: TextStyle(fontSize: 10, color: theme.colorScheme.onSurface.withOpacity(0.6)))),
      ],
    );
  }

  Widget _badge(BuildContext context, String text, bool active) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
          color: active ? theme.colorScheme.onSurface.withOpacity(0.2) : theme.colorScheme.onSurface.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12)
      ),
      child: Text(text, style: TextStyle(fontSize: 10, fontWeight: active ? FontWeight.bold : FontWeight.normal, color: theme.colorScheme.onSurface)),
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
          Text("Recusas do cartão de crédito", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: theme.colorScheme.onSurface)),
          Text("Últimos 7 dias", style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.6), fontSize: 12)),
          const SizedBox(height: 24),
          Center(
            child: SizedBox(
              height: 100, width: 100,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CircularProgressIndicator(value: 1, color: theme.colorScheme.onSurface.withOpacity(0.1), strokeWidth: 8),
                  Text("0%", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: theme.colorScheme.onSurface)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Center(child: Text("Crie um produto e comece a vendê-lo.", style: TextStyle(fontSize: 10, color: theme.colorScheme.onSurface.withOpacity(0.6)))),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 40,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: AppPalette.orange500,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
              ),
              child: const Text("Criar produto +"),
            ),
          )
        ],
      ),
    );
  }
}

class _SidebarMenu extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;

  const _SidebarMenu({required this.selectedIndex, required this.onItemSelected});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: 70,
      color: theme.cardColor,
      child: Column(
        children: [
          const SizedBox(height: 24),
          Image.asset('assets/logo.png', color: AppPalette.orange500, width: 32, height: 32),
          const SizedBox(height: 40),

          _iconBtn(context, Icons.home_filled, 0),
          _iconBtn(context, Icons.inventory_2, 1),
          _iconBtn(context, Icons.pie_chart_outline, 2),
          _iconBtn(context, Icons.delete_outline, 3),
          _iconBtn(context, Icons.account_balance_wallet_outlined, 4),

          const Spacer(),
          Padding(
            padding: const EdgeInsets.only(bottom: 24),
            child: CircleAvatar(
              backgroundColor: const Color(0xFFFFF3E0),
              radius: 18,
              child: Text("AA", style: TextStyle(color: Colors.brown[800], fontSize: 12, fontWeight: FontWeight.bold)),
            ),
          )
        ],
      ),
    );
  }

  Widget _iconBtn(BuildContext context, IconData icon, int index) {
    final isSelected = selectedIndex == index;
    final theme = Theme.of(context);

    return InkWell(
      onTap: () {
        // Lógica de interceptação: Se for o item de Produtos (Index 1)
        if (index == 1) {
          context.go('/create-product');
        } else {
          // Para os outros itens, mantém o comportamento padrão de troca de aba
          onItemSelected(index);
        }
      },
      borderRadius: BorderRadius.circular(8), // Adicionado para o efeito visual do clique ficar bonito
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 12),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFFF3E0) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon,
            size: 20,
            color: isSelected ? Colors.black : theme.iconTheme.color?.withOpacity(0.5)),
      ),
    );
  }
}
