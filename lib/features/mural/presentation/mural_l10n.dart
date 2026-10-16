import '../../../l10n/l10n.dart';
import '../domain/mural_models.dart';

/// Textos do mural que dependem de valores do domínio, no idioma atual.
extension MuralL10n on AppLocalizations {
  String modeloAviso(ModeloAviso modelo) => switch (modelo) {
    ModeloAviso.informativo => muralModeloInformativo,
    ModeloAviso.importante => muralModeloImportante,
    ModeloAviso.evento => muralModeloEvento,
    ModeloAviso.lembrete => muralModeloLembrete,
  };

  String periodicidadeFrase(PeriodicidadeFrase periodicidade) =>
      switch (periodicidade) {
        PeriodicidadeFrase.diaria => muralPeriodoDiaria,
        PeriodicidadeFrase.semanal => muralPeriodoSemanal,
        PeriodicidadeFrase.quinzenal => muralPeriodoQuinzenal,
        PeriodicidadeFrase.mensal => muralPeriodoMensal,
      };
}
