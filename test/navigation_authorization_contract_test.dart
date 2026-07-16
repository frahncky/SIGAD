import 'package:flutter_test/flutter_test.dart';
import 'package:sigad/app/routes/app_routes.dart';
import 'package:sigad/core/models/user_role.dart';
import 'package:sigad/core/navigation/navigation_items.dart';

void main() {
  const expectedRoutes = <String>{
    AppRoutes.dashboard,
    AppRoutes.batePapo,
    AppRoutes.demandas,
    AppRoutes.kanban,
    AppRoutes.aulasPraticas,
    AppRoutes.cargaDocente,
    AppRoutes.atividades,
    AppRoutes.calendario,
    AppRoutes.notas,
    AppRoutes.relatorios,
    AppRoutes.configuracoes,
  };

  const expectedByRole = <UserRole, Set<String>>{
    UserRole.professor: {
      AppRoutes.dashboard,
      AppRoutes.batePapo,
      AppRoutes.kanban,
      AppRoutes.aulasPraticas,
      AppRoutes.cargaDocente,
      AppRoutes.atividades,
      AppRoutes.calendario,
      AppRoutes.notas,
      AppRoutes.configuracoes,
    },
    UserRole.coordenador: {
      AppRoutes.dashboard,
      AppRoutes.batePapo,
      AppRoutes.demandas,
      AppRoutes.kanban,
      AppRoutes.aulasPraticas,
      AppRoutes.cargaDocente,
      AppRoutes.atividades,
      AppRoutes.calendario,
      AppRoutes.notas,
      AppRoutes.relatorios,
      AppRoutes.configuracoes,
    },
    UserRole.servidorAdministrativo: {
      AppRoutes.dashboard,
      AppRoutes.batePapo,
      AppRoutes.kanban,
      AppRoutes.atividades,
      AppRoutes.calendario,
      AppRoutes.notas,
      AppRoutes.relatorios,
      AppRoutes.configuracoes,
    },
    UserRole.chefeDepartamento: expectedRoutes,
  };

  test(
    'rotas de navegação são únicas e cobrem todos os módulos protegidos',
    () {
      final routes = kNavigationItems.map((item) => item.route).toList();

      expect(routes.toSet(), hasLength(routes.length));
      expect(routes.toSet(), expectedRoutes);
      expect(routes, isNot(contains(AppRoutes.professores)));
    },
  );

  for (final entry in expectedByRole.entries) {
    test(
      'matriz de autorização permanece explícita para ${entry.key.name}',
      () {
        final actual = kNavigationItems
            .where((item) => item.isAvailableFor(entry.key))
            .map((item) => item.route)
            .toSet();

        expect(actual, entry.value);
      },
    );
  }
}
