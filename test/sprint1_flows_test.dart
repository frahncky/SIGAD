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

  testWidgets(
    'Coordenador consegue expandir distribuição semanal de qualquer docente',
    (tester) async {
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

      // Simula busca pelo nome do docente
      final searchField = find.byType(TextField).last;
      await tester.enterText(searchField, 'João Silva');
      await tester.pumpAndSettle();

      expect(find.text('Prof. Dr. João Silva'), findsOneWidget);
      await tester.tap(find.text('Prof. Dr. João Silva'));
      await tester.pumpAndSettle();

      expect(find.text('Distribuição semanal'), findsOneWidget);
      expect(find.textContaining('Ter ·'), findsWidgets);
      expect(find.textContaining('Qui ·'), findsWidgets);
    },
  );

  testWidgets('Professor consegue reservar horário em laboratório', (
    tester,
  ) async {
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

    final primeiraCelulaLivre = find.text('Livre').first;
    final celulaInterativa = find
        .ancestor(of: primeiraCelulaLivre, matching: find.byType(InkWell))
        .first;
    await Scrollable.ensureVisible(
      tester.element(celulaInterativa),
      alignment: 0.5,
    );
    await tester.pumpAndSettle();
    expect(celulaInterativa.hitTestable(), findsOneWidget);
    await tester.tap(celulaInterativa);
    await tester.pumpAndSettle();

    expect(find.text('Nova Reserva'), findsOneWidget);

    final campoDisciplina = find.descendant(
      of: find.byType(AlertDialog),
      matching: find.byType(TextField),
    );
    await tester.enterText(campoDisciplina, 'Disciplina Teste');
    await tester.pump();
    await tester.tap(find.text('Confirmar'));
    await tester.pumpAndSettle();

    expect(find.text('Nova Reserva'), findsNothing);
    final livresDepois = find.text('Livre').evaluate().length;
    expect(livresDepois, lessThan(livresAntes));
  });
}
