import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:voomp_sellers_rebranding/main.dart' as app;
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Fluxo completo de cadastro: Passo 1 -> Passo 2 -> Passo 3',
          (WidgetTester tester) async {
        // Inicia o app
        app.main();
        await tester.pumpAndSettle();

        // --- PASSO 1: DADOS BÁSICOS ---
        print('Iniciando Passo 1...');

        // Preenche Nome
        final nameField = find.widgetWithText(TextFormField, 'Digite seu nome');
        await tester.enterText(nameField, 'Usuário Teste');
        await tester.pumpAndSettle();

        // Preenche Email
        final emailField = find.widgetWithText(TextFormField, 'Digite seu e-mail');
        await tester.enterText(emailField, 'teste@voomp.com');
        await tester.pumpAndSettle();

        // Clica em Continuar
        final continueButton1 = find.text('Continuar');
        await tester.tap(continueButton1);
        await tester.pumpAndSettle();

        // --- PASSO 2: CÓDIGO DE VERIFICAÇÃO ---
        print('Iniciando Passo 2...');

        // Verifica se estamos na tela do código (procurando texto específico)
        expect(find.textContaining('digite o código que'), findsOneWidget);

        // Preenche o código correto (123456)
        // Como são 6 campos separados, vamos encontrar todos os TextFormFields dessa tela
        final codeFields = find.byType(TextFormField);
        // Nota: O finder pode achar campos ocultos anteriores, então pegamos os últimos 6 ou usamos keys específicas.
        // Uma abordagem segura em integração é digitar nos focos.

        // Simula a digitação sequencial
        await tester.enterText(codeFields.at(0), '1');
        await tester.pump();
        await tester.enterText(codeFields.at(1), '2');
        await tester.pump();
        await tester.enterText(codeFields.at(2), '3');
        await tester.pump();
        await tester.enterText(codeFields.at(3), '4');
        await tester.pump();
        await tester.enterText(codeFields.at(4), '5');
        await tester.pump();
        await tester.enterText(codeFields.at(5), '6');
        await tester.pumpAndSettle(); // Espera animações/transições

        // O fluxo atual avança automaticamente ou precisamos clicar?
        // No código do Step2Verification, ele chama submit se o código for igual.
        // Se o botão habilitar, clicamos.

        final continueButton2 = find.text('Continuar');
        await tester.tap(continueButton2);
        await tester.pumpAndSettle();

        // --- PASSO 3: DADOS FINAIS ---
        print('Iniciando Passo 3...');

        // Verifica se chegou no passo 3 (campo CPF)
        expect(find.text('CPF'), findsOneWidget);

        // Preenche CPF (use um válido para passar no validador)
        await tester.enterText(find.widgetWithText(TextFormField, 'Digite seu CPF'), '52998224725');

        // Preenche Telefone
        await tester.enterText(find.widgetWithText(TextFormField, '(xx) xxxxx-xxxx'), '11999999999');

        // Preenche Senha (com requisitos: maiúscula, minúscula, número, 8 chars)
        await tester.enterText(find.widgetWithText(TextFormField, 'Digite sua senha'), 'SenhaForte123');
        await tester.pumpAndSettle();

        // Clica em Finalizar/Continuar
        final finishButton = find.text('Continuar');
        await tester.tap(finishButton);
        await tester.pumpAndSettle();

        // Verifica Feedback de Sucesso (SnackBar)
        expect(find.text('Cadastro Finalizado!'), findsOneWidget);
      });
}
