import 'package:flutter_test/flutter_test.dart';
import 'package:sigad/features/atividades/domain/atividade_models.dart';
import 'package:sigad/features/atividades/domain/atividades_service.dart';

void main() {
  group('AtividadesService', () {
    test('filtra por busca e status', () {
      final atividades = [
        const Atividade(
          id: '#ATV-001',
          titulo: 'Treinamento',
          descricao: 'Capacitar equipe',
          data: '01/01/2026',
          responsavel: 'RH',
          status: 'Pendente',
        ),
        const Atividade(
          id: '#ATV-002',
          titulo: 'Auditoria',
          descricao: 'Verificar conformidade',
          data: '02/01/2026',
          responsavel: 'Auditoria',
          status: 'Concluída',
        ),
      ];

      final filtradas = AtividadesService.filtrarAtividades(
        atividades: atividades,
        busca: 'trei',
        filtro: 'Pendente',
      );

      expect(filtradas, hasLength(1));
      expect(filtradas.first.id, '#ATV-001');
    });

    test('valida atividade e gera próximo id', () {
      expect(
        AtividadesService.validarAtividade(titulo: '', descricao: 'x'),
        'Informe o título da atividade',
      );
      expect(
        AtividadesService.gerarProximoIdAtividade(const [
          Atividade(
            id: '#ATV-009',
            titulo: 'x',
            descricao: 'x',
            data: '01/01/2026',
            responsavel: 'TI',
            status: 'Pendente',
          ),
        ]),
        '#ATV-010',
      );
    });
  });
}
