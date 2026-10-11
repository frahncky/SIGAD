import '../config/app_runtime_config.dart';
import '../models/user.dart';
import '../models/user_role.dart';
import 'local_storage_service.dart';

class AuthSessionData {
  const AuthSessionData({
    required this.user,
    required this.sessionToken,
    required this.expiresAt,
  });

  final User user;
  final String sessionToken;
  final DateTime expiresAt;
}

class AuthSessionRepository {
  AuthSessionRepository({this.storageKey = 'sigad_auth_session'});

  final String storageKey;

  Future<AuthSessionData?> load() async {
    final raw = await LocalStorageService.loadMap(storageKey);
    if (raw == null) return null;
    // A saved profile or token hint is not proof of remote authentication.
    if (!AppRuntimeConfig.allowLocalDemo || raw['sessionKind'] != 'demo') {
      await clear();
      return null;
    }

    try {
      final roleName = raw['role'] as String;
      final role = UserRole.values.firstWhere((item) => item.name == roleName);

      final user = User(
        id: raw['id'] as String,
        name: raw['name'] as String,
        email: raw['email'] as String,
        role: role,
        createdAt: DateTime.parse(raw['createdAt'] as String),
        lastLogin: raw['lastLogin'] == null
            ? null
            : DateTime.parse(raw['lastLogin'] as String),
      );

      return AuthSessionData(
        user: user,
        sessionToken: 'local_demo',
        expiresAt: DateTime.parse(raw['expiresAt'] as String),
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> save({
    required User user,
    required String sessionToken,
    DateTime? expiresAt,
  }) async {
    if (!AppRuntimeConfig.allowLocalDemo) {
      throw StateError('Autenticação institucional não integrada.');
    }
    final expiry = expiresAt ?? DateTime.now().add(const Duration(hours: 8));
    return LocalStorageService.saveMap(storageKey, {
      'id': user.id,
      'name': user.name,
      'email': user.email,
      'role': user.role.name,
      'createdAt': user.createdAt.toIso8601String(),
      'lastLogin': user.lastLogin?.toIso8601String(),
      'sessionKind': 'demo',
      'expiresAt': expiry.toIso8601String(),
    });
  }

  Future<void> clear() {
    return LocalStorageService.remove(storageKey);
  }
}
