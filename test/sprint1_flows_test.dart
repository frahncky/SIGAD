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
    final enterButton = find.widgetWithText(FilledButton, 'Entrar');
    await tester.ensureVisible(enterButton);
    await tester.tap(enterButton);
    await tester.pump();

    expect(find.text('Informe um email válido.'), findsOneWidget);
  });

  testWidgets(
    'Coordenador consegue expandir distribuição semanal de qualquer docente',
    (tester) async {
      final userContext = UserContextProvider();
      await userContext.login(
        User(
          id: 'user_email_coordenador@ifma.edu.br',
          name: 'Coordenador',
          email: 'coordenador@ifma.edu.br',
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
      await tester.enterText(searchField, 'Docente 02');
      await tester.pumpAndSettle();

      expect(find.text('Docente 02'), findsWidgets);
      await tester.tap(find.text('Docente 02').last);
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

  testWidgets(
    'Professor consegue editar a disciplina de uma reserva existente',
    (tester) async {
      final userContext = UserContextProvider();
      await userContext.login(
        User(
          id: 'u-editar',
          name: 'Professor Teste',
          email: 'prof.editar@teste.br',
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

      final primeiraCelulaLivre = find.text('Livre').first;
      final celulaInterativa = find
          .ancestor(of: primeiraCelulaLivre, matching: find.byType(InkWell))
          .first;
      await Scrollable.ensureVisible(
        tester.element(celulaInterativa),
        alignment: 0.5,
      );
      await tester.pumpAndSettle();
      await tester.tap(celulaInterativa);
      await tester.pumpAndSettle();

      final campoDisciplina = find.descendant(
        of: find.byType(AlertDialog),
        matching: find.byType(TextField),
      );
      await tester.enterText(campoDisciplina, 'Circuitos I');
      await tester.pump();
      await tester.tap(find.text('Confirmar'));
      await tester.pumpAndSettle();

      // A célula reservada não tem mais o texto "Livre", então localizamos o
      // mesmo horário (Seg, Matutino, período 1) pelo rótulo de semântica, que
      // permanece estável independente do estado de ocupação.
      final celulaReservada = find.bySemanticsLabel(
        RegExp(r'Célula Seg,.*Matutino, período 1,'),
      );

      // A mesma célula agora está ocupada; tocar nela deve abrir o menu de
      // ações (editar/excluir) em vez de reabrir "Nova Reserva".
      await tester.tap(celulaReservada);
      await tester.pumpAndSettle();

      expect(
        find.descendant(
          of: find.byType(SimpleDialog),
          matching: find.text('Circuitos I'),
        ),
        findsOneWidget,
      );
      expect(find.text('Editar reserva'), findsOneWidget);
      expect(find.text('Excluir reserva'), findsOneWidget);

      await tester.tap(find.text('Editar reserva'));
      await tester.pumpAndSettle();

      final campoEdicao = find.descendant(
        of: find.byType(AlertDialog),
        matching: find.byType(TextField),
      );
      expect(
        tester.widget<TextField>(campoEdicao).controller?.text,
        'Circuitos I',
      );
      await tester.enterText(campoEdicao, 'Circuitos II');
      await tester.pump();
      await tester.tap(find.text('Salvar'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Reserva atualizada'), findsOneWidget);

      await tester.tap(celulaReservada);
      await tester.pumpAndSettle();
      expect(
        find.descendant(
          of: find.byType(SimpleDialog),
          matching: find.text('Circuitos II'),
        ),
        findsOneWidget,
      );
    },
  );

  Future<void> criarReservaRecorrente(
    WidgetTester tester, {
    required String userId,
    required int totalSemanas,
  }) async {
    final userContext = UserContextProvider();
    await userContext.login(
      User(
        id: userId,
        name: 'Professor Teste',
        email: '$userId@teste.br',
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

    final primeiraCelulaLivre = find.text('Livre').first;
    final celulaInterativa = find
        .ancestor(of: primeiraCelulaLivre, matching: find.byType(InkWell))
        .first;
    await Scrollable.ensureVisible(
      tester.element(celulaInterativa),
      alignment: 0.5,
    );
    await tester.pumpAndSettle();
    await tester.tap(celulaInterativa);
    await tester.pumpAndSettle();

    final dropdownSemanas = find.descendant(
      of: find.byType(AlertDialog),
      matching: find.byType(DropdownButton<int>),
    );
    await tester.tap(dropdownSemanas);
    await tester.pumpAndSettle();
    await tester.tap(find.text('$totalSemanas').last);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Confirmar'));
    await tester.pumpAndSettle();
  }

  int semanaAtual() => ((DateTime.now().day - 1) ~/ 7) + 1;

  Finder checkboxDaSemana(int semana) => find.ancestor(
    of: find.text('${semana}a semana'),
    matching: find.byType(CheckboxListTile),
  );

  testWidgets(
    'Professor pode excluir só uma ocorrência de uma reserva recorrente',
    (tester) async {
      await criarReservaRecorrente(
        tester,
        userId: 'u-serie-excluir-uma',
        totalSemanas: 3,
      );

      final celulaSegM1 = find.bySemanticsLabel(
        RegExp(r'Célula Seg,.*Matutino, período 1,'),
      );
      await tester.tap(celulaSegM1);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Excluir reserva'));
      await tester.pumpAndSettle();

      // Como a reserva se repete em 3 semanas, o app pergunta quais
      // ocorrências devem ser afetadas: por padrão, só a atual vem marcada.
      expect(find.text('Excluir ocorrências'), findsOneWidget);
      expect(find.byType(CheckboxListTile), findsNWidgets(3));
      expect(
        tester.widget<CheckboxListTile>(checkboxDaSemana(semanaAtual())).value,
        isTrue,
      );

      await tester.tap(find.text('Continuar'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Excluir'));
      await tester.pumpAndSettle();

      expect(find.text('Reserva removida.'), findsOneWidget);
    },
  );

  testWidgets(
    'Professor pode escolher e excluir várias ocorrências de uma reserva recorrente',
    (tester) async {
      await criarReservaRecorrente(
        tester,
        userId: 'u-serie-excluir-todas',
        totalSemanas: 3,
      );

      final celulaSegM1 = find.bySemanticsLabel(
        RegExp(r'Célula Seg,.*Matutino, período 1,'),
      );
      await tester.tap(celulaSegM1);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Excluir reserva'));
      await tester.pumpAndSettle();

      // Marca também as outras duas ocorrências (a atual já vem marcada).
      await tester.tap(checkboxDaSemana(semanaAtual() + 1));
      await tester.pumpAndSettle();
      await tester.tap(checkboxDaSemana(semanaAtual() + 2));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Continuar'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Excluir'));
      await tester.pumpAndSettle();

      expect(find.textContaining('3 ocorrências removidas'), findsOneWidget);
    },
  );

  testWidgets(
    'Professor pode escolher e editar várias ocorrências de uma reserva recorrente',
    (tester) async {
      await criarReservaRecorrente(
        tester,
        userId: 'u-serie-editar',
        totalSemanas: 2,
      );

      final celulaSegM1 = find.bySemanticsLabel(
        RegExp(r'Célula Seg,.*Matutino, período 1,'),
      );
      await tester.tap(celulaSegM1);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Editar reserva'));
      await tester.pumpAndSettle();

      expect(find.text('Editar ocorrências'), findsOneWidget);
      await tester.tap(checkboxDaSemana(semanaAtual() + 1));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Continuar'));
      await tester.pumpAndSettle();

      // Move as duas ocorrências marcadas para Terça, T2.
      expect(find.text('Editar reserva'), findsOneWidget);
      await tester.tap(
        find.descendant(
          of: find.byType(AlertDialog),
          matching: find.widgetWithText(ChoiceChip, 'Ter'),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilterChip, 'T2'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Salvar'));
      await tester.pumpAndSettle();

      expect(find.textContaining('2 ocorrências atualizadas'), findsOneWidget);

      // A célula original (Seg/M1) volta a ficar livre nesta semana...
      expect(tester.widget<Semantics>(celulaSegM1).properties.value, 'Livre');
      // ...e a nova célula (Ter/T2) passa a estar ocupada.
      final celulaTerT2 = find.bySemanticsLabel(
        RegExp(r'Célula Ter,.*Tarde, período 2,'),
      );
      expect(
        tester.widget<Semantics>(celulaTerT2).properties.value,
        isNot('Livre'),
      );
    },
  );

  testWidgets(
    'Professor consegue mover uma reserva existente para outro dia e horário',
    (tester) async {
      final userContext = UserContextProvider();
      await userContext.login(
        User(
          id: 'u-mover',
          name: 'Professor Teste',
          email: 'prof.mover@teste.br',
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

      final primeiraCelulaLivre = find.text('Livre').first;
      final celulaInterativa = find
          .ancestor(of: primeiraCelulaLivre, matching: find.byType(InkWell))
          .first;
      await Scrollable.ensureVisible(
        tester.element(celulaInterativa),
        alignment: 0.5,
      );
      await tester.pumpAndSettle();
      await tester.tap(celulaInterativa);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Confirmar'));
      await tester.pumpAndSettle();

      // A célula reservada é Seg/Matutino/período 1 (M1).
      final celulaSegM1 = find.bySemanticsLabel(
        RegExp(r'Célula Seg,.*Matutino, período 1,'),
      );
      await tester.tap(celulaSegM1);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Editar reserva'));
      await tester.pumpAndSettle();

      // Troca o dia para Terça e o horário para T2 (Tarde, período 2).
      await tester.tap(
        find.descendant(
          of: find.byType(AlertDialog),
          matching: find.widgetWithText(ChoiceChip, 'Ter'),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilterChip, 'T2'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Salvar'));
      await tester.pumpAndSettle();

      expect(find.text('Reserva atualizada.'), findsOneWidget);

      // A célula original (Seg/M1) volta a ficar livre...
      expect(tester.widget<Semantics>(celulaSegM1).properties.value, 'Livre');

      // ...e a nova célula (Ter/T2) passa a estar ocupada.
      final celulaTerT2 = find.bySemanticsLabel(
        RegExp(r'Célula Ter,.*Tarde, período 2,'),
      );
      expect(
        tester.widget<Semantics>(celulaTerT2).properties.value,
        isNot('Livre'),
      );
    },
  );

  testWidgets(
    'Professor consegue reservar o mesmo horário em várias semanas de uma vez',
    (tester) async {
      final userContext = UserContextProvider();
      await userContext.login(
        User(
          id: 'u-multi-semana',
          name: 'Professor Teste',
          email: 'prof.multi@teste.br',
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

      final primeiraCelulaLivre = find.text('Livre').first;
      final celulaInterativa = find
          .ancestor(of: primeiraCelulaLivre, matching: find.byType(InkWell))
          .first;
      await Scrollable.ensureVisible(
        tester.element(celulaInterativa),
        alignment: 0.5,
      );
      await tester.pumpAndSettle();
      await tester.tap(celulaInterativa);
      await tester.pumpAndSettle();

      expect(find.text('Nova Reserva'), findsOneWidget);

      final dropdownSemanas = find.descendant(
        of: find.byType(AlertDialog),
        matching: find.byType(DropdownButton<int>),
      );
      await tester.tap(dropdownSemanas);
      await tester.pumpAndSettle();
      await tester.tap(find.text('3').last);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Confirmar'));
      await tester.pumpAndSettle();

      expect(find.text('Nova Reserva'), findsNothing);
      expect(
        find.textContaining('3 horários reservados com sucesso'),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'Professor consegue marcar outros horários dentro do próprio diálogo de reserva',
    (tester) async {
      final userContext = UserContextProvider();
      await userContext.login(
        User(
          id: 'u-multi-horario',
          name: 'Professor Teste',
          email: 'prof.horarios@teste.br',
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
      await tester.tap(celulaInterativa);
      await tester.pumpAndSettle();

      expect(find.text('Nova Reserva'), findsOneWidget);
      expect(find.text('Horários'), findsOneWidget);

      // A primeira célula livre é Seg/Matutino/período 1 (M1); marca também
      // M2 no mesmo diálogo, sem precisar fechar e reabrir.
      final chipM2 = find.descendant(
        of: find.byType(AlertDialog),
        matching: find.widgetWithText(FilterChip, 'M2'),
      );
      await tester.tap(chipM2);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Confirmar'));
      await tester.pumpAndSettle();

      expect(find.text('Nova Reserva'), findsNothing);
      expect(
        find.textContaining('2 horários reservados com sucesso'),
        findsOneWidget,
      );
      final livresDepois = find.text('Livre').evaluate().length;
      expect(livresDepois, livresAntes - 2);
    },
  );

  testWidgets('painel de otimização adapta ação no mobile com texto ampliado', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final userContext = UserContextProvider();
    await userContext.login(
      User(
        id: 'coordenador-mobile',
        name: 'Coordenação',
        email: 'coordenacao@ifma.edu.br',
        role: UserRole.coordenador,
        createdAt: DateTime(2026),
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: const TextScaler.linear(2)),
          child: child!,
        ),
        home: ChangeNotifierProvider<UserContextProvider>.value(
          value: userContext,
          child: const AulasPraticasPage(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final action = find.text('Reservar sugestão');
    await tester.ensureVisible(action);
    await tester.pumpAndSettle();

    expect(action, findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'professor não vê o painel de otimização de laboratórios (exclusivo de coordenação/chefia)',
    (tester) async {
      final userContext = UserContextProvider();
      await userContext.login(
        User(
          id: 'professor-otimizacao',
          name: 'Professor Teste',
          email: 'professor.teste@ifma.edu.br',
          role: UserRole.professor,
          createdAt: DateTime(2026),
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

      expect(find.text('Otimização de laboratórios'), findsNothing);
      expect(find.text('Reservar sugestão'), findsNothing);
      expect(find.text('Agenda semanal'), findsOneWidget);
    },
  );
}
