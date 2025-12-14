import 'package:flutter/material.dart';
import 'package:voomp_sellers_rebranding/src/core/features/auth/services/auth_service.dart';
import 'package:voomp_sellers_rebranding/src/core/theme/app_colors.dart';
import 'package:voomp_sellers_rebranding/src/core/theme/theme_controller.dart';
import 'package:voomp_sellers_rebranding/src/shared/widgets/custom_button.dart';

// ==========================================
// 1. ESTRUTURA PRINCIPAL (SHELL)
// ==========================================

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  String _userName = "Vendedor";
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  void _loadUser() async {
    final name = await _authService.getUserName();
    if (name != null) {
      setState(() {
        _userName = name.split(' ').first;
      });
    }
  }

  // Lista de Telas
  late final List<Widget> _pages = [
    DashboardContent(userName: _userName), // 0: Home
    const Center(child: Text("Tela de Produtos")), // 1: Produtos
    const SizedBox(), // 2: Placeholder do Botão Central
    const Center(child: Text("Tela Financeira")), // 3: Financeiro
    const ProfileContent(), // 4: Perfil (Com Toggle de Tema)
  ];

  void _onItemTapped(int index) {
    if (index == 2) return; // Ação do botão central tratada no FAB
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 900;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      // Background vem do Theme (AppTheme.scaffoldBackgroundColor)
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Sidebar Desktop
          if (!isMobile)
            _SidebarMenu(
              selectedIndex: _selectedIndex,
              onItemSelected: _onItemTapped,
            ),

          // Conteúdo Principal
          Expanded(
            child: _pages[_selectedIndex],
          ),
        ],
      ),

      // Botão Flutuante (Mobile)
      floatingActionButton: isMobile
          ? FloatingActionButton(
        onPressed: () => _onItemTapped(2),
        backgroundColor: AppPalette.orange500,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white, size: 32),
      )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      // Menu Inferior (Mobile)
      bottomNavigationBar: isMobile
          ? BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        color: theme.colorScheme.surface, // Adapta ao tema (Branco ou Cinza Escuro)
        surfaceTintColor: Colors.transparent,
        elevation: 10,
        height: 70,
        padding: EdgeInsets.zero,
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
    final theme = Theme.of(context);

    // Cor inativa muda dependendo do tema para garantir contraste
    final inactiveColor = theme.brightness == Brightness.dark
        ? AppPalette.neutral500
        : AppPalette.neutral400;

    return IconButton(
      icon: Icon(
        icon,
        color: isSelected ? AppPalette.orange500 : inactiveColor,
        size: 28,
      ),
      onPressed: () => _onItemTapped(index),
    );
  }
}

// ==========================================
// 2. CONTEÚDO DO PERFIL (TELA 4)
// ==========================================

class ProfileContent extends StatelessWidget {
  const ProfileContent({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = ThemeController.instance.isDarkMode;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Minha Conta",
            style: TextStyle(
                fontSize: 28, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface),
          ),
          const SizedBox(height: 32),

          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: theme.cardTheme.color,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                // Toggle de Tema
                ListTile(
                  leading: Icon(
                    isDark ? Icons.dark_mode : Icons.light_mode,
                    color: AppPalette.orange500,
                  ),
                  title: Text(
                    "Modo Escuro",
                    style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface),
                  ),
                  subtitle: Text(
                    isDark ? "Ativado" : "Desativado",
                    style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.6)),
                  ),
                  trailing: Switch(
                    value: isDark,
                    activeColor: AppPalette.orange500,
                    onChanged: (value) {
                      ThemeController.instance.toggleTheme();
                    },
                  ),
                ),
                Divider(color: theme.dividerColor),
                ListTile(
                  leading: const Icon(Icons.logout, color: AppPalette.error500),
                  title: const Text("Sair da conta", style: TextStyle(color: AppPalette.error500)),
                  onTap: () {
                    // Adicione lógica de logout aqui
                  },
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

// ==========================================
// 3. DASHBOARD (TELA 0)
// ==========================================

class DashboardContent extends StatelessWidget {
  final String userName;
  const DashboardContent({super.key, required this.userName});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 900;
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Text(
            "Olá, $userName",
            style: TextStyle(
                fontSize: 28, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface),
          ),
          const SizedBox(height: 8),
          Text(
            "Estamos muito felizes de te receber aqui. Te desejamos boas vendas!",
            style: TextStyle(fontSize: 14, color: theme.colorScheme.onSurface.withOpacity(0.6)),
          ),
          const SizedBox(height: 32),

          const _OnboardingProgressCard(),
          const SizedBox(height: 24),

          // Layout Responsivo
          LayoutBuilder(
            builder: (context, constraints) {
              if (isMobile) {
                return const Column(
                  children: [
                    _IdentityValidationCard(),
                    SizedBox(height: 24),
                    _BalanceCard(),
                    SizedBox(height: 24),
                    _SalesCard(),
                    SizedBox(height: 24),
                    _CreditCardRefusals(),
                    SizedBox(height: 80), // Espaço para BottomNav
                  ],
                );
              } else {
                return Column(
                  children: [
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
                        Expanded(flex: 3, child: _SalesCard()),
                        SizedBox(width: 24),
                        Expanded(flex: 2, child: _CreditCardRefusals()),
                      ],
                    ),
                  ],
                );
              }
            },
          ),
        ],
      ),
    );
  }
}

// ==========================================
// 4. SIDEBAR MENU
// ==========================================

class _SidebarMenu extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;

  const _SidebarMenu({required this.selectedIndex, required this.onItemSelected});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: 80,
      color: theme.cardTheme.color, // Cor do card (Branco/Cinza Dark)
      child: Column(
        children: [
          const SizedBox(height: 32),
          const Icon(Icons.incomplete_circle, color: AppPalette.orange500, size: 32),
          const SizedBox(height: 40),

          _buildSidebarItem(context, 0, Icons.home_filled),
          _buildSidebarItem(context, 1, Icons.inventory_2_outlined),
          _buildSidebarItem(context, 2, Icons.add_circle_outline, isAction: true),
          _buildSidebarItem(context, 3, Icons.account_balance_wallet_outlined),
          _buildSidebarItem(context, 4, Icons.person_outline),

          const Spacer(),
          Padding(
            padding: const EdgeInsets.only(bottom: 24),
            child: Icon(Icons.logout, color: theme.colorScheme.onSurface.withOpacity(0.5)),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarItem(BuildContext context, int index, IconData icon, {bool isAction = false}) {
    final isActive = selectedIndex == index;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Lógica de Cores da Sidebar
    final iconColor = isActive || isAction
        ? AppPalette.orange500
        : theme.colorScheme.onSurface.withOpacity(0.7);

    // Background do item ativo: Laranja claro no light, Laranja translúcido no dark
    final activeBgColor = isDark
        ? AppPalette.orange500.withOpacity(0.15)
        : AppPalette.orange100;

    return GestureDetector(
      onTap: () => onItemSelected(index),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        height: 48,
        width: 48,
        decoration: BoxDecoration(
          color: isActive ? activeBgColor : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: isAction ? Border.all(color: AppPalette.orange500) : null,
        ),
        child: Icon(icon, color: iconColor, size: 24),
      ),
    );
  }
}

// ==========================================
// 5. WIDGETS INTERNOS (CARDS REFATORADOS)
// ==========================================

class _IdentityValidationCard extends StatelessWidget {
  const _IdentityValidationCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
          color: theme.cardTheme.color,
          borderRadius: BorderRadius.circular(12)
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 32, height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppPalette.orange500),
                    ),
                    child: const Center(
                        child: Text("2", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppPalette.orange500))),
                  ),
                  const SizedBox(width: 12),
                  Text("Validação de Identidade",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: theme.colorScheme.onSurface)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isDark ? AppPalette.orange500.withOpacity(0.2) : AppPalette.orange100,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text("Em andamento", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppPalette.orange500)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
              "Faça a validação dos seus documentos para liberar todas as funcionalidades",
              style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.6), fontSize: 14)),
          const SizedBox(height: 24),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              // Usa surfaceContainerHighest para diferenciar fundo secundário
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("O que você precisa:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: theme.colorScheme.onSurface)),
                const SizedBox(height: 12),
                _buildReqItem(context, Icons.description_outlined, "Documentação - CPF"),
                const SizedBox(height: 8),
                _buildReqItem(context, Icons.face, "Selfie - Foto do rosto ao vivo"),
              ],
            ),
          ),
          const SizedBox(height: 24),
          CustomButton(
            text: "Validar identidade",
            onPressed: () {},
            backgroundColor: AppPalette.orange500,
          )
        ],
      ),
    );
  }

  Widget _buildReqItem(BuildContext context, IconData icon, String text) {
    final color = Theme.of(context).colorScheme.onSurface;
    return Row(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 8),
        Text(text, style: TextStyle(fontSize: 13, color: color)),
      ],
    );
  }
}

class _BalanceCard extends StatelessWidget {
  const _BalanceCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
          color: theme.cardTheme.color,
          borderRadius: BorderRadius.circular(12)
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Meu Saldo", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: theme.colorScheme.onSurface)),
              Icon(Icons.credit_card, size: 20, color: theme.colorScheme.onSurface.withOpacity(0.5)),
            ],
          ),
          const SizedBox(height: 24),
          Text("R\$ 0,00", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface)),
          const SizedBox(height: 40),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.shield_outlined, size: 20, color: theme.colorScheme.onSurface.withOpacity(0.6)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Complete seu cadastro",
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: theme.colorScheme.onSurface)),
                      Text("Adicione os seus dados bancários para poder sacar",
                          style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurface.withOpacity(0.6))),
                    ],
                  ),
                )
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 45,
            child: ElevatedButton(
              onPressed: () {}, // Habilitar quando cadastro ok
              style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.secondary, // Azul
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8))),
              child: const Text("Adicionar dados bancários"),
            ),
          )
        ],
      ),
    );
  }
}

class _SalesCard extends StatelessWidget {
  const _SalesCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
          color: theme.cardTheme.color,
          borderRadius: BorderRadius.circular(12)
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Vendas",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: theme.colorScheme.onSurface)),
              Container(
                decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(20)),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                          color: AppPalette.neutral400,
                          borderRadius: BorderRadius.circular(20)),
                      child: const Text("Hoje",
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black)),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text("30 dias",
                          style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurface.withOpacity(0.6))),
                    ),
                  ],
                ),
              )
            ],
          ),
          const SizedBox(height: 30),
          // Empty State
          Center(
            child: Column(
              children: [
                Icon(Icons.sell_outlined, size: 48, color: theme.colorScheme.onSurface.withOpacity(0.2)),
                const SizedBox(height: 16),
                Text("Nenhuma venda ainda", style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface)),
                const SizedBox(height: 16),
                ElevatedButton(
                    onPressed: (){},
                    style: ElevatedButton.styleFrom(backgroundColor: theme.colorScheme.secondary),
                    child: const Text("Criar produto +", style: TextStyle(color: Colors.white))
                )
              ],
            ),
          )
        ],
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
          color: theme.cardTheme.color,
          borderRadius: BorderRadius.circular(12)
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Recusas do cartão",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: theme.colorScheme.onSurface)),
          const SizedBox(height: 24),
          Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(value: 0, backgroundColor: theme.colorScheme.surfaceContainerHighest, color: AppPalette.orange500),
                Text("0%", style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface))
              ],
            ),
          )
        ],
      ),
    );
  }
}

class _OnboardingProgressCard extends StatelessWidget {
  const _OnboardingProgressCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Complete seu cadastro", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: theme.colorScheme.onSurface)),
              const Text("20%", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24, color: AppPalette.orange500)),
            ],
          ),
          const SizedBox(height: 4),
          Text("1 de 5 etapas concluídas", style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.5), fontSize: 12)),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: 0.2,
              minHeight: 8,
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
              color: AppPalette.orange500,
            ),
          ),
        ],
      ),
    );
  }
}
