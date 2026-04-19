class Atividade {
  const Atividade({
    required this.id,
    required this.titulo,
    required this.descricao,
    required this.data,
    required this.responsavel,
    required this.status,
  });

  final String id;
  final String titulo;
  final String descricao;
  final String data;
  final String responsavel;
  final String status;

  Atividade copyWith({
    String? titulo,
    String? descricao,
    String? data,
    String? responsavel,
    String? status,
  }) {
    return Atividade(
      id: id,
      titulo: titulo ?? this.titulo,
      descricao: descricao ?? this.descricao,
      data: data ?? this.data,
      responsavel: responsavel ?? this.responsavel,
      status: status ?? this.status,
    );
  }
}
