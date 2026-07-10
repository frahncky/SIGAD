import 'package:http/http.dart' as http;

import '../../../core/contracts/entity_repository.dart';
import '../../../core/config/app_runtime_config.dart';
import '../../../core/network/api_request.dart';
import '../../../core/network/app_http_client.dart';
import '../../../core/network/http_package_client.dart';
import '../../../core/services/app_event_logger.dart';
import '../domain/relatorio_models.dart';
import '../../../core/services/local_storage_service.dart';
import 'contracts/relatorio_api_contract.dart';

class RelatorioRepository implements EntityRepository<Relatorio> {
  RelatorioRepository({
    this.storageKey = 'sigad_relatorios',
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
  Future<List<Relatorio>> load() => loadRelatorios();

  @override
  Future<void> save(List<Relatorio> entities) => saveRelatorios(entities);

  Future<List<Relatorio>> loadRelatorios() async {
    if (_dataSourceMode == DataSourceMode.local) {
      return _loadLocalRelatorios();
    }

    try {
      return await _loadRemoteRelatorios();
    } catch (error, stackTrace) {
      AppEventLogger.error(
        'relatorios_remote_load_error',
        error,
        stackTrace: stackTrace,
      );
      if (_enableRemoteFallback) {
        AppEventLogger.action('relatorios_remote_load_fallback_local');
        return _loadLocalRelatorios();
      }
      rethrow;
    }
  }

  Future<void> saveRelatorios(List<Relatorio> relatorios) async {
    if (_dataSourceMode == DataSourceMode.local) {
      return _saveLocalRelatorios(relatorios);
    }

    try {
      await _saveRemoteRelatorios(relatorios);
      await _saveLocalRelatorios(relatorios);
    } catch (error, stackTrace) {
      AppEventLogger.error(
        'relatorios_remote_save_error',
        error,
        stackTrace: stackTrace,
      );
      if (_enableRemoteFallback) {
        AppEventLogger.action('relatorios_remote_save_fallback_local');
        return _saveLocalRelatorios(relatorios);
      }
      rethrow;
    }
  }

  Future<List<Relatorio>> _loadLocalRelatorios() async {
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

  Future<void> _saveLocalRelatorios(List<Relatorio> relatorios) {
    return LocalStorageService.saveList(
      storageKey,
      relatorios.map(_relatorioToJson).toList(growable: false),
    );
  }

  Future<List<Relatorio>> _loadRemoteRelatorios() async {
    final response = await _remoteClient.send(
      const ApiRequest(
        path: RelatorioApiContract.collectionPath,
        method: HttpMethod.get,
      ),
    );
    final payload = _extractListPayload(response.body);
    final relatorios = <Relatorio>[];
    for (final item in payload) {
      try {
        relatorios.add(RelatorioDto.fromJson(item).toDomain());
      } catch (_) {
        // Ignora itens inválidos vindos da API sem quebrar a experiência.
      }
    }
    return relatorios;
  }

  Future<void> _saveRemoteRelatorios(List<Relatorio> relatorios) {
    final payload = relatorios
        .map((item) => RelatorioDto.fromDomain(item).toJson())
        .toList(growable: false);
    return _remoteClient.send(
      ApiRequest(
        path: RelatorioApiContract.collectionPath,
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
