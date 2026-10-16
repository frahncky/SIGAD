import 'package:http/http.dart' as http;

import '../models/user.dart';
import '../models/user_role.dart';
import '../network/api_config.dart';
import '../network/api_request.dart';
import '../network/app_http_client.dart';
import '../network/http_package_client.dart';

/// Identidade validada pelo backend institucional (não pelo perfil escolhido
/// no cliente). O token de acesso deve vir de um fluxo OIDC/PKCE autorizado.
class InstitutionalIdentity {
  const InstitutionalIdentity({
    required this.user,
    required this.expiresAt,
  });

  final User user;
  final DateTime expiresAt;
}

class InstitutionalAuthGateway {
  InstitutionalAuthGateway({
    AppHttpClient? client,
    this.baseUrl = ApiConfig.baseUrl,
    DateTime Function()? now,
  }) : _client = client ?? HttpPackageClient(httpClient: http.Client()),
       _now = now ?? DateTime.now;

  final AppHttpClient _client;
  final String baseUrl;
  final DateTime Function() _now;

  Future<InstitutionalIdentity> verifyAccessToken(String accessToken) async {
    final uri = Uri.tryParse(baseUrl);
    if (uri == null || uri.scheme != 'https' || uri.host.isEmpty ||
        uri.host.endsWith('.local')) {
      throw StateError('API institucional HTTPS não configurada.');
    }
    final credential = accessToken.trim();
    if (credential.isEmpty) {
      throw ArgumentError.value('', 'accessToken', 'Credencial ausente.');
    }
    final response = await _client.send(
      ApiRequest(
        path: '/auth/me',
        headers: {'Authorization': 'Bearer $credential'},
      ),
    );
    final body = response.body;
    if (body is! Map) {
      throw const FormatException('Resposta de autenticação inválida.');
    }
    final claims = Map<String, dynamic>.from(body);
    final id = claims['id'];
    final name = claims['name'];
    final email = claims['email'];
    final roleRaw = claims['role'];
    final expiresAtRaw = claims['expiresAt'];
    if (id is! String || id.trim().isEmpty ||
        name is! String || name.trim().isEmpty ||
        email is! String || email.trim().isEmpty ||
        roleRaw is! String || expiresAtRaw is! String) {
      throw const FormatException('Identidade institucional incompleta.');
    }
    final expiresAt = DateTime.tryParse(expiresAtRaw)?.toUtc();
    if (expiresAt == null || !expiresAt.isAfter(_now().toUtc())) {
      throw const FormatException('Sessão institucional inválida ou expirada.');
    }
    UserRole role;
    try {
      role = UserRole.values.firstWhere((value) => value.name == roleRaw);
    } on StateError {
      throw const FormatException('Perfil institucional não autorizado.');
    }
    return InstitutionalIdentity(
      user: User(
        id: id,
        name: name,
        email: email,
        role: role,
        createdAt: _now(),
        lastLogin: _now(),
      ),
      expiresAt: expiresAt,
    );
  }
}
