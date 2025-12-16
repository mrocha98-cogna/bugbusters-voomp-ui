import 'package:flutter/material.dart';
import 'package:voomp_sellers_rebranding/src/core/theme/app_colors.dart';

class Step1Form extends StatefulWidget {
  final TextEditingController nameController;
  final TextEditingController emailController;
  final VoidCallback onContinue;
  final bool isLoading; // 1. Adicionamos o parâmetro aqui

  const Step1Form({
    super.key,
    required this.nameController,
    required this.emailController,
    required this.onContinue,
    this.isLoading = false, // Valor padrão false
  });

  @override
  State<Step1Form> createState() => _Step1FormState();
}

class _Step1FormState extends State<Step1Form> {
  final _formKey = GlobalKey<FormState>();

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      widget.onContinue();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLabel("Nome Completo", theme),
          const SizedBox(height: 8),
          TextFormField(
            controller: widget.nameController,
            style: TextStyle(color: theme.colorScheme.onSurface),
            textInputAction: TextInputAction.next,
            decoration: _inputDecoration(
              hint: "Digite seu nome completo",
              theme: theme,
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Por favor, insira seu nome.';
              }
              if (value.trim().split(' ').length < 2) {
                return 'Insira nome e sobrenome.';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          _buildLabel("E-mail", theme),
          const SizedBox(height: 8),
          TextFormField(
            controller: widget.emailController,
            style: TextStyle(color: theme.colorScheme.onSurface),
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _submit(),
            decoration: _inputDecoration(
              hint: "exemplo@email.com",
              theme: theme,
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'O e-mail é obrigatório.';
              }
              final emailRegex = RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$");
              if (!emailRegex.hasMatch(value)) {
                return 'Insira um e-mail válido.';
              }
              return null;
            },
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              // 2. Se estiver carregando, desabilita o clique (null)
              onPressed: widget.isLoading ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.isLoading ? AppPalette.neutral300 : AppPalette.orange500,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              // 3. Mostra o loading ou o texto
              child: widget.isLoading
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
                style: TextStyle(
                    fontSize: 16, color: AppPalette.surfaceText, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

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

  InputDecoration _inputDecoration(
      {required String hint, required ThemeData theme}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.4)),
      filled: true,
      fillColor: Colors.transparent,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppPalette.neutral300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppPalette.neutral800),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppPalette.error500),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppPalette.error500),
      ),
    );
  }
}
