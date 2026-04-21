import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:sigad/app/theme/app_theme.dart';
import 'package:sigad/core/services/user_context_provider.dart';
import 'package:sigad/features/login/presentation/pages/login_page.dart';

Widget _buildApp() {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => UserContextProvider()),
    ],
    child: MaterialApp(
      theme: AppTheme.light(),
      home: const LoginPage(),
    ),
  );
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('exibe campos de email e senha', (tester) async {
    await tester.pumpWidget(_buildApp());
    await tester.pumpAndSettle();

    expect(find.text('Email institucional'), findsOneWidget);
    expect(find.text('Senha'), findsOneWidget);
    expect(find.text('Entrar'), findsOneWidget);
  });

  testWidgets('valida campos vazios ao tentar logar', (tester) async {
    await tester.pumpWidget(_buildApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Entrar'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Preencha email e senha'), findsOneWidget);
  });

  testWidgets('valida email invalido', (tester) async {
    await tester.pumpWidget(_buildApp());
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).first, 'email-invalido');
    await tester.enterText(find.byType(TextField).at(1), '1234');
    await tester.tap(find.text('Entrar'));
    await tester.pumpAndSettle();

    expect(find.textContaining('email válido'), findsOneWidget);
  });

  testWidgets('valida senha muito curta', (tester) async {
    await tester.pumpWidget(_buildApp());
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).first, 'user@instituicao.edu.br');
    await tester.enterText(find.byType(TextField).at(1), 'ab');
    await tester.tap(find.text('Entrar'));
    await tester.pumpAndSettle();

    expect(find.textContaining('pelo menos 4 caracteres'), findsOneWidget);
  });

  testWidgets('alterna visibilidade da senha', (tester) async {
    await tester.pumpWidget(_buildApp());
    await tester.pumpAndSettle();

    final passwordField = tester.widget<TextField>(find.byType(TextField).at(1));
    expect(passwordField.obscureText, isTrue);

    await tester.tap(find.byIcon(Icons.visibility_outlined));
    await tester.pumpAndSettle();

    final passwordFieldAfter = tester.widget<TextField>(find.byType(TextField).at(1));
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
