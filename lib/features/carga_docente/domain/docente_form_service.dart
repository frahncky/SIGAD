import 'dart:math' as math;

import 'docente_models.dart';

typedef AvaliadorAfinidadeRedistribuicao =
    AvaliacaoAfinidadeRedistribuicao Function(
      Docente docenteDestino,
      HorarioAula horario,
    );

class LimitesCargaAulas {
  const LimitesCargaAulas({required this.minima, required this.maxima});

  final int minima;
  final int maxima;
}

class RegrasDistribuicaoCarga {
  const RegrasDistribuicaoCarga({
    required this.cargaMinimaAulas20h,
    required this.cargaMaximaAulas20h,
    required this.cargaMinimaAulasIntegral,
    required this.cargaMaximaAulasIntegral,
    this.rapCampusAtingida = false,
    this.cargaMinimaAulasIntegralComRap = 8,
    this.instituicao = 'IFMA',
    this.referenciaInstitucional = 'Resolução CONSUP/IFMA nº 67/2019',
    this.referenciaFederal = 'Portaria MEC nº 750/2024',
    this.duracaoHoraAulaMinutos = 50,
    this.cargaMaximaReunioesPedagogicasMinutos = 240,
    this.cargaMaximaPesquisaExtensaoGestao20hMinutos = 240,
    this.cargaMaximaPesquisaExtensaoGestaoIntegralMinutos = 1200,
  });

  const RegrasDistribuicaoCarga.ifma({this.rapCampusAtingida = false})
    : cargaMinimaAulas20h = 8,
      cargaMaximaAulas20h = 10,
      cargaMinimaAulasIntegral = 10,
      cargaMaximaAulasIntegral = 20,
      cargaMinimaAulasIntegralComRap = 8,
      instituicao = 'IFMA',
      referenciaInstitucional = 'Resolução CONSUP/IFMA nº 67/2019',
      referenciaFederal = 'Portaria MEC nº 750/2024',
      duracaoHoraAulaMinutos = 50,
      cargaMaximaReunioesPedagogicasMinutos = 240,
      cargaMaximaPesquisaExtensaoGestao20hMinutos = 240,
      cargaMaximaPesquisaExtensaoGestaoIntegralMinutos = 1200;

  final int cargaMinimaAulas20h;
  final int cargaMaximaAulas20h;
  final int cargaMinimaAulasIntegral;
  final int cargaMaximaAulasIntegral;
  final bool rapCampusAtingida;
  final int cargaMinimaAulasIntegralComRap;
  final String instituicao;
  final String referenciaInstitucional;
  final String referenciaFederal;
  final int duracaoHoraAulaMinutos;
  final int cargaMaximaReunioesPedagogicasMinutos;
  final int cargaMaximaPesquisaExtensaoGestao20hMinutos;
  final int cargaMaximaPesquisaExtensaoGestaoIntegralMinutos;

  LimitesCargaAulas limitesAulasPara(RegimeTrabalhoEbtt regime) {
    switch (regime) {
      case RegimeTrabalhoEbtt.vinteHoras:
        return LimitesCargaAulas(
          minima: cargaMinimaAulas20h,
          maxima: cargaMaximaAulas20h,
        );
      case RegimeTrabalhoEbtt.quarentaHoras:
      case RegimeTrabalhoEbtt.dedicacaoExclusiva:
        return LimitesCargaAulas(
          minima: rapCampusAtingida
              ? cargaMinimaAulasIntegralComRap
              : cargaMinimaAulasIntegral,
          maxima: cargaMaximaAulasIntegral,
        );
    }
  }

  int cargaMaximaPesquisaExtensaoGestaoMinutosPara(RegimeTrabalhoEbtt regime) {
    return regime == RegimeTrabalhoEbtt.vinteHoras
        ? cargaMaximaPesquisaExtensaoGestao20hMinutos
        : cargaMaximaPesquisaExtensaoGestaoIntegralMinutos;
  }
}

abstract final class DocenteFormService {
  static String? validateDocente({
    required String nome,
    required String departamento,
    required String cargaMaxima,
    required List<String> disciplinas,
    required RegimeTrabalhoEbtt regimeTrabalho,
    required List<HorarioAula> horarios,
  }) {
    if (nome.trim().isEmpty) {
      return 'Informe o nome do docente';
    }

    if (departamento.trim().isEmpty) {
      return 'Informe o departamento';
    }

    final carga = int.tryParse(cargaMaxima.trim());
    if (carga == null || carga <= 0) {
      return 'Informe uma carga horária máxima válida';
    }

    if (carga > regimeTrabalho.cargaSemanalLimite) {
      return 'O regime ${regimeTrabalho.code} permite até ${regimeTrabalho.cargaSemanalLimite}h semanais.';
    }

    if (disciplinas.isEmpty) {
      return 'Adicione pelo menos uma disciplina';
    }

    final cargaDistribuida = calcularCargaHorariaSemanal(horarios);
    if (cargaDistribuida > carga) {
      return 'A distribuição semanal cadastrada (${cargaDistribuida}h) excede a carga máxima do docente (${carga}h).';
    }

    return null;
  }

  static String? validateDisciplina({
    required String disciplina,
    required List<String> disciplinasExistentes,
  }) {
    final normalized = disciplina.trim();
    if (normalized.isEmpty) {
      return 'Informe o nome da disciplina.';
    }

    if (disciplinasExistentes.contains(normalized)) {
      return 'Disciplina já adicionada.';
    }

    return null;
  }

  static String? validateHorario({
    required String inicio,
    required String fim,
    String? diaSemana,
    List<HorarioAula> horariosExistentes = const [],
  }) {
    final normalizedInicio = inicio.trim();
    final normalizedFim = fim.trim();

    if (normalizedInicio.isEmpty || normalizedFim.isEmpty) {
      return 'Informe horário de início e fim.';
    }

    final horarioRegex = RegExp(r'^([01]\d|2[0-3]):[0-5]\d$');
    if (!horarioRegex.hasMatch(normalizedInicio) ||
        !horarioRegex.hasMatch(normalizedFim)) {
      return 'Use o formato HH:MM para os horários.';
    }

    final inicioMinutos = _horarioEmMinutos(normalizedInicio);
    final fimMinutos = _horarioEmMinutos(normalizedFim);
    if (inicioMinutos == null || fimMinutos == null) {
      return 'Use o formato HH:MM para os horários.';
    }

    if (fimMinutos <= inicioMinutos) {
      return 'O horário de fim deve ser posterior ao de início.';
    }

    if (diaSemana != null) {
      for (final horario in horariosExistentes.where(
        (item) => item.diaSemana == diaSemana,
      )) {
        final inicioExistente = _horarioEmMinutos(horario.inicio);
        final fimExistente = _horarioEmMinutos(horario.fim);
        if (inicioExistente == null || fimExistente == null) continue;
        if (inicioMinutos < fimExistente && fimMinutos > inicioExistente) {
          return 'Já existe horário cadastrado em conflito para $diaSemana.';
        }
      }
    }

    return null;
  }

  static Docente createDocente({
    required String id,
    required String nome,
    required String email,
    required String departamento,
    required String cargaMaxima,
    required List<String> disciplinas,
    required RegimeTrabalhoEbtt regimeTrabalho,
    required List<HorarioAula> horarios,
  }) {
    return Docente(
      id: id,
      nome: nome.trim(),
      userId: buildUserIdFromEmail(email),
      userEmail: normalizeEmail(email),
      departamento: departamento.trim(),
      cargaHoraria: calcularCargaHorariaSemanal(horarios),
      cargaMaxima: int.parse(cargaMaxima.trim()),
      disciplinas: List<String>.from(disciplinas),
      regimeTrabalho: regimeTrabalho,
      horariosAula: List<HorarioAula>.from(horarios),
    );
  }

  static Docente updateDocente({
    required Docente docente,
    required String nome,
    required String email,
    required String departamento,
    required String cargaMaxima,
    required List<String> disciplinas,
    required RegimeTrabalhoEbtt regimeTrabalho,
    required List<HorarioAula> horarios,
  }) {
    return docente.copyWith(
      nome: nome.trim(),
      userId: buildUserIdFromEmail(email),
      userEmail: normalizeEmail(email),
      departamento: departamento.trim(),
      cargaHoraria: calcularCargaHorariaSemanal(horarios),
      cargaMaxima: int.parse(cargaMaxima.trim()),
      regimeTrabalho: regimeTrabalho,
      horariosAula: List<HorarioAula>.from(horarios),
      disciplinas: List<String>.from(disciplinas),
    );
  }

  static int calcularCargaHorariaSemanal(List<HorarioAula> horarios) {
    var total = 0;
    for (final horario in horarios) {
      total += _cargaSemanalDoHorario(horario);
    }
    return total;
  }

  static int cargaSemanalDoHorario(HorarioAula horario) {
    return _cargaSemanalDoHorario(horario);
  }

  static int calcularCargaAulasSemanalMinutos(
    List<HorarioAula> horarios, {
    RegrasDistribuicaoCarga regras = const RegrasDistribuicaoCarga.ifma(),
  }) {
    return horarios.fold(
      0,
      (total, horario) =>
          total + _cargaSemanalMinutosDoHorario(horario, regras),
    );
  }

  static int cargaAulasDocenteMinutos(
    Docente docente, {
    RegrasDistribuicaoCarga regras = const RegrasDistribuicaoCarga.ifma(),
  }) {
    if (docente.horariosAula.isNotEmpty) {
      return calcularCargaAulasSemanalMinutos(
        docente.horariosAula,
        regras: regras,
      );
    }
    return docente.cargaHoraria * regras.duracaoHoraAulaMinutos;
  }

  static ResultadoValidacaoPlanoTrabalho validarPlanoTrabalho({
    required Docente docente,
    required PlanoTrabalhoDocente plano,
    RegrasDistribuicaoCarga regras = const RegrasDistribuicaoCarga.ifma(),
  }) {
    final pendencias = <PendenciaPlanoTrabalho>[];

    void adicionar(
      String codigo,
      String mensagem, {
      SeveridadePendenciaPlano severidade = SeveridadePendenciaPlano.bloqueio,
    }) {
      pendencias.add(
        PendenciaPlanoTrabalho(
          codigo: codigo,
          mensagem: mensagem,
          severidade: severidade,
        ),
      );
    }

    if (plano.docenteId != docente.id) {
      adicionar(
        'docente_incompativel',
        'O PIT não pertence ao docente informado.',
      );
    }
    if (plano.periodoLetivo.trim().isEmpty) {
      adicionar('periodo_obrigatorio', 'Informe o período letivo do PIT.');
    }
    if ((plano.avaliadorId ?? '').trim().isEmpty) {
      adicionar(
        'avaliador_obrigatorio',
        'Informe a chefia imediata responsável pela avaliação do PIT.',
      );
    }

    for (final atividade in plano.atividades) {
      if (atividade.descricao.trim().isEmpty) {
        adicionar(
          'descricao_atividade_obrigatoria',
          'Todas as atividades do PIT devem possuir descrição.',
        );
      }
      if (atividade.cargaSemanalMinutos < 0) {
        adicionar(
          'carga_atividade_invalida',
          'A carga semanal de uma atividade não pode ser negativa.',
        );
      }
    }
    for (final indisponibilidade in plano.indisponibilidades) {
      final inicio = _horarioEmMinutos(indisponibilidade.inicio);
      final fim = _horarioEmMinutos(indisponibilidade.fim);
      if (indisponibilidade.diaSemana.trim().isEmpty ||
          inicio == null ||
          fim == null ||
          fim <= inicio) {
        adicionar(
          'indisponibilidade_invalida',
          'Revise os dias e horários informados nas indisponibilidades.',
        );
      }
    }

    final cargaAulasMinutos = cargaAulasDocenteMinutos(docente, regras: regras);
    final limitesAulas = regras.limitesAulasPara(docente.regimeTrabalho);
    final cargaMinimaAulasMinutos = limitesAulas.minima * 60;
    final cargaMaximaAulasMinutos = limitesAulas.maxima * 60;
    final aulasForaDosLimites =
        cargaAulasMinutos < cargaMinimaAulasMinutos ||
        cargaAulasMinutos > cargaMaximaAulasMinutos;
    final justificativaCargaAulas = plano.justificativaCargaAulas?.trim() ?? '';
    if (aulasForaDosLimites && justificativaCargaAulas.isEmpty) {
      adicionar(
        'justificativa_carga_aulas_obrigatoria',
        'A carga semanal de aulas está fora dos limites do IFMA e exige justificativa.',
      );
    } else if (aulasForaDosLimites) {
      adicionar(
        'carga_aulas_excepcional',
        'A carga semanal de aulas está fora da faixa de referência e será submetida com justificativa.',
        severidade: SeveridadePendenciaPlano.aviso,
      );
    }

    if (plano.cargaOutrasAtividadesEnsinoMinutos > cargaAulasMinutos) {
      adicionar(
        'outras_atividades_ensino_excedidas',
        'As demais atividades de ensino não podem superar a carga semanal total de aulas.',
      );
    }

    final cargaReunioes = plano.cargaMinutosPorTipo(
      TipoAtividadePlanoDocente.reunioesPedagogicas,
    );
    if (cargaReunioes > regras.cargaMaximaReunioesPedagogicasMinutos) {
      adicionar(
        'reunioes_pedagogicas_excedidas',
        'Reuniões pedagógicas, de grupo e afins estão limitadas a 4 horas semanais.',
      );
    }

    final limitePesquisaExtensaoGestao = regras
        .cargaMaximaPesquisaExtensaoGestaoMinutosPara(docente.regimeTrabalho);
    final outrasAtividadesExcedidas =
        plano.cargaPesquisaExtensaoGestaoMinutos > limitePesquisaExtensaoGestao;
    final justificativaOutrasAtividades =
        plano.justificativaExtrapolacaoOutrasAtividades?.trim() ?? '';
    if (outrasAtividadesExcedidas && justificativaOutrasAtividades.isEmpty) {
      adicionar(
        'justificativa_outras_atividades_obrigatoria',
        'A carga de pesquisa, extensão, gestão e representação excede a referência e exige justificativa.',
      );
    } else if (outrasAtividadesExcedidas) {
      adicionar(
        'outras_atividades_excepcionais',
        'A carga de pesquisa, extensão, gestão e representação será submetida como exceção justificada.',
        severidade: SeveridadePendenciaPlano.aviso,
      );
    }

    final cargaTotalMinutos = cargaAulasMinutos + plano.cargaAtividadesMinutos;
    final cargaRegimeMinutos = docente.regimeTrabalho.cargaSemanalLimite * 60;
    if (cargaTotalMinutos < cargaRegimeMinutos) {
      adicionar(
        'carga_total_insuficiente',
        'A carga total do PIT deve completar ao menos ${docente.regimeTrabalho.cargaSemanalLimite} horas semanais.',
      );
    }

    return ResultadoValidacaoPlanoTrabalho(pendencias: pendencias);
  }

  static bool existeConflitoHorario({
    required List<HorarioAula> horarios,
    required HorarioAula candidato,
  }) {
    final inicioCandidato = _horarioEmMinutos(candidato.inicio);
    final fimCandidato = _horarioEmMinutos(candidato.fim);
    if (inicioCandidato == null || fimCandidato == null) return false;

    for (final horario in horarios.where(
      (item) => item.diaSemana == candidato.diaSemana,
    )) {
      final inicioExistente = _horarioEmMinutos(horario.inicio);
      final fimExistente = _horarioEmMinutos(horario.fim);
      if (inicioExistente == null || fimExistente == null) continue;
      if (inicioCandidato < fimExistente && fimCandidato > inicioExistente) {
        return true;
      }
    }

    return false;
  }

  static bool existeConflitoIndisponibilidade({
    required List<IndisponibilidadeDocente> indisponibilidades,
    required HorarioAula candidato,
  }) {
    final inicioCandidato = _horarioEmMinutos(candidato.inicio);
    final fimCandidato = _horarioEmMinutos(candidato.fim);
    if (inicioCandidato == null || fimCandidato == null) return false;

    for (final item in indisponibilidades.where(
      (restricao) => restricao.diaSemana == candidato.diaSemana,
    )) {
      final inicio = _horarioEmMinutos(item.inicio);
      final fim = _horarioEmMinutos(item.fim);
      if (inicio == null || fim == null) continue;
      if (inicioCandidato < fim && fimCandidato > inicio) return true;
    }
    return false;
  }

  static ResultadoSimulacaoRedistribuicao simularRedistribuicaoDocentes(
    List<Docente> docentes, {
    double limiarAlta = 0.9,
    double limiarBaixa = 0.5,
    int limitePropostas = 6,
    RegrasDistribuicaoCarga? regrasLegais,
    Map<String, PlanoTrabalhoDocente> planosAprovados = const {},
    AvaliadorAfinidadeRedistribuicao? avaliarAfinidade,
  }) {
    if (docentes.isEmpty || limitePropostas <= 0) {
      return const ResultadoSimulacaoRedistribuicao(
        propostas: [],
        mediaOcupacaoAntes: 0,
        mediaOcupacaoDepois: 0,
      );
    }

    final regras = regrasLegais ?? const RegrasDistribuicaoCarga.ifma();
    final ocupacaoAntes = _mediaOcupacaoEnsino(docentes, regras);
    final propostas = <PropostaRedistribuicao>[];
    final cargasProjetadas = {
      for (final docente in docentes)
        docente.id: _cargaAulasAtuaisMinutos(docente, regras),
    };
    final horariosProjetados = {
      for (final docente in docentes)
        docente.id: List<HorarioAula>.from(docente.horariosAula),
    };

    final docentesAlta = docentes
        .where((docente) {
          final cargaAtual = _cargaAulasAtuaisMinutos(docente, regras);
          final limiteEnsino = _cargaMaximaAulasMinutos(docente, regras);
          return _ocupacao(cargaAtual, limiteEnsino) >= limiarAlta ||
              cargaAtual > limiteEnsino;
        })
        .toList(growable: false);

    final docentesBaixa = docentes
        .where((docente) {
          final cargaAtual = _cargaAulasAtuaisMinutos(docente, regras);
          final cargaMinima = _cargaMinimaAulasMinutos(docente, regras);
          final cargaMaxima = _cargaMaximaAulasMinutos(docente, regras);
          return _ocupacao(cargaAtual, cargaMaxima) <= limiarBaixa ||
              cargaAtual < cargaMinima;
        })
        .toList(growable: false);

    for (final origem in docentesAlta) {
      for (final horario in origem.horariosAula) {
        if (propostas.length >= limitePropostas) break;
        if ((horario.disciplina ?? '').trim().isEmpty) continue;

        final cargaHorario = _cargaSemanalDoHorario(horario);
        if (cargaHorario <= 0) continue;
        final cargaHorarioMinutos = _cargaSemanalMinutosDoHorario(
          horario,
          regras,
        );
        if (cargaHorarioMinutos <= 0) continue;

        Docente? melhorDestino;
        double melhorPontuacao = -1;
        List<String> melhoresJustificativas = const [];

        for (final destino in docentesBaixa) {
          if (destino.id == origem.id) continue;
          if (!destino.disciplinas.contains(horario.disciplina)) continue;
          if (existeConflitoHorario(
            horarios: horariosProjetados[destino.id] ?? destino.horariosAula,
            candidato: horario,
          )) {
            continue;
          }

          final planoDestino = planosAprovados[destino.id];
          if (planoDestino?.status == StatusPlanoTrabalhoDocente.aprovado &&
              existeConflitoIndisponibilidade(
                indisponibilidades: planoDestino!.indisponibilidades,
                candidato: horario,
              )) {
            continue;
          }

          final cargaDestinoProjetada =
              (cargasProjetadas[destino.id] ??
                  _cargaAulasAtuaisMinutos(destino, regras)) +
              cargaHorarioMinutos;
          final cargaOrigemProjetada =
              (cargasProjetadas[origem.id] ??
                  _cargaAulasAtuaisMinutos(origem, regras)) -
              cargaHorarioMinutos;
          final cargaMinimaOrigem = _cargaMinimaAulasMinutos(origem, regras);
          final cargaMaximaEnsinoDestino = _cargaMaximaAulasMinutos(
            destino,
            regras,
          );
          if (cargaDestinoProjetada > cargaMaximaEnsinoDestino) continue;
          if (cargaOrigemProjetada < cargaMinimaOrigem) continue;

          final ocupacaoProjetada = _ocupacao(
            cargaDestinoProjetada,
            cargaMaximaEnsinoDestino,
          );
          final equilibrio = (1 - (ocupacaoProjetada - 0.7).abs()).clamp(
            0.0,
            1.0,
          );
          final afinidade =
              avaliarAfinidade?.call(destino, horario) ??
              const AvaliacaoAfinidadeRedistribuicao(
                pontuacao: 0.5,
                explicacao: 'Afinidade histórica neutra.',
              );
          final pontuacao =
              ((equilibrio * 0.75) +
                  (afinidade.pontuacao.clamp(0.0, 1.0) * 0.25)) *
              100;

          if (pontuacao > melhorPontuacao) {
            melhorDestino = destino;
            melhorPontuacao = pontuacao;
            melhoresJustificativas = [
              'Compatível com a disciplina e sem conflito de horário.',
              'Carga projetada dentro dos limites do regime ${destino.regimeTrabalho.label}.',
              afinidade.explicacao,
              if (planoDestino?.status == StatusPlanoTrabalhoDocente.aprovado)
                'Indisponibilidades do PIT aprovado respeitadas.'
              else
                'PIT deverá ser criado ou atualizado antes da efetivação.',
            ];
          }
        }

        if (melhorDestino != null) {
          final destino = melhorDestino;
          cargasProjetadas[destino.id] =
              (cargasProjetadas[destino.id] ??
                  _cargaAulasAtuaisMinutos(destino, regras)) +
              cargaHorarioMinutos;
          cargasProjetadas[origem.id] =
              (cargasProjetadas[origem.id] ??
                  _cargaAulasAtuaisMinutos(origem, regras)) -
              cargaHorarioMinutos;
          horariosProjetados[destino.id]?.add(horario);

          propostas.add(
            PropostaRedistribuicao(
              docenteOrigemId: origem.id,
              docenteOrigemNome: origem.nome,
              docenteDestinoId: destino.id,
              docenteDestinoNome: destino.nome,
              horario: horario,
              cargaSemanal: cargaHorario,
              pontuacao: melhorPontuacao,
              justificativas: melhoresJustificativas,
              requerAtualizacaoPit: true,
            ),
          );
        }
      }
      if (propostas.length >= limitePropostas) break;
    }

    final ocupacaoDepois = _mediaOcupacaoEnsinoProjetada(
      docentes,
      cargasProjetadas,
      regras,
    );

    return ResultadoSimulacaoRedistribuicao(
      propostas: propostas,
      mediaOcupacaoAntes: ocupacaoAntes,
      mediaOcupacaoDepois: ocupacaoDepois,
    );
  }

  static HorarioAula createHorario({
    required String diaSemana,
    required String inicio,
    required String fim,
    required String modalidade,
    String? disciplina,
    String? cargaHoraria,
    String? turma,
  }) {
    return HorarioAula(
      diaSemana: diaSemana,
      inicio: inicio.trim(),
      fim: fim.trim(),
      disciplina: _normalizeNullable(disciplina),
      cargaHoraria: _normalizeNullable(cargaHoraria),
      turma: _normalizeNullable(turma),
      modalidade: _normalizeNullable(modalidade),
    );
  }

  static String? buildUserIdFromEmail(String? email) {
    final normalized = normalizeEmail(email);
    if (normalized == null) return null;
    return 'user_email_$normalized';
  }

  static String? normalizeEmail(String? email) {
    final normalized = email?.trim().toLowerCase();
    if (normalized == null || normalized.isEmpty) return null;
    return normalized;
  }

  static int _cargaSemanalDoHorario(HorarioAula horario) {
    final cargaDeclarada = _parseCargaHorariaSemanal(horario.cargaHoraria);
    if (cargaDeclarada != null && cargaDeclarada > 0) {
      return cargaDeclarada;
    }

    final inicio = _horarioEmMinutos(horario.inicio);
    final fim = _horarioEmMinutos(horario.fim);
    if (inicio == null || fim == null || fim <= inicio) {
      return 0;
    }

    final duracao = fim - inicio;
    final blocos = (duracao / 50).round();
    return blocos < 1 ? 1 : blocos;
  }

  static int _cargaSemanalMinutosDoHorario(
    HorarioAula horario,
    RegrasDistribuicaoCarga regras,
  ) {
    final cargaDeclarada = _parseCargaHorariaSemanal(horario.cargaHoraria);
    if (cargaDeclarada != null && cargaDeclarada > 0) {
      return cargaDeclarada * regras.duracaoHoraAulaMinutos;
    }

    final inicio = _horarioEmMinutos(horario.inicio);
    final fim = _horarioEmMinutos(horario.fim);
    if (inicio == null || fim == null || fim <= inicio) {
      return 0;
    }
    return fim - inicio;
  }

  static int? _parseCargaHorariaSemanal(String? cargaHoraria) {
    final raw = cargaHoraria?.trim();
    if (raw == null || raw.isEmpty) return null;

    final match = RegExp(
      r'(\d+)\s*h\s*/\s*sem',
      caseSensitive: false,
    ).firstMatch(raw);
    if (match == null) return null;
    return int.tryParse(match.group(1)!);
  }

  static int? _horarioEmMinutos(String horario) {
    final partes = horario.split(':');
    if (partes.length != 2) return null;
    final hora = int.tryParse(partes[0]);
    final minuto = int.tryParse(partes[1]);
    if (hora == null || minuto == null) return null;
    return (hora * 60) + minuto;
  }

  static double _ocupacao(int cargaHoraria, int cargaMaxima) {
    if (cargaMaxima <= 0) return 0;
    return cargaHoraria / cargaMaxima;
  }

  static double _mediaOcupacaoEnsino(
    List<Docente> docentes,
    RegrasDistribuicaoCarga regras,
  ) {
    if (docentes.isEmpty) return 0;
    final soma = docentes
        .map(
          (docente) => _ocupacao(
            _cargaAulasAtuaisMinutos(docente, regras),
            _cargaMaximaAulasMinutos(docente, regras),
          ),
        )
        .reduce((a, b) => a + b);
    return soma / docentes.length;
  }

  static double _mediaOcupacaoEnsinoProjetada(
    List<Docente> docentes,
    Map<String, int> cargasProjetadas,
    RegrasDistribuicaoCarga regras,
  ) {
    if (docentes.isEmpty) return 0;
    final soma = docentes
        .map(
          (docente) => _ocupacao(
            cargasProjetadas[docente.id] ??
                _cargaAulasAtuaisMinutos(docente, regras),
            _cargaMaximaAulasMinutos(docente, regras),
          ),
        )
        .reduce((a, b) => a + b);
    return soma / docentes.length;
  }

  static int _cargaAulasAtuaisMinutos(
    Docente docente,
    RegrasDistribuicaoCarga regras,
  ) {
    return math.max(0, docente.cargaHoraria) * regras.duracaoHoraAulaMinutos;
  }

  static int _cargaMinimaAulasMinutos(
    Docente docente,
    RegrasDistribuicaoCarga regras,
  ) {
    final limites = regras.limitesAulasPara(docente.regimeTrabalho);
    final limiteRegime = math.min(docente.cargaMaxima, limites.minima);
    return math.max(0, limiteRegime) * 60;
  }

  static int _cargaMaximaAulasMinutos(
    Docente docente,
    RegrasDistribuicaoCarga regras,
  ) {
    final limites = regras.limitesAulasPara(docente.regimeTrabalho);
    final limiteRegime = math.min(docente.cargaMaxima, limites.maxima);
    return math.max(0, limiteRegime) * 60;
  }

  static String? _normalizeNullable(String? value) {
    final normalized = value?.trim();
    if (normalized == null || normalized.isEmpty) return null;
    return normalized;
  }
}
