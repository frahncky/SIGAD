import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:sigad/app/routes/app_routes.dart';
import 'package:sigad/app/theme/app_theme.dart';
import 'package:sigad/core/models/user.dart';
import 'package:sigad/core/models/user_role.dart';
import 'package:sigad/core/services/chat_provider.dart';
import 'package:sigad/core/services/user_context_provider.dart';
import 'package:sigad/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:sigad/features/home/presentation/pages/home_shell_page.dart';
import 'package:sigad/features/login/presentation/pages/login_page.dart';

const _runGoldenTests = bool.fromEnvironment(
  'RUN_GOLDEN_TESTS',
  defaultValue: false,
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  Future<void> pumpSized(
    WidgetTester tester,
    Widget child, {
    Size size = const Size(390, 844),
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(MaterialApp(theme: AppTheme.light(), home: child));
    await tester.pumpAndSettle();
  }

  testWidgets('login mobile golden', (tester) async {
    await pumpSized(
      tester,
      ChangeNotifierProvider(
        create: (_) => UserContextProvider(),
        child: const LoginPage(),
      ),
    );

    await expectLater(
      find.byType(LoginPage),
      matchesGoldenFile('goldens/baselines/login_mobile.png'),
    );
  }, skip: !_runGoldenTests);

  testWidgets('dashboard desktop golden', (tester) async {
    final userContext = UserContextProvider();
    await userContext.login(
      User(
        id: 'golden-dashboard',
        name: 'Usuario Golden',
        email: 'golden.dashboard@sigad.dev',
        role: UserRole.coordenador,
        createdAt: DateTime(2026, 1, 1),
      ),
    );

    await pumpSized(
      tester,
      ChangeNotifierProvider<UserContextProvider>.value(
        value: userContext,
        // No app, o painel sempre fica dentro do Scaffold do shell.
        child: Scaffold(body: DashboardPage(agora: DateTime(2026, 1, 1, 9))),
      ),
      size: const Size(1440, 900),
    );

    await expectLater(
      find.byType(DashboardPage),
      matchesGoldenFile('goldens/baselines/dashboard_desktop.png'),
    );
  }, skip: !_runGoldenTests);

  testWidgets('home shell desktop golden', (tester) async {
    final userContext = UserContextProvider();
    await userContext.login(
      User(
        id: 'golden-home',
        name: 'Usuario Shell',
        email: 'golden.home@sigad.dev',
        role: UserRole.professor,
        createdAt: DateTime(2026, 1, 1),
      ),
    );

    await pumpSized(
      tester,
      MultiProvider(
        providers: [
          ChangeNotifierProvider<UserContextProvider>.value(value: userContext),
          ChangeNotifierProvider(create: (_) => ChatProvider()),
        ],
        child: HomeShellPage(
          currentRoute: AppRoutes.dashboard,
          greetingNow: DateTime(2026, 1, 1, 21),
          child: DashboardPage(agora: DateTime(2026, 1, 1, 9)),
        ),
      ),
      size: const Size(1440, 900),
    );

    await expectLater(
      find.byType(HomeShellPage),
      matchesGoldenFile('goldens/baselines/home_shell_desktop.png'),
    );
  }, skip: !_runGoldenTests);
}
