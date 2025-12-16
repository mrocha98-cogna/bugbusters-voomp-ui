import 'package:flutter/material.dart';
import 'package:voomp_sellers_rebranding/src/core/theme/app_colors.dart';

class Step4Onboarding extends StatefulWidget {
  // Alteramos o callback para devolver os dados preenchidos
  final Function({
  required String howKnew,
  required bool alreadySellOnline,
  required String goal,
  }) onFinish;

  const Step4Onboarding({
    super.key,
    required this.onFinish,
  });

  @override
  State<Step4Onboarding> createState() => _Step4OnboardingState();
}

class _Step4OnboardingState extends State<Step4Onboarding> {
  // Inicializamos com valores padrão ou nulos
  String? _selectedSource; // howKnew
  bool _salesExperience = false; // alreadySellOnline (default false)
  String? _selectedObjective; // goal

  // Lista de Opções do Dropdown
  final List<String> _sourceOptions = [
    "Amigo ou colega",
    "Anúncio",
    "Artigo ou post de blog",
    "Evento ou feira",
    "Podcast ou vídeo",
    "Post nas redes sociais",
    "Pesquisa online",
    "Colaborador cogna",
    "Outros"
  ];

  // Apenas o objetivo parece ser estritamente obrigatório para o fluxo
  bool get _isValid => _selectedObjective != null;

  void _submit() {
    if (_isValid) {
      widget.onFinish(
        howKnew: _selectedSource ?? "notInformed",
        alreadySellOnline: _salesExperience,
        goal: _selectedObjective!,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Cor bege claro para cards desabilitados
    final unselectedCardColor = const Color(0xFFFFF5EB);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // --- DROPDOWN: COMO CONHECEU ---
        _buildLabel("Como conheceu a Voomp Creators?", optional: true, theme: theme),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _selectedSource,
          icon: const Icon(Icons.keyboard_arrow_down),
          elevation: 2,
          dropdownColor: Colors.white,
          menuMaxHeight: 250,
          style: TextStyle(color: theme.colorScheme.onSurface, fontSize: 14),
          decoration: _inputDecoration(theme),
          hint: Text(
            "Selecione uma opção",
            style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.4)),
          ),
          items: _sourceOptions.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          onChanged: (newValue) {
            setState(() => _selectedSource = newValue);
          },
        ),

        const SizedBox(height: 20),

        // --- RADIO: JÁ VENDE PELA INTERNET? ---
        _buildLabel("Você já vende pela Internet?", optional: true, theme: theme),
        const SizedBox(height: 8),
        Row(
          children: [
            _buildRadioButton(
              label: "Sim",
              value: true,
              groupValue: _salesExperience,
              onChanged: (v) => setState(() => _salesExperience = v ?? false),
              theme: theme,
            ),
            const SizedBox(width: 24),
            _buildRadioButton(
              label: "Não",
              value: false,
              groupValue: _salesExperience,
              onChanged: (v) => setState(() => _salesExperience = v ?? false),
              theme: theme,
            ),
          ],
        ),

        const SizedBox(height: 20),

        // --- CARDS: OBJETIVO ---
        _buildLabel("Seu objetivo na Voomp é:", theme: theme),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildObjectiveCard(
                label: "Vender meus\nprodutos",
                value: "sell", // Ajustado para bater com o DTO ("sell")
                unselectedColor: unselectedCardColor,
                theme: theme,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildObjectiveCard(
                label: "Ser afiliado",
                value: "affiliate",
                unselectedColor: unselectedCardColor,
                theme: theme,
              ),
            ),
          ],
        ),

        const SizedBox(height: 32),

        // --- BOTÃO CONTINUAR ---
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: _isValid ? _submit : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: _isValid ? AppPalette.orange500 : AppPalette.neutral300,
              foregroundColor: _isValid ? Colors.white : AppPalette.neutral600,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              "Finalizar Cadastro", // Texto alterado para fazer sentido
              style: TextStyle(fontSize: 16, color: AppPalette.surfaceText, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }

  // --- WIDGETS AUXILIARES ---

  Widget _buildLabel(String text, {bool optional = false, required ThemeData theme}) {
    return RichText(
      text: TextSpan(
        text: text,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: theme.colorScheme.onSurface,
          fontFamily: theme.textTheme.bodyMedium?.fontFamily,
        ),
        children: [
          if (optional)
            TextSpan(
              text: " (opcional)",
              style: TextStyle(
                fontWeight: FontWeight.normal,
                color: theme.colorScheme.onSurface.withOpacity(0.5),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRadioButton({
    required String label,
    required bool value,
    required bool groupValue,
    required Function(bool?) onChanged,
    required ThemeData theme,
  }) {
    final isSelected = value == groupValue;
    return InkWell(
      onTap: () => onChanged(value),
      borderRadius: BorderRadius.circular(4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Radio<bool>(
            value: value,
            groupValue: groupValue,
            onChanged: onChanged,
            activeColor: AppPalette.orange500,
            fillColor: MaterialStateProperty.resolveWith((states) {
              if (states.contains(MaterialState.selected)) {
                return const Color(0xFF5E3F29);
              }
              return theme.colorScheme.onSurface;
            }),
          ),
          Text(
            label,
            style: TextStyle(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildObjectiveCard({
    required String label,
    required String value,
    required Color unselectedColor,
    required ThemeData theme,
  }) {
    final isSelected = _selectedObjective == value;

    return GestureDetector(
      onTap: () => setState(() => _selectedObjective = value),
      child: Container(
        height: 80,
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? theme.cardTheme.color : unselectedColor,
          borderRadius: BorderRadius.circular(8),
          border: isSelected ? Border.all(color: AppPalette.orange500, width: 1.5) : null,
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: Colors.black,
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(ThemeData theme) {
    return InputDecoration(
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
    );
  }
}
