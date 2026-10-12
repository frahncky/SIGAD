import 'package:flutter/widgets.dart';

import '../app/routes/app_routes.dart';
import '../core/models/navigation_item.dart';
import '../core/models/user_role.dart';
import 'gen/app_localizations.dart';

export 'gen/app_localizations.dart';

extension L10nContext on BuildContext {
  /// Textos no idioma atual. Sem localizações configuradas (por exemplo,
  /// em testes de widget isolados), usa português.
  AppLocalizations get l10n =>
      Localizations.of<AppLocalizations>(this, AppLocalizations) ??
      lookupAppLocalizations(const Locale('pt'));
}

extension UserRoleL10n on UserRole {
  String nomeEm(AppLocalizations l10n) => switch (this) {
    UserRole.professor => l10n.perfilProfessor,
    UserRole.coordenador => l10n.perfilCoordenador,
    UserRole.servidorAdministrativo => l10n.perfilServidor,
    UserRole.chefeDepartamento => l10n.perfilChefe,
  };
}

/// Nome e descrição de um módulo do menu no idioma atual.
extension NavigationItemL10n on NavigationItem {
  String rotuloEm(AppLocalizations l10n) =>
      rotuloDaRota(route, l10n) ?? label;

  String? subtituloEm(AppLocalizations l10n) => switch (route) {
    AppRoutes.dashboard => l10n.navVisaoGeralSub,
    AppRoutes.batePapo => l10n.navBatePapoSub,
    AppRoutes.demandas => l10n.navDemandasSub,
    AppRoutes.professores => l10n.navProfessoresSub,
    AppRoutes.kanban => l10n.navTarefasSub,
    AppRoutes.aulasPraticas => l10n.navLaboratoriosSub,
    AppRoutes.cargaDocente => l10n.navCargaDocenteSub,
    AppRoutes.atividades => l10n.navAtividadesSub,
    AppRoutes.relatorios => l10n.navRelatoriosSub,
    AppRoutes.configuracoes => l10n.navConfiguracoesSub,
    _ => subtitle,
  };
}

/// Nome da tela de uma rota no idioma atual.
String? rotuloDaRota(String route, AppLocalizations l10n) => switch (route) {
  AppRoutes.dashboard => l10n.navVisaoGeral,
  AppRoutes.batePapo => l10n.navBatePapo,
  AppRoutes.demandas => l10n.navDemandas,
  AppRoutes.professores => l10n.navProfessores,
  AppRoutes.kanban => l10n.navTarefas,
  AppRoutes.aulasPraticas => l10n.navLaboratorios,
  AppRoutes.cargaDocente => l10n.navCargaDocente,
  AppRoutes.atividades => l10n.navAtividades,
  AppRoutes.relatorios => l10n.navRelatorios,
  AppRoutes.configuracoes => l10n.navConfiguracoes,
  AppRoutes.calendario => l10n.navCalendario,
  AppRoutes.notas => l10n.navAnotacoes,
  AppRoutes.mais => l10n.navMais,
  AppRoutes.mural => l10n.navMural,
  _ => null,
};
