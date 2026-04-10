import 'package:flutter/material.dart';
import '../../../../shared/widgets/feature_placeholder_page.dart';

class KanbanPage extends StatelessWidget {
  const KanbanPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const FeaturePlaceholderPage(
      title: 'Kanban',
      subtitle: 'Visualize o fluxo das demandas por etapa.',
    );
  }
}
