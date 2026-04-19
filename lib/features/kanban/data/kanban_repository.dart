import '../domain/kanban_models.dart';
import '../../../core/services/local_storage_service.dart';

class KanbanRepository {
  KanbanRepository({this.storageKey = 'sigad_kanban'});

  final String storageKey;

  Future<List<KanbanCardModel>> loadCards() async {
    final list = await LocalStorageService.loadList(storageKey);
    if (list.isEmpty) return const [];

    final cards = <KanbanCardModel>[];
    for (final item in list) {
      try {
        cards.add(_cardFromJson(item));
      } catch (_) {
        // Ignora itens inválidos sem bloquear a tela.
      }
    }
    return cards;
  }

  Future<void> saveCards(List<KanbanCardModel> cards) {
    return LocalStorageService.saveList(
      storageKey,
      cards.map(_cardToJson).toList(growable: false),
    );
  }

  Map<String, dynamic> _cardToJson(KanbanCardModel c) => {
        'id': c.id,
        'titulo': c.titulo,
        'coluna': c.coluna,
        'prioridade': c.prioridade,
      };

  KanbanCardModel _cardFromJson(Map<String, dynamic> json) => KanbanCardModel(
        id: json['id'] as int,
        titulo: json['titulo'] as String,
        coluna: json['coluna'] as String,
        prioridade: json['prioridade'] as String,
      );
}
