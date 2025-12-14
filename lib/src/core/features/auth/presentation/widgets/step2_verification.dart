import 'package:flutter/material.dart';
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
  // Lista de controllers para os 6 dígitos
  final List<TextEditingController> _controllers = List.generate(6, (_) => TextEditingController());
  // Lista de FocusNodes para pular pro próximo campo
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  String? _errorMessage;

  @override
  void dispose() {
    for (var c in _controllers) { c.dispose(); }
    for (var f in _focusNodes) { f.dispose(); }
    super.dispose();
  }

  void _validateAndSubmit() {
    final code = _controllers.map((c) => c.text).join();
    if (code.length < 6) return;

    // Simulação de validação
    if (code == "123456") {
      widget.onContinue();
    } else {
      setState(() {
        _errorMessage = "O código está incorreto";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          "Verifique seu e-mail",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface),
        ),
        const SizedBox(height: 8),
        Text(
          "Enviamos um código para ${widget.email}",
          style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.6)),
        ),
        const SizedBox(height: 32),

        // Campos de Código (Pin Input)
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(6, (index) {
            return SizedBox(
              width: 45,
              height: 55,
              child: TextFormField(
                controller: _controllers[index],
                focusNode: _focusNodes[index],
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface),
                keyboardType: TextInputType.number,
                maxLength: 1,
                decoration: InputDecoration(
                  counterText: "",
                  contentPadding: EdgeInsets.zero,
                  // Borda muda se tiver erro
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: _errorMessage != null ? AppPalette.error500 : theme.colorScheme.outline,
                    ),
                  ),
                ),
                onChanged: (value) {
                  setState(() => _errorMessage = null); // Limpa erro ao digitar
                  if (value.isNotEmpty && index < 5) {
                    _focusNodes[index + 1].requestFocus();
                  }
                  if (value.isEmpty && index > 0) {
                    _focusNodes[index - 1].requestFocus();
                  }
                },
              ),
            );
          }),
        ),

        // Mensagem de Erro
        if (_errorMessage != null)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Row(
              children: [
                const Icon(Icons.error_outline, color: AppPalette.error500, size: 16),
                const SizedBox(width: 4),
                Text(_errorMessage!, style: const TextStyle(color: AppPalette.error500, fontSize: 12)),
              ],
            ),
          ),

        const SizedBox(height: 32),
        SizedBox(
          height: 50,
          child: ElevatedButton(
            onPressed: _validateAndSubmit,
            child: const Text("Verificar"),
          ),
        ),

        const SizedBox(height: 16),
        Center(
          child: TextButton(
            onPressed: () {}, // Lógica de reenviar
            child: const Text("Reenviar código"),
          ),
        ),
      ],
    );
  }
}
