import 'package:flutter_test/flutter_test.dart';
import 'package:sigad/features/aulas_praticas/domain/feriado_models.dart';
import 'package:sigad/features/aulas_praticas/domain/feriado_service.dart';

void main() {
  group('FeriadoService', () {
    test('inclui feriados nacional, estadual e municipais aprovados', () {
      expect(
        FeriadoService.feriadoEm(DateTime(2026, 7, 28))?.abrangencia,
        AbrangenciaFeriado.estadual,
      );
      expect(
        FeriadoService.feriadoEm(DateTime(2026, 6, 29))?.abrangencia,
        AbrangenciaFeriado.municipal,
      );
      expect(
        FeriadoService.feriadoEm(DateTime(2026, 9, 8))?.nome,
        'Aniversário de São Luís',
      );
      expect(
        FeriadoService.feriadoEm(DateTime(2026, 12, 8))?.abrangencia,
        AbrangenciaFeriado.municipal,
      );
      expect(
        FeriadoService.feriadoEm(DateTime(2026, 11, 20))?.abrangencia,
        AbrangenciaFeriado.nacional,
      );
    });

    test('calcula Paixão de Cristo e não inclui ponto facultativo', () {
      expect(
        FeriadoService.feriadoEm(DateTime(2026, 4, 3))?.nome,
        'Paixão de Cristo',
      );
      expect(FeriadoService.feriadoEm(DateTime(2026, 2, 17)), isNull);
      expect(FeriadoService.avisoEscopo, contains('pontos facultativos'));
      expect(
        FeriadoService.avisoEscopo,
        contains('Feriados locais validados para 2026'),
      );
    });

    test('limita dados locais e Paixão a 2026', () {
      expect(FeriadoService.feriadoEm(DateTime(2025, 7, 28)), isNull);
      expect(FeriadoService.feriadoEm(DateTime(2027, 6, 29)), isNull);
      expect(FeriadoService.feriadoEm(DateTime(2025, 4, 18)), isNull);
      expect(
        FeriadoService.feriadoEm(DateTime(2025, 9, 7))?.abrangencia,
        AbrangenciaFeriado.nacional,
      );
      expect(FeriadoService.feriadoEm(DateTime(2023, 11, 20)), isNull);
      expect(
        FeriadoService.feriadoEm(DateTime(2024, 11, 20))?.abrangencia,
        AbrangenciaFeriado.nacional,
      );
    });
  });
}
