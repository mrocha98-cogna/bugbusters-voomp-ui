import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:voomp_sellers_rebranding/src/core/formatters/custom_formatters.dart';
import 'package:voomp_sellers_rebranding/src/core/validators/cpf_validator.dart';

class Step3FinalData extends StatefulWidget {
  final VoidCallback onFinish;
  // Novos parâmetros
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
  bool _submitted = false;

  bool _hasMinLower = false;
  bool _hasMinUpper = false;
  bool _hasMinNumber = false;
  bool _hasMinLength = false;

  bool get _isCpfValid => CpfValidator.isValid(widget.cpfController.text);
  bool get _isPhoneValid => widget.phoneController.text.replaceAll(RegExp(r'[^0-9]'), '').length >= 11;
  bool get _isPasswordValid => _hasMinLower && _hasMinUpper && _hasMinNumber && _hasMinLength;
  bool get _isFormValid => _isCpfValid && _isPhoneValid && _isPasswordValid;
  bool get _hasStartedTyping => widget.cpfController.text.isNotEmpty && widget.phoneController.text.isNotEmpty && widget.passwordController.text.isNotEmpty;

  void _validatePassword(String value) {
    setState(() {
      _hasMinLower = value.contains(RegExp(r'[a-z]'));
      _hasMinUpper = value.contains(RegExp(r'[A-Z]'));
      _hasMinNumber = value.contains(RegExp(r'[0-9]'));
      _hasMinLength = value.length >= 8;
    });
  }

  void _submit() {
    setState(() => _submitted = true);
    if (_isFormValid) {
      widget.onFinish();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Verifique os campos.'), backgroundColor: Colors.red));
    }
  }

  @override
  Widget build(BuildContext context) {
    bool showCpfError = _submitted && !_isCpfValid;
    bool showPhoneError = _submitted && !_isPhoneValid;
    Color btnColor = _hasStartedTyping ? const Color(0xFFFE8700) : const Color(0xFFC4C4C4);

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLabel("CPF"),
          const SizedBox(height: 8),
          TextFormField(
            controller: widget.cpfController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly, CpfInputFormatter()],
            decoration: _inputDecoration("Digite seu CPF", isError: showCpfError),
            onChanged: (_) => setState(() {}),
          ),
          if (showCpfError) _buildErrorMsg("CPF inválido"),
          const SizedBox(height: 20),

          _buildLabel("Telefone"),
          const SizedBox(height: 8),
          TextFormField(
            controller: widget.phoneController,
            keyboardType: TextInputType.phone,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly, PhoneInputFormatter()],
            decoration: _inputDecoration("(xx) xxxxx-xxxx", isError: showPhoneError),
            onChanged: (_) => setState(() {}),
          ),
          if (showPhoneError) _buildErrorMsg("Telefone incorreto"),
          const SizedBox(height: 20),

          _buildLabel("Senha"),
          const SizedBox(height: 8),
          TextFormField(
            controller: widget.passwordController,
            obscureText: _obscurePassword,
            onChanged: _validatePassword,
            decoration: _inputDecoration("Digite sua senha", isError: _submitted && !_isPasswordValid).copyWith(
              suffixIcon: IconButton(
                icon: Icon(_obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
              ),
            ),
          ),
          const SizedBox(height: 20),
          _buildPasswordChecklist(),
          const SizedBox(height: 30),

          SizedBox(
            width: double.infinity, height: 50,
            child: ElevatedButton(
              onPressed: btnColor == const Color(0xFFC4C4C4) ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: btnColor,
                disabledBackgroundColor: const Color(0xFFC4C4C4),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text("Continuar", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) => Text(text, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13));

  Widget _buildErrorMsg(String msg) => Padding(
    padding: const EdgeInsets.only(top: 6),
    child: Row(children: [Icon(Icons.error, size: 14, color: Colors.red[900]), const SizedBox(width: 4), Text(msg, style: TextStyle(color: Colors.red[900], fontSize: 12))]),
  );

  InputDecoration _inputDecoration(String hint, {bool isError = false}) {
    return InputDecoration(
      hintText: hint, hintStyle: TextStyle(color: Colors.grey[400]),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: isError ? Colors.red.shade200 : const Color(0xFFDDDDDD))),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: isError ? Colors.red : const Color(0xFFFF8C00))),
    );
  }

  Widget _buildPasswordChecklist() {
    return Container(
      width: double.infinity, padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: const Color(0xFFF9F9F9), borderRadius: BorderRadius.circular(8)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("A sua senha deve ter", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          _buildRuleItem("Pelo menos 1 caractere minúsculo", _hasMinLower),
          _buildRuleItem("Pelo menos 1 caractere maiúsculo", _hasMinUpper),
          _buildRuleItem("Pelo menos 1 número", _hasMinNumber),
          _buildRuleItem("Pelo menos 8 caracteres", _hasMinLength),
        ],
      ),
    );
  }

  Widget _buildRuleItem(String text, bool isValid) {
    Widget icon;
    Color color;
    if (isValid) { icon = const Icon(Icons.check_circle_outline, color: Colors.green, size: 16); color = Colors.green; }
    else if (_submitted) { icon = const Icon(Icons.cancel_outlined, color: Colors.red, size: 16); color = Colors.red; }
    else { icon = const Icon(Icons.circle, color: Colors.black, size: 5); color = Colors.black87; }

    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(children: [SizedBox(width: 20, child: Center(child: icon)), const SizedBox(width: 8), Text(text, style: TextStyle(color: color, fontSize: 11))]),
    );
  }
}
