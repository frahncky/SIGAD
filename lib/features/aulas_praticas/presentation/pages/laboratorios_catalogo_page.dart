import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme/sigad_colors.dart';
import '../../data/laboratorio_repository.dart';
import '../../data/reserva_repository.dart';
import '../../domain/laboratorio_models.dart';
import '../../domain/reserva_models.dart';

class LaboratoriosCatalogoPage extends StatefulWidget {
  const LaboratoriosCatalogoPage({super.key, required this.onAbrirReservas});

  final VoidCallback onAbrirReservas;

  @override
  State<LaboratoriosCatalogoPage> createState() =>
      _LaboratoriosCatalogoPageState();
}

class _LaboratoriosCatalogoPageState extends State<LaboratoriosCatalogoPage> {
  final _repository = LaboratorioRepository();
  final _reservaRepository = ReservaRepository();
  List<Laboratorio> _laboratorios = const [];
  List<ReservaLaboratorio> _reservas = const [];
  StatusLaboratorio? _status;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final resultados = await Future.wait([
      _repository.load(),
      _reservaRepository.loadReservas(),
    ]);
    if (!mounted) return;
    setState(() {
      _laboratorios = resultados[0] as List<Laboratorio>;
      _reservas = resultados[1] as List<ReservaLaboratorio>;
      _loading = false;
    });
  }

  Future<void> _saveLaboratorio(Laboratorio laboratorio) async {
    final index = _laboratorios.indexWhere((item) => item.id == laboratorio.id);
    if (index < 0) return;
    setState(() {
      final atualizados = List<Laboratorio>.from(_laboratorios);
      atualizados[index] = laboratorio;
      _laboratorios = atualizados;
    });
    await _repository.save(_laboratorios);
  }

  int _reservasDoMes(Laboratorio laboratorio) => _reservas
      .where(
        (item) =>
            item.laboratorio == laboratorio.nome &&
            item.mes == DateTime.now().month,
      )
      .length;

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    final filtrados = _status == null
        ? _laboratorios
        : _laboratorios.where((item) => item.status == _status).toList();
    final operando = _laboratorios
        .where((item) => item.status == StatusLaboratorio.operando)
        .length;
    final manutencao = _laboratorios
        .where((item) => item.status == StatusLaboratorio.manutencao)
        .length;
    final ocorrencias = _laboratorios.fold<int>(
      0,
      (total, item) => total + item.ocorrenciasAtivas,
    );

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
        children: [
          _Header(onAbrirReservas: widget.onAbrirReservas),
          const SizedBox(height: 16),
          _Metrics(
            operando: operando,
            manutencao: manutencao,
            reservas: _reservas
                .where((r) => r.mes == DateTime.now().month)
                .length,
            ocorrencias: ocorrencias,
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ChoiceChip(
                label: const Text('Todos'),
                selected: _status == null,
                onSelected: (_) => setState(() => _status = null),
              ),
              for (final status in StatusLaboratorio.values)
                ChoiceChip(
                  label: Text(_statusLabel(status)),
                  selected: _status == status,
                  onSelected: (_) => setState(() => _status = status),
                ),
            ],
          ),
          const SizedBox(height: 12),
          if (filtrados.isEmpty)
            const _EmptyState()
          else
            LayoutBuilder(
              builder: (context, constraints) {
                final colunas = constraints.maxWidth >= 1050
                    ? 3
                    : constraints.maxWidth >= 650
                    ? 2
                    : 1;
                final largura =
                    (constraints.maxWidth - ((colunas - 1) * 12)) / colunas;
                return Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: filtrados
                      .map(
                        (laboratorio) => SizedBox(
                          width: largura,
                          child: _LaboratorioCard(
                            laboratorio: laboratorio,
                            reservasDoMes: _reservasDoMes(laboratorio),
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) => LaboratorioDetalhesPage(
                                  laboratorio: laboratorio,
                                  reservas: _reservas
                                      .where(
                                        (r) =>
                                            r.laboratorio == laboratorio.nome,
                                      )
                                      .toList(),
                                  onChanged: _saveLaboratorio,
                                  onAbrirReservas: widget.onAbrirReservas,
                                ),
                              ),
                            ),
                          ),
                        ),
                      )
                      .toList(),
                );
              },
            ),
        ],
      ),
    );
  }
}

class LaboratorioDetalhesPage extends StatefulWidget {
  const LaboratorioDetalhesPage({
    super.key,
    required this.laboratorio,
    required this.reservas,
    required this.onChanged,
    required this.onAbrirReservas,
  });

  final Laboratorio laboratorio;
  final List<ReservaLaboratorio> reservas;
  final ValueChanged<Laboratorio> onChanged;
  final VoidCallback onAbrirReservas;

  @override
  State<LaboratorioDetalhesPage> createState() =>
      _LaboratorioDetalhesPageState();
}

class _LaboratorioDetalhesPageState extends State<LaboratorioDetalhesPage> {
  late Laboratorio _laboratorio = widget.laboratorio;

  void _abrirReservas() {
    Navigator.of(context).pop();
    widget.onAbrirReservas();
  }

  Future<void> _reportarProblema() async {
    final titulo = TextEditingController();
    final descricao = TextEditingController();
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reportar problema'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titulo,
              autofocus: true,
              decoration: const InputDecoration(labelText: 'Título'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: descricao,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'Descrição'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Registrar'),
          ),
        ],
      ),
    );
    if (confirmar != true || titulo.text.trim().isEmpty) return;
    final ocorrencia = OcorrenciaLaboratorio(
      id: 'OCO-${DateTime.now().microsecondsSinceEpoch}',
      titulo: titulo.text.trim(),
      descricao: descricao.text.trim(),
      criadaEm: DateTime.now(),
    );
    setState(() {
      _laboratorio = _laboratorio.copyWith(
        ocorrencias: [..._laboratorio.ocorrencias, ocorrencia],
      );
    });
    widget.onChanged(_laboratorio);
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(_laboratorio.status);
    final proximas = List<ReservaLaboratorio>.from(widget.reservas)
      ..sort((a, b) => a.semanaDoMes.compareTo(b.semanaDoMes));
    return Scaffold(
      appBar: AppBar(title: const Text('Detalhes do laboratório')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: SigadColors.brandLight,
                        child: const Icon(
                          Icons.science_outlined,
                          color: SigadColors.brand,
                          size: 30,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _laboratorio.nome,
                              style: Theme.of(context).textTheme.headlineSmall
                                  ?.copyWith(fontWeight: FontWeight.w800),
                            ),
                            const SizedBox(height: 5),
                            Wrap(
                              spacing: 10,
                              runSpacing: 6,
                              children: [
                                _StatusPill(
                                  label: _statusLabel(_laboratorio.status),
                                  color: statusColor,
                                ),
                                Text(_laboratorio.localizacao),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Wrap(
                    spacing: 24,
                    runSpacing: 12,
                    children: [
                      _Info(
                        icon: Icons.groups_outlined,
                        label: 'Capacidade',
                        value: '${_laboratorio.capacidade} pessoas',
                      ),
                      _Info(
                        icon: Icons.person_outline,
                        label: 'Responsável técnico',
                        value: _laboratorio.responsavelTecnico,
                      ),
                      _Info(
                        icon: Icons.devices_outlined,
                        label: 'Equipamentos disponíveis',
                        value: '${_laboratorio.equipamentosDisponiveis}',
                      ),
                      _Info(
                        icon: Icons.warning_amber_rounded,
                        label: 'Ocorrências ativas',
                        value: '${_laboratorio.ocorrenciasAtivas}',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          _Section(
            title: 'Próximas reservas',
            action: TextButton(
              onPressed: _abrirReservas,
              child: const Text('Ver agenda semanal'),
            ),
            child: proximas.isEmpty
                ? const Text(
                    'Nenhuma reserva cadastrada para este laboratório.',
                  )
                : Column(
                    children: proximas
                        .take(4)
                        .map(
                          (reserva) => ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: const Icon(
                              Icons.event_available_outlined,
                              color: SigadColors.brand,
                            ),
                            title: Text(
                              reserva.disciplina ?? 'Reserva de laboratório',
                            ),
                            subtitle: Text(
                              '${reserva.diaSemana} · ${reserva.turno.horarioDo(reserva.periodo)} · ${reserva.professor}',
                            ),
                            trailing: const _StatusPill(
                              label: 'Confirmada',
                              color: SigadColors.success,
                            ),
                          ),
                        )
                        .toList(),
                  ),
          ),
          const SizedBox(height: 14),
          _Section(
            title: 'Equipamentos',
            child: Column(
              children: _laboratorio.equipamentos
                  .map(
                    (equipamento) => ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(
                        Icons.memory_outlined,
                        color: SigadColors.brand,
                      ),
                      title: Text(equipamento.nome),
                      subtitle: Text('${equipamento.quantidade} unidade(s)'),
                      trailing: _StatusPill(
                        label: _equipamentoStatusLabel(equipamento.status),
                        color: _equipamentoStatusColor(equipamento.status),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
          if (_laboratorio.manutencoes.isNotEmpty) ...[
            const SizedBox(height: 14),
            _Section(
              title: 'Manutenção',
              child: Column(
                children: _laboratorio.manutencoes
                    .map(
                      (item) => ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(
                          Icons.build_outlined,
                          color: SigadColors.warning,
                        ),
                        title: Text(item.descricao),
                        subtitle: Text(
                          item.previsaoFim == null
                              ? 'Iniciada em ${DateFormat('dd/MM/yyyy').format(item.inicio)}'
                              : 'Previsão: ${DateFormat('dd/MM/yyyy').format(item.previsaoFim!)}',
                        ),
                        trailing: _StatusPill(
                          label: item.concluida ? 'Concluída' : 'Em andamento',
                          color: item.concluida
                              ? SigadColors.success
                              : SigadColors.warning,
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ],
          if (_laboratorio.ocorrencias.isNotEmpty) ...[
            const SizedBox(height: 14),
            _Section(
              title: 'Ocorrências',
              child: Column(
                children: _laboratorio.ocorrencias.reversed
                    .map(
                      (item) => ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(
                          item.resolvida
                              ? Icons.check_circle_outline
                              : Icons.error_outline,
                          color: item.resolvida
                              ? SigadColors.success
                              : SigadColors.risk,
                        ),
                        title: Text(item.titulo),
                        subtitle: Text(
                          '${item.descricao}\n${DateFormat('dd/MM/yyyy HH:mm').format(item.criadaEm)}',
                        ),
                        isThreeLine: item.descricao.isNotEmpty,
                      ),
                    )
                    .toList(),
              ),
            ),
          ],
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              FilledButton.icon(
                onPressed: _abrirReservas,
                icon: const Icon(Icons.calendar_month_outlined),
                label: const Text('Reservar'),
              ),
              OutlinedButton.icon(
                onPressed: _reportarProblema,
                icon: const Icon(Icons.warning_amber_rounded),
                label: const Text('Reportar problema'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.onAbrirReservas});
  final VoidCallback onAbrirReservas;
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final title = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Laboratórios',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
          const Text('Recursos, disponibilidade, manutenção e ocorrências.'),
        ],
      );
      final action = FilledButton.icon(
        onPressed: onAbrirReservas,
        icon: const Icon(Icons.calendar_month_outlined),
        label: const Text('Reservas'),
      );
      if (constraints.maxWidth < 430) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [title, const SizedBox(height: 12), action],
        );
      }
      return Row(
        children: [
          Expanded(child: title),
          const SizedBox(width: 12),
          action,
        ],
      );
    },
  );
}

class _Metrics extends StatelessWidget {
  const _Metrics({
    required this.operando,
    required this.manutencao,
    required this.reservas,
    required this.ocorrencias,
  });
  final int operando, manutencao, reservas, ocorrencias;
  @override
  Widget build(BuildContext context) => Wrap(
    spacing: 10,
    runSpacing: 10,
    children: [
      _Metric(
        label: 'Operando',
        value: '$operando',
        icon: Icons.check_circle_outline,
        color: SigadColors.success,
      ),
      _Metric(
        label: 'Em manutenção',
        value: '$manutencao',
        icon: Icons.build_outlined,
        color: SigadColors.warning,
      ),
      _Metric(
        label: 'Reservas no mês',
        value: '$reservas',
        icon: Icons.event_outlined,
        color: SigadColors.info,
      ),
      _Metric(
        label: 'Ocorrências ativas',
        value: '$ocorrencias',
        icon: Icons.warning_amber_rounded,
        color: SigadColors.risk,
      ),
    ],
  );
}

class _Metric extends StatelessWidget {
  const _Metric({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });
  final String label, value;
  final IconData icon;
  final Color color;
  @override
  Widget build(BuildContext context) => Container(
    width: 180,
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
    ),
    child: Row(
      children: [
        Icon(icon, color: color),
        const SizedBox(width: 10),
        Text(
          value,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
        ),
        const SizedBox(width: 7),
        Expanded(
          child: Text(label, style: Theme.of(context).textTheme.bodySmall),
        ),
      ],
    ),
  );
}

class _LaboratorioCard extends StatelessWidget {
  const _LaboratorioCard({
    required this.laboratorio,
    required this.reservasDoMes,
    required this.onTap,
  });
  final Laboratorio laboratorio;
  final int reservasDoMes;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    final color = _statusColor(laboratorio.status);
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: SigadColors.brandLight,
                    child: const Icon(
                      Icons.science_outlined,
                      color: SigadColors.brand,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      laboratorio.nome,
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
                  const Icon(Icons.chevron_right),
                ],
              ),
              const SizedBox(height: 12),
              _StatusPill(
                label: _statusLabel(laboratorio.status),
                color: color,
              ),
              const SizedBox(height: 10),
              Text(laboratorio.localizacao),
              Text(
                'Capacidade: ${laboratorio.capacidade} · $reservasDoMes reservas no mês',
              ),
              const Divider(height: 24),
              Text(
                '${laboratorio.equipamentosDisponiveis} equipamentos disponíveis · ${laboratorio.ocorrenciasAtivas} ocorrências ativas',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child, this.action});
  final String title;
  final Widget child;
  final Widget? action;
  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final titleWidget = Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          );
          final compact = action != null && constraints.maxWidth < 420;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (compact) ...[
                titleWidget,
                const SizedBox(height: 4),
                Align(alignment: Alignment.centerLeft, child: action!),
              ] else
                Row(
                  children: [
                    Expanded(child: titleWidget),
                    ?action,
                  ],
                ),
              const SizedBox(height: 8),
              child,
            ],
          );
        },
      ),
    ),
  );
}

class _Info extends StatelessWidget {
  const _Info({required this.icon, required this.label, required this.value});
  final IconData icon;
  final String label, value;
  @override
  Widget build(BuildContext context) => SizedBox(
    width: 210,
    child: Row(
      children: [
        Icon(icon, color: SigadColors.brand),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: Theme.of(context).textTheme.bodySmall),
              Text(value, style: const TextStyle(fontWeight: FontWeight.w700)),
            ],
          ),
        ),
      ],
    ),
  );
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.label, required this.color});
  final String label;
  final Color color;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
    decoration: BoxDecoration(
      color: color.withValues(alpha: .12),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(
      label,
      style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w700),
    ),
  );
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();
  @override
  Widget build(BuildContext context) => const Padding(
    padding: EdgeInsets.all(40),
    child: Center(
      child: Text('Nenhum laboratório encontrado com este status.'),
    ),
  );
}

String _statusLabel(StatusLaboratorio status) => switch (status) {
  StatusLaboratorio.operando => 'Operando',
  StatusLaboratorio.manutencao => 'Em manutenção',
  StatusLaboratorio.interditado => 'Interditado',
};
Color _statusColor(StatusLaboratorio status) => switch (status) {
  StatusLaboratorio.operando => SigadColors.success,
  StatusLaboratorio.manutencao => SigadColors.warning,
  StatusLaboratorio.interditado => SigadColors.risk,
};
String _equipamentoStatusLabel(StatusEquipamento status) => switch (status) {
  StatusEquipamento.disponivel => 'Disponível',
  StatusEquipamento.emUso => 'Em uso',
  StatusEquipamento.manutencao => 'Manutenção',
  StatusEquipamento.indisponivel => 'Indisponível',
};
Color _equipamentoStatusColor(StatusEquipamento status) => switch (status) {
  StatusEquipamento.disponivel => SigadColors.success,
  StatusEquipamento.emUso => SigadColors.info,
  StatusEquipamento.manutencao => SigadColors.warning,
  StatusEquipamento.indisponivel => SigadColors.risk,
};
