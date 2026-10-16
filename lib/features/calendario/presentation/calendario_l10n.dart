import '../../../l10n/l10n.dart';

/// Textos e formatos do calendário que dependem do idioma atual.
extension CalendarioL10n on AppLocalizations {
  /// Locale usado pelo `intl` para nomes de meses e dias da semana.
  String get localeDatas => localeName == 'pt' ? 'pt_BR' : localeName;

  /// Os filtros e categorias são guardados em português; aqui só muda a
  /// exibição.
  String opcaoCalendario(String valor) => switch (valor) {
    'Todos' => calTodos,
    'Reunião' => calReuniao,
    'Laboratório' => calLaboratorio,
    'Comunicação' => calComunicacao,
    _ => valor,
  };
}
