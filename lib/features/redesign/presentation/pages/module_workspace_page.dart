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
  @override
  Widget build(BuildContext context) {
    return widget.operation;
  }
}
