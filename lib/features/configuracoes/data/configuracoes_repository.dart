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
      };

  ConfiguracoesData _fromMap(Map<String, dynamic> data) => ConfiguracoesData(
        notificacoesAtivas: data['notificacoesAtivas'] as bool? ?? true,
        modoDark: data['modoDark'] as bool? ?? false,
        biometriaAtiva: data['biometriaAtiva'] as bool? ?? false,
        backupAutomaticoAtivo: data['backupAutomaticoAtivo'] as bool? ?? true,
        idioma: data['idioma'] as String? ?? 'Português (Brasil)',
        tamanhoFonte: data['tamanhoFonte'] as String? ?? 'Médio',
        nomePerfil: data['nomePerfil'] as String? ?? 'João Silva',
        cargoPerfil: data['cargoPerfil'] as String? ?? 'Coordenador Acadêmico',
        emailUsuario: data['emailUsuario'] as String? ?? 'joao.silva@universidade.edu.br',
        ultimaAlteracaoSenha: data['ultimaAlteracaoSenha'] as String? ?? '20/02/2026',
        proximoBackup: data['proximoBackup'] as String? ?? '25/04/2026',
        ultimoBackup: data['ultimoBackup'] as String? ?? '20/04/2026 às 14:30',
        problemasReportados: data['problemasReportados'] as int? ?? 0,
      );
}
