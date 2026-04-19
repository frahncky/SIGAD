import 'package:flutter_test/flutter_test.dart';
import 'package:sigad/core/models/user_role.dart';
import 'package:sigad/features/carga_docente/domain/docente_visibility_service.dart';

class _DocenteFake {
  const _DocenteFake({this.userId, this.userEmail});

  final String? userId;
  final String? userEmail;
}

void main() {
  group('DocenteVisibilityService.canProfessorSeeDocente', () {
    test('prioriza userId quando ambos possuem userId', () {
      final result = DocenteVisibilityService.canProfessorSeeDocente(
        currentUserId: 'user_email_prof@escola.br',
        currentUserEmail: 'outro@escola.br',
        docenteUserId: 'user_email_prof@escola.br',
        docenteUserEmail: 'nao-importa@escola.br',
      );

      expect(result, isTrue);
    });

    test('cai para email quando userId não está disponível', () {
      final result = DocenteVisibilityService.canProfessorSeeDocente(
        currentUserId: null,
        currentUserEmail: 'PROF@escola.br',
        docenteUserId: null,
        docenteUserEmail: 'prof@escola.br',
      );

      expect(result, isTrue);
    });

    test('retorna falso quando não há match por userId nem email', () {
      final result = DocenteVisibilityService.canProfessorSeeDocente(
        currentUserId: 'user_email_a@escola.br',
        currentUserEmail: 'a@escola.br',
        docenteUserId: 'user_email_b@escola.br',
        docenteUserEmail: 'b@escola.br',
      );

      expect(result, isFalse);
    });
  });

  group('DocenteVisibilityService.filterDocentesForRole', () {
    test('professor vê apenas docente vinculado', () {
      final docentes = [
        const _DocenteFake(userId: 'user_email_prof@escola.br', userEmail: 'prof@escola.br'),
        const _DocenteFake(userId: 'user_email_outro@escola.br', userEmail: 'outro@escola.br'),
      ];

      final visiveis = DocenteVisibilityService.filterDocentesForRole<_DocenteFake>(
        role: UserRole.professor,
        docentes: docentes,
        currentUserId: 'user_email_prof@escola.br',
        currentUserEmail: 'prof@escola.br',
        getUserId: (d) => d.userId,
        getUserEmail: (d) => d.userEmail,
      );

      expect(visiveis.length, 1);
      expect(visiveis.first.userEmail, 'prof@escola.br');
    });

    test('coordenação vê todos os docentes', () {
      final docentes = [
        const _DocenteFake(userId: 'u1', userEmail: 'a@escola.br'),
        const _DocenteFake(userId: 'u2', userEmail: 'b@escola.br'),
      ];

      final visiveis = DocenteVisibilityService.filterDocentesForRole<_DocenteFake>(
        role: UserRole.coordenador,
        docentes: docentes,
        currentUserId: 'qualquer',
        currentUserEmail: 'qualquer@escola.br',
        getUserId: (d) => d.userId,
        getUserEmail: (d) => d.userEmail,
      );

      expect(visiveis.length, 2);
    });
  });
}
