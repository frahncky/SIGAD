import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:sigad/app/routes/app_routes.dart';
import 'package:sigad/app/theme/app_theme.dart';
import 'package:sigad/core/models/user.dart';
import 'package:sigad/core/models/user_role.dart';
import 'package:sigad/core/services/chat_provider.dart';
import 'package:sigad/core/services/user_context_provider.dart';
import 'package:sigad/features/home/presentation/pages/home_shell_page.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('HomeShellPage renderiza em modo escuro com barra de ações', (tester) async {
    final userContext = UserContextProvider();
    await userContext.login(
      User(
        id: 'coord_1',
        name: 'Maria',
        email: 'maria.santos@univ.br',
        role: UserRole.coordenador,
        createdAt: DateTime.now(),
      ),
    );

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<UserContextProvider>.value(value: userContext),
          ChangeNotifierProvider(create: (_) => ChatProvider()),
        ],
        child: MaterialApp(
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          themeMode: ThemeMode.dark,
          home: const HomeShellPage(
            currentRoute: AppRoutes.dashboard,
            child: SizedBox.shrink(),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byType(AppBar), findsOneWidget);
    expect(find.byTooltip('Notificações'), findsOneWidget);
    expect(find.byTooltip('Perfil'), findsOneWidget);
  });
}
