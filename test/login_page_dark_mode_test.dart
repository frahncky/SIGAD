import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sigad/app/theme/app_theme.dart';
import 'package:sigad/features/login/presentation/pages/login_page.dart';

void main() {
  testWidgets('LoginPage renderiza corretamente em modo escuro', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        themeMode: ThemeMode.dark,
        home: const LoginPage(),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Entrar no SIGAD'), findsOneWidget);
    expect(find.text('Acesso por perfil'), findsOneWidget);
    expect(find.byIcon(Icons.email_outlined), findsOneWidget);
    expect(find.byIcon(Icons.lock_outline), findsOneWidget);
  });
}
