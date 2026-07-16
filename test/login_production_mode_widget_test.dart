import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:sigad/app/theme/app_theme.dart';
import 'package:sigad/core/config/app_runtime_config.dart';
import 'package:sigad/core/services/user_context_provider.dart';
import 'package:sigad/features/login/presentation/pages/login_page.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'produção bloqueia formulário, perfis e acesso demonstrativo',
    (tester) async {
      SharedPreferences.setMockInitialValues({});
      final userContext = UserContextProvider();

      await tester.pumpWidget(
        ChangeNotifierProvider<UserContextProvider>.value(
          value: userContext,
          child: MaterialApp(theme: AppTheme.light(), home: const LoginPage()),
        ),
      );
      await tester.pumpAndSettle();

      expect(AppRuntimeConfig.enableDemoAccess, isFalse);
      expect(find.text('Login indisponível'), findsOneWidget);
      expect(find.byType(TextField), findsNothing);
      expect(find.text('Acesso demo do perfil selecionado'), findsNothing);
      expect(find.widgetWithText(ElevatedButton, 'Entrar'), findsNothing);
      expect(find.textContaining('Professor'), findsNothing);
      expect(find.textContaining('Coordenador'), findsNothing);
      expect(userContext.isAuthenticated, isFalse);
    },
    skip: AppRuntimeConfig.flavor.trim().toLowerCase() != 'prod',
  );
}
