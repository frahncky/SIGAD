import 'docente_models.dart';

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
      for (final horario in horariosExistentes.where((item) => item.diaSemana == diaSemana)) {
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

  static bool existeConflitoHorario({
    required List<HorarioAula> horarios,
    required HorarioAula candidato,
  }) {
    final inicioCandidato = _horarioEmMinutos(candidato.inicio);
    final fimCandidato = _horarioEmMinutos(candidato.fim);
    if (inicioCandidato == null || fimCandidato == null) return false;

    for (final horario in horarios.where((item) => item.diaSemana == candidato.diaSemana)) {
      final inicioExistente = _horarioEmMinutos(horario.inicio);
      final fimExistente = _horarioEmMinutos(horario.fim);
      if (inicioExistente == null || fimExistente == null) continue;
      if (inicioCandidato < fimExistente && fimCandidato > inicioExistente) {
        return true;
      }
    }

    return false;
  }

  static ResultadoSimulacaoRedistribuicao simularRedistribuicaoDocentes(
    List<Docente> docentes, {
    double limiarAlta = 0.9,
    double limiarBaixa = 0.5,
    int limitePropostas = 6,
  }) {
    if (docentes.isEmpty || limitePropostas <= 0) {
      return const ResultadoSimulacaoRedistribuicao(
        propostas: [],
        mediaOcupacaoAntes: 0,
        mediaOcupacaoDepois: 0,
      );
    }

    final ocupacaoAntes = _mediaOcupacao(docentes);
    final propostas = <PropostaRedistribuicao>[];
    final cargasProjetadas = {
      for (final docente in docentes) docente.id: docente.cargaHoraria,
    };

    final docentesAlta = docentes.where((docente) {
      return _ocupacao(docente.cargaHoraria, docente.cargaMaxima) >= limiarAlta;
    }).toList(growable: false);

    final docentesBaixa = docentes.where((docente) {
      return _ocupacao(docente.cargaHoraria, docente.cargaMaxima) <= limiarBaixa;
    }).toList(growable: false);

    for (final origem in docentesAlta) {
      for (final horario in origem.horariosAula) {
        if (propostas.length >= limitePropostas) break;
        if ((horario.disciplina ?? '').trim().isEmpty) continue;

        final cargaHorario = _cargaSemanalDoHorario(horario);
        if (cargaHorario <= 0) continue;

        for (final destino in docentesBaixa) {
          if (destino.id == origem.id) continue;
          if (!destino.disciplinas.contains(horario.disciplina)) continue;
          if (existeConflitoHorario(horarios: destino.horariosAula, candidato: horario)) continue;

          final cargaDestinoProjetada = (cargasProjetadas[destino.id] ?? destino.cargaHoraria) + cargaHorario;
          final cargaOrigemProjetada = (cargasProjetadas[origem.id] ?? origem.cargaHoraria) - cargaHorario;
          if (cargaDestinoProjetada > destino.cargaMaxima) continue;
          if (cargaOrigemProjetada < 0) continue;

          cargasProjetadas[destino.id] = cargaDestinoProjetada;
          cargasProjetadas[origem.id] = cargaOrigemProjetada;

          propostas.add(
            PropostaRedistribuicao(
              docenteOrigemId: origem.id,
              docenteOrigemNome: origem.nome,
              docenteDestinoId: destino.id,
              docenteDestinoNome: destino.nome,
              horario: horario,
              cargaSemanal: cargaHorario,
            ),
          );
          break;
        }
      }
      if (propostas.length >= limitePropostas) break;
    }

    final ocupacaoDepois = _mediaOcupacaoProjetada(docentes, cargasProjetadas);

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

  static int? _parseCargaHorariaSemanal(String? cargaHoraria) {
    final raw = cargaHoraria?.trim();
    if (raw == null || raw.isEmpty) return null;

    final match = RegExp(r'(\d+)\s*h\s*/\s*sem', caseSensitive: false).firstMatch(raw);
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

  static double _mediaOcupacao(List<Docente> docentes) {
    if (docentes.isEmpty) return 0;
    final soma = docentes
        .map((docente) => _ocupacao(docente.cargaHoraria, docente.cargaMaxima))
        .reduce((a, b) => a + b);
    return soma / docentes.length;
  }

  static double _mediaOcupacaoProjetada(
    List<Docente> docentes,
    Map<String, int> cargasProjetadas,
  ) {
    if (docentes.isEmpty) return 0;
    final soma = docentes
        .map((docente) => _ocupacao(cargasProjetadas[docente.id] ?? docente.cargaHoraria, docente.cargaMaxima))
        .reduce((a, b) => a + b);
    return soma / docentes.length;
  }

  static String? _normalizeNullable(String? value) {
    final normalized = value?.trim();
    if (normalized == null || normalized.isEmpty) return null;
    return normalized;
  }
}
