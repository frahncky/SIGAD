import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sigad/core/models/user.dart';
import 'package:sigad/core/models/user_role.dart';
import 'package:sigad/core/services/greeting_name_provider.dart';
import 'package:sigad/core/services/greeting_name_repository.dart';
import 'package:sigad/core/services/user_context_provider.dart';

User account(String id) => User(
  id: id,
  name: 'Maria Souza',
  email: 'test@example.com',
  role: UserRole.professor,
  createdAt: DateTime(2026),
);

class FailingRepository extends GreetingNameRepository {
  @override
  Future<void> save(String userId, String? name) async =>
      throw StateError('failed');
}

class DelayedRepository extends GreetingNameRepository {
  final firstLoad = Completer<String?>();
  final pendingSave = Completer<void>();
  @override
  Future<String?> load(String userId) =>
      userId == 'a' ? firstLoad.future : Future.value('Nome B');
  @override
  Future<void> save(String userId, String? name) => pendingSave.future;
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));
  test('leitura tardia não vaza após troca da conta', () async {
    final users = UserContextProvider();
    await users.login(account('a'));
    final repository = DelayedRepository();
    final provider = GreetingNameProvider(users, repository: repository);
    addTearDown(provider.dispose);
    addTearDown(users.dispose);
    await users.login(account('b'));
    await Future<void>.delayed(Duration.zero);
    repository.firstLoad.complete('Nome A');
    await Future<void>.delayed(Duration.zero);
    expect(provider.displayName, 'Nome B');
  });
  test(
    'gravação tardia não muda saudação de outra conta nem aceita duplicata',
    () async {
      final users = UserContextProvider();
      await users.login(account('a'));
      final repository = DelayedRepository()..firstLoad.complete(null);
      final provider = GreetingNameProvider(users, repository: repository);
      addTearDown(provider.dispose);
      addTearDown(users.dispose);
      await Future<void>.delayed(Duration.zero);
      final pending = provider.save('Novo A');
      final failed = expectLater(pending, throwsStateError);
      await expectLater(provider.save('Duplicado'), throwsStateError);
      await users.login(account('b'));
      await Future<void>.delayed(Duration.zero);
      repository.pendingSave.complete();
      await failed;
      expect(provider.displayName, 'Nome B');
    },
  );
  test(
    'persiste por conta, logout limpa memória e vazio volta ao primeiro nome',
    () async {
      final users = UserContextProvider();
      final provider = GreetingNameProvider(users);
      addTearDown(provider.dispose);
      addTearDown(users.dispose);
      await users.login(account('a'));
      await Future<void>.delayed(Duration.zero);
      expect(provider.displayName, 'Maria');
      await provider.save('  Maria Clara  ');
      expect(provider.displayName, 'Maria Clara');
      expect(users.currentUser!.name, 'Maria Souza');
      await users.logout();
      expect(provider.customName, isNull);
      await users.login(account('b'));
      await Future<void>.delayed(Duration.zero);
      expect(provider.displayName, 'Maria');
      await expectLater(
        provider.save('Wrong', expectedUserId: 'a'),
        throwsStateError,
      );
      await users.login(account('a'));
      await Future<void>.delayed(Duration.zero);
      expect(provider.displayName, 'Maria Clara');
      final restored = GreetingNameProvider(users);
      await Future<void>.delayed(Duration.zero);
      expect(restored.displayName, 'Maria Clara');
      restored.dispose();
      await provider.save(' ');
      expect(provider.displayName, 'Maria');
    },
  );
  test(
    'falha de gravação preserva nome anterior e libera nova tentativa',
    () async {
      final users = UserContextProvider();
      await users.login(account('a'));
      final provider = GreetingNameProvider(
        users,
        repository: FailingRepository(),
      );
      addTearDown(provider.dispose);
      addTearDown(users.dispose);
      await Future<void>.delayed(Duration.zero);
      await expectLater(provider.save('Novo'), throwsStateError);
      expect(provider.displayName, 'Maria');
      expect(provider.saving, isFalse);
    },
  );
}
