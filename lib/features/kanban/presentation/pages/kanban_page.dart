import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import '../../../../app/theme/sigad_colors.dart';
import '../../../../app/theme/sigad_icon.dart';
import '../../../../app/theme/sigad_icons.dart';
import '../../../../app/theme/sigad_tone_palette.dart';
import '../../../../core/services/app_event_logger.dart';
import '../../../../core/services/app_feedback_service.dart';
import '../../../../l10n/l10n.dart';
import '../../../../shared/widgets/horizontal_scroll_hint.dart';
import '../../../../shared/widgets/page_status_view.dart';
import '../../../../shared/widgets/sigad_sheet.dart';
import '../../../../shared/widgets/work_item_ui.dart';
import '../../data/kanban_repository.dart';
import '../../domain/kanban_models.dart';
import '../../domain/kanban_service.dart';
import '../kanban_l10n.dart';

typedef _MoverCard = void Function(KanbanCardModel card, String destino);

class KanbanPage extends StatefulWidget {
  const KanbanPage({super.key, this.repository});

  final KanbanRepository? repository;

  /// Abaixo desta largura o quadro mostra uma coluna por vez.
  static const larguraCompacta = 600.0;

  @override
  State<KanbanPage> createState() => _KanbanPageState();
}

class _KanbanPageState extends State<KanbanPage> {
  late final KanbanRepository _kanbanRepository =
      widget.repository ?? KanbanRepository();
  final List<KanbanCardModel> _cards = [];
  bool _isLoading = true;
  bool _isSaving = false;
  bool _arrastando = false;
  String? _loadError;
  String _colunaSelecionada = KanbanService.colunas.first;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _loadError = null;
    });
    try {
      final list = await _kanbanRepository.loadCards();
      if (!mounted) return;
      setState(() {
        // O que foi carregado é a fonte de verdade, mesmo quando vazio.
        _cards
          ..clear()
          ..addAll(list);
        _isLoading = false;
      });
    } catch (error, stackTrace) {
      AppEventLogger.error('kanban_load_error', error, stackTrace: stackTrace);
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _loadError = context.l10n.tarErroCarregar;
      });
    }
  }

  /// Grava a lista proposta e só então a adota como estado da tela.
  Future<bool> _salvar(List<KanbanCardModel> proposta) async {
    if (_isSaving) return false;
    setState(() => _isSaving = true);
    try {
      await _kanbanRepository.saveCards(proposta);
      if (!mounted) return false;
      setState(() {
        _cards
          ..clear()
          ..addAll(proposta);
      });
      return true;
    } catch (error, stackTrace) {
      AppEventLogger.error('kanban_save_error', error, stackTrace: stackTrace);
      if (mounted) {
        AppFeedbackService.error(context, context.l10n.tarErroSalvar);
      }
      return false;
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  /// Move a tarefa imediatamente e desfaz se a gravação falhar.
  Future<void> _moveCard(KanbanCardModel card, String novaColuna) async {
    if (_isSaving || card.coluna == novaColuna) return;
    final l10n = context.l10n;
    final anterior = List<KanbanCardModel>.of(_cards);
    final proposta = [
      for (final item in _cards)
        item.id == card.id ? KanbanService.moverCard(item, novaColuna) : item,
    ];
    setState(() {
      _isSaving = true;
      _cards
        ..clear()
        ..addAll(proposta);
    });
    try {
      await _kanbanRepository.saveCards(proposta);
      if (!mounted) return;
      AppFeedbackService.success(
        context,
        l10n.tarMovida(l10n.opcaoKanban(novaColuna)),
      );
    } catch (error, stackTrace) {
      AppEventLogger.error('kanban_move_error', error, stackTrace: stackTrace);
      if (!mounted) return;
      setState(() {
        _cards
          ..clear()
          ..addAll(anterior);
      });
      AppFeedbackService.error(context, l10n.tarErroSalvar);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _deleteCard(KanbanCardModel card) async {
    if (_isSaving) return;
    final l10n = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        scrollable: true,
        title: Text(l10n.demConfirmarExclusao),
        content: Text(l10n.tarExcluirCardMensagem(card.titulo)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.cancelar),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              l10n.excluir,
              style: TextStyle(color: Theme.of(ctx).colorScheme.error),
            ),
          ),
        ],
      ),
    );
    if (!mounted || confirmed != true) return;
    final proposta = List<KanbanCardModel>.of(_cards)
      ..removeWhere((c) => c.id == card.id);
    final salvo = await _salvar(proposta);
    if (!mounted || !salvo) return;
    AppFeedbackService.info(context, l10n.tarCardRemovido(card.titulo));
  }

  Future<void> _showMoverPara(KanbanCardModel card) async {
    final l10n = context.l10n;
    final colunas = KanbanService.buildColunas(_cards);
    final destino = await showSigadSheet<String>(
      context: context,
      builder: (sheetContext) => SigadSheetFrame(
        title: l10n.tarMoverPara,
        closeTooltip: l10n.fechar,
        onClose: () => Navigator.pop(sheetContext),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final coluna in KanbanService.colunas)
              if (coluna != card.coluna)
                ListTile(
                  minTileHeight: 56,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  leading: const SigadIcon(SigadIcons.setaDireita),
                  title: Text(l10n.opcaoKanban(coluna)),
                  subtitle: Text(
                    l10n.tarQuantidade(colunas[coluna]?.length ?? 0),
                  ),
                  onTap: () => Navigator.pop(sheetContext, coluna),
                ),
          ],
        ),
      ),
    );
    if (!mounted || destino == null) return;
    await _moveCard(card, destino);
  }

  void _setArrastando(bool valor) {
    if (_arrastando != valor) setState(() => _arrastando = valor);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final Widget body;
    if (_isLoading) {
      body = PageStatusView.loading(title: l10n.tarCarregando);
    } else if (_loadError != null) {
      body = PageStatusView.error(
        title: l10n.demErroCarregarTitulo,
        subtitle: _loadError,
        actionLabel: l10n.tentarNovamente,
        onAction: _loadData,
      );
    } else if (_cards.isEmpty) {
      // O botão + flutuante é a única ação de criar, citada na dica.
      body = PageStatusView.empty(
        icon: SigadIcons.kanban,
        title: l10n.tarNenhumCard,
        subtitle: l10n.tarNenhumCardDica,
      );
    } else {
      body = LayoutBuilder(
        builder: (context, constraints) =>
            constraints.maxWidth < KanbanPage.larguraCompacta
            ? _buildCompacto(context)
            : _buildLargo(context, constraints.maxWidth),
      );
    }

    return Scaffold(
      body: body,
      floatingActionButton: FloatingActionButton(
        onPressed: _isLoading || _loadError != null || _isSaving
            ? null
            : () => _showCriarCard(context),
        tooltip: l10n.tarNovoCard,
        backgroundColor: SigadColors.brand,
        foregroundColor: Colors.white,
        child: const SigadIcon(SigadIcons.adicionar),
      ),
    );
  }

  /// Uma coluna por vez, com seletor rolável de colunas.
  Widget _buildCompacto(BuildContext context) {
    final l10n = context.l10n;
    final colunas = KanbanService.buildColunas(_cards);
    final selecionada = _colunaSelecionada;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          container: true,
          label: l10n.tarColunasDoQuadro,
          child: SingleChildScrollView(
            key: const ValueKey('kanban_column_selector'),
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Row(
              children: [
                for (final coluna in KanbanService.colunas)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: DragTarget<KanbanCardModel>(
                      onWillAcceptWithDetails: (details) =>
                          details.data.coluna != coluna,
                      onAcceptWithDetails: (details) =>
                          _moveCard(details.data, coluna),
                      builder: (context, candidatos, _) => ChoiceChip(
                        label: Text(
                          l10n.tarColunaContagem(
                            l10n.opcaoKanban(coluna),
                            colunas[coluna]?.length ?? 0,
                          ),
                        ),
                        selected: coluna == selecionada,
                        side: candidatos.isNotEmpty
                            ? BorderSide(
                                color: Theme.of(context).colorScheme.primary,
                                width: 2,
                              )
                            : null,
                        onSelected: (_) =>
                            setState(() => _colunaSelecionada = coluna),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        Expanded(
          child: _KanbanColuna(
            key: ValueKey('kanban_coluna_$selecionada'),
            titulo: selecionada,
            cards: colunas[selecionada] ?? const [],
            arrastando: _arrastando,
            compacta: true,
            dica: l10n.tarSegureParaMover,
            onCardMoved: _moveCard,
            onMoverPara: _showMoverPara,
            onCardDeleted: _deleteCard,
            onArrastando: _setArrastando,
          ),
        ),
      ],
    );
  }

  /// Colunas lado a lado, com largura entre 260 e 320.
  Widget _buildLargo(BuildContext context, double larguraDisponivel) {
    final l10n = context.l10n;
    final entries = KanbanService.buildColunas(_cards).entries.toList();
    const espaco = 12.0;
    const margem = 16.0;
    final n = entries.length;
    final largura = ((larguraDisponivel - margem * 2 - espaco * (n - 1)) / n)
        .clamp(260.0, 320.0);
    final larguraTotal = largura * n + espaco * (n - 1) + margem * 2;
    return Column(
      children: [
        if (larguraTotal > larguraDisponivel)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: HorizontalScrollHint(message: l10n.tarArrasteDica),
          ),
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(
              horizontal: margem,
              vertical: 12,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var index = 0; index < n; index++) ...[
                  if (index > 0) const SizedBox(width: espaco),
                  SizedBox(
                    width: largura,
                    child: _KanbanColuna(
                      titulo: entries[index].key,
                      cards: entries[index].value,
                      tone: sigadToneForIndex(index),
                      arrastando: _arrastando,
                      onCardMoved: _moveCard,
                      onMoverPara: _showMoverPara,
                      onCardDeleted: _deleteCard,
                      onArrastando: _setArrastando,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showCriarCard(BuildContext context) {
    if (_isSaving) return;
    final l10n = context.l10n;
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => _NovaTarefaDialog(
        colunaInicial: _colunaSelecionada,
        onSubmit: (titulo, prioridade, coluna) async {
          final proposta = List<KanbanCardModel>.of(_cards)
            ..add(
              KanbanCardModel(
                id: KanbanService.nextId(_cards),
                titulo: titulo,
                coluna: coluna,
                prioridade: prioridade,
              ),
            );
          final salvo = await _salvar(proposta);
          if (salvo && mounted) {
            setState(() => _colunaSelecionada = coluna);
            AppFeedbackService.success(this.context, l10n.tarCardCriado);
          }
          return salvo;
        },
      ),
    );
  }
}

class _NovaTarefaDialog extends StatefulWidget {
  const _NovaTarefaDialog({
    required this.colunaInicial,
    required this.onSubmit,
  });

  final String colunaInicial;
  final Future<bool> Function(String titulo, String prioridade, String coluna)
  onSubmit;

  @override
  State<_NovaTarefaDialog> createState() => _NovaTarefaDialogState();
}

class _NovaTarefaDialogState extends State<_NovaTarefaDialog> {
  final TextEditingController _titulo = TextEditingController();
  String _prioridade = 'Média';
  late String _coluna = widget.colunaInicial;
  String? _erro;
  bool _enviando = false;

  @override
  void dispose() {
    _titulo.dispose();
    super.dispose();
  }

  Future<void> _enviar() async {
    if (_enviando) return;
    final erro = KanbanService.validateTitulo(_titulo.text);
    if (erro != null) {
      setState(() => _erro = context.l10n.erroKanban(erro));
      return;
    }
    setState(() => _enviando = true);
    final salvo = await widget.onSubmit(
      _titulo.text.trim(),
      _prioridade,
      _coluna,
    );
    if (!mounted) return;
    setState(() => _enviando = false);
    if (salvo) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return PopScope(
      canPop: !_enviando,
      child: AlertDialog(
        scrollable: true,
        title: Text(l10n.tarNovoCard),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _titulo,
              autofocus: true,
              textCapitalization: TextCapitalization.sentences,
              onChanged: (_) {
                if (_erro != null) setState(() => _erro = null);
              },
              onSubmitted: (_) => _enviar(),
              decoration: InputDecoration(
                labelText: l10n.demTitulo,
                hintText: l10n.tarTituloDica,
                errorText: _erro,
                errorMaxLines: 3,
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _prioridade,
              isExpanded: true,
              itemHeight: null,
              decoration: InputDecoration(labelText: l10n.demPrioridade),
              items: KanbanService.prioridades
                  .map(
                    (p) => DropdownMenuItem(
                      value: p,
                      child: Text(l10n.opcaoKanban(p)),
                    ),
                  )
                  .toList(),
              onChanged: _enviando
                  ? null
                  : (value) => setState(() => _prioridade = value!),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _coluna,
              isExpanded: true,
              itemHeight: null,
              decoration: InputDecoration(labelText: l10n.tarColuna),
              items: KanbanService.colunas
                  .map(
                    (c) => DropdownMenuItem(
                      value: c,
                      child: Text(l10n.opcaoKanban(c)),
                    ),
                  )
                  .toList(),
              onChanged: _enviando
                  ? null
                  : (value) => setState(() => _coluna = value!),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: _enviando ? null : () => Navigator.pop(context),
            child: Text(l10n.cancelar),
          ),
          ElevatedButton(
            onPressed: _enviando ? null : _enviar,
            child: Text(_enviando ? l10n.demSalvando : l10n.demCriar),
          ),
        ],
      ),
    );
  }
}

class _KanbanColuna extends StatelessWidget {
  const _KanbanColuna({
    super.key,
    required this.titulo,
    required this.cards,
    required this.arrastando,
    required this.onCardMoved,
    required this.onMoverPara,
    required this.onCardDeleted,
    required this.onArrastando,
    this.tone,
    this.compacta = false,
    this.dica,
  });

  final String titulo;
  final List<KanbanCardModel> cards;
  final Color? tone;
  final bool arrastando;

  /// Coluna única da visão compacta: sem cabeçalho (o seletor já mostra o
  /// nome e a contagem) e sem fundo de painel.
  final bool compacta;
  final String? dica;
  final _MoverCard onCardMoved;
  final ValueChanged<KanbanCardModel> onMoverPara;
  final ValueChanged<KanbanCardModel> onCardDeleted;
  final ValueChanged<bool> onArrastando;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final l10n = context.l10n;
    final lista = DragTarget<KanbanCardModel>(
      onWillAcceptWithDetails: (details) => details.data.coluna != titulo,
      onAcceptWithDetails: (details) => onCardMoved(details.data, titulo),
      builder: (context, candidatos, _) {
        final recebendo = candidatos.isNotEmpty;
        final Widget conteudo;
        if (cards.isEmpty) {
          conteudo = ListView(
            padding: const EdgeInsets.all(12),
            children: [
              if (arrastando)
                _AreaSoltar(destacada: recebendo, texto: l10n.tarSolteAqui)
              else
                SoftEmptyState(
                  icon: SigadIcons.kanban,
                  text: l10n.tarColunaVazia,
                ),
            ],
          );
        } else {
          conteudo = LayoutBuilder(
            builder: (context, constraints) => ListView.separated(
              padding: EdgeInsets.fromLTRB(
                compacta ? 16 : 12,
                compacta ? 8 : 4,
                compacta ? 16 : 12,
                compacta ? 96 : 12,
              ),
              itemCount: cards.length + (dica == null ? 0 : 1),
              separatorBuilder: (context, i) => const SizedBox(height: 12),
              itemBuilder: (_, index) {
                if (dica != null && index == 0) {
                  return MetaLabel(icon: SigadIcons.deslizar, text: dica!);
                }
                final card = cards[index - (dica == null ? 0 : 1)];
                return _KanbanCard(
                  card: card,
                  larguraFeedback: (constraints.maxWidth - 24).clamp(
                    200.0,
                    320.0,
                  ),
                  onMover: onCardMoved,
                  onMoverPara: onMoverPara,
                  onDeleted: onCardDeleted,
                  onArrastando: onArrastando,
                );
              },
            ),
          );
        }
        return AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          decoration: BoxDecoration(
            color: recebendo
                ? colors.primary.withValues(alpha: 0.08)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(compacta ? 0 : 22),
          ),
          child: conteudo,
        );
      },
    );

    if (compacta) return lista;

    final tom = tone ?? colors.primary;
    return Container(
      decoration: BoxDecoration(
        color: colors.surfaceContainer,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 12, 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Semantics(
                    header: true,
                    child: Text(
                      l10n.opcaoKanban(titulo),
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: tom.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${cards.length}',
                    semanticsLabel: l10n.tarQuantidade(cards.length),
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: tomLegivel(context, tom),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(child: lista),
        ],
      ),
    );
  }
}

class _AreaSoltar extends StatelessWidget {
  const _AreaSoltar({required this.destacada, required this.texto});

  final bool destacada;
  final String texto;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: BoxDecoration(
        color: colors.primary.withValues(alpha: destacada ? 0.14 : 0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.primary, width: destacada ? 2 : 1),
      ),
      child: Text(
        texto,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: colors.onSurface,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _KanbanCard extends StatelessWidget {
  const _KanbanCard({
    required this.card,
    required this.larguraFeedback,
    required this.onMover,
    required this.onMoverPara,
    required this.onDeleted,
    required this.onArrastando,
  });

  final KanbanCardModel card;
  final double larguraFeedback;
  final _MoverCard onMover;
  final ValueChanged<KanbanCardModel> onMoverPara;
  final ValueChanged<KanbanCardModel> onDeleted;
  final ValueChanged<bool> onArrastando;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return LongPressDraggable<KanbanCardModel>(
      data: card,
      hapticFeedbackOnStart: true,
      onDragStarted: () => onArrastando(true),
      onDragEnd: (_) => onArrastando(false),
      onDraggableCanceled: (_, _) => onArrastando(false),
      feedback: Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(16),
        color: theme.colorScheme.surface,
        child: Container(
          width: larguraFeedback,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: theme.colorScheme.primary, width: 1.5),
          ),
          child: Text(
            card.titulo,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
      childWhenDragging: Opacity(opacity: 0.4, child: _conteudo(context)),
      child: _conteudo(context),
    );
  }

  Widget _conteudo(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final prioridade = l10n.opcaoKanban(card.prioridade);
    return Semantics(
      key: ValueKey('kanban_card_semantics_${card.id}'),
      container: true,
      button: true,
      label: l10n.tarCardSemantica(card.titulo, prioridade),
      customSemanticsActions: {
        for (final coluna in KanbanService.colunas)
          if (coluna != card.coluna)
            CustomSemanticsAction(
              label: l10n.tarMoverParaColuna(l10n.opcaoKanban(coluna)),
            ): () =>
                onMover(card, coluna),
      },
      child: SigadSurfaceCard(
        onTap: () => _showDetalhes(context),
        padding: const EdgeInsets.fromLTRB(16, 8, 4, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Text(
                      card.titulo,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                PopupMenuButton<String>(
                  tooltip: l10n.tarMaisAcoes,
                  constraints: const BoxConstraints(
                    minWidth: 200,
                    maxWidth: 280,
                  ),
                  onSelected: (value) {
                    if (value == 'mover') onMoverPara(card);
                    if (value == 'excluir') onDeleted(card);
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'mover',
                      child: Row(
                        children: [
                          const SigadIcon(SigadIcons.trocar, size: 18),
                          const SizedBox(width: 8),
                          Flexible(child: Text(l10n.tarMoverPara)),
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
                    size: 20,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            PriorityBadge(prioridade: card.prioridade, label: prioridade),
          ],
        ),
      ),
    );
  }

  void _showDetalhes(BuildContext context) {
    final l10n = context.l10n;
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        scrollable: true,
        title: Text(card.titulo),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DetailRow(
              label: l10n.tarColuna,
              value: l10n.opcaoKanban(card.coluna),
            ),
            Text(
              l10n.demPrioridade,
              style: Theme.of(dialogContext).textTheme.labelSmall?.copyWith(
                color: Theme.of(dialogContext).colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            PriorityBadge(
              prioridade: card.prioridade,
              label: l10n.opcaoKanban(card.prioridade),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n.fechar),
          ),
        ],
      ),
    );
  }
}
