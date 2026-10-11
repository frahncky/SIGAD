import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sigad/core/config/app_runtime_config.dart';
import 'package:sigad/core/network/api_error.dart';
import 'package:sigad/core/network/api_request.dart';
import 'package:sigad/core/network/api_response.dart';
import 'package:sigad/core/network/app_http_client.dart';
import 'package:sigad/features/demandas/data/demanda_repository.dart';
import 'package:sigad/features/demandas/domain/demandas_service.dart';

class _AlwaysFailingHttpClient implements AppHttpClient {
  @override
  Future<ApiResponse> send(ApiRequest request) {
    throw ApiError(message: 'Falha remota');
  }
}

class _SuccessfulHttpClient implements AppHttpClient {
  @override
  Future<ApiResponse> send(ApiRequest request) async {
    return ApiResponse(
      statusCode: 200,
      body: [
        {
          'id': '#DEM-500',
          'titulo': 'Remoto',
          'descricao': 'Carga remota',
          'prioridade': 'Alta',
          'statusLabel': 'Novo',
          'proprietario': 'NOC',
          'prazo': '01/05/2026',
        },
      ],
      headers: const {},
    );
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('DemandaRepository remote adapter', () {
    test('escrita confirmada remotamente atualiza cache local', () async {
      SharedPreferences.setMockInitialValues({});
      final repo = DemandaRepository(
        storageKey: 'test_commit_cache',
        remoteClient: _SuccessfulHttpClient(),
        dataSourceMode: DataSourceMode.remote,
      );
      final data = DemandasService.defaultDemandas();
      await repo.saveDemandas(data);
      final local = DemandaRepository(
        storageKey: 'test_commit_cache',
        dataSourceMode: DataSourceMode.local,
      );
      expect(
        (await local.loadDemandas()).map((d) => d.id),
        data.map((d) => d.id),
      );
    });
    test(
      'falha de escrita remota não grava fallback nem confirma sucesso',
      () async {
        SharedPreferences.setMockInitialValues({'test_write': '[]'});
        final repo = DemandaRepository(
          storageKey: 'test_write',
          remoteClient: _AlwaysFailingHttpClient(),
          dataSourceMode: DataSourceMode.remote,
          enableRemoteFallback: true,
        );
        await expectLater(
          repo.saveDemandas(DemandasService.defaultDemandas()),
          throwsA(isA<ApiError>()),
        );
        final prefs = await SharedPreferences.getInstance();
        expect(prefs.getString('test_write'), '[]');
      },
    );
    test('usa fallback local quando remoto falha', () async {
      SharedPreferences.setMockInitialValues({
        'test_demandas_remote': jsonEncode([
          {
            'id': '#DEM-001',
            'titulo': 'Local',
            'descricao': 'Carga local',
            'prioridade': 'Média',
            'statusLabel': 'Novo',
            'proprietario': 'TI',
            'prazo': '25/04/2026',
          },
        ]),
      });

      final repo = DemandaRepository(
        storageKey: 'test_demandas_remote',
        remoteClient: _AlwaysFailingHttpClient(),
        dataSourceMode: DataSourceMode.remote,
        enableRemoteFallback: true,
      );

      final demandas = await repo.loadDemandas();

      expect(demandas, hasLength(1));
      expect(demandas.first.id, '#DEM-001');
    });

    test('carrega remoto quando disponível em modo remote', () async {
      SharedPreferences.setMockInitialValues({});

      final repo = DemandaRepository(
        storageKey: 'test_demandas_remote',
        remoteClient: _SuccessfulHttpClient(),
        dataSourceMode: DataSourceMode.remote,
      );

      final demandas = await repo.loadDemandas();

      expect(demandas, hasLength(1));
      expect(demandas.first.id, '#DEM-500');
    });

    test('propaga erro remoto quando fallback está desativado', () async {
      SharedPreferences.setMockInitialValues({});

      final repo = DemandaRepository(
        storageKey: 'test_demandas_remote',
        remoteClient: _AlwaysFailingHttpClient(),
        dataSourceMode: DataSourceMode.remote,
        enableRemoteFallback: false,
      );

      expect(repo.loadDemandas, throwsA(isA<ApiError>()));
    });
  });
}
