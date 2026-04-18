import 'package:flutter/material.dart';
import '../../../../app/theme/sigad_colors.dart';
import '../../../../core/services/local_storage_service.dart';

class KanbanPage extends StatefulWidget {
  const KanbanPage({super.key});

  @override
  State<KanbanPage> createState() => _KanbanPageState();
}

class _KanbanPageState extends State<KanbanPage> {
  final List<_Card> _cards = [
    _Card(id: 1, titulo: 'Revisão de inventário', coluna: 'Backlog', prioridade: 'Alta'),
    _Card(id: 2, titulo: 'Mapear demandas', coluna: 'Em Progresso', prioridade: 'Alta'),
    _Card(id: 3, titulo: 'Padronizar formulários', coluna: 'Em Revisão', prioridade: 'Média'),
    _Card(id: 4, titulo: 'Auditoria de estágio', coluna: 'Em Revisão', prioridade: 'Média'),
    _Card(id: 5, titulo: 'Relatório de labs', coluna: 'Concluído', prioridade: 'Baixa'),
    _Card(id: 6, titulo: 'Planejar semestre', coluna: 'Backlog', prioridade: 'Alta'),
    _Card(id: 7, titulo: 'Revisar documentação', coluna: 'Em Progresso', prioridade: 'Média'),
  ];

  static const String _kKey = 'sigad_kanban';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final list = await LocalStorageService.loadList(_kKey);
    if (list.isEmpty) return;
    setState(() {
      _cards
        ..clear()
        ..addAll(list.map(_cardFromJson));
    });
  }

  void _saveData() {
    LocalStorageService.saveList(_kKey, _cards.map(_cardToJson).toList());
  }

  Map<String, dynamic> _cardToJson(_Card c) => {
    'id': c.id,
    'titulo': c.titulo,
    'coluna': c.coluna,
    'prioridade': c.prioridade,
  };

  _Card _cardFromJson(Map<String, dynamic> json) => _Card(
    id: json['id'] as int,
    titulo: json['titulo'] as String,
    coluna: json['coluna'] as String,
    prioridade: json['prioridade'] as String,
  );

  Map<String, List<_Card>> get _colunas {
    const colunaNames = ['Backlog', 'Em Progresso', 'Em Revisão', 'Concluído'];
    return {
      for (var coluna in colunaNames)
        coluna: _cards.where((card) => card.coluna == coluna).toList(),
    };
  }

  @override
  Widget build(BuildContext context) {
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
      body: SingleChildScrollView(
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
    );
  }

  void _moveCard(_Card card, String novaColuna) {
    setState(() {
      final index = _cards.indexWhere((c) => c.id == card.id);
      if (index != -1) {
        _cards[index] = _Card(
          id: card.id,
          titulo: card.titulo,
          coluna: novaColuna,
          prioridade: card.prioridade,
        );
      }
    });
    _saveData();
  }

  void _deleteCard(_Card card) {
    setState(() {
      _cards.removeWhere((c) => c.id == card.id);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Card "${card.titulo}" removido')),
    );
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
                items: ['Baixa', 'Média', 'Alta']
                    .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                    .toList(),
                onChanged: (value) => setModalState(() => prioridadeSelecionada = value!),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: colunaSelecionada,
                decoration: const InputDecoration(labelText: 'Coluna'),
                items: ['Backlog', 'Em Progresso', 'Em Revisão', 'Concluído']
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
                if (tituloController.text.trim().isNotEmpty) {
                  setState(() {
                    final newId = _cards.isEmpty ? 1 : _cards.map((c) => c.id).reduce((a, b) => a > b ? a : b) + 1;
                    _cards.add(_Card(
                      id: newId,
                      titulo: tituloController.text.trim(),
                      coluna: colunaSelecionada,
                      prioridade: prioridadeSelecionada,
                    ));
                  });
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Card criado com sucesso!')),
                  );
                  _saveData();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Informe o título do card')),
                  );
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
  final List<_Card> cards;
  final Function(_Card, String) onCardMoved;
  final Function(_Card) onCardDeleted;

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
            child: DragTarget<_Card>(
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

  final _Card card;
  final Function(_Card) onDeleted;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Draggable<_Card>(
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
    switch (prioridade) {
      case 'Alta':
        return SigadColors.risk;
      case 'Média':
        return SigadColors.warning;
      default:
        return SigadColors.success;
    }
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

class _Card {
  const _Card({
    required this.id,
    required this.titulo,
    required this.coluna,
    required this.prioridade,
  });

  final int id;
  final String titulo;
  final String coluna;
  final String prioridade;
}
