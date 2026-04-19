import 'package:flutter_test/flutter_test.dart';
import 'package:sigad/features/kanban/domain/kanban_models.dart';
import 'package:sigad/features/kanban/domain/kanban_service.dart';

void main() {
  group('KanbanService', () {
    test('monta colunas e calcula próximo id', () {
      const cards = [
        KanbanCardModel(id: 1, titulo: 'A', coluna: 'Backlog', prioridade: 'Alta'),
        KanbanCardModel(id: 2, titulo: 'B', coluna: 'Concluído', prioridade: 'Baixa'),
      ];

      final colunas = KanbanService.buildColunas(cards);
      expect(colunas['Backlog']!.length, 1);
      expect(KanbanService.nextId(cards), 3);
    });

    test('valida título do card', () {
      expect(KanbanService.validateTitulo(' '), 'Informe o título do card');
      expect(KanbanService.validateTitulo('OK'), isNull);
    });
  });
}
