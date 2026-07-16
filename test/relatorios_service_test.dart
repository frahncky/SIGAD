import 'package:flutter_test/flutter_test.dart';
import 'package:sigad/features/relatorios/domain/relatorio_models.dart';
import 'package:sigad/features/relatorios/domain/relatorios_service.dart';

void main() {
  group('RelatoriosService', () {
    test('filtra por busca e status', () {
      final relatorios = [
        const Relatorio(
          id: '1',
          titulo: 'Desempenho',
          descricao: 'A',
          tipo: 'Mensal',
          data: 'Mar/2026',
          autor: 'Coordenação',
          status: 'Publicado',
          downloads: 1,
          compartilhamentos: 1,
        ),
        const Relatorio(
          id: '2',
          titulo: 'Financeiro',
          descricao: 'B',
          tipo: 'Mensal',
          data: 'Mar/2026',
          autor: 'Coordenação',
          status: 'Em revisão',
          downloads: 1,
          compartilhamentos: 1,
        ),
      ];

      final filtrados = RelatoriosService.filtrarRelatorios(
        relatorios: relatorios,
        busca: 'des',
        filtroStatus: 'Publicado',
      );

      expect(filtrados, hasLength(1));
      expect(filtrados.first.id, '1');
    });
  });
}
