import 'package:flutter/material.dart';
import 'package:voomp_sellers_rebranding/src/shared/widgets/custom_button.dart';

class Step2Verification extends StatefulWidget {  final String email;
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
  final List<TextEditingController> _codeControllers = List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  // Simulação do código correto
  final String _correctCode = "123456";
  bool _hasError = false;

  bool get _isFull => _codeControllers.every((c) => c.text.isNotEmpty);

  @override
  void dispose() {
    for (var c in _codeControllers) c.dispose();
    for (var n in _focusNodes) n.dispose();
    super.dispose();
  }

  void _submit() {
    String inputCode = _codeControllers.map((e) => e.text).join();

    if (inputCode == _correctCode) {
      widget.onContinue();
    } else {
      setState(() => _hasError = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Cores dinâmicas baseadas no erro
    final textColor = _hasError ? const Color(0xFF9E2A2B) : Colors.grey;
    final borderColor = _hasError ? const Color(0xFFE09F9F) : Colors.grey.shade300;
    final focusedColor = _hasError ? const Color(0xFF9E2A2B) : const Color(0xFFFF8C00);

    // Botão fica laranja se estiver preenchido e sem erro visível
    final canSubmit = _isFull && !_hasError;
    final buttonColor = canSubmit ? const Color(0xFFFE8700) : const Color(0xFFC4C4C4);

    return Column(
      children: [
        const Text(
          "Por favor, digite o código que\nenviamos para o email:",
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.black87, fontSize: 14),
        ),
        const SizedBox(height: 12),
        Text(
          widget.email,
          textAlign: TextAlign.center,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF1E2A45)),
        ),
        const SizedBox(height: 30),

        // 6 Campos de Digitação
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(6, (index) {
            return SizedBox(
              width: 45,
              height: 55,
              child: TextFormField(
                controller: _codeControllers[index],
                focusNode: _focusNodes[index],
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: _codeControllers[index].text.isNotEmpty ? textColor : Colors.grey.shade300,
                ),
                maxLength: 1,
                decoration: InputDecoration(
                  counterText: "",
                  enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: borderColor, width: 2)),
                  focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: focusedColor, width: 2)),
                  hintText: "0",
                  hintStyle: TextStyle(color: Colors.grey.shade300),
                ),
                onChanged: (value) {
                  // Limpa o erro ao digitar
                  if (_hasError) setState(() => _hasError = false);
                  else setState(() {}); // Atualiza estado do botão

                  // Pular foco
                  if (value.isNotEmpty && index < 5) _focusNodes[index + 1].requestFocus();
                  // Voltar foco
                  if (value.isEmpty && index > 0) _focusNodes[index - 1].requestFocus();
                },
              ),
            );
          }),
        ),

        const SizedBox(height: 20),

        // Caixa de Erro
        if (_hasError)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFF9EAE9),
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error, color: Color(0xFF5A1A1A), size: 18),
                SizedBox(width: 8),
                Text(
                  "O código está incorreto",
                  style: TextStyle(color: Color(0xFF5A1A1A), fontSize: 13, fontWeight: FontWeight.w500),
                )
              ],
            ),
          ),

        const SizedBox(height: 20),
        const Text("Não encontrou?", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        const SizedBox(height: 4),
        const Text(
          "Confira na aba Spam ou Promoções do\nseu e-mail.",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
        const SizedBox(height: 30),

        CustomButton(
          text: "Continuar",
          onPressed: canSubmit ? _submit : null,
          backgroundColor: buttonColor,
        ),
      ],
    );
  }
}
