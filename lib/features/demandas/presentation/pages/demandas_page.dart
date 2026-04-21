import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../app/theme/sigad_colors.dart';
import '../../../../core/security/authorization_policy.dart';
import '../../../../core/services/app_event_logger.dart';
import '../../../../core/services/app_feedback_service.dart';
import '../../../../core/services/user_context_provider.dart';
import '../../../../shared/widgets/page_status_view.dart';
import '../../data/demanda_repository.dart';
import '../../domain/demanda_models.dart';
import '../../domain/demandas_service.dart';

class DemandasPage extends StatefulWidget {
  const DemandasPage({super.key});

  @override
  State<DemandasPage> createState() => _DemandasPageState();
}

class _DemandasPageState extends State<DemandasPage> {
  String _busca = '';
  String _filtroStatus = 'Todas';
  String _filtroPrioridade = 'Todas';
  String _ordemSelecionada = 'Prazo mais próximo';
  bool _isLoading = true;
  String? _loadError;
  final DemandaRepository _demandaRepository = DemandaRepository();
  final List<Demanda> _demandas = List<Demanda>.of(
    DemandasService.defaultDemandas(),
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
      final list = await _demandaRepository.loadDemandas();
      if (!mounted) return;
      setState(() {
        if (list.isNotEmpty) {
          _demandas
            ..clear()
            ..addAll(list);
        }
        _isLoading = false;
      });
    } catch (error, stackTrace) {
      AppEventLogger.error('demandas_load_error', error, stackTrace: stackTrace);
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _loadError = 'Não foi possível carregar as demandas.';
      });
    }
  }

  void _saveData() {
    _demandaRepository.saveDemandas(_demandas);
  }

  List<Demanda> get _demandasFiltradas => DemandasService.filtrarDemandas(
        demandas: _demandas,
        busca: _busca,
        filtroStatus: _filtroStatus,
        filtroPrioridade: _filtroPrioridade,
      );

  int get _filtrosAtivos {
    return DemandasService.countFiltrosAtivos(
      filtroStatus: _filtroStatus,
      filtroPrioridade: _filtroPrioridade,
      busca: _busca,
    );
  }

  List<Demanda> get _demandasVisiveis =>
      DemandasService.ordenarDemandas(_demandasFiltradas, _ordemSelecionada);

  void _mostrarFeedback(String mensagem) {
    AppFeedbackService.info(context, mensagem);
  }

  @override
  Widget build(BuildContext context) {
    final demandasVisiveis = _demandasVisiveis;
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              onChanged: (value) => setState(() => _busca = value),
              decoration: InputDecoration(
                hintText: 'Buscar por título, descrição ou responsável',
                prefixIcon: const Icon(Icons.search_outlined),
                isDense: true,
                suffixIcon: Tooltip(
                  message: _filtrosAtivos > 0
                      ? 'Abrir filtros ($_filtrosAtivos ativos)'
                      : 'Abrir filtros',
                  child: IconButton(
                    onPressed: () => _showFiltros(context),
                    icon: const Icon(Icons.filter_list),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const PageStatusView.loading(title: 'Carregando demandas...')
                : _loadError != null
                    ? PageStatusView.error(
                        subtitle: _loadError,
                        onAction: _loadData,
                      )
                    : demandasVisiveis.isEmpty
                        ? PageStatusView.empty(
                            icon: Icons.inbox_outlined,
                            title: 'Nenhuma demanda encontrada',
                            subtitle: _filtrosAtivos > 0
                                ? 'Tente limpar os filtros ativos.'
                                : 'Crie uma nova demanda para começar.',
                            actionLabel: _filtrosAtivos > 0 ? 'Limpar filtros' : null,
                            onAction: _filtrosAtivos > 0 ? _limparFiltros : null,
                          )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: demandasVisiveis.length,
                    separatorBuilder: (context, i) => const SizedBox(height: 12),
                    itemBuilder: (_, index) => _DemandasCard(
                      demanda: demandasVisiveis[index],
                      onEditar: () => _showEditarDemanda(context, demandasVisiveis[index]),
                      onExcluir: () => _showConfirmarExclusao(context, demandasVisiveis[index]),
                    ),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCriarDemanda(context),
        backgroundColor: SigadColors.brand,
        foregroundColor: Colors.white,
        tooltip: 'Criar nova demanda',
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showFiltros(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final statusOptions = DemandasService.opcoesUnicas(
      DemandasService.statusDisponiveis,
      primeiro: 'Todas',
    );
    final prioridadeOptions = DemandasService.opcoesUnicas(
      DemandasService.prioridades,
      primeiro: 'Todas',
    );
    final ordenacaoOptions = DemandasService.opcoesUnicas(
      DemandasService.opcoesOrdenacao,
    );
    showModalBottomSheet(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Filtros', style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    tooltip: 'Fechar filtros',
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text('Status', style: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: statusOptions
                    .map((status) => FilterChip(
                      label: Text(status),
                      selected: _filtroStatus == status,
                      onSelected: (selected) {
                        setModalState(() => _filtroStatus = selected ? status : 'Todas');
                      },
                    ))
                    .toList(),
              ),
              const SizedBox(height: 24),
              Text('Prioridade', style: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: prioridadeOptions
                    .map((prioridade) => FilterChip(
                      label: Text(prioridade),
                      selected: _filtroPrioridade == prioridade,
                      onSelected: (selected) {
                        setModalState(() => _filtroPrioridade = selected ? prioridade : 'Todas');
                      },
                    ))
                    .toList(),
              ),
              const SizedBox(height: 24),
              Text('Ordenação', style: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: ordenacaoOptions
                    .map(
                      (ordem) => ChoiceChip(
                        label: Text(ordem),
                        selected: _ordemSelecionada == ordem,
                        onSelected: (selected) {
                          if (selected) {
                            setModalState(() => _ordemSelecionada = ordem);
                          }
                        },
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        _limparFiltros();
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

  void _limparFiltros() {
    setState(() {
      _busca = '';
      _filtroStatus = 'Todas';
      _filtroPrioridade = 'Todas';
      _ordemSelecionada = 'Prazo mais próximo';
    });
  }

  void _showCriarDemanda(BuildContext context) {
    if (!_canManageDemandas(context, actionLabel: 'criar demandas')) return;

    final textTheme = Theme.of(context).textTheme;
    final prioridades = DemandasService.opcoesUnicas(DemandasService.prioridades);
    final proprietarios = DemandasService.opcoesUnicas(DemandasService.proprietarios);
    final statusDisponiveis = DemandasService.opcoesUnicas(DemandasService.statusDisponiveis);
    final tituloController = TextEditingController();
    final descricaoController = TextEditingController();
    String prioridadeSelecionada = prioridades.contains('Média')
      ? 'Média'
      : (prioridades.isNotEmpty ? prioridades.first : 'Média');
    String proprietarioSelecionado = proprietarios.contains('Coordenação')
      ? 'Coordenação'
      : (proprietarios.isNotEmpty ? proprietarios.first : 'Coordenação');
    String statusSelecionado = statusDisponiveis.contains('Novo')
      ? 'Novo'
      : (statusDisponiveis.isNotEmpty ? statusDisponiveis.first : 'Novo');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: const EdgeInsets.all(24),
          height: MediaQuery.of(context).size.height * 0.8,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Nova Demanda', style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    tooltip: 'Fechar criação de demanda',
                    icon: const Icon(Icons.close),
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
                items: prioridades
                    .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                    .toList(),
                onChanged: (value) => setModalState(() => prioridadeSelecionada = value!),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: proprietarioSelecionado,
                decoration: const InputDecoration(labelText: 'Proprietário'),
                items: proprietarios
                    .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                    .toList(),
                onChanged: (value) => setModalState(() => proprietarioSelecionado = value!),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: statusSelecionado,
                decoration: const InputDecoration(labelText: 'Status inicial'),
                items: statusDisponiveis
                    .map((status) => DropdownMenuItem(value: status, child: Text(status)))
                    .toList(),
                onChanged: (value) => setModalState(() => statusSelecionado = value!),
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
                        final erro = DemandasService.validarDemanda(
                          titulo: tituloController.text,
                          descricao: descricaoController.text,
                        );

                        if (erro != null) {
                          _mostrarFeedback(erro);
                          return;
                        }

                        setState(() {
                          _demandas.insert(
                            0,
                            Demanda(
                              id: DemandasService.gerarProximoIdDemanda(_demandas),
                              titulo: tituloController.text.trim(),
                              descricao: descricaoController.text.trim(),
                              prioridade: prioridadeSelecionada,
                              statusLabel: statusSelecionado,
                              proprietario: proprietarioSelecionado,
                              prazo: DemandasService.dataAtual(),
                            ),
                          );
                        });
                        _saveData();

                        Navigator.pop(context);
                        _mostrarFeedback('Demanda criada com sucesso!');
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

  void _showEditarDemanda(BuildContext context, Demanda demanda) {
    if (!_canManageDemandas(context, actionLabel: 'editar demandas')) return;

    final textTheme = Theme.of(context).textTheme;
    final prioridades = DemandasService.opcoesUnicas(DemandasService.prioridades);
    final proprietarios = DemandasService.opcoesUnicas(DemandasService.proprietarios);
    final statusDisponiveis = DemandasService.opcoesUnicas(DemandasService.statusDisponiveis);
    final prioridadeOptions = DemandasService.opcoesUnicas(
      prioridades,
      primeiro: demanda.prioridade,
    );
    final proprietarioOptions = DemandasService.opcoesUnicas(
      proprietarios,
      primeiro: demanda.proprietario,
    );
    final statusOptions = DemandasService.opcoesUnicas(
      statusDisponiveis,
      primeiro: demanda.statusLabel,
    );
    final tituloController = TextEditingController(text: demanda.titulo);
    final descricaoController = TextEditingController(text: demanda.descricao);
    String prioridadeSelecionada = demanda.prioridade;
    String proprietarioSelecionado = demanda.proprietario;
    String statusSelecionado = demanda.statusLabel;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: const EdgeInsets.all(24),
          height: MediaQuery.of(context).size.height * 0.8,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Editar Demanda', style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    tooltip: 'Fechar edição de demanda',
                    icon: const Icon(Icons.close),
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
                items: prioridadeOptions
                    .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                    .toList(),
                onChanged: (value) => setModalState(() => prioridadeSelecionada = value!),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: proprietarioSelecionado,
                decoration: const InputDecoration(labelText: 'Proprietário'),
                items: proprietarioOptions
                    .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                    .toList(),
                onChanged: (value) => setModalState(() => proprietarioSelecionado = value!),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: statusSelecionado,
                decoration: const InputDecoration(labelText: 'Status'),
                items: statusOptions
                    .map((status) => DropdownMenuItem(value: status, child: Text(status)))
                    .toList(),
                onChanged: (value) => setModalState(() => statusSelecionado = value!),
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
                        final erro = DemandasService.validarDemanda(
                          titulo: tituloController.text,
                          descricao: descricaoController.text,
                        );

                        if (erro != null) {
                          _mostrarFeedback(erro);
                          return;
                        }

                        setState(() {
                          final index = _demandas.indexWhere((item) => item.id == demanda.id);
                          if (index >= 0) {
                            _demandas[index] = demanda.copyWith(
                              titulo: tituloController.text.trim(),
                              descricao: descricaoController.text.trim(),
                              prioridade: prioridadeSelecionada,
                              statusLabel: statusSelecionado,
                              proprietario: proprietarioSelecionado,
                            );
                          }
                        });
                        _saveData();

                        Navigator.pop(context);
                        _mostrarFeedback('Demanda atualizada com sucesso!');
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

  void _showConfirmarExclusao(BuildContext context, Demanda demanda) {
    if (!_canManageDemandas(context, actionLabel: 'excluir demandas')) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar exclusão'),
        content: Text('Tem certeza que deseja excluir ${demanda.titulo}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _demandas.removeWhere((item) => item.id == demanda.id);
              });
              _saveData();
              Navigator.pop(context);
              _mostrarFeedback('Demanda excluída com sucesso!');
            },
            child: const Text('Excluir', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  bool _canManageDemandas(BuildContext context, {required String actionLabel}) {
    final role = context.read<UserContextProvider>().userRole;
    if (AuthorizationPolicy.canManageDemandas(role)) {
      return true;
    }
    AppFeedbackService.warning(context, 'Seu perfil não possui permissão para $actionLabel.');
    return false;
  }
}

class _DemandasCard extends StatelessWidget {
  const _DemandasCard({
    required this.demanda,
    required this.onEditar,
    required this.onExcluir,
  });

  final Demanda demanda;
  final VoidCallback onEditar;
  final VoidCallback onExcluir;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Semantics(
      button: true,
      label: 'Abrir demanda ${demanda.titulo}',
      child: Material(
        color: SigadColors.surface,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
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
                      tooltip: 'Mais ações da demanda',
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
                Flexible(
                  child: Text(
                    demanda.proprietario,
                    style: textTheme.bodySmall?.copyWith(
                      color: SigadColors.muted,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: DemandasService.toneStatus(demanda.statusLabel)
                        .withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    demanda.statusLabel,
                    style: textTheme.labelSmall?.copyWith(
                      color: DemandasService.toneStatus(demanda.statusLabel),
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
                Expanded(
                  child: Text(
                    demanda.prazo,
                    style: textTheme.bodySmall?.copyWith(
                      color: SigadColors.muted,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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

  Color _getPrioridadeColor(String prioridade) {
    return DemandasService.tonePrioridade(prioridade);
  }

  void _onMenuItemSelected(BuildContext context, String value, Demanda demanda) {
    switch (value) {
      case 'editar':
        onEditar();
        break;
      case 'excluir':
        onExcluir();
        break;
    }
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
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    tooltip: 'Fechar detalhes da demanda',
                    icon: const Icon(Icons.close),
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
