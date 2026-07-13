class ReferenciaDocenteIfma {
  const ReferenciaDocenteIfma({required this.nome, required this.areas});

  final String nome;
  final List<String> areas;
}

/// Catálogo inicial transcrito da aba "Oficial" da Comissão de Horários
/// 2026.2. Ele apenas auxilia o preenchimento feito pela chefia; não cadastra
/// docentes nem importa arquivos automaticamente.
abstract final class CatalogoDocentesIfma {
  static const eletronica = 'Eletrônica';
  static const microcontroladores = 'Microcontroladores e Eletrônica Digital';
  static const eletricidade = 'Eletricidade e Análise CC e CA';
  static const maquinas = 'Máquinas e Instalações Elétricas';
  static const automacao = 'Automação, Robótica e CLP';
  static const telecomunicacoes = 'Telecomunicações';
  static const sistemasEnergia = 'Sistemas de Energia';

  static const docentes = <ReferenciaDocenteIfma>[
    ReferenciaDocenteIfma(
      nome: 'Ernesto de Lucena Chagas',
      areas: [eletronica],
    ),
    ReferenciaDocenteIfma(
      nome: 'Bruno Valério Everton Costa',
      areas: [eletronica, telecomunicacoes],
    ),
    ReferenciaDocenteIfma(
      nome: 'Evandro de Carvalho Gomes',
      areas: [eletronica, microcontroladores],
    ),
    ReferenciaDocenteIfma(
      nome: 'Ismael Silva de Melo',
      areas: [eletronica, automacao],
    ),
    ReferenciaDocenteIfma(
      nome: 'Priscila Lima Rocha',
      areas: [eletronica, microcontroladores],
    ),
    ReferenciaDocenteIfma(
      nome: 'Jean Mark Correa Santos',
      areas: [eletronica, microcontroladores],
    ),
    ReferenciaDocenteIfma(nome: 'José Lima', areas: [eletronica]),
    ReferenciaDocenteIfma(
      nome: 'Almir Souza e Silva Neto',
      areas: [microcontroladores, automacao, telecomunicacoes],
    ),
    ReferenciaDocenteIfma(
      nome: 'Washington Luis Santos Silva',
      areas: [microcontroladores],
    ),
    ReferenciaDocenteIfma(
      nome: 'Brenno Beserra Coelho',
      areas: [eletricidade, maquinas],
    ),
    ReferenciaDocenteIfma(nome: 'Danubia Soares Pires', areas: [eletricidade]),
    ReferenciaDocenteIfma(
      nome: 'Walter da Silva Castro',
      areas: [eletricidade, telecomunicacoes],
    ),
    ReferenciaDocenteIfma(
      nome: 'Elton Amorim Chagas',
      areas: [eletricidade, sistemasEnergia],
    ),
    ReferenciaDocenteIfma(
      nome: 'Francisco dos Santos Viana',
      areas: [eletricidade, maquinas, sistemasEnergia],
    ),
    ReferenciaDocenteIfma(
      nome: 'Arnaldo Pinheiro de Azevedo',
      areas: [eletricidade, automacao],
    ),
    ReferenciaDocenteIfma(nome: 'Pericles de Sousa Furtado', areas: [maquinas]),
    ReferenciaDocenteIfma(
      nome: 'Raimundo Nonato dos Santos',
      areas: [maquinas],
    ),
    ReferenciaDocenteIfma(nome: 'Wagner Vilar Veiga', areas: [maquinas]),
    ReferenciaDocenteIfma(
      nome: 'Airton Augusto dos Anjos Costa',
      areas: [maquinas],
    ),
    ReferenciaDocenteIfma(nome: 'Pericles Augusto Mendes', areas: [maquinas]),
    ReferenciaDocenteIfma(
      nome: 'André Luis Gomes de Sousa',
      areas: [automacao],
    ),
    ReferenciaDocenteIfma(
      nome: 'Edson Bruno Marques Costa',
      areas: [automacao],
    ),
  ];

  static Iterable<ReferenciaDocenteIfma> buscar(String consulta) {
    final termo = normalizar(consulta);
    if (termo.isEmpty) return docentes;
    return docentes.where(
      (docente) =>
          normalizar(docente.nome).contains(termo) ||
          docente.areas.any((area) => normalizar(area).contains(termo)),
    );
  }

  static String normalizar(String valor) {
    return valor
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[áàãâä]'), 'a')
        .replaceAll(RegExp(r'[éèêë]'), 'e')
        .replaceAll(RegExp(r'[íìîï]'), 'i')
        .replaceAll(RegExp(r'[óòõôö]'), 'o')
        .replaceAll(RegExp(r'[úùûü]'), 'u')
        .replaceAll('ç', 'c')
        .replaceAll(RegExp(r'\s+'), ' ');
  }
}
