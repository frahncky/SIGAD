import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sigad/features/carga_docente/data/distribuicao_historico_repository.dart';
import 'package:sigad/features/carga_docente/domain/afinidade_historica_service.dart';
import 'package:sigad/features/carga_docente/domain/docente_form_service.dart';
import 'package:sigad/features/carga_docente/domain/docente_models.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const horario = HorarioAula(
    diaSemana: 'Segunda',
    inicio: '08:00',
    fim: '09:40',
    disciplina: 'Algoritmos',
    cargaHoraria: '2',
  );
  const origem = Docente(
    id: 'origem',
    nome: 'Origem',
    departamento: 'Computação',
    cargaHoraria: 12,
    cargaMaxima: 20,
    disciplinas: ['Algoritmos'],
    horariosAula: [horario],
  );
  const destino1 = Docente(
    id: 'd1',
    nome: 'Destino 1',
    departamento: 'Computação',
    cargaHoraria: 8,
    cargaMaxima: 20,
    disciplinas: ['Algoritmos'],
  );
  const destino2 = Docente(
    id: 'd2',
    nome: 'Destino 2',
    departamento: 'Computação',
    cargaHoraria: 8,
    cargaMaxima: 20,
    disciplinas: ['Algoritmos'],
  );

  test('PIT aprovado bloqueia candidato em horário indisponível', () {
    final resultado = DocenteFormService.simularRedistribuicaoDocentes(
      const [origem, destino1, destino2],
      planosAprovados: const {
        'd1': PlanoTrabalhoDocente(
          docenteId: 'd1',
          periodoLetivo: '2026.2',
          status: StatusPlanoTrabalhoDocente.aprovado,
          indisponibilidades: [
            IndisponibilidadeDocente(
              diaSemana: 'Segunda',
              inicio: '07:30',
              fim: '10:00',
            ),
          ],
        ),
      },
    );

    expect(resultado.propostas, hasLength(1));
    expect(resultado.propostas.single.docenteDestinoId, 'd2');
    expect(resultado.propostas.single.requerAtualizacaoPit, isTrue);
    expect(resultado.propostas.single.justificativas, isNotEmpty);
  });

  test('afinidade histórica desempata candidatos válidos', () {
    final resultado = DocenteFormService.simularRedistribuicaoDocentes(
      const [origem, destino1, destino2],
      avaliarAfinidade: (destino, _) => AvaliacaoAfinidadeRedistribuicao(
        pontuacao: destino.id == 'd2' ? 0.95 : 0.05,
        explicacao: 'Preferência aprendida em decisões anteriores.',
      ),
    );

    expect(resultado.propostas.single.docenteDestinoId, 'd2');
    expect(resultado.propostas.single.pontuacao, greaterThan(0));
  });

  test('histórico persiste decisões e gera afinidade auditável', () async {
    SharedPreferences.setMockInitialValues({});
    final repository = DistribuicaoHistoricoRepository();
    final proposta = PropostaRedistribuicao(
      docenteOrigemId: 'origem',
      docenteOrigemNome: 'Origem',
      docenteDestinoId: 'd2',
      docenteDestinoNome: 'Destino 2',
      horario: horario,
      cargaSemanal: 2,
    );
    await repository.registrarDecisao(
      propostas: [proposta],
      resultado: ResultadoDecisaoRedistribuicao.aceita,
    );

    final registros = await repository.load();
    final afinidade = const AfinidadeHistoricaService().avaliar(
      docenteDestinoId: 'd2',
      disciplina: 'Algoritmos',
      diaSemana: 'Segunda',
      registros: registros,
    );
    expect(registros.single.resultado, ResultadoDecisaoRedistribuicao.aceita);
    expect(afinidade.pontuacao, greaterThan(0.5));
    expect(afinidade.amostras, 1);
  });
}
