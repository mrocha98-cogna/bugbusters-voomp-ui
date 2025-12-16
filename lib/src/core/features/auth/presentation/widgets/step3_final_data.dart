import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:voomp_sellers_rebranding/src/core/formatters/custom_formatters.dart'; // Seus formatadores
import 'package:voomp_sellers_rebranding/src/core/theme/app_colors.dart';
import 'package:voomp_sellers_rebranding/src/core/validators/cpf_validator.dart';

class Step3FinalData extends StatefulWidget {
  final VoidCallback onFinish;
  final TextEditingController cpfController;
  final TextEditingController phoneController;
  final TextEditingController passwordController;

  const Step3FinalData({
    super.key,
    required this.onFinish,
    required this.cpfController,
    required this.phoneController,
    required this.passwordController,
  });

  @override
  State<Step3FinalData> createState() => _Step3FinalDataState();
}

class _Step3FinalDataState extends State<Step3FinalData> {
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;

  // --- ESTADOS DE VALIDAÇÃO VISUAL ---
  String? _cpfError;
  String? _phoneError;

  // --- ESTADOS DE SENHA ---
  bool? _hasMinLength = null;
  bool? _hasUppercase = null;
  bool? _hasLowercase = null;
  bool? _hasDigits = null;

  void _validatePassword(String value) {
    setState(() {
      _hasMinLength = value.length >= 8;
      _hasUppercase = value.contains(RegExp(r'[A-Z]'));
      _hasLowercase = value.contains(RegExp(r'[a-z]'));
      _hasDigits = value.contains(RegExp(r'[0-9]'));
    });
  }

  void _validateCpf(String value) {
    // Se o campo estiver vazio, limpa o erro (para não mostrar erro logo de cara se o user apagar tudo)
    if (value.isEmpty) {
      setState(() => _cpfError = null);
      return;
    }

    // Usa o validador real do sistema
    final isValid = CpfValidator.isValid(value);

    setState(() {
      // Se não for válido e já tiver digitado 14 caracteres (máscara completa), mostra erro
      // Ou se quiser validar enquanto digita, pode remover a checagem de length,
      // mas geralmente valida-se CPF completo.
      if (!isValid && value.length == 14) {
        _cpfError = "CPF incorreto";
      } else {
        _cpfError = null;
      }
    });
  }

  void _validatePhone(String value) {
    // Remove pontuação
    final unmaskedValue = value.replaceAll(RegExp(r'[^0-9]'), '');

    // Validação básica (Celular deve ter 10 ou 11 dígitos)
    if (unmaskedValue.isNotEmpty && unmaskedValue.length < 10) {
      setState(() => _phoneError = "Telefone incorreto");
    } else {
      setState(() => _phoneError = null);
    }
  }

  bool get _isPasswordValid =>
      (_hasMinLength ?? false) &&
          (_hasUppercase ?? false) &&
          (_hasLowercase ?? false) &&
          (_hasDigits ?? false);

  bool get _isValid =>
      _isPasswordValid &&
      widget.cpfController.text.replaceAll(RegExp(r'[^0-9]'), '').length ==
          11 &&
      _cpfError == null &&
      widget.phoneController.text.replaceAll(RegExp(r'[^0-9]'), '').length >=
          10 &&
      _phoneError == null;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Form(
      key: _formKey,
      onChanged: () => setState(() {}),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- CPF ---
          _buildInputWithValidation(
            label: "CPF",
            controller: widget.cpfController,
            theme: theme,
            hint: "Digite seu CPF",
            errorText: _cpfError,
            formatters: [CpfInputFormatter()],
            // Seu formatador customizado
            keyboardType: TextInputType.number,
            onChanged: _validateCpf,
          ),

          const SizedBox(height: 20),

          // --- TELEFONE ---
          _buildInputWithValidation(
            label: "Telefone",
            controller: widget.phoneController,
            theme: theme,
            hint: "(31) XXXXX-XXXX",
            errorText: _phoneError,
            formatters: [PhoneInputFormatter()],
            // Seu formatador customizado
            keyboardType: TextInputType.phone,
            onChanged: _validatePhone,
          ),

          const SizedBox(height: 20),

          // --- SENHA ---
          _buildLabel("Senha", theme),
          const SizedBox(height: 8),
          TextFormField(
            controller: widget.passwordController,
            obscureText: _obscurePassword,
            style: TextStyle(color: theme.colorScheme.onSurface),
            onChanged: _validatePassword,
            decoration:
                _inputDecoration(
                  hint: "Digite sua senha",
                  theme: theme,
                  hasError: false,
                ).copyWith(
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: AppPalette.neutral500,
                      size: 20,
                    ),
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
          ),

          const SizedBox(height: 20),

          // --- CHECKLIST DE SENHA ---
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? AppPalette.neutral800 : AppPalette.neutral100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "A sua senha deve ter",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 12),
                _buildRequirementItem(
                  "Pelo menos 1 caractere minúsculo",
                  _hasLowercase,
                  theme,
                ),
                _buildRequirementItem(
                  "Pelo menos 1 caractere maiúsculo",
                  _hasUppercase,
                  theme,
                ),
                _buildRequirementItem("Pelo menos 1 número", _hasDigits, theme),
                _buildRequirementItem(
                  "Pelo menos 8 caracteres",
                  _hasMinLength,
                  theme,
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // --- BOTÃO CONTINUAR ---
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _isValid ? widget.onFinish : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: _isValid
                    ? AppPalette.orange500
                    : AppPalette.neutral300,
                foregroundColor: _isValid
                    ? Colors.white
                    : AppPalette.neutral600,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                "Continuar",
                style: TextStyle(fontSize: 16,
                    color: AppPalette.surfaceText,
                    fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGET DE INPUT COM VALIDAÇÃO ---
  Widget _buildInputWithValidation({
    required String label,
    required TextEditingController controller,
    required ThemeData theme,
    required String hint,
    String? errorText,
    List<TextInputFormatter>? formatters,
    TextInputType? keyboardType,
    Function(String)? onChanged,
  }) {
    final hasError = errorText != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label, theme),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: formatters,
          style: TextStyle(color: theme.colorScheme.onSurface),
          onChanged: onChanged,
          decoration: _inputDecoration(
            hint: hint,
            theme: theme,
            hasError: hasError,
          ),
        ),
        SizedBox(height: hasError ? 6 : 0),
        if (hasError)
          Row(
            children: [
              const Icon(Icons.error, color: AppPalette.error500, size: 16),
              const SizedBox(width: 4),
              Text(
                errorText,
                style: const TextStyle(
                  color: AppPalette.error500,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
      ],
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

  Widget _buildRequirementItem(String text, bool? isMet, ThemeData theme) {
    final color = isMet == null ? AppPalette.neutral500 : isMet
        ? AppPalette.success500
        : AppPalette.error500;
    final icon = isMet == null ? null : isMet
        ? Icons.check_circle_outline
        : Icons.cancel_outlined;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          icon != null
            ? Icon(icon, size: 18, color: color)
            : Text('\u2022'),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String hint,
    required ThemeData theme,
    required bool hasError,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.4)),
      filled: true,
      fillColor: Colors.transparent,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(
          color: hasError ? AppPalette.error500 : AppPalette.neutral300,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(
          color: hasError ? AppPalette.error500 : AppPalette.neutral800,
          width: 1.5,
        ),
      ),
    );
  }
}
