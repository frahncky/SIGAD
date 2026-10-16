import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../app/theme/sigad_colors.dart';
import '../../../../app/theme/sigad_icon.dart';
import '../../../../app/theme/sigad_icons.dart';
import '../../../../app/theme/sigad_tone_palette.dart';
import '../../data/laboratorio_repository.dart';
import '../../data/reserva_repository.dart';
import '../../domain/feriado_models.dart';
import '../../domain/feriado_service.dart';
import '../../domain/laboratorio_models.dart';
import '../../domain/reserva_models.dart';
import '../../domain/reserva_service.dart';
import '../../../carga_docente/data/docente_repository.dart';
import '../../../carga_docente/domain/docente_models.dart';
import '../../../../core/security/authorization_policy.dart';
import '../../../../core/services/app_event_logger.dart';
import '../../../../core/services/app_feedback_service.dart';
import '../../../../core/services/user_context_provider.dart';
import '../../../../shared/widgets/horizontal_scroll_hint.dart';
import '../../../../shared/widgets/icon_avatar.dart';
import '../../../../l10n/l10n.dart';
import '../laboratorio_l10n.dart';
import '../widgets/dialog_disciplina_semanas_reserva.dart';
import 'laboratorios_catalogo_page.dart';

class _ResultadoReserva {
  const _ResultadoReserva({required this.criadas, required this.jaOcupadas});

  final int criadas;
  final int jaOcupadas;
}

enum _AcaoReserva { editar, excluir }

String _horarioLegivel(String horario) => horario.replaceAll('-', '–');

class AulasPraticasPage extends StatefulWidget {
  const AulasPraticasPage({super.key, this.dataInicial});

  /// Data usada para escolher a semana inicial. Padrão: hoje.
  final DateTime? dataInicial;

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

  late final ReservaRepository _reservaRepository;
  final LaboratorioRepository _laboratorioRepository = LaboratorioRepository();
  final DocenteRepository _docenteRepository = DocenteRepository();
  final List<ReservaLaboratorio> _reservas = [];
  final List<Docente> _docentes = [];
  List<Laboratorio> _catalogo = const [];

  bool _carregando = true;
  String? _laboratorioSelecionado;
  late DateTime _segunda;

  /// Textos no idioma atual (atualizado se o idioma mudar).
  late AppLocalizations _l10n;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _l10n = context.l10n;
  }

  @override
  void initState() {
    super.initState();
    _reservaRepository = ReservaRepository(
      tokenProvider: () => context.read<UserContextProvider>().sessionToken,
    );
    _segunda = ReservaService.segundaDaSemana(
      widget.dataInicial ?? DateTime.now(),
    );
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final catalogoFuture = _laboratorioRepository.load();
      final list = await _reservaRepository.loadReservas();
      final docentes = await _docenteRepository.loadDocentes(
        generateFallbackId: () => 'DOC-FALLBACK',
      );
      final catalogo = await catalogoFuture;
      if (!mounted) return;
      setState(() {
        _catalogo = catalogo;
        _reservas
          ..clear()
          ..addAll(list);
        _docentes
          ..clear()
          ..addAll(docentes);
      });
    } catch (error, stackTrace) {
      AppEventLogger.error(
        'reservas_load_error',
        error,
        stackTrace: stackTrace,
      );
      _showError(_l10n.labErroCarregar);
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  Future<bool> _saveData() async {
    try {
      await _reservaRepository.saveReservas(_reservas);
      return true;
    } on ReservaConflitoException {
      _showError(
        'Outro usuário alterou a agenda. Os horários serão recarregados; '
        'revise a disponibilidade antes de tentar novamente.',
      );
      return false;
    } catch (error, stackTrace) {
      AppEventLogger.error(
        'reservas_save_error',
        error,
        stackTrace: stackTrace,
      );
      _showError(
        _reservaRepository.isShared
            ? 'Não foi possível confirmar no servidor. Nenhuma reserva foi '
                  'confirmada; verifique sua conexão ou acesso institucional.'
            : _l10n.erroSalvar,
      );
      return false;
    }
  }

  /// Grava e, se falhar, volta as reservas para [antes].
  Future<bool> _salvarOuDesfazer(List<ReservaLaboratorio> antes) async {
    final salvo = await _saveData();
    if (!mounted) return false;
    if (!salvo) {
      setState(() {
        _reservas
          ..clear()
          ..addAll(antes);
      });
      // Em modo compartilhado uma falha pode significar revisão obsoleta.
      // Recarregar o estado oficial antes de qualquer nova edição.
      if (_reservaRepository.isShared) {
        try {
          final atuais = await _reservaRepository.loadReservas();
          if (mounted) {
            setState(() {
              _reservas
                ..clear()
                ..addAll(atuais);
            });
          }
        } catch (error, stackTrace) {
          AppEventLogger.error(
            'reservas_reload_error',
            error,
            stackTrace: stackTrace,
          );
        }
      }
    }
    return salvo;
  }

  List<DateTime> get _diasDaSemana => [
    for (var i = 0; i < 5; i++)
      DateTime(_segunda.year, _segunda.month, _segunda.day + i),
  ];

  /// Laboratórios do catálogo; a lista fixa só vale se o catálogo vier vazio.
  /// Laboratórios do catálogo e, para nenhuma reserva sumir da agenda,
  /// também os que só aparecem em reservas já gravadas. A lista fixa só é
  /// usada quando não há nenhum dos dois.
  List<String> get _laboratorios {
    final nomes = <String>[
      for (final laboratorio in _catalogo) laboratorio.nome,
    ];
    final extras = {
      for (final reserva in _reservas)
        if (!nomes.contains(reserva.laboratorio)) reserva.laboratorio,
    }.toList()..sort();
    final todos = [...nomes, ...extras];
    return todos.isEmpty ? _laboratoriosDefault : todos;
  }

  Laboratorio? get _laboratorioAtual {
    for (final laboratorio in _catalogo) {
      if (laboratorio.nome == _laboratorioSelecionadoValido) return laboratorio;
    }
    return null;
  }

  String get _laboratorioSelecionadoValido {
    if (_laboratorioSelecionado != null &&
        _laboratorios.contains(_laboratorioSelecionado)) {
      return _laboratorioSelecionado!;
    }
    return _laboratorios.first;
  }

  List<IndicadorOcupacaoLaboratorio> get _indicadoresOcupacao =>
      ReservaService.calcularOcupacaoNosDias(
        reservas: _reservas,
        laboratorios: _laboratorios,
        dias: _diasDaSemana,
      );

  List<SugestaoReservaLaboratorio> get _sugestoesReserva =>
      ReservaService.sugerirSlotsLivresNosDias(
        reservas: _reservas,
        laboratorios: _laboratorios,
        dias: _diasDaSemana,
        limite: 4,
        diaIndisponivel: (dia) =>
            dia.isBefore(DateUtils.dateOnly(DateTime.now())) ||
            FeriadoService.feriadoEm(dia) != null,
        laboratoriosIndisponiveis: {
          for (final laboratorio in _catalogo)
            if (laboratorio.status != StatusLaboratorio.operando)
              laboratorio.nome,
        },
      );

  List<String> get _recomendacoesCruzadas {
    final sugestoes = _sugestoesReserva;
    final altaCarga = _docentes
        .where((docente) {
          if (docente.cargaMaxima <= 0) return false;
          return (docente.cargaHoraria / docente.cargaMaxima) >= 0.9;
        })
        .toList(growable: false);

    if (altaCarga.isEmpty || sugestoes.isEmpty) {
      return const [];
    }

    final recomendacoes = <String>[];
    final limite = altaCarga.length < sugestoes.length
        ? altaCarga.length
        : sugestoes.length;

    for (var index = 0; index < limite; index++) {
      final docente = altaCarga[index];
      final sugestao = sugestoes[index];
      recomendacoes.add(
        _l10n.labRecomendacao(
          docente.nome.split(' ').first,
          sugestao.laboratorio,
          _l10n.diaAbrev(sugestao.diaSemana),
          sugestao.horario,
        ),
      );
    }

    return recomendacoes;
  }

  void _mudarSemana(int semanas) => setState(
    () => _segunda = DateTime(
      _segunda.year,
      _segunda.month,
      _segunda.day + 7 * semanas,
    ),
  );

  void _irParaHoje() =>
      setState(() => _segunda = ReservaService.segundaDaSemana(DateTime.now()));

  Future<void> _escolherData() async {
    final escolhida = await showDatePicker(
      context: context,
      initialDate: _segunda,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100, 12, 31),
      helpText: _l10n.labIrParaSemana,
    );
    if (escolhida != null) {
      setState(() => _segunda = ReservaService.segundaDaSemana(escolhida));
    }
  }

  /// Cria a reserva na data e, se [totalSemanas] for maior que 1, também nas
  /// semanas seguintes do mesmo mês (pulando horários já ocupados). Deve ser
  /// chamado dentro de um `setState`.
  _ResultadoReserva _criarReservasParaData({
    required String professor,
    required DateTime data,
    required Turno turno,
    required int periodo,
    required String? disciplina,
    required int totalSemanas,
    required String grupoId,
  }) {
    final diaSemana = ReservaService.diaSemanaDe(data)!;
    var criadas = 0;
    var jaOcupadas = 0;
    for (var i = 0; i < totalSemanas; i++) {
      final dia = DateTime(data.year, data.month, data.day + 7 * i);
      // A repetição para no fim do mês.
      if (dia.month != data.month) break;
      final semana = ReservaService.semanaDoMesDe(dia);
      final ocupado = ReservaService.isSlotOccupied(
        reservas: _reservas,
        laboratorio: _laboratorioSelecionadoValido,
        ano: dia.year,
        mes: dia.month,
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
          ano: dia.year,
          mes: dia.month,
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

    final navegacao = Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: SizedBox(
        width: double.infinity,
        child: SegmentedButton<bool>(
          showSelectedIcon: false,
          segments: [
            ButtonSegment(
              value: false,
              icon: const SigadIcon(SigadIcons.calendarioSemana),
              label: Text(_l10n.labAgenda),
            ),
            ButtonSegment(
              value: true,
              icon: const SigadIcon(SigadIcons.laboratorio),
              label: Text(_l10n.navLaboratorios),
            ),
          ],
          selected: {_mostrarCatalogo},
          onSelectionChanged: (valor) =>
              setState(() => _mostrarCatalogo = valor.first),
        ),
      ),
    );

    if (_mostrarCatalogo) {
      // Voltar do celular retorna à agenda em vez de sair do módulo.
      return PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop) setState(() => _mostrarCatalogo = false);
        },
        child: Scaffold(
          body: Column(
            children: [
              navegacao,
              Expanded(
                child: LaboratoriosCatalogoPage(
                  onAbrirReservas: (laboratorio) => setState(() {
                    if (laboratorio != null) {
                      _laboratorioSelecionado = laboratorio;
                    }
                    _mostrarCatalogo = false;
                  }),
                ),
              ),
            ],
          ),
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
          Column(
            children: [
              navegacao,
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _FiltroLabRow(
                        key: ValueKey(
                          '${_laboratorios.join('|')}#$_laboratorioSelecionadoValido',
                        ),
                        laboratorioSelecionado: _laboratorioSelecionadoValido,
                        laboratorios: _laboratorios,
                        onChanged: (value) =>
                            setState(() => _laboratorioSelecionado = value),
                      ),
                      if (_laboratorioAtual case final laboratorio?
                          when laboratorio.status != StatusLaboratorio.operando)
                        Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: _AvisoSituacao(laboratorio: laboratorio),
                        ),
                      const SizedBox(height: 12),
                      _SemanaNavegador(
                        segunda: _segunda,
                        onAnterior: () => _mudarSemana(-1),
                        onProxima: () => _mudarSemana(1),
                        onHoje: _irParaHoje,
                        onEscolherData: _escolherData,
                      ),
                      const SizedBox(height: 16),
                      if (_carregando)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 48),
                          child: Center(child: CircularProgressIndicator()),
                        )
                      else
                        _AgendaSemanal(
                          dias: _diasDaSemana,
                          laboratorio: _laboratorioSelecionadoValido,
                          reservas: _reservas,
                          usuarioAtual: userContext.currentUser?.name,
                          podeEditar: podeEditar,
                          onTapCelula: (data, turno, periodo, reservaAtual) =>
                              _onTapCelula(
                                data: data,
                                turno: turno,
                                periodo: periodo,
                                reservaAtual: reservaAtual,
                              ),
                        ),
                      if (podeVerOtimizacao && !_carregando) ...[
                        const SizedBox(height: 20),
                        Card(
                          margin: EdgeInsets.zero,
                          clipBehavior: Clip.antiAlias,
                          child: ExpansionTile(
                            leading: const SigadIcon(SigadIcons.analise),
                            title: Text(_l10n.labSugestoes),
                            subtitle: Text(_l10n.labSugestoesSub),
                            childrenPadding: const EdgeInsets.fromLTRB(
                              12,
                              0,
                              12,
                              12,
                            ),
                            children: [
                              _PainelOtimizacaoLaboratorio(
                                indicadores: _indicadoresOcupacao,
                                sugestoes: _sugestoesReserva,
                                recomendacoesCruzadas: _recomendacoesCruzadas,
                                laboratorioSelecionado:
                                    _laboratorioSelecionadoValido,
                                onAplicarSugestao: podeEditar
                                    ? _reservarSugestaoAutomatica
                                    : null,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _onTapCelula({
    required DateTime data,
    required Turno turno,
    required int periodo,
    required ReservaLaboratorio? reservaAtual,
  }) async {
    try {
      final userContext = context.read<UserContextProvider>();
      final user = userContext.currentUser;
      final role = userContext.userRole;

      if (reservaAtual != null) {
        await _abrirReservaExistente(reservaAtual, data);
        return;
      }

      if (user == null ||
          !ReservaService.canChangeReservation(user: user, role: role)) {
        _showInfo(_l10n.labSomenteDocentes);
        return;
      }
      final currentUser = user;
      final diaSemana = ReservaService.diaSemanaDe(data)!;

      String? disciplina;
      var totalSemanas = 1;
      var periodosSelecionados = <(Turno, int)>[(turno, periodo)];

      final ultimoDiaDoMes = DateTime(data.year, data.month + 1, 0);
      final result = await Navigator.of(context).push<Map<String, dynamic>>(
        MaterialPageRoute(
          fullscreenDialog: true,
          builder: (_) => DialogDisciplinaSemanasReserva(
            diaSemanaCompleto: _l10n.dataPorExtenso(data),
            laboratorio: _laboratorioSelecionadoValido,
            horarioInicial: _horarioLegivel(turno.horarioDo(periodo)),
            ultimoDiaDoMes: _l10n.dataCurta(ultimoDiaDoMes),
            maxSemanas: ((ultimoDiaDoMes.day - data.day) ~/ 7) + 1,
            horarios: ReservaService.gerarLinhasGrade(),
            turnoInicial: turno,
            periodoInicial: periodo,
            isOcupado: (t, p) =>
                ReservaService.reservaNaData(
                  reservas: _reservas,
                  laboratorio: _laboratorioSelecionadoValido,
                  data: data,
                  turno: t,
                  periodo: p,
                ) !=
                null,
          ),
        ),
      );
      if (result == null) return;
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

      final antes = List<ReservaLaboratorio>.of(_reservas);
      final grupoId = 'GRP-${DateTime.now().microsecondsSinceEpoch}';
      var totalCriadas = 0;
      var totalJaOcupadas = 0;
      setState(() {
        for (final (turnoSelecionado, periodoSelecionado)
            in periodosSelecionados) {
          final resultado = _criarReservasParaData(
            professor: currentUser.name,
            data: data,
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
        _showInfo(_l10n.labHorarioOcupado);
        return;
      }

      if (!await _salvarOuDesfazer(antes)) return;

      AppEventLogger.action(
        'reserva_create',
        details: {
          'laboratorio': _laboratorioSelecionadoValido,
          'diaSemana': diaSemana,
          'turno': turno.name,
          'periodo': periodo,
          'horariosReservados': periodosSelecionados.length,
          'reservasCriadas': totalCriadas,
        },
      );

      _showSuccess(
        totalCriadas == 1
            ? _l10n.labReservaFeita(
                _laboratorioSelecionadoValido,
                _l10n.diaAbrev(ReservaService.diaSemanaDe(data) ?? ''),
                _l10n.dataCurta(data),
                _horarioLegivel(turno.horarioDo(periodo)),
              )
            : '${_l10n.labHorariosReservados(totalCriadas)}'
                  '${totalJaOcupadas > 0 ? ' ${_l10n.labJaOcupados(totalJaOcupadas)}' : ''}',
      );
    } catch (error, stackTrace) {
      AppEventLogger.error('reserva_error', error, stackTrace: stackTrace);

      _showError(_l10n.labErroOperacao);
    }
  }

  /// Mostra os detalhes da reserva e, para quem pode, editar ou excluir.
  Future<void> _abrirReservaExistente(
    ReservaLaboratorio reservaAtual,
    DateTime data,
  ) async {
    final userContext = context.read<UserContextProvider>();
    final user = userContext.currentUser;
    final podeAlterar =
        user != null &&
        ReservaService.canChangeReservation(
          user: user,
          role: userContext.userRole,
        ) &&
        ReservaService.canRemoveReservation(
          role: userContext.userRole,
          currentUserName: user.name,
          reserva: reservaAtual,
        );

    final acao = await Navigator.of(context).push<_AcaoReserva>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => _DetalhesReservaSheet(
          reserva: reservaAtual,
          data: data,
          ehMinha: reservaAtual.professor == user?.name,
          podeAlterar: podeAlterar,
        ),
      ),
    );
    if (acao == null || !podeAlterar) return;

    final grupo = _reservas
        .where(
          (item) =>
              item.grupoId == reservaAtual.grupoId &&
              item.laboratorio == reservaAtual.laboratorio &&
              item.ano == reservaAtual.ano &&
              item.mes == reservaAtual.mes,
        )
        .toList(growable: false);

    if (acao == _AcaoReserva.editar) {
      await _executarEdicao(reservaAtual: reservaAtual, grupo: grupo);
      return;
    }
    await _executarExclusao(reservaAtual: reservaAtual, grupo: grupo);
  }

  List<ReservaLaboratorio> _ordenarOcorrencias(
    List<ReservaLaboratorio> ocorrencias,
  ) {
    final ordenado = List<ReservaLaboratorio>.from(ocorrencias);
    ordenado.sort((a, b) {
      final dataA = ReservaService.dataDaReserva(a);
      final dataB = ReservaService.dataDaReserva(b);
      if (dataA != null && dataB != null) return dataA.compareTo(dataB);
      return a.semanaDoMes.compareTo(b.semanaDoMes);
    });
    return ordenado;
  }

  String _rotuloOcorrencia(ReservaLaboratorio ocorrencia) {
    final data = ReservaService.dataDaReserva(ocorrencia);
    final dia = data == null
        ? _l10n.diaCompleto(ocorrencia.diaSemana)
        : _l10n.dataPorExtenso(data);
    return '$dia · ${_horarioLegivel(ocorrencia.turno.horarioDo(ocorrencia.periodo))}';
  }

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
        titulo: _l10n.labEditarOcorrencias,
        mensagem: _l10n.labRepeteEditar(grupo.length),
        grupo: grupo,
        selecionadosIniciais: {reservaAtual.id},
        labelConfirmar: _l10n.continuar,
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

    final antes = List<ReservaLaboratorio>.of(_reservas);
    var totalAtualizadas = 0;
    var totalConflitos = 0;
    setState(() {
      for (final ocorrencia in ocorrenciasSelecionadas) {
        // O novo dia é o da mesma semana (segunda a sexta) da ocorrência,
        // e ano/mês/bloco são recalculados a partir da data resultante.
        final dataAtual = ReservaService.dataDaReserva(ocorrencia);
        final novaData = dataAtual == null
            ? null
            : ReservaService.diaDaMesmaSemana(dataAtual, novoDiaSemana);
        if (novaData == null) {
          totalConflitos++;
          continue;
        }

        final ocupante = ReservaService.reservaNaData(
          reservas: _reservas,
          laboratorio: ocorrencia.laboratorio,
          data: novaData,
          turno: novoTurno,
          periodo: novoPeriodo,
        );
        if (ocupante != null && ocupante.id != ocorrencia.id) {
          totalConflitos++;
          continue;
        }

        final index = _reservas.indexWhere((item) => item.id == ocorrencia.id);
        if (index != -1) {
          _reservas[index] = ReservaLaboratorio(
            id: ocorrencia.id,
            professor: ocorrencia.professor,
            laboratorio: ocorrencia.laboratorio,
            ano: novaData.year,
            mes: novaData.month,
            semanaDoMes: ReservaService.semanaDoMesDe(novaData),
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
      _showInfo(_l10n.labNovoHorarioOcupado);
      return;
    }

    if (!await _salvarOuDesfazer(antes)) return;

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

    _showSuccess(
      totalAtualizadas == 1
          ? _l10n.labReservaAtualizada
          : '${_l10n.labOcorrenciasAtualizadas(totalAtualizadas)}'
                '${totalConflitos > 0 ? ' ${_l10n.labNaoMovidas(totalConflitos)}' : ''}',
    );
  }

  Future<void> _executarExclusao({
    required ReservaLaboratorio reservaAtual,
    required List<ReservaLaboratorio> grupo,
  }) async {
    var idsSelecionados = {reservaAtual.id};
    if (grupo.length > 1) {
      final selecionados = await _selecionarOcorrencias(
        titulo: _l10n.labExcluirOcorrencias,
        mensagem: _l10n.labRepeteExcluir(grupo.length),
        grupo: grupo,
        selecionadosIniciais: const {},
        labelConfirmar: _l10n.labRevisarExclusao,
      );
      if (selecionados == null || selecionados.isEmpty) return;
      idsSelecionados = selecionados;
    }

    final ocorrenciasSelecionadas = _ordenarOcorrencias(
      grupo.where((item) => idsSelecionados.contains(item.id)).toList(),
    );
    final unica = ocorrenciasSelecionadas.singleOrNull;
    final confirmarExclusao = await _confirmarAcao(
      titulo: _l10n.labExcluirReserva,
      mensagem: unica != null
          ? _l10n.labRemoverUma(_rotuloOcorrencia(unica), unica.laboratorio)
          : _l10n.labRemoverVarias(
              idsSelecionados.length,
              reservaAtual.laboratorio,
            ),
      confirmarLabel: _l10n.excluir,
      isDelete: true,
    );

    if (!confirmarExclusao) return;

    final antes = List<ReservaLaboratorio>.of(_reservas);
    setState(() {
      _reservas.removeWhere((reserva) => idsSelecionados.contains(reserva.id));
    });
    if (!await _salvarOuDesfazer(antes)) return;

    AppEventLogger.action(
      'reserva_remove',
      details: {
        'grupoId': reservaAtual.grupoId,
        'laboratorio': reservaAtual.laboratorio,
        'ocorrenciasRemovidas': idsSelecionados.length,
      },
    );

    _showSuccess(
      idsSelecionados.length == 1
          ? _l10n.labReservaRemovida
          : _l10n.labOcorrenciasRemovidas(idsSelecionados.length),
    );
  }

  Future<Map<String, dynamic>?> _editarReserva(ReservaLaboratorio reserva) {
    return Navigator.of(context).push<Map<String, dynamic>>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => _DialogEditarReserva(
          reserva: reserva,
          horarios: ReservaService.gerarLinhasGrade(),
          isOcupado: (dia, t, p) {
            final dataAtual = ReservaService.dataDaReserva(reserva);
            final data = dataAtual == null
                ? null
                : ReservaService.diaDaMesmaSemana(dataAtual, dia);
            if (data == null) return true;
            final ocupante = ReservaService.reservaNaData(
              reservas: _reservas,
              laboratorio: reserva.laboratorio,
              data: data,
              turno: t,
              periodo: p,
            );
            return ocupante != null && ocupante.id != reserva.id;
          },
        ),
      ),
    );
  }

  Future<void> _reservarSugestaoAutomatica() async {
    final userContext = context.read<UserContextProvider>();
    final user = userContext.currentUser;
    final role = userContext.userRole;

    if (!ReservaService.canChangeReservation(user: user, role: role)) {
      _showInfo(_l10n.labSomenteDocentes);
      return;
    }

    if (user == null) {
      _showInfo(_l10n.labFacaLogin);
      return;
    }

    final sugestoes = _sugestoesReserva;
    if (sugestoes.isEmpty) {
      _showInfo(_l10n.labSemSugestoes);
      return;
    }

    final sugestao = sugestoes.first;
    final indiceDia = ReservaService.diasUteis.indexOf(sugestao.diaSemana);
    if (indiceDia < 0) return;
    final data = DateTime(
      _segunda.year,
      _segunda.month,
      _segunda.day + indiceDia,
    );
    final horario = _horarioLegivel(sugestao.horario);

    final confirmar = await _confirmarAcao(
      titulo: _l10n.labReservarSugeridoTitulo,
      mensagem:
          '${sugestao.laboratorio}\n${_l10n.dataPorExtenso(data)}, $horario.\n\n'
          '${_l10n.labReservaNoSeuNome}',
      confirmarLabel: _l10n.reservar,
    );
    if (!confirmar) return;

    final jaOcupado =
        ReservaService.reservaNaData(
          reservas: _reservas,
          laboratorio: sugestao.laboratorio,
          data: data,
          turno: sugestao.turno,
          periodo: sugestao.periodo,
        ) !=
        null;
    if (jaOcupado) {
      _showInfo(_l10n.labSugestaoIndisponivel);
      return;
    }

    final antes = List<ReservaLaboratorio>.of(_reservas);
    setState(() {
      _laboratorioSelecionado = sugestao.laboratorio;
      _reservas.add(
        ReservaService.createReserva(
          professor: user.name,
          laboratorio: sugestao.laboratorio,
          ano: data.year,
          mes: data.month,
          semanaDoMes: ReservaService.semanaDoMesDe(data),
          diaSemana: sugestao.diaSemana,
          turno: sugestao.turno,
          periodo: sugestao.periodo,
        ),
      );
    });

    if (!await _salvarOuDesfazer(antes)) return;

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

    _showSuccess(
      _l10n.labReservaFeita(
        sugestao.laboratorio,
        _l10n.diaAbrev(sugestao.diaSemana),
        _l10n.dataCurta(data),
        horario,
      ),
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
              child: Text(_l10n.cancelar),
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

  void _showSuccess(String message) {
    if (!mounted) return;
    AppFeedbackService.success(context, message);
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
    return TelaFormularioReserva(
      titulo: context.l10n.labEditarReserva,
      acaoLabel: context.l10n.salvar,
      acaoIcone: SigadIcons.salvar,
      onAcao: () => Navigator.of(context).pop({
        'diaSemana': _diaSelecionado,
        'turno': _turnoSelecionado.name,
        'periodo': _periodoSelecionado,
        'disciplina': _disciplinaController.text.trim(),
      }),
      children: [
        TextField(
          controller: _disciplinaController,
          decoration: InputDecoration(
            labelText: context.l10n.labDisciplinaOpcional,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          context.l10n.labDiaSemana,
          style: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
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
          context.l10n.labHorario,
          style: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 6),
        for (final turno in Turno.values) ...[
          Text(
            context.l10n.turno(turno),
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
                        widget.isOcupado(_diaSelecionado, turno, linha.periodo);
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
                      tooltip: ocupado
                          ? context.l10n.labHorarioJaOcupado
                          : null,
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
          child: Text(context.l10n.cancelar),
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
    super.key,
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
      decoration: InputDecoration(labelText: context.l10n.labLaboratorio),
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

/// Linha "‹ 12 a 16 de out. ›" com atalhos para hoje e para escolher a data.
class _SemanaNavegador extends StatelessWidget {
  const _SemanaNavegador({
    required this.segunda,
    required this.onAnterior,
    required this.onProxima,
    required this.onHoje,
    required this.onEscolherData,
  });

  final DateTime segunda;
  final VoidCallback onAnterior;
  final VoidCallback onProxima;
  final VoidCallback onHoje;
  final VoidCallback onEscolherData;

  String _rotulo(AppLocalizations l10n) {
    final sexta = DateTime(segunda.year, segunda.month, segunda.day + 4);
    if (segunda.month == sexta.month) {
      return l10n.labSemanaMesmoMes(
        segunda.day,
        sexta.day,
        l10n.mes(sexta.month),
      );
    }
    return l10n.labSemanaDoisMeses(
      segunda.day,
      l10n.mes(segunda.month),
      sexta.day,
      l10n.mes(sexta.month),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ehSemanaAtual =
        ReservaService.segundaDaSemana(DateTime.now()) == segunda;
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: SigadColors.divider),
      ),
      child: Row(
        children: [
          IconButton(
            tooltip: context.l10n.labSemanaAnterior,
            onPressed: onAnterior,
            icon: const SigadIcon(SigadIcons.chevronEsquerda),
          ),
          Expanded(
            child: Semantics(
              button: true,
              label: context.l10n.labSemanaSemantica(
                _rotulo(context.l10n),
                '${segunda.year}',
              ),
              excludeSemantics: true,
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: onEscolherData,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 48),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _rotulo(context.l10n),
                        textAlign: TextAlign.center,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        ehSemanaAtual
                            ? context.l10n.labEstaSemana
                            : _anoDaSemana(segunda),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: SigadColors.muted,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (!ehSemanaAtual)
            TextButton(onPressed: onHoje, child: Text(context.l10n.hoje)),
          IconButton(
            tooltip: context.l10n.labProximaSemana,
            onPressed: onProxima,
            icon: const SigadIcon(SigadIcons.chevronDireita),
          ),
        ],
      ),
    );
  }
}

/// Estado visual de um horário na agenda.
enum _EstadoCelula { livre, minha, outro }

extension on _EstadoCelula {
  Color get fundo => switch (this) {
    _EstadoCelula.livre => SigadColors.surface,
    _EstadoCelula.minha => SigadColors.brandLight,
    _EstadoCelula.outro => SigadColors.surfaceAlt,
  };
}

class _Legenda extends StatelessWidget {
  const _Legenda();

  @override
  Widget build(BuildContext context) {
    Widget item(Color fundo, Color borda, String texto, {bool barra = false}) =>
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                color: fundo,
                borderRadius: BorderRadius.circular(4),
                border: barra
                    ? Border(left: BorderSide(color: borda, width: 4))
                    : Border.all(color: borda),
              ),
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(texto, style: Theme.of(context).textTheme.bodySmall),
            ),
          ],
        );

    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: [
        item(
          SigadColors.surface,
          SigadColors.success,
          context.l10n.labHorarioLivre,
        ),
        item(
          SigadColors.brandLight,
          SigadColors.brand,
          context.l10n.labMinhaReserva,
          barra: true,
        ),
        item(
          SigadColors.surfaceAlt,
          SigadColors.divider,
          context.l10n.labReservadoPorOutro,
        ),
        item(
          SigadColors.warningSoft,
          SigadColors.warning,
          context.l10n.feriado,
        ),
      ],
    );
  }
}

/// Agenda da semana: abas de turno, legenda e grade.
class _AgendaSemanal extends StatefulWidget {
  const _AgendaSemanal({
    required this.dias,
    required this.laboratorio,
    required this.reservas,
    required this.usuarioAtual,
    required this.podeEditar,
    required this.onTapCelula,
  });

  final List<DateTime> dias;
  final String laboratorio;
  final List<ReservaLaboratorio> reservas;
  final String? usuarioAtual;
  final bool podeEditar;
  final Future<void> Function(
    DateTime data,
    Turno turno,
    int periodo,
    ReservaLaboratorio? reservaAtual,
  )
  onTapCelula;

  @override
  State<_AgendaSemanal> createState() => _AgendaSemanalState();
}

class _AgendaSemanalState extends State<_AgendaSemanal> {
  Turno? _turnoSelecionado;

  @override
  Widget build(BuildContext context) {
    final linhas = ReservaService.gerarLinhasGrade()
        .where(
          (linha) =>
              _turnoSelecionado == null || linha.turno == _turnoSelecionado,
        )
        .toList(growable: false);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _TurnoTabs(
          selecionado: _turnoSelecionado,
          onSelected: (turno) => setState(() => _turnoSelecionado = turno),
        ),
        const SizedBox(height: 12),
        const _Legenda(),
        const SizedBox(height: 12),
        _GradeSemanal(
          dias: widget.dias,
          linhas: linhas,
          reservaPara: (data, turno, periodo) => ReservaService.reservaNaData(
            reservas: widget.reservas,
            laboratorio: widget.laboratorio,
            data: data,
            turno: turno,
            periodo: periodo,
          ),
          usuarioAtual: widget.usuarioAtual,
          podeEditar: widget.podeEditar,
          onTapCelula: widget.onTapCelula,
        ),
      ],
    );
  }
}

class _GradeSemanal extends StatelessWidget {
  const _GradeSemanal({
    required this.dias,
    required this.linhas,
    required this.reservaPara,
    required this.usuarioAtual,
    required this.podeEditar,
    required this.onTapCelula,
  });

  final List<DateTime> dias;
  final List<HorarioGridRow> linhas;
  final ReservaLaboratorio? Function(DateTime data, Turno turno, int periodo)
  reservaPara;
  final String? usuarioAtual;
  final bool podeEditar;
  final Future<void> Function(
    DateTime data,
    Turno turno,
    int periodo,
    ReservaLaboratorio? reservaAtual,
  )
  onTapCelula;

  static const double _larguraHorario = 64;
  static const double _larguraMinimaDia = 76;

  @override
  Widget build(BuildContext context) {
    final hoje = DateUtils.dateOnly(DateTime.now());
    final feriados = [for (final dia in dias) FeriadoService.feriadoEm(dia)];

    return LayoutBuilder(
      builder: (context, constraints) {
        final escala = MediaQuery.textScalerOf(context).scale(1);
        final larguraDia = _larguraMinimaDia * escala.clamp(1.0, 1.6);
        final larguraMinima =
            _larguraHorario * escala.clamp(1.0, 1.4) + larguraDia * dias.length;
        final rola = constraints.maxWidth < larguraMinima;
        final largura = rola ? larguraMinima : constraints.maxWidth;
        final larguraHorario = _larguraHorario * escala.clamp(1.0, 1.4);

        final grade = Container(
          width: largura,
          decoration: BoxDecoration(
            color: SigadColors.surface,
            border: Border.all(color: SigadColors.divider),
            borderRadius: BorderRadius.circular(12),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(width: larguraHorario),
                    for (var i = 0; i < dias.length; i++)
                      Expanded(
                        child: _CabecalhoDia(
                          data: dias[i],
                          hoje: dias[i] == hoje,
                          feriado: feriados[i],
                        ),
                      ),
                  ],
                ),
              ),
              for (var index = 0; index < linhas.length; index++) ...[
                if (index == 0 ||
                    linhas[index - 1].turno != linhas[index].turno)
                  _TurnoDividerRow(turno: linhas[index].turno),
                IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(
                        width: larguraHorario,
                        child: _CelulaHorario(horario: linhas[index].horario),
                      ),
                      for (var i = 0; i < dias.length; i++)
                        Expanded(
                          child: _GradeReservaCell(
                            data: dias[i],
                            horario: linhas[index].horario,
                            turno: linhas[index].turno,
                            periodo: linhas[index].periodo,
                            reserva: reservaPara(
                              dias[i],
                              linhas[index].turno,
                              linhas[index].periodo,
                            ),
                            usuarioAtual: usuarioAtual,
                            feriado: feriados[i] != null,
                            ultimaColuna: i == dias.length - 1,
                            podeEditar: podeEditar,
                            onTapCelula: onTapCelula,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        );

        if (!rola) return grade;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            HorizontalScrollHint(message: context.l10n.labArrasteAgenda),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: grade,
            ),
          ],
        );
      },
    );
  }
}

class _CabecalhoDia extends StatelessWidget {
  const _CabecalhoDia({
    required this.data,
    required this.hoje,
    required this.feriado,
  });

  final DateTime data;
  final bool hoje;
  final Feriado? feriado;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cor = hoje ? SigadColors.surface : SigadColors.ink;
    final dia = ReservaService.diaSemanaDe(data) ?? '';
    return Semantics(
      header: true,
      label:
          '${context.l10n.labCabecalhoDia(context.l10n.diaCompleto(dia), context.l10n.dataCurta(data))}'
          '${hoje ? context.l10n.labHojeSufixo : ''}'
          '${feriado != null ? context.l10n.labFeriadoSufixo(feriado!.nome) : ''}',
      excludeSemantics: true,
      child: Tooltip(
        message: feriado?.nome ?? '',
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
          decoration: BoxDecoration(
            color: hoje
                ? SigadColors.brand
                : feriado != null
                ? SigadColors.warningSoft
                : SigadColors.surfaceAlt,
            border: const Border(
              left: BorderSide(color: SigadColors.divider),
              bottom: BorderSide(color: SigadColors.divider),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                context.l10n.diaAbrev(dia),
                style: theme.textTheme.labelLarge?.copyWith(
                  color: cor,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                context.l10n.dataCurta(data),
                style: theme.textTheme.bodySmall?.copyWith(color: cor),
              ),
              if (feriado != null)
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: SigadIcon(
                    SigadIcons.bandeira,
                    size: 14,
                    color: hoje ? SigadColors.surface : SigadColors.warning,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CelulaHorario extends StatelessWidget {
  const _CelulaHorario({required this.horario});

  final String horario;

  @override
  Widget build(BuildContext context) {
    final partes = horario.split('-');
    final style = Theme.of(context).textTheme.labelMedium?.copyWith(
      color: SigadColors.ink,
      fontWeight: FontWeight.w700,
    );
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
      decoration: const BoxDecoration(
        color: SigadColors.surfaceAlt,
        border: Border(top: BorderSide(color: SigadColors.divider)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(partes.first, style: style),
          if (partes.length > 1)
            Text(
              partes.last,
              style: style?.copyWith(
                color: SigadColors.muted,
                fontWeight: FontWeight.w500,
              ),
            ),
        ],
      ),
    );
  }
}

class _GradeReservaCell extends StatelessWidget {
  const _GradeReservaCell({
    required this.data,
    required this.horario,
    required this.turno,
    required this.periodo,
    required this.reserva,
    required this.usuarioAtual,
    required this.feriado,
    required this.ultimaColuna,
    required this.podeEditar,
    required this.onTapCelula,
  });

  final DateTime data;
  final String horario;
  final Turno turno;
  final int periodo;
  final ReservaLaboratorio? reserva;
  final String? usuarioAtual;
  final bool feriado;
  final bool ultimaColuna;
  final bool podeEditar;
  final Future<void> Function(
    DateTime data,
    Turno turno,
    int periodo,
    ReservaLaboratorio? reservaAtual,
  )
  onTapCelula;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final reserva = this.reserva;
    final estado = reserva == null
        ? _EstadoCelula.livre
        : reserva.professor == usuarioAtual
        ? _EstadoCelula.minha
        : _EstadoCelula.outro;
    final diaSemana = ReservaService.diaSemanaDe(data) ?? '';
    final podeTocar = reserva != null || podeEditar;
    final fundo = estado == _EstadoCelula.livre && feriado
        ? SigadColors.warningSoft.withValues(alpha: 0.5)
        : estado.fundo;

    final Widget conteudo = switch (estado) {
      _EstadoCelula.livre => const SizedBox.shrink(),
      _EstadoCelula.minha => Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            reserva!.disciplina ?? context.l10n.labMinhaReserva,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: textTheme.labelMedium?.copyWith(
              color: SigadColors.brandDark,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
      _EstadoCelula.outro => Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            reserva!.professor.split(' ').first,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: textTheme.labelMedium?.copyWith(
              color: SigadColors.ink,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (reserva.disciplina != null)
            Text(
              reserva.disciplina!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: textTheme.bodySmall?.copyWith(color: SigadColors.muted),
            ),
        ],
      ),
    };

    return Semantics(
      button: podeTocar,
      excludeSemantics: true,
      onTap: podeTocar
          ? () => onTapCelula(data, turno, periodo, reserva)
          : null,
      label: context.l10n.labCelula(
        context.l10n.diaAbrev(diaSemana),
        data.day,
        context.l10n.turno(turno),
        periodo,
        horario,
      ),
      value: reserva == null
          ? context.l10n.labLivre
          : estado == _EstadoCelula.minha
          ? context.l10n.labMinhaReserva
          : context.l10n.labReservadoPor(reserva.professor),
      hint: reserva != null
          ? context.l10n.labToqueDetalhes
          : podeEditar
          ? context.l10n.labToqueReservar
          : null,
      child: Material(
        color: fundo,
        child: InkWell(
          onTap: podeTocar
              ? () => onTapCelula(data, turno, periodo, reserva)
              : null,
          child: Container(
            constraints: const BoxConstraints(minHeight: 52),
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
            decoration: BoxDecoration(
              border: Border(
                top: const BorderSide(color: SigadColors.divider),
                left: estado == _EstadoCelula.minha
                    ? const BorderSide(color: SigadColors.brand, width: 4)
                    : const BorderSide(color: SigadColors.divider),
                right: ultimaColuna
                    ? BorderSide.none
                    : const BorderSide(color: Colors.transparent),
              ),
            ),
            alignment: Alignment.center,
            child: conteudo,
          ),
        ),
      ),
    );
  }
}

/// Painel com os detalhes de uma reserva e, se permitido, editar/excluir.
class _DetalhesReservaSheet extends StatelessWidget {
  const _DetalhesReservaSheet({
    required this.reserva,
    required this.data,
    required this.ehMinha,
    required this.podeAlterar,
  });

  final ReservaLaboratorio reserva;
  final DateTime data;
  final bool ehMinha;
  final bool podeAlterar;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    Widget linha(IconData icone, String rotulo, String valor) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SigadIcon(icone, color: SigadColors.brand),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  rotulo,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: SigadColors.muted,
                  ),
                ),
                Text(valor, style: theme.textTheme.bodyLarge),
              ],
            ),
          ),
        ],
      ),
    );

    return TelaFormularioReserva(
      titulo: context.l10n.labDetalhesReserva,
      acaoLabel: podeAlterar ? context.l10n.labEditarReserva : null,
      acaoIcone: SigadIcons.editar,
      onAcao: () => Navigator.pop(context, _AcaoReserva.editar),
      acaoSecundaria: podeAlterar
          ? OutlinedButton.icon(
              onPressed: () => Navigator.pop(context, _AcaoReserva.excluir),
              style: OutlinedButton.styleFrom(
                foregroundColor: SigadColors.risk,
              ),
              icon: const SigadIcon(
                SigadIcons.excluir,
                color: SigadColors.risk,
              ),
              label: Text(context.l10n.labExcluirReserva),
            )
          : null,
      children: [
        Text(
          reserva.disciplina ?? context.l10n.labReservaDeLaboratorio,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        if (ehMinha)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              context.l10n.labSuaReserva,
              style: theme.textTheme.labelLarge?.copyWith(
                color: SigadColors.brand,
              ),
            ),
          ),
        const SizedBox(height: 12),
        linha(
          SigadIcons.laboratorio,
          context.l10n.labLaboratorio,
          reserva.laboratorio,
        ),
        linha(
          SigadIcons.calendario,
          context.l10n.labData,
          context.l10n.dataPorExtenso(data),
        ),
        linha(
          SigadIcons.relogio,
          context.l10n.labHorario,
          '${context.l10n.turno(reserva.turno)}, ${_horarioLegivel(reserva.turno.horarioDo(reserva.periodo))}',
        ),
        linha(
          SigadIcons.pessoa,
          context.l10n.labReservadoPorRotulo,
          reserva.professor,
        ),
        const SizedBox(height: 16),
        if (!podeAlterar)
          Text(
            context.l10n.labSoQuemFez,
            style: theme.textTheme.bodySmall?.copyWith(
              color: SigadColors.muted,
            ),
          ),
      ],
    );
  }
}

class _TurnoTabs extends StatelessWidget {
  const _TurnoTabs({required this.selecionado, required this.onSelected});

  final Turno? selecionado;
  final ValueChanged<Turno?> onSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final opcoes = <MapEntry<String, Turno?>>[
      MapEntry(l10n.turnoTodos, null),
      MapEntry(l10n.turnoManha, Turno.matutino),
      MapEntry(l10n.turnoTarde, Turno.vespertino),
      MapEntry(l10n.turnoNoite, Turno.noturno),
    ];
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          for (final opcao in opcoes)
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
          padding: const EdgeInsets.symmetric(vertical: 14),
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
            context.l10n.turno(turno),
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
              context.l10n.labAcessoRestrito,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              context.l10n.labAcessoRestritoMsg,
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
                      context.l10n.labOtimizacao,
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
                          label: Text(context.l10n.labReservarSugestao),
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
                      label: Text(context.l10n.labReservarSugestao),
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
                  context.l10n.labOcupadoNaSemana(
                    laboratorioSelecionado.isEmpty
                        ? 'N/D'
                        : laboratorioSelecionado,
                  ),
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
                      context.l10n.labIndicadorOcupacao(
                        indicador.laboratorio,
                        (indicador.taxaOcupacao * 100).toStringAsFixed(0),
                        indicador.slotsLivres,
                      ),
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
              context.l10n.labSugestoesSlots,
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
                      '• ${sugestao.laboratorio} · ${context.l10n.diaAbrev(sugestao.diaSemana)} · ${sugestao.horario} (${sugestao.turno.shortLabel}${sugestao.periodo})',
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
              context.l10n.labRecomendacoesCruzadas,
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

String _anoDaSemana(DateTime segunda) {
  final sexta = DateTime(segunda.year, segunda.month, segunda.day + 4);
  return segunda.year == sexta.year
      ? '${segunda.year}'
      : '${segunda.year}–${sexta.year}';
}

/// Faixa de aviso quando o laboratório não está operando normalmente.
class _AvisoSituacao extends StatelessWidget {
  const _AvisoSituacao({required this.laboratorio});

  final Laboratorio laboratorio;

  @override
  Widget build(BuildContext context) {
    final interditado = laboratorio.status == StatusLaboratorio.interditado;
    final cor = interditado ? SigadColors.risk : SigadColors.warning;
    final texto = interditado
        ? context.l10n.labAvisoInterditado
        : context.l10n.labAvisoManutencao;
    return Semantics(
      liveRegion: true,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: (interditado ? SigadColors.riskSoft : SigadColors.warningSoft),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: cor.withValues(alpha: 0.4)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SigadIcon(
              interditado ? SigadIcons.alerta : SigadIcons.manutencao,
              color: cor,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                texto,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: SigadColors.ink),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
