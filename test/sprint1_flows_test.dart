import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:sigad/app/theme/app_theme.dart';
import 'package:sigad/core/models/user.dart';
import 'package:sigad/core/models/user_role.dart';
import 'package:sigad/core/services/user_context_provider.dart';
import 'package:sigad/features/aulas_praticas/presentation/pages/aulas_praticas_page.dart';
import 'package:sigad/features/carga_docente/presentation/pages/carga_docente_page.dart';
import 'package:sigad/features/login/presentation/pages/login_page.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('Login mostra validação para email inválido', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: ChangeNotifierProvider(
          create: (_) => UserContextProvider(),
          child: const LoginPage(),
        ),
      ),
    );

    await tester.enterText(find.byType(TextField).first, 'email-invalido');
    await tester.enterText(find.byType(TextField).at(1), '1234');
    await tester.tap(find.text('Entrar'));
    await tester.pump();

    expect(find.text('Informe um email válido.'), findsOneWidget);
  });

  testWidgets('Coordenador consegue expandir distribuição semanal de qualquer docente', (tester) async {
    final userContext = UserContextProvider();
    await userContext.login(
      User(
        id: 'user_email_coordenador@univ.br',
        name: 'Coordenador',
        email: 'coordenador@univ.br',
        role: UserRole.coordenador,
        createdAt: DateTime.now(),
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: ChangeNotifierProvider<UserContextProvider>.value(
          value: userContext,
          child: const CargaDocentePage(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Distribuição semanal'), findsNothing);

    await tester.tap(find.text('Prof. Dr. João Silva'));
    await tester.pumpAndSettle();

    expect(find.text('Distribuição semanal'), findsOneWidget);
    expect(find.text('Ter'), findsWidgets);
    expect(find.text('Qui'), findsWidgets);
  });

  testWidgets('Professor consegue reservar horário em laboratório', (tester) async {
    final userContext = UserContextProvider();
    await userContext.login(
      User(
        id: 'u2',
        name: 'Professor Teste',
        email: 'prof@teste.br',
        role: UserRole.professor,
        createdAt: DateTime.now(),
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: ChangeNotifierProvider<UserContextProvider>.value(
          value: userContext,
          child: const AulasPraticasPage(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final livresAntes = find.text('Livre').evaluate().length;

    await tester.tap(find.text('Livre').first);
    await tester.pumpAndSettle();

    expect(find.text('Disciplina da reserva'), findsOneWidget);

    final campoDisciplina = find.descendant(
      of: find.byType(AlertDialog),
      matching: find.byType(TextField),
    );
    await tester.enterText(campoDisciplina, 'Disciplina Teste');
    await tester.pump();
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    expect(find.text('Disciplina da reserva'), findsNothing);
    final livresDepois = find.text('Livre').evaluate().length;
    expect(livresDepois, lessThan(livresAntes));
  });
}
