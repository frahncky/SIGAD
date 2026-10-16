import 'package:flutter_test/flutter_test.dart';
import 'package:sigad/core/security/oidc_sign_in_service.dart';

void main() {
  const valid = OidcClientConfig(
    issuer: 'https://idp.instituicao.edu.br/realms/professores',
    clientId: 'sigad-mobile',
    redirectUri: OidcClientConfig.expectedRedirectUri,
    apiScope: 'sigad-api',
  );

  test('SSO começa desabilitado sem parâmetros institucionais', () {
    expect(
      const OidcClientConfig(
        issuer: '',
        clientId: '',
        redirectUri: '',
        apiScope: '',
      ).isConfigured,
      isFalse,
    );
  });

  test('parâmetros públicos de cliente e callback exato habilitam configuração', () {
    expect(valid.isConfigured, isTrue);
    expect(valid.scopes, ['openid', 'profile', 'email', 'sigad-api']);
  });

  test('bloqueia URL insegura, callback não cadastrado e escopo inválido', () {
    expect(
      const OidcClientConfig(
        issuer: 'http://idp.instituicao.edu.br',
        clientId: 'app',
        redirectUri: OidcClientConfig.expectedRedirectUri,
        apiScope: 'sigad-api',
      ).isConfigured,
      isFalse,
    );
    expect(
      const OidcClientConfig(
        issuer: 'https://idp.instituicao.edu.br',
        clientId: 'app',
        redirectUri: 'https://site-nao-registrado.example/callback',
        apiScope: 'sigad-api',
      ).isConfigured,
      isFalse,
    );
    expect(
      const OidcClientConfig(
        issuer: 'https://idp.instituicao.edu.br',
        clientId: 'app',
        redirectUri: OidcClientConfig.expectedRedirectUri,
        apiScope: 'offline_access',
      ).isConfigured,
      isFalse,
    );
  });
}
