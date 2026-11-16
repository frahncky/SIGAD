import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../app/theme/sigad_icon.dart';
import '../../app/theme/sigad_icons.dart';

/// Abre um bottom sheet rolável, limitado a 85% da altura da tela.
///
/// Quando [dismissible] é `false` (formulários com dados digitados), o sheet
/// não fecha com toque fora nem com arraste, e não mostra a alça.
Future<T?> showSigadSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool dismissible = true,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: dismissible,
    isDismissible: dismissible,
    enableDrag: dismissible,
    builder: builder,
  );
}

/// Estrutura padrão dos sheets: cabeçalho com título e botão fechar e corpo
/// roláveis, e rodapé opcional fixo.
///
/// Em alturas pequenas (paisagem ou teclado aberto) o rodapé também passa a
/// rolar junto, para que nada fique cortado.
class SigadSheetFrame extends StatelessWidget {
  const SigadSheetFrame({
    super.key,
    required this.title,
    required this.closeTooltip,
    required this.onClose,
    required this.body,
    this.footer,
    this.leading,
  });

  /// Altura mínima para manter o rodapé fixo.
  static const alturaMinimaFixa = 420.0;

  final String title;
  final String closeTooltip;
  final VoidCallback? onClose;
  final Widget body;
  final Widget? footer;

  /// Conteúdo opcional acima do título (por exemplo, um identificador).
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final teclado = mq.viewInsets.bottom;
    final alturaMaxima = math.max(
      0.0,
      math.min(
        mq.size.height * 0.85,
        mq.size.height - teclado - mq.padding.top,
      ),
    );
    final textTheme = Theme.of(context).textTheme;

    final cabecalho = Padding(
      padding: const EdgeInsets.fromLTRB(24, 4, 12, 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (leading != null) ...[leading!, const SizedBox(height: 4)],
                  Semantics(
                    header: true,
                    child: Text(
                      title,
                      style: textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            tooltip: closeTooltip,
            onPressed: onClose,
            icon: const SigadIcon(SigadIcons.fechar),
          ),
        ],
      ),
    );

    return Padding(
      padding: EdgeInsets.only(bottom: teclado),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: alturaMaxima),
        child: SafeArea(
          top: false,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final compacto = constraints.maxHeight < alturaMinimaFixa;
              if (compacto) {
                return SingleChildScrollView(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      cabecalho,
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            body,
                            if (footer != null) ...[
                              const SizedBox(height: 24),
                              footer!,
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }
              // O cabeçalho rola junto com o corpo: títulos longos com fonte
              // ampliada não podem empurrar o rodapé para fora da tela.
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: SingleChildScrollView(
                      keyboardDismissBehavior:
                          ScrollViewKeyboardDismissBehavior.onDrag,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          cabecalho,
                          Padding(
                            padding: EdgeInsets.fromLTRB(
                              24,
                              8,
                              24,
                              footer == null ? 24 : 16,
                            ),
                            child: body,
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (footer != null)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
                      child: footer,
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

/// Par de ações (secundária e principal) que empilha em telas estreitas ou
/// com fonte ampliada.
class SigadDualActions extends StatelessWidget {
  const SigadDualActions({
    super.key,
    required this.secondaryLabel,
    required this.onSecondary,
    required this.primaryLabel,
    required this.onPrimary,
    this.secondaryIcon,
    this.primaryIcon,
    this.minSideBySideWidth = 320,
  });

  final String secondaryLabel;
  final VoidCallback? onSecondary;
  final String primaryLabel;
  final VoidCallback? onPrimary;

  /// Ícones opcionais exibidos antes de cada rótulo.
  final IconData? secondaryIcon;
  final IconData? primaryIcon;

  /// Largura mínima para os botões ficarem lado a lado.
  final double minSideBySideWidth;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final textScale = MediaQuery.textScalerOf(context).scale(14) / 14;
        final empilhar =
            constraints.maxWidth < minSideBySideWidth || textScale > 1.3;
        final textoSecundario = Text(
          secondaryLabel,
          textAlign: TextAlign.center,
        );
        final textoPrincipal = Text(primaryLabel, textAlign: TextAlign.center);
        final secundario = secondaryIcon == null
            ? OutlinedButton(onPressed: onSecondary, child: textoSecundario)
            : OutlinedButton.icon(
                onPressed: onSecondary,
                icon: SigadIcon(secondaryIcon),
                label: textoSecundario,
              );
        final principal = primaryIcon == null
            ? ElevatedButton(onPressed: onPrimary, child: textoPrincipal)
            : ElevatedButton.icon(
                onPressed: onPrimary,
                icon: SigadIcon(primaryIcon),
                label: textoPrincipal,
              );
        if (empilhar) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [secundario, const SizedBox(height: 12), principal],
          );
        }
        return Row(
          children: [
            Expanded(child: secundario),
            const SizedBox(width: 12),
            Expanded(child: principal),
          ],
        );
      },
    );
  }
}
