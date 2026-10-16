import '../../../l10n/l10n.dart';

/// Colunas, prioridades e validações do quadro de tarefas no idioma atual.
///
/// Os valores são gravados em português; aqui só muda a exibição.
extension KanbanL10n on AppLocalizations {
  String opcaoKanban(String valor) => switch (valor) {
    'Backlog' => tarColunaBacklog,
    'Em Progresso' => tarColunaEmProgresso,
    'Em Revisão' => tarColunaEmRevisao,
    'Concluído' => tarColunaConcluido,
    'Alta' => demPrioridadeAlta,
    'Média' => demPrioridadeMedia,
    'Baixa' => demPrioridadeBaixa,
    _ => valor,
  };

  /// Mensagens de `KanbanService.validateTitulo`.
  String erroKanban(String erro) => switch (erro) {
    'Informe o título do card' => tarInformeTitulo,
    _ => erro,
  };
}
