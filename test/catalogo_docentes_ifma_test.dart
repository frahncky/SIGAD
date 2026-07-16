import 'package:flutter_test/flutter_test.dart';
import 'package:sigad/features/carga_docente/data/catalogo_docentes_ifma.dart';

void main() {
  test('catálogo oficial possui nomes únicos e áreas da comissão', () {
    final nomes = CatalogoDocentesIfma.docentes
        .map((item) => CatalogoDocentesIfma.normalizar(item.nome))
        .toSet();

    expect(CatalogoDocentesIfma.docentes, hasLength(22));
    expect(nomes, hasLength(22));
    expect(
      CatalogoDocentesIfma.buscar('telecomunicações').map((item) => item.nome),
      containsAll([
        'Almir Souza e Silva Neto',
        'Walter da Silva Castro',
        'Bruno Valério Everton Costa',
      ]),
    );
  });

  test('usa aba oficial e não mantém nomes removidos do rascunho', () {
    final nomes = CatalogoDocentesIfma.docentes.map((item) => item.nome);

    expect(nomes, isNot(contains('Claudio Leao Torres')));
    expect(nomes, isNot(contains('Rodrigo Jose Albuquerque Frazao')));
  });
}
