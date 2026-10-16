import 'package:flutter/foundation.dart';
import 'package:flutter_appauth/flutter_appauth.dart';

import '../network/api_config.dart';

/// Parâmetros públicos do cliente OIDC, provisionados pela TI institucional.
///
/// Nenhuma configuração aqui é uma credencial. A URL de retorno precisa
/// corresponder ao esquema registrado em Android e iOS.
class OidcClientConfig {
  const OidcClientConfig({
    required this.issuer,
    required this.clientId,
    required this.redirectUri,
    required this.apiScope,
  });

  static const String redirectScheme = 'sigad-auth';
  static const String expectedRedirectUri = 'sigad-auth://callback';

  static const OidcClientConfig environment = OidcClientConfig(
    issuer: String.fromEnvironment('SIGAD_OIDC_ISSUER', defaultValue: ''),
    clientId: String.fromEnvironment('SIGAD_OIDC_CLIENT_ID', defaultValue: ''),
    redirectUri: String.fromEnvironment(
      'SIGAD_OIDC_REDIRECT_URI',
      defaultValue: '',
    ),
    apiScope: String.fromEnvironment('SIGAD_OIDC_API_SCOPE', defaultValue: ''),
  );

  final String issuer;
  final String clientId;
  final String redirectUri;
  final String apiScope;

  bool get isConfigured {
    final provider = Uri.tryParse(issuer);
    if (provider == null ||
        provider.scheme != 'https' ||
        provider.host.isEmpty ||
        provider.userInfo.isNotEmpty ||
        provider.hasQuery ||
        provider.hasFragment ||
        provider.host.endsWith('.local')) {
      return false;
    }
    // Schemas específicos devem estar cadastrados no IdP e nos sistemas
    // operacionais antes de habilitar a autenticação.
    return redirectUri == expectedRedirectUri &&
        clientId.trim().isNotEmpty &&
        clientId == clientId.trim() &&
        apiScope.trim().isNotEmpty &&
        !apiScope.contains(RegExp(r'\s')) &&
        apiScope != 'openid' &&
        apiScope != 'profile' &&
        apiScope != 'email' &&
        apiScope != 'offline_access';
  }

  List<String> get scopes => ['openid', 'profile', 'email', apiScope];
}

class InstitutionalSignInCancelled implements Exception {
  const InstitutionalSignInCancelled();
}

/// Porta injetável para permitir testes sem abrir o browser nem expor tokens.
abstract class InstitutionalSignInService {
  bool get isReady;
  Future<String> signIn();
}

/// A biblioteca AppAuth utiliza o browser do sistema e Authorization Code
/// + PKCE (S256), sem coletar senhas ou segredos no aplicativo.
class AppAuthInstitutionalSignInService implements InstitutionalSignInService {
  AppAuthInstitutionalSignInService({
    this.config = OidcClientConfig.environment,
    FlutterAppAuth? appAuth,
  }) : _appAuth = appAuth ?? const FlutterAppAuth();

  final OidcClientConfig config;
  final FlutterAppAuth _appAuth;

  bool get _backendConfigured {
    final base = Uri.tryParse(ApiConfig.baseUrl);
    return base != null &&
        base.scheme == 'https' &&
        base.host.isNotEmpty &&
        base.userInfo.isEmpty &&
        !base.host.endsWith('.local') &&
        base.host != 'localhost';
  }

  @override
  bool get isReady =>
      config.isConfigured &&
      _backendConfigured &&
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  @override
  Future<String> signIn() async {
    if (!isReady) {
      throw StateError('SSO institucional não configurado neste dispositivo.');
    }
    try {
      final result = await _appAuth.authorizeAndExchangeCode(
        AuthorizationTokenRequest(
          config.clientId,
          config.redirectUri,
          issuer: config.issuer,
          scopes: config.scopes,
          // Não usar clientSecret no app móvel (cliente público com PKCE).
        ),
      );
      final token = result.accessToken?.trim();
      if (token == null || token.isEmpty) {
        throw StateError('O provedor não retornou token de acesso.');
      }
      final type = result.tokenType;
      if (type != null && type.toLowerCase() != 'bearer') {
        throw StateError('O provedor retornou um tipo de token não suportado.');
      }
      final expiration = result.accessTokenExpirationDateTime;
      if (expiration != null && !expiration.isAfter(DateTime.now())) {
        throw StateError('O provedor retornou credencial expirada.');
      }
      // Refresh e ID tokens não são persistidos ou usados como access tokens.
      // A API confirmará assinatura, audience, issuer e perfil em /auth/me.
      return token;
    } on FlutterAppAuthUserCancelledException {
      throw const InstitutionalSignInCancelled();
    }
  }
}
