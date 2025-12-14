import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:voomp_sellers_rebranding/src/core/features/auth/services/auth_service.dart';
import 'package:voomp_sellers_rebranding/src/core/theme/app_colors.dart';
import 'package:voomp_sellers_rebranding/src/shared/widgets/custom_button.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      // Fundo automático (Light: Cinza, Dark: Preto)
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo (Placeholder)
              const Icon(Icons.incomplete_circle, size: 64, color: AppPalette.orange500),
              const SizedBox(height: 40),

              // Título
              Text(
                "Bem-vindo de volta",
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface // Cor dinâmica
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Entre para gerenciar suas vendas",
                style: TextStyle(
                    fontSize: 14,
                    color: theme.colorScheme.onSurface.withOpacity(0.6)
                ),
              ),
              const SizedBox(height: 32),

              // Card de Login
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: const LoginFormCard(),
              ),

              const SizedBox(height: 24),

              // Rodapé "Criar conta"
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Não tem uma conta? ",
                    style: TextStyle(color: theme.colorScheme.onSurface),
                  ),
                  TextButton(
                    onPressed: () => context.go('/register'),
                    child: const Text(
                        "Cadastre-se",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppPalette.orange500
                        )
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class LoginFormCard extends StatefulWidget {
  const LoginFormCard({super.key});

  @override
  State<LoginFormCard> createState() => _LoginFormCardState();
}

class _LoginFormCardState extends State<LoginFormCard> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  final AuthService _authService = AuthService();
  bool _isLoading = false;

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      final email = _emailController.text;
      final password = _passwordController.text;

      final success = await _authService.login(email, password);

      setState(() => _isLoading = false);

      if (mounted) {
        if (success) {
          context.go('/home');
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('E-mail ou senha inválidos.'),
              backgroundColor: AppPalette.error500,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: theme.cardTheme.color, // Cor do card dinâmica
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          // Sombra sutil apenas no modo Light
          if (theme.brightness == Brightness.light)
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // E-mail Input
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              style: TextStyle(color: theme.colorScheme.onSurface), // Cor do texto digitado
              decoration: const InputDecoration(
                labelText: 'E-mail',
                prefixIcon: Icon(Icons.email_outlined),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) return 'Digite seu e-mail';
                if (!value.contains('@')) return 'E-mail inválido';
                return null;
              },
            ),
            const SizedBox(height: 20),

            // Senha Input
            TextFormField(
              controller: _passwordController,
              obscureText: true,
              style: TextStyle(color: theme.colorScheme.onSurface),
              decoration: const InputDecoration(
                labelText: 'Senha',
                prefixIcon: Icon(Icons.lock_outline),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) return 'Digite sua senha';
                return null;
              },
            ),

            const SizedBox(height: 12),

            // Esqueceu a senha
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {},
                child: Text(
                  "Esqueceu a senha?",
                  style: TextStyle(
                      fontSize: 12,
                      color: theme.colorScheme.onSurface.withOpacity(0.6)
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Botão Entrar
            // Se o CustomButton ainda não foi refatorado,
            // podemos usar ElevatedButton nativo para garantir o tema por enquanto
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppPalette.orange500,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: _isLoading
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text("Entrar", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
