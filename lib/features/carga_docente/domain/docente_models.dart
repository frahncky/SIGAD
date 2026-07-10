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
