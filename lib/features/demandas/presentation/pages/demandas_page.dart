import 'package:flutter/material.dart';
import '../../../../app/theme/sigad_colors.dart';

class DemandasPage extends StatefulWidget {
  const DemandasPage({super.key});

  @override
  State<DemandasPage> createState() => _DemandasPageState();
}

class _DemandasPageState extends State<DemandasPage> {
  String _filtroStatus = 'Todas';
  String _filtroPrioridade = 'Todas';

  static const List<_Demanda> _demandas = [
    _Demanda(
      id: '#DEM-001',
      titulo: 'Revisar inventário de microscópios',
      descricao: 'Auditoria completa do laboratório de biologia',
      prioridade: 'Alta',
      statusLabel: 'Em andamento',
      statusTone: SigadColors.info,
      proprietario: 'Lab. Biologia',
      prazo: '15/04/2026',
    ),
    _Demanda(
      id: '#DEM-002',
      titulo: 'Mapear demandas semestre 2026.1',
      descricao: 'Levantamento de todas as solicitações do período',
      prioridade: 'Alta',
      statusLabel: 'Novo',
      statusTone: SigadColors.brand,
      proprietario: 'Coordenação',
      prazo: '20/04/2026',
    ),
    _Demanda(
      id: '#DEM-003',
      titulo: 'Padronizar formulários de requisição',
      descricao: 'Unificar templates em uso no departamento',
      prioridade: 'Média',
      statusLabel: 'Aguardando',
      statusTone: SigadColors.warning,
      proprietario: 'Secretaria Acadêmica',
      prazo: '30/04/2026',
    ),
    _Demanda(
      id: '#DEM-004',
      titulo: 'Auditoria de processos de estágio',
      descricao: 'Validação de fluxos e documentação',
      prioridade: 'Média',
      statusLabel: 'Revisão',
      statusTone: SigadColors.accent,
      proprietario: 'Comissão de Estágio',
      prazo: '25/04/2026',
    ),
    _Demanda(
      id: '#DEM-005',
      titulo: 'Relatório de uso dos laboratórios',
      descricao: 'Análise de utilização de espaços e equipamentos',
      prioridade: 'Baixa',
      statusLabel: 'Concluído',
      statusTone: SigadColors.success,
      proprietario: 'Gestão',
      prazo: '10/04/2026',
    ),
  ];

  List<_Demanda> get _demandasFiltradas {
    return _demandas.where((d) {
      final statusMatch = _filtroStatus == 'Todas' || d.statusLabel == _filtroStatus;
      final prioridadeMatch = _filtroPrioridade == 'Todas' || d.prioridade == _filtroPrioridade;
      return statusMatch && prioridadeMatch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Demandas'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFiltros(context),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Filtrar por',
                  style: textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Wrap(
                        spacing: 8,
                        children: ['Todas', 'Novo', 'Em andamento', 'Aguardando', 'Revisão', 'Concluído']
                            .map((status) => FilterChip(
                              label: Text(status),
                              selected: _filtroStatus == status,
                              onSelected: (selected) {
                                setState(() => _filtroStatus = selected ? status : 'Todas');
                              },
                            ))
                            .toList(),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Wrap(
                        spacing: 8,
                        children: ['Todas', 'Alta', 'Média', 'Baixa']
                            .map((prioridade) => FilterChip(
                              label: Text(prioridade),
                              selected: _filtroPrioridade == prioridade,
                              onSelected: (selected) {
                                setState(() => _filtroPrioridade = selected ? prioridade : 'Todas');
                              },
                            ))
                            .toList(),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: _demandasFiltradas.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inbox_outlined, size: 64, color: SigadColors.muted.withValues(alpha: 0.3)),
                        const SizedBox(height: 16),
                        Text(
                          'Nenhuma demanda encontrada',
                          style: textTheme.bodyLarge?.copyWith(color: SigadColors.muted),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: _demandasFiltradas.length,
                    separatorBuilder: (context, i) => const SizedBox(height: 12),
                    itemBuilder: (_, index) => _DemandasCard(
                      demanda: _demandasFiltradas[index],
                    ),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCriarDemanda(context),
        backgroundColor: SigadColors.brand,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showFiltros(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    showModalBottomSheet(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Filtros', style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text('Status', style: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: ['Todas', 'Novo', 'Em andamento', 'Aguardando', 'Revisão', 'Concluído']
                    .map((status) => FilterChip(
                      label: Text(status),
                      selected: _filtroStatus == status,
                      onSelected: (selected) {
                        setState(() => _filtroStatus = selected ? status : 'Todas');
                      },
                    ))
                    .toList(),
              ),
              const SizedBox(height: 24),
              Text('Prioridade', style: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: ['Todas', 'Alta', 'Média', 'Baixa']
                    .map((prioridade) => FilterChip(
                      label: Text(prioridade),
                      selected: _filtroPrioridade == prioridade,
                      onSelected: (selected) {
                        setState(() => _filtroPrioridade = selected ? prioridade : 'Todas');
                      },
                    ))
                    .toList(),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        setState(() {
                          _filtroStatus = 'Todas';
                          _filtroPrioridade = 'Todas';
                        });
                        Navigator.pop(context);
                      },
                      child: const Text('Limpar'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Aplicar'),
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

  void _showCriarDemanda(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final tituloController = TextEditingController();
    final descricaoController = TextEditingController();
    String prioridadeSelecionada = 'Média';
    String proprietarioSelecionado = 'Coordenação';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Container(
          padding: const EdgeInsets.all(24),
          height: MediaQuery.of(context).size.height * 0.8,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Nova Demanda', style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              TextField(
                controller: tituloController,
                decoration: const InputDecoration(
                  labelText: 'Título',
                  hintText: 'Digite o título da demanda',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descricaoController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Descrição',
                  hintText: 'Descreva a demanda em detalhes',
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: prioridadeSelecionada,
                decoration: const InputDecoration(labelText: 'Prioridade'),
                items: ['Alta', 'Média', 'Baixa']
                    .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                    .toList(),
                onChanged: (value) => setState(() => prioridadeSelecionada = value!),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: proprietarioSelecionado,
                decoration: const InputDecoration(labelText: 'Proprietário'),
                items: ['Coordenação', 'Secretaria Acadêmica', 'Lab. Biologia', 'TI', 'RH']
                    .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                    .toList(),
                onChanged: (value) => setState(() => proprietarioSelecionado = value!),
              ),
              const Spacer(),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancelar'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        // Aqui seria implementada a lógica para salvar a demanda
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Demanda criada com sucesso!')),
                        );
                      },
                      child: const Text('Criar'),
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

class _DemandasCard extends StatelessWidget {
  const _DemandasCard({required this.demanda});

  final _Demanda demanda;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return GestureDetector(
      onTap: () => _showDetalhesDemanda(context),
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
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        demanda.id,
                        style: textTheme.labelSmall?.copyWith(
                          color: SigadColors.muted,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        demanda.titulo,
                        style: textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: _getPrioridadeColor(demanda.prioridade),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        demanda.prioridade,
                        style: textTheme.labelSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    PopupMenuButton<String>(
                      onSelected: (value) => _onMenuItemSelected(context, value, demanda),
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'editar',
                          child: Row(
                            children: [
                              Icon(Icons.edit, size: 18),
                              SizedBox(width: 8),
                              Text('Editar'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'excluir',
                          child: Row(
                            children: [
                              Icon(Icons.delete, size: 18),
                              SizedBox(width: 8),
                              Text('Excluir'),
                            ],
                          ),
                        ),
                      ],
                      icon: Icon(
                        Icons.more_vert,
                        color: SigadColors.muted,
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              demanda.descricao,
              style: textTheme.bodySmall?.copyWith(
                color: SigadColors.muted,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  demanda.proprietario,
                  style: textTheme.bodySmall?.copyWith(
                    color: SigadColors.muted,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: demanda.statusTone.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    demanda.statusLabel,
                    style: textTheme.labelSmall?.copyWith(
                      color: demanda.statusTone,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.calendar_today, size: 16, color: SigadColors.muted),
                const SizedBox(width: 6),
                Text(
                  demanda.prazo,
                  style: textTheme.bodySmall?.copyWith(
                    color: SigadColors.muted,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getPrioridadeColor(String prioridade) {
    switch (prioridade) {
      case 'Alta':
        return SigadColors.risk;
      case 'Média':
        return SigadColors.warning;
      default:
        return SigadColors.success;
    }
  }

  void _onMenuItemSelected(BuildContext context, String value, _Demanda demanda) {
    switch (value) {
      case 'editar':
        _showEditarDemanda(context);
        break;
      case 'excluir':
        _showConfirmarExclusao(context);
        break;
    }
  }

  void _showEditarDemanda(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final tituloController = TextEditingController(text: demanda.titulo);
    final descricaoController = TextEditingController(text: demanda.descricao);
    String prioridadeSelecionada = demanda.prioridade;
    String proprietarioSelecionado = demanda.proprietario;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Container(
          padding: const EdgeInsets.all(24),
          height: MediaQuery.of(context).size.height * 0.8,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Editar Demanda', style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              TextField(
                controller: tituloController,
                decoration: const InputDecoration(
                  labelText: 'Título',
                  hintText: 'Digite o título da demanda',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descricaoController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Descrição',
                  hintText: 'Descreva a demanda em detalhes',
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: prioridadeSelecionada,
                decoration: const InputDecoration(labelText: 'Prioridade'),
                items: ['Alta', 'Média', 'Baixa']
                    .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                    .toList(),
                onChanged: (value) => setState(() => prioridadeSelecionada = value!),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: proprietarioSelecionado,
                decoration: const InputDecoration(labelText: 'Proprietário'),
                items: ['Coordenação', 'Secretaria Acadêmica', 'Lab. Biologia', 'TI', 'RH']
                    .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                    .toList(),
                onChanged: (value) => setState(() => proprietarioSelecionado = value!),
              ),
              const Spacer(),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancelar'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        // Aqui seria implementada a lógica para atualizar a demanda
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Demanda atualizada com sucesso!')),
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
      ),
    );
  }

  void _showConfirmarExclusao(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar exclusão'),
        content: const Text('Tem certeza que deseja excluir esta demanda?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              // Aqui seria implementada a lógica para excluir a demanda
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Demanda excluída com sucesso!')),
              );
            },
            child: const Text('Excluir', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showDetalhesDemanda(BuildContext context) {
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
                  Text(demanda.id, style: textTheme.labelSmall?.copyWith(color: SigadColors.muted)),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(demanda.titulo, style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 16),
              _DetailRow(label: 'Descrição', value: demanda.descricao),
              _DetailRow(label: 'Proprietário', value: demanda.proprietario),
              _DetailRow(label: 'Prioridade', value: demanda.prioridade),
              _DetailRow(label: 'Status', value: demanda.statusLabel),
              _DetailRow(label: 'Prazo', value: demanda.prazo),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Fechar'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

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
            style: textTheme.labelSmall?.copyWith(color: SigadColors.muted),
          ),
          const SizedBox(height: 4),
          Text(value, style: textTheme.bodyMedium),
        ],
      ),
    );
  }
}

class _Demanda {
  const _Demanda({
    required this.id,
    required this.titulo,
    required this.descricao,
    required this.prioridade,
    required this.statusLabel,
    required this.statusTone,
    required this.proprietario,
    required this.prazo,
  });

  final String id;
  final String titulo;
  final String descricao;
  final String prioridade;
  final String statusLabel;
  final Color statusTone;
  final String proprietario;
  final String prazo;
}
