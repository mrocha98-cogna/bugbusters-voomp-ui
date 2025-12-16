import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pinput/pinput.dart';import 'package:voomp_sellers_rebranding/src/core/features/auth/services/auth_service.dart';
import 'package:voomp_sellers_rebranding/src/core/theme/app_colors.dart';

class Step2Verification extends StatefulWidget {
  final String email;
  final VoidCallback onContinue;

  const Step2Verification({
    super.key,
    required this.email,
    required this.onContinue,
  });

  @override
  State<Step2Verification> createState() => _Step2VerificationState();
}

class _Step2VerificationState extends State<Step2Verification> {
  final TextEditingController _pinController = TextEditingController();
  final AuthService _authService = AuthService();

  bool _isLoading = false;
  bool _isResending = false;

  // Verifica o código na API
  Future<void> _verifyCode() async {
    final code = _pinController.text;
    if (code.length != 6) return;

    setState(() => _isLoading = true);

    final isValid = await _authService.validateVerificationCode(widget.email, code);

    if (mounted) {
      setState(() => _isLoading = false);

      if (isValid) {
        widget.onContinue();
      } else {
        _pinController.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Código inválido ou expirado.'),
            backgroundColor: AppPalette.error500,
          ),
        );
      }
    }
  }

  Future<void> _resendCode() async {
    setState(() => _isResending = true);
    try {
      final success = await _authService.sendVerificationCode(widget.email);
      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Código reenviado com sucesso!'),
              backgroundColor: Colors.green),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Erro ao reenviar. Tente novamente.'),
              backgroundColor: AppPalette.error500),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isResending = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Tema padrão (linha inferior cinza)
    final defaultPinTheme = PinTheme(
      width: 50,
      height: 55,
      textStyle: TextStyle(
          fontSize: 28,
          color: theme.colorScheme.onSurface,
          fontWeight: FontWeight.bold),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppPalette.neutral300,
            width: 2,
          ),
        ),
      ),
    );

    // Tema focado (linha inferior laranja)
    final focusedPinTheme = defaultPinTheme.copyDecorationWith(
      border: const Border(
        bottom: BorderSide(
          color: AppPalette.orange500,
          width: 2,
        ),
      ),
    );

    // Variável para controlar se o botão deve estar habilitado
    final bool canSubmit = _pinController.text.length == 6 && !_isLoading && !_isResending;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          "Por favor, digite o código que enviamos para o email:",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 20,
            height: 1.5,
            color: theme.colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          widget.email,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 32),
        Center(
          child: Pinput(
            length: 6,
            controller: _pinController,
            defaultPinTheme: defaultPinTheme,
            focusedPinTheme: focusedPinTheme,
            submittedPinTheme: defaultPinTheme,
            onChanged: (value) {
              setState(() {});
            },
          ),
        ),
        const SizedBox(height: 32),
        SizedBox(
          width: 120,
          child: _isResending
              ? const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
              : TextButton(
              onPressed: _resendCode,
              child: Row(
                children: [
                  Text(
                    "Reenviar",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(width: 8),
                  Icon(FontAwesomeIcons.paperPlane)
                ],
              )
          ),
        ),
        const SizedBox(height: 16),
        Text(
          "Não encontrou?",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          "Confira na aba Spam ou Promoções do seu e-mail.",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            color: theme.colorScheme.onSurface.withOpacity(0.5),
          ),
        ),
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            // Se canSubmit for false, passamos null (desabilita visualmente e clique)
            onPressed: canSubmit ? _verifyCode : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppPalette.orange500,
              // Cor quando desabilitado
              disabledBackgroundColor: AppPalette.neutral300,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: _isLoading
                ? const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            )
                : const Text(
              "Continuar",
              style: TextStyle(fontSize: 16, color: AppPalette.surfaceText, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }
}
