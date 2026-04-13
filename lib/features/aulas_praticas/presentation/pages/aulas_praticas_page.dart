import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../app/theme/sigad_colors.dart';
import '../../../../core/models/user_role.dart';
import '../../../../core/services/user_context_provider.dart';

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
    'Lab Quimica 1',
    'Lab Biologia 2',
    'Lab Fisica 1',
    'Lab Automacao',
  ];

  final List<_ReservaLaboratorio> _reservas = [
    _ReservaLaboratorio(
      id: 'RES-101',
      professor: 'Ismael',
      laboratorio: 'Lab Quimica 1',
      diaSemana: 'Seg',
      turno: _Turno.matutino,
      periodo: 4,
    ),
    _ReservaLaboratorio(
      id: 'RES-102',
      professor: 'Pee - Claudio Leao',
      laboratorio: 'Lab Quimica 1',
      diaSemana: 'Ter',
      turno: _Turno.matutino,
      periodo: 4,
    ),
    _ReservaLaboratorio(
      id: 'RES-103',
      professor: 'Jean Mark',
      laboratorio: 'Lab Quimica 1',
      diaSemana: 'Sex',
      turno: _Turno.noturno,
      periodo: 1,
    ),
    _ReservaLaboratorio(
      id: 'RES-104',
      professor: 'Lima',
      laboratorio: 'Lab Quimica 1',
      diaSemana: 'Seg',
      turno: _Turno.vespertino,
      periodo: 3,
    ),
  ];

  String _laboratorioSelecionado = _laboratorios.first;

  List<_ReservaLaboratorio> get _reservasDoLaboratorio {
    return _reservas.where((reserva) => reserva.laboratorio == _laboratorioSelecionado).toList();
  }

  int get _totalSlotsSemana {
    const diasUteis = 5;
    final totalPorDia = _Turno.values.fold<int>(0, (total, turno) => total + turno.horarios.length);
    return diasUteis * totalPorDia;
  }

  int get _slotsOcupados => _reservasDoLaboratorio.length;

  int get _slotsLivres {
    final livres = _totalSlotsSemana - _slotsOcupados;
    return livres < 0 ? 0 : livres;
  }

  @override
  Widget build(BuildContext context) {
    final userContext = context.watch<UserContextProvider>();
    final role = userContext.userRole;
    final hasAccess = role != null && _allowedRoles.contains(role);

    if (!hasAccess) {
      return const _AccessDenied();
    }

    final podeEditar = role == UserRole.professor;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Uso do laboratorio'),
      ),
      body: Stack(
        children: [
          const _AmbientBackground(),
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _HeroInfo(
                  totalSlots: _totalSlotsSemana,
                  ocupados: _slotsOcupados,
                  livres: _slotsLivres,
                ),
                const SizedBox(height: 16),
                _FiltroLabRow(
                  laboratorioSelecionado: _laboratorioSelecionado,
                  laboratorios: _laboratorios,
                  onChanged: (value) => setState(() => _laboratorioSelecionado = value),
                ),
                const SizedBox(height: 10),
                _HintBox(
                  text: podeEditar
                      ? 'Toque em celula vazia para adicionar seu nome. Toque no seu proprio nome para excluir a reserva.'
                      : 'Visualizacao para ${role.displayName}. Somente professor pode editar pela grade.',
                ),
                const SizedBox(height: 12),
                _MapaSemanal(
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
    final userContext = context.read<UserContextProvider>();
    final user = userContext.currentUser;
    final role = userContext.userRole;

    if (user == null || role != UserRole.professor) {
      _showInfo('Somente professor pode alterar reservas pela grade.');
      return;
    }

    if (reservaAtual == null) {
      final confirmar = await _confirmarAcao(
        titulo: 'Confirmar reserva',
        mensagem:
            'Reservar $_laboratorioSelecionado em ${_diaCompleto(diaSemana)}, ${turno.horarioDo(periodo)} no seu nome (${user.name})?',
        confirmarLabel: 'Reservar',
      );

      if (!confirmar) return;

      final jaOcupado = _reservas.any(
        (reserva) =>
            reserva.laboratorio == _laboratorioSelecionado &&
            reserva.diaSemana == diaSemana &&
            reserva.turno == turno &&
            reserva.periodo == periodo,
      );

      if (jaOcupado) {
        _showInfo('Este horario acabou de ser reservado por outro usuario.');
        return;
      }

      setState(() {
        _reservas.add(
          _ReservaLaboratorio(
            id: 'RES-${DateTime.now().microsecondsSinceEpoch}',
            professor: user.name,
            laboratorio: _laboratorioSelecionado,
            diaSemana: diaSemana,
            turno: turno,
            periodo: periodo,
          ),
        );
      });

      _showInfo('Horario reservado com sucesso.');
      return;
    }

    final professorAtual = reservaAtual.professor.trim().toLowerCase();
    final professorLogado = user.name.trim().toLowerCase();

    if (professorAtual != professorLogado) {
      _showInfo('Horario ja ocupado por ${reservaAtual.professor}. Somente o proprio professor pode excluir.');
      return;
    }

    final confirmarExclusao = await _confirmarAcao(
      titulo: 'Excluir reserva',
      mensagem:
          'Deseja remover sua reserva de ${_diaCompleto(diaSemana)}, ${turno.horarioDo(periodo)} no $_laboratorioSelecionado?',
      confirmarLabel: 'Excluir',
      isDelete: true,
    );

    if (!confirmarExclusao) return;

    setState(() {
      _reservas.removeWhere((reserva) => reserva.id == reservaAtual.id);
    });

    _showInfo('Reserva removida.');
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
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  String _diaCompleto(String diaSemana) {
    switch (diaSemana) {
      case 'Seg':
        return 'segunda-feira';
      case 'Ter':
        return 'terca-feira';
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
}

class _HeroInfo extends StatelessWidget {
  const _HeroInfo({
    required this.totalSlots,
    required this.ocupados,
    required this.livres,
  });

  final int totalSlots;
  final int ocupados;
  final int livres;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: SigadColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: SigadColors.divider),
      ),
      child: Row(
        children: [
          _BadgeInfo(label: 'Slots/semana', value: '$totalSlots', tone: SigadColors.brand),
          const SizedBox(width: 10),
          _BadgeInfo(label: 'Ocupados', value: '$ocupados', tone: SigadColors.warning),
          const SizedBox(width: 10),
          _BadgeInfo(label: 'Livres', value: '$livres', tone: SigadColors.success),
        ],
      ),
    );
  }
}

class _BadgeInfo extends StatelessWidget {
  const _BadgeInfo({
    required this.label,
    required this.value,
    required this.tone,
  });

  final String label;
  final String value;
  final Color tone;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        decoration: BoxDecoration(
          color: tone.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: SigadColors.muted),
            ),
            Text(
              value,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: tone,
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ],
        ),
      ),
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
      initialValue: laboratorioSelecionado,
      decoration: const InputDecoration(labelText: 'Laboratorio'),
      items: laboratorios.map((lab) => DropdownMenuItem(value: lab, child: Text(lab))).toList(),
      onChanged: (value) {
        if (value != null) onChanged(value);
      },
    );
  }
}

class _HintBox extends StatelessWidget {
  const _HintBox({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: SigadColors.surface,
        border: Border.all(color: SigadColors.divider),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.touch_app_outlined, size: 18, color: SigadColors.muted),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: SigadColors.muted),
            ),
          ),
        ],
      ),
    );
  }
}

class _MapaSemanal extends StatelessWidget {
  const _MapaSemanal({
    required this.reservas,
    required this.podeEditar,
    required this.onTapCelula,
  });

  final List<_ReservaLaboratorio> reservas;
  final bool podeEditar;
  final Future<void> Function(String diaSemana, _Turno turno, int periodo, _ReservaLaboratorio? reservaAtual) onTapCelula;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: SigadColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: SigadColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Disponibilidade semanal',
            style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          _GradeTurno(
            turno: _Turno.matutino,
            reservas: _reservasDoTurno(_Turno.matutino),
            podeEditar: podeEditar,
            onTapCelula: onTapCelula,
          ),
          const SizedBox(height: 12),
          _GradeTurno(
            turno: _Turno.vespertino,
            reservas: _reservasDoTurno(_Turno.vespertino),
            podeEditar: podeEditar,
            onTapCelula: onTapCelula,
          ),
          const SizedBox(height: 12),
          _GradeTurno(
            turno: _Turno.noturno,
            reservas: _reservasDoTurno(_Turno.noturno),
            podeEditar: podeEditar,
            onTapCelula: onTapCelula,
          ),
        ],
      ),
    );
  }

  List<_ReservaLaboratorio> _reservasDoTurno(_Turno turno) {
    return reservas.where((reserva) => reserva.turno == turno).toList();
  }
}

class _GradeTurno extends StatelessWidget {
  const _GradeTurno({
    required this.turno,
    required this.reservas,
    required this.podeEditar,
    required this.onTapCelula,
  });

  final _Turno turno;
  final List<_ReservaLaboratorio> reservas;
  final bool podeEditar;
  final Future<void> Function(String diaSemana, _Turno turno, int periodo, _ReservaLaboratorio? reservaAtual) onTapCelula;

  static const List<String> _dias = ['Seg', 'Ter', 'Qua', 'Qui', 'Sex'];

  @override
  Widget build(BuildContext context) {
    final horarios = turno.horarios;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFF4EA3B),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: SigadColors.divider),
          ),
          child: Text(
            turno.tituloSecao,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w800),
          ),
        ),
        const SizedBox(height: 6),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Table(
            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
            border: TableBorder.all(color: SigadColors.divider),
            columnWidths: const {
              0: FixedColumnWidth(122),
            },
            children: [
              TableRow(
                decoration: const BoxDecoration(color: SigadColors.surfaceAlt),
                children: [
                  _headerCell('Horario'),
                  ..._dias.map((dia) => _headerCell(_rotuloDia(dia))),
                ],
              ),
              ...List.generate(horarios.length, (index) {
                final periodo = index + 1;
                return TableRow(
                  children: [
                    _horarioCell(horarios[index]),
                    ..._dias.map((dia) => _slotCell(context, dia, periodo)),
                  ],
                );
              }),
            ],
          ),
        ),
      ],
    );
  }

  String _rotuloDia(String dia) {
    switch (dia) {
      case 'Seg':
        return 'SEGUNDA';
      case 'Ter':
        return 'TERCA';
      case 'Qua':
        return 'QUARTA';
      case 'Qui':
        return 'QUINTA';
      case 'Sex':
        return 'SEXTA';
      default:
        return dia;
    }
  }

  Widget _headerCell(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
      ),
    );
  }

  Widget _horarioCell(String horario) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Text(
        horario,
        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
      ),
    );
  }

  Widget _slotCell(BuildContext context, String diaSemana, int periodo) {
    final reserva = _buscarReserva(diaSemana, periodo);
    final disponivel = reserva == null;

    return SizedBox(
      width: 144,
      child: Padding(
        padding: const EdgeInsets.all(3),
        child: Material(
          color: disponivel ? SigadColors.surfaceAlt : SigadColors.brand.withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(6),
          child: InkWell(
            borderRadius: BorderRadius.circular(6),
            onTap: podeEditar ? () => onTapCelula(diaSemana, turno, periodo, reserva) : null,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
              child: Center(
                child: disponivel
                    ? Text(
                        podeEditar ? 'TOCAR PARA RESERVAR' : '-',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: SigadColors.muted,
                              fontWeight: FontWeight.w600,
                            ),
                      )
                    : Text(
                        reserva.professor.toUpperCase(),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w700),
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  _ReservaLaboratorio? _buscarReserva(String diaSemana, int periodo) {
    for (final reserva in reservas) {
      if (reserva.diaSemana == diaSemana && reserva.periodo == periodo) {
        return reserva;
      }
    }
    return null;
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
              'Este modulo esta disponivel para professor, coordenador e chefe do departamento.',
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
    required this.diaSemana,
    required this.turno,
    required this.periodo,
  });

  final String id;
  final String professor;
  final String laboratorio;
  final String diaSemana;
  final _Turno turno;
  final int periodo;
}

enum _Turno {
  matutino('Matutino'),
  vespertino('Tarde'),
  noturno('Noite');

  const _Turno(this.label);
  final String label;

  String get tituloSecao {
    switch (this) {
      case _Turno.matutino:
        return 'MANHA';
      case _Turno.vespertino:
        return 'TARDE';
      case _Turno.noturno:
        return 'NOITE';
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
      return 'Horario indefinido';
    }
    return horarios[periodo - 1];
  }
}
