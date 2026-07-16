import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../app/theme/sigad_colors.dart';
import '../../data/reserva_repository.dart';
import '../../domain/reserva_models.dart';
import '../../domain/reserva_service.dart';
import '../../../carga_docente/data/docente_repository.dart';
import '../../../carga_docente/domain/docente_models.dart';
import '../../../../core/services/app_event_logger.dart';
import '../../../../core/services/app_feedback_service.dart';
import '../../../../core/services/user_context_provider.dart';
import '../widgets/dialog_disciplina_semanas_reserva.dart';

class AulasPraticasPage extends StatefulWidget {
  const AulasPraticasPage({super.key});

  @override
  State<AulasPraticasPage> createState() => _AulasPraticasPageState();
}

class _AulasPraticasPageState extends State<AulasPraticasPage> {
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
  final DocenteRepository _docenteRepository = DocenteRepository();
  final List<ReservaLaboratorio> _reservas = ReservaService.defaultReservas(
    DateTime.now().month,
  );
  final List<Docente> _docentes = [];

  final TransformationController _transformationController =
      TransformationController();

  String? _laboratorioSelecionado;
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
    final list = await _reservaRepository.loadReservas();

    final docentes = await _docenteRepository.loadDocentes(
      generateFallbackId: () => 'DOC-FALLBACK',
    );

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

  Future<void> _saveData() async {
    try {
      await _reservaRepository.saveReservas(_reservas);
    } catch (e) {
      _showError('Erro ao salvar os dados localmente.');
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
    final data = DateTime(
      DateTime.now().year,
      _mesSelecionado,
      _diaSelecionado,
    );
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
    final data = DateTime(
      DateTime.now().year,
      _mesSelecionado,
      _diaSelecionado,
    );
    return dias[data.weekday - 1];
  }

  List<ReservaLaboratorio> get _reservasDoLaboratorio =>
      ReservaService.reservasDoLaboratorio(
        reservas: _reservas,
        laboratorio: _laboratorioSelecionadoValido,
        mes: _mesSelecionado,
        semanaDoMes: _semanaSelecionada,
      );

  List<IndicadorOcupacaoLaboratorio> get _indicadoresOcupacao =>
      ReservaService.calcularOcupacaoLaboratorios(
        reservas: _reservas,
        laboratorios: _laboratoriosDefault,
        mes: _mesSelecionado,
        semanaDoMes: _semanaSelecionada,
      );

  List<SugestaoReservaLaboratorio> get _sugestoesReserva =>
      ReservaService.sugerirSlotsLivres(
        reservas: _reservas,
        laboratorios: _laboratoriosDefault,
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
    final now = DateTime.now();
    return DateTime(now.year, _mesSelecionado + 1, 0).day;
  }

  @override
  Widget build(BuildContext context) {
    final userContext = context.watch<UserContextProvider>();
    final role = userContext.userRole;
    final hasAccess = ReservaService.canAccess(role);

    if (!hasAccess) {
      return const _AccessDenied();
    }

    final podeEditar = ReservaService.canEdit(role);

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
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: _FiltroLabRow(
                        laboratorioSelecionado: _laboratorioSelecionadoValido,
                        laboratorios: _laboratoriosDefault,
                        onChanged: (value) =>
                            setState(() => _laboratorioSelecionado = value),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 2,
                      child: _FiltroPeriodoRow(
                        mesSelecionado: _mesSelecionado,
                        meses: _mesesDefault,
                        onMesChanged: (value) {
                          setState(() {
                            _mesSelecionado = value;
                            final maxDia = _diasNoMesSelecionado;
                            if (_diaSelecionado > maxDia) {
                              _diaSelecionado = maxDia;
                            }
                            if (_diaSelecionado < 1) {
                              _diaSelecionado = 1;
                            }
                          });
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                _SelecaoDiaMesRow(
                  mesSelecionado: _mesSelecionado,
                  diaSelecionado: _diaSelecionado,
                  diasNoMes: _diasNoMesSelecionado,
                  onDiaChanged: (value) =>
                      setState(() => _diaSelecionado = value),
                ),
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
                const SizedBox(height: 12),
                _MapaSemanal(
                  mesSelecionado: _mesSelecionado,
                  mesLabel: ReservaService.nomeMes(
                    _mesSelecionado,
                    _mesesDefault,
                  ),
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
        if (ReservaService.canEdit(role)) {
          final result = await showDialog<Map<String, dynamic>>(
            context: context,
            builder: (_) => const DialogDisciplinaSemanasReserva(),
          );
          if (result == null) {
            return;
          }
          disciplina = result['disciplina'] as String?;
        }

        final jaOcupado = ReservaService.isSlotOccupied(
          reservas: _reservas,
          laboratorio: _laboratorioSelecionadoValido,
          mes: _mesSelecionado,
          semanaDoMes: _semanaSelecionada,
          diaSemana: diaSemana,
          turno: turno,
          periodo: periodo,
        );

        if (jaOcupado) {
          _showInfo('Este horário acabou de ser reservado por outro usuário.');
          return;
        }

        setState(() {
          _reservas.add(
            ReservaService.createReserva(
              professor: currentUser.name,
              laboratorio: _laboratorioSelecionadoValido,
              mes: _mesSelecionado,
              semanaDoMes: _semanaSelecionada,
              diaSemana: diaSemana,
              turno: turno,
              periodo: periodo,
              disciplina: disciplina,
            ),
          );
        });
        await _saveData();

        AppEventLogger.action(
          'reserva_create',
          details: {
            'laboratorio': _laboratorioSelecionadoValido,
            'diaSemana': diaSemana,
            'turno': turno.name,
            'periodo': periodo,
            'professor': currentUser.name,
          },
        );

        _showInfo('Horário reservado com sucesso.');
        return;
      }

      if (!ReservaService.canRemoveReservation(
        role: role,
        currentUserName: currentUser.name,
        reserva: reservaAtual,
      )) {
        _showInfo('Você só pode remover as próprias reservas.');
        return;
      }

      final confirmarExclusao = await _confirmarAcao(
        titulo: 'Excluir reserva',
        mensagem:
            'Deseja remover sua reserva de ${ReservaService.diaCompleto(diaSemana)}, ${turno.horarioDo(periodo)}, ${ReservaService.descricaoSemana(_semanaSelecionada)} de ${ReservaService.nomeMes(_mesSelecionado, _mesesDefault)} no $_laboratorioSelecionadoValido?',
        confirmarLabel: 'Excluir',
        isDelete: true,
      );

      if (!confirmarExclusao) return;

      setState(() {
        _reservas.removeWhere((reserva) => reserva.id == reservaAtual.id);
      });
      await _saveData();

      AppEventLogger.action(
        'reserva_remove',
        details: {
          'reservaId': reservaAtual.id,
          'laboratorio': reservaAtual.laboratorio,
          'diaSemana': reservaAtual.diaSemana,
          'turno': reservaAtual.turno.name,
          'periodo': reservaAtual.periodo,
        },
      );

      _showInfo('Reserva removida.');
    } catch (error, stackTrace) {
      AppEventLogger.error('reserva_error', error, stackTrace: stackTrace);

      _showError('Não foi possível concluir a operação. Tente novamente.');
    }
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
      initialValue: laboratorioSelecionado,
      decoration: const InputDecoration(labelText: 'Laboratório'),
      items: laboratorios
          .map((lab) => DropdownMenuItem(value: lab, child: Text(lab)))
          .toList(),
      onChanged: (value) {
        if (value != null) onChanged(value);
      },
    );
  }
}

class _FiltroPeriodoRow extends StatelessWidget {
  const _FiltroPeriodoRow({
    required this.mesSelecionado,
    required this.meses,
    required this.onMesChanged,
  });

  final int mesSelecionado;
  final List<String> meses;
  final ValueChanged<int> onMesChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<int>(
      initialValue: mesSelecionado,
      decoration: const InputDecoration(labelText: 'Mês'),
      items: [
        for (var i = 0; i < meses.length; i++)
          DropdownMenuItem<int>(value: i + 1, child: Text(meses[i])),
      ],
      onChanged: (value) {
        if (value != null) {
          onMesChanged(value);
        }
      },
    );
  }
}

class _SelecaoDiaMesRow extends StatelessWidget {
  const _SelecaoDiaMesRow({
    required this.mesSelecionado,
    required this.diaSelecionado,
    required this.diasNoMes,
    required this.onDiaChanged,
  });

  final int mesSelecionado;
  final int diaSelecionado;
  final int diasNoMes;
  final ValueChanged<int> onDiaChanged;

  @override
  Widget build(BuildContext context) {
    // Calcula em qual dia da semana o mês começa para alinhar o grid
    final ano = DateTime.now().year;
    final primeiroDiaDoMes = DateTime(ano, mesSelecionado, 1);
    // weekday: 1 (seg) a 7 (dom). Subtraímos 1 para o offset começar na segunda.
    final offset = primeiroDiaDoMes.weekday - 1;

    const diasSemanaHeader = ['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb', 'Dom'];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: SigadColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: SigadColors.divider),
      ),
      child: Column(
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
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
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
              return InkWell(
                onTap: () => onDiaChanged(dia),
                borderRadius: BorderRadius.circular(4),
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected ? SigadColors.brand : Colors.transparent,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: isSelected
                          ? SigadColors.brand
                          : SigadColors.divider.withValues(alpha: 0.5),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      '$dia',
                      style: TextStyle(
                        fontSize: 13,
                        //fontFamily: 'Roboto',
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: isSelected ? Colors.white : SigadColors.ink,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _MapaSemanal extends StatelessWidget {
  const _MapaSemanal({
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

  static const List<String> _diasAbreviados = [
    'Seg',
    'Ter',
    'Qua',
    'Qui',
    'Sex',
  ];

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
          '$semanaLabel de $mesLabel · Dia $diaSelecionado ($diaSemanaSelecionado)',
          style: textTheme.bodySmall?.copyWith(color: SigadColors.muted),
        ),
        const SizedBox(height: 14),
        _GradeSemanal(
          diasAbreviados: _diasAbreviados,
          diasDoMes: diasDoMesDaSemana,
          diaSemanaSelecionado: diaSemanaSelecionado,
          linhas: linhas,
          reservaPara: _reservaPara,
          podeEditar: podeEditar,
          onTapCelula: onTapCelula,
        ),
      ],
    );
  }

  List<HorarioGridRow> _gerarLinhasGrade() {
    return ReservaService.gerarLinhasGrade();
  }

  ReservaLaboratorio? _reservaPara(
    String diaSemana,
    Turno turno,
    int periodo,
  ) => ReservaService.reservaPara(
    reservas: reservas,
    diaSemana: diaSemana,
    turno: turno,
    periodo: periodo,
  );

  List<int> _diasDoMesDaSemanaSelecionada() {
    final dataSelecionada = DateTime(
      DateTime.now().year,
      mesSelecionado,
      diaSelecionado,
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
    return Container(
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
            if (index == 0 || linhas[index - 1].turno != linhas[index].turno)
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
                      height: _rowHeight,
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
                    Text(
                      '$diaSemana · $diaDoMes',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: SigadColors.brandDark,
                        fontWeight: FontWeight.w700,
                        fontSize: 10,
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
                    Icon(
                      livre
                          ? Icons.check_circle_outline
                          : Icons.event_busy_outlined,
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
          hintText: 'Ex.: Eletrônica Analógica',
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
            const Icon(Icons.lock_outline, size: 54, color: SigadColors.muted),
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
          Row(
            children: [
              const Icon(
                Icons.insights_outlined,
                size: 18,
                color: SigadColors.brand,
              ),
              const SizedBox(width: 6),
              Text(
                'Otimização de laboratórios',
                style: textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              if (onAplicarSugestao != null)
                TextButton.icon(
                  onPressed: onAplicarSugestao,
                  icon: const Icon(Icons.auto_fix_high_outlined, size: 16),
                  label: const Text('Reservar sugestão'),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Laboratório selecionado: ${laboratorioSelecionado.isEmpty ? 'N/D' : laboratorioSelecionado} · ${taxa.toStringAsFixed(0)}% ocupado na semana.',
            style: textTheme.bodySmall?.copyWith(color: SigadColors.muted),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: indicadoresOrdenados
                .take(4)
                .map(
                  (indicador) => Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: indicador.laboratorio == laboratorioSelecionado
                          ? SigadColors.brand.withValues(alpha: 0.12)
                          : SigadColors.surfaceAlt,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${indicador.laboratorio}: ${(indicador.taxaOcupacao * 100).toStringAsFixed(0)}% · ${indicador.slotsLivres} livres',
                      style: textTheme.labelSmall?.copyWith(
                        color: indicador.laboratorio == laboratorioSelecionado
                            ? SigadColors.brandDark
                            : SigadColors.muted,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                )
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
