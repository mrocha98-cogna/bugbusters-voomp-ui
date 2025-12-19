import 'package:flutter/material.dart';

class MaxWidthContainer extends StatelessWidget {
  final Widget child;
  final double maxWidth;

  const MaxWidthContainer({
    super.key,
    required this.child,
    this.maxWidth = 920.0, // Limite padrão de 1200px (comum na web)
  });

  @override
  Widget build(BuildContext context) {
    // Align topCenter garante que o conteúdo fique centralizado horizontalmente
    // mas comece do topo verticalmente.
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: SizedBox(
          width: double.infinity, // Garante que o conteúdo ocupe a largura disponível até o limite
          child: child,
        ),
      ),
    );
  }
}
