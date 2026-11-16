import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/services/greeting_name_provider.dart';
import '../../core/services/user_context_provider.dart';
import '../../l10n/l10n.dart';

String greetingText(BuildContext context, {DateTime? now}) {
  final hour = (now ?? DateTime.now()).hour;
  final greeting = hour >= 5 && hour < 12
      ? context.l10n.bomDia
      : hour >= 12 && hour < 18
      ? context.l10n.boaTarde
      : context.l10n.boaNoite;
  final preference = context.watch<GreetingNameProvider?>();
  final user = context.watch<UserContextProvider>().currentUser;
  final name =
      preference?.displayName ??
      (user?.name.trim().split(RegExp(r'\s+')).first ?? '');
  return name.isEmpty
      ? context.l10n.saudacaoSemNome(greeting)
      : context.l10n.saudacaoComNome(greeting, name);
}

class GreetingTitle extends StatelessWidget {
  const GreetingTitle({super.key, required this.text, this.style});
  final String text;

  /// Estilo opcional, usado quando a saudação fica sobre o fundo do topo.
  final TextStyle? style;

  @override
  Widget build(BuildContext context) => Tooltip(
    message: text,
    child: InkWell(
      onTap: () => showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          scrollable: true,
          content: SelectableText(text),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(context.l10n.fechar),
            ),
          ],
        ),
      ),
      child: Semantics(
        label: text,
        button: true,
        excludeSemantics: true,
        // Alvo de toque mínimo de 48 dp, com o texto centralizado.
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 48),
          child: Align(
            alignment: AlignmentDirectional.centerStart,
            widthFactor: 1,
            child: Text(
              text,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style:
                  style ??
                  Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ),
        ),
      ),
    ),
  );
}
