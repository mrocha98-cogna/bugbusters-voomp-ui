import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:voomp_sellers_rebranding/src/core/features/auth/services/auth_service.dart';
import 'package:voomp_sellers_rebranding/src/core/theme/app_colors.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isMobile = MediaQuery.of(context).size.width < 900;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Row(
        children: [
          // 1. COLUNA DO FORMULÁRIO (ESQUERDA)
          Expanded(
            flex: 1,
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Container limitado para não ficar muito largo em telas grandes
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 480),
                      child: const LoginFormCard(),
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
                  Image.asset(
                    'assets/capa.png',
                    fit: BoxFit.cover,
                    errorBuilder: (c, o, s) => Container(
                      color: AppPalette.neutral200,
                      child: const Center(
                          child: Icon(Icons.image, size: 80, color: Colors.grey)),
                    ),
                  ),
                  // Máscara opcional
                  Container(color: Colors.black.withOpacity(0.1)),
                ],
              ),
            ),
        ],
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

  bool _obscureText = true;
  bool _isLoading = false;
  final AuthService _authService = AuthService();

  // Validação simples para habilitar/desabilitar botão visualmente
  bool get _isValid =>
      _emailController.text.contains('@') &&
          _passwordController.text.length >= 3;

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      final success = await _authService.login(
        _emailController.text,
        _passwordController.text,
      );

      setState(() => _isLoading = false);

      if (mounted) {
        if (success) {
          context.go('/home');
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Credenciais inválidas.'),
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
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        // Sombra suave igual ao cadastro
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 24,
              offset: const Offset(0, 12),
            ),
        ],
      ),
      child: Form(
        key: _formKey,
        onChanged: () => setState(() {}), // Atualiza estado do botão
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start, // Alinha labels à esquerda
          children: [
            // Logo
            Center(
              child: Image.asset('assets/logo.png', color: AppPalette.blue900, height: 40, width: 40),
            ),
            const SizedBox(height: 32),

            // Títulos
            Center(
              child: Text(
                "Bem-vindo(a) de volta!",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                "Acesse sua conta para continuar",
                style: TextStyle(
                  fontSize: 14,
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ),
            const SizedBox(height: 40),

            // --- CAMPO E-MAIL ---
            _buildLabel("E-mail", theme),
            const SizedBox(height: 8),
            TextFormField(
              controller: _emailController,
              style: TextStyle(color: theme.colorScheme.onSurface),
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              decoration: _inputDecoration(
                hint: "Digite seu e-mail",
                theme: theme,
              ),
              validator: (value) {
                if (value == null || !value.contains('@')) return 'E-mail inválido';
                return null;
              },
            ),

            const SizedBox(height: 20),

            // --- CAMPO SENHA ---
            _buildLabel("Senha", theme),
            const SizedBox(height: 8),
            TextFormField(
              controller: _passwordController,
              obscureText: _obscureText,
              style: TextStyle(color: theme.colorScheme.onSurface),
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _submit(),
              decoration: _inputDecoration(
                hint: "Digite sua senha",
                theme: theme,
              ).copyWith(
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureText ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                    color: AppPalette.neutral500,
                  ),
                  onPressed: () => setState(() => _obscureText = !_obscureText),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) return 'Digite sua senha';
                return null;
              },
            ),

            // Esqueceu a senha
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {},
                child: Text(
                  "Esqueceu a senha?",
                  style: TextStyle(
                    fontSize: 12,
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // --- BOTÃO ENTRAR ---
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: (_isValid && !_isLoading) ? _submit : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isValid ? AppPalette.neutral800 : AppPalette.neutral300,
                  foregroundColor: _isValid ? Colors.white : AppPalette.neutral600,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
                    : const Text(
                  "Entrar",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Rodapé Cadastro
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Não tem uma conta? ",
                  style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.6)),
                ),
                GestureDetector(
                  onTap: () => context.go('/register'),
                  child: const Text(
                    "Cadastre-se",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppPalette.orange500,
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

  // --- REUTILIZANDO O ESTILO EXATO DO STEP 1 ---

  Widget _buildLabel(String text, ThemeData theme) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: theme.colorScheme.onSurface,
      ),
    );
  }

  InputDecoration _inputDecoration({required String hint, required ThemeData theme}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.4)),
      filled: true,
      fillColor: Colors.transparent,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppPalette.neutral300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppPalette.neutral800, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppPalette.error500),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppPalette.error500, width: 1.5),
      ),
    );
  }
}
