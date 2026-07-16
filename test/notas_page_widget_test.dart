import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:sigad/features/notas/presentation/pages/notas_page.dart';

Widget _buildApp() {
  return const MaterialApp(home: NotasPage());
}

Future<void> _remountNotasPage(WidgetTester tester) async {
  await tester.pumpWidget(const MaterialApp(home: SizedBox.shrink()));
  await tester.pumpAndSettle();
  await tester.pumpWidget(_buildApp());
  await tester.pumpAndSettle();
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('persiste criação e exclusão de anotação entre remontagens', (
    tester,
  ) async {
    const textoNota = 'Planejar reunião do colegiado';

    await tester.pumpWidget(_buildApp());
    await tester.pumpAndSettle();

    expect(
      find.text('Nenhuma anotação. Toque em "+" para criar.'),
      findsOneWidget,
    );

    await tester.tap(find.byTooltip('Nova anotação'));
    await tester.pumpAndSettle();
    final noteField = find.byWidgetPredicate(
      (widget) =>
          widget is TextField &&
          widget.decoration?.hintText ==
              'Registre uma ideia, encaminhamento ou lembrete...',
    );
    await tester.enterText(noteField, textoNota);
    await tester.tap(find.widgetWithText(ElevatedButton, 'Salvar'));
    await tester.pumpAndSettle();

    expect(find.text(textoNota), findsOneWidget);

    await _remountNotasPage(tester);

    expect(find.text(textoNota), findsOneWidget);

    await tester.tap(find.byTooltip('Excluir anotação'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(TextButton, 'Excluir'));
    await tester.pumpAndSettle();

    expect(find.text(textoNota), findsNothing);
    expect(
      find.text('Nenhuma anotação. Toque em "+" para criar.'),
      findsOneWidget,
    );

    await _remountNotasPage(tester);

    expect(find.text(textoNota), findsNothing);
    expect(
      find.text('Nenhuma anotação. Toque em "+" para criar.'),
      findsOneWidget,
    );
  });
}
