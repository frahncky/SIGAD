import 'package:flutter/material.dart';
import '../../../../app/theme/sigad_colors.dart';
import '../../../../core/services/app_event_logger.dart';
import '../../../../core/services/app_feedback_service.dart';
import '../../../../shared/widgets/horizontal_scroll_hint.dart';
import '../../../../shared/widgets/page_status_view.dart';
import '../../data/kanban_repository.dart';
import '../../domain/kanban_models.dart';
import '../../domain/kanban_service.dart';

class KanbanPage extends StatefulWidget {
  const KanbanPage({super.key});

  @override
  State<KanbanPage> createState() => _KanbanPageState();
}

class _KanbanPageState extends State<KanbanPage> {
  final KanbanRepository _kanbanRepository = KanbanRepository();
  final List<KanbanCardModel> _cards = KanbanService.defaultCards();
  bool _isLoading = true;
  String? _loadError;

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
        _loadError = 'Nao foi possivel carregar o quadro Kanban.';
      });
    }
  }

  void _saveData() {
    _kanbanRepository.saveCards(_cards);
  }

  Map<String, List<KanbanCardModel>> get _colunas => KanbanService.buildColunas(_cards);

  @override
  Widget build(BuildContext context) {
    final shouldShowScrollHint = MediaQuery.of(context).size.width < 960;
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showCriarCard(context),
          ),
        ],
      ),
      body: _isLoading
          ? const PageStatusView.loading(title: 'Carregando quadro Kanban...')
          : _loadError != null
              ? PageStatusView.error(
                  subtitle: _loadError,
                  onAction: _loadData,
                )
              : Column(
                  children: [
                    if (shouldShowScrollHint)
                      const Padding(
                        padding: EdgeInsets.fromLTRB(16, 12, 16, 0),
                        child: HorizontalScrollHint(
                          message: 'Arraste lateralmente para navegar entre as colunas do quadro.',
                        ),
                      ),
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        child: Row(
                          children: [
                            ..._colunas.entries.map(
                              (entry) => _KanbanColuna(
                                titulo: entry.key,
                                cards: entry.value,
                                onCardMoved: _moveCard,
                                onCardDeleted: _deleteCard,
                              ),
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

  void _deleteCard(KanbanCardModel card) {
    setState(() {
      _cards.removeWhere((c) => c.id == card.id);
    });
    AppFeedbackService.info(context, 'Card "${card.titulo}" removido');
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
          title: const Text('Novo Card'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: tituloController,
                decoration: const InputDecoration(
                  labelText: 'Título',
                  hintText: 'Digite o título do card',
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: prioridadeSelecionada,
                decoration: const InputDecoration(labelText: 'Prioridade'),
                items: KanbanService.prioridades
                    .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                    .toList(),
                onChanged: (value) => setModalState(() => prioridadeSelecionada = value!),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: colunaSelecionada,
                decoration: const InputDecoration(labelText: 'Coluna'),
                items: KanbanService.colunas
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (value) => setModalState(() => colunaSelecionada = value!),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                final erro = KanbanService.validateTitulo(tituloController.text);
                if (erro == null) {
                  setState(() {
                    final newId = KanbanService.nextId(_cards);
                    _cards.add(KanbanCardModel(
                      id: newId,
                      titulo: tituloController.text.trim(),
                      coluna: colunaSelecionada,
                      prioridade: prioridadeSelecionada,
                    ));
                  });
                  Navigator.pop(context);
                  AppFeedbackService.success(context, 'Card criado com sucesso!');
                  _saveData();
                } else {
                  AppFeedbackService.warning(context, erro);
                }
              },
              child: const Text('Criar'),
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
    required this.onCardMoved,
    required this.onCardDeleted,
  });

  final String titulo;
  final List<KanbanCardModel> cards;
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
                Text(
                  titulo,
                  style: textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: SigadColors.muted.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '${cards.length}',
                    style: textTheme.labelSmall?.copyWith(
                      color: SigadColors.muted,
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
                            'Solte aqui',
                            style: textTheme.bodySmall?.copyWith(
                              color: SigadColors.muted.withValues(alpha: 0.5),
                            ),
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.all(12),
                          itemCount: cards.length,
                          separatorBuilder: (context, i) => const SizedBox(height: 12),
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
  const _KanbanCard({
    required this.card,
    required this.onDeleted,
  });

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
    return GestureDetector(
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
            Text(
              card.titulo,
              style: textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getPrioridadeColor(card.prioridade).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    card.prioridade,
                    style: textTheme.labelSmall?.copyWith(
                      color: _getPrioridadeColor(card.prioridade),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'excluir') {
                      _showConfirmarExclusao(context);
                    }
                  },
                  itemBuilder: (context) => [
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
                    size: 18,
                    color: SigadColors.muted.withValues(alpha: 0.5),
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
            Text('ID: ${card.id}', style: textTheme.bodySmall?.copyWith(color: SigadColors.muted)),
            const SizedBox(height: 8),
            Text('Coluna: ${card.coluna}', style: textTheme.bodySmall),
            const SizedBox(height: 8),
            Text('Prioridade: ${card.prioridade}', style: textTheme.bodySmall),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

  void _showConfirmarExclusao(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar exclusão'),
        content: const Text('Tem certeza que deseja excluir este card?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onDeleted(card);
            },
            child: const Text('Excluir', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
