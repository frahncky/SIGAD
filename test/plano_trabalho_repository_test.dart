import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sigad/features/carga_docente/data/plano_trabalho_repository.dart';
import 'package:sigad/features/carga_docente/domain/docente_models.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('persiste PIT, indisponibilidades e trilha de auditoria', () async {
    SharedPreferences.setMockInitialValues({});
    final repository = PlanoTrabalhoRepository();
    final plano = PlanoTrabalhoDocente(
      docenteId: 'd1',
      periodoLetivo: '2026.2',
      status: StatusPlanoTrabalhoDocente.submetido,
      avaliadorId: 'u-chefe',
      atividades: const [
        AtividadePlanoDocente(
          tipo: TipoAtividadePlanoDocente.extensao,
          descricao: 'Projeto de extensão',
          cargaSemanalMinutos: 120,
        ),
      ],
      indisponibilidades: const [
        IndisponibilidadeDocente(
          diaSemana: 'Segunda',
          inicio: '08:00',
          fim: '10:00',
          observacao: 'Projeto institucional',
        ),
      ],
      submetidoEm: DateTime(2026, 7, 1),
    );

    await repository.savePlano(
      plano,
      autorId: 'u-docente',
      acao: AcaoHistoricoPlanoTrabalho.submetido,
    );

    final salvo = await repository.findPlano(
      docenteId: 'd1',
      periodoLetivo: '2026.2',
    );
    final historico = await repository.loadHistorico(planoChave: plano.chave);
    expect(salvo?.status, StatusPlanoTrabalhoDocente.submetido);
    expect(salvo?.indisponibilidades.single.inicio, '08:00');
    expect(salvo?.atividades.single.cargaSemanalMinutos, 120);
    expect(historico.single.acao, AcaoHistoricoPlanoTrabalho.submetido);
    expect(historico.single.autorId, 'u-docente');
  });
}
