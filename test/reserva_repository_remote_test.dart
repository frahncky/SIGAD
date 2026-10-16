import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sigad/core/config/app_runtime_config.dart';
import 'package:sigad/core/network/http_package_client.dart';
import 'package:sigad/core/network/api_error.dart';
import 'package:sigad/features/aulas_praticas/data/reserva_repository.dart';
import 'package:sigad/features/aulas_praticas/domain/reserva_models.dart';

const _reserva = ReservaLaboratorio(
  id: 'R1',
  professor: 'Ana',
  laboratorio: 'Laboratório 8',
  ano: 2026,
  mes: 10,
  semanaDoMes: 3,
  diaSemana: 'Qui',
  turno: Turno.matutino,
  periodo: 1,
);

Map<String, dynamic> get _json => {
  'id': 'R1',
  'professor': 'Ana',
  'laboratorio': 'Laboratório 8',
  'ano': 2026,
  'mes': 10,
  'semanaDoMes': 3,
  'diaSemana': 'Qui',
  'turno': 'matutino',
  'periodo': 1,
  'grupoId': 'R1',
};

ReservaRepository buildRepo(
  MockClient client, {
  String? Function()? tokenProvider,
}) {
  return ReservaRepository(
    dataSourceMode: DataSourceMode.remote,
    apiBaseUrl: 'https://sigad.ifma.edu.br',
    remoteClient: HttpPackageClient(
      httpClient: client,
      baseUrl: 'https://sigad.ifma.edu.br',
    ),
    tokenProvider: tokenProvider ?? () => 'token-validado-pelo-servidor',
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('GET autenticado e PUT envia expectedRevision ao servidor', () async {
    var calls = 0;
    final client = MockClient((req) async {
      calls++;
      expect(req.url.path, '/laboratorios/reservas');
      expect(
        req.headers['authorization'],
        'Bearer token-validado-pelo-servidor',
      );
      if (req.method == 'GET') {
        return http.Response(
          jsonEncode({
            'revision': 'v1',
            'items': [_json],
          }),
          200,
        );
      }
      expect(req.method, 'PUT');
      final body = jsonDecode(req.body) as Map<String, dynamic>;
      expect(body['expectedRevision'], calls == 2 ? 'v1' : 'v2');
      expect((body['items'] as List).first['laboratorio'], 'Laboratório 8');
      return http.Response(jsonEncode({'revision': 'v2'}), 200);
    });
    final repo = buildRepo(client);
    final loaded = await repo.loadReservas();
    expect(loaded, hasLength(1));
    expect(loaded.first.turno, Turno.matutino);
    await repo.saveReservas(loaded);
    await repo.saveReservas([_reserva]);
    expect(calls, 3);
  });

  test('não permite gravar sem carregar revisão inicial', () async {
    final repo = buildRepo(MockClient((_) async => http.Response('{}', 200)));
    await expectLater(repo.saveReservas([_reserva]), throwsStateError);
  });

  test('409 exige recarga e não escreve cache local', () async {
    var calls = 0;
    final repo = buildRepo(
      MockClient((req) async {
        calls++;
        if (req.method == 'GET') {
          return http.Response(
            jsonEncode({'revision': 'v1', 'items': []}),
            200,
          );
        }
        return http.Response(jsonEncode({'error': 'conflict'}), 409);
      }),
    );
    await repo.loadReservas();
    await expectLater(
      repo.saveReservas([_reserva]),
      throwsA(isA<ReservaConflitoException>()),
    );
    await expectLater(repo.saveReservas([_reserva]), throwsStateError);
    expect(calls, 2);
  });

  test('falha do servidor não é tratada como sucesso local', () async {
    final repo = buildRepo(
      MockClient(
        (req) async => http.Response(
          req.method == 'GET'
              ? jsonEncode({'revision': 'v1', 'items': []})
              : '{}',
          req.method == 'GET' ? 200 : 503,
        ),
      ),
    );
    await repo.loadReservas();
    await expectLater(repo.saveReservas([_reserva]), throwsA(isA<ApiError>()));
  });

  test(
    'bloqueia token ausente, API placeholder e respostas incompletas',
    () async {
      final client = MockClient((_) async => http.Response('{}', 200));
      await expectLater(
        buildRepo(client, tokenProvider: () => null).loadReservas(),
        throwsStateError,
      );
      final insecure = ReservaRepository(
        dataSourceMode: DataSourceMode.remote,
        remoteClient: HttpPackageClient(
          httpClient: client,
          baseUrl: 'https://api.sigad.local',
        ),
        tokenProvider: () => 'token',
      );
      await expectLater(insecure.loadReservas(), throwsStateError);
      await expectLater(
        buildRepo(client).loadReservas(),
        throwsFormatException,
      );
    },
  );
}
