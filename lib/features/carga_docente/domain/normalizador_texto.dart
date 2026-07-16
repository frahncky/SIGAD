abstract final class NormalizadorTexto {
  static String paraComparacao(String valor) {
    return valor
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[áàãâä]'), 'a')
        .replaceAll(RegExp(r'[éèêë]'), 'e')
        .replaceAll(RegExp(r'[íìîï]'), 'i')
        .replaceAll(RegExp(r'[óòõôö]'), 'o')
        .replaceAll(RegExp(r'[úùûü]'), 'u')
        .replaceAll('ç', 'c')
        .replaceAll('ñ', 'n')
        .replaceAll(RegExp('[\u0300-\u036f]'), '')
        .replaceAll(RegExp(r'\s+'), ' ');
  }
}
