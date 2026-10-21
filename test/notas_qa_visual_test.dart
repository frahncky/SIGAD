import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sigad/features/notas/presentation/pages/notas_page.dart';

void main() {
  const sizes = <Size>[
    Size(320, 568),
    Size(360, 640),
    Size(390, 844),
    Size(412, 915),
  ];

  for (final portrait in sizes) {
    for (final landscape in [false, true]) {
      final size = landscape ? Size(portrait.height, portrait.width) : portrait;
      for (final scale in [1.0, 1.5, 2.0]) {
        testWidgets('anotações ${size.width}x${size.height} fonte $scale', (
          tester,
        ) async {
          SharedPreferences.setMockInitialValues({});
          tester.view.devicePixelRatio = 1;
          tester.view.physicalSize = size;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);
          addTearDown(tester.view.resetViewInsets);
          await tester.pumpWidget(
            MaterialApp(
              builder: (context, child) => MediaQuery(
                data: MediaQuery.of(
                  context,
                ).copyWith(textScaler: TextScaler.linear(scale)),
                child: child!,
              ),
              home: const NotasPage(),
            ),
          );
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull, reason: 'lista vazia');
          await tester.tap(find.byTooltip('Nova anotação'));
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull, reason: 'diálogo aberto');
          tester.view.viewInsets = FakeViewPadding(bottom: size.height * .4);
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull, reason: 'teclado aberto');
          final input = find.descendant(
            of: find.byType(AlertDialog),
            matching: find.byType(TextField),
          );
          await tester.ensureVisible(input);
          await tester.enterText(
            input,
            'Anotação longa para verificar acesso ao campo e aos botões durante a digitação.',
          );
          final save = find.widgetWithText(ElevatedButton, 'Salvar');
          await tester.ensureVisible(save);
          await tester.tap(save);
          await tester.pumpAndSettle();
          expect(find.byType(AlertDialog), findsNothing);
          expect(tester.takeException(), isNull, reason: 'salvar com teclado');
        });

        testWidgets(
          'fixadas e erro de carga ${size.width}x${size.height} fonte $scale',
          (tester) async {
            SharedPreferences.setMockInitialValues({
              'sigad_notas': jsonEncode([
                for (var i = 0; i < 8; i++)
                  {
                    'id': 'n$i',
                    'texto':
                        'Anotação $i com texto longo para testar quebra '
                        'e reticências no card e na lista de fixadas.',
                    'data': '2026-10-${10 + i}T08:00:00',
                    'categoria': kCategoriasAnotacao[i % 6],
                    'fixada': i < 3,
                  },
              ]),
            });
            tester.view.devicePixelRatio = 1;
            tester.view.physicalSize = size;
            addTearDown(tester.view.resetPhysicalSize);
            addTearDown(tester.view.resetDevicePixelRatio);
            await tester.pumpWidget(app(scale));
            await tester.pumpAndSettle();
            expect(tester.takeException(), isNull, reason: 'lista com notas');
            final manage = find.text('Gerenciar fixadas');
            await tester.ensureVisible(manage);
            await tester.pumpAndSettle();
            await tester.tap(manage);
            await tester.pumpAndSettle();
            expect(find.byType(SwitchListTile), findsWidgets);
            expect(tester.takeException(), isNull, reason: 'sheet fixadas');
            Navigator.of(
              tester.element(find.byType(SwitchListTile).first),
            ).pop();
            await tester.pumpAndSettle();

            SharedPreferences.setMockInitialValues({'sigad_notas': '{'});
            await tester.pumpWidget(const SizedBox());
            await tester.pumpWidget(app(scale));
            await tester.pumpAndSettle();
            expect(find.text('Tentar novamente'), findsOneWidget);
            expect(find.text('Descartar registros inválidos'), findsOneWidget);
            expect(find.text('Todas as anotações'), findsNothing);
            expect(tester.takeException(), isNull, reason: 'erro de carga');
          },
        );
      }
    }
  }
}

Widget app(double scale) => MaterialApp(
  builder: (context, child) => MediaQuery(
    data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(scale)),
    child: child!,
  ),
  home: const NotasPage(),
);
