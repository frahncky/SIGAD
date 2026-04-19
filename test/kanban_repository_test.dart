import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sigad/features/kanban/data/kanban_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('KanbanRepository', () {
    test('carrega cards válidos e ignora inválidos', () async {
      SharedPreferences.setMockInitialValues({
        'test_kanban': jsonEncode([
          {'id': 1, 'titulo': 'A', 'coluna': 'Backlog', 'prioridade': 'Alta'},
          {'id': 'erro'},
        ]),
      });

      final repo = KanbanRepository(storageKey: 'test_kanban');
      final cards = await repo.loadCards();

      expect(cards, hasLength(1));
      expect(cards.first.id, 1);
    });
  });
}
