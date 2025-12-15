import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:voomp_sellers_rebranding/src/core/features/auth/presentation/widgets/step1_form.dart';
import 'package:voomp_sellers_rebranding/src/core/features/auth/presentation/widgets/step2_verification.dart';
import 'package:voomp_sellers_rebranding/src/core/features/auth/presentation/widgets/step3_final_data.dart';
import 'package:voomp_sellers_rebranding/src/core/features/auth/presentation/widgets/step4_onboarding.dart';
import 'package:voomp_sellers_rebranding/src/core/features/auth/services/auth_service.dart';
import 'package:voomp_sellers_rebranding/src/core/theme/app_colors.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isMobile = MediaQuery.of(context).size.width < 900;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor, // Fundo neutro
      body: Row(
        children: [
          // 1. COLUNA DO FORMULÁRIO (ESQUERDA - Ordem trocada conforme pedido)
          Expanded(
            flex: 1,
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Link para voltar ao Login (Mobile ou Desktop)
                    Align(
                      alignment: Alignment.topLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 24, left: 16),
                        child: TextButton.icon(
                          onPressed: () => context.go('/login'),
                          icon: const Icon(Icons.arrow_back, size: 16),
                          label: const Text("Voltar para login"),
                          style: TextButton.styleFrom(
                            foregroundColor: theme.colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                      ),
                    ),

                    // O Card do Formulário
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 480),
                      child: const RegistrationFormCard(),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 2. COLUNA DA IMAGEM (DIREITA - Apenas Desktop)
          if (!isMobile)
            Expanded(
              flex: 1,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Imagem de fundo
                  Image.asset(
                    'assets/capa.png',
                    fit: BoxFit.cover,
                    errorBuilder: (c, o, s) => Container(
                      color: AppPalette.neutral200,
                      child: const Center(child: Icon(Icons.image, size: 80, color: Colors.grey)),
                    ),
                  ),
                  // Máscara opcional para escurecer levemente e destacar o logo se necessário
                  Container(
                    color: Colors.black.withOpacity(0.1),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

// O Card Branco que flutua na tela
class RegistrationFormCard extends StatefulWidget {
  const RegistrationFormCard({super.key});

  @override
  State<RegistrationFormCard> createState() => _RegistrationFormCardState();
}

class _RegistrationFormCardState extends State<RegistrationFormCard> {
  int _currentStep = 1;
  final int _totalSteps = 4;
  final AuthService _authService = AuthService();

  // Controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _cpfController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void _nextStep() => setState(() => _currentStep++);

  Future<void> _finishRegistration() async {
    // Lógica final de cadastro...
    context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(40), // Espaçamento interno generoso como no design
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 24,
              offset: const Offset(0, 12),
            ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 1. Logo Pequeno no Topo
          Image.asset('assets/logo.png', color: AppPalette.blue900, height: 32, width: 32),
          const SizedBox(height: 24),

          // 2. Títulos
          Text(
            "Cadastre sua conta agora",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Comece já a empreender",
            style: TextStyle(
              fontSize: 14,
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 24),

          // 3. Barra de Progresso Visual (Estilo do Print)
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: _currentStep / _totalSteps,
                    minHeight: 6,
                    backgroundColor: AppPalette.neutral200,
                    color: AppPalette.neutral400, // Cinza escuro como na imagem ou Laranja se preferir
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                "$_currentStep/$_totalSteps",
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 32),

          // 4. Conteúdo do Passo Atual
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: _buildCurrentStep(),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentStep() {
    switch (_currentStep) {
      case 1:
        return Step1Form(
          key: const ValueKey(1),
          nameController: _nameController,
          emailController: _emailController,
          onContinue: _nextStep,
        );
      case 2:
        return Step2Verification(
          key: const ValueKey(2),
          email: _emailController.text,
          onContinue: _nextStep,
        );
      case 3:
        return Step3FinalData(
          key: const ValueKey(3),
          cpfController: _cpfController,
          phoneController: _phoneController,
          passwordController: _passwordController,
          onFinish: _nextStep,
        );
      case 4:
        return Step4Onboarding(
          key: const ValueKey(4),
          onFinish: _finishRegistration,
        );
      default:
        return const SizedBox.shrink();
    }
  }
}
