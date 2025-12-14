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
  // Regex simples para validação visual
  final _emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');

  bool get _isValid =>
      widget.nameController.text.trim().isNotEmpty &&
          _emailRegex.hasMatch(widget.emailController.text.trim());

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Form(
      key: _formKey,
      onChanged: () => setState(() {}), // Atualiza UI ao digitar para validar botão
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            "Dados Pessoais",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 24),

          // Nome
          TextFormField(
            controller: widget.nameController,
            style: TextStyle(color: theme.colorScheme.onSurface),
            decoration: const InputDecoration(
              labelText: 'Nome Completo',
              prefixIcon: Icon(Icons.person_outline),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Nome obrigatório';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Email
          TextFormField(
            controller: widget.emailController,
            style: TextStyle(color: theme.colorScheme.onSurface),
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: 'E-mail',
              prefixIcon: Icon(Icons.email_outlined),
            ),
            validator: (value) {
              if (value == null || !_emailRegex.hasMatch(value)) {
                return 'Digite um e-mail válido';
              }
              return null;
            },
          ),
          const SizedBox(height: 32),

          // Botão Continuar
          SizedBox(
            height: 50,
            child: ElevatedButton(
              onPressed: _isValid ? widget.onContinue : null,
              // O estilo vem do Theme, mas o estado 'disabled' é automático
              child: const Text("Continuar"),
            ),
          ),
        ],
      ),
    );
  }
}
