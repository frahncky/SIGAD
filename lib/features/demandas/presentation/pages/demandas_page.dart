import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../app/theme/sigad_colors.dart';
import '../../../../app/theme/sigad_icons.dart';
import '../../../../core/security/authorization_policy.dart';
import '../../../../core/services/app_event_logger.dart';
import '../../../../core/services/app_feedback_service.dart';
import '../../../../core/services/user_context_provider.dart';
import '../../../../shared/widgets/icon_avatar.dart';
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
  final List<Demanda> _demandas = List.of(DemandasService.defaultDemandas());

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
      AppEventLogger.error(
        'demandas_load_error',
        error,
        stackTrace: stackTrace,
      );
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

  void _mostrarErro(String mensagem) {
    AppFeedbackService.error(context, mensagem);
  }

  void _mostrarSucesso(String mensagem) {
    AppFeedbackService.success(context, mensagem);
  }

  @override
  Widget build(BuildContext context) {
    final demandasVisiveis = _demandasVisiveis;
    final totalDemandas = _demandas.length;
    final demandasAbertas = _demandas
        .where((d) => d.statusLabel != 'Concluído')
        .length;
    final demandasUrgentes = _demandas
        .where((d) => d.prioridade == 'Alta')
        .length;
    return Scaffold(
      body: CustomScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            sliver: SliverToBoxAdapter(
              child: _DemandasSummaryBanner(
                total: totalDemandas,
                abertas: demandasAbertas,
                urgentes: demandasUrgentes,
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverToBoxAdapter(
              child: Row(
                children: [
                  Expanded(
                    child: Semantics(
                      key: const ValueKey('demandas_search_semantics'),
                      label: 'Buscar demandas',
                      hint: 'Pesquise por título, descrição ou responsável',
                      textField: true,
                      child: TextField(
                        key: const ValueKey('demandas_search_field'),
                        textInputAction: TextInputAction.search,
                        onChanged: (value) => setState(() => _busca = value),
                        onSubmitted: (_) => FocusScope.of(context).unfocus(),
                        decoration: const InputDecoration(
                          labelText: 'Buscar demandas',
                          floatingLabelBehavior: FloatingLabelBehavior.always,
                          hintText: 'Título, descrição ou responsável',
                          prefixIcon: Icon(SigadIcons.buscar),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Tooltip(
                    message: _filtrosAtivos > 0
                        ? 'Filtros ativos: $_filtrosAtivos'
                        : 'Filtrar demandas',
                    child: SizedBox(
                      width: 48,
                      height: 48,
                      child: OutlinedButton(
                        onPressed: () => _showFiltros(context),
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: const Size(48, 48),
                        ),
                        child: const Icon(SigadIcons.filtro),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_isLoading)
            const SliverToBoxAdapter(
              child: PageStatusView.loading(title: 'Carregando demandas...'),
            )
          else if (_loadError != null)
            SliverToBoxAdapter(
              child: PageStatusView.error(
                subtitle: _loadError,
                onAction: _loadData,
              ),
            )
          else if (demandasVisiveis.isEmpty)
            SliverToBoxAdapter(
              child: PageStatusView.empty(
                icon: SigadIcons.caixaEntrada,
                title: 'Nenhuma demanda encontrada',
                subtitle: _filtrosAtivos > 0
                    ? 'Tente limpar os filtros ativos.'
                    : 'Crie uma nova demanda para começar.',
                actionLabel: _filtrosAtivos > 0 ? 'Limpar filtros' : null,
                onAction: _filtrosAtivos > 0 ? _limparFiltros : null,
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  return Padding(
                    padding: EdgeInsets.only(
                      bottom: index == demandasVisiveis.length - 1 ? 0 : 12,
                    ),
                    child: _DemandasCard(
                      demanda: demandasVisiveis[index],
                      onEditar: () =>
                          _showEditarDemanda(context, demandasVisiveis[index]),
                      onExcluir: () => _showConfirmarExclusao(
                        context,
                        demandasVisiveis[index],
                      ),
                    ),
                  );
                }, childCount: demandasVisiveis.length),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCriarDemanda(context),
        tooltip: 'Criar nova demanda',
        backgroundColor: SigadColors.brand,
        foregroundColor: Colors.white,
        child: const Icon(SigadIcons.adicionar),
      ),
    );
  }

  void _showFiltros(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
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
                  Text(
                    'Filtros',
                    style: textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  IconButton(
                    tooltip: 'Fechar filtros',
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(SigadIcons.fechar),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                'Status',
                style: textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: ['Todas', ...DemandasService.statusDisponiveis]
                    .map(
                      (status) => FilterChip(
                        label: Text(status),
                        selected: _filtroStatus == status,
                        onSelected: (selected) {
                          setModalState(
                            () => _filtroStatus = selected ? status : 'Todas',
                          );
                        },
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 24),
              Text(
                'Prioridade',
                style: textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: ['Todas', ...DemandasService.prioridades]
                    .map(
                      (prioridade) => FilterChip(
                        label: Text(prioridade),
                        selected: _filtroPrioridade == prioridade,
                        onSelected: (selected) {
                          setModalState(
                            () => _filtroPrioridade = selected
                                ? prioridade
                                : 'Todas',
                          );
                        },
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 24),
              Text(
                'Ordenação',
                style: textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: DemandasService.opcoesOrdenacao
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
    final tituloController = TextEditingController();
    final descricaoController = TextEditingController();
    String prioridadeSelecionada = 'Média';
    String proprietarioSelecionado = DemandasService.proprietarios.first;
    String statusSelecionado = 'Novo';

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
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Nova Demanda',
                        style: textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      tooltip: 'Fechar formulário da demanda',
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(SigadIcons.fechar),
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
                  isExpanded: true,
                  itemHeight: null,
                  decoration: const InputDecoration(labelText: 'Prioridade'),
                  items: DemandasService.prioridades
                      .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                      .toList(),
                  onChanged: (value) =>
                      setModalState(() => prioridadeSelecionada = value!),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: proprietarioSelecionado,
                  isExpanded: true,
                  itemHeight: null,
                  decoration: const InputDecoration(labelText: 'Proprietário'),
                  items: DemandasService.proprietarios
                      .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                      .toList(),
                  onChanged: (value) =>
                      setModalState(() => proprietarioSelecionado = value!),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: statusSelecionado,
                  isExpanded: true,
                  itemHeight: null,
                  decoration: const InputDecoration(
                    labelText: 'Status inicial',
                  ),
                  items: DemandasService.statusDisponiveis
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
                const SizedBox(height: 24),
                _DemandasFormActions(
                  submitLabel: 'Criar',
                  onCancel: () => Navigator.pop(context),
                  onSubmit: () {
                    final erro = DemandasService.validarDemanda(
                      titulo: tituloController.text,
                      descricao: descricaoController.text,
                    );
                    if (erro != null) {
                      _mostrarErro(erro);
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
                    _mostrarSucesso('Demanda criada com sucesso!');
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showEditarDemanda(BuildContext context, Demanda demanda) {
    if (!_canManageDemandas(context, actionLabel: 'editar demandas')) return;

    final textTheme = Theme.of(context).textTheme;
    final tituloController = TextEditingController(text: demanda.titulo);
    final descricaoController = TextEditingController(text: demanda.descricao);
    String prioridadeSelecionada = demanda.prioridade;
    String proprietarioSelecionado = demanda.proprietario;
    String statusSelecionado = demanda.statusLabel;

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
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Editar Demanda',
                        style: textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      tooltip: 'Fechar formulário da demanda',
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(SigadIcons.fechar),
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
                  isExpanded: true,
                  itemHeight: null,
                  decoration: const InputDecoration(labelText: 'Prioridade'),
                  items: DemandasService.prioridades
                      .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                      .toList(),
                  onChanged: (value) =>
                      setModalState(() => prioridadeSelecionada = value!),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: proprietarioSelecionado,
                  isExpanded: true,
                  itemHeight: null,
                  decoration: const InputDecoration(labelText: 'Proprietário'),
                  items: DemandasService.proprietarios
                      .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                      .toList(),
                  onChanged: (value) =>
                      setModalState(() => proprietarioSelecionado = value!),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: statusSelecionado,
                  isExpanded: true,
                  itemHeight: null,
                  decoration: const InputDecoration(labelText: 'Status'),
                  items: DemandasService.statusDisponiveis
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
                const SizedBox(height: 24),
                _DemandasFormActions(
                  submitLabel: 'Salvar',
                  onCancel: () => Navigator.pop(context),
                  onSubmit: () {
                    final erro = DemandasService.validarDemanda(
                      titulo: tituloController.text,
                      descricao: descricaoController.text,
                    );
                    if (erro != null) {
                      _mostrarErro(erro);
                      return;
                    }
                    setState(() {
                      final index = _demandas.indexWhere(
                        (item) => item.id == demanda.id,
                      );
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
                    _mostrarSucesso('Demanda atualizada com sucesso!');
                  },
                ),
              ],
            ),
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
              _mostrarSucesso('Demanda excluída com sucesso!');
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

  bool _canManageDemandas(BuildContext context, {required String actionLabel}) {
    final role = context.read<UserContextProvider>().userRole;
    if (AuthorizationPolicy.canManageDemandas(role)) {
      return true;
    }
    AppFeedbackService.warning(
      context,
      'Seu perfil não possui permissão para $actionLabel.',
    );
    return false;
  }
}

class _DemandasFormActions extends StatelessWidget {
  const _DemandasFormActions({
    required this.submitLabel,
    required this.onCancel,
    required this.onSubmit,
  });

  final String submitLabel;
  final VoidCallback onCancel;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final textScale = MediaQuery.textScalerOf(context).scale(14) / 14;
        final shouldStack = constraints.maxWidth < 320 || textScale > 1.3;
        final cancelButton = OutlinedButton(
          onPressed: onCancel,
          child: const Text('Cancelar'),
        );
        final submitButton = ElevatedButton(
          onPressed: onSubmit,
          child: Text(submitLabel),
        );

        if (shouldStack) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [cancelButton, const SizedBox(height: 12), submitButton],
          );
        }

        return Row(
          children: [
            Expanded(child: cancelButton),
            const SizedBox(width: 12),
            Expanded(child: submitButton),
          ],
        );
      },
    );
  }
}

class _DemandasSummaryBanner extends StatelessWidget {
  const _DemandasSummaryBanner({
    required this.total,
    required this.abertas,
    required this.urgentes,
  });

  final int total;
  final int abertas;
  final int urgentes;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Container(
      key: const ValueKey('demandas_summary_banner'),
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SigadIconAvatar(icon: SigadIcons.demanda, tone: colors.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Resumo das demandas',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: colors.onSurface,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _DemandasKpi(
                label: 'No total',
                value: '$total',
                color: colors.primary,
              ),
              const SizedBox(width: 8),
              _DemandasKpi(
                label: 'Abertas',
                value: '$abertas',
                color: colors.tertiary,
              ),
              const SizedBox(width: 8),
              _DemandasKpi(
                label: 'Urgentes',
                value: '$urgentes',
                color: colors.error,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DemandasKpi extends StatelessWidget {
  const _DemandasKpi({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: colors.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colors.onSurfaceVariant,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
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
      child: GestureDetector(
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
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
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
                        constraints: const BoxConstraints(
                          minWidth: 200,
                          maxWidth: 280,
                        ),
                        onSelected: (value) =>
                            _onMenuItemSelected(context, value, demanda),
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'editar',
                            child: Text('Editar'),
                          ),
                          const PopupMenuItem(
                            value: 'excluir',
                            child: Text('Excluir'),
                          ),
                        ],
                        icon: Icon(
                          SigadIcons.maisOpcoes,
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
                style: textTheme.bodySmall?.copyWith(color: SigadColors.muted),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              LayoutBuilder(
                builder: (context, constraints) {
                  final textScale =
                      MediaQuery.textScalerOf(context).scale(14) / 14;
                  final shouldStack =
                      constraints.maxWidth < 360 || textScale > 1.3;
                  final owner = Text(
                    demanda.proprietario,
                    style: textTheme.bodySmall?.copyWith(
                      color: SigadColors.muted,
                    ),
                  );
                  final status = Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: DemandasService.toneStatus(
                        demanda.statusLabel,
                      ).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      demanda.statusLabel,
                      style: textTheme.labelSmall?.copyWith(
                        color: DemandasService.toneStatus(demanda.statusLabel),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  );

                  if (shouldStack) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [owner, const SizedBox(height: 8), status],
                    );
                  }

                  return Row(
                    children: [
                      Expanded(child: owner),
                      const SizedBox(width: 8),
                      status,
                    ],
                  );
                },
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    SigadIcons.calendario,
                    size: 16,
                    color: SigadColors.muted,
                  ),
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
    );
  }

  Color _getPrioridadeColor(String prioridade) {
    return DemandasService.tonePrioridade(prioridade);
  }

  void _onMenuItemSelected(
    BuildContext context,
    String value,
    Demanda demanda,
  ) {
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
                  Text(
                    demanda.id,
                    style: textTheme.labelSmall?.copyWith(
                      color: SigadColors.muted,
                    ),
                  ),
                  IconButton(
                    tooltip: 'Fechar detalhes da demanda',
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(SigadIcons.fechar),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: 260, // valor fixo ou ajuste conforme necessário
                child: Text(
                  demanda.titulo,
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ), // fonte menor
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
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
