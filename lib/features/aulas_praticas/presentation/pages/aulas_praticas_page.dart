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

  final List<_AulaPratica> _aulas = [
    _AulaPratica(
      id: 'LAB-101',
      disciplina: 'Quimica Experimental',
      professor: 'Joao Silva',
      turma: 'QX-2026.1',
      laboratorio: 'Lab Quimica 1',
      diaSemana: 'Ter',
      turno: _Turno.matutino,
      periodo: 1,
      status: _AulaStatus.agendada,
      observacao: 'Levar equipamentos de seguranca.',
    ),
    _AulaPratica(
      id: 'LAB-102',
      disciplina: 'Microbiologia',
      professor: 'Ana Souza',
      turma: 'MB-2026.1',
      laboratorio: 'Lab Biologia 2',
      diaSemana: 'Ter',
      turno: _Turno.matutino,
      periodo: 3,
      status: _AulaStatus.emAndamento,
      observacao: 'Aula com avaliacao pratica.',
    ),
    _AulaPratica(
      id: 'LAB-103',
      disciplina: 'Automacao Industrial',
      professor: 'Carlos Mendes',
      turma: 'AI-2026.1',
      laboratorio: 'Lab Automacao',
      diaSemana: 'Qua',
      turno: _Turno.vespertino,
      periodo: 2,
      status: _AulaStatus.confirmacaoPendente,
      observacao: 'Checar disponibilidade dos kits.',
    ),
    _AulaPratica(
      id: 'LAB-104',
      disciplina: 'Fisica Aplicada',
      professor: 'Maria Costa',
      turma: 'FA-2026.1',
      laboratorio: 'Lab Fisica 1',
      diaSemana: 'Sex',
      turno: _Turno.noturno,
      periodo: 4,
      status: _AulaStatus.concluida,
      observacao: 'Relatorio da turma ja entregue.',
    ),
  ];

  String _filtroLab = 'Todos';
  String _filtroStatus = 'Todos';

  List<_AulaPratica> get _aulasFiltradas {
    return _aulas.where((aula) {
      final matchLab = _filtroLab == 'Todos' || aula.laboratorio == _filtroLab;
      final matchStatus = _filtroStatus == 'Todos' || aula.status.label == _filtroStatus;
      return matchLab && matchStatus;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final role = context.watch<UserContextProvider>().userRole;
    final hasAccess = role != null && _allowedRoles.contains(role);

    if (!hasAccess) {
      return const _AccessDenied();
    }

    final labs = <String>{'Todos', ..._aulas.map((a) => a.laboratorio)};
    final statuses = <String>{'Todos', ..._AulaStatus.values.map((s) => s.label)};

    return Scaffold(
      appBar: AppBar(
        title: const Text('Aulas praticas de laboratorio'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showNovaAulaSheet,
        icon: const Icon(Icons.add),
        label: const Text('Nova aula'),
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
                  total: _aulas.length,
                  emAndamento: _aulas.where((a) => a.status == _AulaStatus.emAndamento).length,
                  pendentes: _aulas.where((a) => a.status == _AulaStatus.confirmacaoPendente).length,
                ),
                const SizedBox(height: 16),
                _FiltroRow(
                  filtroLab: _filtroLab,
                  filtroStatus: _filtroStatus,
                  labs: labs.toList(),
                  statuses: statuses.toList(),
                  onLabChanged: (value) => setState(() => _filtroLab = value),
                  onStatusChanged: (value) => setState(() => _filtroStatus = value),
                ),
                const SizedBox(height: 16),
                _MapaSemanal(
                  aulas: _aulasFiltradas,
                ),
                const SizedBox(height: 16),
                Text(
                  'Lista de aulas',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                if (_aulasFiltradas.isEmpty)
                  const _EmptyState()
                else
                  Column(
                    children: _aulasFiltradas
                        .map(
                          (aula) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _AulaCard(
                              aula: aula,
                              onStatusChange: (status) => _atualizarStatus(aula.id, status),
                            ),
                          ),
                        )
                        .toList(),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _atualizarStatus(String id, _AulaStatus novoStatus) {
    setState(() {
      final index = _aulas.indexWhere((aula) => aula.id == id);
      if (index == -1) return;
      _aulas[index] = _aulas[index].copyWith(status: novoStatus);
    });
  }

  void _showNovaAulaSheet() {
    final disciplinaController = TextEditingController();
    final professorController = TextEditingController();
    final turmaController = TextEditingController();
    final observacaoController = TextEditingController();
    String laboratorioSelecionado = 'Lab Quimica 1';
    String diaSemanaSelecionado = 'Seg';
    _Turno turnoSelecionado = _Turno.matutino;
    int periodoSelecionado = 1;
    _AulaStatus statusSelecionado = _AulaStatus.agendada;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Cadastrar aula pratica',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: disciplinaController,
                      decoration: const InputDecoration(labelText: 'Disciplina'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: professorController,
                      decoration: const InputDecoration(labelText: 'Professor'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: turmaController,
                      decoration: const InputDecoration(labelText: 'Turma'),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: laboratorioSelecionado,
                      decoration: const InputDecoration(labelText: 'Laboratorio'),
                      items: const [
                        DropdownMenuItem(value: 'Lab Quimica 1', child: Text('Lab Quimica 1')),
                        DropdownMenuItem(value: 'Lab Biologia 2', child: Text('Lab Biologia 2')),
                        DropdownMenuItem(value: 'Lab Fisica 1', child: Text('Lab Fisica 1')),
                        DropdownMenuItem(value: 'Lab Automacao', child: Text('Lab Automacao')),
                      ],
                      onChanged: (value) {
                        if (value != null) setModalState(() => laboratorioSelecionado = value);
                      },
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: diaSemanaSelecionado,
                      decoration: const InputDecoration(labelText: 'Dia da semana'),
                      items: const [
                        DropdownMenuItem(value: 'Seg', child: Text('Segunda')),
                        DropdownMenuItem(value: 'Ter', child: Text('Terca')),
                        DropdownMenuItem(value: 'Qua', child: Text('Quarta')),
                        DropdownMenuItem(value: 'Qui', child: Text('Quinta')),
                        DropdownMenuItem(value: 'Sex', child: Text('Sexta')),
                      ],
                      onChanged: (value) {
                        if (value != null) setModalState(() => diaSemanaSelecionado = value);
                      },
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<_Turno>(
                      initialValue: turnoSelecionado,
                      decoration: const InputDecoration(labelText: 'Turno'),
                      items: _Turno.values
                          .map((turno) => DropdownMenuItem(value: turno, child: Text(turno.label)))
                          .toList(),
                      onChanged: (value) {
                        if (value == null) return;
                        setModalState(() {
                          turnoSelecionado = value;
                          periodoSelecionado = 1;
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<int>(
                      initialValue: periodoSelecionado,
                      decoration: const InputDecoration(labelText: 'Horario do turno'),
                      items: List.generate(
                        turnoSelecionado.horarios.length,
                        (index) => DropdownMenuItem(
                          value: index + 1,
                          child: Text('Periodo ${index + 1} - ${turnoSelecionado.horarios[index]}'),
                        ),
                      ),
                      onChanged: (value) {
                        if (value != null) setModalState(() => periodoSelecionado = value);
                      },
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<_AulaStatus>(
                      initialValue: statusSelecionado,
                      decoration: const InputDecoration(labelText: 'Status'),
                      items: _AulaStatus.values
                          .map((status) => DropdownMenuItem(value: status, child: Text(status.label)))
                          .toList(),
                      onChanged: (value) {
                        if (value != null) setModalState(() => statusSelecionado = value);
                      },
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: observacaoController,
                      maxLines: 2,
                      decoration: const InputDecoration(labelText: 'Observacao'),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancelar'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: FilledButton(
                            onPressed: () {
                              if (disciplinaController.text.trim().isEmpty ||
                                  professorController.text.trim().isEmpty ||
                                  turmaController.text.trim().isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Preencha os campos obrigatorios.')),
                                );
                                return;
                              }
                              setState(() {
                                _aulas.add(
                                  _AulaPratica(
                                    id: 'LAB-${100 + _aulas.length + 1}',
                                    disciplina: disciplinaController.text.trim(),
                                    professor: professorController.text.trim(),
                                    turma: turmaController.text.trim(),
                                    laboratorio: laboratorioSelecionado,
                                    diaSemana: diaSemanaSelecionado,
                                    turno: turnoSelecionado,
                                    periodo: periodoSelecionado,
                                    status: statusSelecionado,
                                    observacao: observacaoController.text.trim().isEmpty
                                        ? 'Sem observacao adicional.'
                                        : observacaoController.text.trim(),
                                  ),
                                );
                              });
                              Navigator.pop(context);
                              ScaffoldMessenger.of(this.context).showSnackBar(
                                const SnackBar(content: Text('Aula pratica cadastrada com sucesso.')),
                              );
                            },
                            child: const Text('Salvar'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _HeroInfo extends StatelessWidget {
  const _HeroInfo({
    required this.total,
    required this.emAndamento,
    required this.pendentes,
  });

  final int total;
  final int emAndamento;
  final int pendentes;

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
          _BadgeInfo(label: 'Total', value: '$total', tone: SigadColors.brand),
          const SizedBox(width: 10),
          _BadgeInfo(label: 'Em andamento', value: '$emAndamento', tone: SigadColors.info),
          const SizedBox(width: 10),
          _BadgeInfo(label: 'Pendentes', value: '$pendentes', tone: SigadColors.warning),
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

class _FiltroRow extends StatelessWidget {
  const _FiltroRow({
    required this.filtroLab,
    required this.filtroStatus,
    required this.labs,
    required this.statuses,
    required this.onLabChanged,
    required this.onStatusChanged,
  });

  final String filtroLab;
  final String filtroStatus;
  final List<String> labs;
  final List<String> statuses;
  final ValueChanged<String> onLabChanged;
  final ValueChanged<String> onStatusChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: DropdownButtonFormField<String>(
            initialValue: filtroLab,
            decoration: const InputDecoration(labelText: 'Laboratorio'),
            items: labs.map((lab) => DropdownMenuItem(value: lab, child: Text(lab))).toList(),
            onChanged: (value) {
              if (value != null) onLabChanged(value);
            },
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: DropdownButtonFormField<String>(
            initialValue: filtroStatus,
            decoration: const InputDecoration(labelText: 'Status'),
            items: statuses.map((status) => DropdownMenuItem(value: status, child: Text(status))).toList(),
            onChanged: (value) {
              if (value != null) onStatusChanged(value);
            },
          ),
        ),
      ],
    );
  }
}

class _MapaSemanal extends StatelessWidget {
  const _MapaSemanal({
    required this.aulas,
  });

  final List<_AulaPratica> aulas;

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
            'Disponibilidade semanal do laboratorio',
            style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          Text(
            'Modelo IFMA por turno (manha, tarde e noite) e dias da semana.',
            style: textTheme.bodySmall?.copyWith(color: SigadColors.muted),
          ),
          const SizedBox(height: 12),
          _GradeTurno(
            turno: _Turno.matutino,
            aulas: _aulasDoTurno(_Turno.matutino),
          ),
          const SizedBox(height: 12),
          _GradeTurno(
            turno: _Turno.vespertino,
            aulas: _aulasDoTurno(_Turno.vespertino),
          ),
          const SizedBox(height: 12),
          _GradeTurno(
            turno: _Turno.noturno,
            aulas: _aulasDoTurno(_Turno.noturno),
          ),
        ],
      ),
    );
  }

  List<_AulaPratica> _aulasDoTurno(_Turno turno) {
    return aulas.where((aula) => aula.turno == turno).toList();
  }
}

class _GradeTurno extends StatelessWidget {
  const _GradeTurno({
    required this.turno,
    required this.aulas,
  });

  final _Turno turno;
  final List<_AulaPratica> aulas;

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

  Widget _slotCell(BuildContext context, String dia, int periodo) {
    final aula = _buscarAula(dia, periodo);

    if (aula == null) {
      return const SizedBox(
        width: 140,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 6, vertical: 10),
          child: Text('-', textAlign: TextAlign.center),
        ),
      );
    }

    return SizedBox(
      width: 140,
      child: Container(
        margin: const EdgeInsets.all(3),
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
        decoration: BoxDecoration(
          color: aula.status.color.withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: aula.status.color.withValues(alpha: 0.24)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              aula.professor.toUpperCase(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 2),
            Text(
              aula.disciplina,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  _AulaPratica? _buscarAula(String dia, int periodo) {
    for (final aula in aulas) {
      if (aula.diaSemana == dia && aula.periodo == periodo) {
        return aula;
      }
    }
    return null;
  }
}

class _AulaCard extends StatelessWidget {
  const _AulaCard({
    required this.aula,
    required this.onStatusChange,
  });

  final _AulaPratica aula;
  final ValueChanged<_AulaStatus> onStatusChange;

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
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${aula.id} - ${aula.disciplina}',
                      style: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${aula.laboratorio} - ${aula.diaSemana} - ${aula.turno.label}',
                      style: textTheme.bodySmall?.copyWith(color: SigadColors.muted),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Periodo ${aula.periodo} - ${aula.horario}',
                      style: textTheme.bodySmall?.copyWith(color: SigadColors.muted),
                    ),
                  ],
                ),
              ),
              _StatusChip(status: aula.status),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _metaChip(context, Icons.person_outline, aula.professor),
              _metaChip(context, Icons.groups_outlined, aula.turma),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            aula.observacao,
            style: textTheme.bodySmall?.copyWith(color: SigadColors.muted),
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: PopupMenuButton<_AulaStatus>(
              tooltip: 'Alterar status',
              onSelected: onStatusChange,
              itemBuilder: (context) => _AulaStatus.values
                  .map(
                    (status) => PopupMenuItem<_AulaStatus>(
                      value: status,
                      child: Text(status.label),
                    ),
                  )
                  .toList(),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: SigadColors.surfaceAlt,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text('Atualizar status'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _metaChip(BuildContext context, IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: SigadColors.surfaceAlt,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: SigadColors.muted),
          const SizedBox(width: 4),
          Text(label, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final _AulaStatus status;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: status.color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        status.label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: status.color,
              fontWeight: FontWeight.w700,
            ),
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

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: SigadColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: SigadColors.divider),
      ),
      child: Column(
        children: [
          const Icon(Icons.search_off_outlined, size: 48, color: SigadColors.muted),
          const SizedBox(height: 8),
          Text(
            'Nenhuma aula encontrada para os filtros aplicados.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
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

class _AulaPratica {
  const _AulaPratica({
    required this.id,
    required this.disciplina,
    required this.professor,
    required this.turma,
    required this.laboratorio,
    required this.diaSemana,
    required this.turno,
    required this.periodo,
    required this.status,
    required this.observacao,
  });

  final String id;
  final String disciplina;
  final String professor;
  final String turma;
  final String laboratorio;
  final String diaSemana;
  final _Turno turno;
  final int periodo;
  final _AulaStatus status;
  final String observacao;

  String get horario {
    final horariosTurno = turno.horarios;
    if (periodo < 1 || periodo > horariosTurno.length) {
      return 'Horario indefinido';
    }
    return horariosTurno[periodo - 1];
  }

  _AulaPratica copyWith({
    _AulaStatus? status,
  }) {
    return _AulaPratica(
      id: id,
      disciplina: disciplina,
      professor: professor,
      turma: turma,
      laboratorio: laboratorio,
      diaSemana: diaSemana,
      turno: turno,
      periodo: periodo,
      status: status ?? this.status,
      observacao: observacao,
    );
  }
}

enum _Turno {
  matutino('Matutino'),
  vespertino('Vespertino'),
  noturno('Noturno');

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
}

enum _AulaStatus {
  agendada('Agendada', SigadColors.brand),
  confirmacaoPendente('Confirmacao pendente', SigadColors.warning),
  emAndamento('Em andamento', SigadColors.info),
  concluida('Concluida', SigadColors.success),
  cancelada('Cancelada', SigadColors.risk);

  const _AulaStatus(this.label, this.color);
  final String label;
  final Color color;
}
