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

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.colorScheme.onSurface),
          onPressed: () {
            // Se estiver no primeiro passo, volta pro login, senão volta pro passo anterior
            // (Essa lógica fina geralmente fica no widget pai ou gerenciador de estado,
            // aqui simplificamos voltando para a tela anterior na pilha)
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/login');
            }
          },
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Crie sua conta",
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Comece a vender em poucos minutos",
                style: TextStyle(
                    fontSize: 14,
                    color: theme.colorScheme.onSurface.withOpacity(0.6)
                ),
              ),
              const SizedBox(height: 32),

              // Container do Formulário de Cadastro
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 500), // Um pouco mais largo que o login
                child: const RegistrationFormCard(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class RegistrationFormCard extends StatefulWidget {
  const RegistrationFormCard({super.key});

  @override
  State<RegistrationFormCard> createState() => _RegistrationFormCardState();
}

class _RegistrationFormCardState extends State<RegistrationFormCard> {
  int _currentStep = 1;
  final AuthService _authService = AuthService();

  // Controllers "Lifted Up" (Estado elevado)
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _cpfController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void _nextStep() {
    setState(() => _currentStep++);
  }

  Future<void> _finishRegistration() async {
    final name = _nameController.text;
    final email = _emailController.text;
    final cpf = _cpfController.text;
    final phone = _phoneController.text;
    final password = _passwordController.text;

    await _authService.registerUser(
      name: name,
      email: email,
      password: password,
      cpf: cpf,
      phone: phone,
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Cadastro Realizado! Faça Login.'),
            backgroundColor: AppPalette.success500 // Verde
        ),
      );
      context.go('/login');
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _cpfController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
        ],
      ),
      child: Column(
        children: [
          // Indicador de Passos (Stepper customizado)
          _buildStepIndicator(context),

          const SizedBox(height: 32),

          // Renderização condicional dos passos
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: _buildCurrentStep(),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentStep() {
    // Chave única para animação funcionar
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

  Widget _buildStepIndicator(BuildContext context) {
    // Simples indicador visual (1 de 4)
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(4, (index) {
        final step = index + 1;
        final isActive = step == _currentStep;
        final isCompleted = step < _currentStep;

        Color color;
        if (isActive) {
          color = AppPalette.orange500;
        } else if (isCompleted) {
          color = AppPalette.success500;
        } else {
          color = AppPalette.neutral300;
        }

        return Container(
          width: 40,
          height: 4,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        );
      }),
    );
  }
}
