import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:voomp_sellers_rebranding/src/core/features/auth/presentation/widgets/step1_form.dart';
import 'package:voomp_sellers_rebranding/src/core/features/auth/presentation/widgets/step2_verification.dart';
import 'package:voomp_sellers_rebranding/src/core/features/auth/presentation/widgets/step3_final_data.dart';
import 'package:voomp_sellers_rebranding/src/core/features/auth/presentation/widgets/step4_onboarding.dart';
import 'package:voomp_sellers_rebranding/src/core/features/auth/services/auth_service.dart';
import 'package:voomp_sellers_rebranding/src/core/features/model/user.dart';
import 'package:voomp_sellers_rebranding/src/core/theme/app_colors.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isMobile = MediaQuery.of(context).size.width < 900;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      // Estrutura de Stack idêntica ao Login: Imagem Fundo + Overlay + Conteúdo
      body: Stack(
        children: [
          // 1. IMAGEM DE FUNDO (Ocupa toda a tela, cortada corretamente)
          Positioned.fill(
            child: Image.asset(
              'assets/capa.png',
              fit: BoxFit.cover, // Garante que preencha tudo (Crop)
              alignment: Alignment.center, // Centraliza o corte
              errorBuilder: (c, o, s) => Container(
                color: AppPalette.neutral200,
                child: const Center(
                    child: Icon(Icons.image, size: 80, color: Colors.grey)),
              ),
            ),
          ),

          // 3. CONTEÚDO (Formulário)
          Align(
            // No mobile centraliza, no Desktop alinha à esquerda (conforme padrão login)
            alignment: isMobile ? Alignment.center : Alignment.centerLeft,
            child: SizedBox(
              width: isMobile ? double.infinity : 600,
              height: double.infinity,
              child: Center(
                child: SingleChildScrollView(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                  child: Column(
                    children: [
                      Align(
                        alignment: AlignmentGeometry.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 64, left: 0),
                          child: TextButton.icon(
                            onPressed: () => context.go('/login'),
                            icon: const Icon(Icons.arrow_back,
                                size: 16, color: AppPalette.surfaceText),
                            label: const Text(
                              "Voltar para login",
                              style: TextStyle(color: AppPalette.surfaceText),
                            ),
                            style: TextButton.styleFrom(
                              // Fundo leve para garantir leitura sobre a imagem se necessário
                              backgroundColor: AppPalette.orange500,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
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
          ),
        ],
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
  bool _isGeneratingCode = false;
  final int _totalSteps = 4;
  final AuthService _authService = AuthService();

  // Controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _cpfController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  late bool _alreadySellOnline;
  late String _goal;
  late String _howKnew;

  // Métodos

  void _nextStep() => setState(() => _currentStep++);

  Future<void> _finishRegistration() async {
    final name = _nameController.text;
    final email = _emailController.text;
    final cpf = _cpfController.text;
    final phone = "55${_phoneController.text}";
    final password = _passwordController.text;
    final alreadySellOnline = _alreadySellOnline;
    final goal = _goal;
    final howKnew = _howKnew;

    var result = await _authService.registerUser(
      name: name,
      email: email,
      password: password,
      cpf: cpf,
      phone: phone,
      alreadySellOnline: alreadySellOnline,
      goal: goal,
      howKnew: howKnew,
    );

    if (mounted && result) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Cadastro Salvo! Faça Login.'),
            backgroundColor: Colors.green),
      );

      await _authService.login(email, password);

      context.go('/home');
    }else{
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Ops! Houve uma falha no registro.'),
            backgroundColor: AppPalette.error500),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          // Sombra ajustada para o fundo de imagem
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset('assets/logo_com_texto.png',
              height: 50, width: 200),
          const SizedBox(height: 24),

          // 2. Títulos
          Text(
            "Cadastre sua conta agora",
            style: TextStyle(
              fontSize: 20, // Ajustado para 24 igual ao Login
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Comece já a empreender",
            style: TextStyle(
              fontSize: 16,
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 32), // Espaçamento um pouco maior

          // 3. Barra de Progresso Visual
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: _currentStep / _totalSteps,
                    minHeight: 6,
                    backgroundColor: AppPalette.neutral200,
                    color: AppPalette.orange500,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                "$_currentStep/$_totalSteps",
                style:
                const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
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
          isLoading: _isGeneratingCode,
          onContinue: () async{
            setState(() => _isGeneratingCode = true);
            final success = await _authService.sendVerificationCode(_emailController.text.trim());

            setState(() => _isGeneratingCode = false);

            if (success) {
              _nextStep();
            } else {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Erro ao enviar código. Verifique o e-mail.'),
                    backgroundColor: AppPalette.error500,
                  ),
                );
              }
            }
          },
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
          onFinish: ({required howKnew, required alreadySellOnline, required goal}) {
            setState(() {
              _howKnew = howKnew;
              _alreadySellOnline = alreadySellOnline;
              _goal = goal;
            });
            _finishRegistration();
          },
        );
      default:
        return const SizedBox.shrink();
    }
  }
}
