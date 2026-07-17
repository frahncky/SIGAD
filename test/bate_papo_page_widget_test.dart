import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:sigad/app/theme/app_theme.dart';
import 'package:sigad/core/models/user.dart';
import 'package:sigad/core/models/user_role.dart';
import 'package:sigad/core/services/chat_provider.dart';
import 'package:sigad/core/services/user_context_provider.dart';
import 'package:sigad/features/bate_papo/presentation/pages/bate_papo_page.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('abre conversa e envia mensagem no mobile', (tester) async {
    final userContext = UserContextProvider();
    await userContext.login(
      User(
        id: 'user_email_professor.demo@ifma.edu.br',
        name: 'Professor Demo',
        email: 'professor.demo@ifma.edu.br',
        role: UserRole.professor,
        createdAt: DateTime.now(),
      ),
    );

    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<UserContextProvider>.value(value: userContext),
          ChangeNotifierProvider(create: (_) => ChatProvider()),
        ],
        child: MaterialApp(
          theme: AppTheme.light(),
          home: const Scaffold(body: BatePapoPage()),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Conversas'), findsOneWidget);

    await tester.tap(find.text('Coordenação Demo').first);
    await tester.pumpAndSettle();

    expect(find.text('Digite sua mensagem'), findsOneWidget);

    const texto = 'Mensagem de teste widget';
    await tester.enterText(find.byType(TextField).last, texto);
    await tester.tap(find.text('Enviar'));
    await tester.pumpAndSettle();

    expect(find.text(texto), findsOneWidget);
  });
}
