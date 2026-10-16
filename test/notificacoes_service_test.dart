import 'package:flutter_test/flutter_test.dart';
import 'package:sigad/core/models/user_role.dart';
import 'package:sigad/core/services/notificacoes_service.dart';
import 'package:sigad/features/atividades/domain/atividade_models.dart';
import 'package:sigad/features/demandas/domain/demanda_models.dart';

void main() {
  final hoje = DateTime(2026, 10, 15);

  Demanda demanda({String prazo = '14/10/2026', String status = 'Aberto'}) =>
      Demanda(
        id: 'd1',
        titulo: 'Instalação elétrica',
        descricao: 'Finalizar laboratório',
        prioridade: 'Alta',
        statusLabel: status,
        proprietario: 'Coordenação',
        prazo: prazo,
      );

  Atividade atividade({
    String data = '15/10/2026',
    String responsavel = 'Maria',
    String status = 'Pendente',
  }) => Atividade(
    id: 'a1',
    titulo: 'Entregar projeto',
    descricao: 'Trabalho acadêmico',
    data: data,
    responsavel: responsavel,
    status: status,
  );

  test('sem registros não há alertas inventados para nenhum perfil', () {
    for (final role in UserRole.values) {
      expect(NotificacoesService.porRole(role, agora: hoje), isEmpty);
    }
    expect(NotificacoesService.porRole(null, agora: hoje), isEmpty);
  });

  test('gestores recebem demandas vencidas, sem itens concluídos', () {
    final itens = [
      demanda(),
      demanda(status: 'Concluído'),
      demanda(prazo: '30/10/2026'),
      demanda(prazo: '32/10/2026'),
    ];
    for (final role in [UserRole.coordenador, UserRole.chefeDepartamento]) {
      final notificacoes = NotificacoesService.porRole(
        role,
        demandas: itens,
        agora: hoje,
      );
      expect(notificacoes, hasLength(1));
      expect(notificacoes.single.subtitulo, contains('atrasada'));
    }
  });

  test('professor não recebe demandas institucionais', () {
    final notificacoes = NotificacoesService.porRole(
      UserRole.professor,
      demandas: [demanda()],
      agora: hoje,
    );
    expect(notificacoes, isEmpty);
  });

  test('atividades são filtradas por responsável sem vazar dados', () {
    final notificacoes = NotificacoesService.porRole(
      UserRole.professor,
      userName: 'MARIA',
      atividades: [
        atividade(),
        atividade(responsavel: 'João'),
        atividade(status: 'Concluída'),
        atividade(data: '30/10/2026'),
      ],
      agora: hoje,
    );
    expect(notificacoes, hasLength(1));
    expect(notificacoes.single.titulo, 'Entregar projeto');
    expect(notificacoes.single.subtitulo, contains('hoje'));
  });

  test('somente o usuário com nome definido recebe alertas pessoais', () {
    final notificacoes = NotificacoesService.porRole(
      UserRole.servidorAdministrativo,
      atividades: [atividade()],
      agora: hoje,
    );
    expect(notificacoes, isEmpty);
  });
}
