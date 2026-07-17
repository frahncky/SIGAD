import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sigad/features/aulas_praticas/data/laboratorio_repository.dart';
import 'package:sigad/features/aulas_praticas/domain/laboratorio_models.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('LaboratorioRepository', () {
    late LaboratorioRepository repository;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      repository = LaboratorioRepository(storageKey: 'test_sigad_laboratorios');
    });

    test('carrega catálogo inicial quando não há dados persistidos', () async {
      final laboratorios = await repository.load();

      expect(laboratorios, isNotEmpty);
      expect(laboratorios.first.equipamentos, isNotEmpty);
    });

    test('preserva equipamentos, manutenção e ocorrências', () async {
      final agora = DateTime(2026, 7, 17, 10, 30);
      final laboratorio = Laboratorio(
        id: 'LAB-TESTE',
        nome: 'Lab Teste',
        localizacao: 'Bloco A',
        capacidade: 20,
        responsavelTecnico: 'Ana',
        status: StatusLaboratorio.manutencao,
        equipamentos: const [
          EquipamentoLaboratorio(
            id: 'EQ-1',
            nome: 'Osciloscópio',
            quantidade: 2,
            status: StatusEquipamento.disponivel,
          ),
        ],
        ocorrencias: [
          OcorrenciaLaboratorio(
            id: 'OCO-1',
            titulo: 'Bancada sem energia',
            descricao: 'Bancada 2',
            criadaEm: agora,
          ),
        ],
        manutencoes: [
          ManutencaoLaboratorio(
            id: 'MAN-1',
            descricao: 'Revisão elétrica',
            inicio: agora,
          ),
        ],
      );

      await repository.save([laboratorio]);
      final carregados = await repository.load();

      expect(carregados, hasLength(1));
      expect(carregados.single.status, StatusLaboratorio.manutencao);
      expect(carregados.single.equipamentosDisponiveis, 2);
      expect(carregados.single.ocorrenciasAtivas, 1);
      expect(carregados.single.manutencoes, hasLength(1));
    });
  });
}
