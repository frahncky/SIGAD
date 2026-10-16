import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sigad/features/aulas_praticas/presentation/widgets/reserva_sync_notice.dart';

void main() {
  testWidgets('aviso de sincronização mantém ação acessível na tela estreita', (
    tester,
  ) async {
    var atualizacoes = 0;
    await tester.binding.setSurfaceSize(const Size(320, 640));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MediaQuery(
            data: const MediaQueryData(
              size: Size(320, 640),
              textScaler: TextScaler.linear(1.4),
            ),
            child: SingleChildScrollView(
              child: ReservaSyncNotice(
                title: 'Agenda desatualizada',
                message:
                    'Outra pessoa modificou os horários. Confira antes de salvar.',
                actionLabel: 'Atualizar agenda',
                onRefresh: () => atualizacoes++,
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.text('Agenda desatualizada'), findsOneWidget);
    expect(find.text('Atualizar agenda'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.ensureVisible(find.text('Atualizar agenda'));
    await tester.tap(find.text('Atualizar agenda'));
    expect(atualizacoes, 1);
  });

  testWidgets('não oferece nova atualização enquanto já atualiza', (
    tester,
  ) async {
    var atualizacoes = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ReservaSyncNotice(
            title: 'Connection unavailable',
            message: 'Could not refresh reservations.',
            actionLabel: 'Refresh agenda',
            refreshing: true,
            onRefresh: () => atualizacoes++,
          ),
        ),
      ),
    );
    expect(
      tester.widget<TextButton>(find.byType(TextButton)).onPressed,
      isNull,
    );
    expect(atualizacoes, 0);
  });
}
