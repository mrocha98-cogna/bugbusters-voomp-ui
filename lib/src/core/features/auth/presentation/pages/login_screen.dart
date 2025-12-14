import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:voomp_sellers_rebranding/src/core/features/auth/services/auth_service.dart';
import 'package:voomp_sellers_rebranding/src/shared/widgets/custom_button.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth > 800) {
            return const _DesktopLayout();
          } else {
            return const _MobileLayout();
          }
        },
      ),
    );
  }
}

// --- LAYOUTS RESPONSIVOS (Reutilizando a lógica do Cadastro) ---

class _DesktopLayout extends StatelessWidget {
  const _DesktopLayout();

  @override
  Widget build(BuildContext context) {
    const double formAreaWidth = 550;
    return Stack(
      children: [
        // Imagem de Fundo (Lado Direito)
        Positioned.fill(
          child: Image.asset(
            'assets/capa.png',
            fit: BoxFit.contain,
            alignment: Alignment.centerRight,
            // Fallback caso não tenha a imagem ainda
            errorBuilder: (c, o, s) => Container(color: const Color(0xFF1E2A45)),
          ),
        ),
        // Área do Formulário (Lado Esquerdo)
        Positioned(
          top: 0, bottom: 0, left: 0, width: formAreaWidth,
          child: Container(
            color: Colors.white,
            child: const Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 60),
                child: LoginFormCard(),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _MobileLayout extends StatelessWidget {
  const _MobileLayout();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: Image.asset(
            'assets/capa.png',
            fit: BoxFit.fitHeight,
            color: Colors.black.withOpacity(0.5),
            colorBlendMode: BlendMode.darken,
            errorBuilder: (c, o, s) => Container(color: const Color(0xFF1E2A45)),
          ),
        ),
        const Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(20),
            child: LoginFormCard(),
          ),
        ),
      ],
    );
  }
}

// --- CARD DE LOGIN ---

class LoginFormCard extends StatefulWidget {
  const LoginFormCard({super.key});

  @override
  State<LoginFormCard> createState() => _LoginFormCardState();
}

class _LoginFormCardState extends State<LoginFormCard> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final AuthService _authService = AuthService(); // Instância
  bool _isLoading = false;

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      final email = _emailController.text;
      final password = _passwordController.text;

      // Verifica Login
      final success = await _authService.login(email, password);

      setState(() => _isLoading = false);

      if (mounted) {
        if (success) {
          context.go('/home');
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('E-mail ou senha inválidos (ou usuário não cadastrado).'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  bool _obscurePassword = true;

  // Regex de Email
  final RegExp _emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

  // Validação para habilitar botão (opcional, mas visualmente agradável)
  bool get _isValid =>
      _emailController.text.trim().isNotEmpty &&
          _emailRegex.hasMatch(_emailController.text.trim()) &&
          _passwordController.text.isNotEmpty;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width <= 800;

    // Botão laranja se válido, cinza se não
    final buttonColor = _isValid ? const Color(0xFFFE8700) : const Color(0xFFC4C4C4);

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
      child: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Center(child: Image.asset('assets/logo.png', height: 40, width: 40, color: const Color(0xFF1E2A45))),
            const SizedBox(height: 20),
            const Center(child: Text("Acesse sua conta", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF333333)))),
            const SizedBox(height: 8),
            const Center(child: Text("Bem-vindo de volta!", style: TextStyle(color: Colors.grey))),
            const SizedBox(height: 40),

            // Campo Email
            const Text("E-mail", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            const SizedBox(height: 8),
            TextFormField(
              controller: _emailController,
              decoration: _inputDecoration("Digite seu e-mail"),
              keyboardType: TextInputType.emailAddress,
              onChanged: (_) => setState(() {}),
              validator: (value) {
                if (value == null || value.isEmpty) return 'O e-mail é obrigatório';
                if (!_emailRegex.hasMatch(value)) return 'Digite um e-mail válido';
                return null;
              },
            ),
            const SizedBox(height: 20),

            // Campo Senha
            const Text("Senha", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            const SizedBox(height: 8),
            TextFormField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              decoration: _inputDecoration("Digite sua senha").copyWith(
                suffixIcon: IconButton(
                  icon: Icon(_obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                ),
              ),
              onChanged: (_) => setState(() {}),
              validator: (value) {
                if (value == null || value.isEmpty) return 'A senha é obrigatória';
                return null;
              },
            ),

            // "Esqueci minha senha"
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  // Navegação para recuperação de senha
                },
                child: const Text("Esqueci minha senha", style: TextStyle(color: Color(0xFF1E2A45), fontSize: 12)),
              ),
            ),

            const SizedBox(height: 30),

            // Botão Entrar
            CustomButton(
              text: "Entrar",
              onPressed: _isValid ? _submit : null,
              backgroundColor: buttonColor,
            ),

            const SizedBox(height: 20),

            // Link para Cadastro
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Não tem uma conta? ", style: TextStyle(fontSize: 13, color: Colors.grey)),
                GestureDetector(
                  onTap: () => context.go('/register'),
                  child: const Text(
                    "Cadastre-se",
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFFE8700),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Helper de Estilo (Idêntico ao do cadastro)
  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey[400]),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFDDDDDD)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFFF8C00)),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.red),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.red, width: 2),
      ),
    );
  }
}
