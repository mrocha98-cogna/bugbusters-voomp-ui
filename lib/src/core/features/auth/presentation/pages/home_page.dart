import 'package:flutter/material.dart';
import 'package:voomp_sellers_rebranding/src/core/features/auth/services/auth_service.dart';
import 'package:voomp_sellers_rebranding/src/core/theme/theme_controller.dart';
import 'package:voomp_sellers_rebranding/src/shared/widgets/custom_button.dart';

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
    DashboardContent(userName: _userName), // Tela 0
    const Center(child: Text("Tela de Produtos")), // Tela 1
    const SizedBox(), // Tela 2 (Botão Central)
    const Center(child: Text("Tela Financeira")), // Tela 3
    const ProfileContent(), // Tela 4: PERFIL COM TOGGLE
  ];

  void _onItemTapped(int index) {
    if (index == 2) {
      // Ação do Botão Central (Ex: Criar Produto rápido)
      // Pode abrir um Modal ou navegar para outra rota
      return;
    }
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Breakpoint simples para mobile
    final isMobile = MediaQuery.of(context).size.width < 900;
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isMobile)
            _SidebarMenu(
              selectedIndex: _selectedIndex,
              onItemSelected: _onItemTapped,
            ),
          Expanded(
            child: _pages[_selectedIndex],
          ),
        ],
      ),
      floatingActionButton: isMobile
          ? FloatingActionButton(
        onPressed: () => _onItemTapped(2),
        backgroundColor: const Color(0xFFFE8700),
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white, size: 32),
      )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: isMobile
          ? BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        color: colorScheme.surface, // Cor do tema
        surfaceTintColor: Colors.transparent, // Remove tint do Material 3
        elevation: 10,
        height: 70,
        padding: EdgeInsets.zero,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildBottomNavItem(0, Icons.home_filled),
            _buildBottomNavItem(1, Icons.inventory_2_outlined),
            const SizedBox(width: 48),
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
        color: isSelected ? const Color(0xFFFE8700) : Colors.grey,
        size: 28,
      ),
      onPressed: () => _onItemTapped(index),
    );
  }
}

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

          // Card de Configuração
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                // Toggle de Tema
                ListTile(
                  leading: Icon(
                    isDark ? Icons.dark_mode : Icons.light_mode,
                    color: const Color(0xFFFE8700),
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
                    activeColor: const Color(0xFFFE8700),
                    onChanged: (value) {
                      ThemeController.instance.toggleTheme();
                    },
                  ),
                ),
                const Divider(),
                ListTile(
                  leading: Icon(Icons.logout, color: Colors.red[400]),
                  title: Text("Sair da conta", style: TextStyle(color: Colors.red[400])),
                  onTap: () {
                    // Lógica de logout
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

          // Grid Layout
          if (isMobile)
            const Column(
              children: [
                _IdentityValidationCard(),
                SizedBox(height: 24),
                _BalanceCard(),
                SizedBox(height: 24),
                _SalesCard(),
                SizedBox(height: 24),
                _CreditCardRefusals(),
              ],
            )
          else
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: Column(
                    children: const [
                      _IdentityValidationCard(),
                      SizedBox(height: 24),
                      _SalesCard(),
                    ],
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  flex: 1,
                  child: Column(
                    children: const [
                      _BalanceCard(),
                      SizedBox(height: 24),
                      _CreditCardRefusals(),
                    ],
                  ),
                ),
              ],
            ),
          // Espaço extra no final para não ficar atrás do BottomBar no mobile
          if(isMobile) const SizedBox(height: 80),
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
      width: 80,
      color: theme.colorScheme.surface,
      child: Column(
        children: [
          const SizedBox(height: 32),
          const Icon(Icons.incomplete_circle, color: Color(0xFFFE8700), size: 32),
          const SizedBox(height: 40),

          _buildSidebarItem(context, 0, Icons.home_filled),
          _buildSidebarItem(context, 1, Icons.inventory_2_outlined),
          _buildSidebarItem(context, 2, Icons.add_circle_outline, isAction: true),
          _buildSidebarItem(context, 3, Icons.account_balance_wallet_outlined),
          _buildSidebarItem(context, 4, Icons.person_outline),

          const Spacer(),
          const Padding(
            padding: EdgeInsets.only(bottom: 24),
            child: Icon(Icons.logout, color: Colors.black54),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarItem(BuildContext context, int index, IconData icon, {bool isAction = false}) {
    final isActive = selectedIndex == index;
    final theme = Theme.of(context);
    final iconColor = isActive || isAction
        ? const Color(0xFFFE8700)
        : theme.colorScheme.onSurface.withOpacity(0.7);

    // Fundo do item ativo
    final activeBgColor = theme.brightness == Brightness.dark
        ? const Color(0xFFFE8700).withOpacity(0.2) // Laranja translúcido no escuro
        : const Color(0xFFFFF0E6); // Laranja bem claro no light
    return GestureDetector(
      onTap: () => onItemSelected(index),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        height: 48,
        width: 48,
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFFFFF0E6) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: isAction ? Border.all(color: const Color(0xFFFE8700)) : null,
        ),
        child: Icon(
          icon,
          color: isActive || isAction ? const Color(0xFFFE8700) : Colors.black87,
          size: 24,
        ),
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
      decoration: BoxDecoration(color: theme.colorScheme.surface, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cabeçalho do Card
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text("Complete seu cadastro",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Text("20%",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                      color: Color(0xFFFE8700))),
            ],
          ),
          const SizedBox(height: 4),
          const Text("1 de 5 etapas concluídas",
              style: TextStyle(color: Colors.grey, fontSize: 12)),

          const SizedBox(height: 16),
          // Barra de Progresso
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: const LinearProgressIndicator(
              value: 0.2, // 20%
              minHeight: 8,
              backgroundColor: Color(0xFFEEEEEE),
              color: Color(0xFFFE8700),
            ),
          ),
          const SizedBox(height: 32),

          // Passos (Steps)
          SingleChildScrollView(
            // Scroll horizontal para mobile
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildStepItem(
                    icon: Icons.check,
                    label: "Dados Pessoais",
                    subLabel: "Suas informações",
                    status: 'done'),
                const _StepConnector(),
                _buildStepItem(
                    icon: Icons.verified_user_outlined,
                    label: "Identidade",
                    subLabel: "Validação",
                    status: 'active'),
                const _StepConnector(),
                _buildStepItem(
                    icon: Icons.business,
                    label: "Empresa",
                    subLabel: "Dados da Empresa",
                    status: 'pending'),
                const _StepConnector(),
                _buildStepItem(
                    icon: Icons.inventory_2_outlined,
                    label: "Produto",
                    subLabel: "Primeiro Produto",
                    status: 'pending'),
                const _StepConnector(),
                _buildStepItem(
                    icon: Icons.sell_outlined,
                    label: "Primeira Venda",
                    subLabel: "Vender e Sacar",
                    status: 'pending'),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildStepItem(
      {required IconData icon,
        required String label,
        required String subLabel,
        required String status}) {
    // Status: done (verde), active (laranja + borda), pending (bege)
    Color bgColor;
    Color iconColor;
    Color textColor;
    Border? border;

    if (status == 'done') {
      bgColor = const Color(0xFFE8F5E9); // Verde claro
      iconColor = Colors.green;
      textColor = Colors.green;
    } else if (status == 'active') {
      bgColor = const Color(0xFFFFF0E6); // Laranja claro
      iconColor = Colors.black87;
      textColor = const Color(0xFFFE8700);
      border = Border.all(color: const Color(0xFFFE8700), width: 1.5);
    } else {
      bgColor = const Color(0xFFFFF3E0).withOpacity(0.5); // Bege bem claro
      iconColor = Colors.black87;
      textColor = const Color(0xFFD3A67A); // Marrom claro
    }

    return Container(
      width: 120, // Largura fixa
      height: 110,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: border,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: iconColor, size: 28),
          const SizedBox(height: 12),
          Text(label,
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 12, color: textColor)),
          const SizedBox(height: 4),
          Text(subLabel,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 10, color: Colors.grey[600])),
        ],
      ),
    );
  }
}

class _StepConnector extends StatelessWidget {
  const _StepConnector();
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 20,
      height: 2,
      color: Colors.orange.shade100,
      margin: const EdgeInsets.symmetric(horizontal: 4),
    );
  }
}

class _IdentityValidationCard extends StatelessWidget {
  const _IdentityValidationCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
          color: theme.colorScheme.surface, // COR DO TEMA
          borderRadius: BorderRadius.circular(12)),
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
                      border: Border.all(color: const Color(0xFFFE8700)),
                    ),
                    child: const Center(
                        child: Text("2", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFFFE8700)))),
                  ),
                  const SizedBox(width: 12),
                  Text("Validação de Identidade",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: theme.colorScheme.onSurface)),
                ],
              ),
              // Badge "Em andamento"
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFFFE8700).withOpacity(0.2) : const Color(0xFFFFF0E6),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text("Em andamento", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFFFE8700))),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
              "Faça a validação dos seus documentos para liberar todas as funcionalidades",
              style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.6), fontSize: 14)),
          const SizedBox(height: 24),

          // Área Interna Bege (no Light) ou Cinza (no Dark)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              // Ajuste de cor para fundo secundário
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
          SizedBox(
            width: double.infinity,
            height: 45,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFE8700),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
              child: const Text("Validar identidade"),
            ),
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
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12)),
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
                      Text("Complete seu cadastro", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: theme.colorScheme.onSurface)),
                      Text("Adicione os seus dados bancários para poder sacar", style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurface.withOpacity(0.6))),
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
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E2A45),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8))),
              child: const Text("Adicionar dados bancários",
                  style: TextStyle(color: Colors.white)),
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
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Vendas",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Container(
                decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(20)),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                          color: Colors.grey[400],
                          borderRadius: BorderRadius.circular(20)),
                      child: const Text("Hoje",
                          style: TextStyle(
                              fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: Text("30 dias",
                          style: TextStyle(fontSize: 12, color: Colors.grey)),
                    ),
                  ],
                ),
              )
            ],
          ),
          const SizedBox(height: 30),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Área Empty State
              Expanded(
                flex: 3,
                child: Column(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(12)),
                      child: const Icon(Icons.sell_outlined,
                          size: 30, color: Colors.black54),
                    ),
                    const SizedBox(height: 16),
                    const Text("Nenhuma venda ainda",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 8),
                    const Text(
                      "Crie seu primeiro produto para começar a vender e acompanhar suas vendas aqui",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        OutlinedButton(
                          onPressed: () {},
                          style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.black),
                          child: const Text("Ver tutorial"),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1E2A45)),
                          child: const Text("Criar produto +",
                              style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    )
                  ],
                ),
              ),
              // Divisor vertical
              Container(
                  height: 150,
                  width: 1,
                  color: Colors.grey[200],
                  margin: const EdgeInsets.symmetric(horizontal: 24)),
              // Resumo lateral
              Expanded(
                flex: 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text("R\$ 0,00",
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                    const Text("Vendas de hoje",
                        style: TextStyle(fontSize: 10, color: Colors.grey)),
                    const SizedBox(height: 30),
                    const Text("R\$ 0,00",
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                    const Text("Últimos 30 dias",
                        style: TextStyle(fontSize: 10, color: Colors.grey)),
                  ],
                ),
              )
            ],
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
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Recusas do cartão de crédito",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const Text("Últimos 7 dias",
              style: TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 24),
          Center(
            child: SizedBox(
              width: 120,
              height: 120,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CircularProgressIndicator(
                    value: 0.0,
                    strokeWidth: 8,
                    backgroundColor: Colors.grey[200],
                  ),
                  const Center(
                      child: Text("0%",
                          style: TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold))),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Center(
            child: Text("Crie um produto e comece a vendê-lo",
                style: TextStyle(color: Colors.grey, fontSize: 12)),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 45,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFE8700),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8))),
              child: const Text("Criar produto +",
                  style: TextStyle(color: Colors.white)),
            ),
          )
        ],
      ),
    );
  }
}