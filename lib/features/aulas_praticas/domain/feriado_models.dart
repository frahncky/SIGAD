enum AbrangenciaFeriado {
  nacional('Nacional'),
  estadual('Estadual — Maranhão'),
  municipal('Municipal — São Luís');

  const AbrangenciaFeriado(this.label);

  final String label;
}

class Feriado {
  const Feriado({
    required this.data,
    required this.nome,
    required this.abrangencia,
  });

  final DateTime data;
  final String nome;
  final AbrangenciaFeriado abrangencia;

  String get descricao => '$nome — ${abrangencia.label}';
}
