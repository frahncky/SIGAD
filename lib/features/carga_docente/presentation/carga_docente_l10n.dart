import '../../../l10n/l10n.dart';
import '../domain/docente_models.dart';

/// Textos da carga docente que dependem de valores do domínio, no idioma
/// atual. Dias, modalidades e mensagens continuam gravados em português;
/// aqui só muda a exibição.
extension CargaDocenteL10n on AppLocalizations {
  String regime(RegimeTrabalhoEbtt regime) => switch (regime) {
    RegimeTrabalhoEbtt.vinteHoras => cdRegime20h,
    RegimeTrabalhoEbtt.quarentaHoras => cdRegime40h,
    RegimeTrabalhoEbtt.dedicacaoExclusiva => cdRegimeDe,
  };

  /// 'Segunda' → "Segunda"/"Monday".
  String diaDocente(String dia) => switch (dia) {
    'Segunda' => cdSegunda,
    'Terça' => cdTerca,
    'Quarta' => cdQuarta,
    'Quinta' => cdQuinta,
    'Sexta' => cdSexta,
    _ => dia,
  };

  String modalidade(String modalidade) => switch (modalidade) {
    'Integral' => cdModalidadeIntegral,
    'Concomitante' => cdModalidadeConcomitante,
    'Subsequente' => cdModalidadeSubsequente,
    'EJA' => cdModalidadeEja,
    'Superior' => cdModalidadeSuperior,
    _ => modalidade,
  };

  /// Mensagens de validação de `DocenteFormService`.
  String erroDocente(String erro) {
    final fixas = {
      'Informe o nome do docente': cdInformeNome,
      'Informe o departamento': cdInformeDepartamento,
      'Informe uma carga horária máxima válida': cdInformeCargaMaxima,
      'Adicione pelo menos uma disciplina': cdAdicioneDisciplina,
      'Informe o nome da disciplina.': cdInformeNomeDisciplina,
      'Disciplina já adicionada.': cdDisciplinaJaAdicionada,
      'Informe horário de início e fim.': cdInformeInicioFim,
      'Use o formato HH:MM para os horários.': cdFormatoHorario,
      'O horário de fim deve ser posterior ao de início.': cdFimPosterior,
    };
    final fixa = fixas[erro];
    if (fixa != null) return fixa;

    final regime = RegExp(
      r'^O regime (.+) permite até (\d+)h semanais\.$',
    ).firstMatch(erro);
    if (regime != null) {
      return cdRegimePermite(regime.group(1)!, regime.group(2)!);
    }
    final excede = RegExp(
      r'^A distribuição semanal cadastrada \((\d+)h\) excede a carga máxima '
      r'do docente \((\d+)h\)\.$',
    ).firstMatch(erro);
    if (excede != null) {
      return cdDistribuicaoExcede(excede.group(1)!, excede.group(2)!);
    }
    final conflito = RegExp(
      r'^Já existe horário cadastrado em conflito para (.+)\.$',
    ).firstMatch(erro);
    if (conflito != null) {
      return cdConflitoHorario(diaDocente(conflito.group(1)!));
    }
    return erro;
  }
}
