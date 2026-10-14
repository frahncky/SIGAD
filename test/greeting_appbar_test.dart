import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sigad/app/routes/app_routes.dart';
import 'package:sigad/app/theme/app_theme.dart';
import 'package:sigad/core/models/user.dart';
import 'package:sigad/core/models/user_role.dart';
import 'package:sigad/core/services/user_context_provider.dart';
import 'package:sigad/core/services/greeting_name_provider.dart';
import 'package:sigad/features/home/presentation/pages/home_shell_page.dart';
import 'package:sigad/shared/widgets/greeting_title.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));
  for (final size in [
    const Size(320, 568),
    const Size(360, 640),
    const Size(390, 844),
    const Size(412, 915),
    const Size(844, 390),
    const Size(1280, 800),
  ]) {
    for (final scale in [1.0, 1.5, 2.0]) {
      testWidgets('saudação inicial ${size.width}x${size.height} escala$scale', (
        tester,
      ) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final users = UserContextProvider();
        await users.login(
          User(
            id: 'greeting',
            name: 'Maria Souza',
            email: 'test@example.com',
            role: UserRole.professor,
            createdAt: DateTime(2026),
          ),
        );
        final names = GreetingNameProvider(users);
        await tester.pump();
        const longName =
            'Maria Clara de Souza com nome composto muito longo para leitura completa';
        await names.save(longName);
        await tester.pumpWidget(
          MultiProvider(
            providers: [
              ChangeNotifierProvider<UserContextProvider>.value(value: users),
              ChangeNotifierProvider<GreetingNameProvider>.value(value: names),
            ],
            child: MaterialApp(
              theme: AppTheme.light(),
              builder: (context, child) => MediaQuery(
                data: MediaQuery.of(
                  context,
                ).copyWith(textScaler: TextScaler.linear(scale)),
                child: child!,
              ),
              home: const HomeShellPage(
                currentRoute: AppRoutes.dashboard,
                child: SizedBox(),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(find.byType(GreetingTitle), findsOneWidget);
        expect(find.textContaining(longName), findsOneWidget);
        expect(tester.takeException(), isNull);
        await tester.tap(find.byType(GreetingTitle));
        await tester.pumpAndSettle();
        expect(find.byType(SelectableText), findsOneWidget);
        expect(tester.takeException(), isNull);
        await tester.tap(find.text('Fechar'));
        await tester.pumpAndSettle();
        await names.save('Ana Clara');
        await tester.pumpAndSettle();
        expect(find.textContaining('Ana Clara'), findsOneWidget);
        await tester.pumpWidget(const SizedBox());
        names.dispose();
        users.dispose();
      });
    }
  }
}
