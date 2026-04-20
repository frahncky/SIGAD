import 'package:http/http.dart' as http;

import '../../../core/contracts/entity_repository.dart';
import '../../../core/config/app_runtime_config.dart';
import '../../../core/network/api_request.dart';
import '../../../core/network/app_http_client.dart';
import '../../../core/network/http_package_client.dart';
import '../../../core/services/app_event_logger.dart';
import '../domain/kanban_models.dart';
import '../../../core/services/local_storage_service.dart';
import 'contracts/kanban_api_contract.dart';

class KanbanRepository implements EntityRepository<KanbanCardModel> {
  KanbanRepository({
    this.storageKey = 'sigad_kanban',
    AppHttpClient? remoteClient,
    DataSourceMode? dataSourceMode,
    bool? enableRemoteFallback,
  })  : _remoteClient = remoteClient ?? HttpPackageClient(httpClient: http.Client()),
        _dataSourceMode = dataSourceMode ?? AppRuntimeConfig.dataSourceMode,
        _enableRemoteFallback = enableRemoteFallback ?? AppRuntimeConfig.enableRemoteFallback;

  final String storageKey;
  final AppHttpClient _remoteClient;
  final DataSourceMode _dataSourceMode;
  final bool _enableRemoteFallback;

  @override
  Future<List<KanbanCardModel>> load() => loadCards();

  @override
  Future<void> save(List<KanbanCardModel> entities) => saveCards(entities);

  Future<List<KanbanCardModel>> loadCards() async {
    if (_dataSourceMode == DataSourceMode.local) {
      return _loadLocalCards();
    }

    try {
      return await _loadRemoteCards();
    } catch (error, stackTrace) {
      AppEventLogger.error('kanban_remote_load_error', error, stackTrace: stackTrace);
      if (_enableRemoteFallback) {
        AppEventLogger.action('kanban_remote_load_fallback_local');
        return _loadLocalCards();
      }
      rethrow;
    }
  }

  Future<void> saveCards(List<KanbanCardModel> cards) async {
    if (_dataSourceMode == DataSourceMode.local) {
      return _saveLocalCards(cards);
    }

    try {
      await _saveRemoteCards(cards);
      await _saveLocalCards(cards);
    } catch (error, stackTrace) {
      AppEventLogger.error('kanban_remote_save_error', error, stackTrace: stackTrace);
      if (_enableRemoteFallback) {
        AppEventLogger.action('kanban_remote_save_fallback_local');
        return _saveLocalCards(cards);
      }
      rethrow;
    }
  }

  Future<List<KanbanCardModel>> _loadLocalCards() async {
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

  Future<void> _saveLocalCards(List<KanbanCardModel> cards) {
    return LocalStorageService.saveList(
      storageKey,
      cards.map(_cardToJson).toList(growable: false),
    );
  }

  Future<List<KanbanCardModel>> _loadRemoteCards() async {
    final response = await _remoteClient.send(
      const ApiRequest(
        path: KanbanApiContract.collectionPath,
        method: HttpMethod.get,
      ),
    );
    final payload = _extractListPayload(response.body);
    final cards = <KanbanCardModel>[];
    for (final item in payload) {
      try {
        cards.add(KanbanCardDto.fromJson(item).toDomain());
      } catch (_) {
        // Ignora itens inválidos vindos da API sem quebrar a experiência.
      }
    }
    return cards;
  }

  Future<void> _saveRemoteCards(List<KanbanCardModel> cards) {
    final payload = cards.map((item) => KanbanCardDto.fromDomain(item).toJson()).toList(growable: false);
    return _remoteClient.send(
      ApiRequest(
        path: KanbanApiContract.collectionPath,
        method: HttpMethod.put,
        body: payload,
      ),
    );
  }

  List<Map<String, dynamic>> _extractListPayload(Object? body) {
    if (body is List) {
      return body.whereType<Map>().map((item) => Map<String, dynamic>.from(item)).toList(growable: false);
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
