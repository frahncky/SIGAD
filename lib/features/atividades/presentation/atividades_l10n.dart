import '../../../l10n/l10n.dart';

/// Status e validações das atividades no idioma atual.
///
/// Os valores são gravados em português; aqui só muda a exibição.
extension AtividadesL10n on AppLocalizations {
  String statusAtividade(String status) => switch (status) {
    'Concluída' => atvStatusConcluida,
    'Em progresso' => atvStatusEmProgresso,
    'Agendada' => atvStatusAgendada,
    'Pendente' => atvStatusPendente,
    _ => status,
  };

  /// Mensagens de `AtividadesService.validarAtividade`.
  String erroAtividade(String erro) => switch (erro) {
    'Informe o título da atividade' => atvInformeTitulo,
    'Informe a descrição da atividade' => atvInformeDescricao,
    _ => erro,
  };
}
