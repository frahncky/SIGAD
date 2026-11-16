import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../app/theme/sigad_colors.dart';
import '../../../../app/theme/sigad_icon.dart';
import '../../../../app/theme/sigad_icons.dart';
import '../../../../core/security/authorization_policy.dart';
import '../../../../core/services/app_event_logger.dart';
import '../../../../core/services/app_feedback_service.dart';
import '../../../../core/services/user_context_provider.dart';
import '../../../../l10n/l10n.dart';
import '../../../../shared/widgets/page_status_view.dart';
import '../../../../shared/widgets/sigad_sheet.dart';
import '../../../../shared/widgets/work_item_ui.dart';
import '../../../dashboard/domain/dashboard_summary.dart';
import '../../data/demanda_repository.dart';
import '../../domain/demanda_models.dart';
import '../../domain/demandas_service.dart';
import '../demandas_l10n.dart';

class DemandasPage extends StatefulWidget {
  const DemandasPage({super.key, this.repository, this.agora});

  final DemandaRepository? repository;

  /// Data de referência para prazos (injetável em testes).
  final DateTime? agora;

  @override
  State<DemandasPage> createState() => _DemandasPageState();
}

/// Seleção do sheet de filtros, aplicada só ao tocar em "Aplicar".
class _FiltrosDemanda {
  const _FiltrosDemanda({
    this.status = 'Todas',
    this.prioridade = 'Todas',
    this.ordem = 'Prazo mais próximo',
  });

  final String status;
  final String prioridade;
  final String ordem;
}

class _DemandasPageState extends State<DemandasPage> {
  final TextEditingController _buscaController = TextEditingController();
  String _busca = '';
  String _filtroStatus = 'Todas';
  String _filtroPrioridade = 'Todas';
  String _ordemSelecionada = 'Prazo mais próximo';
  bool _isLoading = true;
  String? _loadError;
  late final DemandaRepository _demandaRepository =
      widget.repository ?? DemandaRepository();
  bool _isSaving = false;
  final List<Demanda> _demandas = [];

  DateTime get _agora => widget.agora ?? DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _buscaController.dispose();
    super.dispose();
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
        _demandas
          ..clear()
          ..addAll(list);
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
        _loadError = context.l10n.demErroCarregar;
      });
    }
  }

  Future<bool> _saveData(List<Demanda> proposed) async {
    if (_isSaving) return false;
    setState(() => _isSaving = true);
    try {
      await _demandaRepository.saveDemandas(proposed);
      if (!mounted) return false;
      setState(() {
        _demandas
          ..clear()
          ..addAll(proposed);
      });
      return true;
    } catch (_) {
      if (mounted) {
        _mostrarErro(context.l10n.demErroSalvar);
      }
      return false;
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  List<Demanda> get _demandasFiltradas => DemandasService.filtrarDemandas(
    demandas: _demandas,
    busca: _busca,
    filtroStatus: _filtroStatus,
    filtroPrioridade: _filtroPrioridade,
  );

  /// Filtros ativos, incluindo a busca.
  int get _filtrosAtivos {
    return DemandasService.countFiltrosAtivos(
      filtroStatus: _filtroStatus,
      filtroPrioridade: _filtroPrioridade,
      busca: _busca,
    );
  }

  /// Filtros escolhidos no sheet (sem a busca), exibidos no selo do botão.
  int get _filtrosDoSheet => DemandasService.countFiltrosAtivos(
    filtroStatus: _filtroStatus,
    filtroPrioridade: _filtroPrioridade,
    busca: '',
  );

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
    final l10n = context.l10n;
    final demandasVisiveis = _demandasVisiveis;
    final abertas = _demandas.where(DashboardSummary.demandaEstaAberta);
    final agora = _agora;
    return Scaffold(
      body: CustomScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        slivers: [
          if (!_isLoading && _loadError == null)
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              sliver: SliverToBoxAdapter(
                child: SummaryKpiPanel(
                  key: const ValueKey('demandas_summary_banner'),
                  items: [
                    SummaryKpi(
                      label: l10n.demNoTotal,
                      value: _demandas.length,
                      tone: SigadColors.brand,
                    ),
                    SummaryKpi(
                      label: l10n.demAbertas,
                      value: abertas.length,
                      tone: SigadColors.info,
                    ),
                    SummaryKpi(
                      label: l10n.demPrioridadeAltaKpi,
                      value: abertas
                          .where((d) => d.prioridade == 'Alta')
                          .length,
                      tone: SigadColors.warning,
                    ),
                  ],
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
                      label: l10n.demBuscar,
                      hint: l10n.demBuscarDica,
                      textField: true,
                      child: TextField(
                        key: const ValueKey('demandas_search_field'),
                        controller: _buscaController,
                        textInputAction: TextInputAction.search,
                        onChanged: (value) => setState(() => _busca = value),
                        onSubmitted: (_) => FocusScope.of(context).unfocus(),
                        decoration: InputDecoration(
                          labelText: l10n.demBuscar,
                          floatingLabelBehavior: FloatingLabelBehavior.always,
                          hintText: l10n.demBuscarExemplo,
                          prefixIcon: const SigadIcon(SigadIcons.buscar),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  FilterButton(
                    key: const ValueKey('demandas_filter_button'),
                    tooltip: _filtrosDoSheet > 0
                        ? l10n.demFiltrosAtivos(_filtrosDoSheet)
                        : l10n.demFiltrar,
                    activeCount: _filtrosDoSheet,
                    onPressed: _showFiltros,
                  ),
                ],
              ),
            ),
          ),
          if (_isLoading)
            SliverToBoxAdapter(
              child: PageStatusView.loading(title: l10n.demCarregando),
            )
          else if (_loadError != null)
            SliverToBoxAdapter(
              child: PageStatusView.error(
                title: l10n.demErroCarregarTitulo,
                subtitle: _loadError,
                actionLabel: l10n.tentarNovamente,
                onAction: _loadData,
              ),
            )
          else if (demandasVisiveis.isEmpty)
            SliverToBoxAdapter(
              child: PageStatusView.empty(
                icon: SigadIcons.caixaEntrada,
                title: l10n.demNenhuma,
                subtitle: _filtrosAtivos > 0
                    ? l10n.demLimparFiltrosDica
                    : l10n.demCrieNova,
                actionLabel: _filtrosAtivos > 0 ? l10n.demLimparFiltros : null,
                actionIcon: SigadIcons.filtro,
                onAction: _filtrosAtivos > 0 ? _limparFiltros : null,
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 96),
              sliver: SliverList.separated(
                itemCount: demandasVisiveis.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final demanda = demandasVisiveis[index];
                  return _DemandasCard(
                    demanda: demanda,
                    agora: agora,
                    onEditar: () => _showFormulario(context, demanda: demanda),
                    onExcluir: () => _showConfirmarExclusao(context, demanda),
                  );
                },
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _isLoading || _loadError != null || _isSaving
            ? null
            : () => _showFormulario(context),
        tooltip: l10n.demCriarNova,
        backgroundColor: SigadColors.brand,
        foregroundColor: Colors.white,
        child: const SigadIcon(SigadIcons.adicionar),
      ),
    );
  }

  Future<void> _showFiltros() async {
    final l10n = context.l10n;
    var status = _filtroStatus;
    var prioridade = _filtroPrioridade;
    var ordem = _ordemSelecionada;

    final resultado = await showSigadSheet<_FiltrosDemanda>(
      context: context,
      builder: (sheetContext) => StatefulBuilder(
        builder: (sheetContext, setSheetState) {
          Widget grupo(
            String titulo,
            List<String> opcoes,
            String selecionado,
            ValueChanged<String> onSelecionar,
          ) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SheetSectionTitle(titulo),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    for (final opcao in opcoes)
                      ChoiceChip(
                        label: Text(l10n.opcaoDemanda(opcao)),
                        selected: selecionado == opcao,
                        onSelected: (_) =>
                            setSheetState(() => onSelecionar(opcao)),
                      ),
                  ],
                ),
              ],
            );
          }

          return SigadSheetFrame(
            title: l10n.demFiltros,
            closeTooltip: l10n.demFecharFiltros,
            onClose: () => Navigator.pop(sheetContext),
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                grupo(
                  l10n.demStatus,
                  ['Todas', ...DemandasService.statusDisponiveis],
                  status,
                  (valor) => status = valor,
                ),
                const SizedBox(height: 20),
                grupo(
                  l10n.demPrioridade,
                  ['Todas', ...DemandasService.prioridades],
                  prioridade,
                  (valor) => prioridade = valor,
                ),
                const SizedBox(height: 20),
                grupo(
                  l10n.demOrdenacao,
                  DemandasService.opcoesOrdenacao,
                  ordem,
                  (valor) => ordem = valor,
                ),
              ],
            ),
            footer: SigadDualActions(
              secondaryLabel: l10n.demLimpar,
              onSecondary: () =>
                  Navigator.pop(sheetContext, const _FiltrosDemanda()),
              primaryLabel: l10n.demAplicar,
              onPrimary: () => Navigator.pop(
                sheetContext,
                _FiltrosDemanda(
                  status: status,
                  prioridade: prioridade,
                  ordem: ordem,
                ),
              ),
            ),
          );
        },
      ),
    );

    // Fechar pelo X, pelo voltar ou tocando fora descarta a seleção.
    if (!mounted || resultado == null) return;
    setState(() {
      _filtroStatus = resultado.status;
      _filtroPrioridade = resultado.prioridade;
      _ordemSelecionada = resultado.ordem;
    });
  }

  void _limparFiltros() {
    _buscaController.clear();
    setState(() {
      _busca = '';
      _filtroStatus = 'Todas';
      _filtroPrioridade = 'Todas';
      _ordemSelecionada = 'Prazo mais próximo';
    });
  }

  void _showFormulario(BuildContext context, {Demanda? demanda}) {
    final l10n = context.l10n;
    final editando = demanda != null;
    if (_isSaving ||
        !_canManageDemandas(
          context,
          mensagem: editando
              ? l10n.demSemPermissaoEditar
              : l10n.demSemPermissaoCriar,
        )) {
      return;
    }

    showSigadSheet<void>(
      context: context,
      dismissible: false,
      builder: (sheetContext) => _DemandaFormSheet(
        demanda: demanda,
        agora: _agora,
        onSubmit: (dados) async {
          final List<Demanda> proposed;
          if (demanda == null) {
            proposed = List<Demanda>.of(_demandas)
              ..insert(
                0,
                Demanda(
                  id: DemandasService.gerarProximoIdDemanda(_demandas),
                  titulo: dados.titulo,
                  descricao: dados.descricao,
                  prioridade: dados.prioridade,
                  statusLabel: dados.status,
                  proprietario: dados.proprietario,
                  prazo: dados.prazo,
                ),
              );
          } else {
            proposed = List<Demanda>.of(_demandas);
            final index = proposed.indexWhere((item) => item.id == demanda.id);
            if (index < 0) return false;
            proposed[index] = demanda.copyWith(
              titulo: dados.titulo,
              descricao: dados.descricao,
              prioridade: dados.prioridade,
              statusLabel: dados.status,
              proprietario: dados.proprietario,
              prazo: dados.prazo,
            );
          }
          final saved = await _saveData(proposed);
          if (saved && mounted) {
            _mostrarSucesso(editando ? l10n.demAtualizada : l10n.demCriada);
          }
          return saved;
        },
      ),
    );
  }

  void _showConfirmarExclusao(BuildContext context, Demanda demanda) {
    if (_isSaving ||
        !_canManageDemandas(
          context,
          mensagem: context.l10n.demSemPermissaoExcluir,
        )) {
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => PopScope(
          canPop: !_isSaving,
          child: AlertDialog(
            scrollable: true,
            title: Text(context.l10n.demConfirmarExclusao),
            content: Text(context.l10n.demExcluirMensagem(demanda.titulo)),
            actions: [
              TextButton(
                onPressed: _isSaving ? null : () => Navigator.pop(context),
                child: Text(context.l10n.cancelar),
              ),
              TextButton(
                onPressed: _isSaving
                    ? null
                    : () async {
                        final proposed = List<Demanda>.of(_demandas)
                          ..removeWhere((item) => item.id == demanda.id);
                        final pending = _saveData(proposed);
                        setModalState(() {});
                        final saved = await pending;
                        if (!context.mounted) return;
                        setModalState(() {});
                        if (!saved) return;
                        Navigator.pop(context);
                        _mostrarSucesso(context.l10n.demExcluida);
                      },
                child: Text(
                  context.l10n.excluir,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool _canManageDemandas(BuildContext context, {required String mensagem}) {
    final role = context.read<UserContextProvider>().userRole;
    if (AuthorizationPolicy.canManageDemandas(role)) {
      return true;
    }
    AppFeedbackService.warning(context, mensagem);
    return false;
  }
}

/// Dados preenchidos no formulário de demanda.
class _DadosDemanda {
  const _DadosDemanda({
    required this.titulo,
    required this.descricao,
    required this.prioridade,
    required this.proprietario,
    required this.status,
    required this.prazo,
  });

  final String titulo;
  final String descricao;
  final String prioridade;
  final String proprietario;
  final String status;

  /// `dd/MM/aaaa` ou vazio (sem prazo).
  final String prazo;
}

/// Formulário de criação/edição. Mantém os controladores e o estado de
/// envio; a gravação é feita pela página através de [onSubmit].
class _DemandaFormSheet extends StatefulWidget {
  const _DemandaFormSheet({
    required this.demanda,
    required this.agora,
    required this.onSubmit,
  });

  final Demanda? demanda;
  final DateTime agora;
  final Future<bool> Function(_DadosDemanda dados) onSubmit;

  @override
  State<_DemandaFormSheet> createState() => _DemandaFormSheetState();
}

class _DemandaFormSheetState extends State<_DemandaFormSheet> {
  late final TextEditingController _titulo = TextEditingController(
    text: widget.demanda?.titulo,
  );
  late final TextEditingController _descricao = TextEditingController(
    text: widget.demanda?.descricao,
  );
  late final TextEditingController _prazoTexto = TextEditingController(
    text: widget.demanda?.prazo,
  );
  late String _prioridade = widget.demanda?.prioridade ?? 'Média';
  late String _proprietario =
      widget.demanda?.proprietario ?? DemandasService.proprietarios.first;
  late String _status = widget.demanda?.statusLabel ?? 'Novo';
  late DateTime? _prazo = widget.demanda == null
      ? null
      : DashboardSummary.dataDaAtividade(widget.demanda!.prazo);
  bool _prazoAlterado = false;
  String? _erroTitulo;
  String? _erroDescricao;
  bool _enviando = false;

  bool get _editando => widget.demanda != null;

  @override
  void dispose() {
    _titulo.dispose();
    _descricao.dispose();
    _prazoTexto.dispose();
    super.dispose();
  }

  Future<void> _escolherPrazo() async {
    final hoje = DateUtils.dateOnly(widget.agora);
    final atual = _prazo;
    final primeiro = atual != null && atual.isBefore(hoje) ? atual : hoje;
    final escolhido = await showDatePicker(
      context: context,
      initialDate: atual ?? hoje,
      firstDate: primeiro,
      lastDate: DateTime(hoje.year + 10, 12, 31),
      helpText: context.l10n.demSelecionarPrazo,
    );
    if (escolhido == null || !mounted) return;
    setState(() {
      _prazo = escolhido;
      _prazoAlterado = true;
      _prazoTexto.text = DemandasService.formatarPrazo(escolhido);
    });
  }

  void _removerPrazo() {
    setState(() {
      _prazo = null;
      _prazoAlterado = true;
      _prazoTexto.clear();
    });
  }

  Future<void> _enviar() async {
    if (_enviando) return;
    final l10n = context.l10n;
    final erroTitulo = DemandasService.validarTituloDemanda(_titulo.text);
    final erroDescricao = DemandasService.validarDescricaoDemanda(
      _descricao.text,
    );
    setState(() {
      _erroTitulo = erroTitulo == null ? null : l10n.erroDemanda(erroTitulo);
      _erroDescricao = erroDescricao == null
          ? null
          : l10n.erroDemanda(erroDescricao);
    });
    if (erroTitulo != null || erroDescricao != null) return;

    final prazo = _prazoAlterado || !_editando
        ? (_prazo == null ? '' : DemandasService.formatarPrazo(_prazo!))
        : widget.demanda!.prazo;
    setState(() => _enviando = true);
    final salvo = await widget.onSubmit(
      _DadosDemanda(
        titulo: _titulo.text.trim(),
        descricao: _descricao.text.trim(),
        prioridade: _prioridade,
        proprietario: _proprietario,
        status: _status,
        prazo: prazo,
      ),
    );
    if (!mounted) return;
    setState(() => _enviando = false);
    if (salvo) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final temPrazo = _prazoTexto.text.trim().isNotEmpty;
    return PopScope(
      canPop: !_enviando,
      child: SigadSheetFrame(
        title: _editando ? l10n.demEditar : l10n.demNova,
        closeTooltip: l10n.demFecharFormulario,
        onClose: _enviando ? null : () => Navigator.pop(context),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _titulo,
              textInputAction: TextInputAction.next,
              textCapitalization: TextCapitalization.sentences,
              onChanged: (_) {
                if (_erroTitulo != null) setState(() => _erroTitulo = null);
              },
              decoration: InputDecoration(
                labelText: l10n.demTitulo,
                hintText: l10n.demTituloDica,
                errorText: _erroTitulo,
                errorMaxLines: 3,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descricao,
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
              onChanged: (_) {
                if (_erroDescricao != null) {
                  setState(() => _erroDescricao = null);
                }
              },
              decoration: InputDecoration(
                labelText: l10n.demDescricao,
                hintText: l10n.demDescricaoDica,
                errorText: _erroDescricao,
                errorMaxLines: 3,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              key: const ValueKey('demanda_prazo_field'),
              controller: _prazoTexto,
              readOnly: true,
              onTap: _enviando ? null : _escolherPrazo,
              decoration: InputDecoration(
                labelText: l10n.demPrazoOpcional,
                hintText: l10n.demSemPrazo,
                floatingLabelBehavior: FloatingLabelBehavior.always,
                prefixIcon: const SigadIcon(SigadIcons.calendario),
                suffixIcon: temPrazo
                    ? IconButton(
                        tooltip: l10n.demRemoverPrazo,
                        onPressed: _enviando ? null : _removerPrazo,
                        icon: const SigadIcon(SigadIcons.fechar),
                      )
                    : null,
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _prioridade,
              isExpanded: true,
              itemHeight: null,
              decoration: InputDecoration(labelText: l10n.demPrioridade),
              items: DemandasService.prioridades
                  .map(
                    (p) => DropdownMenuItem(
                      value: p,
                      child: Text(l10n.opcaoDemanda(p)),
                    ),
                  )
                  .toList(),
              onChanged: _enviando
                  ? null
                  : (value) => setState(() => _prioridade = value!),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _proprietario,
              isExpanded: true,
              itemHeight: null,
              decoration: InputDecoration(labelText: l10n.demProprietario),
              items: DemandasService.opcoesUnicas(
                DemandasService.proprietarios,
                primeiro: widget.demanda?.proprietario,
              ).map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
              onChanged: _enviando
                  ? null
                  : (value) => setState(() => _proprietario = value!),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _status,
              isExpanded: true,
              itemHeight: null,
              decoration: InputDecoration(
                labelText: _editando ? l10n.demStatus : l10n.demStatusInicial,
              ),
              items: DemandasService.statusDisponiveis
                  .map(
                    (status) => DropdownMenuItem(
                      value: status,
                      child: Text(l10n.opcaoDemanda(status)),
                    ),
                  )
                  .toList(),
              onChanged: _enviando
                  ? null
                  : (value) => setState(() => _status = value!),
            ),
            const SizedBox(height: 24),
            SigadDualActions(
              secondaryLabel: l10n.cancelar,
              onSecondary: _enviando ? null : () => Navigator.pop(context),
              primaryLabel: _enviando
                  ? l10n.demSalvando
                  : (_editando ? l10n.salvar : l10n.demCriar),
              onPrimary: _enviando ? null : _enviar,
            ),
          ],
        ),
      ),
    );
  }
}

/// Rótulo e destaque do prazo conforme a situação em relação a hoje.
({IconData icone, String texto, bool risco, bool hoje}) _prazoVisual(
  AppLocalizations l10n,
  Demanda demanda,
  DateTime agora,
) {
  if (!DemandasService.temPrazo(demanda.prazo)) {
    return (
      icone: SigadIcons.calendario,
      texto: l10n.demSemPrazo,
      risco: false,
      hoje: false,
    );
  }
  // Demanda concluída não fica "atrasada".
  final situacao = DashboardSummary.demandaEstaAberta(demanda)
      ? DashboardSummary.situacaoPrazo(demanda.prazo, agora)
      : SituacaoPrazo.futura;
  return switch (situacao) {
    SituacaoPrazo.atrasada => (
      icone: SigadIcons.alerta,
      texto: l10n.demAtrasadaEm(demanda.prazo),
      risco: true,
      hoje: false,
    ),
    SituacaoPrazo.hoje => (
      icone: SigadIcons.relogio,
      texto: l10n.demVenceHoje,
      risco: true,
      hoje: true,
    ),
    _ => (
      icone: SigadIcons.calendario,
      texto: demanda.prazo,
      risco: false,
      hoje: false,
    ),
  };
}

class _DemandasCard extends StatelessWidget {
  const _DemandasCard({
    required this.demanda,
    required this.agora,
    required this.onEditar,
    required this.onExcluir,
  });

  final Demanda demanda;
  final DateTime agora;
  final VoidCallback onEditar;
  final VoidCallback onExcluir;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final l10n = context.l10n;
    final prazo = _prazoVisual(l10n, demanda, agora);
    return Semantics(
      button: true,
      label: l10n.demAbrir(demanda.titulo),
      child: SigadSurfaceCard(
        onTap: () => _showDetalhesDemanda(context),
        padding: const EdgeInsets.fromLTRB(16, 12, 4, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          demanda.id,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          demanda.titulo,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
                PopupMenuButton<String>(
                  constraints: const BoxConstraints(
                    minWidth: 200,
                    maxWidth: 280,
                  ),
                  onSelected: (value) {
                    if (value == 'editar') onEditar();
                    if (value == 'excluir') onExcluir();
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'editar',
                      child: Row(
                        children: [
                          const SigadIcon(SigadIcons.editar, size: 18),
                          const SizedBox(width: 8),
                          Flexible(child: Text(l10n.demEditarAcao)),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'excluir',
                      child: Row(
                        children: [
                          SigadIcon(
                            SigadIcons.excluir,
                            size: 18,
                            color: Theme.of(context).colorScheme.error,
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              l10n.excluir,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.error,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  icon: SigadIcon(
                    SigadIcons.maisOpcoes,
                    color: colors.onSurfaceVariant,
                    size: 20,
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text(
                    demanda.descricao,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      PriorityBadge(
                        prioridade: demanda.prioridade,
                        label: l10n.opcaoDemanda(demanda.prioridade),
                        semanticLabel:
                            '${l10n.demPrioridade}: '
                            '${l10n.opcaoDemanda(demanda.prioridade)}',
                      ),
                      ToneChip(
                        label: l10n.opcaoDemanda(demanda.statusLabel),
                        tone: DemandasService.toneStatus(demanda.statusLabel),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 16,
                    runSpacing: 6,
                    children: [
                      MetaLabel(
                        icon: SigadIcons.pessoa,
                        text: demanda.proprietario,
                        semanticLabel:
                            '${l10n.demProprietario}: ${demanda.proprietario}',
                      ),
                      MetaLabel(
                        icon: prazo.icone,
                        text: prazo.texto,
                        risco: prazo.risco,
                        semanticLabel: prazo.risco
                            ? prazo.texto
                            : l10n.demPrazoValor(prazo.texto),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDetalhesDemanda(BuildContext context) {
    final l10n = context.l10n;
    final prazo = _prazoVisual(l10n, demanda, agora);
    showSigadSheet<void>(
      context: context,
      builder: (sheetContext) => SigadSheetFrame(
        leading: Text(
          demanda.id,
          style: Theme.of(sheetContext).textTheme.labelSmall?.copyWith(
            color: Theme.of(sheetContext).colorScheme.onSurfaceVariant,
          ),
        ),
        title: demanda.titulo,
        closeTooltip: l10n.demFecharDetalhes,
        onClose: () => Navigator.pop(sheetContext),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                PriorityBadge(
                  prioridade: demanda.prioridade,
                  label: l10n.opcaoDemanda(demanda.prioridade),
                ),
                ToneChip(
                  label: l10n.opcaoDemanda(demanda.statusLabel),
                  tone: DemandasService.toneStatus(demanda.statusLabel),
                ),
              ],
            ),
            const SizedBox(height: 16),
            DetailRow(label: l10n.demDescricao, value: demanda.descricao),
            DetailRow(label: l10n.demProprietario, value: demanda.proprietario),
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.demPrazo,
                    style: Theme.of(sheetContext).textTheme.labelSmall
                        ?.copyWith(
                          color: Theme.of(
                            sheetContext,
                          ).colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 4),
                  MetaLabel(
                    icon: prazo.icone,
                    text: prazo.hoje
                        ? '${prazo.texto} · ${demanda.prazo}'
                        : prazo.texto,
                    risco: prazo.risco,
                  ),
                ],
              ),
            ),
          ],
        ),
        footer: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => Navigator.pop(sheetContext),
            child: Text(l10n.fechar),
          ),
        ),
      ),
    );
  }
}
