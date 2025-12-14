import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:voomp_sellers_rebranding/src/core/features/auth/presentation/widgets/step4_onboarding.dart';
import 'package:voomp_sellers_rebranding/src/core/features/auth/services/auth_service.dart';
import 'step1_form.dart';
import 'step2_verification.dart';
import 'step3_final_data.dart';

class RegistrationFormCard extends StatefulWidget {
  const RegistrationFormCard({super.key});

  @override
  State<RegistrationFormCard> createState() => _RegistrationFormCardState();
}

class _RegistrationFormCardState extends State<RegistrationFormCard> {
  int _currentStep = 1;
  final AuthService _authService = AuthService(); // Instância do serviço

  final TextEditingController _nameController = TextEditingController(); // Era do Step1
  final TextEditingController _emailController = TextEditingController(); // Já estava aqui

  final TextEditingController _cpfController = TextEditingController(); // Era do Step3
  final TextEditingController _phoneController = TextEditingController(); // Era do Step3
  final TextEditingController _passwordController = TextEditingController(); // Era do Step3


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
        const SnackBar(content: Text('Cadastro Salvo! Faça Login.'), backgroundColor: Colors.green),
      );
      GoRouter.of(context).go('/home');
    }
  }

  @override
  void dispose() {
    // Não esqueça de dar dispose em todos
    _nameController.dispose();
    _emailController.dispose();
    _cpfController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width <= 800;

    return Container(
      width: double.infinity,
      decoration: isMobile
          ? BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5))
        ],
      )
          : null,
      padding: isMobile ? const EdgeInsets.all(32.0) : EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header (Logo e Títulos)
          Center(child: Image.asset('assets/logo.png', height: 40, width: 40, color: const Color(0xFF1E2A45))),
          const SizedBox(height: 20),
          const Center(child: Text("Cadastre sua conta agora", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF333333)))),
          const SizedBox(height: 8),
          const Center(child: Text("Comece já a empreender", style: TextStyle(color: Colors.grey))),
          const SizedBox(height: 30),

          // Barra de Progresso
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: 0.25 * _currentStep, // Progresso dinâmico (opcional)
                    backgroundColor: const Color(0xFFEEEEEE),
                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF6B4E31)),
                    minHeight: 8,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text("$_currentStep/4", style: const TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
          const SizedBox(height: 30),
          if (_currentStep == 1)
            Step1Form(
              nameController: _nameController,
              emailController: _emailController,
              onContinue: _nextStep,
            )
          else if (_currentStep == 2)
            Step2Verification(
              email: _emailController.text,
              onContinue: _nextStep,
            )
          else if (_currentStep == 3)
              Step3FinalData(
                // PASSAMOS OS CONTROLLERS RESTANTES PARA O FILHO
                cpfController: _cpfController,
                phoneController: _phoneController,
                passwordController: _passwordController,
                onFinish: _nextStep,
              )
            else
              Step4Onboarding(
                onFinish: _finishRegistration,
              ),
        ],
      ),
    );
  }
}
