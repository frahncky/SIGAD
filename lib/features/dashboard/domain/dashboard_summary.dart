import '../../atividades/domain/atividade_models.dart';
import '../../aulas_praticas/domain/laboratorio_models.dart';
import '../../demandas/domain/demanda_models.dart';
import '../../demandas/domain/demandas_service.dart';
import '../../kanban/domain/kanban_models.dart';

/// Situação de prazo de uma pendência em relação ao dia atual.
enum SituacaoPrazo { atrasada, hoje, futura, semData }

/// Indicadores consolidados exibidos no topo da Visão geral.
///
/// Os números são calculados apenas a partir dos registros já carregados
/// pelos repositórios; nenhum valor é estimado ou fixo.
class DashboardSummary {
  const DashboardSummary({
    required this.demandasAbertas,
    required this.demandasPrioritarias,
    required this.tarefasAbertas,
    required this.tarefasEmAndamento,
    required this.atividadesAbertas,
    required this.atividadesSemana,
    required this.laboratorios,
    required this.laboratoriosManutencao,
  });

  factory DashboardSummary.calcular({
    required List<Demanda> demandas,
    required List<KanbanCardModel> cards,
    required List<Atividade> atividades,
    required List<Laboratorio> laboratorios,
    required DateTime agora,
  }) {
    final demandasAbertas = demandas.where(demandaEstaAberta).toList();
    final tarefasAbertas = cards
        .where((card) => card.coluna != 'Concluído')
        .toList();
    final atividadesAbertas = atividades.where(atividadeEstaAberta).toList();
    // Semana útil: segunda a sexta.
    final inicioSemana = _inicioDaSemana(agora);
    final fimSemana = DateTime(
      inicioSemana.year,
      inicioSemana.month,
      inicioSemana.day + 5,
    );

    return DashboardSummary(
      demandasAbertas: demandasAbertas.length,
      demandasPrioritarias: demandasAbertas
          .where((item) => item.prioridade == 'Alta')
          .length,
      tarefasAbertas: tarefasAbertas.length,
      tarefasEmAndamento: tarefasAbertas
          .where((card) => card.coluna == 'Em Progresso')
          .length,
      atividadesAbertas: atividadesAbertas.length,
      atividadesSemana: atividadesAbertas.where((item) {
        final data = dataDaAtividade(item.data);
        return data != null &&
            !data.isBefore(inicioSemana) &&
            data.isBefore(fimSemana);
      }).length,
      laboratorios: laboratorios.length,
      laboratoriosManutencao: laboratorios
          .where((lab) => lab.status == StatusLaboratorio.manutencao)
          .length,
    );
  }

  final int demandasAbertas;
  final int demandasPrioritarias;
  final int tarefasAbertas;
  final int tarefasEmAndamento;
  final int atividadesAbertas;
  final int atividadesSemana;
  final int laboratorios;
  final int laboratoriosManutencao;

  static bool demandaEstaAberta(Demanda demanda) =>
      demanda.statusLabel != 'Concluído';

  static bool atividadeEstaAberta(Atividade atividade) =>
      atividade.status != 'Concluída';

  /// Demandas abertas ordenadas pelo prazo mais próximo e, em empate,
  /// pela prioridade.
  static List<Demanda> demandasPorPrazo(List<Demanda> demandas) {
    final abertas = demandas.where(demandaEstaAberta).toList();
    abertas.sort((a, b) {
      final prazo = (dataDaAtividade(a.prazo) ?? _semData).compareTo(
        dataDaAtividade(b.prazo) ?? _semData,
      );
      if (prazo != 0) return prazo;
      return DemandasService.pesoPrioridade(
        a.prioridade,
      ).compareTo(DemandasService.pesoPrioridade(b.prioridade));
    });
    return abertas;
  }

  /// Atividades abertas ordenadas pela data mais próxima; sem data por último.
  static List<Atividade> atividadesPorData(List<Atividade> atividades) {
    final abertas = atividades.where(atividadeEstaAberta).toList();
    abertas.sort((a, b) {
      final dataA = dataDaAtividade(a.data) ?? _semData;
      final dataB = dataDaAtividade(b.data) ?? _semData;
      return dataA.compareTo(dataB);
    });
    return abertas;
  }

  /// Compara um prazo no formato `dd/MM/aaaa` com o dia de [agora].
  static SituacaoPrazo situacaoPrazo(String prazo, DateTime agora) {
    final data = dataDaAtividade(prazo);
    if (data == null) return SituacaoPrazo.semData;
    final hoje = DateTime(agora.year, agora.month, agora.day);
    if (data.isBefore(hoje)) return SituacaoPrazo.atrasada;
    if (data == hoje) return SituacaoPrazo.hoje;
    return SituacaoPrazo.futura;
  }

  /// Lê o dia de textos como `15/04/2026` ou `15/04/2026 - 10:30`.
  static DateTime? dataDaAtividade(String texto) {
    final match = RegExp(
      r'(?<!\d)(\d{1,2})/(\d{1,2})/(\d{4})(?!\d)',
    ).firstMatch(texto);
    if (match == null) return null;
    final dia = int.parse(match.group(1)!);
    final mes = int.parse(match.group(2)!);
    final ano = int.parse(match.group(3)!);
    if (mes < 1 || mes > 12 || dia < 1 || dia > 31) return null;
    final data = DateTime(ano, mes, dia);
    // Rejeita datas inexistentes, como 31/02, que o DateTime normalizaria.
    if (data.month != mes || data.day != dia) return null;
    return data;
  }

  /// Datas ausentes ou inválidas vão para o fim das listas.
  static final _semData = DateTime(2100);

  /// Segunda-feira da semana útil de [agora]. No sábado e no domingo os
  /// dias úteis já passaram, então vale a semana seguinte.
  static DateTime _inicioDaSemana(DateTime agora) {
    // Construído por calendário para não depender de horário de verão.
    final deslocamento = agora.weekday >= DateTime.saturday
        ? DateTime.daysPerWeek - (agora.weekday - DateTime.monday)
        : -(agora.weekday - DateTime.monday);
    return DateTime(agora.year, agora.month, agora.day + deslocamento);
  }
}
