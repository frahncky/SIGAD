import 'package:flutter/material.dart';

/// Indicador de carregamento compartilhado do SIGAD.
class SigadLoadingIndicator extends StatelessWidget {
  const SigadLoadingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }
}
