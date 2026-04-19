import '../data/configuracoes_repository.dart';
import 'configuracoes_models.dart';
import 'configuracoes_service.dart';

abstract final class AgendaConvitesService {
  static Future<void> registrarConviteRecebido({
    required String destinatarioUserId,
    required String titulo,
    required String descricao,
    required String inicio,
    required String local,
    String origem = 'Convite recebido',
    ConfiguracoesRepository? repository,
  }) async {
    final repo = repository ?? ConfiguracoesRepository();
    final atual = await repo.load() ?? ConfiguracoesService.defaultData();

    final convite = CompromissoAgenda(
      id: 'convite_${DateTime.now().microsecondsSinceEpoch}',
      titulo: titulo,
      descricao: descricao,
      inicio: inicio,
      local: local,
      origem: origem,
      destinatarioUserId: destinatarioUserId,
    );

    final atualizado = ConfiguracoesService.adicionarConviteNaAgenda(
      data: atual,
      convite: convite,
    );

    await repo.save(atualizado);
  }
}
