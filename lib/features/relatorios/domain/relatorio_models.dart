class Relatorio {
  const Relatorio({
    required this.id,
    required this.titulo,
    required this.descricao,
    required this.tipo,
    required this.data,
    required this.autor,
    required this.status,
    this.downloads = 0,
    this.compartilhamentos = 0,
    this.ultimaAcao,
  });

  final String id;
  final String titulo;
  final String descricao;
  final String tipo;
  final String data;
  final String autor;
  final String status;
  final int downloads;
  final int compartilhamentos;
  final String? ultimaAcao;

  Relatorio copyWith({
    String? titulo,
    String? descricao,
    String? tipo,
    String? data,
    String? autor,
    String? status,
    int? downloads,
    int? compartilhamentos,
    String? ultimaAcao,
  }) {
    return Relatorio(
      id: id,
      titulo: titulo ?? this.titulo,
      descricao: descricao ?? this.descricao,
      tipo: tipo ?? this.tipo,
      data: data ?? this.data,
      autor: autor ?? this.autor,
      status: status ?? this.status,
      downloads: downloads ?? this.downloads,
      compartilhamentos: compartilhamentos ?? this.compartilhamentos,
      ultimaAcao: ultimaAcao ?? this.ultimaAcao,
    );
  }
}
