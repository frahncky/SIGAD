import '../domain/demanda_models.dart';
import '../../../core/services/local_storage_service.dart';

class DemandaRepository {
  DemandaRepository({this.storageKey = 'sigad_demandas'});

  final String storageKey;

  Future<List<Demanda>> loadDemandas() async {
    final list = await LocalStorageService.loadList(storageKey);
    if (list.isEmpty) return const [];

    final demandas = <Demanda>[];
    for (final item in list) {
      try {
        demandas.add(_demandaFromJson(item));
      } catch (_) {
        // Ignora registros inválidos sem quebrar a tela.
      }
    }
    return demandas;
  }

  Future<void> saveDemandas(List<Demanda> demandas) {
    return LocalStorageService.saveList(
      storageKey,
      demandas.map(_demandaToJson).toList(growable: false),
    );
  }

  Map<String, dynamic> _demandaToJson(Demanda d) => {
        'id': d.id,
        'titulo': d.titulo,
        'descricao': d.descricao,
        'prioridade': d.prioridade,
        'statusLabel': d.statusLabel,
        'proprietario': d.proprietario,
        'prazo': d.prazo,
      };

  Demanda _demandaFromJson(Map<String, dynamic> json) => Demanda(
        id: json['id'] as String,
        titulo: json['titulo'] as String,
        descricao: json['descricao'] as String,
        prioridade: json['prioridade'] as String,
        statusLabel: json['statusLabel'] as String,
        proprietario: json['proprietario'] as String,
        prazo: json['prazo'] as String,
      );
}
