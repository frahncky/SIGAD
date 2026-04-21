import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:sigad/app/theme/app_theme.dart';
import 'package:sigad/features/kanban/presentation/pages/kanban_page.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('arrastar card move para outra coluna sem abrir detalhes', (tester) async {
    tester.view.physicalSize = const Size(1400, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: const KanbanPage(),
      ),
    );

    await tester.pumpAndSettle();

    final backlogColumn = find.byKey(const ValueKey('kanban-column-Backlog'));
    final concludedColumn = find.byKey(const ValueKey('kanban-column-Concluído'));
    final card = find.byKey(const ValueKey('kanban-card-1'));

    expect(backlogColumn, findsOneWidget);
    expect(concludedColumn, findsOneWidget);
    expect(card, findsOneWidget);

    final sourceCenter = tester.getCenter(card);
    final targetCenter = tester.getCenter(concludedColumn);

    await tester.dragFrom(
      sourceCenter,
      Offset(targetCenter.dx - sourceCenter.dx, targetCenter.dy - sourceCenter.dy),
    );
    await tester.pump();
    await tester.pumpAndSettle();

    expect(
      find.descendant(
        of: concludedColumn,
        matching: find.text('Revisão de inventário'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: backlogColumn,
        matching: find.text('Revisão de inventário'),
      ),
      findsNothing,
    );
    expect(find.text('ID: 1'), findsNothing);
  });
}