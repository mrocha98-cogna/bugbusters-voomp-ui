import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:voomp_sellers_rebranding/src/core/features/auth/presentation/widgets/step4_onboarding.dart';
import 'package:voomp_sellers_rebranding/src/core/theme/app_colors.dart';

void main() {
  testWidgets('Step4Onboarding obriga seleção de objetivo e envia dados corretamente',
          (WidgetTester tester) async {
        // Variáveis para capturar os dados retornados pelo widget
        bool finished = false;
        String? capturedHowKnew;
        bool? capturedAlreadySellOnline;
        String? capturedGoal;

        await tester.pumpWidget(MaterialApp(
          home: Scaffold(
            body: Step4Onboarding(
              onFinish: ({
                required String howKnew,
                required bool alreadySellOnline,
                required String goal,
              }) {
                finished = true;
                capturedHowKnew = howKnew;
                capturedAlreadySellOnline = alreadySellOnline;
                capturedGoal = goal;
              },
            ),
          ),
        ));

        // Identificamos o botão pelo texto "Finalizar Cadastro"
        final btnFinder = find.widgetWithText(ElevatedButton, 'Finalizar Cadastro');

        // 1. Verifica estado inicial (Botão deve estar desabilitado visualmente ou não funcional)
        // O widget que implementamos usa a propriedade onPressed: _isValid ? _submit : null
        // Portanto, se não é válido, o botão está disabled.
        final buttonWidget = tester.widget<ElevatedButton>(btnFinder);
        expect(buttonWidget.onPressed, isNull, reason: "Botão deve estar desabilitado inicialmente");

        // 2. Interage com o Radio Button "Sim" (Já vende pela internet)
        await tester.tap(find.text('Sim'));
        await tester.pump();

        // 3. Seleciona o Objetivo "Vender meus produtos"
        // O texto no widget tem uma quebra de linha: "Vender meus\nprodutos"
        final cardVenderFinder = find.text("Vender meus\nprodutos");
        expect(cardVenderFinder, findsOneWidget);

        await tester.tap(cardVenderFinder);
        await tester.pump();

        // 4. Agora o formulário é válido, o botão deve estar habilitado
        final buttonWidgetEnabled = tester.widget<ElevatedButton>(btnFinder);
        expect(buttonWidgetEnabled.onPressed, isNotNull, reason: "Botão deve habilitar após selecionar objetivo");

        // 5. Clica no botão para finalizar
        await tester.tap(btnFinder);
        await tester.pump();

        // 6. Verifica se os dados foram enviados corretamente
        expect(finished, isTrue);
        expect(capturedGoal, 'sell'); // Valor interno mapeado no widget
        expect(capturedAlreadySellOnline, isTrue);
        expect(capturedHowKnew, 'notInformed'); // Valor padrão pois não selecionamos o dropdown
      });
}
