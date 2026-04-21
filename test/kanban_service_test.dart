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

    test('fornece lista padrão mutável para suportar drag and drop', () {
      final cards = KanbanService.defaultCards();

      expect(
        () => cards[0] = cards[0].copyWith(coluna: 'Concluído'),
        returnsNormally,
      );
    });

    test('valida título do card', () {
      expect(KanbanService.validateTitulo(' '), 'Informe o título do card');
      expect(KanbanService.validateTitulo('OK'), isNull);
    });
  });
}
