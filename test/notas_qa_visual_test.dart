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
      }
    }
  }
}
