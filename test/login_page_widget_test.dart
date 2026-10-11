import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:sigad/app/theme/app_theme.dart';
import 'package:sigad/core/services/user_context_provider.dart';
import 'package:sigad/features/login/presentation/pages/login_page.dart';

Widget _buildApp() {
  return MultiProvider(
    providers: [ChangeNotifierProvider(create: (_) => UserContextProvider())],
    child: MaterialApp(theme: AppTheme.light(), home: const LoginPage()),
  );
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('exibe campos de email e senha', (tester) async {
    await tester.pumpWidget(_buildApp());
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('login-campus-background')),
      findsOneWidget,
    );
    expect(find.text('Email institucional'), findsOneWidget);
    expect(find.text('Senha'), findsOneWidget);
    expect(find.text('Entrar'), findsNWidgets(2));
    expect(find.byIcon(Icons.account_balance_outlined), findsNothing);
    expect(find.byIcon(Icons.verified_user_outlined), findsNothing);
    expect(find.text('Entrar no SIGAD'), findsNothing);
    expect(find.textContaining('Use suas credenciais'), findsNothing);
  });

  testWidgets('valida campos vazios ao tentar logar', (tester) async {
    await tester.pumpWidget(_buildApp());
    await tester.pumpAndSettle();

    final enterButton = find.widgetWithText(FilledButton, 'Entrar');
    await tester.ensureVisible(enterButton);
    await tester.tap(enterButton);
    await tester.pumpAndSettle();

    expect(find.textContaining('Preencha email e senha'), findsOneWidget);
  });

  testWidgets('valida email invalido', (tester) async {
    await tester.pumpWidget(_buildApp());
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).first, 'email-invalido');
    await tester.enterText(find.byType(TextField).at(1), '1234');
    final enterButton = find.widgetWithText(FilledButton, 'Entrar');
    await tester.ensureVisible(enterButton);
    await tester.tap(enterButton);
    await tester.pumpAndSettle();

    expect(find.textContaining('email válido'), findsOneWidget);
  });

  testWidgets('valida senha muito curta', (tester) async {
    await tester.pumpWidget(_buildApp());
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byType(TextField).first,
      'user@instituicao.edu.br',
    );
    await tester.enterText(find.byType(TextField).at(1), 'ab');
    final enterButton = find.widgetWithText(FilledButton, 'Entrar');
    await tester.ensureVisible(enterButton);
    await tester.tap(enterButton);
    await tester.pumpAndSettle();

    expect(find.textContaining('pelo menos 4 caracteres'), findsOneWidget);
  });

  testWidgets('credenciais válidas não criam sessão simulada', (tester) async {
    await tester.pumpWidget(_buildApp());
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).first, 'usuario@ifma.edu.br');
    await tester.enterText(find.byType(TextField).at(1), 'senha_teste');
    final enterButton = find.widgetWithText(FilledButton, 'Entrar');
    await tester.ensureVisible(enterButton);
    await tester.tap(enterButton);
    await tester.pumpAndSettle();
    expect(
      find.textContaining('Autenticação institucional indisponível'),
      findsOneWidget,
    );
    final provider = tester
        .element(find.byType(LoginPage))
        .read<UserContextProvider>();
    expect(provider.isAuthenticated, isFalse);
    expect(provider.sessionToken, isNull);
    expect(
      await SharedPreferences.getInstance().then(
        (p) => p.getString('sigad_auth_session'),
      ),
      isNull,
    );
  });
  testWidgets('alterna visibilidade da senha', (tester) async {
    await tester.pumpWidget(_buildApp());
    await tester.pumpAndSettle();

    final passwordField = tester.widget<TextField>(
      find.byType(TextField).at(1),
    );
    expect(passwordField.obscureText, isTrue);

    await tester.tap(find.byIcon(Icons.visibility_outlined));
    await tester.pumpAndSettle();

    final passwordFieldAfter = tester.widget<TextField>(
      find.byType(TextField).at(1),
    );
    expect(passwordFieldAfter.obscureText, isFalse);
  });

  testWidgets('exibe pills de perfil e permite selecionar', (tester) async {
    await tester.pumpWidget(_buildApp());
    await tester.pumpAndSettle();

    expect(find.textContaining('Professor'), findsWidgets);
    expect(find.textContaining('Coordenador'), findsWidgets);

    await tester.tap(find.textContaining('Coordenador').first);
    await tester.pumpAndSettle();
  });

  testWidgets('botao acesso demo esta visivel', (tester) async {
    await tester.pumpWidget(_buildApp());
    await tester.pumpAndSettle();

    expect(find.text('Acesso demo do perfil selecionado'), findsOneWidget);
  });
}
