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
  final List<HorarioAula> horariosAula;

  Docente copyWith({
    String? nome,
    String? userId,
    String? userEmail,
    String? departamento,
    int? cargaHoraria,
    int? cargaMaxima,
    List<String>? disciplinas,
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
