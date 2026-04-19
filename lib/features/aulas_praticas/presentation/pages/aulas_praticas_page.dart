import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../app/theme/sigad_colors.dart';
import '../../../../core/models/user_role.dart';
import '../../../../core/services/app_event_logger.dart';
import '../../../../core/services/app_feedback_service.dart';
import '../../../../core/services/user_context_provider.dart';
import '../../../../core/services/local_storage_service.dart';

class AulasPraticasPage extends StatefulWidget {
  const AulasPraticasPage({super.key});

  @override
  State<AulasPraticasPage> createState() => _AulasPraticasPageState();
}

class _AulasPraticasPageState extends State<AulasPraticasPage> {
  static const Set<UserRole> _allowedRoles = {
    UserRole.professor,
    UserRole.coordenador,
    UserRole.chefeDepartamento,
  };

  static const List<String> _laboratorios = [
    'Lab Química 1',
    'Lab Biologia 2',
    'Lab Física 1',
    'Lab Automação',
  ];

  static const List<String> _meses = [
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

  final List<_ReservaLaboratorio> _reservas = [
    _ReservaLaboratorio(
      id: 'RES-101',
      professor: 'Ismael',
      laboratorio: 'Lab Química 1',
      mes: DateTime.now().month,
      semanaDoMes: 2,
      diaSemana: 'Seg',
      turno: _Turno.matutino,
      periodo: 4,
    ),
    _ReservaLaboratorio(
      id: 'RES-102',
      professor: 'PEE - Cláudio Leão',
      laboratorio: 'Lab Química 1',
      mes: DateTime.now().month,
      semanaDoMes: 2,
      diaSemana: 'Ter',
      turno: _Turno.matutino,
      periodo: 4,
    ),
    _ReservaLaboratorio(
      id: 'RES-103',
      professor: 'Jean Mark',
      laboratorio: 'Lab Química 1',
      mes: DateTime.now().month,
      semanaDoMes: 3,
      diaSemana: 'Sex',
      turno: _Turno.noturno,
      periodo: 1,
    ),
    _ReservaLaboratorio(
      id: 'RES-104',
      professor: 'Lima',
      laboratorio: 'Lab Química 1',
      mes: DateTime.now().month,
      semanaDoMes: 3,
      diaSemana: 'Seg',
      turno: _Turno.vespertino,
      periodo: 3,
    ),
  ];

  String _laboratorioSelecionado = _laboratorios.first;
  int _mesSelecionado = DateTime.now().month;
  int _diaSelecionado = DateTime.now().day;

  static const String _kKey = 'sigad_reservas';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final list = await LocalStorageService.loadList(_kKey);
    if (list.isEmpty) return;
    setState(() {
      _reservas
        ..clear()
        ..addAll(list.map(_reservaFromJson));
    });
  }

  void _saveData() {
    LocalStorageService.saveList(_kKey, _reservas.map(_reservaToJson).toList());
  }

  Map<String, dynamic> _reservaToJson(_ReservaLaboratorio r) => {
    'id': r.id,
    'professor': r.professor,
    'laboratorio': r.laboratorio,
    'mes': r.mes,
    'semanaDoMes': r.semanaDoMes,
    'diaSemana': r.diaSemana,
    'turno': r.turno.name,
    'periodo': r.periodo,
    if (r.disciplina != null) 'disciplina': r.disciplina,
  };

  _ReservaLaboratorio _reservaFromJson(Map<String, dynamic> json) => _ReservaLaboratorio(
    id: json['id'] as String,
    professor: json['professor'] as String,
    laboratorio: json['laboratorio'] as String,
    mes: json['mes'] as int,
    semanaDoMes: json['semanaDoMes'] as int,
    diaSemana: json['diaSemana'] as String,
    turno: _Turno.values.firstWhere((t) => t.name == json['turno']),
    periodo: json['periodo'] as int,
    disciplina: json['disciplina'] as String?,
  );

  int get _semanaSelecionada => ((_diaSelecionado - 1) ~/ 7) + 1;

  String get _laboratorioSelecionadoValido {
    if (_laboratorios.contains(_laboratorioSelecionado)) {
      return _laboratorioSelecionado;
    }
    return _laboratorios.first;
  }

  List<_ReservaLaboratorio> get _reservasDoLaboratorio {
    return _reservas
        .where(
          (reserva) =>
              reserva.laboratorio == _laboratorioSelecionadoValido &&
              reserva.mes == _mesSelecionado &&
              reserva.semanaDoMes == _semanaSelecionada,
        )
        .toList();
  }

  int get _diasNoMesSelecionado {
    final now = DateTime.now();
    return DateTime(now.year, _mesSelecionado + 1, 0).day;
  }

  @override
  Widget build(BuildContext context) {
    final userContext = context.watch<UserContextProvider>();
    final role = userContext.userRole;
    final hasAccess = role != null && _allowedRoles.contains(role);

    if (!hasAccess) {
      return const _AccessDenied();
    }

    final podeEditar =
      role == UserRole.professor || role == UserRole.coordenador || role == UserRole.chefeDepartamento;

    return Scaffold(
      body: Stack(
        children: [
          const _AmbientBackground(),
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: _FiltroLabRow(
                        laboratorioSelecionado: _laboratorioSelecionadoValido,
                        laboratorios: _laboratorios,
                        onChanged: (value) => setState(() => _laboratorioSelecionado = value),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 2,
                      child: _FiltroPeriodoRow(
                        mesSelecionado: _mesSelecionado,
                        meses: _meses,
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
                  diaSelecionado: _diaSelecionado,
                  diasNoMes: _diasNoMesSelecionado,
                  onDiaChanged: (value) => setState(() => _diaSelecionado = value),
                ),
                const SizedBox(height: 12),
                _MapaSemanal(
                  mesSelecionado: _mesSelecionado,
                  mesLabel: _nomeMes(_mesSelecionado),
                  semanaLabel: _descricaoSemana(_semanaSelecionada),
                  diaSelecionado: _diaSelecionado,
                  diaSemanaSelecionado: _diaSemanaAbreviadoDoDiaSelecionado,
                  diaSemanaSelecionadoCompleto: _diaSemanaCompletoDoDiaSelecionado,
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
    required _Turno turno,
    required int periodo,
    required _ReservaLaboratorio? reservaAtual,
  }) async {
    try {
      final userContext = context.read<UserContextProvider>();
      final user = userContext.currentUser;
      final role = userContext.userRole;

      if (user == null || (role != UserRole.chefeDepartamento && role != UserRole.coordenador && role != UserRole.professor)) {
        _showInfo('Somente perfis docentes podem alterar reservas pela grade.');
        return;
      }

      if (reservaAtual == null) {
        String? disciplina;
        if (role == UserRole.professor || role == UserRole.coordenador || role == UserRole.chefeDepartamento) {
          disciplina = await _solicitarDisciplinaProfessor();
          if (disciplina == null) {
            return;
          }
        }

        final jaOcupado = _reservas.any(
          (reserva) =>
              reserva.laboratorio == _laboratorioSelecionadoValido &&
              reserva.mes == _mesSelecionado &&
              reserva.semanaDoMes == _semanaSelecionada &&
              reserva.diaSemana == diaSemana &&
              reserva.turno == turno &&
              reserva.periodo == periodo,
        );

        if (jaOcupado) {
          _showInfo('Este horário acabou de ser reservado por outro usuário.');
          return;
        }

        setState(() {
          _reservas.add(
            _ReservaLaboratorio(
              id: 'RES-${DateTime.now().microsecondsSinceEpoch}',
              professor: user.name,
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
        _saveData();

        AppEventLogger.action('reserva_create', details: {
          'laboratorio': _laboratorioSelecionadoValido,
          'diaSemana': diaSemana,
          'turno': turno.name,
          'periodo': periodo,
          'professor': user.name,
        });

        _showInfo('Horário reservado com sucesso.');
        return;
      }

      if (role != UserRole.chefeDepartamento && reservaAtual.professor != user.name) {
        _showInfo('Você só pode remover as próprias reservas.');
        return;
      }

      final confirmarExclusao = await _confirmarAcao(
        titulo: 'Excluir reserva',
        mensagem:
            'Deseja remover sua reserva de ${_diaCompleto(diaSemana)}, ${turno.horarioDo(periodo)}, ${_descricaoSemana(_semanaSelecionada)} de ${_nomeMes(_mesSelecionado)} no $_laboratorioSelecionadoValido?',
        confirmarLabel: 'Excluir',
        isDelete: true,
      );

      if (!confirmarExclusao) return;

      setState(() {
        _reservas.removeWhere((reserva) => reserva.id == reservaAtual.id);
      });
      _saveData();

      AppEventLogger.action('reserva_remove', details: {
        'reservaId': reservaAtual.id,
        'laboratorio': reservaAtual.laboratorio,
        'diaSemana': reservaAtual.diaSemana,
        'turno': reservaAtual.turno.name,
        'periodo': reservaAtual.periodo,
      });

      _showInfo('Reserva removida.');
    } catch (error, stackTrace) {
      AppEventLogger.error('reserva_error', error, stackTrace: stackTrace);
      _showError('Não foi possível concluir a operação. Tente novamente.');
    }
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

  Future<String?> _solicitarDisciplinaProfessor() async {
    final result = await showDialog<String>(
      context: context,
      builder: (_) => const _DialogDisciplinaReserva(),
    );

    if (result == null || result.trim().isEmpty) {
      return null;
    }

    return result.trim();
  }

  void _showInfo(String message) {
    if (!mounted) return;
    AppFeedbackService.info(context, message);
  }

  void _showError(String message) {
    if (!mounted) return;
    AppFeedbackService.error(context, message);
  }

  String _diaCompleto(String diaSemana) {
    switch (diaSemana) {
      case 'Seg':
        return 'segunda-feira';
      case 'Ter':
        return 'terça-feira';
      case 'Qua':
        return 'quarta-feira';
      case 'Qui':
        return 'quinta-feira';
      case 'Sex':
        return 'sexta-feira';
      default:
        return diaSemana;
    }
  }

  String _nomeMes(int mes) {
    if (mes < 1 || mes > _meses.length) {
      return 'Mês inválido';
    }
    return _meses[mes - 1];
  }

  String get _diaSemanaAbreviadoDoDiaSelecionado {
    final weekday = DateTime(DateTime.now().year, _mesSelecionado, _diaSelecionado).weekday;
    switch (weekday) {
      case DateTime.monday:
        return 'Seg';
      case DateTime.tuesday:
        return 'Ter';
      case DateTime.wednesday:
        return 'Qua';
      case DateTime.thursday:
        return 'Qui';
      case DateTime.friday:
        return 'Sex';
      case DateTime.saturday:
        return 'Sáb';
      case DateTime.sunday:
        return 'Dom';
      default:
        return '-';
    }
  }

  String get _diaSemanaCompletoDoDiaSelecionado {
    final weekday = DateTime(DateTime.now().year, _mesSelecionado, _diaSelecionado).weekday;
    switch (weekday) {
      case DateTime.monday:
        return 'segunda-feira';
      case DateTime.tuesday:
        return 'terça-feira';
      case DateTime.wednesday:
        return 'quarta-feira';
      case DateTime.thursday:
        return 'quinta-feira';
      case DateTime.friday:
        return 'sexta-feira';
      case DateTime.saturday:
        return 'sábado';
      case DateTime.sunday:
        return 'domingo';
      default:
        return 'dia inválido';
    }
  }

  String _descricaoSemana(int semana) {
    return '${semana}a semana';
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
      items: laboratorios.map((lab) => DropdownMenuItem(value: lab, child: Text(lab))).toList(),
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
          DropdownMenuItem<int>(
            value: i + 1,
            child: Text(meses[i]),
          ),
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
    required this.diaSelecionado,
    required this.diasNoMes,
    required this.onDiaChanged,
  });

  final int diaSelecionado;
  final int diasNoMes;
  final ValueChanged<int> onDiaChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: SigadColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: SigadColors.divider),
      ),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (var dia = 1; dia <= diasNoMes; dia++)
            ChoiceChip(
              label: Text('$dia'),
              selected: dia == diaSelecionado,
              onSelected: (_) => onDiaChanged(dia),
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
  final List<_ReservaLaboratorio> reservas;
  final bool podeEditar;
  final Future<void> Function(String diaSemana, _Turno turno, int periodo, _ReservaLaboratorio? reservaAtual) onTapCelula;

  static const List<String> _diasAbreviados = ['Seg', 'Ter', 'Qua', 'Qui', 'Sex'];

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
          '$semanaLabel de $mesLabel',
          style: textTheme.bodySmall?.copyWith(color: SigadColors.muted),
        ),
        const SizedBox(height: 2),
        Text(
          'Dia selecionado: $diaSelecionado ($diaSemanaSelecionado - $diaSemanaSelecionadoCompleto)',
          style: textTheme.bodySmall?.copyWith(color: SigadColors.muted),
        ),
        const SizedBox(height: 14),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: _GradeSemanal(
            diasAbreviados: _diasAbreviados,
            diasDoMes: diasDoMesDaSemana,
            diaSemanaSelecionado: diaSemanaSelecionado,
            linhas: linhas,
            reservaPara: _reservaPara,
            podeEditar: podeEditar,
            onTapCelula: onTapCelula,
          ),
        ),
      ],
    );
  }

  List<_HorarioGridRow> _gerarLinhasGrade() {
    return [
      for (final turno in _Turno.values)
        for (var periodo = 1; periodo <= turno.horarios.length; periodo++)
          _HorarioGridRow(
            turno: turno,
            periodo: periodo,
            horario: turno.horarioDo(periodo),
          ),
    ];
  }

  _ReservaLaboratorio? _reservaPara(String diaSemana, _Turno turno, int periodo) {
    for (final reserva in reservas) {
      if (reserva.diaSemana == diaSemana && reserva.turno == turno && reserva.periodo == periodo) {
        return reserva;
      }
    }
    return null;
  }

  List<int> _diasDoMesDaSemanaSelecionada() {
    final dataSelecionada = DateTime(DateTime.now().year, mesSelecionado, diaSelecionado);
    final inicioDaSemana = dataSelecionada.subtract(Duration(days: dataSelecionada.weekday - DateTime.monday));
    return List<int>.generate(5, (index) => inicioDaSemana.add(Duration(days: index)).day);
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
  final List<_HorarioGridRow> linhas;
  final _ReservaLaboratorio? Function(String diaSemana, _Turno turno, int periodo) reservaPara;
  final bool podeEditar;
  final Future<void> Function(String diaSemana, _Turno turno, int periodo, _ReservaLaboratorio? reservaAtual) onTapCelula;

  static const double _dayColumnWidth = 156;
  static const double _rowHeight = 72;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: SigadColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: SigadColors.divider),
      ),
      child: Column(
        children: [
          Row(
            children: [
              for (var index = 0; index < diasAbreviados.length; index++)
                _GradeHeaderCell(
                  width: _dayColumnWidth,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        diasAbreviados[index],
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: diasAbreviados[index] == diaSemanaSelecionado
                              ? SigadColors.brand
                              : null,
                        ),
                      ),
                      Text(
                        '${diasDoMes[index]}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: diasAbreviados[index] == diaSemanaSelecionado
                              ? SigadColors.brand
                              : SigadColors.muted,
                          fontWeight: diasAbreviados[index] == diaSemanaSelecionado
                              ? FontWeight.w700
                              : FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const Divider(height: 1),
          for (var index = 0; index < linhas.length; index++) ...[
            if (index == 0 || linhas[index - 1].turno != linhas[index].turno)
              _TurnoDividerRow(
                width: _dayColumnWidth * diasAbreviados.length,
                turno: linhas[index].turno,
              ),
            Row(
              children: [
                for (final diaSemana in diasAbreviados)
                  _GradeReservaCell(
                    width: _dayColumnWidth,
                    height: _rowHeight,
                    horario: linhas[index].horario,
                    turno: linhas[index].turno,
                    periodo: linhas[index].periodo,
                    diaSemana: diaSemana,
                    reserva: reservaPara(diaSemana, linhas[index].turno, linhas[index].periodo),
                    podeEditar: podeEditar,
                    onTapCelula: onTapCelula,
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
  const _TurnoDividerRow({
    required this.width,
    required this.turno,
  });

  final double width;
  final _Turno turno;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
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

class _GradeHeaderCell extends StatelessWidget {
  const _GradeHeaderCell({
    required this.width,
    required this.child,
  });

  final double width;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      alignment: Alignment.center,
      child: child,
    );
  }
}

class _GradeReservaCell extends StatelessWidget {
  const _GradeReservaCell({
    required this.width,
    required this.height,
    required this.horario,
    required this.turno,
    required this.periodo,
    required this.diaSemana,
    required this.reserva,
    required this.podeEditar,
    required this.onTapCelula,
  });

  final double width;
  final double height;
  final String horario;
  final _Turno turno;
  final int periodo;
  final String diaSemana;
  final _ReservaLaboratorio? reserva;
  final bool podeEditar;
  final Future<void> Function(String diaSemana, _Turno turno, int periodo, _ReservaLaboratorio? reservaAtual) onTapCelula;

  @override
  Widget build(BuildContext context) {
    final livre = reserva == null;
    final tone = livre ? SigadColors.success : SigadColors.warning;
    final background = livre ? SigadColors.successSoft.withValues(alpha: 0.55) : SigadColors.accentSoft.withValues(alpha: 0.70);
    return Semantics(
      button: podeEditar,
      label: 'Célula $diaSemana, ${turno.label}, período $periodo, horário $horario.',
      value: livre ? 'Livre' : 'Reservado por ${reserva!.professor}',
      hint: podeEditar ? 'Toque para reservar ou remover reserva.' : null,
      child: InkWell(
        onTap: podeEditar ? () => onTapCelula(diaSemana, turno, periodo, reserva) : null,
        child: Container(
        width: width,
        height: height,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        decoration: BoxDecoration(
          color: background,
          border: Border(
            top: const BorderSide(color: SigadColors.divider),
            right: BorderSide(
              color: diaSemana == 'Sex' ? Colors.transparent : SigadColors.divider,
            ),
            bottom: BorderSide(
              color: tone.withValues(alpha: 0.35),
              width: 2,
            ),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    horario,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: SigadColors.muted,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
                const SizedBox(width: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: turno.chipBackground,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${turno.shortLabel}$periodo',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: turno.chipTextColor,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Flexible(
              child: Row(
                children: [
                  Icon(
                    livre ? Icons.check_circle_outline : Icons.event_busy_outlined,
                    size: 14,
                    color: tone,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      livre ? 'Livre' : 'Reservado',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: tone,
                          ),
                    ),
                  ),
                ],
              ),
            ),
            if (!livre) ...[
              const SizedBox(height: 2),
              Flexible(
                child: Text(
                  reserva!.professor,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: SigadColors.brandDark,
                        fontWeight: FontWeight.w600,
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

class _HorarioGridRow {
  const _HorarioGridRow({
    required this.turno,
    required this.periodo,
    required this.horario,
  });

  final _Turno turno;
  final int periodo;
  final String horario;
}

class _DialogDisciplinaReserva extends StatefulWidget {
  const _DialogDisciplinaReserva();

  @override
  State<_DialogDisciplinaReserva> createState() => _DialogDisciplinaReservaState();
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
            const Icon(Icons.lock_outline, size: 54, color: SigadColors.muted),
            const SizedBox(height: 12),
            Text(
              'Acesso restrito',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              'Este módulo está disponível para professor, coordenador e chefe do departamento.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: SigadColors.muted),
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

class _ReservaLaboratorio {
  const _ReservaLaboratorio({
    required this.id,
    required this.professor,
    required this.laboratorio,
    required this.mes,
    required this.semanaDoMes,
    required this.diaSemana,
    required this.turno,
    required this.periodo,
    this.disciplina,
  });

  final String id;
  final String professor;
  final String laboratorio;
  final int mes;
  final int semanaDoMes;
  final String diaSemana;
  final _Turno turno;
  final int periodo;
  final String? disciplina;
}

enum _Turno {
  matutino('Matutino'),
  vespertino('Tarde'),
  noturno('Noite');

  const _Turno(this.label);
  final String label;

  String get shortLabel {
    switch (this) {
      case _Turno.matutino:
        return 'M';
      case _Turno.vespertino:
        return 'T';
      case _Turno.noturno:
        return 'N';
    }
  }

  Color get chipBackground {
    switch (this) {
      case _Turno.matutino:
        return SigadColors.successSoft.withValues(alpha: 0.85);
      case _Turno.vespertino:
        return SigadColors.accentSoft.withValues(alpha: 0.85);
      case _Turno.noturno:
        return SigadColors.surfaceAlt;
    }
  }

  Color get chipTextColor {
    switch (this) {
      case _Turno.matutino:
        return SigadColors.success;
      case _Turno.vespertino:
        return SigadColors.warning;
      case _Turno.noturno:
        return SigadColors.brandDark;
    }
  }

  List<String> get horarios {
    switch (this) {
      case _Turno.matutino:
        return const ['07:15-08:05', '08:05-08:55', '08:55-09:45', '09:45-10:35', '10:50-11:40', '11:40-12:30'];
      case _Turno.vespertino:
        return const ['13:10-14:00', '14:00-14:50', '14:50-15:40', '15:55-16:45', '16:45-17:35', '17:35-18:25'];
      case _Turno.noturno:
        return const ['18:30-19:20', '19:20-20:10', '20:30-21:15', '21:15-22:00', '22:00-22:45'];
    }
  }

  String horarioDo(int periodo) {
    if (periodo < 1 || periodo > horarios.length) {
      return 'Horário indefinido';
    }
    return horarios[periodo - 1];
  }
}
