enum RegimeTrabalhoEbtt {
  vinteHoras('20h', '20 horas', 20),
  quarentaHoras('40h', '40 horas', 40),
  dedicacaoExclusiva('DE', 'Dedicação exclusiva', 40);

  const RegimeTrabalhoEbtt(this.code, this.label, this.cargaSemanalLimite);

  final String code;
  final String label;
  final int cargaSemanalLimite;

  static RegimeTrabalhoEbtt fromStorage(String? raw, {int? cargaMaxima}) {
    switch (raw?.trim().toUpperCase()) {
      case '20H':
        return RegimeTrabalhoEbtt.vinteHoras;
      case '40H':
        return RegimeTrabalhoEbtt.quarentaHoras;
      case 'DE':
        return RegimeTrabalhoEbtt.dedicacaoExclusiva;
      default:
        if (cargaMaxima != null && cargaMaxima <= 20) {
          return RegimeTrabalhoEbtt.vinteHoras;
        }
        return RegimeTrabalhoEbtt.quarentaHoras;
    }
  }
}

class Docente {
  const Docente({
    required this.id,
    required this.nome,
    this.userId,
    this.userEmail,
    required this.departamento,
    required this.cargaHoraria,
    required this.cargaMaxima,
    required this.disciplinas,
    this.regimeTrabalho = RegimeTrabalhoEbtt.vinteHoras,
    this.horariosAula = const [],
  });

  final String id;
  final String nome;
  final String? userId;
  final String? userEmail;
  final String departamento;
  final int cargaHoraria;
  final int cargaMaxima;
  final List<String> disciplinas;
  final RegimeTrabalhoEbtt regimeTrabalho;
  final List<HorarioAula> horariosAula;

  Docente copyWith({
    String? nome,
    String? userId,
    String? userEmail,
    String? departamento,
    int? cargaHoraria,
    int? cargaMaxima,
    List<String>? disciplinas,
    RegimeTrabalhoEbtt? regimeTrabalho,
    List<HorarioAula>? horariosAula,
  }) {
    return Docente(
      id: id,
      nome: nome ?? this.nome,
      userId: userId ?? this.userId,
      userEmail: userEmail ?? this.userEmail,
      departamento: departamento ?? this.departamento,
      cargaHoraria: cargaHoraria ?? this.cargaHoraria,
      cargaMaxima: cargaMaxima ?? this.cargaMaxima,
      disciplinas: disciplinas ?? this.disciplinas,
      regimeTrabalho: regimeTrabalho ?? this.regimeTrabalho,
      horariosAula: horariosAula ?? this.horariosAula,
    );
  }
}

class HorarioAula {
  const HorarioAula({
    required this.diaSemana,
    required this.inicio,
    required this.fim,
    this.disciplina,
    this.cargaHoraria,
    this.turma,
    this.modalidade,
  });

  final String diaSemana;
  final String inicio;
  final String fim;
  final String? disciplina;
  final String? cargaHoraria;
  final String? turma;
  final String? modalidade;
}

enum TipoAtividadePlanoDocente {
  preparacaoManutencaoApoioEnsino,
  programasProjetosEnsino,
  atendimentoAcompanhamentoOrientacao,
  reunioesPedagogicas,
  pesquisa,
  extensao,
  gestaoRepresentacao,
  formacaoContinuada,
}

enum StatusPlanoTrabalhoDocente { rascunho, submetido, aprovado, devolvido }

class AtividadePlanoDocente {
  const AtividadePlanoDocente({
    required this.tipo,
    required this.descricao,
    required this.cargaSemanalMinutos,
    this.comprovante,
  });

  final TipoAtividadePlanoDocente tipo;
  final String descricao;
  final int cargaSemanalMinutos;
  final String? comprovante;
}

class IndisponibilidadeDocente {
  const IndisponibilidadeDocente({
    required this.diaSemana,
    required this.inicio,
    required this.fim,
    this.observacao,
  });

  final String diaSemana;
  final String inicio;
  final String fim;
  final String? observacao;
}

class PlanoTrabalhoDocente {
  const PlanoTrabalhoDocente({
    required this.docenteId,
    required this.periodoLetivo,
    this.atividades = const [],
    this.indisponibilidades = const [],
    this.status = StatusPlanoTrabalhoDocente.rascunho,
    this.justificativaCargaAulas,
    this.justificativaExtrapolacaoOutrasAtividades,
    this.avaliadorId,
    this.parecerAvaliacao,
    this.criadoEm,
    this.atualizadoEm,
    this.submetidoEm,
    this.avaliadoEm,
  });

  final String docenteId;
  final String periodoLetivo;
  final List<AtividadePlanoDocente> atividades;
  final List<IndisponibilidadeDocente> indisponibilidades;
  final StatusPlanoTrabalhoDocente status;
  final String? justificativaCargaAulas;
  final String? justificativaExtrapolacaoOutrasAtividades;
  final String? avaliadorId;
  final String? parecerAvaliacao;
  final DateTime? criadoEm;
  final DateTime? atualizadoEm;
  final DateTime? submetidoEm;
  final DateTime? avaliadoEm;

  String get chave => '$docenteId::$periodoLetivo';

  PlanoTrabalhoDocente copyWith({
    String? periodoLetivo,
    List<AtividadePlanoDocente>? atividades,
    List<IndisponibilidadeDocente>? indisponibilidades,
    StatusPlanoTrabalhoDocente? status,
    String? justificativaCargaAulas,
    String? justificativaExtrapolacaoOutrasAtividades,
    String? avaliadorId,
    String? parecerAvaliacao,
    DateTime? criadoEm,
    DateTime? atualizadoEm,
    DateTime? submetidoEm,
    DateTime? avaliadoEm,
    bool limparParecerAvaliacao = false,
    bool limparAvaliacao = false,
  }) {
    return PlanoTrabalhoDocente(
      docenteId: docenteId,
      periodoLetivo: periodoLetivo ?? this.periodoLetivo,
      atividades: atividades ?? this.atividades,
      indisponibilidades: indisponibilidades ?? this.indisponibilidades,
      status: status ?? this.status,
      justificativaCargaAulas:
          justificativaCargaAulas ?? this.justificativaCargaAulas,
      justificativaExtrapolacaoOutrasAtividades:
          justificativaExtrapolacaoOutrasAtividades ??
          this.justificativaExtrapolacaoOutrasAtividades,
      avaliadorId: avaliadorId ?? this.avaliadorId,
      parecerAvaliacao: limparParecerAvaliacao
          ? null
          : parecerAvaliacao ?? this.parecerAvaliacao,
      criadoEm: criadoEm ?? this.criadoEm,
      atualizadoEm: atualizadoEm ?? this.atualizadoEm,
      submetidoEm: submetidoEm ?? this.submetidoEm,
      avaliadoEm: limparAvaliacao ? null : avaliadoEm ?? this.avaliadoEm,
    );
  }

  int cargaMinutosPorTipo(TipoAtividadePlanoDocente tipo) {
    return atividades
        .where((atividade) => atividade.tipo == tipo)
        .fold(0, (total, atividade) => total + atividade.cargaSemanalMinutos);
  }

  int get cargaOutrasAtividadesEnsinoMinutos {
    const tipos = {
      TipoAtividadePlanoDocente.preparacaoManutencaoApoioEnsino,
      TipoAtividadePlanoDocente.programasProjetosEnsino,
      TipoAtividadePlanoDocente.atendimentoAcompanhamentoOrientacao,
      TipoAtividadePlanoDocente.reunioesPedagogicas,
    };
    return atividades
        .where((atividade) => tipos.contains(atividade.tipo))
        .fold(0, (total, atividade) => total + atividade.cargaSemanalMinutos);
  }

  int get cargaPesquisaExtensaoGestaoMinutos {
    const tipos = {
      TipoAtividadePlanoDocente.pesquisa,
      TipoAtividadePlanoDocente.extensao,
      TipoAtividadePlanoDocente.gestaoRepresentacao,
    };
    return atividades
        .where((atividade) => tipos.contains(atividade.tipo))
        .fold(0, (total, atividade) => total + atividade.cargaSemanalMinutos);
  }

  int get cargaAtividadesMinutos => atividades.fold(
    0,
    (total, atividade) => total + atividade.cargaSemanalMinutos,
  );
}

enum AcaoHistoricoPlanoTrabalho {
  criado,
  atualizado,
  submetido,
  aprovado,
  devolvido,
}

class EventoHistoricoPlanoTrabalho {
  const EventoHistoricoPlanoTrabalho({
    required this.planoChave,
    required this.acao,
    required this.autorId,
    required this.ocorridoEm,
    this.detalhes,
  });

  final String planoChave;
  final AcaoHistoricoPlanoTrabalho acao;
  final String autorId;
  final DateTime ocorridoEm;
  final String? detalhes;
}

enum SeveridadePendenciaPlano { aviso, bloqueio }

class PendenciaPlanoTrabalho {
  const PendenciaPlanoTrabalho({
    required this.codigo,
    required this.mensagem,
    required this.severidade,
  });

  final String codigo;
  final String mensagem;
  final SeveridadePendenciaPlano severidade;
}

class ResultadoValidacaoPlanoTrabalho {
  const ResultadoValidacaoPlanoTrabalho({required this.pendencias});

  final List<PendenciaPlanoTrabalho> pendencias;

  bool get podeSubmeter => pendencias.every(
    (pendencia) => pendencia.severidade != SeveridadePendenciaPlano.bloqueio,
  );
}

class PropostaRedistribuicao {
  const PropostaRedistribuicao({
    required this.docenteOrigemId,
    required this.docenteOrigemNome,
    required this.docenteDestinoId,
    required this.docenteDestinoNome,
    required this.horario,
    required this.cargaSemanal,
    this.pontuacao = 0,
    this.justificativas = const [],
    this.requerAtualizacaoPit = false,
  });

  final String docenteOrigemId;
  final String docenteOrigemNome;
  final String docenteDestinoId;
  final String docenteDestinoNome;
  final HorarioAula horario;
  final int cargaSemanal;
  final double pontuacao;
  final List<String> justificativas;
  final bool requerAtualizacaoPit;
}

class AvaliacaoAfinidadeRedistribuicao {
  const AvaliacaoAfinidadeRedistribuicao({
    required this.pontuacao,
    required this.explicacao,
  });

  final double pontuacao;
  final String explicacao;
}

class ResultadoSimulacaoRedistribuicao {
  const ResultadoSimulacaoRedistribuicao({
    required this.propostas,
    required this.mediaOcupacaoAntes,
    required this.mediaOcupacaoDepois,
  });

  final List<PropostaRedistribuicao> propostas;
  final double mediaOcupacaoAntes;
  final double mediaOcupacaoDepois;
}

enum ResultadoDecisaoRedistribuicao { aceita, rejeitada }

class RegistroDecisaoRedistribuicao {
  const RegistroDecisaoRedistribuicao({
    required this.docenteDestinoId,
    required this.disciplina,
    required this.diaSemana,
    required this.resultado,
    required this.ocorridoEm,
  });

  final String docenteDestinoId;
  final String disciplina;
  final String diaSemana;
  final ResultadoDecisaoRedistribuicao resultado;
  final DateTime ocorridoEm;
}
