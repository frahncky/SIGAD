import '../domain/relatorio_models.dart';
import '../../../core/services/local_storage_service.dart';

class RelatorioRepository {
  RelatorioRepository({this.storageKey = 'sigad_relatorios'});

  final String storageKey;

  Future<List<Relatorio>> loadRelatorios() async {
    final list = await LocalStorageService.loadList(storageKey);
    if (list.isEmpty) return const [];

    final relatorios = <Relatorio>[];
    for (final item in list) {
      try {
        relatorios.add(_relatorioFromJson(item));
      } catch (_) {
        // Ignora registros inválidos sem bloquear a tela.
      }
    }
    return relatorios;
  }

  Future<void> saveRelatorios(List<Relatorio> relatorios) {
    return LocalStorageService.saveList(
      storageKey,
      relatorios.map(_relatorioToJson).toList(growable: false),
    );
  }

  Map<String, dynamic> _relatorioToJson(Relatorio r) => {
        'id': r.id,
        'titulo': r.titulo,
        'descricao': r.descricao,
        'tipo': r.tipo,
        'data': r.data,
        'autor': r.autor,
        'status': r.status,
        'downloads': r.downloads,
        'compartilhamentos': r.compartilhamentos,
        if (r.ultimaAcao != null) 'ultimaAcao': r.ultimaAcao,
      };

  Relatorio _relatorioFromJson(Map<String, dynamic> json) => Relatorio(
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
}
