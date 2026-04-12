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
  final List<_AulaPratica> _aulas = [
    _AulaPratica(
      id: 'LAB-101',
      disciplina: 'Quimica Experimental',
      professor: 'Joao Silva',
      turma: 'QX-2026.1',
      laboratorio: 'Lab Quimica 1',
      data: '2026-04-14',
      horario: '08:00 - 10:00',
      status: _AulaStatus.agendada,
      observacao: 'Levar equipamentos de seguranca.',
    ),
    _AulaPratica(
      id: 'LAB-102',
      disciplina: 'Microbiologia',
      professor: 'Ana Souza',
      turma: 'MB-2026.1',
      laboratorio: 'Lab Biologia 2',
      data: '2026-04-14',
      horario: '10:30 - 12:30',
      status: _AulaStatus.emAndamento,
      observacao: 'Aula com avaliacao pratica.',
    ),
    _AulaPratica(
      id: 'LAB-103',
      disciplina: 'Automacao Industrial',
      professor: 'Carlos Mendes',
      turma: 'AI-2026.1',
      laboratorio: 'Lab Automacao',
      data: '2026-04-15',
      horario: '14:00 - 16:00',
      status: _AulaStatus.confirmacaoPendente,
      observacao: 'Checar disponibilidade dos kits.',
    ),
    _AulaPratica(
      id: 'LAB-104',
      disciplina: 'Fisica Aplicada',
      professor: 'Maria Costa',
      turma: 'FA-2026.1',
      laboratorio: 'Lab Fisica 1',
      data: '2026-04-12',
      horario: '16:30 - 18:30',
      status: _AulaStatus.concluida,
      observacao: 'Relatorio da turma ja entregue.',
    ),
  ];

  String _filtroLab = 'Todos';
  String _filtroStatus = 'Todos';

  static const Set<UserRole> _allowedRoles = {
    UserRole.professor,
    UserRole.coordenador,
    UserRole.chefeDepartamento,
  };

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
        title: const Text('Aulas praticas'),
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
    String dataSelecionada = '2026-04-20';
    String horarioSelecionado = '08:00 - 10:00';
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
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: disciplinaController,
                      decoration: const InputDecoration(
                        labelText: 'Disciplina',
                        hintText: 'Ex: Quimica Experimental',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: professorController,
                      decoration: const InputDecoration(
                        labelText: 'Professor',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: turmaController,
                      decoration: const InputDecoration(
                        labelText: 'Turma',
                        hintText: 'Ex: QX-2026.1',
                      ),
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
                        if (value == null) return;
                        setModalState(() => laboratorioSelecionado = value);
                      },
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: dataSelecionada,
                      decoration: const InputDecoration(labelText: 'Data'),
                      items: const [
                        DropdownMenuItem(value: '2026-04-20', child: Text('2026-04-20')),
                        DropdownMenuItem(value: '2026-04-21', child: Text('2026-04-21')),
                        DropdownMenuItem(value: '2026-04-22', child: Text('2026-04-22')),
                      ],
                      onChanged: (value) {
                        if (value == null) return;
                        setModalState(() => dataSelecionada = value);
                      },
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: horarioSelecionado,
                      decoration: const InputDecoration(labelText: 'Horario'),
                      items: const [
                        DropdownMenuItem(value: '08:00 - 10:00', child: Text('08:00 - 10:00')),
                        DropdownMenuItem(value: '10:30 - 12:30', child: Text('10:30 - 12:30')),
                        DropdownMenuItem(value: '14:00 - 16:00', child: Text('14:00 - 16:00')),
                        DropdownMenuItem(value: '16:30 - 18:30', child: Text('16:30 - 18:30')),
                      ],
                      onChanged: (value) {
                        if (value == null) return;
                        setModalState(() => horarioSelecionado = value);
                      },
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<_AulaStatus>(
                      initialValue: statusSelecionado,
                      decoration: const InputDecoration(labelText: 'Status'),
                      items: _AulaStatus.values
                          .map(
                            (status) => DropdownMenuItem(
                              value: status,
                              child: Text(status.label),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value == null) return;
                        setModalState(() => statusSelecionado = value);
                      },
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: observacaoController,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        labelText: 'Observacao',
                      ),
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
                                    data: dataSelecionada,
                                    horario: horarioSelecionado,
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
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: SigadColors.muted,
                  ),
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
            decoration: const InputDecoration(
              labelText: 'Laboratorio',
            ),
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
            decoration: const InputDecoration(
              labelText: 'Status',
            ),
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
                      '${aula.id} • ${aula.disciplina}',
                      style: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${aula.laboratorio} • ${aula.horario}',
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
              _metaChip(context, Icons.calendar_today_outlined, aula.data),
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
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall,
          ),
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
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Este modulo esta disponivel para professor, coordenador e chefe do departamento.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: SigadColors.muted,
                  ),
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
          colors: [
            SigadColors.canvas,
            SigadColors.surfaceAlt,
          ],
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
    required this.data,
    required this.horario,
    required this.status,
    required this.observacao,
  });

  final String id;
  final String disciplina;
  final String professor;
  final String turma;
  final String laboratorio;
  final String data;
  final String horario;
  final _AulaStatus status;
  final String observacao;

  _AulaPratica copyWith({
    _AulaStatus? status,
  }) {
    return _AulaPratica(
      id: id,
      disciplina: disciplina,
      professor: professor,
      turma: turma,
      laboratorio: laboratorio,
      data: data,
      horario: horario,
      status: status ?? this.status,
      observacao: observacao,
    );
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
