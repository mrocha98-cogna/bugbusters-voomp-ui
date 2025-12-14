import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:voomp_sellers_rebranding/src/core/features/auth/presentation/widgets/step3_final_data.dart';
import 'package:voomp_sellers_rebranding/src/shared/widgets/custom_button.dart';

void main() {
  testWidgets('Step3FinalData valida CPF e Senha Forte', (WidgetTester tester) async {
    final cpfController = TextEditingController();
    final phoneController = TextEditingController();
    final passwordController = TextEditingController();
    bool finishPressed = false;

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView( // Necessário pois o teclado pode "tapar" widgets em testes pequenos
          child: Step3FinalData(
            cpfController: cpfController,
            phoneController: phoneController,
            passwordController: passwordController,
            onFinish: () => finishPressed = true,
          ),
        ),
      ),
    ));

    final btnFinder = find.widgetWithText(CustomButton, 'Continuar');

    // 1. Tenta submeter vazio
    await tester.tap(btnFinder);
    await tester.pump();
    expect(finishPressed, isFalse);
    expect(find.text('CPF obrigatório'), findsOneWidget);

    // 2. CPF Inválido
    await tester.enterText(find.widgetWithText(TextFormField, 'CPF'), '12345678900');
    await tester.pump();
    await tester.tap(btnFinder);
    await tester.pump();
    expect(find.text('CPF inválido'), findsOneWidget);

    // 3. CPF Válido (Matematicamente)
    await tester.enterText(find.widgetWithText(TextFormField, 'CPF'), '52998224725');
    await tester.pump();

    // 4. Telefone
    await tester.enterText(find.widgetWithText(TextFormField, 'Telefone'), '11999999999');
    await tester.pump();

    // 5. Senha Fraca (apenas letras)
    await tester.enterText(find.widgetWithText(TextFormField, 'Senha'), 'senhafraca');
    await tester.pump();
    // Verifica se checklist visual atualizou (ícones vermelhos ou não verdes)
    // Uma forma de testar é tentar submeter e ver se falha
    await tester.tap(btnFinder);
    await tester.pump();
    expect(finishPressed, isFalse);

    // 6. Senha Forte (Maiúscula, minúscula, número, 8 chars)
    await tester.enterText(find.widgetWithText(TextFormField, 'Senha'), 'SenhaForte1');
    await tester.pump();

    // Agora deve passar
    await tester.tap(btnFinder);
    await tester.pump();
    expect(finishPressed, isTrue);

    // Verifica se os controllers foram populados
    expect(cpfController.text, contains('529')); // Formatter pode ter adicionado pontos
    expect(passwordController.text, 'SenhaForte1');
  });
}
