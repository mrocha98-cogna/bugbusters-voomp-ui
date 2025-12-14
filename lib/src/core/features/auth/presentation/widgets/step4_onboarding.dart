import 'package:flutter/material.dart';
import 'package:voomp_sellers_rebranding/src/shared/widgets/custom_button.dart';

class Step4Onboarding extends StatefulWidget {
  final VoidCallback onFinish;

  const Step4Onboarding({super.key, required this.onFinish});

  @override
  State<Step4Onboarding> createState() => _Step4OnboardingState();
}

class _Step4OnboardingState extends State<Step4Onboarding> {
  // Estado dos campos
  String? _selectedOrigin;
  String? _sellsOnline; // "Sim" ou "Não"
  String? _selectedGoal; // "Vender meus produtos" ou "Ser afiliado"

  // Opções do Dropdown
  final List<String> _originOptions = [
    "Amigo ou colega",
    "Anúncio",
    "Artigo ou post de blog",
    "Evento ou feira",
    "Podcast ou vídeo",
    "Post nas redes sociais",
    "Pesquisa online",
    "Colaborador cogna",
    "Outros",
    "Não quero informar"
  ];

  bool get _canSubmit => _selectedGoal != null;

  @override
  Widget build(BuildContext context) {
    // Cor do botão baseada na validação
    final buttonColor = _canSubmit ? const Color(0xFFFE8700) : const Color(0xFFC4C4C4);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Dropdown "Como conheceu"
        _buildLabel("Como conheceu a Voomp Creators?", optional: true),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _selectedOrigin,
          icon: const Icon(Icons.keyboard_arrow_down),
          decoration: _inputDecoration("Selecione uma opção"),

          // Expande o dropdown para preencher a largura e evitar erros de layout
          isExpanded: true,

          // Limita a altura do menu para exibir aprox. 4 itens (4 * 48px = ~192px)
          menuMaxHeight: 200,

          // Configurações visuais do Menu
          dropdownColor: Colors.white,
          borderRadius: BorderRadius.circular(8), // Arredonda o menu suspenso

          // Estilo dos itens dentro do menu
          items: _originOptions.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(
                  value,
                  style: const TextStyle(fontSize: 14, color: Colors.black87)
              ),
            );
          }).toList(),

          onChanged: (newValue) {
            setState(() {
              _selectedOrigin = newValue;
            });
          },
          // Estilo do texto selecionado (input fechado)
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 14,
            overflow: TextOverflow.ellipsis, // Evita quebra de linha se o texto for longo
          ),
          // Garante que o texto selecionado no campo tenha a cor correta
          selectedItemBuilder: (BuildContext context) {
            return _originOptions.map<Widget>((String item) {
              return Text(item, style: const TextStyle(color: Colors.black87));
            }).toList();
          },
        ),

        const SizedBox(height: 20),

        // 2. Radio "Você já vende pela internet?"
        _buildLabel("Você já vende pela internet?", optional: true),
        const SizedBox(height: 8),
        Row(
          children: [
            _buildRadioOption("Sim"),
            const SizedBox(width: 20),
            _buildRadioOption("Não"),
          ],
        ),

        const SizedBox(height: 20),

        // 3. Objetivo na Voomp (Cards Selecionáveis)
        _buildLabel("Seu objetivo na Voomp é", optional: false),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildGoalCard("Vender meus\nprodutos", "vender"),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildGoalCard("Ser afiliado", "afiliado"),
            ),
          ],
        ),

        const SizedBox(height: 30),

        // 4. Botão Continuar
        CustomButton(
          text: "Continuar",
          onPressed: _canSubmit ? widget.onFinish : null,
          backgroundColor: buttonColor,
        ),
      ],
    );
  }

  // --- WIDGETS AUXILIARES ---

  Widget _buildLabel(String text, {bool optional = false}) {
    return RichText(
      text: TextSpan(
        text: text,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87),
        children: optional
            ? [
          const TextSpan(
            text: " (opcional)",
            style: TextStyle(color: Colors.grey, fontWeight: FontWeight.normal),
          )
        ]
            : [],
      ),
    );
  }

  // Widget para os Radio Buttons Customizados
  Widget _buildRadioOption(String value) {
    final isSelected = _sellsOnline == value;

    return GestureDetector(
      onTap: () {
        setState(() {
          _sellsOnline = value;
        });
      },
      child: Row(
        children: [
          // Círculo externo
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? const Color(0xFF6B4E31) : Colors.black, // Marrom se selecionado, preto se não
                width: 2,
              ),
            ),
            child: isSelected
                ? Center(
              child: Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFF6B4E31), // Marrom
                ),
              ),
            )
                : null,
          ),
          const SizedBox(width: 8),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
        ],
      ),
    );
  }

  // Widget para os Cards de Objetivo (Vender vs Afiliado)
  Widget _buildGoalCard(String label, String value) {
    final isSelected = _selectedGoal == value;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedGoal = value;
        });
      },
      child: Container(
        height: 60, // Altura fixa para alinhar
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF0E6), // Fundo bege claro padrão
          border: Border.all(
            color: isSelected ? const Color(0xFFFE8700) : Colors.transparent, // Borda laranja se selecionado
            width: 2,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: Colors.black87,
            ),
          ),
        ),
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
        borderSide: const BorderSide(color: Color(0xFFDDDDDD)), // Borda cinza padrão
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFF6B4E31)), // Borda marrom ao focar
      ),
    );
  }
}
