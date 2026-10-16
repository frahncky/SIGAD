import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sigad/core/models/user.dart';
import 'package:sigad/core/models/user_role.dart';
import 'package:sigad/core/services/user_context_provider.dart';
import 'package:sigad/core/services/greeting_name_provider.dart';
import 'package:sigad/core/services/greeting_name_repository.dart';
import 'package:sigad/features/configuracoes/presentation/greeting_name_dialog.dart';

class Failure extends GreetingNameRepository {
  int attempts = 0;
  @override
  Future<void> save(String userId, String? name) async {
    attempts++;
    throw StateError('failed');
  }
}

void main() {
  testWidgets('erro mantém edição e cancelamento com teclado e fonte200', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    tester.view.viewInsets = const FakeViewPadding(bottom: 250);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetViewInsets);
    final users = UserContextProvider();
    await users.login(
      User(
        id: 'a',
        name: 'Maria Souza',
        email: 'test@example.com',
        role: UserRole.professor,
        createdAt: DateTime(2026),
      ),
    );
    final repository = Failure();
    final preference = GreetingNameProvider(users, repository: repository);
    await tester.pump();
    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: const TextScaler.linear(2)),
          child: child!,
        ),
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () => showDialog<void>(
                context: context,
                builder: (_) => GreetingNameDialog(preference: preference),
              ),
              child: const Text('Abrir'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Abrir'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Nome longo de teste');
    await tester.ensureVisible(find.text('Salvar'));
    await tester.tap(find.text('Salvar'));
    await tester.pumpAndSettle();
    expect(
      find.text('Não foi possível salvar. Tente novamente.'),
      findsOneWidget,
    );
    expect(find.text('Nome longo de teste'), findsOneWidget);
    expect(preference.displayName, 'Maria');
    await users.login(
      User(
        id: 'b',
        name: 'Outra Conta',
        email: 'other@example.com',
        role: UserRole.professor,
        createdAt: DateTime(2026),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Salvar'));
    await tester.pumpAndSettle();
    expect(repository.attempts, 1);
    expect(tester.takeException(), isNull);
    await tester.ensureVisible(find.text('Cancelar'));
    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();
    expect(find.byType(GreetingNameDialog), findsNothing);
    await tester.pumpWidget(const SizedBox());
    preference.dispose();
    users.dispose();
  });
}
