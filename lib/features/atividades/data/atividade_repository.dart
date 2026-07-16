import 'package:http/http.dart' as http;

import '../../../core/contracts/entity_repository.dart';
import '../../../core/config/app_runtime_config.dart';
import '../../../core/network/api_request.dart';
import '../../../core/network/app_http_client.dart';
import '../../../core/network/http_package_client.dart';
import '../../../core/services/app_event_logger.dart';
import '../../../core/services/local_storage_service.dart';
import '../domain/atividade_models.dart';
import 'contracts/atividade_api_contract.dart';

class AtividadeRepository implements EntityRepository<Atividade> {
  AtividadeRepository({
    this.storageKey = 'sigad_atividades',
    AppHttpClient? remoteClient,
    DataSourceMode? dataSourceMode,
    bool? enableRemoteFallback,
  }) : _remoteClient =
           remoteClient ?? HttpPackageClient(httpClient: http.Client()),
       _dataSourceMode = dataSourceMode ?? AppRuntimeConfig.dataSourceMode,
       _enableRemoteFallback =
           enableRemoteFallback ?? AppRuntimeConfig.enableRemoteFallback;

  final String storageKey;
  final AppHttpClient _remoteClient;
  final DataSourceMode _dataSourceMode;
  final bool _enableRemoteFallback;

  @override
  Future<List<Atividade>> load() => loadAtividades();

  @override
  Future<void> save(List<Atividade> entities) => saveAtividades(entities);

  Future<List<Atividade>> loadAtividades({
    List<Atividade> initialData = const [],
  }) async {
    if (_dataSourceMode == DataSourceMode.local) {
      return _loadLocalAtividades(initialData: initialData);
    }

    try {
      return await _loadRemoteAtividades();
    } catch (error, stackTrace) {
      AppEventLogger.error(
        'atividades_remote_load_error',
        error,
        stackTrace: stackTrace,
      );
      if (_enableRemoteFallback) {
        AppEventLogger.action('atividades_remote_load_fallback_local');
        return _loadLocalAtividades(initialData: initialData);
      }
      rethrow;
    }
  }

  Future<void> saveAtividades(List<Atividade> atividades) async {
    if (_dataSourceMode == DataSourceMode.local) {
      return _saveLocalAtividades(atividades);
    }

    try {
      await _saveRemoteAtividades(atividades);
      await _saveLocalAtividades(atividades);
    } catch (error, stackTrace) {
      AppEventLogger.error(
        'atividades_remote_save_error',
        error,
        stackTrace: stackTrace,
      );
      if (_enableRemoteFallback) {
        AppEventLogger.action('atividades_remote_save_fallback_local');
        return _saveLocalAtividades(atividades);
      }
      rethrow;
    }
  }

  Future<List<Atividade>> _loadLocalAtividades({
    List<Atividade> initialData = const [],
  }) async {
    final list = await LocalStorageService.loadListOrNull(storageKey);
    if (list == null) {
      if (initialData.isNotEmpty) {
        await _saveLocalAtividades(initialData);
      }
      return List<Atividade>.of(initialData, growable: false);
    }
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

  Future<void> _saveLocalAtividades(List<Atividade> atividades) {
    return LocalStorageService.saveList(
      storageKey,
      atividades.map(_atividadeToJson).toList(growable: false),
    );
  }

  Future<List<Atividade>> _loadRemoteAtividades() async {
    final response = await _remoteClient.send(
      const ApiRequest(
        path: AtividadeApiContract.collectionPath,
        method: HttpMethod.get,
      ),
    );
    final payload = _extractListPayload(response.body);
    final atividades = <Atividade>[];
    for (final item in payload) {
      try {
        atividades.add(AtividadeDto.fromJson(item).toDomain());
      } catch (_) {
        // Ignora itens inválidos vindos da API sem quebrar a experiência.
      }
    }
    return atividades;
  }

  Future<void> _saveRemoteAtividades(List<Atividade> atividades) {
    final payload = atividades
        .map((item) => AtividadeDto.fromDomain(item).toJson())
        .toList(growable: false);
    return _remoteClient.send(
      ApiRequest(
        path: AtividadeApiContract.collectionPath,
        method: HttpMethod.put,
        body: payload,
      ),
    );
  }

  List<Map<String, dynamic>> _extractListPayload(Object? body) {
    if (body is List) {
      return body
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList(growable: false);
    }
    if (body is Map<String, dynamic>) {
      final nested = body['items'] ?? body['data'];
      if (nested is List) {
        return nested
            .whereType<Map>()
            .map((item) => Map<String, dynamic>.from(item))
            .toList(growable: false);
      }
    }
    return const [];
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
