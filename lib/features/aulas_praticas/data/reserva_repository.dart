import 'package:http/http.dart' as http;

import '../../../core/config/app_runtime_config.dart';
import '../../../core/network/api_error.dart';
import '../../../core/network/api_request.dart';
import '../../../core/network/app_http_client.dart';
import '../../../core/network/http_package_client.dart';
import '../../../core/network/api_config.dart';
import '../../../core/services/local_storage_service.dart';
import '../domain/reserva_models.dart';

/// O servidor deve aplicar expectedRevision e a unicidade de cada horário
/// na mesma transação, inclusive para alterações de múltiplas semanas.
class ReservaConflitoException implements Exception {
  const ReservaConflitoException();
  @override
  String toString() => 'A agenda foi alterada por outro usuário.';
}

class ReservaRepository {
  ReservaRepository({
    this.storageKey = 'sigad_reservas',
    int? legacyYear,
    DataSourceMode? dataSourceMode,
    AppHttpClient? remoteClient,
    String? Function()? tokenProvider,
    String apiBaseUrl = ApiConfig.baseUrl,
  }) : legacyYear = legacyYear ?? DateTime.now().year,
       _dataSourceMode = dataSourceMode ?? AppRuntimeConfig.dataSourceMode,
       _remoteClient =
           remoteClient ?? HttpPackageClient(httpClient: http.Client()),
       _tokenProvider = tokenProvider,
       _apiBaseUrl = apiBaseUrl;

  final String storageKey;
  final int legacyYear;
  final DataSourceMode _dataSourceMode;
  final AppHttpClient _remoteClient;
  final String? Function()? _tokenProvider;
  final String _apiBaseUrl;
  String? _revision;

  bool get isShared => _dataSourceMode == DataSourceMode.remote;

  Future<List<ReservaLaboratorio>> loadReservas() async {
    if (isShared) {
      _ensureTrustedRemote();
      final response = await _remoteClient.send(
        ApiRequest(path: '/laboratorios/reservas', headers: _authHeaders()),
      );
      final body = _requiredMap(response.body);
      final revision = body['revision'];
      final items = body['items'];
      if (revision is! String || revision.trim().isEmpty || items is! List) {
        throw const FormatException(
          'Resposta inválida da agenda institucional.',
        );
      }
      // Parse completo antes de atualizar a revisão. Não aceitar agenda
      // parcialmente decodificada e arriscar apagar dados de outros usuários.
      final reservas = items
          .map((item) {
            if (item is! Map || !item.containsKey('ano')) {
              throw const FormatException('Reserva remota inválida.');
            }
            return _reservaFromJson(Map<String, dynamic>.from(item));
          })
          .toList(growable: false);
      _revision = revision;
      return reservas;
    }

    final list = await LocalStorageService.loadList(storageKey);
    if (list.isEmpty) return const [];

    final reservas = <ReservaLaboratorio>[];
    var migratedLegacyYear = false;
    for (final item in list) {
      try {
        final reserva = _reservaFromJson(item);
        reservas.add(reserva);
        if (!item.containsKey('ano')) migratedLegacyYear = true;
      } catch (_) {
        // Apenas o modo local permite ignorar dados legados inválidos.
      }
    }
    if (migratedLegacyYear) await saveReservas(reservas);
    return reservas;
  }

  Future<void> saveReservas(List<ReservaLaboratorio> reservas) async {
    if (isShared) {
      _ensureTrustedRemote();
      _assertUniqueSlots(reservas);
      final revision = _revision;
      if (revision == null || revision.isEmpty) {
        throw StateError('Carregue a agenda institucional antes de alterar.');
      }
      try {
        final response = await _remoteClient.send(
          ApiRequest(
            path: '/laboratorios/reservas',
            method: HttpMethod.put,
            headers: _authHeaders(),
            body: {
              'expectedRevision': revision,
              'items': reservas.map(_reservaToJson).toList(growable: false),
            },
          ),
        );
        final body = _requiredMap(response.body);
        final nextRevision = body['revision'];
        if (nextRevision is! String || nextRevision.trim().isEmpty) {
          // A confirmação precisa conter uma nova revisão do servidor.
          _revision = null;
          throw const FormatException('O servidor não confirmou a revisão.');
        }
        _revision = nextRevision;
        return;
      } on ApiError catch (error) {
        if (error.statusCode == 409 || error.statusCode == 412) {
          _revision = null;
          throw const ReservaConflitoException();
        }
        rethrow; // Sem fallback local ao salvar uma agenda compartilhada.
      }
    }

    return LocalStorageService.saveList(
      storageKey,
      reservas.map(_reservaToJson).toList(growable: false),
    );
  }

  void _assertUniqueSlots(List<ReservaLaboratorio> reservas) {
    final occupied = <String>{};
    for (final r in reservas) {
      final slot =
          '${r.laboratorio}| ${r.ano}|${r.mes}|${r.semanaDoMes}|'
          '${r.diaSemana}|${r.turno.name}|${r.periodo}';
      if (!occupied.add(slot)) {
        throw const ReservaConflitoException();
      }
    }
  }

  void _ensureTrustedRemote() {
    final uri = Uri.tryParse(_apiBaseUrl);
    if (uri == null ||
        uri.scheme != 'https' ||
        uri.host.isEmpty ||
        uri.host.endsWith('.local')) {
      throw StateError('Configure uma API institucional HTTPS válida.');
    }
  }

  Map<String, String> _authHeaders() {
    final token = _tokenProvider?.call()?.trim();
    if (token == null || token.isEmpty) {
      throw StateError(
        'Entre com sua conta institucional para acessar reservas.',
      );
    }
    return {'Authorization': 'Bearer $token'};
  }

  Map<String, dynamic> _requiredMap(Object? body) {
    if (body is! Map) {
      throw const FormatException('Resposta inválida da agenda institucional.');
    }
    return Map<String, dynamic>.from(body);
  }

  Map<String, dynamic> _reservaToJson(ReservaLaboratorio r) => {
    'id': r.id,
    'professor': r.professor,
    'laboratorio': r.laboratorio,
    'ano': r.ano,
    'mes': r.mes,
    'semanaDoMes': r.semanaDoMes,
    'diaSemana': r.diaSemana,
    'turno': r.turno.name,
    'periodo': r.periodo,
    if (r.disciplina != null) 'disciplina': r.disciplina,
    'grupoId': r.grupoId,
  };

  ReservaLaboratorio _reservaFromJson(Map<String, dynamic> json) {
    return ReservaLaboratorio(
      id: json['id'] as String,
      professor: json['professor'] as String,
      laboratorio: json['laboratorio'] as String,
      ano: json['ano'] as int? ?? legacyYear,
      mes: json['mes'] as int,
      semanaDoMes: json['semanaDoMes'] as int,
      diaSemana: json['diaSemana'] as String,
      turno: Turno.values.firstWhere((turno) => turno.name == json['turno']),
      periodo: json['periodo'] as int,
      disciplina: json['disciplina'] as String?,
      grupoId: json['grupoId'] as String?,
    );
  }
}
