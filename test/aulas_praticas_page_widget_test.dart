import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:sigad/app/theme/app_theme.dart';
import 'package:sigad/core/models/user.dart';
import 'package:sigad/core/models/user_role.dart';
import 'package:sigad/core/services/user_context_provider.dart';
import 'package:sigad/features/aulas_praticas/presentation/pages/aulas_praticas_page.dart';

Widget _buildApp(UserContextProvider userContext) {
  return ChangeNotifierProvider<UserContextProvider>.value(
    value: userContext,
    child: MaterialApp(
      theme: AppTheme.light(),
      home: const AulasPraticasPage(),
    ),
  );
}

Future<UserContextProvider> _loggedIn(UserRole role) async {
  final ctx = UserContextProvider();
  await ctx.login(
    User(
      id: 'ap_user',
      name: 'Usuário Teste',
      email: 'usuario@univ.br',
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

  testWidgets('professor ve calendário de reservas', (tester) async {
    final ctx = await _loggedIn(UserRole.professor);

    await tester.pumpWidget(_buildApp(ctx));
    await tester.pumpAndSettle();

    expect(find.textContaining('Lab'), findsWidgets);
    expect(find.text('Acesso negado'), findsNothing);
  });

  testWidgets('aluno nao tem acesso', (tester) async {
    final ctx = await _loggedIn(UserRole.aluno);

    await tester.pumpWidget(_buildApp(ctx));
    await tester.pumpAndSettle();

    expect(find.textContaining('acesso'), findsWidgets);
    expect(find.textContaining('Lab'), findsNothing);
  });

  testWidgets('exibe selecao de mes', (tester) async {
    final ctx = await _loggedIn(UserRole.professor);

    await tester.pumpWidget(_buildApp(ctx));
    await tester.pumpAndSettle();

    final meses = [
      'Janeiro', 'Fevereiro', 'Março', 'Abril', 'Maio', 'Junho',
      'Julho', 'Agosto', 'Setembro', 'Outubro', 'Novembro', 'Dezembro',
    ];
    expect(
      meses.any((m) => tester.any(find.textContaining(m))),
      isTrue,
    );
  });

  testWidgets('coordenador pode editar reservas', (tester) async {
    final ctx = await _loggedIn(UserRole.coordenador);

    await tester.pumpWidget(_buildApp(ctx));
    await tester.pumpAndSettle();

    expect(find.textContaining('Lab'), findsWidgets);
  });
}
