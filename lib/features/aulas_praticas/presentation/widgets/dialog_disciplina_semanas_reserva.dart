import 'package:flutter/material.dart';

import '../../domain/reserva_models.dart';

class DialogDisciplinaSemanasReserva extends StatefulWidget {
  const DialogDisciplinaSemanasReserva({
    super.key,
    required this.diaSemanaCompleto,
    required this.horarios,
    required this.turnoInicial,
    required this.periodoInicial,
    required this.isOcupado,
  });

  final String diaSemanaCompleto;
  final List<HorarioGridRow> horarios;
  final Turno turnoInicial;
  final int periodoInicial;
  final bool Function(Turno turno, int periodo) isOcupado;

  @override
  State<DialogDisciplinaSemanasReserva> createState() =>
      DialogDisciplinaSemanasReservaState();
}

class DialogDisciplinaSemanasReservaState
    extends State<DialogDisciplinaSemanasReserva> {
  final TextEditingController _disciplinaController = TextEditingController();
  int _totalSemanas = 1;
  late final Set<String> _periodosSelecionados;

  @override
  void initState() {
    super.initState();
    _periodosSelecionados = {
      _chave(widget.turnoInicial, widget.periodoInicial),
    };
  }

  @override
  void dispose() {
    _disciplinaController.dispose();
    super.dispose();
  }

  String _chave(Turno turno, int periodo) => '${turno.name}|$periodo';

  void _alternarPeriodo(Turno turno, int periodo) {
    final chave = _chave(turno, periodo);
    setState(() {
      if (_periodosSelecionados.contains(chave)) {
        if (_periodosSelecionados.length > 1) {
          _periodosSelecionados.remove(chave);
        }
      } else {
        _periodosSelecionados.add(chave);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return AlertDialog(
      title: const Text('Nova Reserva'),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.diaSemanaCompleto,
                style: textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _disciplinaController,
                decoration: const InputDecoration(
                  labelText: 'Disciplina (opcional)',
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Text('Total de semanas:'),
                  const SizedBox(width: 8),
                  DropdownButton<int>(
                    value: _totalSemanas,
                    items: List.generate(
                      6,
                      (i) => DropdownMenuItem(
                        value: i + 1,
                        child: Text('${i + 1}'),
                      ),
                    ),
                    onChanged: (v) {
                      if (v != null) setState(() => _totalSemanas = v);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'Horários',
                style: textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Marque outros horários para reservar de uma vez.',
                style: textTheme.bodySmall,
              ),
              const SizedBox(height: 8),
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
                      _PeriodoChip(
                        label: '${turno.shortLabel}${linha.periodo}',
                        selecionado: _periodosSelecionados.contains(
                          _chave(turno, linha.periodo),
                        ),
                        ocupado: widget.isOcupado(turno, linha.periodo),
                        onTap: () => _alternarPeriodo(turno, linha.periodo),
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
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop({
              'disciplina': _disciplinaController.text.trim().isEmpty
                  ? null
                  : _disciplinaController.text.trim(),
              'totalSemanas': _totalSemanas,
              'periodos': _periodosSelecionados
                  .map((chave) {
                    final partes = chave.split('|');
                    return {
                      'turno': partes[0],
                      'periodo': int.parse(partes[1]),
                    };
                  })
                  .toList(growable: false),
            });
          },
          child: const Text('Confirmar'),
        ),
      ],
    );
  }
}

class _PeriodoChip extends StatelessWidget {
  const _PeriodoChip({
    required this.label,
    required this.selecionado,
    required this.ocupado,
    required this.onTap,
  });

  final String label;
  final bool selecionado;
  final bool ocupado;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(
        label,
        style: ocupado
            ? const TextStyle(decoration: TextDecoration.lineThrough)
            : null,
      ),
      selected: selecionado,
      onSelected: ocupado ? null : (_) => onTap(),
      tooltip: ocupado ? 'Horário já ocupado' : null,
    );
  }
}
