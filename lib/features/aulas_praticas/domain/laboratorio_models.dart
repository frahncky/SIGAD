enum StatusLaboratorio { operando, manutencao, interditado }

enum StatusEquipamento { disponivel, emUso, manutencao, indisponivel }

class EquipamentoLaboratorio {
  const EquipamentoLaboratorio({
    required this.id,
    required this.nome,
    required this.quantidade,
    required this.status,
  });

  final String id;
  final String nome;
  final int quantidade;
  final StatusEquipamento status;

  Map<String, dynamic> toJson() => {
    'id': id,
    'nome': nome,
    'quantidade': quantidade,
    'status': status.name,
  };

  factory EquipamentoLaboratorio.fromJson(Map<String, dynamic> json) =>
      EquipamentoLaboratorio(
        id: json['id'] as String,
        nome: json['nome'] as String,
        quantidade: json['quantidade'] as int,
        status: StatusEquipamento.values.byName(json['status'] as String),
      );
}

class OcorrenciaLaboratorio {
  const OcorrenciaLaboratorio({
    required this.id,
    required this.titulo,
    required this.descricao,
    required this.criadaEm,
    this.resolvida = false,
  });

  final String id;
  final String titulo;
  final String descricao;
  final DateTime criadaEm;
  final bool resolvida;

  Map<String, dynamic> toJson() => {
    'id': id,
    'titulo': titulo,
    'descricao': descricao,
    'criadaEm': criadaEm.toIso8601String(),
    'resolvida': resolvida,
  };

  factory OcorrenciaLaboratorio.fromJson(Map<String, dynamic> json) =>
      OcorrenciaLaboratorio(
        id: json['id'] as String,
        titulo: json['titulo'] as String,
        descricao: json['descricao'] as String,
        criadaEm: DateTime.parse(json['criadaEm'] as String),
        resolvida: json['resolvida'] as bool? ?? false,
      );
}

class ManutencaoLaboratorio {
  const ManutencaoLaboratorio({
    required this.id,
    required this.descricao,
    required this.inicio,
    this.previsaoFim,
    this.concluida = false,
  });

  final String id;
  final String descricao;
  final DateTime inicio;
  final DateTime? previsaoFim;
  final bool concluida;

  Map<String, dynamic> toJson() => {
    'id': id,
    'descricao': descricao,
    'inicio': inicio.toIso8601String(),
    if (previsaoFim != null) 'previsaoFim': previsaoFim!.toIso8601String(),
    'concluida': concluida,
  };

  factory ManutencaoLaboratorio.fromJson(Map<String, dynamic> json) =>
      ManutencaoLaboratorio(
        id: json['id'] as String,
        descricao: json['descricao'] as String,
        inicio: DateTime.parse(json['inicio'] as String),
        previsaoFim: json['previsaoFim'] == null
            ? null
            : DateTime.parse(json['previsaoFim'] as String),
        concluida: json['concluida'] as bool? ?? false,
      );
}

class Laboratorio {
  const Laboratorio({
    required this.id,
    required this.nome,
    required this.localizacao,
    required this.capacidade,
    required this.responsavelTecnico,
    required this.status,
    required this.equipamentos,
    this.ocorrencias = const [],
    this.manutencoes = const [],
  });

  final String id;
  final String nome;
  final String localizacao;
  final int capacidade;
  final String responsavelTecnico;
  final StatusLaboratorio status;
  final List<EquipamentoLaboratorio> equipamentos;
  final List<OcorrenciaLaboratorio> ocorrencias;
  final List<ManutencaoLaboratorio> manutencoes;

  int get equipamentosDisponiveis => equipamentos
      .where((item) => item.status == StatusEquipamento.disponivel)
      .fold(0, (total, item) => total + item.quantidade);

  int get ocorrenciasAtivas =>
      ocorrencias.where((item) => !item.resolvida).length;

  Laboratorio copyWith({
    StatusLaboratorio? status,
    List<EquipamentoLaboratorio>? equipamentos,
    List<OcorrenciaLaboratorio>? ocorrencias,
    List<ManutencaoLaboratorio>? manutencoes,
  }) => Laboratorio(
    id: id,
    nome: nome,
    localizacao: localizacao,
    capacidade: capacidade,
    responsavelTecnico: responsavelTecnico,
    status: status ?? this.status,
    equipamentos: equipamentos ?? this.equipamentos,
    ocorrencias: ocorrencias ?? this.ocorrencias,
    manutencoes: manutencoes ?? this.manutencoes,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'nome': nome,
    'localizacao': localizacao,
    'capacidade': capacidade,
    'responsavelTecnico': responsavelTecnico,
    'status': status.name,
    'equipamentos': equipamentos.map((item) => item.toJson()).toList(),
    'ocorrencias': ocorrencias.map((item) => item.toJson()).toList(),
    'manutencoes': manutencoes.map((item) => item.toJson()).toList(),
  };

  factory Laboratorio.fromJson(Map<String, dynamic> json) => Laboratorio(
    id: json['id'] as String,
    nome: json['nome'] as String,
    localizacao: json['localizacao'] as String,
    capacidade: json['capacidade'] as int,
    responsavelTecnico: json['responsavelTecnico'] as String,
    status: StatusLaboratorio.values.byName(json['status'] as String),
    equipamentos: (json['equipamentos'] as List<dynamic>? ?? const [])
        .map(
          (item) =>
              EquipamentoLaboratorio.fromJson(item as Map<String, dynamic>),
        )
        .toList(),
    ocorrencias: (json['ocorrencias'] as List<dynamic>? ?? const [])
        .map(
          (item) =>
              OcorrenciaLaboratorio.fromJson(item as Map<String, dynamic>),
        )
        .toList(),
    manutencoes: (json['manutencoes'] as List<dynamic>? ?? const [])
        .map(
          (item) =>
              ManutencaoLaboratorio.fromJson(item as Map<String, dynamic>),
        )
        .toList(),
  );
}
