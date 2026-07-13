import '../../../core/services/local_storage_service.dart';
import '../domain/docente_models.dart';

class PlanoTrabalhoRepository {
  PlanoTrabalhoRepository({
    this.planosStorageKey = 'sigad_planos_trabalho_docente',
    this.historicoStorageKey = 'sigad_planos_trabalho_historico',
  });

  final String planosStorageKey;
  final String historicoStorageKey;

  Future<List<PlanoTrabalhoDocente>> loadPlanos() async {
    final dados = await LocalStorageService.loadList(planosStorageKey);
    return dados
        .map(_planoFromJson)
        .whereType<PlanoTrabalhoDocente>()
        .toList(growable: false);
  }

  Future<PlanoTrabalhoDocente?> findPlano({
    required String docenteId,
    required String periodoLetivo,
  }) async {
    final chave = '$docenteId::$periodoLetivo';
    final planos = await loadPlanos();
    for (final plano in planos) {
      if (plano.chave == chave) return plano;
    }
    return null;
  }

  Future<void> savePlano(
    PlanoTrabalhoDocente plano, {
    required String autorId,
    required AcaoHistoricoPlanoTrabalho acao,
    String? detalhes,
  }) async {
    final planos = await loadPlanos();
    final atualizados = List<PlanoTrabalhoDocente>.from(planos);
    final index = atualizados.indexWhere((item) => item.chave == plano.chave);
    if (index >= 0) {
      atualizados[index] = plano;
    } else {
      atualizados.add(plano);
    }
    await LocalStorageService.saveList(
      planosStorageKey,
      atualizados.map(_planoToJson).toList(growable: false),
    );

    final historico = await loadHistorico();
    final evento = EventoHistoricoPlanoTrabalho(
      planoChave: plano.chave,
      acao: acao,
      autorId: autorId,
      ocorridoEm: DateTime.now(),
      detalhes: detalhes,
    );
    await LocalStorageService.saveList(
      historicoStorageKey,
      [...historico, evento].map(_eventoToJson).toList(growable: false),
    );
  }

  Future<List<EventoHistoricoPlanoTrabalho>> loadHistorico({
    String? planoChave,
  }) async {
    final dados = await LocalStorageService.loadList(historicoStorageKey);
    final eventos =
        dados
            .map(_eventoFromJson)
            .whereType<EventoHistoricoPlanoTrabalho>()
            .where(
              (evento) => planoChave == null || evento.planoChave == planoChave,
            )
            .toList(growable: true)
          ..sort((a, b) => a.ocorridoEm.compareTo(b.ocorridoEm));
    return eventos;
  }

  Map<String, dynamic> _planoToJson(PlanoTrabalhoDocente plano) => {
    'docenteId': plano.docenteId,
    'periodoLetivo': plano.periodoLetivo,
    'status': plano.status.name,
    if (plano.justificativaCargaAulas != null)
      'justificativaCargaAulas': plano.justificativaCargaAulas,
    if (plano.justificativaExtrapolacaoOutrasAtividades != null)
      'justificativaExtrapolacaoOutrasAtividades':
          plano.justificativaExtrapolacaoOutrasAtividades,
    if (plano.avaliadorId != null) 'avaliadorId': plano.avaliadorId,
    if (plano.parecerAvaliacao != null)
      'parecerAvaliacao': plano.parecerAvaliacao,
    if (plano.criadoEm != null) 'criadoEm': plano.criadoEm!.toIso8601String(),
    if (plano.atualizadoEm != null)
      'atualizadoEm': plano.atualizadoEm!.toIso8601String(),
    if (plano.submetidoEm != null)
      'submetidoEm': plano.submetidoEm!.toIso8601String(),
    if (plano.avaliadoEm != null)
      'avaliadoEm': plano.avaliadoEm!.toIso8601String(),
    'atividades': plano.atividades
        .map(
          (atividade) => {
            'tipo': atividade.tipo.name,
            'descricao': atividade.descricao,
            'cargaSemanalMinutos': atividade.cargaSemanalMinutos,
            if (atividade.comprovante != null)
              'comprovante': atividade.comprovante,
          },
        )
        .toList(growable: false),
    'indisponibilidades': plano.indisponibilidades
        .map(
          (item) => {
            'diaSemana': item.diaSemana,
            'inicio': item.inicio,
            'fim': item.fim,
            if (item.observacao != null) 'observacao': item.observacao,
          },
        )
        .toList(growable: false),
  };

  PlanoTrabalhoDocente? _planoFromJson(Map<String, dynamic> json) {
    final docenteId = _texto(json['docenteId']);
    final periodo = _texto(json['periodoLetivo']);
    if (docenteId == null || periodo == null) return null;

    final atividadesRaw = json['atividades'];
    final atividades = atividadesRaw is List
        ? atividadesRaw
              .whereType<Map>()
              .map(
                (item) => _atividadeFromJson(Map<String, dynamic>.from(item)),
              )
              .whereType<AtividadePlanoDocente>()
              .toList(growable: false)
        : const <AtividadePlanoDocente>[];
    final indisponibilidadesRaw = json['indisponibilidades'];
    final indisponibilidades = indisponibilidadesRaw is List
        ? indisponibilidadesRaw
              .whereType<Map>()
              .map(
                (item) =>
                    _indisponibilidadeFromJson(Map<String, dynamic>.from(item)),
              )
              .whereType<IndisponibilidadeDocente>()
              .toList(growable: false)
        : const <IndisponibilidadeDocente>[];

    return PlanoTrabalhoDocente(
      docenteId: docenteId,
      periodoLetivo: periodo,
      atividades: atividades,
      indisponibilidades: indisponibilidades,
      status: _enumByName(
        StatusPlanoTrabalhoDocente.values,
        json['status'],
        StatusPlanoTrabalhoDocente.rascunho,
      ),
      justificativaCargaAulas: _texto(json['justificativaCargaAulas']),
      justificativaExtrapolacaoOutrasAtividades: _texto(
        json['justificativaExtrapolacaoOutrasAtividades'],
      ),
      avaliadorId: _texto(json['avaliadorId']),
      parecerAvaliacao: _texto(json['parecerAvaliacao']),
      criadoEm: _data(json['criadoEm']),
      atualizadoEm: _data(json['atualizadoEm']),
      submetidoEm: _data(json['submetidoEm']),
      avaliadoEm: _data(json['avaliadoEm']),
    );
  }

  AtividadePlanoDocente? _atividadeFromJson(Map<String, dynamic> json) {
    final tipo = _enumByNameOrNull(
      TipoAtividadePlanoDocente.values,
      json['tipo'],
    );
    final descricao = _texto(json['descricao']);
    final minutos = int.tryParse(json['cargaSemanalMinutos']?.toString() ?? '');
    if (tipo == null || descricao == null || minutos == null || minutos < 0) {
      return null;
    }
    return AtividadePlanoDocente(
      tipo: tipo,
      descricao: descricao,
      cargaSemanalMinutos: minutos,
      comprovante: _texto(json['comprovante']),
    );
  }

  IndisponibilidadeDocente? _indisponibilidadeFromJson(
    Map<String, dynamic> json,
  ) {
    final dia = _texto(json['diaSemana']);
    final inicio = _texto(json['inicio']);
    final fim = _texto(json['fim']);
    if (dia == null || inicio == null || fim == null) return null;
    return IndisponibilidadeDocente(
      diaSemana: dia,
      inicio: inicio,
      fim: fim,
      observacao: _texto(json['observacao']),
    );
  }

  Map<String, dynamic> _eventoToJson(EventoHistoricoPlanoTrabalho evento) => {
    'planoChave': evento.planoChave,
    'acao': evento.acao.name,
    'autorId': evento.autorId,
    'ocorridoEm': evento.ocorridoEm.toIso8601String(),
    if (evento.detalhes != null) 'detalhes': evento.detalhes,
  };

  EventoHistoricoPlanoTrabalho? _eventoFromJson(Map<String, dynamic> json) {
    final planoChave = _texto(json['planoChave']);
    final autorId = _texto(json['autorId']);
    final ocorridoEm = _data(json['ocorridoEm']);
    final acao = _enumByNameOrNull(
      AcaoHistoricoPlanoTrabalho.values,
      json['acao'],
    );
    if (planoChave == null ||
        autorId == null ||
        ocorridoEm == null ||
        acao == null) {
      return null;
    }
    return EventoHistoricoPlanoTrabalho(
      planoChave: planoChave,
      acao: acao,
      autorId: autorId,
      ocorridoEm: ocorridoEm,
      detalhes: _texto(json['detalhes']),
    );
  }

  String? _texto(dynamic raw) {
    final texto = raw?.toString().trim();
    return texto == null || texto.isEmpty ? null : texto;
  }

  DateTime? _data(dynamic raw) => DateTime.tryParse(raw?.toString() ?? '');

  T _enumByName<T extends Enum>(List<T> values, dynamic raw, T fallback) {
    return _enumByNameOrNull(values, raw) ?? fallback;
  }

  T? _enumByNameOrNull<T extends Enum>(List<T> values, dynamic raw) {
    final nome = raw?.toString();
    for (final value in values) {
      if (value.name == nome) return value;
    }
    return null;
  }
}
