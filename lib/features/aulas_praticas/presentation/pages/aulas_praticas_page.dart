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
    'Lab Química 1',
    'Lab Biologia 2',
    'Lab Física 1',
    'Lab Automação',
  ];

  final List<_ReservaLaboratorio> _reservas = [
    _ReservaLaboratorio(
      id: 'RES-101',
      professor: 'Ismael',
      laboratorio: 'Lab Química 1',
      diaSemana: 'Seg',
      turno: _Turno.matutino,
      periodo: 4,
    ),
    _ReservaLaboratorio(
      id: 'RES-102',
      professor: 'Pee - Claudio Leao',
      laboratorio: 'Lab Química 1',
      diaSemana: 'Ter',
      turno: _Turno.matutino,
      periodo: 4,
    ),
    _ReservaLaboratorio(
      id: 'RES-103',
      professor: 'Jean Mark',
      laboratorio: 'Lab Química 1',
      diaSemana: 'Sex',
      turno: _Turno.noturno,
      periodo: 1,
    ),
    _ReservaLaboratorio(
      id: 'RES-104',
      professor: 'Lima',
      laboratorio: 'Lab Química 1',
      diaSemana: 'Seg',
      turno: _Turno.vespertino,
      periodo: 3,
    ),
  ];

  String _laboratorioSelecionado = _laboratorios.first;

  String get _laboratorioSelecionadoValido {
    if (_laboratorios.contains(_laboratorioSelecionado)) {
      return _laboratorioSelecionado;
    }
    return _laboratorios.first;
  }

  List<_ReservaLaboratorio> get _reservasDoLaboratorio {
    return _reservas.where((reserva) => reserva.laboratorio == _laboratorioSelecionadoValido).toList();
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

    final podeEditar = role == UserRole.chefeDepartamento;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Uso do laboratório'),
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
                  laboratorioSelecionado: _laboratorioSelecionadoValido,
                  laboratorios: _laboratorios,
                  onChanged: (value) => setState(() => _laboratorioSelecionado = value),
                ),
                const SizedBox(height: 10),
                _HintBox(
                  text: podeEditar
                      ? 'Edição disponível para o chefe do departamento.'
                      : 'Visualização disponível para ${role.displayName}. A edição da grade é restrita ao chefe do departamento.',
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

    if (user == null || role != UserRole.chefeDepartamento) {
      _showInfo('Somente o chefe do departamento pode alterar reservas pela grade.');
      return;
    }

    if (reservaAtual == null) {
      final confirmar = await _confirmarAcao(
        titulo: 'Confirmar reserva',
        mensagem:
            'Reservar $_laboratorioSelecionadoValido em ${_diaCompleto(diaSemana)}, ${turno.horarioDo(periodo)} em nome de ${user.name}?',
        confirmarLabel: 'Reservar',
      );

      if (!confirmar) return;

      final jaOcupado = _reservas.any(
        (reserva) =>
            reserva.laboratorio == _laboratorioSelecionadoValido &&
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
            diaSemana: diaSemana,
            turno: turno,
            periodo: periodo,
          ),
        );
      });

      _showInfo('Horário reservado com sucesso.');
      return;
    }

    final confirmarExclusao = await _confirmarAcao(
      titulo: 'Excluir reserva',
      mensagem:
          'Deseja remover sua reserva de ${_diaCompleto(diaSemana)}, ${turno.horarioDo(periodo)} no $_laboratorioSelecionadoValido?',
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
      decoration: const InputDecoration(labelText: 'Laboratório'),
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
          const Icon(Icons.info_outline, size: 18, color: SigadColors.muted),
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

  static const List<String> _diasAbreviados = ['Seg', 'Ter', 'Qua', 'Qui', 'Sex'];
  static const List<String> _diasCompletos = ['Segunda', 'Terça', 'Quarta', 'Quinta', 'Sexta'];

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Agenda por dia da semana',
          style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 0),
          child: Row(
            children: [
              ..._diasAbreviados.asMap().entries.map(
                    (entry) => _ColunaDay(
                      diaAbreviado: entry.value,
                      diaCompleto: _diasCompletos[entry.key],
                      reservas: _reservasDosDia(entry.value),
                      podeEditar: podeEditar,
                      onTapCelula: onTapCelula,
                    ),
                  ),
            ],
          ),
        ),
      ],
    );
  }

  List<_ReservaLaboratorio> _reservasDosDia(String diaSemana) {
    return reservas.where((reserva) => reserva.diaSemana == diaSemana).toList();
  }
}

class _ColunaDay extends StatelessWidget {
  const _ColunaDay({
    required this.diaAbreviado,
    required this.diaCompleto,
    required this.reservas,
    required this.podeEditar,
    required this.onTapCelula,
  });

  final String diaAbreviado;
  final String diaCompleto;
  final List<_ReservaLaboratorio> reservas;
  final bool podeEditar;
  final Future<void> Function(String diaSemana, _Turno turno, int periodo, _ReservaLaboratorio? reservaAtual) onTapCelula;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final slots = _gerarSlotsDoDia();

    return Container(
      width: 320,
      margin: const EdgeInsets.only(right: 12, bottom: 12),
      decoration: BoxDecoration(
        color: SigadColors.canvas,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: SigadColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      diaCompleto,
                      style: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    Text(
                      diaAbreviado,
                      style: textTheme.bodySmall?.copyWith(color: SigadColors.muted),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: SigadColors.muted.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '${slots.length}',
                    style: textTheme.labelSmall?.copyWith(color: SigadColors.muted),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          SizedBox(
            height: 300,
            child: ListView.separated(
              padding: const EdgeInsets.all(12),
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: slots.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (_, index) {
                final slot = slots[index];
                return _SlotCard(
                  slot: slot,
                  onTap: () => onTapCelula(slot.diaSemana, slot.turno, slot.periodo, slot.reserva),
                  podeEditar: podeEditar,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  List<_HorarioSlot> _gerarSlotsDoDia() {
    return [
      for (final turno in _Turno.values)
        for (var periodo = 1; periodo <= turno.horarios.length; periodo++)
          _HorarioSlot(
            diaSemana: diaAbreviado,
            turno: turno,
            periodo: periodo,
            reserva: _encontrarReserva(turno, periodo),
          ),
    ];
  }

  _ReservaLaboratorio? _encontrarReserva(_Turno turno, int periodo) {
    for (final reserva in reservas) {
      if (reserva.turno == turno && reserva.periodo == periodo) {
        return reserva;
      }
    }
    return null;
  }
}

class _SlotCard extends StatelessWidget {
  const _SlotCard({
    required this.slot,
    required this.onTap,
    required this.podeEditar,
  });

  final _HorarioSlot slot;
  final VoidCallback onTap;
  final bool podeEditar;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final isEmpty = slot.reserva == null;
    final turnoColor = _corDoTurno(slot.turno);

    return GestureDetector(
      onTap: podeEditar ? onTap : null,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isEmpty ? SigadColors.surfaceAlt : SigadColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: SigadColors.divider),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: turnoColor.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    slot.turno.label,
                    style: textTheme.labelSmall?.copyWith(
                      color: turnoColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  slot.turno.horarioDo(slot.periodo),
                  style: textTheme.bodySmall?.copyWith(color: SigadColors.muted),
                ),
              ],
            ),
            const SizedBox(height: 10),
            if (isEmpty) ...[
              Text(
                'Disponível',
                style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 4),
              Text(
                podeEditar ? 'Disponível para reserva' : 'Sem reserva editável neste perfil',
                style: textTheme.bodySmall?.copyWith(color: SigadColors.muted),
              ),
            ] else ...[
              Text(
                slot.reserva!.professor,
                style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                'Reservado',
                style: textTheme.bodySmall?.copyWith(color: SigadColors.muted),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _corDoTurno(_Turno turno) {
    switch (turno) {
      case _Turno.matutino:
        return Colors.amber;
      case _Turno.vespertino:
        return Colors.orange;
      case _Turno.noturno:
        return Colors.indigo;
    }
  }
}

class _HorarioSlot {
  const _HorarioSlot({
    required this.diaSemana,
    required this.turno,
    required this.periodo,
    this.reserva,
  });

  final String diaSemana;
  final _Turno turno;
  final int periodo;
  final _ReservaLaboratorio? reserva;
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
