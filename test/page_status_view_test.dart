import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sigad/app/theme/app_theme.dart';
import 'package:sigad/app/theme/sigad_icons.dart';
import 'package:sigad/shared/widgets/page_status_view.dart';

void main() {
  GoogleFonts.config.allowRuntimeFetching = false;

  for (final brightness in Brightness.values) {
    testWidgets(
      'usa papéis de superfície e semântica no tema ${brightness.name}',
      (tester) async {
        final theme = brightness == Brightness.dark
            ? AppTheme.dark()
            : AppTheme.light();
        final scheme = theme.colorScheme;
        var actionCalled = false;

        await tester.pumpWidget(
          MaterialApp(
            theme: theme,
            home: Scaffold(
              body: PageStatusView.error(
                title: 'Falha ao carregar',
                subtitle: 'Verifique a conexão',
                onAction: () => actionCalled = true,
              ),
            ),
          ),
        );

        final statusIcon = tester.widget<Icon>(find.byIcon(SigadIcons.erro));
        expect(statusIcon.color, scheme.onSurfaceVariant);

        final iconContainer = tester.widget<Container>(
          find.ancestor(
            of: find.byIcon(SigadIcons.erro),
            matching: find.byType(Container),
          ),
        );
        final decoration = iconContainer.decoration! as BoxDecoration;
        expect(decoration.color, scheme.surfaceContainer);

        final title = tester.widget<Text>(find.text('Falha ao carregar'));
        final subtitle = tester.widget<Text>(find.text('Verifique a conexão'));
        expect(title.style?.color, scheme.onSurface);
        expect(subtitle.style?.color, scheme.onSurfaceVariant);

        const semanticLabel = 'Falha ao carregar. Verifique a conexão';
        final semantics = tester.widget<Semantics>(
          find.byWidgetPredicate(
            (widget) =>
                widget is Semantics && widget.properties.label == semanticLabel,
          ),
        );
        expect(semantics.properties.liveRegion, isTrue);

        await tester.tap(
          find.widgetWithText(OutlinedButton, 'Tentar novamente'),
        );
        expect(actionCalled, isTrue);
      },
    );
  }

  testWidgets('estado de carregamento mantém anúncio e indicador', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(home: const Scaffold(body: PageStatusView.loading())),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    final semantics = tester.widget<Semantics>(
      find.byWidgetPredicate(
        (widget) =>
            widget is Semantics &&
            widget.properties.label == 'Carregando dados...',
      ),
    );
    expect(semantics.properties.liveRegion, isTrue);
  });

  testWidgets('cabe em 320 x 568 com texto ampliado a 200%', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(320, 568);
    addTearDown(() {
      tester.view.resetDevicePixelRatio();
      tester.view.resetPhysicalSize();
    });

    var actionCalled = false;

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: const TextScaler.linear(2)),
          child: child!,
        ),
        home: Scaffold(
          body: PageStatusView.error(
            subtitle: 'Verifique sua conexão e tente novamente.',
            onAction: () => actionCalled = true,
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(
      find.widgetWithText(OutlinedButton, 'Tentar novamente'),
      findsOneWidget,
    );
    expect(find.byType(SingleChildScrollView), findsOneWidget);

    final action = find.widgetWithText(OutlinedButton, 'Tentar novamente');
    await tester.ensureVisible(action);
    await tester.tap(action);
    expect(actionCalled, isTrue);
  });
}
