import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../app/theme/sigad_colors.dart';
import '../../../../app/theme/sigad_icon.dart';
import '../../../../app/theme/sigad_icons.dart';
import '../../../../app/theme/sigad_tone_palette.dart';
import '../../data/laboratorio_repository.dart';
import '../../data/reserva_repository.dart';
import '../../domain/feriado_service.dart';
import '../../domain/reserva_models.dart';
import '../../domain/reserva_service.dart';
import '../../../carga_docente/data/docente_repository.dart';
import '../../../carga_docente/domain/docente_models.dart';
import '../../../../core/security/authorization_policy.dart';
import '../../../../core/services/app_event_logger.dart';
import '../../../../core/services/app_feedback_service.dart';
import '../../../../core/services/user_context_provider.dart';
import '../../../../shared/widgets/icon_avatar.dart';
import '../widgets/dialog_disciplina_semanas_reserva.dart';
import 'laboratorios_catalogo_page.dart';

class _ResultadoReserva {
  const _ResultadoReserva({required this.criadas, required this.jaOcupadas});

  final int criadas;
  final int jaOcupadas;
}

enum _AcaoReserva { editar, excluir }

class AulasPraticasPage extends StatefulWidget {
  const AulasPraticasPage({super.key});

  @override
  State<AulasPraticasPage> createState() => _AulasPraticasPageState();
}

class _AulasPraticasPageState extends State<AulasPraticasPage> {
  bool _mostrarCatalogo = false;
  static const List<String> _laboratoriosDefault = [
    'Lab. de Eletrônica Analógica',
    'Lab. de Máquinas Elétricas',
    'Lab. de Medidas Elétricas',
    'Lab. de Automação',
  ];

  static const List<String> _mesesDefault = [
    'Janeiro',
    'Fevereiro',
    'Março',
    'Abril',
    'Maio',
    'Junho',
    'Julho',
    'Agosto',
    'Setembro',
    'Outubro',
    'Novembro',
    'Dezembro',
  ];

  final ReservaRepository _reservaRepository = ReservaRepository();
  final LaboratorioRepository _laboratorioRepository = LaboratorioRepository();
  final DocenteRepository _docenteRepository = DocenteRepository();
  final List<ReservaLaboratorio> _reservas = ReservaService.defaultReservas(
    ano: DateTime.now().year,
    mes: DateTime.now().month,
  );
  final List<Docente> _docentes = [];

  final TransformationController _transformationController =
      TransformationController();

  String? _laboratorioSelecionado;
  int _anoSelecionado = DateTime.now().year;
  int _mesSelecionado = DateTime.now().month;
  int _diaSelecionado = DateTime.now().day;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final catalogoFuture = _laboratorioRepository.load();
    final list = await _reservaRepository.loadReservas();

    final docentes = await _docenteRepository.loadDocentes(
      generateFallbackId: () => 'DOC-FALLBACK',
    );
    await catalogoFuture;

    if (!mounted) return;
    setState(() {
      if (list.isNotEmpty) {
        _reservas
          ..clear()
          ..addAll(list);
      }
      _docentes
        ..clear()
        ..addAll(docentes);
    });
  }

  Future<bool> _saveData() async {
    try {
      await _reservaRepository.saveReservas(_reservas);
      return true;
    } catch (e) {
      _showError('Erro ao salvar os dados localmente.');
      return false;
    }
  }

  int get _semanaSelecionada => ((_diaSelecionado - 1) ~/ 7) + 1;

  String get _laboratorioSelecionadoValido {
    if (_laboratorioSelecionado != null &&
        _laboratoriosDefault.contains(_laboratorioSelecionado)) {
      return _laboratorioSelecionado!;
    }
    return _laboratoriosDefault.first;
  }

  String get _diaSemanaAbreviadoDoDiaSelecionado {
    // Segunda = 1, Domingo = 7
    const dias = ['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb', 'Dom'];
    final data = DateTime(_anoSelecionado, _mesSelecionado, _diaSelecionado);
    // DateTime.weekday: segunda=1, domingo=7
    return dias[data.weekday - 1];
  }

  String get _diaSemanaCompletoDoDiaSelecionado {
    const dias = [
      'Segunda-feira',
      'Terça-feira',
      'Quarta-feira',
      'Quinta-feira',
      'Sexta-feira',
      'Sábado',
      'Domingo',
    ];
    final data = DateTime(_anoSelecionado, _mesSelecionado, _diaSelecionado);
    return dias[data.weekday - 1];
  }

  List<ReservaLaboratorio> get _reservasDoLaboratorio =>
      ReservaService.reservasDoLaboratorio(
        reservas: _reservas,
        laboratorio: _laboratorioSelecionadoValido,
        ano: _anoSelecionado,
        mes: _mesSelecionado,
        semanaDoMes: _semanaSelecionada,
      );

  List<IndicadorOcupacaoLaboratorio> get _indicadoresOcupacao =>
      ReservaService.calcularOcupacaoLaboratorios(
        reservas: _reservas,
        laboratorios: _laboratoriosDefault,
        ano: _anoSelecionado,
        mes: _mesSelecionado,
        semanaDoMes: _semanaSelecionada,
      );

  List<SugestaoReservaLaboratorio> get _sugestoesReserva =>
      ReservaService.sugerirSlotsLivres(
        reservas: _reservas,
        laboratorios: _laboratoriosDefault,
        ano: _anoSelecionado,
        mes: _mesSelecionado,
        semanaDoMes: _semanaSelecionada,
        diaSemanaPreferencial: _diaSemanaAbreviadoDoDiaSelecionado,
        limite: 4,
      );

  List<String> get _recomendacoesCruzadas {
    final altaCarga = _docentes
        .where((docente) {
          if (docente.cargaMaxima <= 0) return false;
          return (docente.cargaHoraria / docente.cargaMaxima) >= 0.9;
        })
        .toList(growable: false);

    if (altaCarga.isEmpty || _sugestoesReserva.isEmpty) {
      return const [];
    }

    final recomendacoes = <String>[];
    final limite = altaCarga.length < _sugestoesReserva.length
        ? altaCarga.length
        : _sugestoesReserva.length;

    for (var index = 0; index < limite; index++) {
      final docente = altaCarga[index];
      final sugestao = _sugestoesReserva[index];
      recomendacoes.add(
        '${docente.nome.split(' ').first}: priorizar ${sugestao.laboratorio} em ${sugestao.diaSemana} ${sugestao.horario} para aliviar carga em turmas práticas.',
      );
    }

    return recomendacoes;
  }

  int get _diasNoMesSelecionado {
    return DateTime(_anoSelecionado, _mesSelecionado + 1, 0).day;
  }

  void _selecionarPeriodo(int ano, int mes) {
    final periodo = DateTime(ano.clamp(2020, 2100), mes);
    setState(() {
      _anoSelecionado = periodo.year;
      _mesSelecionado = periodo.month;
      _diaSelecionado = _diaSelecionado.clamp(1, _diasNoMesSelecionado);
    });
  }

  void _irParaMesAnterior() {
    if (_anoSelecionado == 2020 && _mesSelecionado == DateTime.january) {
      return;
    }
    final anterior = DateTime(_anoSelecionado, _mesSelecionado - 1);
    _selecionarPeriodo(anterior.year, anterior.month);
  }

  void _irParaProximoMes() {
    if (_anoSelecionado == 2100 && _mesSelecionado == DateTime.december) {
      return;
    }
    final proximo = DateTime(_anoSelecionado, _mesSelecionado + 1);
    _selecionarPeriodo(proximo.year, proximo.month);
  }

  Future<void> _abrirSeletorMesAno() async {
    var ano = _anoSelecionado;
    var mes = _mesSelecionado;
    final periodo = await showDialog<DateTime>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          scrollable: true,
          title: const Text('Escolher mês e ano'),
          content: SizedBox(
            width: 360,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<int>(
                  initialValue: mes,
                  isExpanded: true,
                  decoration: const InputDecoration(labelText: 'Mês'),
                  items: [
                    for (var index = 0; index < _mesesDefault.length; index++)
                      DropdownMenuItem(
                        value: index + 1,
                        child: Text(_mesesDefault[index]),
                      ),
                  ],
                  onChanged: (value) {
                    if (value != null) setDialogState(() => mes = value);
                  },
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<int>(
                  initialValue: ano,
                  isExpanded: true,
                  decoration: const InputDecoration(labelText: 'Ano'),
                  items: [
                    for (var value = 2020; value <= 2100; value++)
                      DropdownMenuItem(value: value, child: Text('$value')),
                  ],
                  onChanged: (value) {
                    if (value != null) setDialogState(() => ano = value);
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () =>
                  Navigator.of(dialogContext).pop(DateTime(ano, mes)),
              child: const Text('Aplicar'),
            ),
          ],
        ),
      ),
    );
    if (periodo != null) _selecionarPeriodo(periodo.year, periodo.month);
  }

  /// Cria a reserva de uma célula na semana atual e, se [totalSemanas] for
  /// maior que 1, também nas semanas seguintes do mês (pulando semanas já
  /// ocupadas). Deve ser chamado dentro de um `setState`.
  _ResultadoReserva _criarReservasParaCelula({
    required String professor,
    required String diaSemana,
    required Turno turno,
    required int periodo,
    required String? disciplina,
    required int totalSemanas,
    required String grupoId,
    int? semanaInicial,
  }) {
    final semanaBase = semanaInicial ?? _semanaSelecionada;
    final maxSemana = ((_diasNoMesSelecionado - 1) ~/ 7) + 1;
    final ultimaSemana = (semanaBase + totalSemanas - 1).clamp(
      semanaBase,
      maxSemana,
    );

    var criadas = 0;
    var jaOcupadas = 0;
    for (var semana = semanaBase; semana <= ultimaSemana; semana++) {
      final ocupado = ReservaService.isSlotOccupied(
        reservas: _reservas,
        laboratorio: _laboratorioSelecionadoValido,
        ano: _anoSelecionado,
        mes: _mesSelecionado,
        semanaDoMes: semana,
        diaSemana: diaSemana,
        turno: turno,
        periodo: periodo,
      );
      if (ocupado) {
        jaOcupadas++;
        continue;
      }
      _reservas.add(
        ReservaService.createReserva(
          professor: professor,
          laboratorio: _laboratorioSelecionadoValido,
          ano: _anoSelecionado,
          mes: _mesSelecionado,
          semanaDoMes: semana,
          diaSemana: diaSemana,
          turno: turno,
          periodo: periodo,
          disciplina: disciplina,
          grupoId: grupoId,
        ),
      );
      criadas++;
    }
    return _ResultadoReserva(criadas: criadas, jaOcupadas: jaOcupadas);
  }

  @override
  Widget build(BuildContext context) {
    final userContext = context.watch<UserContextProvider>();
    final role = userContext.userRole;
    final hasAccess = ReservaService.canAccess(role);

    if (!hasAccess) {
      return const _AccessDenied();
    }

    if (_mostrarCatalogo) {
      return Scaffold(
        body: LaboratoriosCatalogoPage(
          onAbrirReservas: () => setState(() => _mostrarCatalogo = false),
        ),
      );
    }

    final podeEditar = ReservaService.canEdit(role);
    final podeVerOtimizacao = AuthorizationPolicy.canViewOtimizacaoLaboratorios(
      role,
    );

    return Scaffold(
      body: Stack(
        children: [
          const _AmbientBackground(),
          SingleChildScrollView(
            padding: const EdgeInsets.all(5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final stacked =
                        constraints.maxWidth < 460 ||
                        MediaQuery.textScalerOf(context).scale(14) > 18;
                    final title = Text(
                      'Reservas de laboratórios',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w800),
                    );
                    final action = OutlinedButton.icon(
                      onPressed: () => setState(() => _mostrarCatalogo = true),
                      icon: const SigadIcon(SigadIcons.laboratorio),
                      label: const Text('Laboratórios'),
                    );

                    if (stacked) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          title,
                          const SizedBox(height: 8),
                          Align(
                            alignment: Alignment.centerRight,
                            child: action,
                          ),
                        ],
                      );
                    }

                    return Row(
                      children: [
                        Expanded(child: title),
                        action,
                      ],
                    );
                  },
                ),
                const SizedBox(height: 12),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final stacked =
                        constraints.maxWidth < 560 ||
                        MediaQuery.textScalerOf(context).scale(14) > 18;
                    final laboratorio = _FiltroLabRow(
                      laboratorioSelecionado: _laboratorioSelecionadoValido,
                      laboratorios: _laboratoriosDefault,
                      onChanged: (value) =>
                          setState(() => _laboratorioSelecionado = value),
                    );
                    final periodo = _FiltroPeriodoRow(
                      anoSelecionado: _anoSelecionado,
                      mesSelecionado: _mesSelecionado,
                      meses: _mesesDefault,
                      onAnterior: _irParaMesAnterior,
                      onProximo: _irParaProximoMes,
                      onSelecionarPeriodo: _abrirSeletorMesAno,
                    );

                    if (stacked) {
                      return Column(
                        children: [
                          laboratorio,
                          const SizedBox(height: 10),
                          periodo,
                        ],
                      );
                    }

                    return Row(
                      children: [
                        Expanded(flex: 3, child: laboratorio),
                        const SizedBox(width: 10),
                        Expanded(flex: 2, child: periodo),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 10),
                _SelecaoDiaMesRow(
                  anoSelecionado: _anoSelecionado,
                  mesSelecionado: _mesSelecionado,
                  diaSelecionado: _diaSelecionado,
                  diasNoMes: _diasNoMesSelecionado,
                  onDiaChanged: (value) =>
                      setState(() => _diaSelecionado = value),
                  onMesAnterior: _irParaMesAnterior,
                  onProximoMes: _irParaProximoMes,
                ),
                if (podeVerOtimizacao) ...[
                  const SizedBox(height: 12),
                  _PainelOtimizacaoLaboratorio(
                    indicadores: _indicadoresOcupacao,
                    sugestoes: _sugestoesReserva,
                    recomendacoesCruzadas: _recomendacoesCruzadas,
                    laboratorioSelecionado: _laboratorioSelecionadoValido,
                    onAplicarSugestao: podeEditar
                        ? _reservarSugestaoAutomatica
                        : null,
                  ),
                ],
                const SizedBox(height: 12),
                _MapaSemanal(
                  anoSelecionado: _anoSelecionado,
                  mesSelecionado: _mesSelecionado,
                  mesLabel:
                      '${ReservaService.nomeMes(_mesSelecionado, _mesesDefault)} de $_anoSelecionado',
                  semanaLabel: ReservaService.descricaoSemana(
                    _semanaSelecionada,
                  ),
                  diaSelecionado: _diaSelecionado,
                  diaSemanaSelecionado: _diaSemanaAbreviadoDoDiaSelecionado,
                  diaSemanaSelecionadoCompleto:
                      _diaSemanaCompletoDoDiaSelecionado,
                  reservas: _reservasDoLaboratorio,
                  podeEditar: podeEditar,
                  onTapCelula: (diaSemana, turno, periodo, reservaAtual) {
                    return _onTapCelula(
                      diaSemana: diaSemana,
                      turno: turno,
                      periodo: periodo,
                      reservaAtual: reservaAtual,
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _onTapCelula({
    required String diaSemana,
    required Turno turno,
    required int periodo,
    required ReservaLaboratorio? reservaAtual,
  }) async {
    try {
      final userContext = context.read<UserContextProvider>();
      final user = userContext.currentUser;
      final role = userContext.userRole;

      if (user == null ||
          !ReservaService.canChangeReservation(user: user, role: role)) {
        _showInfo('Somente perfis docentes podem alterar reservas pela grade.');
        return;
      }
      final currentUser = user;

      if (reservaAtual == null) {
        String? disciplina;
        var totalSemanas = 1;
        var periodosSelecionados = <(Turno, int)>[(turno, periodo)];

        if (ReservaService.canEdit(role)) {
          final result = await showDialog<Map<String, dynamic>>(
            context: context,
            builder: (_) => DialogDisciplinaSemanasReserva(
              diaSemanaCompleto: ReservaService.diaCompleto(diaSemana),
              horarios: ReservaService.gerarLinhasGrade(),
              turnoInicial: turno,
              periodoInicial: periodo,
              isOcupado: (t, p) => ReservaService.isSlotOccupied(
                reservas: _reservas,
                laboratorio: _laboratorioSelecionadoValido,
                ano: _anoSelecionado,
                mes: _mesSelecionado,
                semanaDoMes: _semanaSelecionada,
                diaSemana: diaSemana,
                turno: t,
                periodo: p,
              ),
            ),
          );
          if (result == null) {
            return;
          }
          disciplina = result['disciplina'] as String?;
          totalSemanas = result['totalSemanas'] as int? ?? 1;
          final periodos = result['periodos'] as List<dynamic>?;
          if (periodos != null && periodos.isNotEmpty) {
            periodosSelecionados = periodos
                .cast<Map<String, dynamic>>()
                .map(
                  (item) => (
                    Turno.values.byName(item['turno'] as String),
                    item['periodo'] as int,
                  ),
                )
                .toList(growable: false);
          }
        }

        final grupoId = 'GRP-${DateTime.now().microsecondsSinceEpoch}';
        var totalCriadas = 0;
        var totalJaOcupadas = 0;
        setState(() {
          for (final (turnoSelecionado, periodoSelecionado)
              in periodosSelecionados) {
            final resultado = _criarReservasParaCelula(
              professor: currentUser.name,
              diaSemana: diaSemana,
              turno: turnoSelecionado,
              periodo: periodoSelecionado,
              disciplina: disciplina,
              totalSemanas: totalSemanas,
              grupoId: grupoId,
            );
            totalCriadas += resultado.criadas;
            totalJaOcupadas += resultado.jaOcupadas;
          }
        });

        if (totalCriadas == 0) {
          _showInfo('Este horário acabou de ser reservado por outro usuário.');
          return;
        }

        await _saveData();

        AppEventLogger.action(
          'reserva_create',
          details: {
            'laboratorio': _laboratorioSelecionadoValido,
            'diaSemana': diaSemana,
            'turno': turno.name,
            'periodo': periodo,
            'professor': currentUser.name,
            'horariosReservados': periodosSelecionados.length,
            'reservasCriadas': totalCriadas,
          },
        );

        _showInfo(
          totalCriadas == 1
              ? 'Horário reservado com sucesso.'
              : '$totalCriadas horários reservados com sucesso.'
                    '${totalJaOcupadas > 0 ? ' $totalJaOcupadas já estavam ocupados.' : ''}',
        );
        return;
      }

      if (!ReservaService.canRemoveReservation(
        role: role,
        currentUserName: currentUser.name,
        reserva: reservaAtual,
      )) {
        _showInfo('Você só pode editar ou remover as próprias reservas.');
        return;
      }

      final grupo = _reservas
          .where(
            (item) =>
                item.grupoId == reservaAtual.grupoId &&
                item.laboratorio == reservaAtual.laboratorio &&
                item.ano == reservaAtual.ano &&
                item.mes == reservaAtual.mes,
          )
          .toList(growable: false);

      final acao = await _escolherAcaoReserva(reservaAtual);
      if (acao == null) return;

      if (acao == _AcaoReserva.editar) {
        await _executarEdicao(reservaAtual: reservaAtual, grupo: grupo);
        return;
      }

      await _executarExclusao(reservaAtual: reservaAtual, grupo: grupo);
    } catch (error, stackTrace) {
      AppEventLogger.error('reserva_error', error, stackTrace: stackTrace);

      _showError('Não foi possível concluir a operação. Tente novamente.');
    }
  }

  Future<_AcaoReserva?> _escolherAcaoReserva(ReservaLaboratorio reserva) async {
    return showDialog<_AcaoReserva>(
      context: context,
      builder: (dialogContext) => SimpleDialog(
        title: Text(reserva.disciplina ?? 'Reserva de laboratório'),
        children: [
          SimpleDialogOption(
            onPressed: () =>
                Navigator.of(dialogContext).pop(_AcaoReserva.editar),
            child: const ListTile(
              leading: SigadIcon(SigadIcons.editar),
              title: Text('Editar reserva'),
              contentPadding: EdgeInsets.zero,
            ),
          ),
          SimpleDialogOption(
            onPressed: () =>
                Navigator.of(dialogContext).pop(_AcaoReserva.excluir),
            child: const ListTile(
              leading: SigadIcon(SigadIcons.excluir, color: SigadColors.risk),
              title: Text('Excluir reserva'),
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ],
      ),
    );
  }

  List<ReservaLaboratorio> _ordenarOcorrencias(
    List<ReservaLaboratorio> ocorrencias,
  ) {
    final ordenado = List<ReservaLaboratorio>.from(ocorrencias);
    ordenado.sort((a, b) {
      final porSemana = a.semanaDoMes.compareTo(b.semanaDoMes);
      if (porSemana != 0) return porSemana;
      return a.diaSemana.compareTo(b.diaSemana);
    });
    return ordenado;
  }

  String _rotuloOcorrencia(ReservaLaboratorio ocorrencia) =>
      '${ReservaService.diaCompleto(ocorrencia.diaSemana)} · '
      '${ocorrencia.turno.horarioDo(ocorrencia.periodo)}';

  /// Deixa o usuário escolher exatamente quais ocorrências de uma reserva
  /// recorrente devem ser afetadas, em vez de o app decidir por "esta" ou
  /// "todas".
  Future<Set<String>?> _selecionarOcorrencias({
    required String titulo,
    required String mensagem,
    required List<ReservaLaboratorio> grupo,
    required Set<String> selecionadosIniciais,
    required String labelConfirmar,
  }) {
    return showDialog<Set<String>>(
      context: context,
      builder: (_) => _DialogSelecionarOcorrencias(
        titulo: titulo,
        mensagem: mensagem,
        ocorrencias: _ordenarOcorrencias(grupo),
        rotulo: _rotuloOcorrencia,
        selecionadosIniciais: selecionadosIniciais,
        labelConfirmar: labelConfirmar,
      ),
    );
  }

  Future<void> _executarEdicao({
    required ReservaLaboratorio reservaAtual,
    required List<ReservaLaboratorio> grupo,
  }) async {
    var idsSelecionados = {reservaAtual.id};
    if (grupo.length > 1) {
      final selecionados = await _selecionarOcorrencias(
        titulo: 'Editar ocorrências',
        mensagem:
            'Essa reserva se repete em ${grupo.length} ocorrências. Selecione quais você quer editar.',
        grupo: grupo,
        selecionadosIniciais: {reservaAtual.id},
        labelConfirmar: 'Continuar',
      );
      if (selecionados == null || selecionados.isEmpty) return;
      idsSelecionados = selecionados;
    }

    final resultado = await _editarReserva(reservaAtual);
    if (resultado == null) return;

    final novoDiaSemana = resultado['diaSemana'] as String;
    final novoTurno = Turno.values.byName(resultado['turno'] as String);
    final novoPeriodo = resultado['periodo'] as int;
    final novaDisciplinaBruta = resultado['disciplina'] as String?;
    final novaDisciplina = (novaDisciplinaBruta?.isEmpty ?? true)
        ? null
        : novaDisciplinaBruta;

    final ocorrenciasSelecionadas = grupo
        .where((item) => idsSelecionados.contains(item.id))
        .toList(growable: false);

    var totalAtualizadas = 0;
    var totalConflitos = 0;
    setState(() {
      for (final ocorrencia in ocorrenciasSelecionadas) {
        final moveu =
            novoDiaSemana != ocorrencia.diaSemana ||
            novoTurno != ocorrencia.turno ||
            novoPeriodo != ocorrencia.periodo;

        if (moveu &&
            ReservaService.isSlotOccupied(
              reservas: _reservas,
              laboratorio: _laboratorioSelecionadoValido,
              ano: ocorrencia.ano,
              mes: _mesSelecionado,
              semanaDoMes: ocorrencia.semanaDoMes,
              diaSemana: novoDiaSemana,
              turno: novoTurno,
              periodo: novoPeriodo,
            )) {
          totalConflitos++;
          continue;
        }

        final index = _reservas.indexWhere((item) => item.id == ocorrencia.id);
        if (index != -1) {
          _reservas[index] = ReservaLaboratorio(
            id: ocorrencia.id,
            professor: ocorrencia.professor,
            laboratorio: ocorrencia.laboratorio,
            ano: ocorrencia.ano,
            mes: ocorrencia.mes,
            semanaDoMes: ocorrencia.semanaDoMes,
            diaSemana: novoDiaSemana,
            turno: novoTurno,
            periodo: novoPeriodo,
            disciplina: novaDisciplina,
            grupoId: ocorrencia.grupoId,
          );
          totalAtualizadas++;
        }
      }
    });

    if (totalAtualizadas == 0) {
      _showInfo(
        'Não foi possível salvar: o novo horário já está ocupado em todas as ocorrências selecionadas.',
      );
      return;
    }

    await _saveData();

    AppEventLogger.action(
      'reserva_edit',
      details: {
        'grupoId': reservaAtual.grupoId,
        'laboratorio': reservaAtual.laboratorio,
        'ocorrenciasEditadas': totalAtualizadas,
        'diaSemanaNova': novoDiaSemana,
        'turnoNovo': novoTurno.name,
        'periodoNovo': novoPeriodo,
      },
    );

    _showInfo(
      totalAtualizadas == 1
          ? 'Reserva atualizada.'
          : '$totalAtualizadas ocorrências atualizadas.'
                '${totalConflitos > 0 ? ' $totalConflitos não puderam ser movidas (horário ocupado).' : ''}',
    );
  }

  Future<void> _executarExclusao({
    required ReservaLaboratorio reservaAtual,
    required List<ReservaLaboratorio> grupo,
  }) async {
    var idsSelecionados = {reservaAtual.id};
    if (grupo.length > 1) {
      final selecionados = await _selecionarOcorrencias(
        titulo: 'Excluir ocorrências',
        mensagem:
            'Essa reserva se repete em ${grupo.length} ocorrências. Selecione quais você quer excluir.',
        grupo: grupo,
        selecionadosIniciais: const {},
        labelConfirmar: 'Revisar exclusão',
      );
      if (selecionados == null || selecionados.isEmpty) return;
      idsSelecionados = selecionados;
    }

    final ocorrenciasSelecionadas = _ordenarOcorrencias(
      grupo.where((item) => idsSelecionados.contains(item.id)).toList(),
    );
    final unica = ocorrenciasSelecionadas.singleOrNull;
    final confirmarExclusao = await _confirmarAcao(
      titulo: 'Excluir reserva',
      mensagem: unica != null
          ? 'Deseja remover sua reserva de ${ReservaService.diaCompleto(unica.diaSemana)}, ${unica.turno.horarioDo(unica.periodo)}, ${ReservaService.descricaoSemana(unica.semanaDoMes)} de ${ReservaService.nomeMes(unica.mes, _mesesDefault)} de ${unica.ano} no ${unica.laboratorio}?'
          : 'Deseja remover as ${idsSelecionados.length} ocorrências selecionadas no $_laboratorioSelecionadoValido?',
      confirmarLabel: 'Excluir',
      isDelete: true,
    );

    if (!confirmarExclusao) return;

    setState(() {
      _reservas.removeWhere((reserva) => idsSelecionados.contains(reserva.id));
    });
    final salvo = await _saveData();
    if (!salvo) {
      setState(() => _reservas.addAll(ocorrenciasSelecionadas));
      return;
    }

    AppEventLogger.action(
      'reserva_remove',
      details: {
        'grupoId': reservaAtual.grupoId,
        'laboratorio': reservaAtual.laboratorio,
        'ocorrenciasRemovidas': idsSelecionados.length,
      },
    );

    _showInfo(
      idsSelecionados.length == 1
          ? 'Reserva removida.'
          : '${idsSelecionados.length} ocorrências removidas.',
    );
  }

  Future<Map<String, dynamic>?> _editarReserva(ReservaLaboratorio reserva) {
    return showDialog<Map<String, dynamic>>(
      context: context,
      builder: (_) => _DialogEditarReserva(
        reserva: reserva,
        horarios: ReservaService.gerarLinhasGrade(),
        isOcupado: (dia, t, p) => _reservas.any(
          (item) =>
              item.id != reserva.id &&
              item.laboratorio == _laboratorioSelecionadoValido &&
              item.ano == _anoSelecionado &&
              item.mes == _mesSelecionado &&
              item.semanaDoMes == _semanaSelecionada &&
              item.diaSemana == dia &&
              item.turno == t &&
              item.periodo == p,
        ),
      ),
    );
  }

  Future<void> _reservarSugestaoAutomatica() async {
    final userContext = context.read<UserContextProvider>();
    final user = userContext.currentUser;
    final role = userContext.userRole;

    if (!ReservaService.canChangeReservation(user: user, role: role)) {
      _showInfo('Somente perfis docentes podem reservar horários.');
      return;
    }

    if (user == null) {
      _showInfo('Faça login para reservar horários.');
      return;
    }

    final sugestoes = _sugestoesReserva;
    if (sugestoes.isEmpty) {
      _showInfo('Não há slots livres recomendados para a semana selecionada.');
      return;
    }

    final sugestao = sugestoes.first;
    final jaOcupado = ReservaService.isSlotOccupied(
      reservas: _reservas,
      laboratorio: sugestao.laboratorio,
      ano: _anoSelecionado,
      mes: _mesSelecionado,
      semanaDoMes: _semanaSelecionada,
      diaSemana: sugestao.diaSemana,
      turno: sugestao.turno,
      periodo: sugestao.periodo,
    );

    if (jaOcupado) {
      _showInfo('A sugestão ficou indisponível. Tente novamente.');
      return;
    }

    setState(() {
      _laboratorioSelecionado = sugestao.laboratorio;
      _reservas.add(
        ReservaService.createReserva(
          professor: user.name,
          laboratorio: sugestao.laboratorio,
          ano: _anoSelecionado,
          mes: _mesSelecionado,
          semanaDoMes: _semanaSelecionada,
          diaSemana: sugestao.diaSemana,
          turno: sugestao.turno,
          periodo: sugestao.periodo,
          disciplina: 'Reserva sugerida automaticamente',
        ),
      );
    });

    await _saveData();

    AppEventLogger.action(
      'reserva_auto_create',
      details: {
        'laboratorio': sugestao.laboratorio,
        'diaSemana': sugestao.diaSemana,
        'turno': sugestao.turno.name,
        'periodo': sugestao.periodo,
        'score': sugestao.score.toStringAsFixed(2),
      },
    );

    _showInfo(
      'Reserva automática criada em ${sugestao.laboratorio} (${sugestao.diaSemana} ${sugestao.horario}).',
    );
  }

  Future<bool> _confirmarAcao({
    required String titulo,
    required String mensagem,
    required String confirmarLabel,
    bool isDelete = false,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(titulo),
          content: Text(mensagem),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              style: isDelete
                  ? FilledButton.styleFrom(backgroundColor: SigadColors.risk)
                  : null,
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text(confirmarLabel),
            ),
          ],
        );
      },
    );

    return result ?? false;
  }

  void _showInfo(String message) {
    if (!mounted) return;
    AppFeedbackService.info(context, message);
  }

  void _showError(String message) {
    if (!mounted) return;
    AppFeedbackService.error(context, message);
  }
}

class _DialogEditarReserva extends StatefulWidget {
  const _DialogEditarReserva({
    required this.reserva,
    required this.horarios,
    required this.isOcupado,
  });

  final ReservaLaboratorio reserva;
  final List<HorarioGridRow> horarios;
  final bool Function(String diaSemana, Turno turno, int periodo) isOcupado;

  @override
  State<_DialogEditarReserva> createState() => _DialogEditarReservaState();
}

class _DialogEditarReservaState extends State<_DialogEditarReserva> {
  static const _diasAbreviados = ['Seg', 'Ter', 'Qua', 'Qui', 'Sex'];

  late final TextEditingController _disciplinaController =
      TextEditingController(text: widget.reserva.disciplina ?? '');
  late String _diaSelecionado = widget.reserva.diaSemana;
  late Turno _turnoSelecionado = widget.reserva.turno;
  late int _periodoSelecionado = widget.reserva.periodo;

  @override
  void dispose() {
    _disciplinaController.dispose();
    super.dispose();
  }

  bool _ehSlotAtual(String dia, Turno turno, int periodo) =>
      dia == widget.reserva.diaSemana &&
      turno == widget.reserva.turno &&
      periodo == widget.reserva.periodo;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return AlertDialog(
      title: const Text('Editar reserva'),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _disciplinaController,
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: 'Disciplina (opcional)',
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Dia da semana',
                style: textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  for (final dia in _diasAbreviados)
                    ChoiceChip(
                      label: Text(dia),
                      selected: _diaSelecionado == dia,
                      onSelected: (_) => setState(() => _diaSelecionado = dia),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'Horário',
                style: textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              for (final turno in Turno.values) ...[
                Text(
                  turno.label,
                  style: textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: turno.chipTextColor,
                  ),
                ),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    for (final linha in widget.horarios.where(
                      (item) => item.turno == turno,
                    ))
                      Builder(
                        builder: (context) {
                          final ehAtual = _ehSlotAtual(
                            _diaSelecionado,
                            turno,
                            linha.periodo,
                          );
                          final ocupado =
                              !ehAtual &&
                              widget.isOcupado(
                                _diaSelecionado,
                                turno,
                                linha.periodo,
                              );
                          final selecionado =
                              _turnoSelecionado == turno &&
                              _periodoSelecionado == linha.periodo;
                          return FilterChip(
                            label: Text(
                              '${turno.shortLabel}${linha.periodo}',
                              style: ocupado
                                  ? const TextStyle(
                                      decoration: TextDecoration.lineThrough,
                                    )
                                  : null,
                            ),
                            selected: selecionado,
                            tooltip: ocupado ? 'Horário já ocupado' : null,
                            onSelected: ocupado
                                ? null
                                : (_) => setState(() {
                                    _turnoSelecionado = turno;
                                    _periodoSelecionado = linha.periodo;
                                  }),
                          );
                        },
                      ),
                  ],
                ),
                const SizedBox(height: 8),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop({
            'diaSemana': _diaSelecionado,
            'turno': _turnoSelecionado.name,
            'periodo': _periodoSelecionado,
            'disciplina': _disciplinaController.text.trim(),
          }),
          child: const Text('Salvar'),
        ),
      ],
    );
  }
}

class _DialogSelecionarOcorrencias extends StatefulWidget {
  const _DialogSelecionarOcorrencias({
    required this.titulo,
    required this.mensagem,
    required this.ocorrencias,
    required this.rotulo,
    required this.selecionadosIniciais,
    required this.labelConfirmar,
  });

  final String titulo;
  final String mensagem;
  final List<ReservaLaboratorio> ocorrencias;
  final String Function(ReservaLaboratorio ocorrencia) rotulo;
  final Set<String> selecionadosIniciais;
  final String labelConfirmar;

  @override
  State<_DialogSelecionarOcorrencias> createState() =>
      _DialogSelecionarOcorrenciasState();
}

class _DialogSelecionarOcorrenciasState
    extends State<_DialogSelecionarOcorrencias> {
  late final Set<String> _selecionados = {...widget.selecionadosIniciais};

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return AlertDialog(
      title: Text(widget.titulo),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.mensagem,
                style: textTheme.bodySmall?.copyWith(color: SigadColors.muted),
              ),
              const SizedBox(height: 4),
              for (final ocorrencia in widget.ocorrencias)
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  value: _selecionados.contains(ocorrencia.id),
                  title: Text(widget.rotulo(ocorrencia)),
                  subtitle: Text(
                    ReservaService.descricaoSemana(ocorrencia.semanaDoMes),
                  ),
                  onChanged: (selecionado) => setState(() {
                    if (selecionado ?? false) {
                      _selecionados.add(ocorrencia.id);
                    } else {
                      _selecionados.remove(ocorrencia.id);
                    }
                  }),
                ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: _selecionados.isEmpty
              ? null
              : () => Navigator.of(context).pop(_selecionados),
          child: Text(widget.labelConfirmar),
        ),
      ],
    );
  }
}

class _FiltroLabRow extends StatelessWidget {
  const _FiltroLabRow({
    required this.laboratorioSelecionado,
    required this.laboratorios,
    required this.onChanged,
  });

  final String laboratorioSelecionado;
  final List<String> laboratorios;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      isExpanded: true,
      initialValue: laboratorioSelecionado,
      decoration: const InputDecoration(labelText: 'Laboratório'),
      items: laboratorios
          .map(
            (lab) => DropdownMenuItem(
              value: lab,
              child: Text(lab, maxLines: 1, overflow: TextOverflow.ellipsis),
            ),
          )
          .toList(),
      onChanged: (value) {
        if (value != null) onChanged(value);
      },
    );
  }
}

class _FiltroPeriodoRow extends StatelessWidget {
  const _FiltroPeriodoRow({
    required this.anoSelecionado,
    required this.mesSelecionado,
    required this.meses,
    required this.onAnterior,
    required this.onProximo,
    required this.onSelecionarPeriodo,
  });

  final int anoSelecionado;
  final int mesSelecionado;
  final List<String> meses;
  final VoidCallback onAnterior;
  final VoidCallback onProximo;
  final VoidCallback onSelecionarPeriodo;

  @override
  Widget build(BuildContext context) {
    final titulo = '${meses[mesSelecionado - 1]} de $anoSelecionado';
    return Semantics(
      container: true,
      label: 'Navegação do calendário',
      child: Row(
        children: [
          IconButton(
            onPressed: anoSelecionado == 2020 && mesSelecionado == 1
                ? null
                : onAnterior,
            tooltip: 'Mês anterior',
            icon: const SigadIcon(SigadIcons.chevronEsquerda),
          ),
          Expanded(
            child: Tooltip(
              message: 'Escolher mês e ano',
              child: OutlinedButton(
                onPressed: onSelecionarPeriodo,
                child: Text(titulo, textAlign: TextAlign.center, maxLines: 2),
              ),
            ),
          ),
          IconButton(
            onPressed: anoSelecionado == 2100 && mesSelecionado == 12
                ? null
                : onProximo,
            tooltip: 'Próximo mês',
            icon: const SigadIcon(SigadIcons.chevronDireita),
          ),
        ],
      ),
    );
  }
}

class _SelecaoDiaMesRow extends StatelessWidget {
  const _SelecaoDiaMesRow({
    required this.anoSelecionado,
    required this.mesSelecionado,
    required this.diaSelecionado,
    required this.diasNoMes,
    required this.onDiaChanged,
    required this.onMesAnterior,
    required this.onProximoMes,
  });

  final int anoSelecionado;
  final int mesSelecionado;
  final int diaSelecionado;
  final int diasNoMes;
  final ValueChanged<int> onDiaChanged;
  final VoidCallback onMesAnterior;
  final VoidCallback onProximoMes;

  @override
  Widget build(BuildContext context) {
    // Calcula em qual dia da semana o mês começa para alinhar o grid
    final primeiroDiaDoMes = DateTime(anoSelecionado, mesSelecionado, 1);
    // weekday: 1 (seg) a 7 (dom). Subtraímos 1 para o offset começar na segunda.
    final offset = primeiroDiaDoMes.weekday - 1;

    const diasSemanaHeader = ['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb', 'Dom'];

    final feriadoSelecionado = FeriadoService.feriadoEm(
      DateTime(anoSelecionado, mesSelecionado, diaSelecionado),
    );

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onHorizontalDragEnd: (details) {
        final velocidade = details.primaryVelocity ?? 0;
        if (velocidade.abs() < 250) return;
        if (velocidade < 0) {
          onProximoMes();
        } else {
          onMesAnterior();
        }
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: SigadColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: SigadColors.divider),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cabeçalho com as iniciais dos dias da semana
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: diasSemanaHeader
                  .map(
                    (d) => Expanded(
                      child: Center(
                        child: Text(
                          d,
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: const Color.fromARGB(255, 17, 17, 17),
                                fontSize: 12,
                              ),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 6),
            // Grade de dias com offset para alinhamento correto
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                mainAxisSpacing: 4,
                crossAxisSpacing: 4,
                childAspectRatio:
                    1.1, // Torna as células levemente mais achatadas
              ),
              itemCount: offset + diasNoMes,
              itemBuilder: (context, index) {
                if (index < offset) return const SizedBox.shrink();

                final dia = index - offset + 1;
                final isSelected = dia == diaSelecionado;
                final feriado = FeriadoService.feriadoEm(
                  DateTime(anoSelecionado, mesSelecionado, dia),
                );
                return Semantics(
                  button: true,
                  selected: isSelected,
                  label: feriado == null
                      ? 'Dia $dia'
                      : 'Dia $dia, feriado: ${feriado.descricao}',
                  excludeSemantics: true,
                  child: InkWell(
                    onTap: () => onDiaChanged(dia),
                    borderRadius: BorderRadius.circular(4),
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected
                            ? SigadColors.brand
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: isSelected
                              ? SigadColors.brand
                              : feriado != null
                              ? SigadColors.warning
                              : SigadColors.divider.withValues(alpha: 0.5),
                          width: feriado != null ? 2 : 1,
                        ),
                      ),
                      child: Stack(
                        children: [
                          Center(
                            child: Text(
                              '$dia',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                color: isSelected
                                    ? Colors.white
                                    : SigadColors.ink,
                              ),
                            ),
                          ),
                          if (feriado != null)
                            Positioned(
                              right: 2,
                              top: 2,
                              child: SigadIcon(
                                SigadIcons.bandeira,
                                size: 10,
                                color: isSelected
                                    ? Colors.white
                                    : SigadColors.warning,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 8),
            if (feriadoSelecionado != null)
              Semantics(
                liveRegion: true,
                label: 'Feriado selecionado: ${feriadoSelecionado.descricao}',
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SigadIcon(
                      SigadIcons.bandeira,
                      size: 18,
                      color: SigadColors.warning,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        feriadoSelecionado.descricao,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 4),
            Text(
              FeriadoService.avisoEscopo,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: SigadColors.muted),
            ),
          ],
        ),
      ),
    );
  }
}

class _MapaSemanal extends StatefulWidget {
  const _MapaSemanal({
    required this.anoSelecionado,
    required this.mesSelecionado,
    required this.mesLabel,
    required this.semanaLabel,
    required this.diaSelecionado,
    required this.diaSemanaSelecionado,
    required this.diaSemanaSelecionadoCompleto,
    required this.reservas,
    required this.podeEditar,
    required this.onTapCelula,
  });

  final int anoSelecionado;
  final int mesSelecionado;
  final String mesLabel;
  final String semanaLabel;
  final int diaSelecionado;
  final String diaSemanaSelecionado;
  final String diaSemanaSelecionadoCompleto;
  final List<ReservaLaboratorio> reservas;
  final bool podeEditar;
  final Future<void> Function(
    String diaSemana,
    Turno turno,
    int periodo,
    ReservaLaboratorio? reservaAtual,
  )
  onTapCelula;

  @override
  State<_MapaSemanal> createState() => _MapaSemanalState();
}

class _MapaSemanalState extends State<_MapaSemanal> {
  static const List<String> _diasAbreviados = [
    'Seg',
    'Ter',
    'Qua',
    'Qui',
    'Sex',
  ];

  Turno? _turnoSelecionado;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final linhas = _gerarLinhasGrade();
    final diasDoMesDaSemana = _diasDoMesDaSemanaSelecionada();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Agenda semanal',
          style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 4),
        Text(
          '${widget.semanaLabel} de ${widget.mesLabel} · Dia ${widget.diaSelecionado} (${widget.diaSemanaSelecionado})',
          style: textTheme.bodySmall?.copyWith(color: SigadColors.muted),
        ),
        const SizedBox(height: 12),
        _TurnoTabs(
          selecionado: _turnoSelecionado,
          onSelected: (turno) => setState(() => _turnoSelecionado = turno),
        ),
        const SizedBox(height: 12),
        _GradeSemanal(
          diasAbreviados: _diasAbreviados,
          diasDoMes: diasDoMesDaSemana,
          diaSemanaSelecionado: widget.diaSemanaSelecionado,
          linhas: linhas,
          reservaPara: _reservaPara,
          podeEditar: widget.podeEditar,
          onTapCelula: widget.onTapCelula,
        ),
      ],
    );
  }

  List<HorarioGridRow> _gerarLinhasGrade() {
    final todasAsLinhas = ReservaService.gerarLinhasGrade();
    if (_turnoSelecionado == null) return todasAsLinhas;
    return todasAsLinhas
        .where((linha) => linha.turno == _turnoSelecionado)
        .toList(growable: false);
  }

  ReservaLaboratorio? _reservaPara(
    String diaSemana,
    Turno turno,
    int periodo,
  ) => ReservaService.reservaPara(
    reservas: widget.reservas,
    diaSemana: diaSemana,
    turno: turno,
    periodo: periodo,
  );

  List<int> _diasDoMesDaSemanaSelecionada() {
    final dataSelecionada = DateTime(
      widget.anoSelecionado,
      widget.mesSelecionado,
      widget.diaSelecionado,
    );
    final inicioDaSemana = dataSelecionada.subtract(
      Duration(days: dataSelecionada.weekday - DateTime.monday),
    );
    return List<int>.generate(
      5,
      (index) => inicioDaSemana.add(Duration(days: index)).day,
    );
  }
}

class _TurnoTabs extends StatelessWidget {
  const _TurnoTabs({required this.selecionado, required this.onSelected});

  final Turno? selecionado;
  final ValueChanged<Turno?> onSelected;

  static const _opcoes = <MapEntry<String, Turno?>>[
    MapEntry('Todos', null),
    MapEntry('Manhã', Turno.matutino),
    MapEntry('Tarde', Turno.vespertino),
    MapEntry('Noite', Turno.noturno),
  ];

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          for (final opcao in _opcoes)
            Expanded(
              child: _TurnoTabButton(
                label: opcao.key,
                selecionado: selecionado == opcao.value,
                onTap: () => onSelected(opcao.value),
              ),
            ),
        ],
      ),
    );
  }
}

class _TurnoTabButton extends StatelessWidget {
  const _TurnoTabButton({
    required this.label,
    required this.selecionado,
    required this.onTap,
  });

  final String label;
  final bool selecionado;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Material(
      color: selecionado ? colors.surface : Colors.transparent,
      borderRadius: BorderRadius.circular(9),
      elevation: selecionado ? 1 : 0,
      child: InkWell(
        borderRadius: BorderRadius.circular(9),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 9),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: selecionado ? FontWeight.w800 : FontWeight.w500,
              color: selecionado ? SigadColors.brand : colors.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }
}

class _GradeSemanal extends StatelessWidget {
  const _GradeSemanal({
    required this.diasAbreviados,
    required this.diasDoMes,
    required this.diaSemanaSelecionado,
    required this.linhas,
    required this.reservaPara,
    required this.podeEditar,
    required this.onTapCelula,
  });

  final List<String> diasAbreviados;
  final List<int> diasDoMes;
  final String diaSemanaSelecionado;
  final List<HorarioGridRow> linhas;
  final ReservaLaboratorio? Function(String diaSemana, Turno turno, int periodo)
  reservaPara;
  final bool podeEditar;
  final Future<void> Function(
    String diaSemana,
    Turno turno,
    int periodo,
    ReservaLaboratorio? reservaAtual,
  )
  onTapCelula;

  static const double _rowHeight = 60;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final textoAmpliado = MediaQuery.textScalerOf(context).scale(14) > 18;
        final rowHeight = textoAmpliado ? 96.0 : _rowHeight;
        final minimumWidth = textoAmpliado ? 700.0 : 560.0;
        final gridWidth = constraints.maxWidth < minimumWidth
            ? minimumWidth
            : constraints.maxWidth;

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            width: gridWidth,
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: SigadColors.divider),
                borderRadius: BorderRadius.circular(8),
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (var index = 0; index < linhas.length; index++) ...[
                    if (index == 0 ||
                        linhas[index - 1].turno != linhas[index].turno)
                      _TurnoDividerRow(turno: linhas[index].turno),
                    Row(
                      children: [
                        for (
                          var dayIndex = 0;
                          dayIndex < diasAbreviados.length;
                          dayIndex++
                        )
                          Expanded(
                            child: _GradeReservaCell(
                              height: rowHeight,
                              horario: linhas[index].horario,
                              turno: linhas[index].turno,
                              periodo: linhas[index].periodo,
                              diaSemana: diasAbreviados[dayIndex],
                              diaDoMes: diasDoMes[dayIndex],
                              reserva: reservaPara(
                                diasAbreviados[dayIndex],
                                linhas[index].turno,
                                linhas[index].periodo,
                              ),
                              podeEditar: podeEditar,
                              onTapCelula: onTapCelula,
                            ),
                          ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _TurnoDividerRow extends StatelessWidget {
  const _TurnoDividerRow({required this.turno});

  final Turno turno;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: turno.chipBackground,
        border: const Border(
          top: BorderSide(color: SigadColors.divider),
          bottom: BorderSide(color: SigadColors.divider),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: turno.chipTextColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            turno.label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: turno.chipTextColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _GradeReservaCell extends StatelessWidget {
  const _GradeReservaCell({
    required this.height,
    required this.horario,
    required this.turno,
    required this.periodo,
    required this.diaSemana,
    required this.diaDoMes,
    required this.reserva,
    required this.podeEditar,
    required this.onTapCelula,
  });

  final double height;
  final String horario;
  final Turno turno;
  final int periodo;
  final String diaSemana;
  final int diaDoMes;
  final ReservaLaboratorio? reserva;
  final bool podeEditar;
  final Future<void> Function(
    String diaSemana,
    Turno turno,
    int periodo,
    ReservaLaboratorio? reservaAtual,
  )
  onTapCelula;

  @override
  Widget build(BuildContext context) {
    final livre = reserva == null;
    final tone = livre ? SigadColors.success : SigadColors.warning;
    final background = livre
        ? SigadColors.successSoft.withValues(alpha: 0.95)
        : SigadColors.accentSoft.withValues(alpha: 0.95);
    return Semantics(
      button: podeEditar,
      label:
          'Célula $diaSemana, dia $diaDoMes, ${turno.label}, período $periodo, horário $horario.',
      value: livre ? 'Livre' : 'Reservado por ${reserva!.professor}',
      hint: podeEditar ? 'Toque para reservar ou remover reserva.' : null,
      child: InkWell(
        onTap: podeEditar
            ? () => onTapCelula(diaSemana, turno, periodo, reserva)
            : null,
        child: Container(
          height: height,
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
          decoration: BoxDecoration(
            color: background,
            border: Border(
              top: const BorderSide(color: SigadColors.divider),
              right: BorderSide(
                color: diaSemana == 'Sex'
                    ? Colors.transparent
                    : SigadColors.divider,
              ),
              bottom: BorderSide(color: tone.withValues(alpha: 0.25), width: 1),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        '$diaSemana · $diaDoMes',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: SigadColors.brandDark,
                          fontWeight: FontWeight.w700,
                          fontSize: 10,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 1,
                      ),
                      decoration: BoxDecoration(
                        color: turno.chipBackground,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${turno.shortLabel}$periodo',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: turno.chipTextColor,
                          fontWeight: FontWeight.w700,
                          fontSize: 9,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 1),
              Text(
                horario,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: SigadColors.muted,
                  fontWeight: FontWeight.w600,
                  fontSize: 9,
                ),
              ),
              const SizedBox(height: 1),
              Flexible(
                child: Row(
                  children: [
                    SigadIcon(
                      livre ? SigadIcons.concluido : SigadIcons.eventoOcupado,
                      size: 12,
                      color: tone,
                    ),
                    const SizedBox(width: 2),
                    Expanded(
                      child: Text(
                        livre ? 'Livre' : 'Reservado',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: tone,
                          fontSize: 9,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (!livre) ...[
                const SizedBox(height: 1),
                Flexible(
                  child: Text(
                    reserva!.professor,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: SigadColors.brandDark,
                      fontWeight: FontWeight.w600,
                      fontSize: 9,
                    ),
                  ),
                ),
                if (reserva!.disciplina != null)
                  Flexible(
                    child: Text(
                      reserva!.disciplina!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: SigadColors.brandDark,
                        fontWeight: FontWeight.w400,
                        fontSize: 9,
                      ),
                    ),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _DialogDisciplinaReserva extends StatefulWidget {
  const _DialogDisciplinaReserva();

  @override
  State<_DialogDisciplinaReserva> createState() =>
      _DialogDisciplinaReservaState();
}

class _DialogDisciplinaReservaState extends State<_DialogDisciplinaReserva> {
  late final TextEditingController _controller;
  String? _erro;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _continuar() {
    final value = _controller.text.trim();
    if (value.isEmpty) {
      setState(() => _erro = 'Informe a disciplina.');
      return;
    }
    Navigator.of(context).pop(value);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Disciplina da reserva'),
      content: TextField(
        controller: _controller,
        autofocus: true,
        textInputAction: TextInputAction.done,
        decoration: InputDecoration(
          labelText: 'Disciplina',
          hintText: 'Ex.: Química Orgânica',
          errorText: _erro,
        ),
        onChanged: (_) {
          if (_erro != null) {
            setState(() => _erro = null);
          } else {
            setState(() {});
          }
        },
        onSubmitted: (_) => _continuar(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: _controller.text.trim().isEmpty ? null : _continuar,
          child: const Text('Reservar'),
        ),
      ],
    );
  }
}

class _AccessDenied extends StatelessWidget {
  const _AccessDenied();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SigadIcon(
              SigadIcons.cadeado,
              size: 54,
              color: SigadColors.muted,
            ),
            const SizedBox(height: 12),
            Text(
              'Acesso restrito',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              'Este módulo está disponível para professor, coordenador e chefe do departamento.',
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: SigadColors.muted),
            ),
          ],
        ),
      ),
    );
  }
}

class _AmbientBackground extends StatelessWidget {
  const _AmbientBackground();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [SigadColors.canvas, SigadColors.surfaceAlt],
        ),
      ),
    );
  }
}

class _PainelOtimizacaoLaboratorio extends StatelessWidget {
  const _PainelOtimizacaoLaboratorio({
    required this.indicadores,
    required this.sugestoes,
    required this.recomendacoesCruzadas,
    required this.laboratorioSelecionado,
    this.onAplicarSugestao,
  });

  final List<IndicadorOcupacaoLaboratorio> indicadores;
  final List<SugestaoReservaLaboratorio> sugestoes;
  final List<String> recomendacoesCruzadas;
  final String laboratorioSelecionado;
  final Future<void> Function()? onAplicarSugestao;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final indicadoresOrdenados = List<IndicadorOcupacaoLaboratorio>.from(
      indicadores,
    )..sort((a, b) => a.taxaOcupacao.compareTo(b.taxaOcupacao));

    final indicadorSelecionado = indicadores.firstWhere(
      (item) => item.laboratorio == laboratorioSelecionado,
      orElse: () => const IndicadorOcupacaoLaboratorio(
        laboratorio: '',
        totalSlots: 0,
        slotsReservados: 0,
      ),
    );

    final taxa = (indicadorSelecionado.taxaOcupacao * 100);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: SigadColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: SigadColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final textScaler = MediaQuery.textScalerOf(context);
              final stacked =
                  constraints.maxWidth < 420 || textScaler.scale(14) > 18;
              final title = Row(
                children: [
                  const SigadIconAvatar(
                    icon: SigadIcons.tendencia,
                    tone: SigadColors.brand,
                    size: 30,
                    iconSize: 16,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Otimização de laboratórios',
                      maxLines: stacked ? 2 : 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              );
              if (stacked) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    title,
                    if (onAplicarSugestao != null) ...[
                      const SizedBox(height: 4),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton.icon(
                          onPressed: onAplicarSugestao,
                          icon: const SigadIcon(
                            SigadIcons.automatico,
                            size: 16,
                          ),
                          label: const Text('Reservar sugestão'),
                        ),
                      ),
                    ],
                  ],
                );
              }

              return Row(
                children: [
                  Expanded(child: title),
                  if (onAplicarSugestao != null)
                    TextButton.icon(
                      onPressed: onAplicarSugestao,
                      icon: const SigadIcon(SigadIcons.automatico, size: 16),
                      label: const Text('Reservar sugestão'),
                    ),
                ],
              );
            },
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '${taxa.toStringAsFixed(0)}%',
                style: textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: taxa < 40
                      ? SigadColors.success
                      : taxa < 75
                      ? SigadColors.warning
                      : SigadColors.risk,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'ocupado na semana em ${laboratorioSelecionado.isEmpty ? 'N/D' : laboratorioSelecionado}',
                  style: textTheme.bodySmall?.copyWith(
                    color: SigadColors.muted,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: indicadoresOrdenados
                .take(4)
                .toList()
                .asMap()
                .entries
                .map((entry) {
                  final index = entry.key;
                  final indicador = entry.value;
                  final selecionado =
                      indicador.laboratorio == laboratorioSelecionado;
                  final tone = sigadToneForIndex(index);
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: selecionado
                          ? SigadColors.brand.withValues(alpha: 0.12)
                          : tone.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${indicador.laboratorio}: ${(indicador.taxaOcupacao * 100).toStringAsFixed(0)}% · ${indicador.slotsLivres} livres',
                      style: textTheme.labelSmall?.copyWith(
                        color: selecionado ? SigadColors.brandDark : tone,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  );
                })
                .toList(growable: false),
          ),
          if (sugestoes.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              'Sugestões de slots livres',
              style: textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            ...sugestoes
                .take(3)
                .map(
                  (sugestao) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      '• ${sugestao.laboratorio} · ${sugestao.diaSemana} · ${sugestao.horario} (${sugestao.turno.shortLabel}${sugestao.periodo})',
                      style: textTheme.bodySmall?.copyWith(
                        color: SigadColors.ink,
                      ),
                    ),
                  ),
                ),
          ],
          if (recomendacoesCruzadas.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              'Recomendações cruzadas com carga docente',
              style: textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            ...recomendacoesCruzadas
                .take(2)
                .map(
                  (recomendacao) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      '• $recomendacao',
                      style: textTheme.bodySmall?.copyWith(
                        color: SigadColors.ink,
                      ),
                    ),
                  ),
                ),
          ],
        ],
      ),
    );
  }
}
