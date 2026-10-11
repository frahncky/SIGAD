import 'package:flutter/material.dart';
import '../../../../app/theme/sigad_colors.dart';
import '../../../../core/services/app_event_logger.dart';
import '../../../../core/services/app_feedback_service.dart';
import '../../../../shared/widgets/page_status_view.dart';
import '../../../../shared/widgets/icon_avatar.dart';
import '../../data/atividade_repository.dart';
import '../../domain/atividade_models.dart';
import '../../domain/atividades_service.dart';

class AtividadesPage extends StatefulWidget {
  const AtividadesPage({super.key});

  @override
  State<AtividadesPage> createState() => _AtividadesPageState();
}

class _AtividadesPageState extends State<AtividadesPage> {
  void _showFiltroAtividades(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Filtrar atividades',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),
            RadioGroup<String>(
              groupValue: _filtro,
              onChanged: (value) {
                if (value == null) return;
                setState(() => _filtro = value);
                Navigator.pop(context);
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: AtividadesService.statusAtividade
                    .map(
                      (status) => RadioListTile<String>(
                        title: Text(status),
                        value: status,
                      ),
                    )
                    .toList(growable: false),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() => _filtro = 'Todas');
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
    );
  }

  String _busca = '';
  String _filtro = 'Todas';
  bool _isLoading = true;
  String? _loadError;
  final AtividadeRepository _atividadeRepository = AtividadeRepository();
  final List<Atividade> _atividades = List<Atividade>.of(
    AtividadesService.defaultAtividades(),
    growable: true,
  );

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _loadError = null;
    });
    try {
      final list = await _atividadeRepository.loadAtividades();
      if (!mounted) return;
      setState(() {
        if (list.isNotEmpty) {
          _atividades
            ..clear()
            ..addAll(list);
        }
        _isLoading = false;
      });
    } catch (error, stackTrace) {
      AppEventLogger.error(
        'atividades_load_error',
        error,
        stackTrace: stackTrace,
      );
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _loadError = 'Não foi possível carregar as atividades.';
      });
    }
  }

  void _saveData() {
    _atividadeRepository.saveAtividades(_atividades);
  }

  List<Atividade> get _atividadesFiltradas =>
      AtividadesService.filtrarAtividades(
        atividades: _atividades,
        busca: _busca,
        filtro: _filtro,
      );

  int get _atividadesConcluidas =>
      AtividadesService.countConcluidas(_atividades);

  int get _atividadesPendentes => AtividadesService.countPendentes(_atividades);

  void _mostrarFeedback(String mensagem) {
    AppFeedbackService.info(context, mensagem);
  }

  @override
  Widget build(BuildContext context) {
    final atividadesFiltradas = _atividadesFiltradas;
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _AtividadesSummaryBanner(
                  totalAtividades: _atividades.length,
                  atividadesConcluidas: _atividadesConcluidas,
                  atividadesPendentes: _atividadesPendentes,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    // Campo de busca
                    Expanded(
                      flex: 2,
                      child: TextField(
                        onChanged: (value) => setState(() => _busca = value),
                        decoration: const InputDecoration(
                          hintText:
                              'Buscar por título, descrição ou responsável',
                          prefixIcon: Icon(Icons.search_outlined),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Botão de filtro funcional
                    SizedBox(
                      width: 48,
                      height: 48,
                      child: OutlinedButton(
                        onPressed: () => _showFiltroAtividades(context),
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: const Size(48, 48),
                        ),
                        child: const Icon(Icons.filter_list),
                      ),
                    ),
                  ],
                ),
                //const SizedBox(height: 5),
                // Linha de filtros removida
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const PageStatusView.loading(
                    title: 'Carregando atividades...',
                  )
                : _loadError != null
                ? PageStatusView.error(
                    subtitle: _loadError,
                    onAction: _loadData,
                  )
                : atividadesFiltradas.isEmpty
                ? const PageStatusView.empty(
                    icon: Icons.checklist,
                    title: 'Nenhuma atividade encontrada',
                    subtitle: 'Ajuste os filtros ou crie uma nova atividade.',
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    itemCount: atividadesFiltradas.length,
                    separatorBuilder: (context, i) =>
                        const SizedBox(height: 12),
                    itemBuilder: (_, index) => _AtividadeCard(
                      atividade: atividadesFiltradas[index],
                      onEditar: () => _showEditarAtividade(
                        context,
                        atividadesFiltradas[index],
                      ),
                      onExcluir: () => _showConfirmarExclusao(
                        context,
                        atividadesFiltradas[index],
                      ),
                    ),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCriarAtividade(context),
        tooltip: 'Criar nova atividade',
        backgroundColor: SigadColors.brand,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showCriarAtividade(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final tituloController = TextEditingController();
    final descricaoController = TextEditingController();
    String responsavelSelecionado = 'Coordenação';
    String statusSelecionado = 'Pendente';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.fromLTRB(
            24,
            24,
            24,
            MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Nova Atividade',
                      style: textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    IconButton(
                      tooltip: 'Fechar formulário',
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: tituloController,
                  decoration: const InputDecoration(
                    labelText: 'Título',
                    hintText: 'Digite o título da atividade',
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descricaoController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Descrição',
                    hintText: 'Descreva a atividade em detalhes',
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: responsavelSelecionado,
                  decoration: const InputDecoration(labelText: 'Responsável'),
                  items: AtividadesService.responsaveis
                      .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                      .toList(),
                  onChanged: (value) =>
                      setModalState(() => responsavelSelecionado = value!),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: statusSelecionado,
                  decoration: const InputDecoration(
                    labelText: 'Status inicial',
                  ),
                  items: AtividadesService.statusAtividade
                      .map(
                        (status) => DropdownMenuItem(
                          value: status,
                          child: Text(status),
                        ),
                      )
                      .toList(),
                  onChanged: (value) =>
                      setModalState(() => statusSelecionado = value!),
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
                          final erro = AtividadesService.validarAtividade(
                            titulo: tituloController.text,
                            descricao: descricaoController.text,
                          );
                          if (erro != null) {
                            _mostrarFeedback(erro);
                            return;
                          }
                          setState(() {
                            _atividades.insert(
                              0,
                              Atividade(
                                id: AtividadesService.gerarProximoIdAtividade(
                                  _atividades,
                                ),
                                titulo: tituloController.text.trim(),
                                descricao: descricaoController.text.trim(),
                                data:
                                    AtividadesService.dataPadraoNovaAtividade(),
                                responsavel: responsavelSelecionado,
                                status: statusSelecionado,
                              ),
                            );
                          });
                          _saveData();
                          Navigator.pop(context);
                          _mostrarFeedback('Atividade criada com sucesso!');
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
      ),
    );
  }

  void _showEditarAtividade(BuildContext context, Atividade atividade) {
    final textTheme = Theme.of(context).textTheme;
    final tituloController = TextEditingController(text: atividade.titulo);
    final descricaoController = TextEditingController(
      text: atividade.descricao,
    );
    String responsavelSelecionado = atividade.responsavel;
    String statusSelecionado = atividade.status;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.fromLTRB(
            24,
            24,
            24,
            MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Editar Atividade',
                      style: textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    IconButton(
                      tooltip: 'Fechar formulário',
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: tituloController,
                  decoration: const InputDecoration(
                    labelText: 'Título',
                    hintText: 'Digite o título da atividade',
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descricaoController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Descrição',
                    hintText: 'Descreva a atividade em detalhes',
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: responsavelSelecionado,
                  decoration: const InputDecoration(labelText: 'Responsável'),
                  items: AtividadesService.responsaveis
                      .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                      .toList(),
                  onChanged: (value) =>
                      setModalState(() => responsavelSelecionado = value!),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: statusSelecionado,
                  decoration: const InputDecoration(labelText: 'Status'),
                  items: AtividadesService.statusAtividade
                      .map(
                        (status) => DropdownMenuItem(
                          value: status,
                          child: Text(status),
                        ),
                      )
                      .toList(),
                  onChanged: (value) =>
                      setModalState(() => statusSelecionado = value!),
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
                          final erro = AtividadesService.validarAtividade(
                            titulo: tituloController.text,
                            descricao: descricaoController.text,
                          );
                          if (erro != null) {
                            _mostrarFeedback(erro);
                            return;
                          }
                          setState(() {
                            final index = _atividades.indexWhere(
                              (item) => item.id == atividade.id,
                            );
                            if (index >= 0) {
                              _atividades[index] = atividade.copyWith(
                                titulo: tituloController.text.trim(),
                                descricao: descricaoController.text.trim(),
                                responsavel: responsavelSelecionado,
                                status: statusSelecionado,
                              );
                            }
                          });
                          _saveData();
                          Navigator.pop(context);
                          _mostrarFeedback('Atividade atualizada com sucesso!');
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
      ),
    );
  }

  void _showConfirmarExclusao(BuildContext context, Atividade atividade) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar exclusão'),
        content: Text('Tem certeza que deseja excluir ${atividade.titulo}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _atividades.removeWhere((item) => item.id == atividade.id);
              });
              _saveData();
              Navigator.pop(context);
              _mostrarFeedback('Atividade excluída com sucesso!');
            },
            child: Text(
              'Excluir',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ],
      ),
    );
  }
}

class _AtividadesSummaryBanner extends StatelessWidget {
  const _AtividadesSummaryBanner({
    required this.totalAtividades,
    required this.atividadesConcluidas,
    required this.atividadesPendentes,
  });

  final int totalAtividades;
  final int atividadesConcluidas;
  final int atividadesPendentes;

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
          Row(
            children: [
              const SigadIconAvatar(
                icon: Icons.fact_check_outlined,
                tone: SigadColors.brand,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Agenda operacional',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _AtividadesKpi(
                label: 'No total',
                value: '$totalAtividades',
                tone: SigadColors.brand,
              ),
              const SizedBox(width: 8),
              _AtividadesKpi(
                label: 'Concluídas',
                value: '$atividadesConcluidas',
                tone: SigadColors.success,
              ),
              const SizedBox(width: 8),
              _AtividadesKpi(
                label: 'Pendentes',
                value: '$atividadesPendentes',
                tone: SigadColors.warning,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AtividadesKpi extends StatelessWidget {
  const _AtividadesKpi({
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
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: SigadColors.surfaceAlt,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: SigadColors.muted),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: tone,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AtividadeCard extends StatelessWidget {
  const _AtividadeCard({
    required this.atividade,
    required this.onEditar,
    required this.onExcluir,
  });

  final Atividade atividade;
  final VoidCallback onEditar;
  final VoidCallback onExcluir;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Semantics(
      button: true,
      label: 'Abrir atividade ${atividade.titulo}',
      child: GestureDetector(
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
                    width: 4,
                    height: 60,
                    decoration: BoxDecoration(
                      color: AtividadesService.statusColor(atividade.status),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          atividade.id,
                          style: textTheme.labelSmall?.copyWith(
                            color: SigadColors.muted,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          atividade.titulo,
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
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AtividadesService.statusColor(
                        atividade.status,
                      ).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      atividade.status,
                      style: textTheme.labelSmall?.copyWith(
                        color: AtividadesService.statusColor(atividade.status),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  PopupMenuButton<String>(
                    tooltip: 'Mais ações da atividade',
                    onSelected: (value) => _onMenuItemSelected(context, value),
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
                      PopupMenuItem(
                        value: 'excluir',
                        child: Row(
                          children: [
                            Icon(
                              Icons.delete,
                              color: Theme.of(context).colorScheme.error,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Excluir',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.error,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    icon: const Icon(Icons.more_vert, size: 18),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                atividade.descricao,
                style: textTheme.bodySmall?.copyWith(color: SigadColors.muted),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: _InfoChip(
                      icon: Icons.person_outline,
                      label: atividade.responsavel,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: _InfoChip(
                      icon: Icons.calendar_today,
                      label: atividade.data,
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

  void _onMenuItemSelected(BuildContext context, String value) {
    switch (value) {
      case 'editar':
        onEditar();
        break;
      case 'excluir':
        onExcluir();
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
                  // Adiciona Expanded para o título para evitar overflow
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        atividade.id,
                        style: textTheme.labelSmall?.copyWith(
                          color: SigadColors.muted,
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: 260, // valor fixo ou ajuste conforme necessário
                        child: Text(
                          atividade.titulo,
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ), // fonte menor
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    tooltip: 'Fechar detalhes da atividade',
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _DetailSection(label: 'Descrição', value: atividade.descricao),
              _DetailSection(
                label: 'Responsável',
                value: atividade.responsavel,
              ),
              _DetailSection(label: 'Data', value: atividade.data),
              _DetailSection(label: 'Status', value: atividade.status),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Fechar'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        onEditar();
                      },
                      child: const Text('Editar'),
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
        Flexible(
          child: Text(
            label,
            style: textTheme.bodySmall?.copyWith(color: SigadColors.muted),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
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
      padding: const EdgeInsets.only(bottom: 20),
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
          const SizedBox(height: 6),
          Text(value, style: textTheme.bodyMedium),
        ],
      ),
    );
  }
}
