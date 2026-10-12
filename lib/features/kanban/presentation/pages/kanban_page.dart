import 'package:flutter/material.dart';
import '../../../../app/theme/sigad_colors.dart';
import '../../../../app/theme/sigad_icon.dart';
import '../../../../app/theme/sigad_icons.dart';
import '../../../../app/theme/sigad_tone_palette.dart';
import '../../../../core/services/app_event_logger.dart';
import '../../../../core/services/app_feedback_service.dart';
import '../../../../l10n/l10n.dart';
import '../../../../shared/widgets/horizontal_scroll_hint.dart';
import '../../../../shared/widgets/page_status_view.dart';
import '../../data/kanban_repository.dart';
import '../../domain/kanban_models.dart';
import '../../domain/kanban_service.dart';
import '../kanban_l10n.dart';

class KanbanPage extends StatefulWidget {
  const KanbanPage({super.key});

  @override
  State<KanbanPage> createState() => _KanbanPageState();
}

class _KanbanPageState extends State<KanbanPage> {
  final KanbanRepository _kanbanRepository = KanbanRepository();
  final List<KanbanCardModel> _cards = List<KanbanCardModel>.of(
    KanbanService.defaultCards(),
    growable: true,
  );
  bool _isLoading = true;
  String? _loadError;

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
        if (list.isNotEmpty) {
          _cards
            ..clear()
            ..addAll(list);
        }
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

  void _saveData() {
    _kanbanRepository.saveCards(_cards);
  }

  Map<String, List<KanbanCardModel>> get _colunas =>
      KanbanService.buildColunas(_cards);

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final shouldShowScrollHint = MediaQuery.of(context).size.width < 960;
    final colunasEntries = _colunas.entries.toList();
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        actions: [
          IconButton(
            icon: const SigadIcon(SigadIcons.adicionar),
            onPressed: () => _showCriarCard(context),
            tooltip: l10n.tarNovoCard,
          ),
        ],
      ),
      body: _isLoading
          ? PageStatusView.loading(title: l10n.tarCarregando)
          : _loadError != null
          ? PageStatusView.error(
              title: l10n.demErroCarregarTitulo,
              subtitle: _loadError,
              actionLabel: l10n.tentarNovamente,
              onAction: _loadData,
            )
          : _cards.isEmpty
          ? PageStatusView.empty(
              icon: SigadIcons.kanban,
              title: l10n.tarNenhumCard,
              subtitle: l10n.tarNenhumCardDica,
              actionLabel: l10n.tarCriarCard,
              onAction: () => _showCriarCard(context),
            )
          : Column(
              children: [
                if (shouldShowScrollHint)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                    child: HorizontalScrollHint(message: l10n.tarArrasteDica),
                  ),
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: Row(
                      children: [
                        for (
                          var index = 0;
                          index < colunasEntries.length;
                          index++
                        )
                          _KanbanColuna(
                            titulo: colunasEntries[index].key,
                            cards: colunasEntries[index].value,
                            tone: sigadToneForIndex(index),
                            onCardMoved: _moveCard,
                            onCardDeleted: _deleteCard,
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  void _moveCard(KanbanCardModel card, String novaColuna) {
    setState(() {
      final index = _cards.indexWhere((c) => c.id == card.id);
      if (index != -1) {
        _cards[index] = KanbanService.moverCard(card, novaColuna);
      }
    });
    _saveData();
  }

  Future<void> _deleteCard(KanbanCardModel card) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(context.l10n.demConfirmarExclusao),
        content: Text(context.l10n.tarExcluirCardMensagem(card.titulo)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(context.l10n.cancelar),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              context.l10n.excluir,
              style: TextStyle(color: Theme.of(ctx).colorScheme.error),
            ),
          ),
        ],
      ),
    );
    if (!mounted || confirmed != true) return;
    setState(() {
      _cards.removeWhere((c) => c.id == card.id);
    });
    AppFeedbackService.info(context, context.l10n.tarCardRemovido(card.titulo));
    _saveData();
  }

  void _showCriarCard(BuildContext context) {
    final tituloController = TextEditingController();
    String prioridadeSelecionada = 'Média';
    String colunaSelecionada = 'Backlog';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => AlertDialog(
          title: Text(context.l10n.tarNovoCard),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: tituloController,
                decoration: InputDecoration(
                  labelText: context.l10n.demTitulo,
                  hintText: context.l10n.tarTituloDica,
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: prioridadeSelecionada,
                decoration: InputDecoration(
                  labelText: context.l10n.demPrioridade,
                ),
                items: KanbanService.prioridades
                    .map(
                      (p) => DropdownMenuItem(
                        value: p,
                        child: Text(context.l10n.opcaoKanban(p)),
                      ),
                    )
                    .toList(),
                onChanged: (value) =>
                    setModalState(() => prioridadeSelecionada = value!),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: colunaSelecionada,
                decoration: InputDecoration(labelText: context.l10n.tarColuna),
                items: KanbanService.colunas
                    .map(
                      (c) => DropdownMenuItem(
                        value: c,
                        child: Text(context.l10n.opcaoKanban(c)),
                      ),
                    )
                    .toList(),
                onChanged: (value) =>
                    setModalState(() => colunaSelecionada = value!),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(context.l10n.cancelar),
            ),
            ElevatedButton(
              onPressed: () {
                final erro = KanbanService.validateTitulo(
                  tituloController.text,
                );
                if (erro == null) {
                  setState(() {
                    final newId = KanbanService.nextId(_cards);
                    _cards.add(
                      KanbanCardModel(
                        id: newId,
                        titulo: tituloController.text.trim(),
                        coluna: colunaSelecionada,
                        prioridade: prioridadeSelecionada,
                      ),
                    );
                  });
                  Navigator.pop(context);
                  AppFeedbackService.success(
                    context,
                    context.l10n.tarCardCriado,
                  );
                  _saveData();
                } else {
                  AppFeedbackService.warning(
                    context,
                    context.l10n.erroKanban(erro),
                  );
                }
              },
              child: Text(context.l10n.demCriar),
            ),
          ],
        ),
      ),
    );
  }
}

class _KanbanColuna extends StatelessWidget {
  const _KanbanColuna({
    required this.titulo,
    required this.cards,
    required this.tone,
    required this.onCardMoved,
    required this.onCardDeleted,
  });

  final String titulo;
  final List<KanbanCardModel> cards;
  final Color tone;
  final Function(KanbanCardModel, String) onCardMoved;
  final Function(KanbanCardModel) onCardDeleted;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      width: 300,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: SigadColors.canvas,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    context.l10n.opcaoKanban(titulo),
                    style: textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: tone.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '${cards.length}',
                    style: textTheme.labelSmall?.copyWith(
                      color: tone,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: DragTarget<KanbanCardModel>(
              onAcceptWithDetails: (details) {
                onCardMoved(details.data, titulo);
              },
              builder: (context, candidateData, rejectedData) {
                return Container(
                  decoration: BoxDecoration(
                    color: candidateData.isNotEmpty
                        ? SigadColors.brand.withValues(alpha: 0.1)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: cards.isEmpty
                      ? Center(
                          child: Text(
                            context.l10n.tarSolteAqui,
                            style: textTheme.bodySmall?.copyWith(
                              color: SigadColors.muted.withValues(alpha: 0.5),
                            ),
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.all(12),
                          itemCount: cards.length,
                          separatorBuilder: (context, i) =>
                              const SizedBox(height: 12),
                          itemBuilder: (_, index) => _KanbanCard(
                            card: cards[index],
                            onDeleted: onCardDeleted,
                          ),
                        ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _KanbanCard extends StatelessWidget {
  const _KanbanCard({required this.card, required this.onDeleted});

  final KanbanCardModel card;
  final Function(KanbanCardModel) onDeleted;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Draggable<KanbanCardModel>(
      data: card,
      feedback: Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          width: 280,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: SigadColors.surface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: SigadColors.brand),
          ),
          child: Text(
            card.titulo,
            style: textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
      childWhenDragging: Opacity(
        opacity: 0.5,
        child: _buildCardContent(context, textTheme),
      ),
      child: _buildCardContent(context, textTheme),
    );
  }

  Widget _buildCardContent(BuildContext context, TextTheme textTheme) {
    return Semantics(
      button: true,
      label: context.l10n.tarCardSemantica(
        card.titulo,
        context.l10n.opcaoKanban(card.prioridade),
      ),
      child: GestureDetector(
        onTap: () => _showDetalhes(context),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: SigadColors.surface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: SigadColors.divider),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 6,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 220, // valor fixo ou ajuste conforme necessário
                child: Text(
                  card.titulo,
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getPrioridadeColor(
                        card.prioridade,
                      ).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      context.l10n.opcaoKanban(card.prioridade),
                      style: textTheme.labelSmall?.copyWith(
                        color: _getPrioridadeColor(card.prioridade),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  PopupMenuButton<String>(
                    tooltip: context.l10n.tarMaisAcoes,
                    onSelected: (value) {
                      if (value == 'excluir') {
                        _showConfirmarExclusao(context);
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'excluir',
                        child: Row(
                          children: [
                            const SigadIcon(SigadIcons.excluir, size: 18),
                            const SizedBox(width: 8),
                            Text(context.l10n.excluir),
                          ],
                        ),
                      ),
                    ],
                    icon: SigadIcon(
                      SigadIcons.maisOpcoes,
                      size: 18,
                      color: SigadColors.muted,
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
    return KanbanService.prioridadeColor(prioridade);
  }

  void _showDetalhes(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(card.titulo),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.l10n.tarId(card.id.toString()),
              style: textTheme.bodySmall?.copyWith(color: SigadColors.muted),
            ),
            const SizedBox(height: 8),
            Text(
              context.l10n.tarColunaValor(
                context.l10n.opcaoKanban(card.coluna),
              ),
              style: textTheme.bodySmall,
            ),
            const SizedBox(height: 8),
            Text(
              context.l10n.tarPrioridadeValor(
                context.l10n.opcaoKanban(card.prioridade),
              ),
              style: textTheme.bodySmall,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(context.l10n.fechar),
          ),
        ],
      ),
    );
  }

  void _showConfirmarExclusao(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.demConfirmarExclusao),
        content: Text(context.l10n.tarExcluirEsteCard),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(context.l10n.cancelar),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onDeleted(card);
            },
            child: Text(
              context.l10n.excluir,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ],
      ),
    );
  }
}
