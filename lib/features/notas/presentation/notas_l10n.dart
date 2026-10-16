import '../../../l10n/l10n.dart';

/// Nome de uma categoria de anotação no idioma atual.
///
/// As categorias são gravadas em português; aqui só muda a exibição.
extension NotasL10n on AppLocalizations {
  String categoriaNota(String categoria) => switch (categoria) {
    'Geral' => notaGeral,
    'Reuniões' => notaReunioes,
    'Laboratórios' => navLaboratorios,
    'Planejamento' => notaPlanejamento,
    'Carga horária' => notaCargaHoraria,
    'Eventos' => notaEventos,
    'Todas' => notaTodas,
    'Mais' => navMais,
    _ => categoria,
  };
}
