import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sigad/features/notas/presentation/pages/notas_page.dart';

void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('plugins.flutter.io/shared_preferences');
  late String raw;
  late int writes;
  late bool fail;
  late bool throwOnWrite;
  Completer<bool>? pending;
  final original = jsonEncode([
    {
      'id': 'one',
      'texto': 'Anotação original',
      'data': '2026-10-16T12:00:00',
      'categoria': 'Geral',
      'fixada': false,
    },
  ]);

  setUp(() {
    SharedPreferences.resetStatic();
    raw = original;
    writes = 0;
    fail = true;
    throwOnWrite = false;
    pending = null;
    binding.defaultBinaryMessenger.setMockMethodCallHandler(channel, (
      call,
    ) async {
      if (call.method.startsWith('getAll')) return {'flutter.sigad_notas': raw};
      if (call.method == 'setString') {
        writes++;
        if (throwOnWrite) throw PlatformException(code: 'storage_unavailable');
        final saved = pending == null ? !fail : await pending!.future;
        if (saved) raw = (call.arguments as Map)['value'] as String;
        return saved;
      }
      return true;
    });
  });
  tearDown(() {
    binding.defaultBinaryMessenger.setMockMethodCallHandler(channel, null);
    SharedPreferences.resetStatic();
  });

  Future<void> mount(WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: NotasPage()));
    await tester.pumpAndSettle();
  }

  Finder getField() => find.descendant(
    of: find.byType(AlertDialog),
    matching: find.byType(TextField),
  );

  for (final edit in [false, true]) {
    testWidgets(
      'falha ao ${edit ? 'editar' : 'criar'} preserva lista e rascunho e permite repetir',
      (tester) async {
        await mount(tester);
        await tester.tap(
          find.byTooltip(edit ? 'Editar anotação' : 'Nova anotação'),
        );
        await tester.pumpAndSettle();
        await tester.enterText(getField(), 'Rascunho mantido');
        await tester.tap(find.widgetWithText(ElevatedButton, 'Salvar'));
        await tester.pumpAndSettle();
        expect(find.byType(AlertDialog), findsOneWidget);
        expect(
          find.text('Não foi possível salvar. Tente novamente.'),
          findsOneWidget,
        );
        expect(
          tester.widget<TextField>(getField()).controller!.text,
          'Rascunho mantido',
        );
        expect(raw, original);
        fail = false;
        await tester.tap(find.widgetWithText(ElevatedButton, 'Salvar'));
        await tester.pumpAndSettle();
        expect(find.byType(AlertDialog), findsNothing);
        expect(find.text('Rascunho mantido'), findsOneWidget);
        expect(writes, 2);
      },
    );
  }

  testWidgets('falha excluir mantém anotação e oferece feedback', (
    tester,
  ) async {
    await mount(tester);
    await tester.tap(find.byTooltip('Excluir anotação'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(TextButton, 'Excluir'));
    await tester.pumpAndSettle();
    expect(find.text('Anotação original'), findsOneWidget);
    expect(
      find.text('Não foi possível salvar. Tente novamente.'),
      findsOneWidget,
    );
    expect(raw, original);
  });

  testWidgets('falha fixar mantém estado anterior', (tester) async {
    await mount(tester);
    await tester.tap(find.byTooltip('Fixar anotação'));
    await tester.pumpAndSettle();
    expect(find.byTooltip('Fixar anotação'), findsOneWidget);
    expect(find.byTooltip('Desafixar'), findsNothing);
    expect(
      find.text('Não foi possível salvar. Tente novamente.'),
      findsOneWidget,
    );
    expect(raw, original);
  });

  testWidgets('exceção ao desafixar preserva anotação fixada', (tester) async {
    raw = original.replaceFirst('"fixada":false', '"fixada":true');
    final persisted = raw;
    throwOnWrite = true;
    await mount(tester);
    await tester.tap(find.byTooltip('Desafixar').first);
    await tester.pumpAndSettle();
    expect(find.byTooltip('Desafixar'), findsNWidgets(2));
    expect(
      find.text('Não foi possível salvar. Tente novamente.'),
      findsOneWidget,
    );
    expect(raw, persisted);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'gravação pendente bloqueia reentrância e só então atualiza lista',
    (tester) async {
      await mount(tester);
      pending = Completer<bool>();
      await tester.tap(find.byTooltip('Nova anotação'));
      await tester.pumpAndSettle();
      await tester.enterText(getField(), 'Uma única nota');
      final button = find.widgetWithText(ElevatedButton, 'Salvar');
      await tester.tap(button);
      await tester.pump();
      expect(tester.widget<ElevatedButton>(button).onPressed, isNull);
      await tester.tap(button);
      await tester.pump();
      expect(writes, 1);
      expect(raw, original);
      pending!.complete(true);
      await tester.pumpAndSettle();
      expect(find.text('Uma única nota'), findsOneWidget);
      expect(writes, 1);
    },
  );

  for (final invalid in ['{', '[42]', '[{"texto":"","data":"2026-10-16"}]']) {
    testWidgets(
      'carga inválida $invalid bloqueia escrita e permite recuperar',
      (tester) async {
        raw = invalid;
        await mount(tester);
        expect(
          find.text('Nenhuma anotação. Toque em "+" para criar.'),
          findsNothing,
        );
        expect(
          tester
              .widget<FloatingActionButton>(find.byType(FloatingActionButton))
              .onPressed,
          isNull,
        );
        expect(find.text('Tentar novamente'), findsOneWidget);
        expect(writes, 0);
        expect(raw, invalid);
        raw = original;
        SharedPreferences.resetStatic();
        await tester.tap(find.text('Tentar novamente'));
        await tester.pumpAndSettle();
        expect(find.text('Anotação original'), findsOneWidget);
      },
    );
  }
}
