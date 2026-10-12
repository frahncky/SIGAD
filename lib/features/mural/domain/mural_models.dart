import '../../../core/models/user_role.dart';

/// Modelo visual e semântico de um aviso do mural.
enum ModeloAviso {
  informativo('Informativo'),
  importante('Importante'),
  evento('Evento'),
  lembrete('Lembrete');

  const ModeloAviso(this.rotulo);

  final String rotulo;

  static ModeloAviso porNome(Object? nome) => ModeloAviso.values.firstWhere(
    (modelo) => modelo.name == nome,
    orElse: () => ModeloAviso.informativo,
  );
}

/// Aviso cadastrado pela chefia e exibido no card do topo do painel.
class Aviso {
  const Aviso({
    required this.id,
    required this.modelo,
    required this.titulo,
    required this.conteudo,
    required this.criadoEm,
    this.publico = const {},
    this.inicio,
    this.fim,
    this.fixado = false,
    this.ativo = true,
  });

  final String id;
  final ModeloAviso modelo;
  final String titulo;
  final String conteudo;
  final DateTime criadoEm;

  /// Perfis que veem o aviso. Vazio significa todos os perfis.
  final Set<UserRole> publico;

  /// Primeiro dia em que o aviso aparece (inclusive). Nulo: imediato.
  final DateTime? inicio;

  /// Último dia em que o aviso aparece (inclusive). Nulo: sem prazo.
  final DateTime? fim;

  /// Avisos fixados aparecem antes dos demais.
  final bool fixado;
  final bool ativo;

  bool visivelPara(UserRole? perfil, DateTime agora) {
    if (!ativo) return false;
    if (perfil == null) return false;
    if (publico.isNotEmpty && !publico.contains(perfil)) return false;
    final hoje = _dia(agora);
    final inicio = this.inicio;
    if (inicio != null && hoje.isBefore(_dia(inicio))) {
      return false;
    }
    final fim = this.fim;
    if (fim != null && hoje.isAfter(_dia(fim))) return false;
    return true;
  }

  Aviso copyWith({
    ModeloAviso? modelo,
    String? titulo,
    String? conteudo,
    Set<UserRole>? publico,
    DateTime? Function()? inicio,
    DateTime? Function()? fim,
    bool? fixado,
    bool? ativo,
  }) => Aviso(
    id: id,
    criadoEm: criadoEm,
    modelo: modelo ?? this.modelo,
    titulo: titulo ?? this.titulo,
    conteudo: conteudo ?? this.conteudo,
    publico: publico ?? this.publico,
    inicio: inicio == null ? this.inicio : inicio(),
    fim: fim == null ? this.fim : fim(),
    fixado: fixado ?? this.fixado,
    ativo: ativo ?? this.ativo,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'modelo': modelo.name,
    'titulo': titulo,
    'conteudo': conteudo,
    'criadoEm': criadoEm.toIso8601String(),
    'publico': [for (final perfil in publico) perfil.name],
    'inicio': inicio?.toIso8601String(),
    'fim': fim?.toIso8601String(),
    'fixado': fixado,
    'ativo': ativo,
  };

  factory Aviso.fromJson(Map<String, dynamic> json) => Aviso(
    id: json['id'] as String,
    modelo: ModeloAviso.porNome(json['modelo']),
    titulo: json['titulo'] as String? ?? '',
    conteudo: json['conteudo'] as String? ?? '',
    criadoEm:
        DateTime.tryParse(json['criadoEm'] as String? ?? '') ??
        DateTime.fromMillisecondsSinceEpoch(0),
    publico: {
      for (final nome in (json['publico'] as List<dynamic>? ?? const []))
        for (final perfil in UserRole.values)
          if (perfil.name == nome) perfil,
    },
    inicio: DateTime.tryParse(json['inicio'] as String? ?? ''),
    fim: DateTime.tryParse(json['fim'] as String? ?? ''),
    fixado: json['fixado'] as bool? ?? false,
    ativo: json['ativo'] as bool? ?? true,
  );
}

/// Frase motivacional exibida no card de boas-vindas.
class FraseMotivacional {
  const FraseMotivacional({
    required this.id,
    required this.texto,
    this.ativa = true,
  });

  final String id;
  final String texto;
  final bool ativa;

  FraseMotivacional copyWith({String? texto, bool? ativa}) => FraseMotivacional(
    id: id,
    texto: texto ?? this.texto,
    ativa: ativa ?? this.ativa,
  );

  Map<String, dynamic> toJson() => {'id': id, 'texto': texto, 'ativa': ativa};

  factory FraseMotivacional.fromJson(Map<String, dynamic> json) =>
      FraseMotivacional(
        id: json['id'] as String,
        texto: json['texto'] as String? ?? '',
        ativa: json['ativa'] as bool? ?? true,
      );
}

/// Com que frequência a frase de boas-vindas muda.
enum PeriodicidadeFrase {
  diaria('Todo dia'),
  semanal('Toda semana'),
  quinzenal('A cada 15 dias'),
  mensal('Todo mês');

  const PeriodicidadeFrase(this.rotulo);

  final String rotulo;

  static PeriodicidadeFrase porNome(Object? nome) =>
      PeriodicidadeFrase.values.firstWhere(
        (item) => item.name == nome,
        orElse: () => PeriodicidadeFrase.semanal,
      );

  /// Número sequencial do período que contém [data].
  int indiceDoPeriodo(DateTime data) {
    // Base fixa numa segunda-feira para que semanas comecem na segunda.
    final base = DateTime.utc(2024, 1, 1);
    final dia = DateTime.utc(data.year, data.month, data.day);
    final dias = dia.difference(base).inDays;
    return switch (this) {
      PeriodicidadeFrase.diaria => dias,
      PeriodicidadeFrase.semanal => dias ~/ 7,
      PeriodicidadeFrase.quinzenal => dias ~/ 14,
      PeriodicidadeFrase.mensal => data.year * 12 + data.month - 1,
    };
  }
}

/// Escolhe a frase ativa do período atual, em rodízio.
FraseMotivacional? fraseDoPeriodo(
  List<FraseMotivacional> frases,
  PeriodicidadeFrase periodicidade,
  DateTime agora,
) {
  final ativas = frases.where((frase) => frase.ativa).toList(growable: false);
  if (ativas.isEmpty) return null;
  final indice = periodicidade.indiceDoPeriodo(agora);
  return ativas[indice % ativas.length];
}

/// Frases iniciais, usadas até a chefia personalizar a lista.
const frasesPadrao = [
  'Cada pequena entrega de hoje constrói o departamento de amanhã.',
  'Bons resultados nascem de equipes que se apoiam.',
  'Organização hoje é tranquilidade amanhã.',
  'Ensinar é acender caminhos. Obrigado por fazer parte disso.',
  'Um passo de cada vez também chega longe.',
  'Seu trabalho faz diferença na formação de muita gente.',
  'Foco no essencial, cuidado nos detalhes.',
  'A educação transforma, e você faz parte dessa transformação.',
];

DateTime _dia(DateTime data) => DateTime(data.year, data.month, data.day);
