import '../../../l10n/l10n.dart';

/// Status, prioridades e ordenações das demandas no idioma atual.
///
/// Os valores são gravados em português; aqui só muda a exibição.
extension DemandasL10n on AppLocalizations {
  String opcaoDemanda(String valor) => switch (valor) {
    'Todas' => demTodas,
    'Novo' => demStatusNovo,
    'Em andamento' => demStatusEmAndamento,
    'Aguardando' => demStatusAguardando,
    'Revisão' => demStatusRevisao,
    'Concluído' => demStatusConcluido,
    'Alta' => demPrioridadeAlta,
    'Média' => demPrioridadeMedia,
    'Baixa' => demPrioridadeBaixa,
    'Prazo mais próximo' => demOrdemPrazo,
    'Prioridade' => demPrioridade,
    'Recém-criadas' => demOrdemRecentes,
    _ => valor,
  };

  /// Mensagens de validação de `DemandasService.validarDemanda`.
  String erroDemanda(String erro) => switch (erro) {
    'Informe o título da demanda' => demInformeTitulo,
    'Informe a descrição da demanda' => demInformeDescricao,
    _ => erro,
  };
}
