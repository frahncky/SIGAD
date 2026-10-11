import 'package:flutter/material.dart';

/// Apresenta a operação funcional do módulo.
///
/// A visão gerencial é reservada para integração futura com dados reais.
/// Ela não é exibida enquanto depender de conteúdo demonstrativo.
class ModuleWorkspacePage extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return operation;
  }
}
