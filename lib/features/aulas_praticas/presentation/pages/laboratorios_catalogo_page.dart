import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme/sigad_colors.dart';
import '../../../../app/theme/sigad_icon.dart';
import '../../../../app/theme/sigad_icons.dart';
import '../../data/laboratorio_repository.dart';
import '../../data/reserva_repository.dart';
import '../../domain/laboratorio_models.dart';
import '../../domain/reserva_models.dart';
import '../../domain/reserva_service.dart';

class LaboratoriosCatalogoPage extends StatefulWidget {
  const LaboratoriosCatalogoPage({super.key, required this.onAbrirReservas});

  /// Abre a agenda, já com o laboratório informado selecionado.
  final ValueChanged<String?> onAbrirReservas;

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
            item.ano == DateTime.now().year &&
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
          _Metrics(
            operando: operando,
            manutencao: manutencao,
            reservas: _reservas
                .where(
                  (r) =>
                      r.ano == DateTime.now().year &&
                      r.mes == DateTime.now().month,
                )
                .length,
            ocorrencias: ocorrencias,
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ChoiceChip(
                label: Text('Todos (${_laboratorios.length})'),
                selected: _status == null,
                onSelected: (_) => setState(() => _status = null),
              ),
              for (final status in StatusLaboratorio.values)
                ChoiceChip(
                  label: Text(
                    '${_statusLabel(status)} '
                    '(${_laboratorios.where((item) => item.status == status).length})',
                  ),
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
                            onVerAgenda: () =>
                                widget.onAbrirReservas(laboratorio.nome),
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
  final ValueChanged<String?> onAbrirReservas;

  @override
  State<LaboratorioDetalhesPage> createState() =>
      _LaboratorioDetalhesPageState();
}

class _LaboratorioDetalhesPageState extends State<LaboratorioDetalhesPage> {
  late Laboratorio _laboratorio = widget.laboratorio;

  void _abrirReservas() {
    Navigator.of(context).pop();
    widget.onAbrirReservas(_laboratorio.nome);
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
    final textScale = MediaQuery.textScalerOf(context).scale(1);
    // O nome aparece inteiro: o topo cresce uma linha a cada quebra.
    final estiloNome = Theme.of(
      context,
    ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800);
    final linhasNome =
        (TextPainter(
              text: TextSpan(text: _laboratorio.nome, style: estiloNome),
              textDirection: Directionality.of(context),
              textScaler: MediaQuery.textScalerOf(context),
            )..layout(maxWidth: MediaQuery.sizeOf(context).width - 92))
            .computeLineMetrics();
    final alturaExtraNome = linhasNome
        .skip(1)
        .fold<double>(0, (total, linha) => total + linha.height);
    final expandedHeight =
        216.0 + (72.0 * (textScale - 1).clamp(0.0, 1.0)) + alturaExtraNome;
    final hoje = DateUtils.dateOnly(DateTime.now());
    final proximas =
        [
          for (final reserva in widget.reservas)
            if (ReservaService.dataDaReserva(reserva) case final data?)
              if (!data.isBefore(hoje)) (reserva: reserva, data: data),
        ]..sort((a, b) {
          final porData = a.data.compareTo(b.data);
          if (porData != 0) return porData;
          return a.reserva.turno.index * 10 +
              a.reserva.periodo -
              (b.reserva.turno.index * 10 + b.reserva.periodo);
        });
    return Scaffold(
      backgroundColor: SigadColors.canvas,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: expandedHeight,
            backgroundColor: statusColor,
            foregroundColor: Colors.white,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          statusColor,
                          statusColor.withValues(alpha: .78),
                        ],
                      ),
                    ),
                  ),
                  const Positioned(
                    top: -40,
                    right: -30,
                    child: _HeroBlob(size: 140, opacity: .14),
                  ),
                  const Positioned(
                    bottom: -50,
                    left: -20,
                    child: _HeroBlob(size: 110, opacity: .10),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 60, 20, 18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CircleAvatar(
                              radius: 26,
                              backgroundColor: Colors.white.withValues(
                                alpha: .22,
                              ),
                              child: const SigadIcon(
                                SigadIcons.laboratorio,
                                color: Colors.white,
                                size: 26,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _laboratorio.nome,
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineSmall
                                        ?.copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w800,
                                        ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const SigadIcon(
                                        SigadIcons.local,
                                        size: 14,
                                        color: Colors.white,
                                      ),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          _laboratorio.localizacao,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        _GradientPill(label: _statusLabel(_laboratorio.status)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _InfoGrid(laboratorio: _laboratorio),
                const SizedBox(height: 14),
                _Section(
                  title: 'Próximas reservas',
                  icon: SigadIcons.eventoConfirmado,
                  tone: SigadColors.info,
                  action: TextButton(
                    onPressed: _abrirReservas,
                    child: const Text('Ver agenda'),
                  ),
                  child: proximas.isEmpty
                      ? const _SectionEmptyState(
                          icon: SigadIcons.eventoOcupado,
                          message:
                              'Nenhuma reserva futura para este laboratório.',
                        )
                      : Column(
                          children: proximas
                              .take(4)
                              .map(
                                (item) => ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  leading: CircleAvatar(
                                    radius: 18,
                                    backgroundColor: SigadColors.info
                                        .withValues(alpha: .12),
                                    child: const SigadIcon(
                                      SigadIcons.eventoConfirmado,
                                      color: SigadColors.info,
                                      size: 18,
                                    ),
                                  ),
                                  title: Text(
                                    item.reserva.disciplina ??
                                        'Reserva de laboratório',
                                  ),
                                  subtitle: Text(
                                    '${item.reserva.diaSemana} ${item.data.day.toString().padLeft(2, '0')}/${item.data.month.toString().padLeft(2, '0')} · ${item.reserva.turno.horarioDo(item.reserva.periodo).replaceAll('-', '–')} · ${item.reserva.professor}',
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                ),
                const SizedBox(height: 14),
                _Section(
                  title: 'Equipamentos',
                  icon: SigadIcons.equipamento,
                  tone: SigadColors.brand,
                  child: Column(
                    children: _laboratorio.equipamentos
                        .map(
                          (equipamento) => ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: CircleAvatar(
                              radius: 18,
                              backgroundColor: SigadColors.brand.withValues(
                                alpha: .12,
                              ),
                              child: const SigadIcon(
                                SigadIcons.equipamento,
                                color: SigadColors.brand,
                                size: 18,
                              ),
                            ),
                            title: Text(equipamento.nome),
                            subtitle: Text(
                              '${equipamento.quantidade} unidade(s)',
                            ),
                            trailing: _StatusPill(
                              label: _equipamentoStatusLabel(
                                equipamento.status,
                              ),
                              color: _equipamentoStatusColor(
                                equipamento.status,
                              ),
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
                    icon: SigadIcons.manutencao,
                    tone: SigadColors.warning,
                    child: Column(
                      children: _laboratorio.manutencoes
                          .map(
                            (item) => ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: CircleAvatar(
                                radius: 18,
                                backgroundColor: SigadColors.warning.withValues(
                                  alpha: .12,
                                ),
                                child: const SigadIcon(
                                  SigadIcons.manutencao,
                                  color: SigadColors.warning,
                                  size: 18,
                                ),
                              ),
                              title: Text(item.descricao),
                              subtitle: Text(
                                item.previsaoFim == null
                                    ? 'Iniciada em ${DateFormat('dd/MM/yyyy').format(item.inicio)}'
                                    : 'Previsão: ${DateFormat('dd/MM/yyyy').format(item.previsaoFim!)}',
                              ),
                              trailing: _StatusPill(
                                label: item.concluida
                                    ? 'Concluída'
                                    : 'Em andamento',
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
                    icon: SigadIcons.alerta,
                    tone: SigadColors.risk,
                    child: Column(
                      children: _laboratorio.ocorrencias.reversed
                          .map(
                            (item) => ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: CircleAvatar(
                                radius: 18,
                                backgroundColor:
                                    (item.resolvida
                                            ? SigadColors.success
                                            : SigadColors.risk)
                                        .withValues(alpha: .12),
                                child: SigadIcon(
                                  item.resolvida
                                      ? SigadIcons.concluido
                                      : SigadIcons.erro,
                                  color: item.resolvida
                                      ? SigadColors.success
                                      : SigadColors.risk,
                                  size: 18,
                                ),
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
                const SizedBox(height: 18),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    FilledButton.icon(
                      onPressed: _abrirReservas,
                      icon: const SigadIcon(SigadIcons.calendario),
                      label: const Text('Reservar'),
                    ),
                    OutlinedButton.icon(
                      onPressed: _reportarProblema,
                      icon: const SigadIcon(SigadIcons.alerta),
                      label: const Text('Reportar problema'),
                    ),
                  ],
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
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
  Widget build(BuildContext context) {
    final itens = [
      _Metric(
        label: 'Operando',
        value: '$operando',
        icon: SigadIcons.concluido,
        color: SigadColors.success,
      ),
      _Metric(
        label: 'Em manutenção',
        value: '$manutencao',
        icon: SigadIcons.manutencao,
        color: SigadColors.warning,
      ),
      _Metric(
        label: 'Reservas no mês',
        value: '$reservas',
        icon: SigadIcons.evento,
        color: SigadColors.info,
      ),
      _Metric(
        label: 'Ocorrências ativas',
        value: '$ocorrencias',
        icon: SigadIcons.alerta,
        color: SigadColors.risk,
      ),
    ];
    return LayoutBuilder(
      builder: (context, constraints) {
        final colunas = constraints.maxWidth >= 720 ? 4 : 2;
        final largura = (constraints.maxWidth - (colunas - 1) * 10) / colunas;
        return Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            for (final item in itens) SizedBox(width: largura, child: item),
          ],
        );
      },
    );
  }
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
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Semantics(
      container: true,
      label: '$label: $value',
      excludeSemantics: true,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: SigadColors.divider),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: SigadIcon(icon, color: color, size: 20),
                ),
                const Spacer(),
                Text(
                  value,
                  style: textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(label, style: textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}

class _LaboratorioCard extends StatelessWidget {
  const _LaboratorioCard({
    required this.laboratorio,
    required this.reservasDoMes,
    required this.onTap,
    required this.onVerAgenda,
  });
  final Laboratorio laboratorio;
  final int reservasDoMes;
  final VoidCallback onTap;
  final VoidCallback onVerAgenda;
  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final color = _statusColor(laboratorio.status);
    Widget info(IconData icone, String texto, {Color? cor}) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          SigadIcon(icone, size: 18, color: cor ?? SigadColors.muted),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              texto,
              style: textTheme.bodyMedium?.copyWith(color: cor),
            ),
          ),
        ],
      ),
    );

    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: SigadColors.divider),
      ),
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            border: Border(left: BorderSide(color: color, width: 5)),
          ),
          padding: const EdgeInsets.fromLTRB(16, 14, 12, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _StatusPill(
                label: _statusLabel(laboratorio.status),
                color: color,
              ),
              const SizedBox(height: 8),
              Text(
                laboratorio.nome,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 10),
              info(SigadIcons.local, laboratorio.localizacao),
              info(
                SigadIcons.grupo,
                'Capacidade: ${laboratorio.capacidade} pessoas',
              ),
              info(
                SigadIcons.equipamento,
                '${laboratorio.equipamentosDisponiveis} equipamentos disponíveis',
              ),
              info(
                SigadIcons.evento,
                reservasDoMes == 1
                    ? '1 reserva neste mês'
                    : '$reservasDoMes reservas neste mês',
              ),
              if (laboratorio.ocorrenciasAtivas > 0)
                info(
                  SigadIcons.alerta,
                  laboratorio.ocorrenciasAtivas == 1
                      ? '1 ocorrência ativa'
                      : '${laboratorio.ocorrenciasAtivas} ocorrências ativas',
                  cor: SigadColors.risk,
                ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                alignment: WrapAlignment.end,
                children: [
                  TextButton(onPressed: onTap, child: const Text('Detalhes')),
                  FilledButton.tonalIcon(
                    onPressed: onVerAgenda,
                    icon: const SigadIcon(SigadIcons.calendarioSemana),
                    label: const Text('Ver agenda'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({
    required this.title,
    required this.child,
    this.action,
    this.icon,
    this.tone = SigadColors.brand,
  });
  final String title;
  final Widget child;
  final Widget? action;
  final IconData? icon;
  final Color tone;
  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: SigadColors.surface,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: SigadColors.divider),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: .04),
          blurRadius: 16,
          offset: const Offset(0, 6),
        ),
      ],
    ),
    padding: const EdgeInsets.all(16),
    child: LayoutBuilder(
      builder: (context, constraints) {
        final titleWidget = Row(
          children: [
            if (icon != null) ...[
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: tone.withValues(alpha: .12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: SigadIcon(icon, size: 18, color: tone),
              ),
              const SizedBox(width: 10),
            ],
            Expanded(
              child: Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
              ),
            ),
          ],
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
            const SizedBox(height: 12),
            child,
          ],
        );
      },
    ),
  );
}

class _SectionEmptyState extends StatelessWidget {
  const _SectionEmptyState({required this.icon, required this.message});
  final IconData icon;
  final String message;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 18),
    child: Column(
      children: [
        SigadIcon(icon, size: 28, color: SigadColors.muted),
        const SizedBox(height: 8),
        Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(color: SigadColors.muted),
        ),
      ],
    ),
  );
}

class _InfoGrid extends StatelessWidget {
  const _InfoGrid({required this.laboratorio});
  final Laboratorio laboratorio;

  @override
  Widget build(BuildContext context) {
    final ocorrenciaTone = laboratorio.ocorrenciasAtivas > 0
        ? SigadColors.risk
        : SigadColors.success;
    final itens = [
      _InfoTile(
        icon: SigadIcons.grupo,
        label: 'Capacidade',
        value: '${laboratorio.capacidade} pessoas',
        tone: SigadColors.info,
      ),
      _InfoTile(
        icon: SigadIcons.pessoa,
        label: 'Responsável técnico',
        value: laboratorio.responsavelTecnico,
        tone: SigadColors.brand,
      ),
      _InfoTile(
        icon: SigadIcons.dispositivos,
        label: 'Equipamentos disponíveis',
        value: '${laboratorio.equipamentosDisponiveis}',
        tone: SigadColors.success,
      ),
      _InfoTile(
        icon: SigadIcons.alerta,
        label: 'Ocorrências ativas',
        value: '${laboratorio.ocorrenciasAtivas}',
        tone: ocorrenciaTone,
      ),
    ];
    return LayoutBuilder(
      builder: (context, constraints) {
        final textScale = MediaQuery.textScalerOf(context).scale(1);
        final colunas = constraints.maxWidth >= 640
            ? 4
            : constraints.maxWidth < 360 || textScale > 1.3
            ? 1
            : 2;
        final largura = (constraints.maxWidth - ((colunas - 1) * 12)) / colunas;
        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: itens
              .map((item) => SizedBox(width: largura, child: item))
              .toList(),
        );
      },
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.tone,
  });
  final IconData icon;
  final String label, value;
  final Color tone;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: SigadColors.surface,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: tone.withValues(alpha: .16)),
      boxShadow: [
        BoxShadow(
          color: tone.withValues(alpha: .10),
          blurRadius: 14,
          offset: const Offset(0, 6),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: tone.withValues(alpha: .12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: SigadIcon(icon, color: tone, size: 20),
        ),
        const SizedBox(height: 10),
        Text(
          value,
          maxLines: 3,
          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          maxLines: 3,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: SigadColors.muted),
        ),
      ],
    ),
  );
}

class _GradientPill extends StatelessWidget {
  const _GradientPill({required this.label});
  final String label;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: .20),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: Colors.white.withValues(alpha: .35)),
    ),
    child: Text(
      label,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 12,
        fontWeight: FontWeight.w700,
      ),
    ),
  );
}

class _HeroBlob extends StatelessWidget {
  const _HeroBlob({required this.size, required this.opacity});
  final double size;
  final double opacity;
  @override
  Widget build(BuildContext context) => IgnorePointer(
    child: Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: opacity),
      ),
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
