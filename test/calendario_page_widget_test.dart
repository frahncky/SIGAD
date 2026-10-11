import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sigad/app/theme/app_theme.dart';
import 'package:sigad/features/aulas_praticas/data/reserva_repository.dart';
import 'package:sigad/features/aulas_praticas/domain/reserva_models.dart';
import 'package:sigad/features/calendario/presentation/pages/calendario_page.dart';
import 'package:sigad/features/calendario/presentation/widgets/calendario_mes_widget.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await initializeDateFormatting('pt_BR');
  });

  void configurarTela(WidgetTester tester, Size tamanho) {
    tester.view.physicalSize = tamanho;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  DateTime proximoDiaUtil() {
    final agora = DateTime.now();
    var data = DateTime(agora.year, agora.month, agora.day + 1);
    while (data.weekday > DateTime.friday) {
      data = data.add(const Duration(days: 1));
    }
    return data;
  }

  String siglaDiaDaSemana(DateTime data) {
    return switch (data.weekday) {
      DateTime.monday => 'Seg',
      DateTime.tuesday => 'Ter',
      DateTime.wednesday => 'Qua',
      DateTime.thursday => 'Qui',
      DateTime.friday => 'Sex',
      _ => throw StateError('A fixture deve usar um dia útil.'),
    };
  }

  const laboratorioLongo =
      'Laboratório de Sistemas Elétricos e Automação Industrial';
  const disciplinaLonga =
      'Prática integrada de sistemas elétricos e automação industrial';

  Future<DateTime> salvarAgendaPreenchida({int quantidade = 18}) async {
    SharedPreferences.setMockInitialValues({});
    final data = proximoDiaUtil();
    final reservas = List<ReservaLaboratorio>.generate(quantidade, (index) {
      final turno = Turno.values[index % Turno.values.length];
      return ReservaLaboratorio(
        id: 'CAL-RESP-$index',
        professor: 'Professora Responsável com Nome Extenso $index',
        laboratorio: laboratorioLongo,
        ano: data.year,
        mes: data.month,
        semanaDoMes: ((data.day - 1) ~/ 7) + 1,
        diaSemana: siglaDiaDaSemana(data),
        turno: turno,
        periodo: (index % 5) + 1,
        disciplina: '$disciplinaLonga $index',
      );
    });
    await ReservaRepository().saveReservas(reservas);
    return data;
  }

  Widget comTextoAmpliado(Widget child) {
    return MaterialApp(
      theme: AppTheme.light(),
      builder: (context, appChild) => MediaQuery(
        data: MediaQuery.of(
          context,
        ).copyWith(textScaler: const TextScaler.linear(2)),
        child: appChild!,
      ),
      home: Scaffold(body: child),
    );
  }

  testWidgets(
    'mês não apresenta overflow em 320x568 com texto a 200% e descreve o dia',
    (tester) async {
      configurarTela(tester, const Size(320, 568));
      DateTime? diaTocado;
      final diaSelecionado = DateTime(2026, 7, 28);

      await tester.pumpWidget(
        comTextoAmpliado(
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: CalendarioMesWidget(
              mesAtual: DateTime(2026, 7),
              diaSelecionado: diaSelecionado,
              feriados: {diaSelecionado: 'Adesão do Maranhão à Independência'},
              marcadores: {
                diaSelecionado: const [
                  Colors.blue,
                  Colors.green,
                  Colors.orange,
                  Colors.purple,
                ],
              },
              onDiaSelecionado: (dia) => diaTocado = dia,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Julho de 2026'), findsOneWidget);
      expect(tester.takeException(), isNull);

      final diaAcessivel = find.bySemanticsLabel(
        RegExp(
          'Terça-feira, 28 de julho de 2026, '
          'feriado: Adesão do Maranhão à Independência, 4 eventos',
        ),
      );
      expect(diaAcessivel, findsOneWidget);

      final semantics = tester.getSemantics(diaAcessivel);
      expect(semantics.flagsCollection.isSelected, ui.Tristate.isTrue);
      expect(
        semantics.getSemanticsData().hasAction(SemanticsAction.tap),
        isTrue,
      );

      await tester.tap(diaAcessivel);
      await tester.pump();
      expect(diaTocado, diaSelecionado);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('filtros empilham sem truncar em 320x568 com texto a 200%', (
    tester,
  ) async {
    configurarTela(tester, const Size(320, 568));
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(comTextoAmpliado(const CalendarioPage()));
    await tester.pumpAndSettle();

    final departamento = find.text('Departamento');
    await tester.scrollUntilVisible(
      departamento,
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    final tipoItem = find.text('Tipo de item');
    final laboratorios = find.text('Laboratórios');
    expect(departamento, findsOneWidget);
    expect(tipoItem, findsOneWidget);
    expect(laboratorios, findsOneWidget);
    expect(find.text('Eletroeletrônica (DEE)'), findsOneWidget);

    final topoDepartamento = tester.getTopLeft(departamento).dy;
    final topoTipoItem = tester.getTopLeft(tipoItem).dy;
    final topoLaboratorios = tester.getTopLeft(laboratorios).dy;
    expect(topoTipoItem, greaterThan(topoDepartamento));
    expect(topoLaboratorios, greaterThan(topoTipoItem));

    final filtroDepartamento = find.bySemanticsLabel(
      'Departamento: Eletroeletrônica (DEE)',
    );
    expect(filtroDepartamento, findsOneWidget);
    expect(tester.getSize(filtroDepartamento).width, greaterThan(250));

    final ocupacaoLaboratorios = find.text('Ocupação dos laboratórios (hoje)');
    await tester.scrollUntilVisible(
      ocupacaoLaboratorios,
      400,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    expect(ocupacaoLaboratorios, findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'compromissos preenchidos preservam subtítulo em 320x568 com texto a 200%',
    (tester) async {
      configurarTela(tester, const Size(320, 568));
      final data = await salvarAgendaPreenchida();

      await tester.pumpWidget(comTextoAmpliado(const CalendarioPage()));
      await tester.pumpAndSettle();

      final proximos = find.text('Próximos compromissos');
      await tester.scrollUntilVisible(
        proximos,
        350,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();

      final subtitulos = find.textContaining(disciplinaLonga);
      expect(subtitulos, findsWidgets);
      final subtitulo = tester.widget<Text>(subtitulos.first);
      expect(subtitulo.maxLines, isNull);
      expect(subtitulo.overflow, isNull);

      final quando = find.textContaining(DateFormat('dd/MM/yyyy').format(data));
      expect(quando, findsWidgets);
      expect(
        tester.getTopLeft(quando.first).dy,
        greaterThan(tester.getBottomLeft(subtitulos.first).dy),
      );
      expect(tester.takeException(), isNull);
    },
  );

  for (final caso in <({String nome, Size tamanho})>[
    (nome: 'retrato 320x568', tamanho: const Size(320, 568)),
    (nome: 'paisagem 568x320', tamanho: const Size(568, 320)),
  ]) {
    testWidgets(
      'agenda completa com muitos eventos é limitada e rolável em ${caso.nome}',
      (tester) async {
        configurarTela(tester, caso.tamanho);
        final data = await salvarAgendaPreenchida();

        await tester.pumpWidget(comTextoAmpliado(const CalendarioPage()));
        await tester.pumpAndSettle();

        final proximoMes = find.byTooltip('Próximo mês');
        await tester.scrollUntilVisible(
          proximoMes,
          250,
          scrollable: find.byType(Scrollable).first,
        );
        await tester.pumpAndSettle();
        final agora = DateTime.now();
        if (data.month != agora.month || data.year != agora.year) {
          await tester.tap(proximoMes);
          await tester.pumpAndSettle();
        }

        final dataFormatada = DateFormat(
          "EEEE, d 'de' MMMM 'de' y",
          'pt_BR',
        ).format(data);
        final dataCapitalizada =
            dataFormatada[0].toUpperCase() + dataFormatada.substring(1);
        final dia = find.bySemanticsLabel(
          RegExp('^${RegExp.escape(dataCapitalizada)}.*18 eventos'),
        );
        expect(dia, findsOneWidget);
        await tester.tap(dia);
        await tester.pumpAndSettle();

        final abrirAgenda = find.text('Ver agenda completa');
        await tester.scrollUntilVisible(
          abrirAgenda,
          400,
          scrollable: find.byType(Scrollable).first,
        );
        await tester.pumpAndSettle();
        await tester.tap(abrirAgenda);
        await tester.pumpAndSettle();

        final modal = find.byKey(const Key('calendario-agenda-completa'));
        final lista = find.byKey(const Key('calendario-agenda-completa-lista'));
        expect(find.text('Agenda completa'), findsOneWidget);
        expect(modal, findsOneWidget);
        expect(lista, findsOneWidget);
        expect(
          tester.getSize(modal).height,
          lessThanOrEqualTo(caso.tamanho.height),
        );

        final scrollableDaLista = find.descendant(
          of: lista,
          matching: find.byType(Scrollable),
        );
        final scrollableState = tester.state<ScrollableState>(
          scrollableDaLista,
        );
        expect(scrollableState.position.maxScrollExtent, greaterThan(0));

        final ultimoEvento = find.text('Aula prática – $disciplinaLonga 17');
        await tester.scrollUntilVisible(
          ultimoEvento,
          240,
          scrollable: scrollableDaLista,
        );
        await tester.pumpAndSettle();
        expect(ultimoEvento, findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
  }
}
