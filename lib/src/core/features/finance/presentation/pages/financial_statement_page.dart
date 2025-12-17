import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:voomp_sellers_rebranding/src/core/common/widgets/max_width_container.dart';
import 'package:voomp_sellers_rebranding/src/core/theme/app_colors.dart'; // Ajuste o import conforme seu projeto

// --- MODELO DE DADOS MOCK (Para visualização) ---
class Transaction {
  final String date;
  final String type; // 'Vendas', 'Saques', etc.
  final String id;
  final String product;
  final double value;
  final String availableDate;

  Transaction({
    required this.date,
    required this.type,
    required this.id,
    required this.product,
    required this.value,
    required this.availableDate,
  });
}

class FinancialStatementPage extends StatefulWidget {
  const FinancialStatementPage({super.key});

  @override
  State<FinancialStatementPage> createState() => _FinancialStatementPageState();
}

class _FinancialStatementPageState extends State<FinancialStatementPage> {
  int _selectedTabIndex = 0; // 0: Transações, 1: Saques

  // Dados Mockados
  final List<Transaction> _transactions = [
    Transaction(date: '15/12/25', type: 'Vendas', id: '1234567', product: 'Curso de Gato', value: 200.00, availableDate: '15/12/25'),
    Transaction(date: '15/12/25', type: 'Saques', id: '1234567', product: 'Curso de Gato', value: 1000.00, availableDate: '15/12/25'),
    Transaction(date: '14/12/25', type: 'Vendas', id: '9876543', product: 'Mentoria VIP', value: 500.00, availableDate: '14/01/26'),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Breakpoint para layout
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor, // Ou Colors.grey[50]
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: MaxWidthContainer(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Botão Voltar
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: () => context.go('/home'),
                    icon: const Icon(Icons.arrow_back, size: 16, color: AppPalette.orange500),
                    label: const Text("Voltar", style: TextStyle(color: AppPalette.orange500, fontWeight: FontWeight.bold)),
                    style: TextButton.styleFrom(padding: EdgeInsets.zero, alignment: Alignment.centerLeft),
                  ),
                ),
                const SizedBox(height: 16),

                // 2. Card Principal (Saldo)
                const _MainBalanceCard(),

                const SizedBox(height: 24),

                // 3. Cards de Resumo (Carteira, Mês, A Liberar)
                const _SummaryCardsSection(),

                const SizedBox(height: 32),

                // 4. Abas (Transações / Saques)
                Row(
                  children: [
                    _buildTabItem("Transações", 0),
                    const SizedBox(width: 24),
                    _buildTabItem("Saques", 1),
                  ],
                ),
                const Divider(height: 1, color: AppPalette.neutral300),

                const SizedBox(height: 24),

                // 5. Filtros
                const _FiltersSection(),

                const SizedBox(height: 24),

                // 6. Tabela de Dados (Responsiva)
                _TransactionList(transactions: _transactions),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabItem(String label, int index) {
    final isSelected = _selectedTabIndex == index;
    return InkWell(
      onTap: () => setState(() => _selectedTabIndex = index),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          border: isSelected
              ? const Border(bottom: BorderSide(color: AppPalette.orange500, width: 2))
              : null,
        ),
        child: Row(
          children: [
            if (index == 0) ...[
              Icon(Icons.swap_horiz, size: 18, color: isSelected ? AppPalette.orange500 : Colors.grey),
              const SizedBox(width: 8),
            ] else ...[
              Icon(Icons.attach_money, size: 18, color: isSelected ? AppPalette.orange500 : Colors.grey),
              const SizedBox(width: 8),
            ],
            Text(
              label,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? AppPalette.orange500 : Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MainBalanceCard extends StatelessWidget {
  const _MainBalanceCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 700;

        return Container(
          width: double.infinity,
          decoration: BoxDecoration(
            // MUDANÇA: Cor de fundo dinâmica
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(isDark ? 0.3 : 0.05), // Sombra mais sutil no dark
                  blurRadius: 10,
                  offset: const Offset(0, 4)
              )
            ],
          ),
          child: IntrinsicHeight(
            child: Row(
              children: [
                Container(
                  width: 6,
                  decoration: const BoxDecoration(
                    color: AppPalette.orange500,
                    borderRadius: BorderRadius.only(topLeft: Radius.circular(12), bottomLeft: Radius.circular(12)),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: isMobile
                        ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeaderSection(theme, isDark), // Passando tema
                        const SizedBox(height: 24),
                        const Divider(),
                        const SizedBox(height: 24),
                        _buildValueSection(CrossAxisAlignment.start, theme), // Passando tema
                      ],
                    )
                        : Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildHeaderSection(theme, isDark),
                        _buildValueSection(CrossAxisAlignment.end, theme),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeaderSection(ThemeData theme, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
            "Extrato Financeiro",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface, // Texto dinâmico
            )
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            // MUDANÇA: Fundo laranja adaptado para dark mode (mais escuro/transparente)
              color: isDark
                  ? AppPalette.orange500.withOpacity(0.2)
                  : const Color(0xFFFFF3E0),
              borderRadius: BorderRadius.circular(20)
          ),
          child: const Text(
              "Preço Único",
              style: TextStyle(
                  color: AppPalette.orange500,
                  fontWeight: FontWeight.bold,
                  fontSize: 12
              )
          ),
        ),
        const SizedBox(height: 24),
        // ... botão Realizar Saque mantém igual pois usa AppPalette.orange500 e branco
        ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: AppPalette.orange500,
            foregroundColor: Colors.white, // Mantém branco no botão sólido
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          ),
          child: const Text("Realizar Saque", style: TextStyle(fontWeight: FontWeight.bold)),
        )
      ],
    );
  }

  Widget _buildValueSection(CrossAxisAlignment alignment, ThemeData theme) {
    return Column(
      crossAxisAlignment: alignment,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
            "Valor disponível para saque",
            style: TextStyle(
                color: theme.colorScheme.onSurface.withOpacity(0.6), // Texto secundário dinâmico
                fontSize: 14
            )
        ),
        const SizedBox(height: 8),
        Text(
            "R\$ 200,00",
            style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface // Texto principal dinâmico
            )
        ),
        const SizedBox(height: 8),
        Text(
            "Referente ao período de 01/01/25 a 16/12/25",
            style: TextStyle(
                color: theme.colorScheme.onSurface.withOpacity(0.5), // Texto terciário dinâmico
                fontSize: 12
            )
        ),
      ],
    );
  }
}

class _SummaryCardsSection extends StatelessWidget {
  const _SummaryCardsSection();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final cards = [
      _buildCard(Icons.attach_money, "Minha Carteira", "R\$ 200,00", theme, isDark),
      _buildCard(Icons.show_chart, "Esse mês", "R\$ 200,00", theme, isDark),
      _buildCard(Icons.account_balance_wallet_outlined, "Saldo à liberar", "R\$ 0,00", theme, isDark),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 900;

        if (isMobile) {
          return Column(
            children: [
              cards[0], const SizedBox(height: 16),
              cards[1], const SizedBox(height: 16),
              cards[2],
            ],
          );
        }

        return Row(
          children: [
            Expanded(child: cards[0]),
            const SizedBox(width: 24),
            Expanded(child: cards[1]),
            const SizedBox(width: 24),
            Expanded(child: cards[2]),
          ],
        );
      },
    );
  }

  Widget _buildCard(IconData icon, String label, String value, ThemeData theme, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardColor, // Fundo do card
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          // Borda sutil no dark mode
            color: isDark ? Colors.white10 : Colors.grey[200]!
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  // Fundo do ícone adaptado
                    color: isDark
                        ? AppPalette.orange500.withOpacity(0.2)
                        : const Color(0xFFFFF3E0),
                    borderRadius: BorderRadius.circular(8)
                ),
                child: Icon(icon, color: AppPalette.orange500, size: 20),
              ),
              const SizedBox(height: 16),
              Text(
                  label,
                  style: TextStyle(
                      color: theme.colorScheme.onSurface.withOpacity(0.6), // Texto secundário
                      fontSize: 13
                  )
              ),
            ],
          ),
          Text(
              value,
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface // Texto principal
              )
          ),
        ],
      ),
    );
  }
}

class _FiltersSection extends StatelessWidget {
  const _FiltersSection();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final borderColor = isDark ? Colors.white24 : Colors.grey[300]!;
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 800;

        final filterLabel = Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                  color: isDark ? Colors.white10 : Colors.grey[200], // Fundo do ícone filtro
                  borderRadius: BorderRadius.circular(4)
              ),
              child: Icon(
                  Icons.filter_alt_outlined,
                  size: 16,
                  color: theme.colorScheme.onSurface // Ícone dinâmico
              ),
            ),
            const SizedBox(width: 8),
            Text(
                "Filtro",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface
                )
            ),
          ],
        );

        final dropdown = Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
              border: Border.all(color: borderColor),
              borderRadius: BorderRadius.circular(8)
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: "Todos",
              isExpanded: true,
              dropdownColor: theme.cardColor, // Fundo do menu dropdown
              style: TextStyle(color: theme.colorScheme.onSurface), // Texto do item
              items: [
                DropdownMenuItem(
                    value: "Todos",
                    child: Text(
                        "Todos os tipos de transação",
                        style: TextStyle(color: theme.colorScheme.onSurface)
                    )
                )
              ],
              onChanged: (_) {},
            ),
          ),
        );

        final datePicker = OutlinedButton.icon(
          onPressed: () {},
          icon: Icon(Icons.calendar_today, size: 16, color: theme.colorScheme.onSurface),
          label: Text("Escolher Período", style: TextStyle(color: theme.colorScheme.onSurface)),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
            side: BorderSide(color: isDark ? Colors.white24 : AppPalette.surfaceText.withOpacity(0.5)),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );

        final searchBar = TextField(
          style: TextStyle(color: theme.colorScheme.onSurface), // Cor do texto digitado
          decoration: InputDecoration(
            hintText: "Buscar por produto ou ID",
            hintStyle: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.5)),
            prefixIcon: Icon(Icons.search, color: theme.colorScheme.onSurface.withOpacity(0.6)),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: borderColor)
            ),
            enabledBorder: OutlineInputBorder( // Borda quando não focado
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: borderColor)
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
          ),
        );

        if (isMobile) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              filterLabel,
              const SizedBox(height: 16),
              dropdown,
              const SizedBox(height: 12),
              SizedBox(width: double.infinity, child: datePicker),
              const SizedBox(height: 12),
              searchBar,
            ],
          );
        }

        return Row(
          children: [
            filterLabel,
            const SizedBox(width: 24),
            Expanded(flex: 2, child: dropdown),
            const SizedBox(width: 16),
            Expanded(flex: 1, child: datePicker),
            const SizedBox(width: 16),
            Expanded(flex: 2, child: searchBar),
          ],
        );
      },
    );
  }
}

class _TransactionList extends StatelessWidget {
  final List<Transaction> transactions;

  const _TransactionList({required this.transactions});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final borderColor = isDark ? Colors.white10 : Colors.grey[200]!;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 800;

        if (isMobile) {
          // --- MOBILE: CARDS ---
          return Column(
            children: transactions.map((t) => _buildMobileCard(t, theme, borderColor)).toList(),
          );
        } else {
          // --- DESKTOP: TABELA ---
          return Container(
            decoration: BoxDecoration(
              color: theme.cardColor, // Fundo da tabela
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: borderColor),
            ),
            child: Column(
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                  decoration: BoxDecoration(
                    // Fundo do Header da Tabela
                    color: isDark
                        ? Colors.white.withOpacity(0.05)
                        : const Color(0xFFFFF7F0),
                    borderRadius: const BorderRadius.only(topLeft: Radius.circular(8), topRight: Radius.circular(8)),
                  ),
                  child: Row(
                    children: [
                      // Textos do header devem usar onSurface
                      Expanded(flex: 1, child: Text("Data de pgto", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: theme.colorScheme.onSurface))),
                      Expanded(flex: 2, child: Text("Tipo de transação", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: theme.colorScheme.onSurface))),
                      // ... aplique color: theme.colorScheme.onSurface em todos os Textos do header
                    ],
                  ),
                ),
                // Rows
                ...transactions.map((t) => _buildDesktopRow(t, theme, borderColor)).toList(),
              ],
            ),
          );
        }
      },
    );
  }

  Widget _buildDesktopRow(Transaction t, ThemeData theme, Color borderColor) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: borderColor)),
      ),
      child: Row(
        children: [
          // Textos das linhas
          Expanded(flex: 1, child: Text(t.date, style: TextStyle(fontSize: 13, color: theme.colorScheme.onSurface))),
          Expanded(flex: 2, child: Align(alignment: Alignment.centerLeft, child: _StatusBadge(type: t.type))),
          Expanded(flex: 1, child: Text(t.id, style: TextStyle(fontSize: 13, color: theme.colorScheme.onSurface))),
          // ... Repita color: theme.colorScheme.onSurface para os outros textos
        ],
      ),
    );
  }

  Widget _buildMobileCard(Transaction t, ThemeData theme, Color borderColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ... use theme.colorScheme.onSurface e onSurface.withOpacity(0.6) para os textos aqui também
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String type;
  const _StatusBadge({required this.type});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Color bg;
    Color text;

    if (type == 'Vendas') {
      // Ajuste para Dark Mode: fundo mais transparente, texto mais claro
      bg = isDark ? const Color(0xFF1B5E20) : const Color(0xFFE8F5E9);
      text = isDark ? const Color(0xFFA5D6A7) : const Color(0xFF2E7D32);
    } else {
      bg = isDark ? const Color(0xFF4A148C) : const Color(0xFFF3E5F5);
      text = isDark ? const Color(0xFFCE93D8) : const Color(0xFF7B1FA2);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        type,
        style: TextStyle(color: text, fontWeight: FontWeight.bold, fontSize: 11),
      ),
    );
  }
}