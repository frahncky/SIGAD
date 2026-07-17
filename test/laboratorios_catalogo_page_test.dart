import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sigad/features/aulas_praticas/presentation/pages/laboratorios_catalogo_page.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('catálogo e detalhes não geram overflow no mobile', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: LaboratoriosCatalogoPage(onAbrirReservas: () {})),
      ),
    );
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 1));

    expect(tester.takeException(), isNull);
    expect(find.text('Laboratórios'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
    await tester.scrollUntilVisible(
      find.text('Lab. de Medidas Elétricas'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Lab. de Medidas Elétricas'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
