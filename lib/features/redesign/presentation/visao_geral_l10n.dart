import '../../../l10n/l10n.dart';

/// Opções de filtros e situações das visões gerais no idioma atual.
///
/// Os valores continuam em português nos dados de demonstração; aqui só muda
/// a exibição.
extension VisaoGeralL10n on AppLocalizations {
  String opcaoVisaoGeral(String valor) => switch (valor) {
    'Todos' => vgOpTodos,
    'Todas' => vgOpTodas,
    'Regular' => vgOpRegular,
    'Atenção' => vgOpAtencao,
    'Excedida' => vgOpExcedida,
    'Ativo' => vgOpAtivo,
    'Afastamento' => vgOpAfastamento,
    'Em análise' => vgOpEmAnalise,
    'Em andamento' => vgOpEmAndamento,
    'Aguardando' => vgOpAguardando,
    'Atrasada' => vgOpAtrasada,
    'A fazer' => vgOpAFazer,
    'Concluído' => vgOpConcluido,
    'Pendente' => vgOpPendente,
    'Em progresso' => vgOpEmProgresso,
    'Concluída' => vgOpConcluida,
    'Agenda semanal' => vgOpAgendaSemanal,
    'Calendário mensal' => vgOpCalendarioMensal,
    'Ocupação' => vgOpOcupacao,
    'Acadêmico' => vgOpAcademico,
    'Infraestrutura' => relTipoInfraestrutura,
    'Gestão' => vgOpGestao,
    'Produtividade' => vgOpProdutividade,
    'Alta' => demPrioridadeAlta,
    'Média' => demPrioridadeMedia,
    'Baixa' => demPrioridadeBaixa,
    'Ontem' => vgOntem,
    'Atualizado hoje' => vgAtualizadoHoje,
    'Atualizado ontem' => vgAtualizadoOntem,
    _ when valor.startsWith('Atualizado em ') => vgAtualizadoEm(
      valor.substring('Atualizado em '.length),
    ),
    _ => valor,
  };
}
