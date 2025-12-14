import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:voomp_sellers_rebranding/src/core/features/auth/presentation/widgets/step2_verification.dart';
import 'package:voomp_sellers_rebranding/src/shared/widgets/custom_button.dart';

void main() {
  testWidgets('Step2Verification valida código correto', (WidgetTester tester) async {
    bool continuePressed = false;

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Step2Verification(
          email: 'teste@teste.com',
          onContinue: () => continuePressed = true,
        ),
      ),
    ));

    // Verifica se exibe o email passado
    expect(find.text('teste@teste.com'), findsOneWidget);

    // Encontra os campos de código (são 6 TextFormFields)
    final codeFields = find.byType(TextFormField);
    expect(codeFields, findsNWidgets(6));

    // Tenta digitar código errado: 111111
    for (int i = 0; i < 6; i++) {
      await tester.enterText(codeFields.at(i), '1');
      await tester.pump(); // refresh ui
    }

    // Clica em continuar
    await tester.tap(find.widgetWithText(CustomButton, 'Continuar'));
    await tester.pump();

    // Deve mostrar erro e NÃO chamar onContinue
    expect(find.text('O código está incorreto'), findsOneWidget);
    expect(continuePressed, isFalse);

    // Digita código correto: 123456 (Simulação hardcoded no widget)
    // Limpar campos é complexo no teste, vamos apenas sobrescrever
    // Nota: No teste de integração é sequencial, aqui podemos injetar direto se tivéssemos controllers,
    // mas como o Step2 gerencia seus próprios controllers internos, usamos enterText.
    await tester.enterText(codeFields.at(0), '1');
    await tester.enterText(codeFields.at(1), '2');
    await tester.enterText(codeFields.at(2), '3');
    await tester.enterText(codeFields.at(3), '4');
    await tester.enterText(codeFields.at(4), '5');
    await tester.enterText(codeFields.at(5), '6');
    await tester.pump();

    // O erro deve sumir ao digitar
    expect(find.text('O código está incorreto'), findsNothing);

    // Clica em continuar
    await tester.tap(find.widgetWithText(CustomButton, 'Continuar'));
    await tester.pump();

    expect(continuePressed, isTrue);
  });
}
