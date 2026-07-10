import 'package:flutter_test/flutter_test.dart';
import 'package:sigad/core/models/user_role.dart';
import 'package:sigad/core/services/notificacoes_service.dart';

void main() {
  group('NotificacoesService.porRole', () {
    test('null retorna lista vazia', () {
      expect(NotificacoesService.porRole(null), isEmpty);
    });

    test('professor retorna notificações não vazias', () {
      final lista = NotificacoesService.porRole(UserRole.professor);
      expect(lista, isNotEmpty);
    });

    test('coordenador retorna notificações não vazias', () {
      final lista = NotificacoesService.porRole(UserRole.coordenador);
      expect(lista, isNotEmpty);
    });

    test('servidorAdministrativo retorna notificações não vazias', () {
      final lista = NotificacoesService.porRole(
        UserRole.servidorAdministrativo,
      );
      expect(lista, isNotEmpty);
    });

    test('chefeDepartamento retorna mais notificações que outros roles', () {
      final chefeCount = NotificacoesService.porRole(
        UserRole.chefeDepartamento,
      ).length;
      final profCount = NotificacoesService.porRole(UserRole.professor).length;
      final coordCount = NotificacoesService.porRole(
        UserRole.coordenador,
      ).length;
      expect(chefeCount, greaterThanOrEqualTo(profCount));
      expect(chefeCount, greaterThanOrEqualTo(coordCount));
    });

    test('todos os itens têm titulo, subtitulo e icone não vazios', () {
      for (final role in UserRole.values) {
        for (final notif in NotificacoesService.porRole(role)) {
          expect(notif.titulo, isNotEmpty, reason: 'titulo vazio em $role');
          expect(
            notif.subtitulo,
            isNotEmpty,
            reason: 'subtitulo vazio em $role',
          );
          expect(notif.icone, isNotNull, reason: 'icone nulo em $role');
        }
      }
    });

    test('listas de roles distintos são independentes', () {
      final prof = NotificacoesService.porRole(UserRole.professor);
      final coord = NotificacoesService.porRole(UserRole.coordenador);
      expect(prof.first.titulo, isNot(equals(coord.first.titulo)));
    });
  });
}
