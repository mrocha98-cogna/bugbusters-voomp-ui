import 'package:flutter/material.dart';
import 'package:voomp_sellers_rebranding/src/core/common/widgets/max_width_container.dart';
import 'package:voomp_sellers_rebranding/src/core/theme/app_colors.dart';

class OverviewDashboardPage extends StatelessWidget {
  final String userName;

  const OverviewDashboardPage({super.key, required this.userName});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final isDesktop = MediaQuery.of(context).size.width >= 1000;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: MaxWidthContainer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Header
            Text(
              "Olá, $userName",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Estamos muito felizes de te receber aqui. Te desejamos boas vendas!",
              style: TextStyle(
                fontSize: 14,
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 24),

            // 2. Banner (Placeholder Cinza)
            Container(
              height: 150,
              width: double.infinity,
              decoration: BoxDecoration(
                color: isDark ? Colors.white10 : Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            const SizedBox(height: 24),

            // 3. Cards de Métricas (Top Row)
            _MetricsRow(isDesktop: isDesktop),

            const SizedBox(height: 24),

            // 4. Área Principal (Gráfico e Saldo)
            if (isDesktop)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Expanded(flex: 3, child: _SalesFunnelCard()),
                  SizedBox(width: 24),
                  Expanded(flex: 2, child: _BalanceOverviewCard()),
                ],
              )
            else ...[
              const _SalesFunnelCard(),
              const SizedBox(height: 24),
              const _BalanceOverviewCard(),
            ],

            const SizedBox(height: 24),

            // 5. Área Inferior (Suporte e Meios de Pagamento)
            if (isDesktop)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Expanded(flex: 3, child: _SupportInfoCard()),
                  SizedBox(width: 24),
                  Expanded(flex: 2, child: _PaymentMethodsCard()),
                ],
              )
            else ...[
              const _SupportInfoCard(),
              const SizedBox(height: 24),
              const _PaymentMethodsCard(),
            ],
          ],
        ),
      ),
    );
  }
}

class _MetricsRow extends StatelessWidget {
  final bool isDesktop;

  const _MetricsRow({required this.isDesktop});

  @override
  Widget build(BuildContext context) {
    // Dados Mockados
    final metrics = [
      _MetricData(icon: Icons.local_offer_outlined, label: "Vendas", value: "1", color: AppPalette.orange500),
      _MetricData(icon: Icons.attach_money, label: "Receita", value: "R\$ 200,00", color: AppPalette.orange500),
      _MetricData(icon: Icons.inventory_2_outlined, label: "Produtos", value: "1", color: AppPalette.orange500),
    ];

    if (isDesktop) {
      return Row(
        children: metrics.map((m) => Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0), // Espaçamento entre cards
            child: _MetricCard(data: m),
          ),
        )).toList(),
      );
    } else {
      // No mobile, empilha ou usa Grid (aqui vou empilhar com espaçamento)
      return Column(
        children: metrics.map((m) => Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: _MetricCard(data: m),
        )).toList(),
      );
    }
  }
}

class _MetricCard extends StatelessWidget {
  final _MetricData data;
  const _MetricCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? Colors.white10 : Colors.grey[200]!),
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
                  color: isDark ? data.color.withOpacity(0.2) : const Color(0xFFFFF3E0),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(data.icon, color: data.color, size: 20),
              ),
              const SizedBox(height: 16),
              Text(data.label, style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.6), fontSize: 13)),
            ],
          ),
          Text(data.value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface)),
        ],
      ),
    );
  }
}

class _MetricData {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  _MetricData({required this.icon, required this.label, required this.value, required this.color});
}

class _SalesFunnelCard extends StatelessWidget {
  const _SalesFunnelCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? Colors.white10 : Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Vendas", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface)),
              Icon(Icons.sell_outlined, color: theme.colorScheme.onSurface.withOpacity(0.5)),
            ],
          ),
          const SizedBox(height: 24),

          // Gráfico Simulado (Placeholder visual)
          SizedBox(
            height: 160,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _buildFunnelBar("40 Visitas", Colors.blue[100]!, Colors.blue, 0.4, theme),
                const SizedBox(width: 4),
                _buildFunnelBar("10 Leads", const Color(0xFF1565C0), const Color(0xFF0D47A1), 0.25, theme), // Azul escuro
                const SizedBox(width: 4),
                _buildFunnelBar("1 Venda", Colors.greenAccent[100]!, Colors.green, 0.15, theme),
                const SizedBox(width: 16),

                // Legenda Lateral
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Flexible(child: _buildLegendItem("2,5% de taxa de conversão no Funil", theme)),
                      const SizedBox(height: 8),
                      Flexible(child: _buildLegendItem("25% dos visitantes se tornam Leads", theme)),
                      const SizedBox(height: 8),
                      Flexible(child: _buildLegendItem("10% dos Leads se tornam Vendas", theme)),
                    ],
                  ),
                )
              ],
            ),
          ),

          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 16),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildBottomValue("R\$ 200,00", "Vendas de hoje", theme),
              _buildBottomValue("R\$ 200,00", "Últimos 30 dias", theme),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildFunnelBar(String label, Color color, Color textColor, double heightFactor, ThemeData theme) {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            height: 80 * (heightFactor * 3), // Altura proporcional simulada
            decoration: BoxDecoration(
              color: color,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(4)), // Curva leve no topo
            ),
          ),
          const SizedBox(height: 8),
          Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface), textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String text, ThemeData theme) {
    return Text(
      text,
      style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurface.withOpacity(0.7)),
    );
  }

  Widget _buildBottomValue(String value, String label, ThemeData theme) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface)),
        Text(label, style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurface.withOpacity(0.5))),
      ],
    );
  }
}

class _BalanceOverviewCard extends StatelessWidget {
  const _BalanceOverviewCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? Colors.white10 : Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Meu Saldo", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface)),
              Icon(Icons.account_balance_wallet_outlined, color: theme.colorScheme.onSurface.withOpacity(0.5)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("R\$ 195,00", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface)),
              Icon(Icons.visibility_off_outlined, size: 20, color: theme.colorScheme.onSurface.withOpacity(0.4)),
            ],
          ),
          const SizedBox(height: 24),

          // Aviso de Cadastro
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[800] : Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.shield_outlined, size: 20, color: theme.colorScheme.onSurface.withOpacity(0.6)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Complete seu cadastro", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: theme.colorScheme.onSurface)),
                      const SizedBox(height: 4),
                      Text("Adicione os seus dados bancários para poder sacar", style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurface.withOpacity(0.6))),
                    ],
                  ),
                )
              ],
            ),
          ),
          const SizedBox(height: 16),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0D1B2A), // Azul escuro quase preto
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text("Adicionar dados bancários"),
            ),
          )
        ],
      ),
    );
  }
}

class _SupportInfoCard extends StatelessWidget {
  const _SupportInfoCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final supportItems = [
      _SupportItem(icon: Icons.cancel_presentation, title: "Pagamento recusado no checkout", time: "Hoje às 16:00 | Ana Paula Santos", tag: "Erro no checkout"),
      _SupportItem(icon: Icons.replay, title: "Reembolso não recebido após cancelamento", time: "11/12/25 | Carlos Eduardo Lima", tag: "Reembolso"),
      _SupportItem(icon: Icons.not_interested, title: "Conteúdo prometido não está disponível", time: "10/12/25 | Mariana Rocha", tag: "Conteúdo"),
      _SupportItem(icon: Icons.block, title: "Conta bloqueada sem aviso prévio", time: "Hoje às 16:00 | Felipe Andrade", tag: "Conta"),
    ];

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? Colors.white10 : Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Informações de Suporte", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface)),
          const SizedBox(height: 24),

          Column(
            children: supportItems.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              // CORREÇÃO: Usamos um LayoutBuilder ou simplesmente ajustamos a Row para lidar com o overflow
              child: IntrinsicHeight( // Ajuda no alinhamento vertical
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Ícone
                    Container(
                      padding: const EdgeInsets.all(10), // Aumentei um pouco o padding visual
                      decoration: BoxDecoration(
                        color: AppPalette.orange500.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.support_agent, color: Colors.black87, size: 24),
                    ),
                    const SizedBox(width: 12),

                    // Texto Central + Botão
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Título e Botão na mesma "linha lógica", mas com Wrap para quebrar se necessário
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Título flexível
                              Expanded(
                                child: Text(
                                    item.title,
                                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: theme.colorScheme.onSurface),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis
                                ),
                              ),
                              // Botão Ver detalhes (agora não empurra para fora)
                              const SizedBox(width: 8),
                              TextButton(
                                onPressed: () {},
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  minimumSize: const Size(50, 20),
                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  alignment: Alignment.topRight,
                                ),
                                child: const Text("Ver detalhes", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppPalette.orange500)),
                              )
                            ],
                          ),

                          const SizedBox(height: 4),

                          // Informações de hora e Tag
                          Wrap( // Wrap ajuda se a tag for muito longa ou tela muito pequena
                            crossAxisAlignment: WrapCrossAlignment.center,
                            spacing: 8, // Espaço horizontal
                            runSpacing: 4, // Espaço vertical se quebrar linha
                            children: [
                              Text(item.time, style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurface.withOpacity(0.5))),

                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: isDark ? Colors.white10 : Colors.grey[200],
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(item.tag, style: TextStyle(fontSize: 9, color: theme.colorScheme.onSurface.withOpacity(0.7))),
                              )
                            ],
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            )).toList(),
          )
        ],
      ),
    );
  }
}

class _SupportItem {
  final IconData icon;
  final String title;
  final String time;
  final String tag;
  _SupportItem({required this.icon, required this.title, required this.time, required this.tag});
}

class _PaymentMethodsCard extends StatelessWidget {
  const _PaymentMethodsCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final methods = [
      _PaymentMethod(icon: Icons.qr_code, label: "Boleto", percent: "100%", isHighlighted: true),
      _PaymentMethod(icon: Icons.credit_card, label: "Crédito", percent: "0%", isHighlighted: false),
      _PaymentMethod(icon: Icons.credit_card_outlined, label: "Débito", percent: "0%", isHighlighted: false),
      _PaymentMethod(icon: Icons.pix, label: "Pix", percent: "0%", isHighlighted: false),
    ];

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? Colors.white10 : Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Meios de Pagamento", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface)),
          Text("Últimos 7 dias", style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurface.withOpacity(0.5))),
          const SizedBox(height: 24),

          Column(
            children: methods.map((m) => Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: m.isHighlighted
                    ? AppPalette.orange500.withOpacity(0.1)
                    : Colors.transparent, // Highlight amarelo/laranja
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(m.icon, size: 18, color: theme.colorScheme.onSurface.withOpacity(0.7)),
                  const SizedBox(width: 12),
                  Text(m.label, style: TextStyle(color: theme.colorScheme.onSurface)),
                  const Spacer(),
                  Text(m.percent, style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface)),
                ],
              ),
            )).toList(),
          ),

          const SizedBox(height: 16),
          Center(
            child: TextButton(
              onPressed: () {},
              child: const Text("Ver mais informações", style: TextStyle(fontSize: 12, color: AppPalette.orange500)),
            ),
          )
        ],
      ),
    );
  }
}

class _PaymentMethod {
  final IconData icon;
  final String label;
  final String percent;
  final bool isHighlighted;
  _PaymentMethod({required this.icon, required this.label, required this.percent, required this.isHighlighted});
}
