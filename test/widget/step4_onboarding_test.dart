import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:voomp_sellers_rebranding/src/core/features/auth/presentation/widgets/step4_onboarding.dart';
import 'package:voomp_sellers_rebranding/src/shared/widgets/custom_button.dart';

void main() {
  testWidgets('Step4Onboarding obriga seleção de objetivo', (WidgetTester tester) async {
    bool finished = false;

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Step4Onboarding(
          onFinish: () => finished = true,
        ),
      ),
    ));

    final btnFinder = find.widgetWithText(CustomButton, 'Continuar');

    // 1. Tenta clicar sem selecionar nada (Objetivo é obrigatório)
    await tester.tap(btnFinder);
    await tester.pump();

    // Deve mostrar mensagem de erro (SnackBar ou Texto de erro)
    expect(finished, isFalse);
    expect(find.text('Campo obrigatório'), findsOneWidget);

    // 2. Seleciona Dropdown (Opcional, mas testamos interação)
    // DropdownFormField é complexo de testar interação de clique exato no item,
    // mas podemos verificar se ele existe.
    expect(find.text('Como conheceu a Voomp Creators? (opcional)'), findsOneWidget);

    // 3. Seleciona Radio Button "Sim"
    await tester.tap(find.text('Sim'));
    await tester.pump();

    // Botão ainda deve falhar pois Objetivo é nulo
    await tester.tap(btnFinder);
    await tester.pump();
    expect(finished, isFalse);

    // 4. Seleciona Objetivo "Vender meus produtos"
    // Procuramos pelo texto dentro do Card
    await tester.tap(find.textContaining('Vender meus\nprodutos'));
    await tester.pump();

    // Agora o erro "Campo obrigatório" deve sumir
    expect(find.text('Campo obrigatório'), findsNothing);

    // Clica em Continuar
    await tester.tap(btnFinder);
    await tester.pump();

    expect(finished, isTrue);
  });
}
