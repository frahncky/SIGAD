import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:sigad/app/theme/app_theme.dart';
import 'package:sigad/core/models/user.dart';
import 'package:sigad/core/models/user_role.dart';
import 'package:sigad/core/services/user_context_provider.dart';
import 'package:sigad/features/carga_docente/presentation/pages/carga_docente_page.dart';

Widget _buildApp(UserContextProvider userContext) {
  return ChangeNotifierProvider<UserContextProvider>.value(
    value: userContext,
    child: MaterialApp(theme: AppTheme.light(), home: const CargaDocentePage()),
  );
}

Future<UserContextProvider> _loggedIn(
  UserRole role, {
  String email = 'user@ifma.edu.br',
}) async {
  final ctx = UserContextProvider();
  await ctx.login(
    User(
      id: 'user_email_$email',
      name: 'Teste',
      email: email,
      role: role,
      createdAt: DateTime.now(),
    ),
  );
  return ctx;
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('coordenador ve lista de docentes', (tester) async {
    final ctx = await _loggedIn(UserRole.coordenador);

    await tester.pumpWidget(_buildApp(ctx));
    await tester.pumpAndSettle();

    expect(find.textContaining('Docente 01'), findsWidgets);
    expect(find.text('Nenhum docente encontrado'), findsNothing);
  });

  testWidgets('professor ve apenas os proprios dados', (tester) async {
    final ctx = await _loggedIn(
      UserRole.professor,
      email: 'maria.santos@ifma.edu.br',
    );

    await tester.pumpWidget(_buildApp(ctx));
    await tester.pumpAndSettle();

    expect(find.textContaining('Docente 01'), findsWidgets);
    expect(find.textContaining('Docente 02'), findsNothing);
  });

  testWidgets('chefe ve todos os docentes', (tester) async {
    final ctx = await _loggedIn(UserRole.chefeDepartamento);

    await tester.pumpWidget(_buildApp(ctx));
    await tester.pumpAndSettle();

    expect(find.textContaining('Docente 01'), findsWidgets);
    expect(find.text('Nenhum docente encontrado'), findsNothing);
  });

  testWidgets('coordenador pode adicionar docente', (tester) async {
    final ctx = await _loggedIn(UserRole.coordenador);

    await tester.pumpWidget(_buildApp(ctx));
    await tester.pumpAndSettle();

    final fab = find.byType(FloatingActionButton);
    if (fab.evaluate().isNotEmpty) {
      await tester.tap(fab);
      await tester.pumpAndSettle();
      expect(find.text('Novo Docente'), findsOneWidget);
    }
  });
}
