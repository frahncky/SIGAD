import '../../../core/services/local_storage_service.dart';
import '../domain/mural_models.dart';

/// Conteúdo completo do mural do departamento.
class MuralDados {
  const MuralDados({
    required this.avisos,
    required this.frases,
    required this.periodicidade,
  });

  final List<Aviso> avisos;
  final List<FraseMotivacional> frases;
  final PeriodicidadeFrase periodicidade;
}

/// Persistência local do mural (avisos, frases e configuração).
///
/// Ainda não há API do mural: os dados ficam no aparelho.
class MuralRepository {
  MuralRepository({this.prefixo = 'sigad_mural'});

  final String prefixo;

  String get _chaveAvisos => '${prefixo}_avisos';
  String get _chaveFrases => '${prefixo}_frases';
  String get _chaveConfig => '${prefixo}_config';

  Future<MuralDados> carregar() async {
    final avisos = await LocalStorageService.loadList(_chaveAvisos);
    final config = await LocalStorageService.loadMap(_chaveConfig);
    // Sem configuração salva, o mural nunca foi personalizado.
    final frases = config == null
        ? [
            for (var i = 0; i < frasesPadrao.length; i++)
              FraseMotivacional(id: 'padrao_$i', texto: frasesPadrao[i]),
          ]
        : [
            for (final json in await LocalStorageService.loadList(_chaveFrases))
              ?_ler(json, FraseMotivacional.fromJson),
          ];
    return MuralDados(
      avisos: [for (final json in avisos) ?_ler(json, Aviso.fromJson)],
      frases: frases,
      periodicidade: PeriodicidadeFrase.porNome(config?['periodicidade']),
    );
  }

  Future<void> salvarAvisos(List<Aviso> avisos) => LocalStorageService.saveList(
    _chaveAvisos,
    [for (final aviso in avisos) aviso.toJson()],
  );

  Future<void> salvarFrases(
    List<FraseMotivacional> frases,
    PeriodicidadeFrase periodicidade,
  ) async {
    await LocalStorageService.saveList(_chaveFrases, [
      for (final frase in frases) frase.toJson(),
    ]);
    await LocalStorageService.saveMap(_chaveConfig, {
      'periodicidade': periodicidade.name,
    });
  }
}

/// Ignora um registro inválido sem perder os demais.
T? _ler<T>(Map<String, dynamic> json, T Function(Map<String, dynamic>) ler) {
  try {
    return ler(json);
  } catch (_) {
    return null;
  }
}
