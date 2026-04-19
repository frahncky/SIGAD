import '../../../core/services/local_storage_service.dart';
import '../domain/atividade_models.dart';

class AtividadeRepository {
  AtividadeRepository({this.storageKey = 'sigad_atividades'});

  final String storageKey;

  Future<List<Atividade>> loadAtividades() async {
    final list = await LocalStorageService.loadList(storageKey);
    if (list.isEmpty) return const [];

    final atividades = <Atividade>[];
    for (final item in list) {
      try {
        atividades.add(_atividadeFromJson(item));
      } catch (_) {
        // Ignora registros inválidos para manter a tela funcional.
      }
    }
    return atividades;
  }

  Future<void> saveAtividades(List<Atividade> atividades) {
    return LocalStorageService.saveList(
      storageKey,
      atividades.map(_atividadeToJson).toList(growable: false),
    );
  }

  Map<String, dynamic> _atividadeToJson(Atividade a) => {
        'id': a.id,
        'titulo': a.titulo,
        'descricao': a.descricao,
        'data': a.data,
        'responsavel': a.responsavel,
        'status': a.status,
      };

  Atividade _atividadeFromJson(Map<String, dynamic> json) => Atividade(
        id: json['id'] as String,
        titulo: json['titulo'] as String,
        descricao: json['descricao'] as String,
        data: json['data'] as String,
        responsavel: json['responsavel'] as String,
        status: json['status'] as String,
      );
}
