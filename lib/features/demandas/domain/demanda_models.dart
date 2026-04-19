class Demanda {
  const Demanda({
    required this.id,
    required this.titulo,
    required this.descricao,
    required this.prioridade,
    required this.statusLabel,
    required this.proprietario,
    required this.prazo,
  });

  final String id;
  final String titulo;
  final String descricao;
  final String prioridade;
  final String statusLabel;
  final String proprietario;
  final String prazo;

  Demanda copyWith({
    String? titulo,
    String? descricao,
    String? prioridade,
    String? statusLabel,
    String? proprietario,
    String? prazo,
  }) {
    return Demanda(
      id: id,
      titulo: titulo ?? this.titulo,
      descricao: descricao ?? this.descricao,
      prioridade: prioridade ?? this.prioridade,
      statusLabel: statusLabel ?? this.statusLabel,
      proprietario: proprietario ?? this.proprietario,
      prazo: prazo ?? this.prazo,
    );
  }
}
