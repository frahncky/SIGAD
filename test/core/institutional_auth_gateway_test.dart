import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sigad/core/config/app_runtime_config.dart';
import 'package:sigad/core/models/user_role.dart';
import 'package:sigad/core/network/api_request.dart';
import 'package:sigad/core/network/api_response.dart';
import 'package:sigad/core/network/app_http_client.dart';
import 'package:sigad/core/security/institutional_auth_gateway.dart';
import 'package:sigad/core/services/user_context_provider.dart';
import 'package:sigad/core/services/local_storage_service.dart';

class FakeAuthClient implements AppHttpClient {
  FakeAuthClient(this.handler);
  final Future<ApiResponse> Function(ApiRequest) handler;
  @override
  Future<ApiResponse> send(ApiRequest request) => handler(request);
}

ApiResponse _response(Object? body) =>
    ApiResponse(statusCode: 200, body: body, headers: const {});

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('identidade e cargo vêm do backend, não do login local', () async {
    final gateway = InstitutionalAuthGateway(
      baseUrl: 'https://sigad.ifma.edu.br',
      now: () => DateTime.utc(2026, 10, 15),
      client: FakeAuthClient((request) async {
        expect(request.path, '/auth/me');
        expect(request.headers['Authorization'], 'Bearer token-sso');
        return _response({
          'id': 'funcional-1',
          'name': 'Docente Institucional',
          'email': 'docente@ifma.edu.br',
          'role': 'professor',
          'expiresAt': '2026-10-16T00:00:00Z',
        });
      }),
    );
    final identity = await gateway.verifyAccessToken('token-sso');
    expect(identity.user.role, UserRole.professor);
    expect(identity.user.email, 'docente@ifma.edu.br');
  });

  test(
    'rejeita role não autorizada, sessão expirada e HTTPS ausente',
    () async {
      final now = DateTime.utc(2026, 10, 15);
      final gateway = InstitutionalAuthGateway(
        baseUrl: 'https://sigad.ifma.edu.br',
        now: () => now,
        client: FakeAuthClient(
          (_) async => _response({
            'id': 'u1',
            'name': 'Usuário',
            'email': 'u@ifma.edu.br',
            'role': 'superadmin',
            'expiresAt': '2026-10-16T00:00:00Z',
          }),
        ),
      );
      await expectLater(gateway.verifyAccessToken('t'), throwsFormatException);
      final expired = InstitutionalAuthGateway(
        baseUrl: 'https://sigad.ifma.edu.br',
        now: () => now,
        client: FakeAuthClient(
          (_) async => _response({
            'id': 'u1',
            'name': 'Usuário',
            'email': 'u@ifma.edu.br',
            'role': 'professor',
            'expiresAt': '2026-10-14T00:00:00Z',
          }),
        ),
      );
      await expectLater(expired.verifyAccessToken('t'), throwsFormatException);
      final insecure = InstitutionalAuthGateway(
        baseUrl: 'http://sigad.ifma.edu.br',
        client: FakeAuthClient((_) async => _response({})),
      );
      await expectLater(insecure.verifyAccessToken('t'), throwsStateError);
    },
  );

  test(
    'sessão remota valida no servidor, não persiste token e sai no logout',
    () async {
      final now = DateTime.utc(2026, 10, 15);
      var calls = 0;
      final gateway = InstitutionalAuthGateway(
        baseUrl: 'https://sigad.ifma.edu.br',
        now: () => now,
        client: FakeAuthClient((_) async {
          calls++;
          return _response({
            'id': 'u1',
            'name': 'Docente',
            'email': 'd@ifma.edu.br',
            'role': 'professor',
            'expiresAt': '2026-10-15T12:00:00Z',
          });
        }),
      );
      final provider = UserContextProvider(
        dataSourceMode: DataSourceMode.remote,
        institutionalGateway: gateway,
        now: () => now,
      );
      await provider.loginInstitutional('token-sso');
      expect(provider.isAuthenticated, isTrue);
      expect(provider.sessionToken, 'token-sso');
      expect(provider.userRole, UserRole.professor);
      expect(await LocalStorageService.loadMap('sigad_auth_session'), isNull);
      await expectLater(
        provider.updateUser(provider.currentUser!),
        throwsStateError,
      );
      await provider.refreshSession();
      expect(calls, 2);
      await provider.logout();
      expect(provider.isAuthenticated, isFalse);
      expect(provider.sessionToken, isNull);
    },
  );

  test('login remoto recusa credenciais não verificadas', () async {
    final provider = UserContextProvider(
      dataSourceMode: DataSourceMode.remote,
      institutionalGateway: InstitutionalAuthGateway(
        baseUrl: 'https://sigad.ifma.edu.br',
        client: FakeAuthClient((_) async => throw StateError('Acesso negado')),
      ),
    );
    await expectLater(provider.loginInstitutional('invalid'), throwsStateError);
    expect(provider.isAuthenticated, isFalse);
    expect(provider.sessionToken, isNull);
  });
}
