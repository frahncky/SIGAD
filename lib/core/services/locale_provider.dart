import 'package:flutter/widgets.dart';

/// Idioma escolhido pelo usuário. "Automático" segue o idioma do celular:
/// inglês se o aparelho estiver em inglês, português nos demais casos.
class LocaleProvider extends ChangeNotifier {
  LocaleProvider({String? idioma}) : _idioma = normalizar(idioma);

  static const automatico = 'Automático';
  static const portugues = 'Português';
  static const ingles = 'English';
  static const opcoes = [automatico, portugues, ingles];

  static const suportados = [Locale('pt', 'BR'), Locale('en')];

  /// Converte valores salvos (inclusive os antigos) para uma opção válida.
  /// O antigo "Português (Brasil)" era só o valor padrão e não tinha efeito,
  /// então passa a seguir o celular.
  static String normalizar(String? valor) =>
      opcoes.contains(valor) ? valor! : automatico;

  /// Escolhe entre os idiomas suportados a partir do idioma do aparelho.
  static Locale resolver(Locale? aparelho) =>
      aparelho?.languageCode == 'en' ? suportados[1] : suportados[0];

  String _idioma;

  String get idioma => _idioma;

  /// Nulo quando automático: o MaterialApp usa o idioma do aparelho.
  Locale? get locale => switch (_idioma) {
    portugues => suportados[0],
    ingles => suportados[1],
    _ => null,
  };

  void setIdioma(String idioma) {
    final next = normalizar(idioma);
    if (next == _idioma) return;
    _idioma = next;
    notifyListeners();
  }
}
