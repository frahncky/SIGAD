import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sigad/core/models/user.dart';
import 'package:sigad/core/models/user_role.dart';
import 'package:sigad/core/services/auth_session_repository.dart';
import 'package:sigad/core/services/user_context_provider.dart';
import 'package:sigad/core/services/local_storage_service.dart';
import 'package:sigad/core/config/app_runtime_config.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('UserContextProvider session', () {
    if (!AppRuntimeConfig.allowLocalDemo) {
      test('login simulado bloqueado fora de desenvolvimento local', () async {
        SharedPreferences.setMockInitialValues({});
        final provider = UserContextProvider();
        final user = User(
          id: 'u',
          name: 'Demo',
          email: 'demo@example.invalid',
          role: UserRole.professor,
          createdAt: DateTime(2026),
        );
        await expectLater(provider.login(user), throwsStateError);
        expect(provider.isAuthenticated, isFalse);
        expect(provider.sessionToken, isNull);
        await expectLater(provider.refreshSession(), throwsStateError);
      });
      return;
    }
    test(
      'persiste demo sem armazenar credencial e restaura apenas demo',
      () async {
        SharedPreferences.setMockInitialValues({});

        final sessionRepo = AuthSessionRepository(
          storageKey: 'test_auth_session',
        );
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

        final restoredProvider = UserContextProvider(
          sessionRepository: sessionRepo,
        );
        await restoredProvider.restoreSession();

        expect(restoredProvider.isAuthenticated, isTrue);
        expect(restoredProvider.currentUser?.email, 'teste@sigad.dev');
        expect(restoredProvider.sessionToken, isNull);
        final raw = await LocalStorageService.loadMap('test_auth_session');
        expect(raw!['sessionKind'], 'demo');
        expect(raw.containsKey('sessionToken'), isFalse);
        expect(raw.containsKey('sessionTokenHint'), isFalse);
        expect(restoredProvider.sessionToken, isNot('token_abc'));
        expect(restoredProvider.requiresReauthentication, isFalse);
      },
    );

    test('token hint antigo não autentica nem permanece salvo', () async {
      SharedPreferences.setMockInitialValues({});
      final repository = AuthSessionRepository(storageKey: 'legacy');
      await LocalStorageService.saveMap('legacy', {
        'sessionTokenHint': 'abcd',
        'sessionToken': 'old_private_token',
      });
      final provider = UserContextProvider(sessionRepository: repository);
      await provider.restoreSession();
      expect(provider.isAuthenticated, isFalse);
      expect(provider.sessionToken, isNull);
      expect(await LocalStorageService.loadMap('legacy'), isNull);
    });

    test('expiração em memória remove acesso e impede renovação', () async {
      SharedPreferences.setMockInitialValues({});
      var now = DateTime(2026, 1, 1);
      final provider = UserContextProvider(now: () => now);
      final user = User(
        id: 'demo',
        name: 'Demo',
        email: 'demo@example.invalid',
        role: UserRole.professor,
        createdAt: now,
      );
      await provider.login(user);
      expect(provider.isAuthenticated, isTrue);
      now = now.add(const Duration(hours: 8));
      expect(provider.requiresReauthentication, isTrue);
      expect(provider.isAuthenticated, isFalse);
      expect(provider.currentUser, isNull);
      expect(provider.hasRole(UserRole.professor), isFalse);
      expect(provider.hasAnyRole({UserRole.professor}), isFalse);
      await expectLater(provider.refreshSession(), throwsStateError);
    });
    testWidgets(
      'notifica expiração em tela ativa e cancela timer ao desmontar',
      (tester) async {
        SharedPreferences.setMockInitialValues({});
        var now = DateTime(2026);
        final provider = UserContextProvider(now: () => now);
        await provider.login(
          User(
            id: 'demo',
            name: 'Demo',
            email: 'demo@example.invalid',
            role: UserRole.professor,
            createdAt: now,
          ),
        );
        var notifications = 0;
        void listener() {
          notifications++;
        }

        provider.addListener(listener);
        now = now.add(const Duration(hours: 8));
        await tester.pump(const Duration(hours: 8));
        expect(notifications, 1);
        expect(provider.isAuthenticated, isFalse);
        provider.removeListener(listener);
        provider.dispose();
      },
    );
    test('limpa sessão no logout', () async {
      SharedPreferences.setMockInitialValues({});

      final sessionRepo = AuthSessionRepository(
        storageKey: 'test_auth_session',
      );
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

      final restoredProvider = UserContextProvider(
        sessionRepository: sessionRepo,
      );
      await restoredProvider.restoreSession();

      expect(restoredProvider.isAuthenticated, isFalse);
      expect(restoredProvider.sessionToken, isNull);
    });

    test('força reautenticação quando sessão está expirada', () async {
      SharedPreferences.setMockInitialValues({});

      final sessionRepo = AuthSessionRepository(
        storageKey: 'test_auth_session',
      );
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
