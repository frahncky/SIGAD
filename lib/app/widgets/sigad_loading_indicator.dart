/// Widget de exemplo compartilhado para o app SIGAD.
/// Adicione aqui widgets reutilizáveis entre telas.
import 'package:flutter/material.dart';

class SigadLoadingIndicator extends StatelessWidget {
  const SigadLoadingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }
}
