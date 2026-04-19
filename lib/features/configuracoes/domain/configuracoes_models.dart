class CompromissoAgenda {
  const CompromissoAgenda({
    required this.id,
    required this.titulo,
    required this.descricao,
    required this.inicio,
    required this.local,
    required this.origem,
    required this.destinatarioUserId,
  });

  final String id;
  final String titulo;
  final String descricao;
  final String inicio;
  final String local;
  final String origem;
  final String destinatarioUserId;

  Map<String, dynamic> toMap() => {
        'id': id,
        'titulo': titulo,
        'descricao': descricao,
        'inicio': inicio,
        'local': local,
        'origem': origem,
        'destinatarioUserId': destinatarioUserId,
      };

  factory CompromissoAgenda.fromMap(Map<String, dynamic> data) {
    return CompromissoAgenda(
      id: data['id'] as String,
      titulo: data['titulo'] as String,
      descricao: data['descricao'] as String,
      inicio: data['inicio'] as String,
      local: data['local'] as String,
      origem: data['origem'] as String,
      destinatarioUserId: data['destinatarioUserId'] as String? ?? '',
    );
  }
}

class ConfiguracoesData {
  const ConfiguracoesData({
    required this.notificacoesAtivas,
    required this.notificarAntesDaDisciplina,
    required this.antecedenciaNotificacaoMinutos,
    required this.modoDark,
    required this.biometriaAtiva,
    required this.backupAutomaticoAtivo,
    required this.idioma,
    required this.tamanhoFonte,
    required this.nomePerfil,
    required this.cargoPerfil,
    required this.emailUsuario,
    required this.ultimaAlteracaoSenha,
    required this.proximoBackup,
    required this.ultimoBackup,
    required this.problemasReportados,
    required this.agendaCompromissos,
  });

  final bool notificacoesAtivas;
  final bool notificarAntesDaDisciplina;
  final int antecedenciaNotificacaoMinutos;
  final bool modoDark;
  final bool biometriaAtiva;
  final bool backupAutomaticoAtivo;
  final String idioma;
  final String tamanhoFonte;
  final String nomePerfil;
  final String cargoPerfil;
  final String emailUsuario;
  final String ultimaAlteracaoSenha;
  final String proximoBackup;
  final String ultimoBackup;
  final int problemasReportados;
  final List<CompromissoAgenda> agendaCompromissos;

  ConfiguracoesData copyWith({
    bool? notificacoesAtivas,
    bool? notificarAntesDaDisciplina,
    int? antecedenciaNotificacaoMinutos,
    bool? modoDark,
    bool? biometriaAtiva,
    bool? backupAutomaticoAtivo,
    String? idioma,
    String? tamanhoFonte,
    String? nomePerfil,
    String? cargoPerfil,
    String? emailUsuario,
    String? ultimaAlteracaoSenha,
    String? proximoBackup,
    String? ultimoBackup,
    int? problemasReportados,
    List<CompromissoAgenda>? agendaCompromissos,
  }) {
    return ConfiguracoesData(
      notificacoesAtivas: notificacoesAtivas ?? this.notificacoesAtivas,
      notificarAntesDaDisciplina: notificarAntesDaDisciplina ?? this.notificarAntesDaDisciplina,
      antecedenciaNotificacaoMinutos:
          antecedenciaNotificacaoMinutos ?? this.antecedenciaNotificacaoMinutos,
      modoDark: modoDark ?? this.modoDark,
      biometriaAtiva: biometriaAtiva ?? this.biometriaAtiva,
      backupAutomaticoAtivo: backupAutomaticoAtivo ?? this.backupAutomaticoAtivo,
      idioma: idioma ?? this.idioma,
      tamanhoFonte: tamanhoFonte ?? this.tamanhoFonte,
      nomePerfil: nomePerfil ?? this.nomePerfil,
      cargoPerfil: cargoPerfil ?? this.cargoPerfil,
      emailUsuario: emailUsuario ?? this.emailUsuario,
      ultimaAlteracaoSenha: ultimaAlteracaoSenha ?? this.ultimaAlteracaoSenha,
      proximoBackup: proximoBackup ?? this.proximoBackup,
      ultimoBackup: ultimoBackup ?? this.ultimoBackup,
      problemasReportados: problemasReportados ?? this.problemasReportados,
      agendaCompromissos: agendaCompromissos ?? this.agendaCompromissos,
    );
  }
}
