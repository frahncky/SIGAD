import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sigad/app/app.dart';

void main() {
  testWidgets('SIGAD app renders login page when session is not restored', (tester) async {
    SharedPreferences.setMockInitialValues({});

    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(1920, 1080);
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(const SigadApp());
    await tester.pump();

    expect(find.text('Entrar no SIGAD'), findsOneWidget);
  });
}
