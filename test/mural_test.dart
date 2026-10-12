import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:sigad/app/theme/app_theme.dart';
import 'package:sigad/core/config/app_runtime_config.dart';
import 'package:sigad/core/models/user.dart';
import 'package:sigad/core/models/user_role.dart';
import 'package:sigad/core/services/user_context_provider.dart';
import 'package:sigad/features/mural/domain/mural_models.dart';
import 'package:sigad/features/mural/presentation/pages/mural_page.dart';
import 'package:sigad/features/mural/presentation/state/mural_controller.dart';
import 'package:sigad/shared/widgets/welcome_hero.dart';

Aviso _aviso({
  String id = 'a',
  Set<UserRole> publico = const {},
  DateTime? inicio,
  DateTime? fim,
  bool ativo = true,
  bool fixado = false,
  DateTime? criadoEm,
}) => Aviso(
  id: id,
  modelo: ModeloAviso.informativo,
  titulo: 'Aviso $id',
  conteudo: 'Conteúdo $id',
  criadoEm: criadoEm ?? DateTime(2026, 1, 1),
  publico: publico,
  inicio: inicio,
  fim: fim,
  ativo: ativo,
  fixado: fixado,
);

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  group('Aviso.visivelPara', () {
    final hoje = DateTime(2026, 10, 11, 15);

    test('respeita ativo, público e período (datas inclusivas)', () {
      expect(_aviso().visivelPara(UserRole.professor, hoje), isTrue);
      expect(_aviso().visivelPara(null, hoje), isFalse);
      expect(_aviso(ativo: false).visivelPara(null, hoje), isFalse);
      expect(
        _aviso(
          publico: {UserRole.coordenador},
        ).visivelPara(UserRole.professor, hoje),
        isFalse,
      );
      expect(
        _aviso(
          publico: {UserRole.coordenador},
        ).visivelPara(UserRole.coordenador, hoje),
        isTrue,
      );
      expect(
        _aviso(
          inicio: DateTime(2026, 10, 11),
        ).visivelPara(UserRole.professor, hoje),
        isTrue,
      );
      expect(
        _aviso(inicio: DateTime(2026, 10, 12)).visivelPara(null, hoje),
        isFalse,
      );
      expect(
        _aviso(
          fim: DateTime(2026, 10, 11),
        ).visivelPara(UserRole.professor, hoje),
        isTrue,
      );
      expect(
        _aviso(fim: DateTime(2026, 10, 10)).visivelPara(null, hoje),
        isFalse,
      );
    });

    test('serializa e desserializa sem perdas', () {
      final original = _aviso(
        publico: {UserRole.professor},
        inicio: DateTime(2026, 10, 1),
        fim: DateTime(2026, 10, 31),
        fixado: true,
      );
      final copia = Aviso.fromJson(original.toJson());
      expect(copia.toJson(), original.toJson());
    });
  });

  group('fraseDoPeriodo', () {
    final frases = [
      for (var i = 0; i < 4; i++)
        FraseMotivacional(id: '$i', texto: 'Frase $i'),
    ];

    test('semanal: mesma frase de segunda a domingo e troca na segunda', () {
      // 2026-10-05 é segunda-feira.
      final segunda = fraseDoPeriodo(
        frases,
        PeriodicidadeFrase.semanal,
        DateTime(2026, 10, 5),
      );
      final domingo = fraseDoPeriodo(
        frases,
        PeriodicidadeFrase.semanal,
        DateTime(2026, 10, 11),
      );
      final proxima = fraseDoPeriodo(
        frases,
        PeriodicidadeFrase.semanal,
        DateTime(2026, 10, 12),
      );
      expect(domingo!.id, segunda!.id);
      expect(proxima!.id, isNot(segunda.id));
    });

    test('mensal: troca na virada do mês', () {
      final fim = fraseDoPeriodo(
        frases,
        PeriodicidadeFrase.mensal,
        DateTime(2026, 10, 31),
      );
      final inicio = fraseDoPeriodo(
        frases,
        PeriodicidadeFrase.mensal,
        DateTime(2026, 11, 1),
      );
      expect(inicio!.id, isNot(fim!.id));
    });

    test('ignora frases inativas e retorna nulo sem ativas', () {
      final umaAtiva = [
        const FraseMotivacional(id: 'x', texto: 'X', ativa: false),
        const FraseMotivacional(id: 'y', texto: 'Y'),
      ];
      for (var dia = 1; dia <= 28; dia++) {
        expect(
          fraseDoPeriodo(
            umaAtiva,
            PeriodicidadeFrase.diaria,
            DateTime(2026, 2, dia),
          )!.id,
          'y',
        );
      }
      expect(
        fraseDoPeriodo(
          [const FraseMotivacional(id: 'x', texto: 'X', ativa: false)],
          PeriodicidadeFrase.semanal,
          DateTime(2026),
        ),
        isNull,
      );
    });
  });

  group('MuralController', () {
    test('registro corrompido é ignorado sem perder os demais', () async {
      SharedPreferences.setMockInitialValues({
        'sigad_mural_avisos':
            '[{"titulo":"sem id"},'
            '{"id":"ok","titulo":"Válido","conteudo":"c","criadoEm":"2026-01-01"}]',
      });
      final mural = MuralController(agora: () => DateTime(2026, 10, 11));
      await mural.carregar();
      expect(mural.falhouAoCarregar, isFalse);
      expect([for (final a in mural.avisos) a.id], ['ok']);
    });

    test('começa com frases padrão e persiste alterações', () async {
      final mural = MuralController(agora: () => DateTime(2026, 10, 11));
      await mural.carregar();
      expect(mural.frases, isNotEmpty);
      expect(mural.avisos, isEmpty);
      expect(mural.periodicidade, PeriodicidadeFrase.semanal);

      await mural.salvarAviso(_aviso(id: '1'));
      await mural.salvarFrase(
        const FraseMotivacional(id: 'nova', texto: 'Nova frase'),
      );
      await mural.definirPeriodicidade(PeriodicidadeFrase.mensal);

      final recarregado = MuralController(agora: () => DateTime(2026, 10, 11));
      await recarregado.carregar();
      expect(recarregado.avisos.single.id, '1');
      expect(recarregado.frases.last.texto, 'Nova frase');
      expect(recarregado.periodicidade, PeriodicidadeFrase.mensal);

      await recarregado.excluirAviso('1');
      expect(recarregado.avisos, isEmpty);
    });

    test(
      'avisos visíveis: fixados primeiro, depois os mais recentes',
      () async {
        final mural = MuralController(agora: () => DateTime(2026, 10, 11));
        await mural.carregar();
        await mural.salvarAviso(_aviso(id: 'antigo', criadoEm: DateTime(2026)));
        await mural.salvarAviso(
          _aviso(id: 'recente', criadoEm: DateTime(2026, 9)),
        );
        await mural.salvarAviso(
          _aviso(id: 'fixado', criadoEm: DateTime(2025), fixado: true),
        );
        await mural.salvarAviso(_aviso(id: 'off', ativo: false));

        expect(
          [
            for (final aviso in mural.avisosVisiveis(UserRole.professor))
              aviso.id,
          ],
          ['fixado', 'recente', 'antigo'],
        );
      },
    );
  });

  group('MuralPage', () {
    Future<MuralController> pumpPage(WidgetTester tester, UserRole role) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final userContext = UserContextProvider();
      await userContext.login(
        User(
          id: 'u1',
          name: 'Chefe Teste',
          email: 'chefe@sigad.dev',
          role: role,
          createdAt: DateTime(2026),
        ),
      );
      final mural = MuralController();
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: userContext),
            ChangeNotifierProvider.value(value: mural),
          ],
          child: MaterialApp(
            theme: AppTheme.light(),
            home: const Scaffold(body: MuralPage()),
          ),
        ),
      );
      await tester.pumpAndSettle();
      return mural;
    }

    testWidgets('professor não acessa a gestão do mural', (tester) async {
      await pumpPage(tester, UserRole.professor);
      expect(
        find.text('Somente a chefia do departamento pode gerenciar o mural.'),
        findsOneWidget,
      );
      expect(find.text('Novo aviso'), findsNothing);
    }, skip: !AppRuntimeConfig.allowLocalDemo);

    testWidgets('chefe cadastra aviso com modelo, conteúdo e público', (
      tester,
    ) async {
      final mural = await pumpPage(tester, UserRole.chefeDepartamento);
      expect(find.textContaining('Nenhum aviso cadastrado'), findsOneWidget);

      await tester.tap(find.text('Novo aviso'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Importante'));
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Título'),
        'Prazo do PIT',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Conteúdo'),
        'Entregar até sexta-feira.',
      );
      await tester.ensureVisible(find.text('Professor').last);
      await tester.tap(find.text('Professor').last);
      await tester.scrollUntilVisible(
        find.text('Publicar aviso'),
        200,
        scrollable: find.byType(Scrollable).last,
      );
      expect(find.text('Pré-visualização no painel'), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(WelcomeHero),
          matching: find.text('Prazo do PIT'),
        ),
        findsOneWidget,
      );
      await tester.tap(find.text('Publicar aviso'));
      await tester.pumpAndSettle();

      final aviso = mural.avisos.single;
      expect(aviso.titulo, 'Prazo do PIT');
      expect(aviso.conteudo, 'Entregar até sexta-feira.');
      expect(aviso.modelo, ModeloAviso.importante);
      expect(aviso.publico, {UserRole.professor});
      expect(find.text('Prazo do PIT'), findsOneWidget);
    }, skip: !AppRuntimeConfig.allowLocalDemo);

    testWidgets('chefe adiciona frase e muda a frequência', (tester) async {
      final mural = await pumpPage(tester, UserRole.chefeDepartamento);
      await tester.tap(find.text('Frases'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Nova frase'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Frase'),
        'Juntos vamos mais longe.',
      );
      await tester.pumpAndSettle();
      expect(
        find.descendant(
          of: find.byType(WelcomeHero),
          matching: find.text('Juntos vamos mais longe.'),
        ),
        findsOneWidget,
      );
      await tester.scrollUntilVisible(
        find.text('Salvar frase'),
        200,
        scrollable: find.byType(Scrollable).last,
      );
      await tester.tap(find.text('Salvar frase'));
      await tester.pumpAndSettle();
      expect(mural.frases.last.texto, 'Juntos vamos mais longe.');

      await tester.tap(find.text('Toda semana'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Todo mês').last);
      await tester.pumpAndSettle();
      expect(mural.periodicidade, PeriodicidadeFrase.mensal);
    }, skip: !AppRuntimeConfig.allowLocalDemo);
  });
}
