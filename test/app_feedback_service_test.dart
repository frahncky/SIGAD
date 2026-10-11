import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sigad/app/theme/app_theme.dart';
import 'package:sigad/app/theme/sigad_icons.dart';
import 'package:sigad/core/services/app_feedback_service.dart';

void main() {
  GoogleFonts.config.allowRuntimeFetching = false;

  const message = 'Operação processada';
  final feedbackCases = <_FeedbackCase>[
    _FeedbackCase(
      name: 'informação',
      label: 'Informação',
      icon: SigadIcons.info,
      show: AppFeedbackService.info,
      background: (scheme) => scheme.tertiaryContainer,
      foreground: (scheme) => scheme.onTertiaryContainer,
    ),
    _FeedbackCase(
      name: 'sucesso',
      label: 'Sucesso',
      icon: SigadIcons.concluido,
      show: AppFeedbackService.success,
      background: (scheme) => scheme.primaryContainer,
      foreground: (scheme) => scheme.onPrimaryContainer,
    ),
    _FeedbackCase(
      name: 'atenção',
      label: 'Atenção',
      icon: SigadIcons.alerta,
      show: AppFeedbackService.warning,
      background: (scheme) => scheme.secondaryContainer,
      foreground: (scheme) => scheme.onSecondaryContainer,
    ),
    _FeedbackCase(
      name: 'erro',
      label: 'Erro',
      icon: SigadIcons.erro,
      show: AppFeedbackService.error,
      background: (scheme) => scheme.errorContainer,
      foreground: (scheme) => scheme.onErrorContainer,
    ),
  ];

  for (final brightness in Brightness.values) {
    for (final feedbackCase in feedbackCases) {
      testWidgets(
        '${feedbackCase.name} usa cor, ícone e semântica acessíveis no tema '
        '${brightness.name}',
        (tester) async {
          final theme = brightness == Brightness.dark
              ? AppTheme.dark()
              : AppTheme.light();
          final scheme = theme.colorScheme;
          late BuildContext hostContext;

          await tester.pumpWidget(
            MaterialApp(
              theme: theme,
              home: Scaffold(
                body: Builder(
                  builder: (context) {
                    hostContext = context;
                    return const SizedBox.shrink();
                  },
                ),
              ),
            ),
          );

          feedbackCase.show(hostContext, message);
          await tester.pumpAndSettle();

          final snackBar = tester.widget<SnackBar>(find.byType(SnackBar));
          final expectedBackground = feedbackCase.background(scheme);
          final expectedForeground = feedbackCase.foreground(scheme);

          expect(snackBar.backgroundColor, expectedBackground);
          final closeButton = tester.widget<IconButton>(
            find.widgetWithIcon(IconButton, SigadIcons.fechar),
          );
          expect(closeButton.color, expectedForeground);
          expect(closeButton.tooltip, isNotEmpty);
          expect(find.byIcon(feedbackCase.icon), findsOneWidget);
          expect(find.text(feedbackCase.label), findsOneWidget);
          expect(find.text(message), findsOneWidget);

          final labelText = tester.widget<Text>(find.text(feedbackCase.label));
          final messageText = tester.widget<Text>(find.text(message));
          expect(labelText.style?.color, expectedForeground);
          expect(messageText.style?.color, expectedForeground);
          expect(
            _contrastRatio(expectedBackground, expectedForeground),
            greaterThanOrEqualTo(4.5),
          );

          final semanticLabel = '${feedbackCase.label}: $message';
          final semantics = tester.widget<Semantics>(
            find.byWidgetPredicate(
              (widget) =>
                  widget is Semantics &&
                  widget.properties.label == semanticLabel,
            ),
          );
          expect(semantics.properties.liveRegion, isTrue);

          expect(find.byIcon(SigadIcons.fechar), findsOneWidget);
          await tester.tap(find.byIcon(SigadIcons.fechar));
          await tester.pumpAndSettle();
          expect(find.byType(SnackBar), findsNothing);
        },
      );
    }
  }

  testWidgets('mensagem longa cabe em 320 px com texto ampliado a 200%', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(320, 568);
    addTearDown(() {
      tester.view.resetDevicePixelRatio();
      tester.view.resetPhysicalSize();
    });

    late BuildContext hostContext;
    final theme = AppTheme.dark();

    await tester.pumpWidget(
      MaterialApp(
        theme: theme,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: const TextScaler.linear(2)),
          child: child!,
        ),
        home: Scaffold(
          body: Builder(
            builder: (context) {
              hostContext = context;
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );

    AppFeedbackService.warning(
      hostContext,
      'A conexão está instável. Confira os dados antes de tentar novamente.',
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('Atenção'), findsOneWidget);
    expect(find.byIcon(SigadIcons.fechar), findsOneWidget);
    await tester.tap(find.byIcon(SigadIcons.fechar));
    await tester.pumpAndSettle();
    expect(find.byType(SnackBar), findsNothing);
  });
}

double _contrastRatio(Color first, Color second) {
  final firstLuminance = first.computeLuminance();
  final secondLuminance = second.computeLuminance();
  final lighter = firstLuminance > secondLuminance
      ? firstLuminance
      : secondLuminance;
  final darker = firstLuminance > secondLuminance
      ? secondLuminance
      : firstLuminance;
  return (lighter + 0.05) / (darker + 0.05);
}

typedef _ShowFeedback = void Function(BuildContext context, String message);
typedef _SchemeColor = Color Function(ColorScheme scheme);

class _FeedbackCase {
  const _FeedbackCase({
    required this.name,
    required this.label,
    required this.icon,
    required this.show,
    required this.background,
    required this.foreground,
  });

  final String name;
  final String label;
  final IconData icon;
  final _ShowFeedback show;
  final _SchemeColor background;
  final _SchemeColor foreground;
}
