import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:sigad/app/theme/app_theme.dart';
import 'package:sigad/core/models/user.dart';
import 'package:sigad/core/models/user_role.dart';
import 'package:sigad/core/services/user_context_provider.dart';
import 'package:sigad/features/configuracoes/presentation/pages/configuracoes_page.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('edita perfil com sucesso', (tester) async {
    final userContext = UserContextProvider();
    await userContext.login(
      User(
        id: 'cfg-chefe',
        name: 'Chefia Teste',
        email: 'chefe@sigad.dev',
        role: UserRole.chefeDepartamento,
        createdAt: DateTime(2026, 1, 1),
      ),
    );

    await tester.pumpWidget(
      ChangeNotifierProvider<UserContextProvider>.value(
        value: userContext,
        child: MaterialApp(
          theme: AppTheme.light(),
          home: const ConfiguracoesPage(),
        ),
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
    final userContext = UserContextProvider();
    await userContext.login(
      User(
        id: 'cfg-chefe-2',
        name: 'Chefia Teste 2',
        email: 'chefe2@sigad.dev',
        role: UserRole.chefeDepartamento,
        createdAt: DateTime(2026, 1, 1),
      ),
    );

    await tester.pumpWidget(
      ChangeNotifierProvider<UserContextProvider>.value(
        value: userContext,
        child: MaterialApp(
          theme: AppTheme.light(),
          home: const ConfiguracoesPage(),
        ),
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
