import '../../../core/services/local_storage_service.dart';
import '../domain/configuracoes_models.dart';

class ConfiguracoesRepository {
  ConfiguracoesRepository({this.storageKey = 'sigad_configuracoes'});

  final String storageKey;

  Future<ConfiguracoesData?> load() async {
    final data = await LocalStorageService.loadMap(storageKey);
    if (data == null) return null;

    try {
      return _fromMap(data);
    } catch (_) {
      return null;
    }
  }

  Future<void> save(ConfiguracoesData data) {
    return LocalStorageService.saveMap(storageKey, _toMap(data));
  }

  Map<String, dynamic> _toMap(ConfiguracoesData data) => {
    'notificacoesAtivas': data.notificacoesAtivas,
    'notificarAntesDaDisciplina': data.notificarAntesDaDisciplina,
    'antecedenciaNotificacaoMinutos': data.antecedenciaNotificacaoMinutos,
    'modoDark': data.modoDark,
    'biometriaAtiva': data.biometriaAtiva,
    'backupAutomaticoAtivo': data.backupAutomaticoAtivo,
    'idioma': data.idioma,
    'tamanhoFonte': data.tamanhoFonte,
    'nomePerfil': data.nomePerfil,
    'cargoPerfil': data.cargoPerfil,
    'emailUsuario': data.emailUsuario,
    'ultimaAlteracaoSenha': data.ultimaAlteracaoSenha,
    'proximoBackup': data.proximoBackup,
    'ultimoBackup': data.ultimoBackup,
    'problemasReportados': data.problemasReportados,
    'agendaCompromissos': data.agendaCompromissos
        .map((item) => item.toMap())
        .toList(growable: false),
  };

  ConfiguracoesData _fromMap(Map<String, dynamic> data) => ConfiguracoesData(
    notificacoesAtivas: data['notificacoesAtivas'] as bool? ?? false,
    notificarAntesDaDisciplina:
        data['notificarAntesDaDisciplina'] as bool? ?? false,
    antecedenciaNotificacaoMinutos:
        data['antecedenciaNotificacaoMinutos'] as int? ?? 15,
    modoDark: data['modoDark'] as bool? ?? false,
    biometriaAtiva: data['biometriaAtiva'] as bool? ?? false,
    backupAutomaticoAtivo: data['backupAutomaticoAtivo'] as bool? ?? false,
    idioma: data['idioma'] as String? ?? 'Português (Brasil)',
    tamanhoFonte: data['tamanhoFonte'] as String? ?? 'Médio',
    nomePerfil: data['nomePerfil'] as String? ?? 'Usuário',
    cargoPerfil: data['cargoPerfil'] as String? ?? 'Perfil institucional',
    emailUsuario: data['emailUsuario'] as String? ?? '',
    ultimaAlteracaoSenha:
        data['ultimaAlteracaoSenha'] as String? ?? 'Indisponível',
    proximoBackup: data['proximoBackup'] as String? ?? 'Indisponível',
    ultimoBackup: data['ultimoBackup'] as String? ?? 'Indisponível',
    problemasReportados: data['problemasReportados'] as int? ?? 0,
    agendaCompromissos:
        (data['agendaCompromissos'] as List<dynamic>? ?? const [])
            .whereType<Map>()
            .map(
              (item) =>
                  CompromissoAgenda.fromMap(Map<String, dynamic>.from(item)),
            )
            .toList(growable: false),
  );
}
