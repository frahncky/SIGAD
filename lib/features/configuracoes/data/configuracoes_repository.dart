import '../../../core/services/local_storage_service.dart';
import '../domain/configuracoes_models.dart';
import '../domain/configuracoes_service.dart';

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

  /// Grava o objeto inteiro. Prefira [atualizar] ou [salvarPreferencias],
  /// que partem do valor atual do armazenamento e não sobrescrevem campos
  /// gravados por outras partes do app (como os convites da agenda).
  Future<void> save(ConfiguracoesData data) {
    return _emSequencia(
      () => LocalStorageService.saveMap(storageKey, _toMap(data)),
    );
  }

  /// Lê o valor atual, aplica [alterar] e grava, sem intercalar com outras
  /// gravações da mesma chave feitas neste processo.
  ///
  /// Se o valor salvo não puder ser lido, lança [FormatException] e não grava
  /// nada, para não substituir dados existentes pelos valores padrão.
  Future<void> atualizar(
    ConfiguracoesData Function(ConfiguracoesData atual) alterar,
  ) {
    return _emSequencia(() async {
      final bruto = await LocalStorageService.loadMap(storageKey);
      final ConfiguracoesData atual;
      if (bruto == null) {
        atual = ConfiguracoesService.defaultData();
      } else {
        try {
          atual = _fromMap(bruto);
        } catch (error) {
          throw FormatException('Configurações salvas inválidas: $error');
        }
      }
      await LocalStorageService.saveMap(storageKey, _toMap(alterar(atual)));
    });
  }

  /// Grava somente as preferências informadas, preservando todos os demais
  /// campos já salvos (inclusive os que este repositório não conhece).
  Future<void> salvarPreferencias({
    bool? modoDark,
    String? tamanhoFonte,
    String? idioma,
  }) {
    return _emSequencia(() async {
      final atual = await LocalStorageService.loadMap(storageKey) ?? {};
      await LocalStorageService.saveMap(storageKey, {
        ...atual,
        'modoDark': ?modoDark,
        'tamanhoFonte': ?tamanhoFonte,
        'idioma': ?idioma,
      });
    });
  }

  /// Fila de gravações por chave: cada leitura-alteração-gravação espera a
  /// anterior terminar, para que uma não apague o que a outra gravou.
  static final Map<String, Future<void>> _filas = {};

  Future<T> _emSequencia<T>(Future<T> Function() acao) {
    final anterior = _filas[storageKey] ?? Future<void>.value();
    final resultado = anterior.then((_) => acao());
    _filas[storageKey] = resultado.then<void>((_) {}, onError: (_) {});
    return resultado;
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
    notificacoesAtivas: data['notificacoesAtivas'] as bool? ?? true,
    notificarAntesDaDisciplina:
        data['notificarAntesDaDisciplina'] as bool? ?? true,
    antecedenciaNotificacaoMinutos:
        data['antecedenciaNotificacaoMinutos'] as int? ?? 15,
    modoDark: data['modoDark'] as bool? ?? false,
    biometriaAtiva: data['biometriaAtiva'] as bool? ?? false,
    backupAutomaticoAtivo: data['backupAutomaticoAtivo'] as bool? ?? true,
    idioma: data['idioma'] as String? ?? 'Português (Brasil)',
    tamanhoFonte: data['tamanhoFonte'] as String? ?? 'Médio',
    nomePerfil: data['nomePerfil'] as String? ?? 'Usuário Demonstrativo',
    cargoPerfil:
        data['cargoPerfil'] as String? ?? 'Coordenação dos Cursos do DEE',
    emailUsuario:
        data['emailUsuario'] as String? ?? 'usuario.demo@exemplo.edu.br',
    ultimaAlteracaoSenha:
        data['ultimaAlteracaoSenha'] as String? ?? '20/02/2026',
    proximoBackup: data['proximoBackup'] as String? ?? '25/04/2026',
    ultimoBackup: data['ultimoBackup'] as String? ?? '20/04/2026 às 14:30',
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
