import 'package:http/http.dart' as http;

import '../../../core/contracts/entity_repository.dart';
import '../../../core/config/app_runtime_config.dart';
import '../../../core/network/api_request.dart';
import '../../../core/network/app_http_client.dart';
import '../../../core/network/http_package_client.dart';
import '../../../core/services/app_event_logger.dart';
import '../domain/demanda_models.dart';
import '../../../core/services/local_storage_service.dart';
import 'contracts/demanda_api_contract.dart';

class DemandaRepository implements EntityRepository<Demanda> {
  DemandaRepository({
    this.storageKey = 'sigad_demandas',
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
  Future<List<Demanda>> load() => loadDemandas();

  @override
  Future<void> save(List<Demanda> entities) => saveDemandas(entities);

  Future<List<Demanda>> loadDemandas() async {
    if (_dataSourceMode == DataSourceMode.local) {
      return _loadLocalDemandas();
    }

    try {
      return await _loadRemoteDemandas();
    } catch (error, stackTrace) {
      AppEventLogger.error(
        'demandas_remote_load_error',
        error,
        stackTrace: stackTrace,
      );
      if (_enableRemoteFallback) {
        AppEventLogger.action('demandas_remote_load_fallback_local');
        return _loadLocalDemandas();
      }
      rethrow;
    }
  }

  Future<void> saveDemandas(List<Demanda> demandas) async {
    if (_dataSourceMode == DataSourceMode.local) {
      return _saveLocalDemandas(demandas);
    }

    try {
      await _saveRemoteDemandas(demandas);
    } catch (error, stackTrace) {
      AppEventLogger.error(
        'demandas_remote_save_error',
        error,
        stackTrace: stackTrace,
      );
      rethrow;
    }
    // O servidor confirmou a gravação; falha de cache não desfaz o commit.
    try {
      await _saveLocalDemandas(demandas);
    } catch (error, stackTrace) {
      AppEventLogger.error(
        'demandas_cache_save_error',
        error,
        stackTrace: stackTrace,
      );
    }
  }

  Future<List<Demanda>> _loadLocalDemandas() async {
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

  Future<void> _saveLocalDemandas(List<Demanda> demandas) {
    return LocalStorageService.saveList(
      storageKey,
      demandas.map(_demandaToJson).toList(growable: false),
    );
  }

  Future<List<Demanda>> _loadRemoteDemandas() async {
    final response = await _remoteClient.send(
      const ApiRequest(
        path: DemandaApiContract.collectionPath,
        method: HttpMethod.get,
      ),
    );
    final payload = _extractListPayload(response.body);
    final demandas = <Demanda>[];
    for (final item in payload) {
      try {
        demandas.add(DemandaDto.fromJson(item).toDomain());
      } catch (_) {
        // Ignora itens inválidos vindos da API sem quebrar a experiência.
      }
    }
    return demandas;
  }

  Future<void> _saveRemoteDemandas(List<Demanda> demandas) {
    final payload = demandas
        .map((item) => DemandaDto.fromDomain(item).toJson())
        .toList(growable: false);
    return _remoteClient.send(
      ApiRequest(
        path: DemandaApiContract.collectionPath,
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
