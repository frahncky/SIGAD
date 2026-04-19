class KanbanCardModel {
  const KanbanCardModel({
    required this.id,
    required this.titulo,
    required this.coluna,
    required this.prioridade,
  });

  final int id;
  final String titulo;
  final String coluna;
  final String prioridade;

  KanbanCardModel copyWith({
    String? titulo,
    String? coluna,
    String? prioridade,
  }) {
    return KanbanCardModel(
      id: id,
      titulo: titulo ?? this.titulo,
      coluna: coluna ?? this.coluna,
      prioridade: prioridade ?? this.prioridade,
    );
  }
}
