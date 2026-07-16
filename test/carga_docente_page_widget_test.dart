import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:sigad/app/theme/app_theme.dart';
import 'package:sigad/core/models/user.dart';
import 'package:sigad/core/models/user_role.dart';
import 'package:sigad/core/services/user_context_provider.dart';
import 'package:sigad/features/carga_docente/data/docente_repository.dart';
import 'package:sigad/features/carga_docente/domain/docente_models.dart';
import 'package:sigad/features/carga_docente/presentation/pages/carga_docente_page.dart';

Widget _buildApp(UserContextProvider userContext) {
  return ChangeNotifierProvider<UserContextProvider>.value(
    value: userContext,
    child: MaterialApp(theme: AppTheme.light(), home: const CargaDocentePage()),
  );
}

Future<UserContextProvider> _loggedIn(
  UserRole role, {
  String email = 'user@univ.br',
}) async {
  final ctx = UserContextProvider();
  await ctx.login(
    User(
      id: 'user_email_$email',
      name: 'Teste',
      email: email,
      role: role,
      createdAt: DateTime.now(),
    ),
  );
  return ctx;
}

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await DocenteRepository().saveDocentes(const [
      Docente(
        id: '#DOC-001',
        nome: 'Profa. Dra. Maria Silva',
        userId: 'user_email_maria.santos@univ.br',
        userEmail: 'maria.santos@univ.br',
        departamento: 'Eletrônica',
        cargaHoraria: 10,
        cargaMaxima: 20,
        disciplinas: ['Programação I'],
      ),
      Docente(
        id: '#DOC-002',
        nome: 'Prof. Dr. João Silva',
        userEmail: 'joao.silva@univ.br',
        departamento: 'Telecomunicações',
        cargaHoraria: 8,
        cargaMaxima: 20,
        disciplinas: ['Redes I'],
      ),
    ]);
  });

  testWidgets('coordenador ve lista de docentes', (tester) async {
    final ctx = await _loggedIn(UserRole.coordenador);

    await tester.pumpWidget(_buildApp(ctx));
    await tester.pumpAndSettle();

    expect(find.textContaining('Maria Silva'), findsWidgets);
    expect(find.text('Nenhum docente encontrado'), findsNothing);
  });

  testWidgets('instalação nova começa sem docentes ativos', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final ctx = await _loggedIn(UserRole.chefeDepartamento);

    await tester.pumpWidget(_buildApp(ctx));
    await tester.pumpAndSettle();

    expect(find.text('Nenhum docente encontrado'), findsOneWidget);
    expect(find.text('Almir Souza e Silva Neto'), findsNothing);
    expect(find.byType(FloatingActionButton), findsOneWidget);
  });

  testWidgets('professor ve apenas os proprios dados', (tester) async {
    final ctx = await _loggedIn(
      UserRole.professor,
      email: 'maria.santos@univ.br',
    );

    await tester.pumpWidget(_buildApp(ctx));
    await tester.pumpAndSettle();

    expect(find.textContaining('Maria Silva'), findsWidgets);
    expect(find.textContaining('João Silva'), findsNothing);
  });

  testWidgets('chefe ve todos os docentes', (tester) async {
    final ctx = await _loggedIn(UserRole.chefeDepartamento);

    await tester.pumpWidget(_buildApp(ctx));
    await tester.pumpAndSettle();

    expect(find.textContaining('Maria Silva'), findsWidgets);
    expect(find.text('Nenhum docente encontrado'), findsNothing);
  });

  testWidgets(
    'somente chefe pode cadastrar docente usando nome e área oficial',
    (tester) async {
      final ctx = await _loggedIn(UserRole.coordenador);

      await tester.pumpWidget(_buildApp(ctx));
      await tester.pumpAndSettle();
      expect(find.byType(FloatingActionButton), findsNothing);

      final chefe = await _loggedIn(UserRole.chefeDepartamento);
      await tester.pumpWidget(_buildApp(chefe));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      expect(find.text('Novo Docente'), findsOneWidget);
      final nomeField = find.byWidgetPredicate(
        (widget) =>
            widget is TextField &&
            widget.decoration?.labelText == 'Nome completo',
      );
      await tester.enterText(nomeField, 'Almir');
      await tester.pumpAndSettle();
      await tester.tap(find.text('Almir Souza e Silva Neto').last);
      await tester.pumpAndSettle();

      final areaField = tester.widget<TextField>(
        find.byWidgetPredicate(
          (widget) =>
              widget is TextField &&
              widget.decoration?.labelText == 'Área/Comissão',
        ),
      );
      expect(areaField.controller?.text, contains('Telecomunicações'));
    },
  );

  testWidgets('chefe não cadastra email já vinculado a outro docente', (
    tester,
  ) async {
    final chefe = await _loggedIn(UserRole.chefeDepartamento);
    await tester.pumpWidget(_buildApp(chefe));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    Finder campo(String label) => find.byWidgetPredicate(
      (widget) => widget is TextField && widget.decoration?.labelText == label,
    );

    await tester.enterText(campo('Nome completo'), 'Docente Novo');
    await tester.enterText(campo('Email de acesso'), ' MARIA.SANTOS@UNIV.BR ');
    await tester.enterText(campo('Área/Comissão'), 'Computação');
    await tester.enterText(campo('Carga Horária Máxima Semanal (horas)'), '20');

    final adicionarDisciplina = find.widgetWithText(ActionChip, 'Adicionar');
    await tester.ensureVisible(adicionarDisciplina);
    await tester.tap(adicionarDisciplina);
    await tester.pumpAndSettle();
    await tester.enterText(campo('Nome da Disciplina'), 'Algoritmos');
    final confirmarDisciplina = find.descendant(
      of: find.byType(AlertDialog),
      matching: find.widgetWithText(TextButton, 'Adicionar'),
    );
    await tester.tap(confirmarDisciplina);
    await tester.pumpAndSettle();

    final confirmar = find.widgetWithText(ElevatedButton, 'Adicionar');
    await tester.ensureVisible(confirmar);
    await tester.tap(confirmar);
    await tester.pumpAndSettle();

    expect(
      find.text('Este email de acesso já está vinculado a outro docente.'),
      findsOneWidget,
    );
    expect(find.text('Novo Docente'), findsOneWidget);
  });

  testWidgets('somente chefe pode acionar simulacao de redistribuicao', (
    tester,
  ) async {
    final ctxCoordenador = await _loggedIn(UserRole.coordenador);
    await tester.pumpWidget(_buildApp(ctxCoordenador));
    await tester.pumpAndSettle();

    final botaoCoordenador = tester.widget<TextButton>(
      find.widgetWithText(TextButton, 'Somente chefe'),
    );
    expect(botaoCoordenador.onPressed, isNull);

    final ctxChefe = await _loggedIn(UserRole.chefeDepartamento);
    await tester.pumpWidget(_buildApp(ctxChefe));
    await tester.pumpAndSettle();

    final botaoChefe = tester.widget<TextButton>(
      find.widgetWithText(TextButton, 'Simular'),
    );
    expect(botaoChefe.onPressed, isNotNull);
  });
}
