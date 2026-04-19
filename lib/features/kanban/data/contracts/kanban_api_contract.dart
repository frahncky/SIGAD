import '../../../../core/network/api_config.dart';
import '../../domain/kanban_models.dart';

class KanbanCardDto {
  const KanbanCardDto({
    required this.id,
    required this.titulo,
    required this.coluna,
    required this.prioridade,
  });

  final int id;
  final String titulo;
  final String coluna;
  final String prioridade;

  factory KanbanCardDto.fromJson(Map<String, dynamic> json) => KanbanCardDto(
        id: json['id'] as int,
        titulo: json['titulo'] as String,
        coluna: json['coluna'] as String,
        prioridade: json['prioridade'] as String,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'titulo': titulo,
        'coluna': coluna,
        'prioridade': prioridade,
      };

  KanbanCardModel toDomain() => KanbanCardModel(
        id: id,
        titulo: titulo,
        coluna: coluna,
        prioridade: prioridade,
      );

  static KanbanCardDto fromDomain(KanbanCardModel card) => KanbanCardDto(
        id: card.id,
        titulo: card.titulo,
        coluna: card.coluna,
        prioridade: card.prioridade,
      );
}

abstract final class KanbanApiContract {
  static const String collectionPath = ApiConfig.kanbanPath;
}
