import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:sigad/app/theme/app_theme.dart';
import 'package:sigad/core/models/user.dart';
import 'package:sigad/core/models/user_role.dart';
import 'package:sigad/core/services/user_context_provider.dart';
import 'package:sigad/features/aulas_praticas/presentation/pages/aulas_praticas_page.dart';
import 'package:sigad/features/aulas_praticas/presentation/widgets/dialog_disciplina_semanas_reserva.dart';
import 'package:sigad/features/carga_docente/presentation/pages/carga_docente_page.dart';
import 'package:sigad/features/login/presentation/pages/login_page.dart';

void main() {
  int contarLivres(WidgetTester tester) => tester
      .widgetList<Semantics>(find.bySemanticsLabel(RegExp(r'^Célula ')))
      .where((celula) => celula.properties.value == 'Livre')
      .length;

  Finder celulaLivreSegM1() =>
      find.bySemanticsLabel(RegExp(r'Célula Seg,.*Matutino, período 1,'));

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

    final livresAntes = contarLivres(tester);

    final celulaInterativa = celulaLivreSegM1();
    await Scrollable.ensureVisible(
      tester.element(celulaInterativa),
      alignment: 0.5,
    );
    await tester.pumpAndSettle();
    expect(celulaInterativa.hitTestable(), findsOneWidget);
    await tester.tap(celulaInterativa);
    await tester.pumpAndSettle();

    expect(find.text('Reservar horário'), findsOneWidget);

    final campoDisciplina = find.descendant(
      of: find.byType(TelaFormularioReserva),
      matching: find.byType(TextField),
    );
    await tester.enterText(campoDisciplina, 'Disciplina Teste');
    await tester.pump();
    await tester.tap(find.text('Reservar'));
    await tester.pumpAndSettle();

    expect(find.text('Reservar horário'), findsNothing);
    final livresDepois = contarLivres(tester);
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

      final celulaInterativa = celulaLivreSegM1();
      await Scrollable.ensureVisible(
        tester.element(celulaInterativa),
        alignment: 0.5,
      );
      await tester.pumpAndSettle();
      await tester.tap(celulaInterativa);
      await tester.pumpAndSettle();

      final campoDisciplina = find.descendant(
        of: find.byType(TelaFormularioReserva),
        matching: find.byType(TextField),
      );
      await tester.enterText(campoDisciplina, 'Circuitos I');
      await tester.pump();
      await tester.tap(find.text('Reservar'));
      await tester.pumpAndSettle();

      // A célula reservada não tem mais o texto "Livre", então localizamos o
      // mesmo horário (Seg, Matutino, período 1) pelo rótulo de semântica, que
      // permanece estável independente do estado de ocupação.
      final celulaReservada = find.bySemanticsLabel(
        RegExp(r'Célula Seg,.*Matutino, período 1,'),
      );

      // A mesma célula agora está ocupada; tocar nela deve abrir o menu de
      // ações (editar/excluir) em vez de reabrir "Reservar horário".
      await tester.tap(celulaReservada);
      await tester.pumpAndSettle();

      expect(
        find.descendant(
          of: find.byType(TelaFormularioReserva),
          matching: find.text('Circuitos I'),
        ),
        findsOneWidget,
      );
      expect(find.text('Editar reserva'), findsOneWidget);
      expect(find.text('Excluir reserva'), findsOneWidget);

      await tester.tap(find.text('Editar reserva'));
      await tester.pumpAndSettle();

      final campoEdicao = find.descendant(
        of: find.byType(TelaFormularioReserva),
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
          of: find.byType(TelaFormularioReserva),
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
          child: AulasPraticasPage(dataInicial: DateTime(2026, 10, 5)),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final celulaInterativa = celulaLivreSegM1();
    await Scrollable.ensureVisible(
      tester.element(celulaInterativa),
      alignment: 0.5,
    );
    await tester.pumpAndSettle();
    await tester.tap(celulaInterativa);
    await tester.pumpAndSettle();

    final dropdownSemanas = find.descendant(
      of: find.byType(TelaFormularioReserva),
      matching: find.byType(DropdownButton<int>),
    );
    await tester.tap(dropdownSemanas);
    await tester.pumpAndSettle();
    await tester.tap(
      find.text('Esta e mais ${totalSemanas - 1} semana(s)').last,
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Reservar'));
    await tester.pumpAndSettle();
  }

  // O helper seleciona explicitamente o primeiro dia para que os cenários de
  // recorrência não dependam da data em que a suíte é executada.
  int semanaAtual() => 1;

  // Os cenários de recorrência começam na segunda 05/10/2026.
  String dataDaSemana(int semana) =>
      '${(5 + 7 * (semana - 1)).toString().padLeft(2, '0')}/10';

  Finder checkboxDaSemana(int semana) => find.ancestor(
    of: find.textContaining(dataDaSemana(semana)),
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

      // A exclusão recorrente exige escolha explícita e começa vazia.
      expect(find.text('Excluir ocorrências'), findsOneWidget);
      expect(find.byType(CheckboxListTile), findsNWidgets(3));
      expect(
        tester
            .widgetList<CheckboxListTile>(find.byType(CheckboxListTile))
            .every((item) => item.value == false),
        isTrue,
      );
      final revisar = find.widgetWithText(FilledButton, 'Revisar exclusão');
      expect(tester.widget<FilledButton>(revisar).onPressed, isNull);

      final semanaEscolhida = semanaAtual() + 1;
      await tester.tap(checkboxDaSemana(semanaEscolhida));
      await tester.pumpAndSettle();
      expect(tester.widget<FilledButton>(revisar).onPressed, isNotNull);
      await tester.tap(revisar);
      await tester.pumpAndSettle();
      expect(
        find.textContaining(dataDaSemana(semanaEscolhida)),
        findsOneWidget,
      );
      await tester.tap(find.text('Excluir'));
      await tester.pumpAndSettle();

      expect(find.text('Reserva removida.'), findsOneWidget);
      final prefs = await SharedPreferences.getInstance();
      final salvas = (jsonDecode(prefs.getString('sigad_reservas')!) as List)
          .cast<Map<String, dynamic>>()
          .where((item) => item['professor'] == 'Professor Teste')
          .toList(growable: false);
      expect(salvas, hasLength(2));
      expect(
        salvas.map((item) => item['semanaDoMes']),
        isNot(contains(semanaEscolhida)),
      );
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

      // Marca explicitamente todas as ocorrências.
      await tester.tap(checkboxDaSemana(semanaAtual()));
      await tester.pumpAndSettle();
      await tester.tap(checkboxDaSemana(semanaAtual() + 1));
      await tester.pumpAndSettle();
      await tester.tap(checkboxDaSemana(semanaAtual() + 2));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Revisar exclusão'));
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
          of: find.byType(TelaFormularioReserva),
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

      final celulaInterativa = celulaLivreSegM1();
      await Scrollable.ensureVisible(
        tester.element(celulaInterativa),
        alignment: 0.5,
      );
      await tester.pumpAndSettle();
      await tester.tap(celulaInterativa);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Reservar'));
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
          of: find.byType(TelaFormularioReserva),
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
            child: AulasPraticasPage(dataInicial: DateTime(2026, 10, 5)),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final celulaInterativa = celulaLivreSegM1();
      await Scrollable.ensureVisible(
        tester.element(celulaInterativa),
        alignment: 0.5,
      );
      await tester.pumpAndSettle();
      await tester.tap(celulaInterativa);
      await tester.pumpAndSettle();

      expect(find.text('Reservar horário'), findsOneWidget);

      final dropdownSemanas = find.descendant(
        of: find.byType(TelaFormularioReserva),
        matching: find.byType(DropdownButton<int>),
      );
      await tester.tap(dropdownSemanas);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Esta e mais 2 semana(s)').last);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Reservar'));
      await tester.pumpAndSettle();

      expect(find.text('Reservar horário'), findsNothing);
      expect(find.textContaining('3 horários reservados'), findsOneWidget);
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

      final livresAntes = contarLivres(tester);

      final celulaInterativa = celulaLivreSegM1();
      await Scrollable.ensureVisible(
        tester.element(celulaInterativa),
        alignment: 0.5,
      );
      await tester.pumpAndSettle();
      await tester.tap(celulaInterativa);
      await tester.pumpAndSettle();

      expect(find.text('Reservar horário'), findsOneWidget);
      await tester.tap(find.text('Reservar outros horários deste dia'));
      await tester.pumpAndSettle();

      // A primeira célula livre é Seg/Matutino/período 1 (M1); marca também
      // M2 no mesmo diálogo, sem precisar fechar e reabrir.
      final chipM2 = find.descendant(
        of: find.byType(TelaFormularioReserva),
        matching: find.widgetWithText(FilterChip, '08:05'),
      );
      await tester.tap(chipM2);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Reservar'));
      await tester.pumpAndSettle();

      expect(find.text('Reservar horário'), findsNothing);
      expect(find.textContaining('2 horários reservados'), findsOneWidget);
      final livresDepois = contarLivres(tester);
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

    final sugestoes = find.text('Sugestões de horários');
    await tester.ensureVisible(sugestoes);
    await tester.tap(sugestoes);
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

      expect(find.text('Sugestões de horários'), findsNothing);
      expect(find.text('Reservar sugestão'), findsNothing);
      expect(find.text('Agenda'), findsOneWidget);
    },
  );

  testWidgets('agenda navega por semana, mostra datas reais e marca feriado', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final userContext = UserContextProvider();
    await userContext.login(
      User(
        id: 'professor-calendario',
        name: 'Professor Teste',
        email: 'professor.calendario@ifma.edu.br',
        role: UserRole.professor,
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
          // Terça, 28/07/2026: feriado estadual no Maranhão.
          child: AulasPraticasPage(dataInicial: DateTime(2026, 7, 28)),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('27 a 31 de jul.'), findsOneWidget);
    expect(
      find.bySemanticsLabel(
        RegExp(r'terça-feira, 28/07, feriado: Adesão do Maranhão'),
      ),
      findsOneWidget,
    );

    await tester.ensureVisible(find.byTooltip('Próxima semana'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Próxima semana'));
    await tester.pumpAndSettle();
    expect(find.text('3 a 7 de ago.'), findsOneWidget);

    for (var i = 0; i < 2; i++) {
      await tester.ensureVisible(find.byTooltip('Semana anterior'));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Semana anterior'));
      await tester.pumpAndSettle();
    }
    await tester.pumpAndSettle();
    expect(find.text('20 a 24 de jul.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'reserva aparece na data real mesmo quando o mês não começa na segunda',
    (tester) async {
      // Outubro de 2026 começa numa quinta. A quinta 08/10 pertence ao
      // segundo bloco de 7 dias, mas aparece na semana de 05 a 09.
      SharedPreferences.setMockInitialValues({
        'sigad_reservas': jsonEncode([
          {
            'id': 'r-qui-08',
            'professor': 'Outra Pessoa',
            'laboratorio': 'Lab. de Eletrônica Analógica',
            'ano': 2026,
            'mes': 10,
            'semanaDoMes': 2,
            'diaSemana': 'Qui',
            'turno': 'matutino',
            'periodo': 1,
            'disciplina': 'Circuitos',
          },
        ]),
      });
      final userContext = UserContextProvider();
      await userContext.login(
        User(
          id: 'professor-data-real',
          name: 'Professor Teste',
          email: 'professor.data@ifma.edu.br',
          role: UserRole.professor,
          createdAt: DateTime(2026),
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light(),
          home: ChangeNotifierProvider<UserContextProvider>.value(
            value: userContext,
            child: AulasPraticasPage(dataInicial: DateTime(2026, 10, 5)),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final quinta08 = find.bySemanticsLabel(
        RegExp(r'Célula Qui, dia 8, Matutino, período 1,'),
      );
      expect(
        tester.widget<Semantics>(quinta08).properties.value,
        'Reservado por Outra Pessoa',
      );

      // Tocar na reserva de outra pessoa mostra os detalhes, sem ações.
      await tester.ensureVisible(quinta08);
      await tester.tap(quinta08);
      await tester.pumpAndSettle();
      expect(find.text('Reservado por'), findsOneWidget);
      expect(find.text('Outra Pessoa'), findsOneWidget);
      expect(find.text('Editar reserva'), findsNothing);
    },
  );

  testWidgets('voltar do celular em Laboratórios retorna à agenda', (
    tester,
  ) async {
    final userContext = UserContextProvider();
    await userContext.login(
      User(
        id: 'professor-voltar',
        name: 'Professor Teste',
        email: 'professor.voltar@ifma.edu.br',
        role: UserRole.professor,
        createdAt: DateTime(2026),
      ),
    );
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: ChangeNotifierProvider<UserContextProvider>.value(
          value: userContext,
          child: AulasPraticasPage(dataInicial: DateTime(2026, 10, 5)),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Laboratórios'));
    await tester.pumpAndSettle();
    expect(find.text('Voltar para a agenda'), findsNothing);

    // Botão voltar do sistema.
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('5 a 9 de out.'), findsOneWidget);
  });

  testWidgets('Ver agenda no cartão do laboratório abre a agenda dele', (
    tester,
  ) async {
    final userContext = UserContextProvider();
    await userContext.login(
      User(
        id: 'professor-ver-agenda',
        name: 'Professor Teste',
        email: 'professor.agenda@ifma.edu.br',
        role: UserRole.professor,
        createdAt: DateTime(2026),
      ),
    );
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: ChangeNotifierProvider<UserContextProvider>.value(
          value: userContext,
          child: AulasPraticasPage(dataInicial: DateTime(2026, 10, 5)),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Laboratórios'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Todos ('), findsOneWidget);

    final verAgenda = find.text('Ver agenda').first;
    await tester.ensureVisible(verAgenda);
    await tester.pumpAndSettle();
    await tester.tap(verAgenda);
    await tester.pumpAndSettle();
    expect(find.text('5 a 9 de out.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
