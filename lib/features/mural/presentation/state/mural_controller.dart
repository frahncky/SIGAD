import 'package:flutter/foundation.dart';

import '../../../../core/models/user_role.dart';
import '../../../../core/services/app_event_logger.dart';
import '../../data/mural_repository.dart';
import '../../domain/mural_models.dart';

/// Estado do mural do departamento, compartilhado pelo app.
///
/// O card do topo do painel e a tela de gestão leem daqui, então uma edição
/// da chefia aparece no painel sem recarregar.
class MuralController extends ChangeNotifier {
  MuralController({MuralRepository? repository, DateTime Function()? agora})
    : _repository = repository ?? MuralRepository(),
      _agora = agora ?? DateTime.now;

  final MuralRepository _repository;
  final DateTime Function() _agora;

  List<Aviso> _avisos = const [];
  List<FraseMotivacional> _frases = [
    for (var i = 0; i < frasesPadrao.length; i++)
      FraseMotivacional(id: 'padrao_$i', texto: frasesPadrao[i]),
  ];
  PeriodicidadeFrase _periodicidade = PeriodicidadeFrase.semanal;
  bool _carregado = false;
  bool _falhouAoCarregar = false;
  Future<void>? _carregando;

  List<Aviso> get avisos => List.unmodifiable(_avisos);
  List<FraseMotivacional> get frases => List.unmodifiable(_frases);
  PeriodicidadeFrase get periodicidade => _periodicidade;
  bool get carregado => _carregado;

  /// Verdadeiro quando os dados salvos não puderam ser lidos. Nesse caso as
  /// gravações ficam bloqueadas para não sobrescrever o que está salvo.
  bool get falhouAoCarregar => _falhouAoCarregar;

  /// Avisos que o perfil vê hoje: fixados primeiro, depois os mais recentes.
  List<Aviso> avisosVisiveis(UserRole? perfil) {
    final agora = _agora();
    final visiveis = [
      for (final aviso in _avisos)
        if (aviso.visivelPara(perfil, agora)) aviso,
    ];
    visiveis.sort((a, b) {
      if (a.fixado != b.fixado) return a.fixado ? -1 : 1;
      return b.criadoEm.compareTo(a.criadoEm);
    });
    return visiveis;
  }

  FraseMotivacional? get fraseAtual =>
      fraseDoPeriodo(_frases, _periodicidade, _agora());

  Future<void> carregar() => _carregando ??= _carregar();

  Future<void> _carregar() async {
    try {
      final dados = await _repository.carregar();
      _avisos = dados.avisos;
      _frases = dados.frases;
      _periodicidade = dados.periodicidade;
    } catch (error, stackTrace) {
      AppEventLogger.error('mural_load_error', error, stackTrace: stackTrace);
      _falhouAoCarregar = true;
    } finally {
      _carregado = true;
      notifyListeners();
    }
  }

  String novoId() => _agora().microsecondsSinceEpoch.toString();

  DateTime agora() => _agora();

  void _garantirGravavel() {
    if (_falhouAoCarregar) {
      throw StateError('Mural não carregado; gravação bloqueada.');
    }
  }

  Future<void> salvarAviso(Aviso aviso) async {
    _garantirGravavel();
    final indice = _avisos.indexWhere((item) => item.id == aviso.id);
    final novos = [..._avisos];
    if (indice < 0) {
      novos.add(aviso);
    } else {
      novos[indice] = aviso;
    }
    await _repository.salvarAvisos(novos);
    _avisos = novos;
    notifyListeners();
  }

  Future<void> excluirAviso(String id) async {
    _garantirGravavel();
    final novos = [
      for (final aviso in _avisos)
        if (aviso.id != id) aviso,
    ];
    await _repository.salvarAvisos(novos);
    _avisos = novos;
    notifyListeners();
  }

  Future<void> salvarFrase(FraseMotivacional frase) async {
    final indice = _frases.indexWhere((item) => item.id == frase.id);
    final novas = [..._frases];
    if (indice < 0) {
      novas.add(frase);
    } else {
      novas[indice] = frase;
    }
    await _salvarFrases(novas, _periodicidade);
  }

  Future<void> excluirFrase(String id) => _salvarFrases([
    for (final frase in _frases)
      if (frase.id != id) frase,
  ], _periodicidade);

  Future<void> definirPeriodicidade(PeriodicidadeFrase periodicidade) =>
      _salvarFrases(_frases, periodicidade);

  Future<void> _salvarFrases(
    List<FraseMotivacional> frases,
    PeriodicidadeFrase periodicidade,
  ) async {
    _garantirGravavel();
    await _repository.salvarFrases(frases, periodicidade);
    _frases = frases;
    _periodicidade = periodicidade;
    notifyListeners();
  }
}
