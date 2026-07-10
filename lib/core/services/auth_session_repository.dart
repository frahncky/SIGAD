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
        sessionToken: _restoreSessionToken(raw),
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
  }) {
    final expiry = expiresAt ?? DateTime.now().add(const Duration(hours: 8));
    return LocalStorageService.saveMap(storageKey, {
      'id': user.id,
      'name': user.name,
      'email': user.email,
      'role': user.role.name,
      'createdAt': user.createdAt.toIso8601String(),
      'lastLogin': user.lastLogin?.toIso8601String(),
      // Não persistimos o token completo para reduzir exposição em storage local.
      'sessionTokenHint': _tokenHint(sessionToken),
      'expiresAt': expiry.toIso8601String(),
    });
  }

  Future<void> clear() {
    return LocalStorageService.remove(storageKey);
  }

  String _restoreSessionToken(Map<String, dynamic> raw) {
    final hinted = raw['sessionTokenHint'] as String?;
    if (hinted != null && hinted.trim().isNotEmpty) {
      return 'restored_$hinted';
    }

    // Migração para payloads antigos que persistiam token completo.
    final legacy = raw['sessionToken'] as String?;
    if (legacy != null && legacy.trim().isNotEmpty) {
      return 'legacy_${_tokenHint(legacy)}';
    }

    return 'local_session';
  }

  String _tokenHint(String token) {
    final clean = token.trim();
    if (clean.isEmpty) return 'session';
    if (clean.length <= 4) return clean;
    return clean.substring(clean.length - 4);
  }
}
