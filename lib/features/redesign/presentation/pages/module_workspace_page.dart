import 'package:flutter/material.dart';

/// Mantém, no mesmo módulo, a nova visão gerencial e a operação já existente.
///
/// O redesign não substitui fluxos funcionais: o usuário pode alternar entre a
/// leitura executiva e a tela operacional sem sair do módulo.
class ModuleWorkspacePage extends StatefulWidget {
  const ModuleWorkspacePage({
    super.key,
    required this.overview,
    required this.operation,
    this.overviewLabel = 'Visão geral',
    this.operationLabel = 'Operação',
  });

  final Widget overview;
  final Widget operation;
  final String overviewLabel;
  final String operationLabel;

  @override
  State<ModuleWorkspacePage> createState() => _ModuleWorkspacePageState();
}

class _ModuleWorkspacePageState extends State<ModuleWorkspacePage> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
          child: Align(
            alignment: Alignment.centerRight,
            child: SegmentedButton<int>(
              segments: [
                ButtonSegment<int>(
                  value: 0,
                  icon: const Icon(Icons.grid_view_rounded, size: 18),
                  label: const Text('Visão'),
                ),
                ButtonSegment<int>(
                  value: 1,
                  icon: const Icon(Icons.tune_rounded, size: 18),
                  label: const Text('Gerenciar'),
                ),
              ],
              selected: {_selectedIndex},
              onSelectionChanged: (selection) {
                setState(() => _selectedIndex = selection.first);
              },
              showSelectedIcon: false,
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.resolveWith(
                  (states) => states.contains(WidgetState.selected)
                      ? colors.primaryContainer
                      : colors.surface,
                ),
                foregroundColor: WidgetStateProperty.resolveWith(
                  (states) => states.contains(WidgetState.selected)
                      ? colors.onPrimaryContainer
                      : colors.onSurfaceVariant,
                ),
                side: WidgetStatePropertyAll(
                  BorderSide(color: colors.outlineVariant),
                ),
                padding: const WidgetStatePropertyAll(
                  EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
                textStyle: WidgetStatePropertyAll(
                  Theme.of(context).textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        ),
        Expanded(
          child: IndexedStack(
            index: _selectedIndex,
            children: [widget.overview, widget.operation],
          ),
        ),
      ],
    );
  }
}
