import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:sigad/app/theme/app_theme.dart';
import 'package:sigad/core/models/user.dart';
import 'package:sigad/core/models/user_role.dart';
import 'package:sigad/core/services/user_context_provider.dart';
import 'package:sigad/features/carga_docente/domain/docente_form_service.dart';
import 'package:sigad/features/carga_docente/domain/docente_models.dart';
import 'package:sigad/features/carga_docente/presentation/carga_docente_l10n.dart';
import 'package:sigad/features/carga_docente/presentation/pages/carga_docente_page.dart';
import 'package:sigad/l10n/l10n.dart';

Future<void> _pump(
  WidgetTester tester,
  UserRole role, {
  Locale locale = const Locale('en'),
}) async {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  final userContext = UserContextProvider();
  await userContext.login(
    User(
      id: 'user_email_coordenacao@exemplo.edu.br',
      name: 'Coordenação Teste',
      email: 'coordenacao@exemplo.edu.br',
      role: role,
      createdAt: DateTime(2026),
    ),
  );
  await tester.pumpWidget(
    ChangeNotifierProvider<UserContextProvider>.value(
      value: userContext,
      child: MaterialApp(
        theme: AppTheme.light(),
        locale: locale,
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: const CargaDocentePage(),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  final en = lookupAppLocalizations(const Locale('en'));

  test('mensagens de validação do formulário têm tradução', () {
    final erros = <String?>[
      DocenteFormService.validateDisciplina(
        disciplina: '',
        disciplinasExistentes: const [],
      ),
      DocenteFormService.validateDisciplina(
        disciplina: 'Redes I',
        disciplinasExistentes: const ['Redes I'],
      ),
      DocenteFormService.validateHorario(inicio: '', fim: ''),
      DocenteFormService.validateHorario(inicio: '8h', fim: '9h'),
      DocenteFormService.validateHorario(inicio: '10:00', fim: '09:00'),
    ];
    for (final erro in erros.whereType<String>()) {
      expect(en.erroDocente(erro), isNot(erro), reason: erro);
    }
    expect(
      en.erroDocente('O regime DE permite até 40h semanais.'),
      'The DE regime allows up to 40h per week.',
    );
    expect(
      en.erroDocente('Já existe horário cadastrado em conflito para Terça.'),
      'There is already a conflicting time on Tuesday.',
    );
  });

  test('regimes têm nome em inglês', () {
    for (final regime in RegimeTrabalhoEbtt.values) {
      expect(en.regime(regime), isNot(regime.label));
    }
  });

  testWidgets('carga docente em inglês', (tester) async {
    await _pump(tester, UserRole.coordenador);

    expect(find.text('Distribution optimization'), findsOneWidget);
    expect(find.textContaining('EBTT Regime:'), findsWidgets);
    expect(find.byTooltip('Add teacher'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.tap(find.byTooltip('Add teacher'));
    await tester.pumpAndSettle();
    expect(find.text('New Teacher'), findsOneWidget);
    expect(find.text('Full Name'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('carga docente em português sem overflow', (tester) async {
    await _pump(tester, UserRole.coordenador, locale: const Locale('pt'));
    expect(find.text('Otimização da distribuição'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
