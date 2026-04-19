import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sigad/features/atividades/data/atividade_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AtividadeRepository', () {
    test('carrega registros válidos e ignora inválidos', () async {
      SharedPreferences.setMockInitialValues({
        'test_atividades': jsonEncode([
          {
            'id': '#ATV-001',
            'titulo': 'A',
            'descricao': 'B',
            'data': '01/01/2026',
            'responsavel': 'TI',
            'status': 'Pendente',
          },
          {'id': '#ATV-ERR'},
        ]),
      });

      final repo = AtividadeRepository(storageKey: 'test_atividades');
      final list = await repo.loadAtividades();

      expect(list, hasLength(1));
      expect(list.first.id, '#ATV-001');
    });
  });
}
