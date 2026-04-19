import '../../../../core/network/api_config.dart';
import '../../domain/relatorio_models.dart';

class RelatorioDto {
  const RelatorioDto({
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

  factory RelatorioDto.fromJson(Map<String, dynamic> json) => RelatorioDto(
        id: json['id'] as String,
        titulo: json['titulo'] as String,
        descricao: json['descricao'] as String,
        tipo: json['tipo'] as String,
        data: json['data'] as String,
        autor: json['autor'] as String,
        status: json['status'] as String,
        downloads: json['downloads'] as int? ?? 0,
        compartilhamentos: json['compartilhamentos'] as int? ?? 0,
        ultimaAcao: json['ultimaAcao'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'titulo': titulo,
        'descricao': descricao,
        'tipo': tipo,
        'data': data,
        'autor': autor,
        'status': status,
        'downloads': downloads,
        'compartilhamentos': compartilhamentos,
        if (ultimaAcao != null) 'ultimaAcao': ultimaAcao,
      };

  Relatorio toDomain() => Relatorio(
        id: id,
        titulo: titulo,
        descricao: descricao,
        tipo: tipo,
        data: data,
        autor: autor,
        status: status,
        downloads: downloads,
        compartilhamentos: compartilhamentos,
        ultimaAcao: ultimaAcao,
      );

  static RelatorioDto fromDomain(Relatorio relatorio) => RelatorioDto(
        id: relatorio.id,
        titulo: relatorio.titulo,
        descricao: relatorio.descricao,
        tipo: relatorio.tipo,
        data: relatorio.data,
        autor: relatorio.autor,
        status: relatorio.status,
        downloads: relatorio.downloads,
        compartilhamentos: relatorio.compartilhamentos,
        ultimaAcao: relatorio.ultimaAcao,
      );
}

abstract final class RelatorioApiContract {
  static const String collectionPath = ApiConfig.relatoriosPath;
}
