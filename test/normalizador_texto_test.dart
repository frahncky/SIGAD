import 'package:flutter_test/flutter_test.dart';
import 'package:sigad/features/carga_docente/domain/normalizador_texto.dart';

void main() {
  group('NormalizadorTexto', () {
    test('ignora caixa, acentos precompostos e espaços repetidos', () {
      expect(
        NormalizadorTexto.paraComparacao('  PROGRAMAÇÃO   E   AUTOMAÇÃO  '),
        'programacao e automacao',
      );
    });

    test('remove marcas Unicode combinantes', () {
      expect(
        NormalizadorTexto.paraComparacao('Programac\u0327a\u0303o'),
        'programacao',
      );
    });
  });
}
