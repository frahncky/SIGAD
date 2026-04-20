import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:sigad/app/theme/app_theme.dart';
import 'package:sigad/core/models/user.dart';
import 'package:sigad/core/models/user_role.dart';
import 'package:sigad/core/services/user_context_provider.dart';
import 'package:sigad/features/dashboard/presentation/pages/dashboard_page.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('renderiza dashboard por perfil em dark mode', (tester) async {
    final userContext = UserContextProvider();
    await userContext.login(
      User(
        id: 'coord_dark',
        name: 'Maria',
        email: 'maria.santos@univ.br',
        role: UserRole.coordenador,
        createdAt: DateTime.now(),
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        themeMode: ThemeMode.dark,
        home: ChangeNotifierProvider<UserContextProvider>.value(
          value: userContext,
          child: const Scaffold(body: DashboardPage()),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('Olá, Maria'), findsOneWidget);
    expect(find.text('Atalhos do seu perfil'), findsOneWidget);
    expect(find.text('Demandas'), findsWidgets);
  });
}
