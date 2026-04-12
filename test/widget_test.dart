import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sigad/app/app.dart';

void main() {
  testWidgets('SIGAD app renders login page', (tester) async {
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(1920, 1080);
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(const SigadApp());
    await tester.pumpAndSettle();

    expect(find.text('Entrar no SIGAD'), findsOneWidget);
    expect(find.text('Acesso por perfil'), findsOneWidget);
  });
}
