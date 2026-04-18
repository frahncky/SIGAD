import 'package:flutter/material.dart';
import '../../../../app/theme/sigad_colors.dart';

class RelatoriosPage extends StatefulWidget {
  const RelatoriosPage({super.key});

  @override
  State<RelatoriosPage> createState() => _RelatoriosPageState();
}

class _RelatoriosPageState extends State<RelatoriosPage> {
  String _busca = '';
  String _filtroStatus = 'Todos';
  final List<_Relatorio> _relatorios = [
    _Relatorio(
      id: '#REL-001',
      titulo: 'Mapeamento de Demandas do Período',
      descricao: 'Análise consolidada de todas as solicitações recebidas no semestre 2026.1',
      tipo: 'Análise Geral',
      data: '15/04/2026',
      autor: 'Coordenação Acadêmica',
      status: 'Publicado',
      statusColor: SigadColors.success,
    ),
    _Relatorio(
      id: '#REL-002',
      titulo: 'Distribuição de Carga Horária Docente',
      descricao: 'Relatório detalhado sobre equilíbrio de carga entre docentes',
      tipo: 'Recursos Humanos',
      data: '12/04/2026',
      autor: 'Departamento de RH',
      status: 'Publicado',
      statusColor: SigadColors.success,
    ),
    _Relatorio(
      id: '#REL-003',
      titulo: 'Indicadores de Desempenho - Q1 2026',
      descricao: 'Métricas de performance e KPIs do primeiro trimestre',
      tipo: 'Desempenho',
      data: '10/04/2026',
      autor: 'Gestão',
      status: 'Publicado',
      statusColor: SigadColors.success,
    ),
    _Relatorio(
      id: '#REL-004',
      titulo: 'Análise de Utilização de Laboratórios',
      descricao: 'Levantamento sobre uso de espaços e equipamentos',
      tipo: 'Infraestrutura',
      data: '18/04/2026',
      autor: 'Coordenação de Laboratórios',
      status: 'Em revisão',
      statusColor: SigadColors.warning,
    ),
    _Relatorio(
      id: '#REL-005',
      titulo: 'Conformidade com Normas ISO',
      descricao: 'Avaliação de conformidade dos processos com normas internacionais',
      tipo: 'Conformidade',
      data: '20/04/2026',
      autor: 'Auditoria Interna',
      status: 'Agendado',
      statusColor: SigadColors.info,
    ),
  ];

  void _atualizarRelatorio(_Relatorio relatorioAtualizado) {
    setState(() {
      final index = _relatorios.indexWhere((item) => item.id == relatorioAtualizado.id);
      if (index >= 0) {
        _relatorios[index] = relatorioAtualizado;
      }
    });
  }

  void _baixarRelatorio(_Relatorio relatorio) {
    final atualizado = relatorio.copyWith(
      downloads: relatorio.downloads + 1,
      ultimaAcao: 'PDF baixado agora',
    );
    _atualizarRelatorio(atualizado);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Relatório baixado: ${relatorio.titulo}')),
    );
  }

  void _compartilharRelatorio(_Relatorio relatorio) {
    final atualizado = relatorio.copyWith(
      compartilhamentos: relatorio.compartilhamentos + 1,
      ultimaAcao: 'Compartilhado agora',
    );
    _atualizarRelatorio(atualizado);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Link de compartilhamento gerado para ${relatorio.titulo}')),
    );
  }

  List<_Relatorio> get _relatoriosFiltrados {
    return _relatorios.where((relatorio) {
      final filtroMatch = _filtroStatus == 'Todos' || relatorio.status == _filtroStatus;
      final busca = _busca.trim().toLowerCase();
      final buscaMatch = busca.isEmpty ||
          relatorio.titulo.toLowerCase().contains(busca) ||
          relatorio.descricao.toLowerCase().contains(busca) ||
          relatorio.autor.toLowerCase().contains(busca);
      return filtroMatch && buscaMatch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Relatórios'),
        elevation: 0,
      ),
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
              children: ['Todos', 'Publicado', 'Em revisão', 'Agendado']
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

  final _Relatorio relatorio;
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
                    color: relatorio.statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    relatorio.status,
                    style: textTheme.labelSmall?.copyWith(
                      color: relatorio.statusColor,
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

class _Relatorio {
  const _Relatorio({
    required this.id,
    required this.titulo,
    required this.descricao,
    required this.tipo,
    required this.data,
    required this.autor,
    required this.status,
    required this.statusColor,
    this.downloads = 0,
    this.compartilhamentos = 0,
    this.ultimaAcao,
  });

  final String id;
  final String titulo;
  final String descricao;
  final String tipo;
  final String data;
  final String autor;
  final String status;
  final Color statusColor;
  final int downloads;
  final int compartilhamentos;
  final String? ultimaAcao;

  _Relatorio copyWith({
    String? titulo,
    String? descricao,
    String? tipo,
    String? data,
    String? autor,
    String? status,
    Color? statusColor,
    int? downloads,
    int? compartilhamentos,
    String? ultimaAcao,
  }) {
    return _Relatorio(
      id: id,
      titulo: titulo ?? this.titulo,
      descricao: descricao ?? this.descricao,
      tipo: tipo ?? this.tipo,
      data: data ?? this.data,
      autor: autor ?? this.autor,
      status: status ?? this.status,
      statusColor: statusColor ?? this.statusColor,
      downloads: downloads ?? this.downloads,
      compartilhamentos: compartilhamentos ?? this.compartilhamentos,
      ultimaAcao: ultimaAcao ?? this.ultimaAcao,
    );
  }
}
