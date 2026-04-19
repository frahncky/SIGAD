import 'docente_models.dart';

abstract final class DocenteFormService {
  static String? validateDocente({
    required String nome,
    required String departamento,
    required String cargaMaxima,
    required List<String> disciplinas,
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

    if (disciplinas.isEmpty) {
      return 'Adicione pelo menos uma disciplina';
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

    return null;
  }

  static Docente createDocente({
    required String id,
    required String nome,
    required String email,
    required String departamento,
    required String cargaMaxima,
    required List<String> disciplinas,
    required List<HorarioAula> horarios,
  }) {
    return Docente(
      id: id,
      nome: nome.trim(),
      userId: buildUserIdFromEmail(email),
      userEmail: normalizeEmail(email),
      departamento: departamento.trim(),
      cargaHoraria: horarios.length * 2,
      cargaMaxima: int.parse(cargaMaxima.trim()),
      disciplinas: List<String>.from(disciplinas),
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
    required List<HorarioAula> horarios,
  }) {
    return docente.copyWith(
      nome: nome.trim(),
      userId: buildUserIdFromEmail(email),
      userEmail: normalizeEmail(email),
      departamento: departamento.trim(),
      cargaHoraria: horarios.length * 2,
      cargaMaxima: int.parse(cargaMaxima.trim()),
      horariosAula: List<HorarioAula>.from(horarios),
      disciplinas: List<String>.from(disciplinas),
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

  static String? _normalizeNullable(String? value) {
    final normalized = value?.trim();
    if (normalized == null || normalized.isEmpty) return null;
    return normalized;
  }
}
