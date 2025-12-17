import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:voomp_sellers_rebranding/src/core/features/auth/services/auth_service.dart';
import 'package:voomp_sellers_rebranding/src/core/theme/app_colors.dart';
import 'package:flutter_svg/flutter_svg.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isMobile = MediaQuery.of(context).size.width < 900;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      // Usamos Stack para empilhar elementos (Imagem no fundo, formulário por cima)
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/capa.png',
              fit: BoxFit.cover,
              alignment: Alignment.center,
              errorBuilder: (c, o, s) => Container(
                color: AppPalette.neutral200,
                child: const Center(
                  child: Icon(Icons.image, size: 80, color: Colors.grey),
                ),
              ),
            ),
          ),

          // 2. OVERLAY ESCURO (Opcional: melhora o contraste do card sobre a imagem)
          // Positioned.fill(
          //   child: Container(
          //     color: Colors.black.withOpacity(0.4), // 40% de opacidade preta
          //   ),
          // ),

          // 3. CONTEÚDO (Formulário à Esquerda)
          Align(
            // No mobile centraliza, no Desktop alinha à esquerda
            alignment: isMobile ? Alignment.center : Alignment.centerLeft,
            child: SizedBox(
              // No Desktop, fixamos uma largura para a "coluna" do formulário
              // No Mobile, ocupa a largura total
              width: isMobile ? double.infinity : 600,
              height: double.infinity,
              // Opcional: Se quiser que o fundo atrás do card seja levemente branco/fosco
              // color: isMobile ? Colors.transparent : Colors.white.withOpacity(0.9),
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 480),
                        child: const LoginFormCard(),
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

class LoginFormCard extends StatefulWidget {
// ... (O restante do código da classe LoginFormCard permanece igual)
  const LoginFormCard({super.key});

  @override
  State<LoginFormCard> createState() => _LoginFormCardState();
}

class _LoginFormCardState extends State<LoginFormCard> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final AuthService _authService = AuthService();

  bool _obscureText = true;
  bool _isLoading = false;
  String? _emailError;
  String? _passwordError;

  bool _isEmailValid(String email) {
    final RegExp emailRegex = RegExp(
      r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
    );
    return emailRegex.hasMatch(email);
  }

  late bool _isFormFilled;

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();

    setState(() {
      _emailError = null;
      _passwordError = null;
    });

    bool hasLocalError = false;

    // 2. Validação LOCAL (Formato e campos vazios)
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty) {
      _emailError = 'O campo e-mail é obrigatório';
      hasLocalError = true;
    } else if (!_isEmailValid(email)) {
      _emailError = 'E-mail inválido';
      hasLocalError = true;
    }

    if (password.isEmpty) {
      _passwordError = 'Digite sua senha';
      hasLocalError = true;
    }

    // Se houve erro local, mostra Toast e para a execução
    if (hasLocalError) {
      setState(() {}); // Reconstrói para mostrar as mensagens customizadas abaixo dos campos
      _formKey.currentState?.validate(); // Dispara a borda vermelha do TextFormField

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Verifique os campos inválidos.'),
          backgroundColor: AppPalette.error500,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // 3. Validação no SERVIDOR (AuthService)
    setState(() => _isLoading = true);

    // Simula ou chama o serviço real
    final user = await _authService.login(email, password);

    setState(() => _isLoading = false);

    if (mounted) {
      if (user != null) {
        context.go('/home');
      } else {
        // Erro retornado pelo backend (ex: senha incorreta ou usuário não encontrado)
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('E-mail ou senha incorretos.'),
            backgroundColor: AppPalette.error500,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  void initState() {
    _isFormFilled = _emailController.text.isNotEmpty && _passwordController.text.isNotEmpty;
    super.initState();
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
          // Sombra um pouco mais forte para destacar do fundo da imagem
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Image.asset('assets/logo_com_texto.png', height: 50, width: 200),
            ),
            const SizedBox(height: 32),
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
            _buildLabel("E-mail", theme),
            const SizedBox(height: 8),
            TextFormField(
              controller: _emailController,
              style: TextStyle(color: theme.colorScheme.onSurface),
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              // Ao digitar, limpamos o erro visual para melhor UX
              onChanged: (v) {
                if (_emailError != null){
                  _emailError = null;
                }
                _isFormFilled = _emailController.text.isNotEmpty && _passwordController.text.isNotEmpty;
                setState(() { });
              },
              decoration: _inputDecoration(
                hint: "Digite seu e-mail",
                theme: theme,
              ),
              validator: (value) {
                setState(() {
                  _isFormFilled = _emailController.text.isNotEmpty && _passwordController.text.isNotEmpty;
                });
                return _emailError != null ? '' : null;
              },
            ),
            if (_emailError != null)
              _buildCustomErrorRow(_emailError!),

            const SizedBox(height: 20),
            _buildLabel("Senha", theme),
            const SizedBox(height: 8),
            TextFormField(
              controller: _passwordController,
              obscureText: _obscureText,
              style: TextStyle(color: theme.colorScheme.onSurface),
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _submit(),
              onChanged: (v) {
                if (_passwordError != null){
                  _passwordError = null;
                }

                _isFormFilled = _emailController.text.isNotEmpty && _passwordController.text.isNotEmpty;
                setState(() { });
              },
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
                setState(() {
                  _isFormFilled = _emailController.text.isNotEmpty && _passwordController.text.isNotEmpty;
                });
                return _passwordError != null ? '' : null;
              },
            ),
            if (_passwordError != null)
              _buildCustomErrorRow(_passwordError!),
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
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading || !_isFormFilled ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isFormFilled ? AppPalette.orange500 : AppPalette.neutral300,
                  foregroundColor: _isFormFilled ? Colors.black : AppPalette.neutral600,
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

  // --- MÉTODOS AUXILIARES ---

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

  // Novo widget para o erro com ícone (Conforme imagem)
  Widget _buildCustomErrorRow(String error) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Row(
        children: [
          const Icon(Icons.error_rounded, color: AppPalette.error500, size: 20),
          const SizedBox(width: 8),
          Text(
            error,
            style: const TextStyle(
              color: AppPalette.error500,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
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
      // Esconde o texto de erro padrão do Flutter para usarmos o nosso customizado
      errorStyle: const TextStyle(height: 0),
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
