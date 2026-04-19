import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sigad/features/demandas/data/demanda_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('DemandaRepository', () {
    test('ignora registro inválido', () async {
      SharedPreferences.setMockInitialValues({
        'test_demandas': jsonEncode([
          {
            'id': '#DEM-001',
            'titulo': 'A',
            'descricao': 'B',
            'prioridade': 'Alta',
            'statusLabel': 'Novo',
            'proprietario': 'TI',
            'prazo': '01/01/2026',
          },
          {'id': '#DEM-ERR'},
        ]),
      });

      final repo = DemandaRepository(storageKey: 'test_demandas');
      final list = await repo.loadDemandas();

      expect(list, hasLength(1));
      expect(list.first.id, '#DEM-001');
    });
  });
}
