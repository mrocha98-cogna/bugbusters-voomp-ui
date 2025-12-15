import 'package:flutter/material.dart';
import 'package:voomp_sellers_rebranding/src/core/theme/app_colors.dart';

class Step1Form extends StatefulWidget {
  final TextEditingController nameController;
  final TextEditingController emailController;
  final VoidCallback onContinue;

  const Step1Form({
    super.key,
    required this.nameController,
    required this.emailController,
    required this.onContinue,
  });

  @override
  State<Step1Form> createState() => _Step1FormState();
}

class _Step1FormState extends State<Step1Form> {
  final _formKey = GlobalKey<FormState>();

  // Valida se os campos estão preenchidos para mudar a cor do botão
  bool get _isValid =>
      widget.nameController.text.trim().length > 3 &&
          widget.emailController.text.contains('@');

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Form(
      key: _formKey,
      onChanged: () => setState(() {}), // Atualiza UI para habilitar/desabilitar botão
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // --- CAMPO NOME ---
          _buildLabel("Nome Completo", theme),
          const SizedBox(height: 8),
          TextFormField(
            controller: widget.nameController,
            style: TextStyle(color: theme.colorScheme.onSurface),
            decoration: _inputDecoration(
              hint: "Digite seu nome",
              theme: theme,
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) return 'Nome obrigatório';
              return null;
            },
          ),

          const SizedBox(height: 20),

          // --- CAMPO EMAIL ---
          _buildLabel("E-mail", theme),
          const SizedBox(height: 8),
          TextFormField(
            controller: widget.emailController,
            style: TextStyle(color: theme.colorScheme.onSurface),
            keyboardType: TextInputType.emailAddress,
            decoration: _inputDecoration(
              hint: "Digite seu e-mail",
              theme: theme,
            ),
            validator: (value) {
              if (value == null || !value.contains('@')) return 'E-mail inválido';
              return null;
            },
          ),

          const SizedBox(height: 8),
          Text(
            "ex: seunome@gmail.com",
            style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurface.withOpacity(0.5)),
          ),

          const SizedBox(height: 32),

          // --- BOTÃO CONTINUAR ---
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _isValid ? widget.onContinue : null,
              style: ElevatedButton.styleFrom(
                // Se inválido: Cinza (como na imagem). Se válido: Laranja ou Preto (conforme sua preferência)
                backgroundColor: _isValid ? AppPalette.orange500 : AppPalette.neutral300,
                foregroundColor: _isValid ? Colors.white : AppPalette.neutral600,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                "Continuar",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper para criar o Label acima do input (Estilo da imagem)
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

  // Helper para o estilo da caixa de texto (Borda arredondada suave)
  InputDecoration _inputDecoration({required String hint, required ThemeData theme}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.4)),
      filled: true,
      fillColor: Colors.transparent, // Fundo transparente pois a borda define a caixa
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      // Borda Padrão (Cinza claro)
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: AppPalette.neutral300),
      ),
      // Borda Focada (Preto ou Laranja)
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppPalette.neutral800, width: 1.5),
      ),
      // Borda Erro
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
