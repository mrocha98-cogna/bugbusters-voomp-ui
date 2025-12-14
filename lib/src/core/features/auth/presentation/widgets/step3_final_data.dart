import 'package:flutter/material.dart';
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

  // Estados para checklist de senha
  bool _hasMinLength = false;
  bool _hasUppercase = false;
  bool _hasLowercase = false;
  bool _hasDigits = false;

  void _validatePassword(String value) {
    setState(() {
      _hasMinLength = value.length >= 8;
      _hasUppercase = value.contains(RegExp(r'[A-Z]'));
      _hasLowercase = value.contains(RegExp(r'[a-z]'));
      _hasDigits = value.contains(RegExp(r'[0-9]'));
    });
  }

  bool get _isPasswordValid => _hasMinLength && _hasUppercase && _hasLowercase && _hasDigits;
  bool get _isCpfValid => CpfValidator.isValid(widget.cpfController.text); // Use seu validator real

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Form(
      key: _formKey,
      onChanged: () => setState(() {}),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            "Dados Finais",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface),
          ),
          const SizedBox(height: 24),

          // CPF
          TextFormField(
            controller: widget.cpfController,
            style: TextStyle(color: theme.colorScheme.onSurface),
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'CPF',
              prefixIcon: Icon(Icons.badge_outlined),
            ),
            validator: (v) => _isCpfValid ? null : 'CPF inválido',
          ),
          const SizedBox(height: 16),

          // Telefone
          TextFormField(
            controller: widget.phoneController,
            style: TextStyle(color: theme.colorScheme.onSurface),
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
              labelText: 'Telefone',
              prefixIcon: Icon(Icons.phone_outlined),
            ),
            validator: (v) => (v != null && v.length > 8) ? null : 'Telefone inválido',
          ),
          const SizedBox(height: 16),

          // Senha
          TextFormField(
            controller: widget.passwordController,
            obscureText: true,
            style: TextStyle(color: theme.colorScheme.onSurface),
            decoration: const InputDecoration(
              labelText: 'Senha',
              prefixIcon: Icon(Icons.lock_outline),
            ),
            onChanged: _validatePassword,
          ),

          const SizedBox(height: 16),
          // Checklist de Senha
          _buildCheckItem("Mínimo 8 caracteres", _hasMinLength, theme),
          _buildCheckItem("Letra Maiúscula", _hasUppercase, theme),
          _buildCheckItem("Letra Minúscula", _hasLowercase, theme),
          _buildCheckItem("Números", _hasDigits, theme),

          const SizedBox(height: 32),
          SizedBox(
            height: 50,
            child: ElevatedButton(
              onPressed: (_isPasswordValid && _isCpfValid) ? widget.onFinish : null,
              child: const Text("Finalizar Cadastro"),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckItem(String label, bool isValid, ThemeData theme) {
    // Cores: Verde (Valid), Cinza (Default) - Sem erro explícito aqui, apenas estado
    final color = isValid ? AppPalette.success500 : theme.colorScheme.onSurface.withOpacity(0.4);
    final icon = isValid ? Icons.check_circle : Icons.circle_outlined;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Text(label, style: TextStyle(color: color, fontSize: 12)),
        ],
      ),
    );
  }
}
