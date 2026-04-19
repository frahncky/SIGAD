import '../../../../core/network/api_config.dart';
import '../../domain/demanda_models.dart';

class DemandaDto {
  const DemandaDto({
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

  factory DemandaDto.fromJson(Map<String, dynamic> json) => DemandaDto(
        id: json['id'] as String,
        titulo: json['titulo'] as String,
        descricao: json['descricao'] as String,
        prioridade: json['prioridade'] as String,
        statusLabel: json['statusLabel'] as String,
        proprietario: json['proprietario'] as String,
        prazo: json['prazo'] as String,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'titulo': titulo,
        'descricao': descricao,
        'prioridade': prioridade,
        'statusLabel': statusLabel,
        'proprietario': proprietario,
        'prazo': prazo,
      };

  Demanda toDomain() => Demanda(
        id: id,
        titulo: titulo,
        descricao: descricao,
        prioridade: prioridade,
        statusLabel: statusLabel,
        proprietario: proprietario,
        prazo: prazo,
      );

  static DemandaDto fromDomain(Demanda demanda) => DemandaDto(
        id: demanda.id,
        titulo: demanda.titulo,
        descricao: demanda.descricao,
        prioridade: demanda.prioridade,
        statusLabel: demanda.statusLabel,
        proprietario: demanda.proprietario,
        prazo: demanda.prazo,
      );
}

abstract final class DemandaApiContract {
  static const String collectionPath = ApiConfig.demandasPath;
}
