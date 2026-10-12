import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sigad/core/models/user.dart';
import 'package:sigad/core/models/user_role.dart';
import 'package:sigad/core/services/user_context_provider.dart';
import 'package:sigad/features/aulas_praticas/data/laboratorio_repository.dart';
import 'package:sigad/features/aulas_praticas/presentation/pages/laboratorios_catalogo_page.dart';
import 'package:sigad/features/aulas_praticas/presentation/widgets/dialog_disciplina_semanas_reserva.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    LaboratorioRepository.limparCache();
  });

  Future<void> abrirCatalogo(
    WidgetTester tester, {
    UserRole? perfil,
    Size tamanho = const Size(412, 915),
    double escala = 1,
  }) async {
    tester.view.physicalSize = tamanho;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    // Descarta telas abertas de uma montagem anterior no mesmo teste.
    await tester.pumpWidget(const SizedBox.shrink());

    final app = MaterialApp(
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(
          context,
        ).copyWith(textScaler: TextScaler.linear(escala)),
        child: child!,
      ),
      home: Scaffold(body: LaboratoriosCatalogoPage(onAbrirReservas: (_) {})),
    );
    if (perfil == null) {
      await tester.pumpWidget(app);
    } else {
      final userContext = UserContextProvider();
      await userContext.login(
        User(
          id: 'u-${perfil.name}',
          name: 'Usuário Teste',
          email: '${perfil.name}@ifma.edu.br',
          role: perfil,
          createdAt: DateTime(2026),
        ),
      );
      await tester.pumpWidget(
        ChangeNotifierProvider<UserContextProvider>.value(
          value: userContext,
          child: app,
        ),
      );
    }
    await tester.pumpAndSettle();
  }

  Future<void> abrirLaboratorio(WidgetTester tester, String nome) async {
    await tester.scrollUntilVisible(
      find.text(nome),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.ensureVisible(find.text(nome));
    await tester.pumpAndSettle();
    await tester.tap(find.text(nome));
    await tester.pumpAndSettle();
  }

  Future<void> reportar(WidgetTester tester, String titulo) async {
    await tester.ensureVisible(find.text('Reportar problema'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Reportar problema'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextFormField, 'O que aconteceu?'),
      titulo,
    );
    await tester.tap(find.text('Registrar ocorrência'));
    await tester.pumpAndSettle();
  }

  testWidgets('catálogo e detalhes não geram overflow no mobile', (
    tester,
  ) async {
    for (final escala in [1.0, 1.5, 2.0]) {
      LaboratorioRepository.limparCache();
      await abrirCatalogo(
        tester,
        tamanho: const Size(320, 568),
        escala: escala,
      );
      expect(find.byType(CircularProgressIndicator), findsNothing);
      await abrirLaboratorio(tester, 'Lab. de Automação');
      await tester.scrollUntilVisible(
        find.text('Responsável técnico'),
        300,
        scrollable: find.byType(Scrollable).last,
      );
      expect(find.text('Responsável técnico'), findsOneWidget);
      expect(tester.takeException(), isNull, reason: 'escala $escala');
    }
  });

  testWidgets('rodapé só fica fixo quando cabe sem ocupar a tela', (
    tester,
  ) async {
    await abrirCatalogo(tester);
    await abrirLaboratorio(tester, 'Lab. de Automação');
    expect(
      tester.widget<Scaffold>(find.byType(Scaffold).last).bottomNavigationBar,
      isNotNull,
    );

    await abrirCatalogo(tester, tamanho: const Size(320, 568), escala: 2);
    await abrirLaboratorio(tester, 'Lab. de Automação');
    expect(
      tester.widget<Scaffold>(find.byType(Scaffold).last).bottomNavigationBar,
      isNull,
    );
  });

  testWidgets('chefe reporta problema e marca como resolvido; fica salvo', (
    tester,
  ) async {
    await abrirCatalogo(tester, perfil: UserRole.chefeDepartamento);
    await abrirLaboratorio(tester, 'Lab. de Automação');

    await tester.tap(find.text('Reportar problema'));
    await tester.pumpAndSettle();
    expect(find.byType(TelaFormularioReserva), findsOneWidget);
    expect(
      find.text('Não inclua nomes, matrículas ou dados pessoais.'),
      findsOneWidget,
    );

    // Título obrigatório.
    await tester.tap(find.text('Registrar ocorrência'));
    await tester.pumpAndSettle();
    expect(
      find.text('Descreva o problema em poucas palavras.'),
      findsOneWidget,
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'O que aconteceu?'),
      'Bancada 2 sem energia',
    );
    await tester.tap(find.text('Registrar ocorrência'));
    await tester.pumpAndSettle();
    expect(find.text('Ocorrência registrada.'), findsOneWidget);

    final resolver = find.bySemanticsLabel(
      RegExp('Resolver ocorrência: Bancada 2 sem energia'),
    );
    await tester.scrollUntilVisible(
      find.text('Bancada 2 sem energia'),
      300,
      scrollable: find.byType(Scrollable).last,
    );
    expect(resolver, findsOneWidget);
    await tester.ensureVisible(find.widgetWithText(TextButton, 'Resolver'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(TextButton, 'Resolver'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Resolvida'));
    await tester.pumpAndSettle();
    expect(find.text('Ocorrência marcada como resolvida.'), findsOneWidget);

    // Persistido: relê do armazenamento, sem o cache em memória.
    LaboratorioRepository.limparCache();
    final salvos = await LaboratorioRepository().load();
    final ocorrencia = salvos
        .firstWhere((item) => item.nome == 'Lab. de Automação')
        .ocorrencias
        .firstWhere((item) => item.titulo == 'Bancada 2 sem energia');
    expect(ocorrencia.resolvida, isTrue);
  });

  testWidgets('professor reporta problema mas não vê "Resolver"', (
    tester,
  ) async {
    await abrirCatalogo(tester, perfil: UserRole.professor);
    await abrirLaboratorio(tester, 'Lab. de Automação');
    await reportar(tester, 'Projetor sem imagem');
    expect(find.text('Ocorrência registrada.'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Projetor sem imagem'),
      300,
      scrollable: find.byType(Scrollable).last,
    );
    expect(find.widgetWithText(TextButton, 'Resolver'), findsNothing);
  });
}
