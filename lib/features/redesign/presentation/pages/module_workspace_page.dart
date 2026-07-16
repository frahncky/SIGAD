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
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Align(
            alignment: Alignment.centerLeft,
            child: SegmentedButton<int>(
              segments: [
                ButtonSegment<int>(
                  value: 0,
                  icon: const Icon(Icons.dashboard_outlined),
                  label: Text(widget.overviewLabel),
                ),
                ButtonSegment<int>(
                  value: 1,
                  icon: const Icon(Icons.tune_rounded),
                  label: Text(widget.operationLabel),
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
              ),
            ),
          ),
        ),
        Expanded(
          child: IndexedStack(
            index: _selectedIndex,
            children: [
              widget.overview,
              widget.operation,
            ],
          ),
        ),
      ],
    );
  }
}
