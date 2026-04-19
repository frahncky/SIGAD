import 'package:flutter/material.dart';
import '../../../../app/theme/sigad_colors.dart';
import '../../../../core/services/app_feedback_service.dart';
import '../../data/relatorio_repository.dart';
import '../../domain/relatorio_models.dart';
import '../../domain/relatorios_service.dart';

class RelatoriosPage extends StatefulWidget {
  const RelatoriosPage({super.key});

  @override
  State<RelatoriosPage> createState() => _RelatoriosPageState();
}

class _RelatoriosPageState extends State<RelatoriosPage> {
  String _busca = '';
  String _filtroStatus = 'Todos';
  final RelatorioRepository _relatorioRepository = RelatorioRepository();
  final List<Relatorio> _relatorios = RelatoriosService.defaultRelatorios();

    @override
    void initState() {
      super.initState();
      _loadData();
    }

    Future<void> _loadData() async {
      final list = await _relatorioRepository.loadRelatorios();
      if (list.isEmpty) return;
      setState(() {
        _relatorios
          ..clear()
          ..addAll(list);
      });
    }

    void _saveData() {
      _relatorioRepository.saveRelatorios(_relatorios);
    }

  void _atualizarRelatorio(Relatorio relatorioAtualizado) {
    setState(() {
      final index = _relatorios.indexWhere((item) => item.id == relatorioAtualizado.id);
      if (index >= 0) {
        _relatorios[index] = relatorioAtualizado;
      }
    });
    _saveData();
  }

  void _baixarRelatorio(Relatorio relatorio) {
    final atualizado = RelatoriosService.registrarDownload(relatorio);
    _atualizarRelatorio(atualizado);
    AppFeedbackService.success(context, 'Relatório baixado: ${relatorio.titulo}');
  }

  void _compartilharRelatorio(Relatorio relatorio) {
    final atualizado = RelatoriosService.registrarCompartilhamento(relatorio);
    _atualizarRelatorio(atualizado);
    AppFeedbackService.info(context, 'Link de compartilhamento gerado para ${relatorio.titulo}');
  }

  List<Relatorio> get _relatoriosFiltrados => RelatoriosService.filtrarRelatorios(
        relatorios: _relatorios,
        busca: _busca,
        filtroStatus: _filtroStatus,
      );

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        children: [
          _RelatoriosSummaryBanner(
            totalRelatorios: _relatorios.length,
            publicados: _relatorios.where((r) => r.status == 'Publicado').length,
            emRevisao: _relatorios.where((r) => r.status == 'Em revisão').length,
          ),
          const SizedBox(height: 16),
          TextField(
            onChanged: (value) => setState(() => _busca = value),
            decoration: const InputDecoration(
              hintText: 'Buscar por título, descrição ou autor',
              prefixIcon: Icon(Icons.search_outlined),
            ),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
                children: RelatoriosService.statusDisponiveis
                  .map(
                    (status) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(status),
                        selected: _filtroStatus == status,
                        onSelected: (_) => setState(() => _filtroStatus = status),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: SigadColors.brand.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: SigadColors.brand.withValues(alpha: 0.2)),
            ),
            child: Row(
              children: [
                Icon(Icons.info, color: SigadColors.brand),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '${_relatoriosFiltrados.length} relatórios disponíveis para consulta',
                    style: textTheme.bodySmall?.copyWith(color: SigadColors.brand),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          ..._relatoriosFiltrados.asMap().entries.map(
                (entry) => Padding(
                  padding: EdgeInsets.only(bottom: entry.key < _relatoriosFiltrados.length - 1 ? 12 : 0),
                  child: _RelatorioCard(
                    relatorio: entry.value,
                    onBaixar: () => _baixarRelatorio(entry.value),
                    onCompartilhar: () => _compartilharRelatorio(entry.value),
                  ),
                ),
              ),
        ],
      ),
    );
  }
}

class _RelatoriosSummaryBanner extends StatelessWidget {
  const _RelatoriosSummaryBanner({
    required this.totalRelatorios,
    required this.publicados,
    required this.emRevisao,
  });

  final int totalRelatorios;
  final int publicados;
  final int emRevisao;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: SigadColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: SigadColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Central de relatórios',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _RelatoriosKpi(label: 'Disponíveis', value: '$totalRelatorios'),
              const SizedBox(width: 8),
              _RelatoriosKpi(label: 'Publicados', value: '$publicados'),
              const SizedBox(width: 8),
              _RelatoriosKpi(label: 'Em revisão', value: '$emRevisao'),
            ],
          ),
        ],
      ),
    );
  }
}

class _RelatoriosKpi extends StatelessWidget {
  const _RelatoriosKpi({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: SigadColors.surfaceAlt,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: SigadColors.muted)),
            const SizedBox(height: 4),
            Text(value, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}

class _RelatorioCard extends StatelessWidget {
  const _RelatorioCard({
    required this.relatorio,
    required this.onBaixar,
    required this.onCompartilhar,
  });

  final Relatorio relatorio;
  final VoidCallback onBaixar;
  final VoidCallback onCompartilhar;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return GestureDetector(
      onTap: () => _showDetalhes(context),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: SigadColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: SigadColors.divider),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: SigadColors.brand.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.description,
                      color: SigadColors.brand,
                      size: 20,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        relatorio.id,
                        style: textTheme.labelSmall?.copyWith(
                          color: SigadColors.muted,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        relatorio.titulo,
                        style: textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              relatorio.descricao,
              style: textTheme.bodySmall?.copyWith(
                color: SigadColors.muted,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: SigadColors.brand.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    relatorio.tipo,
                    style: textTheme.labelSmall?.copyWith(
                      color: SigadColors.brand,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: RelatoriosService.statusColor(relatorio.status).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    relatorio.status,
                    style: textTheme.labelSmall?.copyWith(
                      color: RelatoriosService.statusColor(relatorio.status),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),                PopupMenuButton<String>(
                  onSelected: (value) => _onMenuItemSelected(context, value),
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'visualizar',
                      child: Row(
                        children: [
                          Icon(Icons.visibility, size: 18),
                          SizedBox(width: 8),
                          Text('Visualizar'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'baixar',
                      child: Row(
                        children: [
                          Icon(Icons.download, size: 18),
                          SizedBox(width: 8),
                          Text('Baixar PDF'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'compartilhar',
                      child: Row(
                        children: [
                          Icon(Icons.share, size: 18),
                          SizedBox(width: 8),
                          Text('Compartilhar'),
                        ],
                      ),
                    ),
                  ],
                  icon: const Icon(Icons.more_vert, size: 18),
                ),              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _InfoChip(
                  icon: Icons.calendar_today,
                  label: relatorio.data,
                ),
                _InfoChip(
                  icon: Icons.person_outline,
                  label: relatorio.autor,
                ),
              ],
            ),
            if (relatorio.ultimaAcao != null) ...[
              const SizedBox(height: 8),
              Text(
                relatorio.ultimaAcao!,
                style: textTheme.labelSmall?.copyWith(color: SigadColors.muted),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _onMenuItemSelected(BuildContext context, String value) {
    switch (value) {
      case 'visualizar':
        _showDetalhes(context);
        break;
      case 'baixar':
        onBaixar();
        break;
      case 'compartilhar':
        onCompartilhar();
        break;
    }
  }

  void _showDetalhes(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    showModalBottomSheet(
      context: context,
      builder: (context) => SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(relatorio.id, style: textTheme.labelSmall?.copyWith(color: SigadColors.muted)),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: 280,
                        child: Text(
                          relatorio.titulo,
                          style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _DetailSection(label: 'Descrição', value: relatorio.descricao),
              _DetailSection(label: 'Tipo de Relatório', value: relatorio.tipo),
              _DetailSection(label: 'Autor', value: relatorio.autor),
              _DetailSection(label: 'Data', value: relatorio.data),
              _DetailSection(label: 'Status', value: relatorio.status),
              _DetailSection(label: 'Downloads', value: '${relatorio.downloads}'),
              _DetailSection(label: 'Compartilhamentos', value: '${relatorio.compartilhamentos}'),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        onBaixar();
                      },
                      icon: const Icon(Icons.download),
                      label: const Text('Baixar PDF'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        onCompartilhar();
                      },
                      icon: const Icon(Icons.share),
                      label: const Text('Compartilhar'),
                    ),
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

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: SigadColors.muted),
        const SizedBox(width: 6),
        Text(
          label,
          style: textTheme.bodySmall?.copyWith(color: SigadColors.muted),
        ),
      ],
    );
  }
}

class _DetailSection extends StatelessWidget {
  const _DetailSection({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: textTheme.labelSmall?.copyWith(
              color: SigadColors.muted,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(value, style: textTheme.bodyMedium),
        ],
      ),
    );
  }
}

