import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sigad/core/models/user.dart';
import 'package:sigad/core/models/user_role.dart';
import 'package:sigad/core/services/auth_session_repository.dart';
import 'package:sigad/core/services/user_context_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('UserContextProvider session', () {
    test('persiste e restaura sessão autenticada', () async {
      SharedPreferences.setMockInitialValues({});

      final sessionRepo = AuthSessionRepository(storageKey: 'test_auth_session');
      final provider = UserContextProvider(sessionRepository: sessionRepo);

      final user = User(
        id: 'u1',
        name: 'Usuário Teste',
        email: 'teste@sigad.dev',
        role: UserRole.coordenador,
        createdAt: DateTime(2026, 1, 1),
        lastLogin: DateTime(2026, 1, 2),
      );

      await provider.login(user, sessionToken: 'token_abc');

      final restoredProvider = UserContextProvider(sessionRepository: sessionRepo);
      await restoredProvider.restoreSession();

      expect(restoredProvider.isAuthenticated, isTrue);
      expect(restoredProvider.currentUser?.email, 'teste@sigad.dev');
      expect(restoredProvider.sessionToken, 'token_abc');
      expect(restoredProvider.requiresReauthentication, isFalse);
    });

    test('limpa sessão no logout', () async {
      SharedPreferences.setMockInitialValues({});

      final sessionRepo = AuthSessionRepository(storageKey: 'test_auth_session');
      final provider = UserContextProvider(sessionRepository: sessionRepo);

      final user = User(
        id: 'u2',
        name: 'Usuário 2',
        email: 'u2@sigad.dev',
        role: UserRole.professor,
        createdAt: DateTime(2026, 1, 1),
      );

      await provider.login(user, sessionToken: 'token_logout');
      await provider.logout();

      final restoredProvider = UserContextProvider(sessionRepository: sessionRepo);
      await restoredProvider.restoreSession();

      expect(restoredProvider.isAuthenticated, isFalse);
      expect(restoredProvider.sessionToken, isNull);
    });

    test('força reautenticação quando sessão está expirada', () async {
      SharedPreferences.setMockInitialValues({});

      final sessionRepo = AuthSessionRepository(storageKey: 'test_auth_session');
      final provider = UserContextProvider(sessionRepository: sessionRepo);

      final user = User(
        id: 'u3',
        name: 'Usuário Expirado',
        email: 'expirado@sigad.dev',
        role: UserRole.servidorAdministrativo,
        createdAt: DateTime(2026, 1, 1),
      );

      await sessionRepo.save(
        user: user,
        sessionToken: 'token_expirado',
        expiresAt: DateTime.now().subtract(const Duration(minutes: 1)),
      );

      await provider.restoreSession();

      expect(provider.isAuthenticated, isFalse);
      expect(provider.sessionToken, isNull);
      expect(provider.isSessionRestored, isTrue);
    });
  });
}
