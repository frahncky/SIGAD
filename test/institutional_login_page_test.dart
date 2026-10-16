import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:sigad/app/routes/app_routes.dart';
import 'package:sigad/app/theme/app_theme.dart';
import 'package:sigad/core/config/app_runtime_config.dart';
import 'package:sigad/core/network/api_request.dart';
import 'package:sigad/core/network/api_response.dart';
import 'package:sigad/core/network/app_http_client.dart';
import 'package:sigad/core/security/institutional_auth_gateway.dart';
import 'package:sigad/core/security/oidc_sign_in_service.dart';
import 'package:sigad/core/services/user_context_provider.dart';
import 'package:sigad/features/login/presentation/pages/login_page.dart';

class _FakeSignIn implements InstitutionalSignInService {
  _FakeSignIn({this.ready = true, this.cancel = false, this.fail = false});
  final bool ready;
  final bool cancel;
  final bool fail;
  int attempts = 0;

  @override
  bool get isReady => ready;

  @override
  Future<String> signIn() async {
    attempts++;
    if (cancel) throw const InstitutionalSignInCancelled();
    if (fail) throw StateError('Falha fictícia sem tokens reais');
    return 'token-de-teste';
  }
}

class _FakeValidatedApi implements AppHttpClient {
  int requests = 0;

  @override
  Future<ApiResponse> send(ApiRequest request) async {
    requests++;
    expect(request.path, '/auth/me');
    expect(request.headers['Authorization'], 'Bearer token-de-teste');
    return ApiResponse(
      statusCode: 200,
      body: {
        'id': 'docente-100',
        'name': 'Docente Teste',
        'email': 'docente@instituicao.edu.br',
        'role': 'professor',
        'expiresAt': DateTime.now()
            .add(const Duration(hours: 1))
            .toUtc()
            .toIso8601String(),
      },
      headers: const {},
    );
  }
}

Future<void> _pumpRemote(
  WidgetTester tester, {
  required InstitutionalSignInService service,
  required UserContextProvider provider,
}) async {
  await tester.pumpWidget(
    ChangeNotifierProvider<UserContextProvider>.value(
      value: provider,
      child: MaterialApp(
        theme: AppTheme.light(),
        initialRoute: '/sign-in',
        routes: {
          '/sign-in': (_) => LoginPage(
            dataSourceMode: DataSourceMode.remote,
            institutionalSignInService: service,
          ),
          AppRoutes.dashboard: (_) =>
              const Scaffold(body: Text('Área institucional autenticada')),
        },
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('sem IdP configurado não mostra formulário de senha nem entra', (
    tester,
  ) async {
    final signIn = _FakeSignIn(ready: false);
    final provider = UserContextProvider(dataSourceMode: DataSourceMode.remote);
    await _pumpRemote(tester, service: signIn, provider: provider);

    expect(find.text('Entrar com conta institucional'), findsOneWidget);
    expect(find.text('Senha'), findsNothing);
    expect(find.byType(TextField), findsNothing);
    final button = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Entrar com conta institucional'),
    );
    expect(button.onPressed, isNull);
    expect(provider.isAuthenticated, isFalse);
    expect(signIn.attempts, 0);
  });

  testWidgets('só navega depois de /auth/me validar a identidade', (
    tester,
  ) async {
    final signIn = _FakeSignIn();
    final api = _FakeValidatedApi();
    final provider = UserContextProvider(
      dataSourceMode: DataSourceMode.remote,
      institutionalGateway: InstitutionalAuthGateway(
        client: api,
        baseUrl: 'https://api.instituicao.edu.br',
      ),
    );

    await _pumpRemote(tester, service: signIn, provider: provider);
    await tester.tap(
      find.widgetWithText(FilledButton, 'Entrar com conta institucional'),
    );
    await tester.pumpAndSettle();

    expect(signIn.attempts, 1);
    expect(api.requests, 1);
    expect(provider.isAuthenticated, isTrue);
    expect(provider.userRole?.name, 'professor');
    expect(find.text('Área institucional autenticada'), findsOneWidget);
    await provider.logout();
  });

  testWidgets('cancelamento do navegador não cria sessão', (tester) async {
    final signIn = _FakeSignIn(cancel: true);
    final provider = UserContextProvider(dataSourceMode: DataSourceMode.remote);
    await _pumpRemote(tester, service: signIn, provider: provider);
    await tester.tap(
      find.widgetWithText(FilledButton, 'Entrar com conta institucional'),
    );
    await tester.pumpAndSettle();
    expect(provider.isAuthenticated, isFalse);
    expect(find.byType(LoginPage), findsOneWidget);
  });

  testWidgets('falha no IdP não autentica usuário', (tester) async {
    final signIn = _FakeSignIn(fail: true);
    final provider = UserContextProvider(dataSourceMode: DataSourceMode.remote);
    await _pumpRemote(tester, service: signIn, provider: provider);
    await tester.tap(
      find.widgetWithText(FilledButton, 'Entrar com conta institucional'),
    );
    await tester.pumpAndSettle();
    expect(provider.isAuthenticated, isFalse);
    expect(find.text('Área institucional autenticada'), findsNothing);
  });
}
