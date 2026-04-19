class ConfiguracoesData {
  const ConfiguracoesData({
    required this.notificacoesAtivas,
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
  });

  final bool notificacoesAtivas;
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

  ConfiguracoesData copyWith({
    bool? notificacoesAtivas,
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
  }) {
    return ConfiguracoesData(
      notificacoesAtivas: notificacoesAtivas ?? this.notificacoesAtivas,
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
    );
  }
}
