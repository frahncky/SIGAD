import 'package:flutter_test/flutter_test.dart';

import 'package:sigad/features/aulas_praticas/domain/reserva_models.dart';
import 'package:sigad/features/aulas_praticas/domain/reserva_service.dart';

ReservaLaboratorio _reserva({
  required int ano,
  required int mes,
  required int semana,
  required String dia,
}) => ReservaLaboratorio(
  id: 'r',
  professor: 'P',
  laboratorio: 'Lab',
  ano: ano,
  mes: mes,
  semanaDoMes: semana,
  diaSemana: dia,
  turno: Turno.matutino,
  periodo: 1,
);

void main() {
  group('datas das reservas', () {
    test('semanaDoMesDe usa blocos de 7 dias do mês', () {
      expect(ReservaService.semanaDoMesDe(DateTime(2026, 10, 1)), 1);
      expect(ReservaService.semanaDoMesDe(DateTime(2026, 10, 7)), 1);
      expect(ReservaService.semanaDoMesDe(DateTime(2026, 10, 8)), 2);
      expect(ReservaService.semanaDoMesDe(DateTime(2026, 10, 31)), 5);
    });

    test('diaSemanaDe só devolve dias úteis', () {
      expect(ReservaService.diaSemanaDe(DateTime(2026, 10, 5)), 'Seg');
      expect(ReservaService.diaSemanaDe(DateTime(2026, 10, 9)), 'Sex');
      expect(ReservaService.diaSemanaDe(DateTime(2026, 10, 10)), isNull);
      expect(ReservaService.diaSemanaDe(DateTime(2026, 10, 11)), isNull);
    });

    test('dataDaReserva ida e volta, inclusive bloco 5 parcial', () {
      for (var dia = 1; dia <= 31; dia++) {
        final data = DateTime(2026, 10, dia);
        final diaSemana = ReservaService.diaSemanaDe(data);
        if (diaSemana == null) continue;
        final reserva = _reserva(
          ano: 2026,
          mes: 10,
          semana: ReservaService.semanaDoMesDe(data),
          dia: diaSemana,
        );
        expect(ReservaService.dataDaReserva(reserva), data);
      }
      // Bloco 5 de outubro/2026 tem só 29 (qui), 30 (sex) e 31 (sáb).
      expect(
        ReservaService.dataDaReserva(
          _reserva(ano: 2026, mes: 10, semana: 5, dia: 'Seg'),
        ),
        isNull,
      );
      expect(
        ReservaService.dataDaReserva(
          _reserva(ano: 2026, mes: 10, semana: 1, dia: 'Dom'),
        ),
        isNull,
      );
    });

    test('segundaDaSemana: dia útil, fim de semana e virada de ano', () {
      expect(
        ReservaService.segundaDaSemana(DateTime(2026, 10, 8)),
        DateTime(2026, 10, 5),
      );
      // Sábado e domingo mostram a semana seguinte.
      expect(
        ReservaService.segundaDaSemana(DateTime(2026, 10, 10)),
        DateTime(2026, 10, 12),
      );
      expect(
        ReservaService.segundaDaSemana(DateTime(2026, 10, 11)),
        DateTime(2026, 10, 12),
      );
      // Semana que atravessa meses e anos.
      expect(
        ReservaService.segundaDaSemana(DateTime(2026, 10, 2)),
        DateTime(2026, 9, 28),
      );
      expect(
        ReservaService.segundaDaSemana(DateTime(2027, 1, 1)),
        DateTime(2026, 12, 28),
      );
    });

    test('diaDaMesmaSemana move só dentro da semana segunda–sexta', () {
      // Quinta 08/10 → segunda da mesma semana = 05/10 (e não 12/10).
      expect(
        ReservaService.diaDaMesmaSemana(DateTime(2026, 10, 8), 'Seg'),
        DateTime(2026, 10, 5),
      );
      // Quinta 29/10 → segunda 26/10: nunca uma data inexistente.
      final segunda = ReservaService.diaDaMesmaSemana(
        DateTime(2026, 10, 29),
        'Seg',
      )!;
      expect(segunda, DateTime(2026, 10, 26));
      expect(ReservaService.semanaDoMesDe(segunda), 4);
      // Sexta 02/10 → segunda 28/09, em outro mês.
      expect(
        ReservaService.diaDaMesmaSemana(DateTime(2026, 10, 2), 'Seg'),
        DateTime(2026, 9, 28),
      );
      expect(
        ReservaService.diaDaMesmaSemana(DateTime(2026, 10, 2), 'Sáb'),
        isNull,
      );
    });

    test('reservaNaData encontra a reserva pela data real', () {
      final quinta08 = _reserva(ano: 2026, mes: 10, semana: 2, dia: 'Qui');
      final achada = ReservaService.reservaNaData(
        reservas: [quinta08],
        laboratorio: 'Lab',
        data: DateTime(2026, 10, 8),
        turno: Turno.matutino,
        periodo: 1,
      );
      expect(achada, same(quinta08));
      expect(
        ReservaService.reservaNaData(
          reservas: [quinta08],
          laboratorio: 'Lab',
          data: DateTime(2026, 10, 1),
          turno: Turno.matutino,
          periodo: 1,
        ),
        isNull,
      );
    });
  });
}
