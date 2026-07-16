import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../domain/docente_models.dart';

class DistribuicaoHistoricoRepository {
  static const _storageKey = 'carga_docente_decisoes_redistribuicao_v1';
  static const _limiteRegistros = 500;

  Future<List<RegistroDecisaoRedistribuicao>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw == null || raw.trim().isEmpty) return const [];

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return const [];
      return decoded
          .whereType<Map>()
          .map((item) => _fromJson(Map<String, dynamic>.from(item)))
          .whereType<RegistroDecisaoRedistribuicao>()
          .toList(growable: false);
    } on FormatException {
      return const [];
    }
  }

  Future<void> registrarDecisao({
    required List<PropostaRedistribuicao> propostas,
    required ResultadoDecisaoRedistribuicao resultado,
  }) async {
    if (propostas.isEmpty) return;
    final agora = DateTime.now();
    final registros = List<RegistroDecisaoRedistribuicao>.from(await load());
    registros.addAll(
      propostas.map(
        (proposta) => RegistroDecisaoRedistribuicao(
          docenteDestinoId: proposta.docenteDestinoId,
          disciplina: proposta.horario.disciplina ?? '',
          diaSemana: proposta.horario.diaSemana,
          resultado: resultado,
          ocorridoEm: agora,
        ),
      ),
    );
    final mantidos = registros.length <= _limiteRegistros
        ? registros
        : registros.sublist(registros.length - _limiteRegistros);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _storageKey,
      jsonEncode(mantidos.map(_toJson).toList(growable: false)),
    );
  }

  Map<String, dynamic> _toJson(RegistroDecisaoRedistribuicao item) => {
    'docenteDestinoId': item.docenteDestinoId,
    'disciplina': item.disciplina,
    'diaSemana': item.diaSemana,
    'resultado': item.resultado.name,
    'ocorridoEm': item.ocorridoEm.toIso8601String(),
  };

  RegistroDecisaoRedistribuicao? _fromJson(Map<String, dynamic> json) {
    final docenteId = json['docenteDestinoId'] as String?;
    final ocorridoEm = DateTime.tryParse(json['ocorridoEm'] as String? ?? '');
    final resultado = ResultadoDecisaoRedistribuicao.values
        .where((item) => item.name == json['resultado'])
        .firstOrNull;
    if (docenteId == null || ocorridoEm == null || resultado == null) {
      return null;
    }
    return RegistroDecisaoRedistribuicao(
      docenteDestinoId: docenteId,
      disciplina: json['disciplina'] as String? ?? '',
      diaSemana: json['diaSemana'] as String? ?? '',
      resultado: resultado,
      ocorridoEm: ocorridoEm,
    );
  }
}
