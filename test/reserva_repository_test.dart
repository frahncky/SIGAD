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
    });

    test('ignora registros inválidos durante leitura', () async {
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

      repository = ReservaRepository(storageKey: 'test_sigad_reservas');
      final carregadas = await repository.loadReservas();

      expect(carregadas, hasLength(1));
      expect(carregadas.first.id, 'RES-2');
    });

    test('insere dados iniciais apenas quando a chave não existe', () async {
      const seed = ReservaLaboratorio(
        id: 'RES-SEED',
        professor: 'Professor Exemplo',
        laboratorio: 'Lab A',
        mes: 4,
        semanaDoMes: 1,
        diaSemana: 'Qua',
        turno: Turno.vespertino,
        periodo: 2,
      );

      final primeiraCarga = await repository.loadReservas(
        initialData: const [seed],
      );
      await repository.saveReservas(const []);
      final aposExcluirTudo = await repository.loadReservas(
        initialData: const [seed],
      );

      expect(primeiraCarga.single.id, seed.id);
      expect(aposExcluirTudo, isEmpty);
    });
  });
}
