import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:voomp_sellers_rebranding/src/core/common/widgets/max_width_container.dart';
import 'package:voomp_sellers_rebranding/src/core/database/database_helper.dart';
import 'package:voomp_sellers_rebranding/src/core/features/dashboard/data/repositories/sales_repository.dart';
import 'package:voomp_sellers_rebranding/src/core/features/model/PendingSteps.dart';
import 'package:voomp_sellers_rebranding/src/core/features/model/SalesStatistics.dart';
import 'package:voomp_sellers_rebranding/src/core/features/model/user.dart';
import 'package:voomp_sellers_rebranding/src/core/features/products/data/repositories/product_repository.dart';
import 'package:voomp_sellers_rebranding/src/core/features/settings/data/repositories/settings_repository.dart';
import 'package:voomp_sellers_rebranding/src/core/network/api_endpoints.dart';
import 'package:voomp_sellers_rebranding/src/core/network/voomp_api_client.dart';
import 'package:voomp_sellers_rebranding/src/core/theme/app_colors.dart';
import 'package:http/http.dart' as http;

class OverviewDashboardPage extends StatefulWidget {
  const OverviewDashboardPage({super.key});

  @override
  State<OverviewDashboardPage> createState() => _OverviewDashboardPageState();
}

class _OverviewDashboardPageState extends State<OverviewDashboardPage> {
  late User _user;
  late PendingSteps _userPendingSteps;
  late double _salesRevenue;
  late double _salesTotal;
  late SalesStatistics _salesStatistics;
  late int _totalProducts;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUser();
    _fetchData();
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

    final SettingsRepository _settingsRepository = SettingsRepository(); // Instancia o repositório
    _userPendingSteps = await _settingsRepository.getUserPendingSteps();
    _userPendingSteps.hasWhatsappNotification = await _settingsRepository.getWhatsappUserStatus();

    if (mounted) {
      setState(() {
        _user = extra;
      });
    }
  }

  void _fetchData() async{
    final SettingsRepository _settingsRepository = SettingsRepository();
    _userPendingSteps = await _settingsRepository.getUserPendingSteps();
    _userPendingSteps.hasWhatsappNotification = await _settingsRepository.getWhatsappUserStatus();

    final SalesRepository _salesRepository = SalesRepository();
    _salesRevenue = await _salesRepository.getSalesRevenue();
    _salesTotal = await _salesRepository.getSalesTotal();
    _salesStatistics = await _salesRepository.getSalesStatistics();

    final voompClient = VoompApiClient(
        client: http.Client(),
        baseUrl: ApiEndpoints.apiVoompBaseUrl
    );
    final ProductRepository _productRepository = ProductRepository(voompClient);
    _totalProducts = await _productRepository.getTotalProducts();

    if (mounted) {
      setState(() {
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

    final isDesktop = MediaQuery.of(context).size.width >= 1000;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: MaxWidthContainer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Stack(
                children: [
                  Image.asset(
                    'assets/capa_overview.png',
                    height: 350,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            if(!_userPendingSteps.hasWhatsappNotification)
              const _WhatsAppNotificationCard(),

            const SizedBox(height: 24),

            _MetricsRow(
                isDesktop: isDesktop,
              salesTotal: _salesTotal,
              salesRevenue: _salesRevenue,
              totalProducts: _totalProducts,
            ),

            const SizedBox(height: 24),

            // 4. Área Principal (Gráfico e Saldo)
            if (isDesktop)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 3, child: _SalesFunnelCard(salesStatistics: _salesStatistics)),
                  SizedBox(width: 24),
                  Expanded(flex: 2, child: _BalanceOverviewCard()),
                ],
              )
            else ...[
              _SalesFunnelCard(salesStatistics: _salesStatistics),
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
                  final SettingsRepository _settingsRepository = SettingsRepository(); // Instancia o repositório
                  final whatsappLink = await _settingsRepository.getWhatsappLink();
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

class _MetricsRow extends StatelessWidget {
  final bool isDesktop;
  final double salesTotal;
  final double salesRevenue;
  final int totalProducts;

  const _MetricsRow({
    required this.isDesktop,
    required this.salesTotal,
    required this.salesRevenue,
    required this.totalProducts,
  });

  @override
  Widget build(BuildContext context) {
    final metrics = [
      _MetricData(icon: Icons.local_offer_outlined, label: "Vendas", value: salesTotal.toString(), color: AppPalette.orange500),
      _MetricData(icon: Icons.attach_money, label: "Receita", value: "R\$ $salesRevenue", color: AppPalette.orange500),
      _MetricData(icon: Icons.inventory_2_outlined, label: "Produtos", value: totalProducts.toString(), color: AppPalette.orange500),
    ];

    if (isDesktop) {
      return Row(
        children: metrics.map((m) => Expanded(
          child: Padding(
            padding: EdgeInsets.fromLTRB(metrics.indexOf(m) == 0 ? 0 : 16,0,0,0), // Espaçamento entre cards
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
  final SalesStatistics salesStatistics;
  const _SalesFunnelCard({required this.salesStatistics});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    var SalesStatistics(:todayRevenue, :last30DaysRevenue, :salesFunnel) = salesStatistics;
    var SalesFunnel(:totalSales, :totalLeads, :totalVisits, :conversionMetrics) = salesFunnel;
    var ConversionMetrics(:visitsToLeads, :leadsToSales, :overallConversion) = conversionMetrics;


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
                _buildFunnelBar("$totalVisits", Colors.blue[100]!, Colors.blue, (visitsToLeads / 100), theme),
                const SizedBox(width: 4),
                _buildFunnelBar("$totalLeads", const Color(0xFF1565C0), const Color(0xFF0D47A1), (leadsToSales / 100), theme), // Azul escuro
                const SizedBox(width: 4),
                _buildFunnelBar("$totalSales", Colors.greenAccent[100]!, Colors.green, (overallConversion / 100), theme),
                const SizedBox(width: 16),

                // Legenda Lateral
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Flexible(child: _buildLegendItem("$overallConversion% de taxa de conversão no Funil", theme)),
                      const SizedBox(height: 8),
                      Flexible(child: _buildLegendItem("$visitsToLeads% dos visitantes se tornam Leads", theme)),
                      const SizedBox(height: 8),
                      Flexible(child: _buildLegendItem("$leadsToSales% dos Leads se tornam Vendas", theme)),
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
              _buildBottomValue("R\$ $todayRevenue", "Vendas de hoje", theme),
              _buildBottomValue("R\$ $last30DaysRevenue", "Últimos 30 dias", theme),
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
      height: 380,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? Colors.white10 : Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        spacing: 15,
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
      height: 385,
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
