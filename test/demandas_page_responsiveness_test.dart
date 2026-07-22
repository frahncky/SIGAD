import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:sigad/app/theme/app_theme.dart';
import 'package:sigad/core/models/user.dart';
import 'package:sigad/core/models/user_role.dart';
import 'package:sigad/core/services/user_context_provider.dart';
import 'package:sigad/features/demandas/presentation/pages/demandas_page.dart';

const _keyboardHeight = 260.0;
const _landscapeKeyboardHeight = 180.0;

void _configureView(WidgetTester tester, {required Size size}) {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(tester.view.resetViewInsets);
}

void _configureCompactView(WidgetTester tester) {
  _configureView(tester, size: const Size(320, 568));
}

Future<UserContextProvider> _coordinatorContext() async {
  final userContext = UserContextProvider();
  await userContext.updateUser(
    User(
      id: 'coordenador-demandas',
      name: 'Coordenação Teste',
      email: 'coordenacao@ifma.edu.br',
      role: UserRole.coordenador,
      createdAt: DateTime(2026),
    ),
  );
  return userContext;
}

Widget _buildApp(
  UserContextProvider userContext, {
  ThemeData? theme,
  double textScale = 2,
}) {
  return ChangeNotifierProvider<UserContextProvider>.value(
    value: userContext,
    child: MaterialApp(
      theme: theme ?? AppTheme.light(),
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(
          context,
        ).copyWith(textScaler: TextScaler.linear(textScale)),
        child: child!,
      ),
      home: const DemandasPage(),
    ),
  );
}

Finder _textFieldWithLabel(String label) {
  return find.byWidgetPredicate(
    (widget) => widget is TextField && widget.decoration?.labelText == label,
    description: 'TextField com rótulo "$label"',
  );
}

Future<void> _openKeyboard(WidgetTester tester) async {
  final titleField = _textFieldWithLabel('Título');
  await tester.ensureVisible(titleField);
  await tester.tap(titleField);
  await tester.showKeyboard(titleField);
  tester.view.viewInsets = const FakeViewPadding(bottom: _keyboardHeight);
  await tester.pumpAndSettle();
}

Future<void> _expectStackedAndReachableActions(
  WidgetTester tester, {
  required String submitLabel,
}) async {
  final cancelButton = find.widgetWithText(OutlinedButton, 'Cancelar');
  final submitButton = find.widgetWithText(ElevatedButton, submitLabel);

  expect(cancelButton, findsOneWidget);
  expect(submitButton, findsOneWidget);
  expect(
    tester.getRect(submitButton).top,
    greaterThan(tester.getRect(cancelButton).bottom),
  );

  await tester.ensureVisible(submitButton);
  await tester.pumpAndSettle();

  expect(submitButton.hitTestable(), findsOneWidget);
  final viewportHeight =
      tester.view.physicalSize.height / tester.view.devicePixelRatio;
  final keyboardTop =
      viewportHeight -
      tester.view.viewInsets.bottom / tester.view.devicePixelRatio;
  expect(tester.getRect(submitButton).bottom, lessThanOrEqualTo(keyboardTop));
  expect(tester.takeException(), isNull);
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets(
    'criação mantém ações roláveis com 320x568, texto 200% e teclado',
    (tester) async {
      _configureCompactView(tester);
      final userContext = await _coordinatorContext();

      await tester.pumpWidget(_buildApp(userContext));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      await tester.tap(find.byTooltip('Criar nova demanda'));
      await tester.pumpAndSettle();
      expect(find.text('Nova Demanda'), findsOneWidget);

      await _openKeyboard(tester);
      await _expectStackedAndReachableActions(tester, submitLabel: 'Criar');
    },
  );

  testWidgets(
    'edição mantém ações roláveis com 320x568, texto 200% e teclado',
    (tester) async {
      _configureCompactView(tester);
      final userContext = await _coordinatorContext();

      await tester.pumpWidget(_buildApp(userContext));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      final menuButton = find.byIcon(Icons.more_vert).first;
      await tester.ensureVisible(menuButton);
      await tester.pumpAndSettle();
      await tester.tap(menuButton);
      await tester.pumpAndSettle();
      final menuException = tester.takeException();
      expect(
        menuException,
        isNull,
        reason: 'O menu de ações não deve gerar overflow.',
      );
      await tester.tap(find.text('Editar').last);
      await tester.pumpAndSettle();
      expect(find.text('Editar Demanda'), findsOneWidget);
      expect(
        tester.takeException(),
        isNull,
        reason: 'O formulário de edição não deve gerar overflow ao abrir.',
      );

      await _openKeyboard(tester);
      expect(
        tester.takeException(),
        isNull,
        reason: 'O teclado não deve gerar overflow no formulário de edição.',
      );
      await _expectStackedAndReachableActions(tester, submitLabel: 'Salvar');
    },
  );

  testWidgets(
    'busca permanece rotulada e utilizável em paisagem com texto 200% e teclado',
    (tester) async {
      _configureView(tester, size: const Size(568, 320));
      final semantics = tester.ensureSemantics();
      final userContext = await _coordinatorContext();

      try {
        await tester.pumpWidget(_buildApp(userContext));
        await tester.pumpAndSettle();

        final searchField = find.byKey(const ValueKey('demandas_search_field'));
        final searchWidget = tester.widget<TextField>(searchField);
        expect(searchWidget.decoration?.labelText, 'Buscar demandas');
        expect(
          searchWidget.decoration?.floatingLabelBehavior,
          FloatingLabelBehavior.always,
        );
        expect(
          tester
              .getSemantics(
                find.byKey(const ValueKey('demandas_search_semantics')),
              )
              .label,
          contains('Buscar demandas'),
        );

        await tester.ensureVisible(searchField);
        await tester.pumpAndSettle();
        await tester.tap(searchField);
        await tester.showKeyboard(searchField);
        tester.view.viewInsets = const FakeViewPadding(
          bottom: _landscapeKeyboardHeight,
        );
        await tester.pumpAndSettle();
        await tester.ensureVisible(searchField);
        await tester.pumpAndSettle();

        expect(searchField.hitTestable(), findsOneWidget);
        final keyboardTop =
            tester.view.physicalSize.height - tester.view.viewInsets.bottom;
        expect(
          tester.getRect(searchField).bottom,
          lessThanOrEqualTo(keyboardTop),
        );

        await tester.enterText(searchField, 'inventário');
        await tester.pumpAndSettle();
        expect(
          find.text('Revisar inventário de instrumentos de medição'),
          findsOneWidget,
        );
        expect(tester.takeException(), isNull);
      } finally {
        semantics.dispose();
      }
    },
  );

  testWidgets('resumo usa ColorScheme no tema escuro', (tester) async {
    _configureView(tester, size: const Size(390, 844));
    final userContext = await _coordinatorContext();
    final theme = AppTheme.dark();

    await tester.pumpWidget(_buildApp(userContext, theme: theme, textScale: 1));
    await tester.pumpAndSettle();

    final banner = tester.widget<Container>(
      find.byKey(const ValueKey('demandas_summary_banner')),
    );
    final decoration = banner.decoration! as BoxDecoration;
    final border = decoration.border! as Border;
    expect(decoration.color, theme.colorScheme.surface);
    expect(border.top.color, theme.colorScheme.outlineVariant);

    final title = tester.widget<Text>(find.text('Resumo das demandas'));
    expect(title.style?.color, theme.colorScheme.onSurface);
    final icon = tester.widget<Icon>(find.byIcon(Icons.assignment_outlined));
    expect(icon.color, theme.colorScheme.primary);
    final kpiLabel = tester.widget<Text>(find.text('No total'));
    expect(kpiLabel.style?.color, theme.colorScheme.onSurfaceVariant);
    expect(tester.takeException(), isNull);
  });

  testWidgets('criação diferencia feedback de validação e sucesso', (
    tester,
  ) async {
    _configureView(tester, size: const Size(390, 844));
    final userContext = await _coordinatorContext();

    await tester.pumpWidget(_buildApp(userContext, textScale: 1));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Criar nova demanda'));
    await tester.pumpAndSettle();

    final createButton = find.widgetWithText(ElevatedButton, 'Criar');
    await tester.ensureVisible(createButton);
    await tester.tap(createButton);
    await tester.pumpAndSettle();

    expect(find.text('Erro'), findsOneWidget);
    expect(find.text('Informe o título da demanda'), findsOneWidget);
    expect(find.text('Informação'), findsNothing);

    await tester.enterText(_textFieldWithLabel('Título'), 'Demanda de teste');
    await tester.enterText(
      _textFieldWithLabel('Descrição'),
      'Descrição válida da demanda',
    );
    await tester.ensureVisible(createButton);
    await tester.tap(createButton);
    await tester.pumpAndSettle();

    expect(find.text('Sucesso'), findsOneWidget);
    expect(find.text('Demanda criada com sucesso!'), findsOneWidget);
    expect(find.text('Informação'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
