import 'package:flutter/foundation.dart';

import '../../../core/services/local_storage_service.dart';
import '../domain/laboratorio_models.dart';

class LaboratorioRepository {
  LaboratorioRepository({this.storageKey = 'sigad_laboratorios'});

  final String storageKey;
  static final Map<String, List<Laboratorio>> _memoryCache = {};

  /// Esvazia o cache em memória (usado entre testes).
  @visibleForTesting
  static void limparCache() => _memoryCache.clear();

  Future<List<Laboratorio>> load() async {
    final cached = _memoryCache[storageKey];
    if (cached != null) return List<Laboratorio>.from(cached);
    final data = await LocalStorageService.loadList(storageKey);
    if (data.isEmpty) {
      final defaults = defaultLaboratorios();
      _memoryCache[storageKey] = defaults;
      return List<Laboratorio>.from(defaults);
    }
    final laboratorios = <Laboratorio>[];
    for (final item in data) {
      try {
        laboratorios.add(Laboratorio.fromJson(item));
      } catch (_) {
        // Um registro inválido não deve impedir o acesso aos demais.
      }
    }
    final resultado = laboratorios.isEmpty
        ? defaultLaboratorios()
        : laboratorios;
    _memoryCache[storageKey] = resultado;
    return List<Laboratorio>.from(resultado);
  }

  Future<void> save(List<Laboratorio> laboratorios) {
    _memoryCache[storageKey] = List<Laboratorio>.from(laboratorios);
    return LocalStorageService.saveList(
      storageKey,
      laboratorios.map((item) => item.toJson()).toList(growable: false),
    );
  }

  List<Laboratorio> defaultLaboratorios() => [
    Laboratorio(
      id: 'LAB-MEDIDAS',
      nome: 'Lab. de Medidas Elétricas',
      localizacao: 'Bloco C · Sala 12',
      capacidade: 24,
      responsavelTecnico: 'Prof. Antônio Carlos',
      status: StatusLaboratorio.operando,
      equipamentos: [
        EquipamentoLaboratorio(
          id: 'EQ-OSC',
          nome: 'Osciloscópio digital',
          quantidade: 2,
          status: StatusEquipamento.disponivel,
        ),
        EquipamentoLaboratorio(
          id: 'EQ-FONTE',
          nome: 'Fonte de alimentação CC',
          quantidade: 2,
          status: StatusEquipamento.disponivel,
        ),
        EquipamentoLaboratorio(
          id: 'EQ-MULT',
          nome: 'Multímetro digital',
          quantidade: 8,
          status: StatusEquipamento.disponivel,
        ),
        EquipamentoLaboratorio(
          id: 'EQ-PROJ',
          nome: 'Projetor',
          quantidade: 1,
          status: StatusEquipamento.disponivel,
        ),
      ],
    ),
    Laboratorio(
      id: 'LAB-ELETRONICA',
      nome: 'Lab. de Eletrônica',
      localizacao: 'Bloco C · Sala 10',
      capacidade: 20,
      responsavelTecnico: 'Profa. Mariana Costa',
      status: StatusLaboratorio.manutencao,
      equipamentos: [
        EquipamentoLaboratorio(
          id: 'EQ-BANC',
          nome: 'Bancada didática',
          quantidade: 6,
          status: StatusEquipamento.disponivel,
        ),
        EquipamentoLaboratorio(
          id: 'EQ-GER',
          nome: 'Gerador de funções',
          quantidade: 4,
          status: StatusEquipamento.manutencao,
        ),
      ],
      manutencoes: [
        ManutencaoLaboratorio(
          id: 'MAN-001',
          descricao: 'Revisão da rede elétrica das bancadas',
          inicio: DateTime(2026, 7, 15),
          previsaoFim: DateTime(2026, 7, 22),
        ),
      ],
    ),
    Laboratorio(
      id: 'LAB-AUTOMACAO',
      nome: 'Lab. de Automação',
      localizacao: 'Bloco D · Sala 04',
      capacidade: 18,
      responsavelTecnico: 'Prof. Jefferson Lima',
      status: StatusLaboratorio.operando,
      equipamentos: [
        EquipamentoLaboratorio(
          id: 'EQ-CLP',
          nome: 'CLP didático',
          quantidade: 8,
          status: StatusEquipamento.disponivel,
        ),
        EquipamentoLaboratorio(
          id: 'EQ-IHM',
          nome: 'IHM',
          quantidade: 4,
          status: StatusEquipamento.emUso,
        ),
      ],
    ),
  ];
}
