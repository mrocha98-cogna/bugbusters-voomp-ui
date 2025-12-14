import 'package:flutter/material.dart';
import 'package:voomp_sellers_rebranding/src/core/theme/app_colors.dart';

class Step4Onboarding extends StatefulWidget {
  final VoidCallback onFinish;
  const Step4Onboarding({super.key, required this.onFinish});

  @override
  State<Step4Onboarding> createState() => _Step4OnboardingState();
}

class _Step4OnboardingState extends State<Step4Onboarding> {
  String? _selectedObjective;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppPalette.success100, // Verde claro fixo para sucesso
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check, color: AppPalette.success500, size: 32),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          "Cadastro Concluído!",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface),
        ),
        const SizedBox(height: 8),
        Text(
          "Para finalizar, qual seu principal objetivo?",
          textAlign: TextAlign.center,
          style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.6)),
        ),
        const SizedBox(height: 32),

        // Opções
        _buildOptionCard("Vender meus produtos", Icons.shopping_bag_outlined),
        const SizedBox(height: 12),
        _buildOptionCard("Acompanhar vendas", Icons.bar_chart),

        const SizedBox(height: 32),
        SizedBox(
          height: 50,
          child: ElevatedButton(
            onPressed: _selectedObjective != null ? widget.onFinish : null,
            child: const Text("Acessar Plataforma"),
          ),
        ),
      ],
    );
  }

  Widget _buildOptionCard(String title, IconData icon) {
    final theme = Theme.of(context);
    final isSelected = _selectedObjective == title;

    // Cores de Seleção
    final borderColor = isSelected ? AppPalette.orange500 : theme.colorScheme.outline;
    final bgColor = isSelected
        ? (theme.brightness == Brightness.dark ? AppPalette.orange500.withOpacity(0.2) : AppPalette.orange100)
        : Colors.transparent;

    return InkWell(
      onTap: () => setState(() => _selectedObjective = title),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor, width: isSelected ? 2 : 1),
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? AppPalette.orange500 : theme.colorScheme.onSurface),
            const SizedBox(width: 16),
            Text(
              title,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? AppPalette.orange500 : theme.colorScheme.onSurface,
              ),
            ),
            const Spacer(),
            if (isSelected)
              const Icon(Icons.check_circle, color: AppPalette.orange500),
          ],
        ),
      ),
    );
  }
}
