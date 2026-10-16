import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:sigad/app/theme/app_theme.dart';
import 'package:sigad/features/redesign/presentation/pages/sigad_redesign_pages.dart';
import 'package:sigad/l10n/l10n.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  final paginas = <String, (Widget, String)>{
    'painel': (const SigadDashboardPage(), 'Department overview'),
    'bate-papo': (const SigadChatPage(), 'Chat'),
    'carga docente': (const SigadCargaDocentePage(), 'Distribution by teacher'),
    'professores': (const SigadProfessoresPage(), 'Faculty'),
    'demandas': (const SigadDemandasPage(), 'Request list'),
    'tarefas': (const SigadKanbanPage(), 'To do'),
    'laboratórios': (const SigadLaboratoriosPage(), 'Bookings today'),
    'atividades': (const SigadAtividadesPage(), 'Activities in the period'),
    'relatórios': (const SigadRelatoriosPage(), 'Available reports'),
    'configurações': (const SigadConfiguracoesPage(), 'Profile and account'),
  };

  for (final MapEntry(key: nome, value: (pagina, texto)) in paginas.entries) {
    testWidgets('visão geral de $nome em inglês', (tester) async {
      tester.view.physicalSize = const Size(1280, 2400);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light(),
          locale: const Locale('en'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          home: Scaffold(body: pagina),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text(texto), findsWidgets);
      expect(tester.takeException(), isNull);
      if (nome == 'carga docente') {
        expect(find.text('Excedida'), findsNothing);
        expect(find.text('Exceeded'), findsOneWidget);
      }
    });
  }
}
