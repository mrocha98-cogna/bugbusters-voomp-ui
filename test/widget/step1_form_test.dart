import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:voomp_sellers_rebranding/src/core/features/auth/presentation/widgets/step1_form.dart';
import 'package:voomp_sellers_rebranding/src/shared/widgets/custom_button.dart';

void main() {
  testWidgets('Step1Form valida campos e habilita botão', (WidgetTester tester) async {
    // Controllers mockados (Agora precisamos de ambos)
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    bool continuePressed = false;

    // Renderiza o widget envolto em MaterialApp
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Step1Form(
          nameController: nameController, // Passamos o controller aqui
          emailController: emailController,
          onContinue: () => continuePressed = true,
        ),
      ),
    ));

    // 1. Verifica estado inicial
    final buttonFinder = find.widgetWithText(CustomButton, 'Continuar');
    expect(buttonFinder, findsOneWidget);

    // Tenta clicar no botão vazio (deve falhar validação e não chamar onContinue)
    await tester.tap(buttonFinder);
    await tester.pump();
    expect(continuePressed, isFalse);

    // 2. Preenche apenas o nome
    // Nota: Como passamos o controller, podemos setar o texto direto ou usar tester.enterText
    await tester.enterText(find.widgetWithText(TextFormField, 'Nome Completo'), 'João Silva');
    await tester.pump();

    // 3. Preenche email inválido
    await tester.enterText(find.widgetWithText(TextFormField, 'E-mail'), 'email_invalido');
    await tester.pump();

    // Tenta clicar (deve falhar e mostrar erro)
    await tester.tap(buttonFinder);
    await tester.pump();
    expect(continuePressed, isFalse);
    expect(find.text('Digite um e-mail válido'), findsOneWidget);

    // 4. Preenche email válido
    await tester.enterText(find.widgetWithText(TextFormField, 'E-mail'), 'joao@email.com');
    await tester.pump();

    // Agora o botão deve funcionar
    await tester.tap(buttonFinder);
    await tester.pump();

    expect(continuePressed, isTrue);
    expect(nameController.text, 'João Silva');
    expect(emailController.text, 'joao@email.com');
  });
}
