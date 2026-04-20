enum StatusConviteAgenda { pendente, aceito, recusado }

class CompromissoAgenda {
  const CompromissoAgenda({
    required this.id,
    required this.titulo,
    required this.descricao,
    required this.inicio,
    required this.inicioIso,
    required this.local,
    required this.origem,
    required this.destinatarioUserId,
    this.linkReuniao,
    this.statusConvite = StatusConviteAgenda.pendente,
  });

  final String id;
  final String titulo;
  final String descricao;
  final String inicio;
  final String inicioIso;
  final String local;
  final String origem;
  final String destinatarioUserId;
  final String? linkReuniao;
  final StatusConviteAgenda statusConvite;

  CompromissoAgenda copyWith({
    String? id,
    String? titulo,
    String? descricao,
    String? inicio,
    String? inicioIso,
    String? local,
    String? origem,
    String? destinatarioUserId,
    String? linkReuniao,
    StatusConviteAgenda? statusConvite,
  }) {
    return CompromissoAgenda(
      id: id ?? this.id,
      titulo: titulo ?? this.titulo,
      descricao: descricao ?? this.descricao,
      inicio: inicio ?? this.inicio,
      inicioIso: inicioIso ?? this.inicioIso,
      local: local ?? this.local,
      origem: origem ?? this.origem,
      destinatarioUserId: destinatarioUserId ?? this.destinatarioUserId,
      linkReuniao: linkReuniao ?? this.linkReuniao,
      statusConvite: statusConvite ?? this.statusConvite,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'titulo': titulo,
        'descricao': descricao,
        'inicio': inicio,
        'inicioIso': inicioIso,
        'local': local,
        'origem': origem,
        'destinatarioUserId': destinatarioUserId,
        'linkReuniao': linkReuniao,
        'statusConvite': statusConvite.name,
      };

  factory CompromissoAgenda.fromMap(Map<String, dynamic> data) {
    final statusRaw = data['statusConvite'] as String?;
    StatusConviteAgenda? parsedStatus;
    for (final item in StatusConviteAgenda.values) {
      if (item.name == statusRaw) {
        parsedStatus = item;
        break;
      }
    }

    return CompromissoAgenda(
      id: data['id'] as String,
      titulo: data['titulo'] as String,
      descricao: data['descricao'] as String,
      inicio: data['inicio'] as String,
      inicioIso: data['inicioIso'] as String? ?? DateTime.now().toIso8601String(),
      local: data['local'] as String,
      origem: data['origem'] as String,
      destinatarioUserId: data['destinatarioUserId'] as String? ?? '',
      linkReuniao: data['linkReuniao'] as String?,
      statusConvite: parsedStatus ?? StatusConviteAgenda.pendente,
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
