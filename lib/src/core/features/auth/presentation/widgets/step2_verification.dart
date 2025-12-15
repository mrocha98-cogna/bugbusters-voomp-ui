import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Necessário para filtrar apenas números
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
  // 6 Controllers e 6 FocusNodes para manipular o foco entre os dígitos
  final List<TextEditingController> _controllers = List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  // Estado para validar se todos os campos estão preenchidos
  bool _isValid = false;

  @override
  void initState() {
    super.initState();
    // Ouve mudanças em todos os controllers para validar o botão
    for (var controller in _controllers) {
      controller.addListener(_validateForm);
    }
  }

  @override
  void dispose() {
    for (var c in _controllers) { c.dispose(); }
    for (var f in _focusNodes) { f.dispose(); }
    super.dispose();
  }

  void _validateForm() {
    // Verifica se todos os campos tem pelo menos 1 caractere
    final allFilled = _controllers.every((c) => c.text.isNotEmpty);
    if (allFilled != _isValid) {
      setState(() {
        _isValid = allFilled;
      });
    }
  }

  void _onDigitEntered(int index, String value) {
    if (value.isNotEmpty) {
      // Se digitou e não é o último, vai para o próximo
      if (index < 5) {
        _focusNodes[index + 1].requestFocus();
      } else {
        // Se é o último, tira o foco (fecha teclado)
        _focusNodes[index].unfocus();
      }
    } else {
      // Se apagou (ficou vazio) e não é o primeiro, volta para o anterior
      if (index > 0) {
        _focusNodes[index - 1].requestFocus();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center, // Centraliza tudo horizontalmente
      children: [

        // --- TEXTOS DE INSTRUÇÃO ---
        Text(
          "Por favor, digite o código que\nenviamos para o email:",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            height: 1.5,
            color: theme.colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          widget.email,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),

        const SizedBox(height: 32),

        // --- INPUTS DE CÓDIGO (LINHA ÚNICA) ---
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(6, (index) {
            return _buildSingleDigitInput(index, theme);
          }),
        ),

        const SizedBox(height: 32),

        // --- RODAPÉ "NÃO ENCONTROU?" ---
        Text(
          "Não encontrou?",
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          "Confira na aba Spam ou Promoções do\nseu e-mail.",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            color: theme.colorScheme.onSurface.withOpacity(0.5),
          ),
        ),

        const SizedBox(height: 32),

        // --- BOTÃO CONTINUAR ---
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: _isValid ? widget.onContinue : null,
            style: ElevatedButton.styleFrom(
              // Cor Laranja (conforme imagem) quando ativo
              backgroundColor: _isValid ? AppPalette.orange500 : AppPalette.neutral300,
              foregroundColor: Colors.white,
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
    );
  }

  // Widget auxiliar para cada dígito (Estilo Underline)
  Widget _buildSingleDigitInput(int index, ThemeData theme) {
    return SizedBox(
      width: 40,
      child: TextFormField(
        controller: _controllers[index],
        focusNode: _focusNodes[index],
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        maxLength: 1, // Apenas 1 dígito

        // Estilo do texto (Grande e Negrito como na imagem)
        style: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: theme.colorScheme.onSurface,
        ),

        // Filtra para aceitar apenas dígitos
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
        ],

        decoration: InputDecoration(
          counterText: "", // Esconde o contador "0/1"
          contentPadding: const EdgeInsets.symmetric(vertical: 8),

          // Borda habilitada (Linha cinza)
          enabledBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: AppPalette.neutral400, width: 2),
          ),

          // Borda Focada (Linha preta ou laranja)
          focusedBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: AppPalette.neutral800, width: 2),
          ),

          // Borda sem foco (para garantir alinhamento)
          border: const UnderlineInputBorder(
            borderSide: BorderSide(color: AppPalette.neutral300),
          ),
        ),

        onChanged: (value) => _onDigitEntered(index, value),
      ),
    );
  }
}
