import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sigad/features/relatorios/data/relatorio_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('RelatorioRepository', () {
    test('carrega registros válidos e ignora inválidos', () async {
      SharedPreferences.setMockInitialValues({
        'test_relatorios': jsonEncode([
          {
            'id': '1',
            'titulo': 'A',
            'descricao': 'B',
            'tipo': 'Mensal',
            'data': 'Mar/2026',
            'autor': 'Coordenação',
            'status': 'Publicado',
            'downloads': 1,
            'compartilhamentos': 2,
          },
          {'id': '2'},
        ]),
      });

      final repo = RelatorioRepository(storageKey: 'test_relatorios');
      final list = await repo.loadRelatorios();

      expect(list, hasLength(1));
      expect(list.first.id, '1');
    });
  });
}
