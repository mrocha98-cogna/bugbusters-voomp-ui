import 'package:flutter/material.dart';
import 'package:voomp_sellers_rebranding/src/shared/widgets/custom_button.dart';

class Step1Form extends StatefulWidget {
  final TextEditingController nameController; // Adicione este
  final TextEditingController emailController;  final VoidCallback onContinue;

  const Step1Form({
    super.key,
    required this.nameController, // Requira no construtor
    required this.emailController,
    required this.onContinue,
  });

  @override
  State<Step1Form> createState() => _Step1FormState();
}

class _Step1FormState extends State<Step1Form> {
  final _formKey = GlobalKey<FormState>();

  // Regex de Email
  final RegExp _emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

  bool get _isValid =>
      widget.nameController.text.trim().isNotEmpty && // Use widget.
          _emailRegex.hasMatch(widget.emailController.text.trim());

  @override
  void dispose() {
    // REMOVA: _nameController.dispose(); (O Pai cuida disso agora)
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      widget.onContinue();
    }
  }

  @override
  Widget build(BuildContext context) {
    final buttonColor = _isValid ? const Color(0xFFFE8700) : const Color(0xFFC4C4C4);

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Campo Nome
          const Text("Nome Completo", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          const SizedBox(height: 8),
          TextFormField(
            controller: widget.nameController,
            decoration: _inputDecoration("Digite seu nome"),
            onChanged: (_) => setState(() {}),
            validator: (value) => (value == null || value.isEmpty) ? 'Por favor, digite seu nome' : null,
          ),
          const SizedBox(height: 20),

          // Campo Email
          const Text("E-mail", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          const SizedBox(height: 8),
          TextFormField(
            controller: widget.emailController, // Usa o controller do pai
            decoration: _inputDecoration("Digite seu e-mail"),
            onChanged: (_) => setState(() {}),
            validator: (value) {
              if (value == null || value.isEmpty) return 'O e-mail é obrigatório';
              if (!_emailRegex.hasMatch(value)) return 'Digite um e-mail válido';
              return null;
            },
          ),
          const SizedBox(height: 6),
          const Text("ex: seunome@gmail.com", style: TextStyle(fontSize: 11, color: Colors.grey)),
          const SizedBox(height: 30),

          // Botão (agora usando o CustomButton)
          CustomButton(
            text: "Continuar",
            onPressed: _isValid ? _submit : null, // Se for null, o botão fica disabled (cinza) automaticamente pela lógica interna
            backgroundColor: buttonColor,
          ),
        ],
      ),
    );
  }

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
    );
  }
}
