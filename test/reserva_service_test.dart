import 'package:flutter_test/flutter_test.dart';
import 'package:sigad/core/models/user.dart';
import 'package:sigad/core/models/user_role.dart';
import 'package:sigad/features/aulas_praticas/domain/reserva_models.dart';
import 'package:sigad/features/aulas_praticas/domain/reserva_service.dart';

void main() {
  group('ReservaService', () {
    test('filtra reservas por laboratório, mês e semana', () {
      final reservas = [
        const ReservaLaboratorio(
          id: '1',
          professor: 'Ana',
          laboratorio: 'Lab A',
          mes: 4,
          semanaDoMes: 2,
          diaSemana: 'Seg',
          turno: Turno.matutino,
          periodo: 1,
        ),
        const ReservaLaboratorio(
          id: '2',
          professor: 'Bruno',
          laboratorio: 'Lab B',
          mes: 4,
          semanaDoMes: 2,
          diaSemana: 'Seg',
          turno: Turno.matutino,
          periodo: 1,
        ),
      ];

      final filtradas = ReservaService.reservasDoLaboratorio(
        reservas: reservas,
        laboratorio: 'Lab A',
        mes: 4,
        semanaDoMes: 2,
      );

      expect(filtradas, hasLength(1));
      expect(filtradas.first.id, '1');
    });

    test('detecta conflito de horário ocupado', () {
      final reservas = [
        const ReservaLaboratorio(
          id: '1',
          professor: 'Ana',
          laboratorio: 'Lab A',
          mes: 4,
          semanaDoMes: 2,
          diaSemana: 'Seg',
          turno: Turno.matutino,
          periodo: 2,
        ),
      ];

      final ocupado = ReservaService.isSlotOccupied(
        reservas: reservas,
        laboratorio: 'Lab A',
        mes: 4,
        semanaDoMes: 2,
        diaSemana: 'Seg',
        turno: Turno.matutino,
        periodo: 2,
      );

      expect(ocupado, isTrue);
    });

    test('permite remoção para chefia e dono da reserva', () {
      const reserva = ReservaLaboratorio(
        id: '1',
        professor: 'Ana',
        laboratorio: 'Lab A',
        mes: 4,
        semanaDoMes: 2,
        diaSemana: 'Seg',
        turno: Turno.matutino,
        periodo: 1,
      );

      expect(
        ReservaService.canRemoveReservation(
          role: UserRole.professor,
          currentUserName: 'Ana',
          reserva: reserva,
        ),
        isTrue,
      );

      expect(
        ReservaService.canRemoveReservation(
          role: UserRole.chefeDepartamento,
          currentUserName: 'Outro',
          reserva: reserva,
        ),
        isTrue,
      );

      expect(
        ReservaService.canRemoveReservation(
          role: UserRole.professor,
          currentUserName: 'Outro',
          reserva: reserva,
        ),
        isFalse,
      );
    });

    test('valida acesso e geração de linhas da grade', () {
      expect(ReservaService.canAccess(UserRole.professor), isTrue);
      expect(ReservaService.canAccess(UserRole.aluno), isFalse);
      expect(ReservaService.gerarLinhasGrade(), isNotEmpty);
    });

    test('valida disciplina e criação de reserva', () {
      final erro = ReservaService.validateDisciplina(' ');
      expect(erro, 'Informe a disciplina.');

      final reserva = ReservaService.createReserva(
        professor: 'Ana',
        laboratorio: 'Lab A',
        mes: 4,
        semanaDoMes: 2,
        diaSemana: 'Ter',
        turno: Turno.vespertino,
        periodo: 3,
        disciplina: ' Química ',
      );

      expect(reserva.id.startsWith('RES-'), isTrue);
      expect(reserva.disciplina, 'Química');
    });

    test('permite alteração apenas para usuário docente logado', () {
      const user = User(
        id: '1',
        name: 'Ana',
        email: 'ana@sigad.br',
        role: UserRole.professor,
      );

      expect(
        ReservaService.canChangeReservation(user: user, role: UserRole.professor),
        isTrue,
      );
      expect(
        ReservaService.canChangeReservation(user: null, role: UserRole.professor),
        isFalse,
      );
    });
  });
}
