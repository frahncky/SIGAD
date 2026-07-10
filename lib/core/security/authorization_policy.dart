import '../models/user_role.dart';

abstract final class AuthorizationPolicy {
  static bool canManageDemandas(UserRole? role) {
    return role == UserRole.coordenador || role == UserRole.chefeDepartamento;
  }

  static bool canAccessRelatorios(UserRole? role) {
    return role == UserRole.coordenador ||
        role == UserRole.servidorAdministrativo ||
        role == UserRole.chefeDepartamento;
  }

  static bool canManageConfiguracoes(UserRole? role) {
    return role == UserRole.chefeDepartamento;
  }

  static bool canAccessConfiguracoes(UserRole? role) {
    return role != null;
  }
}
