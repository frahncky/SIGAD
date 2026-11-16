import 'package:flutter/material.dart';
import '../../../../app/theme/sigad_colors.dart';
import '../../../../app/theme/sigad_icon.dart';
import '../../../../app/theme/sigad_icons.dart';
import '../../../../core/services/app_event_logger.dart';
import '../../../../core/services/app_feedback_service.dart';
import '../../../../l10n/l10n.dart';
import '../../../../shared/widgets/page_status_view.dart';
import '../../../../shared/widgets/sigad_sheet.dart';
import '../../../../shared/widgets/work_item_ui.dart';
import '../../../dashboard/domain/dashboard_summary.dart';
import '../../data/atividade_repository.dart';
import '../../domain/atividade_models.dart';
import '../../domain/atividades_service.dart';
import '../atividades_l10n.dart';

class AtividadesPage extends StatefulWidget {
  const AtividadesPage({super.key, this.repository, this.agora});

  final AtividadeRepository? repository;

  /// Data de referência para "na semana" e "atrasadas" (injetável em testes).
  final DateTime? agora;

  @override
  State<AtividadesPage> createState() => _AtividadesPageState();
}

/// Data e hora completas para ordenação; sem data vai para o fim.
DateTime _chaveOrdenacao(Atividade atividade) {
  final data = DashboardSummary.dataDaAtividade(atividade.data);
  if (data == null) return DateTime(2100);
  final hora = AtividadesService.horaDaAtividade(atividade.data);
  return DateTime(
    data.year,
    data.month,
    data.day,
    hora?.hora ?? 0,
    hora?.minuto ?? 0,
  );
}

IconData _iconeStatus(String status) => switch (status) {
  'Concluída' => SigadIcons.concluido,
  'Em progresso' => SigadIcons.progressoTempo,
  'Agendada' => SigadIcons.evento,
  _ => SigadIcons.pendente,
};

class _AtividadesPageState extends State<AtividadesPage> {
  final TextEditingController _buscaController = TextEditingController();
  String _busca = '';
  String _filtro = 'Todas';
  bool _isLoading = true;
  bool _isSaving = false;
  String? _loadError;
  late final AtividadeRepository _atividadeRepository =
      widget.repository ?? AtividadeRepository();
  final List<Atividade> _atividades = [];

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
      final list = await _atividadeRepository.loadAtividades();
      if (!mounted) return;
      setState(() {
        // O que foi carregado é a fonte de verdade, mesmo quando vazio.
        _atividades
          ..clear()
          ..addAll(list);
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
        _loadError = context.l10n.atvErroCarregar;
      });
    }
  }

  /// Grava e só então adota a lista proposta.
  Future<bool> _saveData(List<Atividade> proposed) async {
    if (_isSaving) return false;
    setState(() => _isSaving = true);
    try {
      await _atividadeRepository.saveAtividades(proposed);
      if (!mounted) return false;
      setState(() {
        _atividades
          ..clear()
          ..addAll(proposed);
      });
      return true;
    } catch (error, stackTrace) {
      AppEventLogger.error(
        'atividades_save_error',
        error,
        stackTrace: stackTrace,
      );
      if (mounted) {
        AppFeedbackService.error(context, context.l10n.atvErroSalvar);
      }
      return false;
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  List<Atividade> get _atividadesVisiveis {
    final filtradas = AtividadesService.filtrarAtividades(
      atividades: _atividades,
      busca: _busca,
      filtro: _filtro,
    ).toList();
    // Ordenação estável por data; sem data no fim.
    final indices = {
      for (var i = 0; i < filtradas.length; i++) filtradas[i].id: i,
    };
    filtradas.sort((a, b) {
      final porData = _chaveOrdenacao(a).compareTo(_chaveOrdenacao(b));
      if (porData != 0) return porData;
      return (indices[a.id] ?? 0).compareTo(indices[b.id] ?? 0);
    });
    return filtradas;
  }

  int get _filtrosDoSheet => _filtro == 'Todas' ? 0 : 1;

  bool get _temFiltroOuBusca => _filtrosDoSheet > 0 || _busca.trim().isNotEmpty;

  void _limparFiltros() {
    _buscaController.clear();
    setState(() {
      _busca = '';
      _filtro = 'Todas';
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final agora = _agora;
    final visiveis = _atividadesVisiveis;
    final abertas = _atividades
        .where(DashboardSummary.atividadeEstaAberta)
        .toList();
    final naSemana = DashboardSummary.calcular(
      demandas: const [],
      cards: const [],
      atividades: _atividades,
      laboratorios: const [],
      agora: agora,
    ).atividadesSemana;
    final atrasadas = abertas
        .where(
          (a) =>
              DashboardSummary.situacaoPrazo(a.data, agora) ==
              SituacaoPrazo.atrasada,
        )
        .length;

    return Scaffold(
      body: CustomScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        slivers: [
          if (!_isLoading && _loadError == null)
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              sliver: SliverToBoxAdapter(
                child: SummaryKpiPanel(
                  key: const ValueKey('atividades_summary'),
                  items: [
                    SummaryKpi(
                      label: l10n.atvAbertas,
                      value: abertas.length,
                      tone: SigadColors.brand,
                    ),
                    SummaryKpi(
                      label: l10n.atvNaSemana,
                      value: naSemana,
                      tone: SigadColors.info,
                    ),
                    SummaryKpi(
                      label: l10n.atvAtrasadas,
                      value: atrasadas,
                      risco: atrasadas > 0,
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
                    child: TextField(
                      key: const ValueKey('atividades_search_field'),
                      controller: _buscaController,
                      textInputAction: TextInputAction.search,
                      onChanged: (value) => setState(() => _busca = value),
                      onSubmitted: (_) => FocusScope.of(context).unfocus(),
                      decoration: InputDecoration(
                        labelText: l10n.atvBuscar,
                        floatingLabelBehavior: FloatingLabelBehavior.always,
                        hintText: l10n.atvBuscarDica,
                        prefixIcon: const SigadIcon(SigadIcons.buscar),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  FilterButton(
                    key: const ValueKey('atividades_filter_button'),
                    tooltip: _filtrosDoSheet > 0
                        ? l10n.demFiltrosAtivos(_filtrosDoSheet)
                        : l10n.atvFiltrar,
                    activeCount: _filtrosDoSheet,
                    onPressed: _showFiltroAtividades,
                  ),
                ],
              ),
            ),
          ),
          if (_isLoading)
            SliverToBoxAdapter(
              child: PageStatusView.loading(title: l10n.atvCarregando),
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
          else if (visiveis.isEmpty)
            SliverToBoxAdapter(
              child: PageStatusView.empty(
                icon: SigadIcons.checklist,
                title: l10n.atvNenhuma,
                subtitle: _temFiltroOuBusca
                    ? l10n.demLimparFiltrosDica
                    : l10n.atvCrieNova,
                actionLabel: _temFiltroOuBusca ? l10n.demLimparFiltros : null,
                actionIcon: SigadIcons.filtro,
                onAction: _temFiltroOuBusca ? _limparFiltros : null,
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 96),
              sliver: SliverList.separated(
                itemCount: visiveis.length,
                separatorBuilder: (context, i) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final atividade = visiveis[index];
                  return _AtividadeCard(
                    atividade: atividade,
                    agora: agora,
                    onEditar: () =>
                        _showFormulario(context, atividade: atividade),
                    onExcluir: () => _showConfirmarExclusao(context, atividade),
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
        tooltip: l10n.atvCriarNova,
        backgroundColor: SigadColors.brand,
        foregroundColor: Colors.white,
        child: const SigadIcon(SigadIcons.adicionar),
      ),
    );
  }

  Future<void> _showFiltroAtividades() async {
    final l10n = context.l10n;
    var selecionado = _filtro;
    final resultado = await showSigadSheet<String>(
      context: context,
      builder: (sheetContext) => StatefulBuilder(
        builder: (sheetContext, setSheetState) => SigadSheetFrame(
          title: l10n.atvFiltrar,
          closeTooltip: l10n.atvFecharFiltro,
          onClose: () => Navigator.pop(sheetContext),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SheetSectionTitle(l10n.demStatus),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  for (final opcao in AtividadesService.opcoesFiltro)
                    ChoiceChip(
                      label: Text(
                        opcao == 'Todas'
                            ? l10n.demTodas
                            : l10n.statusAtividade(opcao),
                      ),
                      selected: selecionado == opcao,
                      onSelected: (_) =>
                          setSheetState(() => selecionado = opcao),
                    ),
                ],
              ),
            ],
          ),
          footer: SigadDualActions(
            secondaryLabel: l10n.demLimpar,
            onSecondary: () => Navigator.pop(sheetContext, 'Todas'),
            primaryLabel: l10n.demAplicar,
            onPrimary: () => Navigator.pop(sheetContext, selecionado),
          ),
        ),
      ),
    );
    // Fechar sem aplicar descarta a seleção.
    if (!mounted || resultado == null) return;
    setState(() => _filtro = resultado);
  }

  void _showFormulario(BuildContext context, {Atividade? atividade}) {
    if (_isSaving) return;
    final l10n = context.l10n;
    showSigadSheet<void>(
      context: context,
      dismissible: false,
      builder: (sheetContext) => _AtividadeFormSheet(
        atividade: atividade,
        agora: _agora,
        onSubmit: (dados) async {
          final List<Atividade> proposed;
          if (atividade == null) {
            proposed = List<Atividade>.of(_atividades)
              ..insert(
                0,
                Atividade(
                  id: AtividadesService.gerarProximoIdAtividade(_atividades),
                  titulo: dados.titulo,
                  descricao: dados.descricao,
                  data: dados.data,
                  responsavel: dados.responsavel,
                  status: dados.status,
                ),
              );
          } else {
            proposed = List<Atividade>.of(_atividades);
            final index = proposed.indexWhere((a) => a.id == atividade.id);
            if (index < 0) return false;
            proposed[index] = atividade.copyWith(
              titulo: dados.titulo,
              descricao: dados.descricao,
              data: dados.data,
              responsavel: dados.responsavel,
              status: dados.status,
            );
          }
          final salvo = await _saveData(proposed);
          if (salvo && mounted) {
            AppFeedbackService.success(
              this.context,
              atividade == null ? l10n.atvCriada : l10n.atvAtualizada,
            );
          }
          return salvo;
        },
      ),
    );
  }

  void _showConfirmarExclusao(BuildContext context, Atividade atividade) {
    if (_isSaving) return;
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => PopScope(
          canPop: !_isSaving,
          child: AlertDialog(
            scrollable: true,
            title: Text(dialogContext.l10n.demConfirmarExclusao),
            content: Text(
              dialogContext.l10n.demExcluirMensagem(atividade.titulo),
            ),
            actions: [
              TextButton(
                onPressed: _isSaving
                    ? null
                    : () => Navigator.pop(dialogContext),
                child: Text(dialogContext.l10n.cancelar),
              ),
              TextButton(
                onPressed: _isSaving
                    ? null
                    : () async {
                        final proposed = List<Atividade>.of(_atividades)
                          ..removeWhere((item) => item.id == atividade.id);
                        final pending = _saveData(proposed);
                        setDialogState(() {});
                        final salvo = await pending;
                        if (!dialogContext.mounted) return;
                        setDialogState(() {});
                        if (!salvo) return;
                        Navigator.pop(dialogContext);
                        if (!mounted) return;
                        AppFeedbackService.success(
                          this.context,
                          this.context.l10n.atvExcluida,
                        );
                      },
                child: Text(
                  dialogContext.l10n.excluir,
                  style: TextStyle(
                    color: Theme.of(dialogContext).colorScheme.error,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DadosAtividade {
  const _DadosAtividade({
    required this.titulo,
    required this.descricao,
    required this.data,
    required this.responsavel,
    required this.status,
  });

  final String titulo;
  final String descricao;

  /// `dd/MM/aaaa`, `dd/MM/aaaa - HH:mm` ou vazio (sem data).
  final String data;
  final String responsavel;
  final String status;
}

class _AtividadeFormSheet extends StatefulWidget {
  const _AtividadeFormSheet({
    required this.atividade,
    required this.agora,
    required this.onSubmit,
  });

  final Atividade? atividade;
  final DateTime agora;
  final Future<bool> Function(_DadosAtividade dados) onSubmit;

  @override
  State<_AtividadeFormSheet> createState() => _AtividadeFormSheetState();
}

class _AtividadeFormSheetState extends State<_AtividadeFormSheet> {
  late final TextEditingController _titulo = TextEditingController(
    text: widget.atividade?.titulo,
  );
  late final TextEditingController _descricao = TextEditingController(
    text: widget.atividade?.descricao,
  );
  late final TextEditingController _dataTexto = TextEditingController();
  late final TextEditingController _horaTexto = TextEditingController();
  late String _responsavel =
      widget.atividade?.responsavel ?? AtividadesService.responsaveis.first;
  late String _status = widget.atividade?.status ?? 'Pendente';
  DateTime? _data;
  TimeOfDay? _hora;
  bool _dataAlterada = false;
  String? _erroTitulo;
  String? _erroDescricao;
  bool _enviando = false;

  bool get _editando => widget.atividade != null;

  @override
  void initState() {
    super.initState();
    final original = widget.atividade?.data ?? '';
    _data = DashboardSummary.dataDaAtividade(original);
    final hora = AtividadesService.horaDaAtividade(original);
    if (_data != null && hora != null) {
      _hora = TimeOfDay(hour: hora.hora, minute: hora.minuto);
    }
    if (_data != null) {
      _dataTexto.text = AtividadesService.formatarData(_data);
    } else {
      // Texto legado que não é uma data reconhecida: exibido sem alteração.
      _dataTexto.text = original;
    }
    if (_hora != null) {
      _horaTexto.text = _formatarHora(_hora!);
    }
  }

  @override
  void dispose() {
    _titulo.dispose();
    _descricao.dispose();
    _dataTexto.dispose();
    _horaTexto.dispose();
    super.dispose();
  }

  String _formatarHora(TimeOfDay hora) =>
      '${hora.hour.toString().padLeft(2, '0')}:'
      '${hora.minute.toString().padLeft(2, '0')}';

  Future<void> _escolherData() async {
    final hoje = DateUtils.dateOnly(widget.agora);
    final atual = _data;
    final primeiro = atual != null && atual.isBefore(hoje) ? atual : hoje;
    final escolhida = await showDatePicker(
      context: context,
      initialDate: atual ?? hoje,
      firstDate: primeiro,
      lastDate: DateTime(hoje.year + 10, 12, 31),
      helpText: context.l10n.atvSelecionarData,
    );
    if (escolhida == null || !mounted) return;
    setState(() {
      _data = escolhida;
      _dataAlterada = true;
      _dataTexto.text = AtividadesService.formatarData(escolhida);
    });
  }

  void _removerData() {
    setState(() {
      _data = null;
      _hora = null;
      _dataAlterada = true;
      _dataTexto.clear();
      _horaTexto.clear();
    });
  }

  Future<void> _escolherHora() async {
    if (_data == null) return;
    final escolhida = await showTimePicker(
      context: context,
      initialTime: _hora ?? TimeOfDay.fromDateTime(widget.agora),
      helpText: context.l10n.atvSelecionarHora,
    );
    if (escolhida == null || !mounted) return;
    setState(() {
      _hora = escolhida;
      _dataAlterada = true;
      _horaTexto.text = _formatarHora(escolhida);
    });
  }

  void _removerHora() {
    setState(() {
      _hora = null;
      _dataAlterada = true;
      _horaTexto.clear();
    });
  }

  Future<void> _enviar() async {
    if (_enviando) return;
    final l10n = context.l10n;
    final erroTitulo = AtividadesService.validarTituloAtividade(_titulo.text);
    final erroDescricao = AtividadesService.validarDescricaoAtividade(
      _descricao.text,
    );
    setState(() {
      _erroTitulo = erroTitulo == null ? null : l10n.erroAtividade(erroTitulo);
      _erroDescricao = erroDescricao == null
          ? null
          : l10n.erroAtividade(erroDescricao);
    });
    if (erroTitulo != null || erroDescricao != null) return;

    final data = _dataAlterada || !_editando
        ? AtividadesService.formatarData(
            _data,
            hora: _hora?.hour,
            minuto: _hora?.minute,
          )
        : widget.atividade!.data;
    setState(() => _enviando = true);
    final salvo = await widget.onSubmit(
      _DadosAtividade(
        titulo: _titulo.text.trim(),
        descricao: _descricao.text.trim(),
        data: data,
        responsavel: _responsavel,
        status: _status,
      ),
    );
    if (!mounted) return;
    setState(() => _enviando = false);
    if (salvo) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final temData = _dataTexto.text.trim().isNotEmpty;
    final responsaveis = <String>{
      if (widget.atividade != null) widget.atividade!.responsavel,
      ...AtividadesService.responsaveis,
    }.toList();
    return PopScope(
      canPop: !_enviando,
      child: SigadSheetFrame(
        title: _editando ? l10n.atvEditar : l10n.atvNova,
        closeTooltip: l10n.atvFecharFormulario,
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
                hintText: l10n.atvTituloDica,
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
                hintText: l10n.atvDescricaoDica,
                errorText: _erroDescricao,
                errorMaxLines: 3,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              key: const ValueKey('atividade_data_field'),
              controller: _dataTexto,
              readOnly: true,
              onTap: _enviando ? null : _escolherData,
              decoration: InputDecoration(
                labelText: l10n.atvDataOpcional,
                hintText: l10n.atvSemData,
                floatingLabelBehavior: FloatingLabelBehavior.always,
                prefixIcon: const SigadIcon(SigadIcons.calendario),
                suffixIcon: temData
                    ? IconButton(
                        tooltip: l10n.atvRemoverData,
                        onPressed: _enviando ? null : _removerData,
                        icon: const SigadIcon(SigadIcons.fechar),
                      )
                    : null,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              key: const ValueKey('atividade_hora_field'),
              controller: _horaTexto,
              readOnly: true,
              enabled: _data != null && !_enviando,
              onTap: _escolherHora,
              decoration: InputDecoration(
                labelText: l10n.atvHoraOpcional,
                floatingLabelBehavior: FloatingLabelBehavior.always,
                helperText: _data == null ? l10n.atvHoraSemData : null,
                helperMaxLines: 3,
                prefixIcon: const SigadIcon(SigadIcons.relogio),
                suffixIcon: _hora != null
                    ? IconButton(
                        tooltip: l10n.atvRemoverHora,
                        onPressed: _enviando ? null : _removerHora,
                        icon: const SigadIcon(SigadIcons.fechar),
                      )
                    : null,
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _responsavel,
              isExpanded: true,
              itemHeight: null,
              decoration: InputDecoration(labelText: l10n.atvResponsavel),
              items: responsaveis
                  .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                  .toList(),
              onChanged: _enviando
                  ? null
                  : (value) => setState(() => _responsavel = value!),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _status,
              isExpanded: true,
              itemHeight: null,
              decoration: InputDecoration(
                labelText: _editando ? l10n.demStatus : l10n.demStatusInicial,
              ),
              items: AtividadesService.statusAtividade
                  .map(
                    (status) => DropdownMenuItem(
                      value: status,
                      child: Text(l10n.statusAtividade(status)),
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

/// Rótulo e destaque da data conforme a situação em relação a hoje.
({IconData icone, String curto, String completo, bool risco}) _dataVisual(
  AppLocalizations l10n,
  Atividade atividade,
  DateTime agora,
) {
  final texto = atividade.data.trim();
  if (texto.isEmpty) {
    return (
      icone: SigadIcons.calendario,
      curto: l10n.atvSemData,
      completo: l10n.atvSemData,
      risco: false,
    );
  }
  final data = DashboardSummary.dataDaAtividade(texto);
  final situacao =
      data != null && DashboardSummary.atividadeEstaAberta(atividade)
      ? DashboardSummary.situacaoPrazo(texto, agora)
      : SituacaoPrazo.futura;
  final hora = AtividadesService.horaDaAtividade(texto);
  switch (situacao) {
    case SituacaoPrazo.atrasada:
      final diaMes =
          '${data!.day.toString().padLeft(2, '0')}/'
          '${data.month.toString().padLeft(2, '0')}';
      return (
        icone: SigadIcons.alerta,
        curto: l10n.atvAtrasadaEm(diaMes),
        completo: l10n.atvAtrasadaEm(texto),
        risco: true,
      );
    case SituacaoPrazo.hoje:
      final horario = hora == null
          ? null
          : '${hora.hora.toString().padLeft(2, '0')}:'
                '${hora.minuto.toString().padLeft(2, '0')}';
      return (
        icone: SigadIcons.relogio,
        curto: horario == null ? l10n.vgHoje : l10n.atvHojeEm(horario),
        completo: l10n.atvHojeEm(texto),
        risco: true,
      );
    case SituacaoPrazo.futura:
    case SituacaoPrazo.semData:
      return (
        icone: SigadIcons.calendario,
        curto: texto,
        completo: texto,
        risco: false,
      );
  }
}

class _AtividadeCard extends StatelessWidget {
  const _AtividadeCard({
    required this.atividade,
    required this.agora,
    required this.onEditar,
    required this.onExcluir,
  });

  final Atividade atividade;
  final DateTime agora;
  final VoidCallback onEditar;
  final VoidCallback onExcluir;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final l10n = context.l10n;
    final data = _dataVisual(l10n, atividade, agora);
    return Semantics(
      button: true,
      label: l10n.atvAbrir(atividade.titulo),
      child: SigadSurfaceCard(
        onTap: () => _showDetalhes(context),
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
                          atividade.id,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          atividade.titulo,
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
                  tooltip: l10n.atvMaisAcoes,
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
                            color: Theme.of(context).colorScheme.error,
                            size: 18,
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
                    size: 20,
                    color: colors.onSurfaceVariant,
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
                    atividade.descricao,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 12,
                    runSpacing: 8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      ToneChip(
                        label: l10n.statusAtividade(atividade.status),
                        tone: AtividadesService.statusColor(atividade.status),
                        icon: _iconeStatus(atividade.status),
                      ),
                      MetaLabel(
                        icon: SigadIcons.pessoa,
                        text: atividade.responsavel,
                        semanticLabel:
                            '${l10n.atvResponsavel}: ${atividade.responsavel}',
                      ),
                      MetaLabel(
                        icon: data.icone,
                        text: data.curto,
                        risco: data.risco,
                        semanticLabel: data.risco
                            ? data.completo
                            : l10n.atvDataValor(data.completo),
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

  void _showDetalhes(BuildContext context) {
    final l10n = context.l10n;
    final data = _dataVisual(l10n, atividade, agora);
    showSigadSheet<void>(
      context: context,
      builder: (sheetContext) {
        final theme = Theme.of(sheetContext);
        return SigadSheetFrame(
          leading: Text(
            atividade.id,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          title: atividade.titulo,
          closeTooltip: l10n.atvFecharDetalhes,
          onClose: () => Navigator.pop(sheetContext),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ToneChip(
                label: l10n.statusAtividade(atividade.status),
                tone: AtividadesService.statusColor(atividade.status),
                icon: _iconeStatus(atividade.status),
              ),
              const SizedBox(height: 16),
              DetailRow(label: l10n.demDescricao, value: atividade.descricao),
              DetailRow(
                label: l10n.atvResponsavel,
                value: atividade.responsavel,
              ),
              Text(
                l10n.atvData,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              MetaLabel(
                icon: data.icone,
                text: data.completo,
                risco: data.risco,
              ),
            ],
          ),
          footer: SigadDualActions(
            secondaryLabel: l10n.fechar,
            onSecondary: () => Navigator.pop(sheetContext),
            primaryLabel: l10n.demEditarAcao,
            onPrimary: () {
              Navigator.pop(sheetContext);
              onEditar();
            },
          ),
        );
      },
    );
  }
}
