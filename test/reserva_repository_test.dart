import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sigad/features/aulas_praticas/data/reserva_repository.dart';
import 'package:sigad/features/aulas_praticas/domain/reserva_models.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ReservaRepository', () {
    late ReservaRepository repository;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      repository = ReservaRepository(storageKey: 'test_sigad_reservas');
    });

    test('salva e carrega reservas preservando turno e disciplina', () async {
      const reservas = [
        ReservaLaboratorio(
          id: 'RES-1',
          professor: 'Ana',
          laboratorio: 'Lab A',
          ano: 2031,
          mes: 4,
          semanaDoMes: 2,
          diaSemana: 'Seg',
          turno: Turno.noturno,
          periodo: 1,
          disciplina: 'Química',
        ),
      ];

      await repository.saveReservas(reservas);
      final carregadas = await repository.loadReservas();

      expect(carregadas, hasLength(1));
      expect(carregadas.first.turno, Turno.noturno);
      expect(carregadas.first.disciplina, 'Química');
      expect(carregadas.first.ano, 2031);
    });

    test(
      'migra ano legado uma única vez e persiste o valor injetado',
      () async {
        SharedPreferences.setMockInitialValues({
          'test_sigad_reservas': jsonEncode([
            {
              'id': 'RES-2',
              'professor': 'Bruno',
              'laboratorio': 'Lab B',
              'mes': 4,
              'semanaDoMes': 1,
              'diaSemana': 'Ter',
              'turno': 'matutino',
              'periodo': 2,
            },
            {'id': 'quebrado'},
          ]),
        });

        repository = ReservaRepository(
          storageKey: 'test_sigad_reservas',
          legacyYear: 2026,
        );
        final carregadas = await repository.loadReservas();

        expect(carregadas, hasLength(1));
        expect(carregadas.first.id, 'RES-2');
        expect(carregadas.first.ano, 2026);

        final prefs = await SharedPreferences.getInstance();
        final migratedJson =
            jsonDecode(prefs.getString('test_sigad_reservas')!)
                as List<dynamic>;
        expect((migratedJson.single as Map<String, dynamic>)['ano'], 2026);

        final reloaded = await ReservaRepository(
          storageKey: 'test_sigad_reservas',
          legacyYear: 2027,
        ).loadReservas();
        expect(reloaded.single.ano, 2026);
      },
    );
  });
}
