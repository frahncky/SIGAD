import 'docente_models.dart';
import 'normalizador_texto.dart';

class ResultadoAfinidadeHistorica {
  const ResultadoAfinidadeHistorica({
    required this.pontuacao,
    required this.amostras,
    required this.explicacao,
  });

  final double pontuacao;
  final int amostras;
  final String explicacao;
}

/// Aprende uma preferência simples e auditável a partir das decisões do chefe.
///
/// Enquanto não há volume suficiente para um modelo estatístico treinado, usa
/// suavização de Laplace. Assim, o histórico influencia o desempate sem jamais
/// ultrapassar as restrições legais e de horário.
class AfinidadeHistoricaService {
  const AfinidadeHistoricaService();

  ResultadoAfinidadeHistorica avaliar({
    required String docenteDestinoId,
    required String disciplina,
    required String diaSemana,
    required List<RegistroDecisaoRedistribuicao> registros,
  }) {
    final disciplinaNormalizada = NormalizadorTexto.paraComparacao(disciplina);
    final diaNormalizado = NormalizadorTexto.paraComparacao(diaSemana);
    final doDocente = registros
        .where((item) => item.docenteDestinoId == docenteDestinoId)
        .toList(growable: false);
    final especificos = doDocente
        .where(
          (item) =>
              NormalizadorTexto.paraComparacao(item.disciplina) ==
                  disciplinaNormalizada &&
              NormalizadorTexto.paraComparacao(item.diaSemana) ==
                  diaNormalizado,
        )
        .toList(growable: false);

    if (doDocente.isEmpty) {
      return const ResultadoAfinidadeHistorica(
        pontuacao: 0.5,
        amostras: 0,
        explicacao: 'Sem decisões anteriores; afinidade histórica neutra.',
      );
    }

    final pontuacaoGeral = _taxaSuavizada(doDocente);
    final pontuacaoEspecifica = especificos.isEmpty
        ? pontuacaoGeral
        : _taxaSuavizada(especificos);
    final pesoEspecifico = (especificos.length / 5).clamp(0.0, 0.7);
    final pontuacao =
        (pontuacaoEspecifica * pesoEspecifico) +
        (pontuacaoGeral * (1 - pesoEspecifico));

    return ResultadoAfinidadeHistorica(
      pontuacao: pontuacao.clamp(0.0, 1.0),
      amostras: doDocente.length,
      explicacao: especificos.isEmpty
          ? 'Afinidade baseada em ${doDocente.length} decisão(ões) anteriores.'
          : 'Afinidade baseada em ${especificos.length} decisão(ões) para esta disciplina e dia.',
    );
  }

  double _taxaSuavizada(List<RegistroDecisaoRedistribuicao> registros) {
    final aceitas = registros
        .where(
          (item) => item.resultado == ResultadoDecisaoRedistribuicao.aceita,
        )
        .length;
    return (aceitas + 1) / (registros.length + 2);
  }
}
