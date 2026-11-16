import 'configuracoes_repository.dart';
import '../domain/configuracoes_models.dart';
import '../domain/configuracoes_service.dart';

abstract final class AgendaConvitesService {
  static Future<void> registrarConviteRecebido({
    required String destinatarioUserId,
    required String titulo,
    required String descricao,
    required String inicio,
    DateTime? inicioDateTime,
    required String local,
    String origem = 'Convite recebido',
    ConfiguracoesRepository? repository,
  }) async {
    final repo = repository ?? ConfiguracoesRepository();

    final convite = CompromissoAgenda(
      id: 'convite_${DateTime.now().microsecondsSinceEpoch}',
      titulo: titulo,
      descricao: descricao,
      inicio: inicio,
      inicioIso:
          (inicioDateTime ?? DateTime.now().add(const Duration(minutes: 45)))
              .toIso8601String(),
      local: local,
      origem: origem,
      destinatarioUserId: destinatarioUserId,
    );

    // Lê e grava em sequência com as demais gravações da mesma chave, para
    // não apagar preferências alteradas ao mesmo tempo (e vice-versa).
    await repo.atualizar(
      (atual) => ConfiguracoesService.adicionarConviteNaAgenda(
        data: atual,
        convite: convite,
      ),
    );
  }
}
