import '../../../../core/network/api_config.dart';
import '../../domain/atividade_models.dart';

class AtividadeDto {
  const AtividadeDto({
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

  factory AtividadeDto.fromJson(Map<String, dynamic> json) => AtividadeDto(
    id: json['id'] as String,
    titulo: json['titulo'] as String,
    descricao: json['descricao'] as String,
    data: json['data'] as String,
    responsavel: json['responsavel'] as String,
    status: json['status'] as String,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'titulo': titulo,
    'descricao': descricao,
    'data': data,
    'responsavel': responsavel,
    'status': status,
  };

  Atividade toDomain() => Atividade(
    id: id,
    titulo: titulo,
    descricao: descricao,
    data: data,
    responsavel: responsavel,
    status: status,
  );

  static AtividadeDto fromDomain(Atividade atividade) => AtividadeDto(
    id: atividade.id,
    titulo: atividade.titulo,
    descricao: atividade.descricao,
    data: atividade.data,
    responsavel: atividade.responsavel,
    status: atividade.status,
  );
}

abstract final class AtividadeApiContract {
  static const String collectionPath = ApiConfig.atividadesPath;
}
