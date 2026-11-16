import 'package:flutter_test/flutter_test.dart';
import 'package:sigad/features/atividades/domain/atividade_models.dart';
import 'package:sigad/features/aulas_praticas/domain/laboratorio_models.dart';
import 'package:sigad/features/dashboard/domain/dashboard_summary.dart';
import 'package:sigad/features/demandas/domain/demanda_models.dart';
import 'package:sigad/features/kanban/domain/kanban_models.dart';

Demanda _demanda(
  String id, {
  String prioridade = 'Média',
  String status = 'Novo',
  String prazo = '20/11/2026',
}) => Demanda(
  id: id,
  titulo: 'Demanda $id',
  descricao: '',
  prioridade: prioridade,
  statusLabel: status,
  proprietario: 'Chefia do DEE',
  prazo: prazo,
);

Atividade _atividade(String id, String data, {String status = 'Planejada'}) =>
    Atividade(
      id: id,
      titulo: 'Atividade $id',
      descricao: '',
      data: data,
      responsavel: 'Coordenação',
      status: status,
    );

Laboratorio _lab(String id, StatusLaboratorio status) => Laboratorio(
  id: id,
  nome: 'Lab $id',
  localizacao: 'Bloco A',
  capacidade: 20,
  responsavelTecnico: 'Técnico',
  status: status,
  equipamentos: const [],
);

void main() {
  // Quinta-feira, 12/11/2026 → semana útil de 09/11 a 13/11.
  final agora = DateTime(2026, 11, 12, 7, 33);

  test('consolida apenas registros abertos e calcula os destaques', () {
    final resumo = DashboardSummary.calcular(
      demandas: [
        _demanda('1', prioridade: 'Alta'),
        _demanda('2', prioridade: 'Alta', status: 'Concluído'),
        _demanda('3'),
      ],
      cards: const [
        KanbanCardModel(id: 1, titulo: 'a', coluna: 'Backlog', prioridade: ''),
        KanbanCardModel(
          id: 2,
          titulo: 'b',
          coluna: 'Em Progresso',
          prioridade: '',
        ),
        KanbanCardModel(
          id: 3,
          titulo: 'c',
          coluna: 'Concluído',
          prioridade: '',
        ),
      ],
      atividades: [
        _atividade('1', '09/11/2026 - 08:00'),
        _atividade('2', '13/11/2026'),
        _atividade('3', '14/11/2026'),
        _atividade('6', '16/11/2026'),
        _atividade('4', '12/11/2026', status: 'Concluída'),
        _atividade('5', 'sem data'),
      ],
      laboratorios: [
        _lab('1', StatusLaboratorio.operando),
        _lab('2', StatusLaboratorio.manutencao),
        _lab('3', StatusLaboratorio.interditado),
      ],
      agora: agora,
    );

    expect(resumo.demandasAbertas, 2);
    expect(resumo.demandasPrioritarias, 1);
    expect(resumo.tarefasAbertas, 2);
    expect(resumo.tarefasEmAndamento, 1);
    expect(resumo.atividadesAbertas, 5);
    expect(resumo.atividadesSemana, 2);
    expect(resumo.laboratorios, 3);
    expect(resumo.laboratoriosManutencao, 1);
  });

  test(
    'semana útil vai de segunda a sexta; no fim de semana vale a próxima',
    () {
      final atividades = [
        _atividade('sex', '13/11/2026'),
        _atividade('sab', '14/11/2026'),
        _atividade('dom', '15/11/2026'),
        _atividade('seg', '16/11/2026'),
        _atividade('sex2', '20/11/2026'),
        _atividade('sab2', '21/11/2026'),
      ];
      int naSemana(DateTime agora) => DashboardSummary.calcular(
        demandas: const [],
        cards: const [],
        atividades: atividades,
        laboratorios: const [],
        agora: agora,
      ).atividadesSemana;

      // Sexta-feira 13/11: só a própria sexta.
      expect(naSemana(DateTime(2026, 11, 13, 18)), 1);
      // Sábado 14/11 e domingo 15/11: semana de 16/11 a 20/11.
      expect(naSemana(DateTime(2026, 11, 14, 9)), 2);
      expect(naSemana(DateTime(2026, 11, 15, 23, 59)), 2);
    },
  );

  test('ordena demandas abertas por prazo e depois por prioridade', () {
    final ordenadas = DashboardSummary.demandasPorPrazo([
      _demanda('tarde', prazo: '30/12/2026'),
      _demanda('baixa', prioridade: 'Baixa', prazo: '01/12/2026'),
      _demanda('alta', prioridade: 'Alta', prazo: '01/12/2026'),
      _demanda('feita', status: 'Concluído', prazo: '01/01/2026'),
      _demanda('invalida', prazo: 'a definir'),
    ]);

    expect(ordenadas.map((d) => d.id), ['alta', 'baixa', 'tarde', 'invalida']);
  });

  test('classifica a situação do prazo em relação ao dia atual', () {
    expect(
      DashboardSummary.situacaoPrazo('11/11/2026', agora),
      SituacaoPrazo.atrasada,
    );
    expect(
      DashboardSummary.situacaoPrazo('12/11/2026 - 18:00', agora),
      SituacaoPrazo.hoje,
    );
    expect(
      DashboardSummary.situacaoPrazo('13/11/2026', agora),
      SituacaoPrazo.futura,
    );
    expect(DashboardSummary.situacaoPrazo('', agora), SituacaoPrazo.semData);
    expect(
      DashboardSummary.situacaoPrazo('31/02/2026', agora),
      SituacaoPrazo.semData,
    );
  });

  test('atividades sem data ficam por último', () {
    final ordenadas = DashboardSummary.atividadesPorData([
      _atividade('sem', 'a combinar'),
      _atividade('depois', '20/11/2026'),
      _atividade('antes', '10/11/2026'),
    ]);
    expect(ordenadas.map((a) => a.id), ['antes', 'depois', 'sem']);
  });

  test('não aproveita datas embutidas em números maiores', () {
    expect(DashboardSummary.dataDaAtividade('115/04/2026'), isNull);
    expect(DashboardSummary.dataDaAtividade('15/04/20260'), isNull);
    expect(
      DashboardSummary.dataDaAtividade('Prazo 15/04/2026.'),
      DateTime(2026, 4, 15),
    );
  });

  test('prazo inválido vai para o fim, sem passar à frente', () {
    final ordenadas = DashboardSummary.demandasPorPrazo([
      _demanda('invalida', prazo: '31/02/2026'),
      _demanda('valida', prazo: '30/12/2026'),
    ]);
    expect(ordenadas.map((d) => d.id), ['valida', 'invalida']);
  });
}
