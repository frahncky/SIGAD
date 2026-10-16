import '../../../l10n/l10n.dart';

/// Status, tipos e últimas ações dos relatórios no idioma atual.
///
/// Os valores são gravados em português; aqui só muda a exibição.
extension RelatoriosL10n on AppLocalizations {
  String opcaoRelatorio(String valor) => switch (valor) {
    'Todos' => relStatusTodos,
    'Publicado' => relStatusPublicado,
    'Em revisão' => relEmRevisao,
    'Agendado' => relStatusAgendado,
    'Disponível' => relStatusDisponivel,
    'Análise Geral' => relTipoAnaliseGeral,
    'Recursos Humanos' => relTipoRecursosHumanos,
    'Desempenho' => relTipoDesempenho,
    'Infraestrutura' => relTipoInfraestrutura,
    'Conformidade' => relTipoConformidade,
    'PDF baixado agora' => relPdfBaixadoAgora,
    'Compartilhado agora' => relCompartilhadoAgora,
    _ => valor,
  };
}
