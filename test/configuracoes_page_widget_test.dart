import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:sigad/app/theme/app_theme.dart';
import 'package:sigad/features/configuracoes/presentation/pages/configuracoes_page.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('edita perfil com sucesso', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: const ConfiguracoesPage(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Perfil'));
    await tester.pumpAndSettle();

    expect(find.text('Editar Perfil'), findsOneWidget);

    final campos = find.byType(TextField);
    await tester.enterText(campos.first, 'Maria QA');
    await tester.enterText(campos.at(1), 'Coordenadora QA');

    await tester.tap(find.text('Salvar'));
    await tester.pumpAndSettle();

    expect(find.text('Nome: Maria QA'), findsOneWidget);
  });

  testWidgets('valida email invalido no modal de alteracao', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: const ConfiguracoesPage(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Email'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).first, 'email-invalido');
    await tester.tap(find.text('Enviar Código'));
    await tester.pump();

    expect(find.text('Informe um email válido'), findsOneWidget);
  });
}
