import '../../../l10n/l10n.dart';
import '../domain/laboratorio_models.dart';
import '../domain/reserva_models.dart';
import '../domain/reserva_service.dart';

/// Textos do módulo de laboratórios que dependem de valores do domínio
/// (dias, turnos, meses e situações), no idioma atual.
extension LaboratorioL10n on AppLocalizations {
  /// 'Seg' → "Seg"/"Mon".
  String diaAbrev(String diaSemana) => switch (diaSemana) {
    'Seg' => diaSeg,
    'Ter' => diaTer,
    'Qua' => diaQua,
    'Qui' => diaQui,
    'Sex' => diaSex,
    _ => diaSemana,
  };

  /// 'Seg' → "segunda-feira"/"Monday".
  String diaCompleto(String diaSemana) => switch (diaSemana) {
    'Seg' => diaSegunda,
    'Ter' => diaTerca,
    'Qua' => diaQuarta,
    'Qui' => diaQuinta,
    'Sex' => diaSexta,
    _ => diaSemana,
  };

  String turno(Turno turno) => switch (turno) {
    Turno.matutino => turnoMatutino,
    Turno.vespertino => turnoVespertino,
    Turno.noturno => turnoNoturno,
  };

  String mes(int mes) => mesAbrev('$mes');

  String statusLaboratorio(StatusLaboratorio status) => switch (status) {
    StatusLaboratorio.operando => labOperando,
    StatusLaboratorio.manutencao => labEmManutencao,
    StatusLaboratorio.interditado => labInterditado,
  };

  String statusEquipamento(StatusEquipamento status) => switch (status) {
    StatusEquipamento.disponivel => labDisponivel,
    StatusEquipamento.emUso => labEmUso,
    StatusEquipamento.manutencao => labManutencao,
    StatusEquipamento.indisponivel => labIndisponivel,
  };

  /// "12/10".
  String dataCurta(DateTime data) =>
      '${data.day.toString().padLeft(2, '0')}/'
      '${data.month.toString().padLeft(2, '0')}';

  /// "segunda-feira, 12/10/2026".
  String dataPorExtenso(DateTime data) =>
      '${diaCompleto(ReservaService.diaSemanaDe(data) ?? '')}, '
      '${dataCurta(data)}/${data.year}';
}
