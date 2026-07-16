import 'package:flutter_test/flutter_test.dart';
import 'package:sigad/core/models/user_role.dart';
import 'package:sigad/features/dashboard/presentation/dashboard_role_profile.dart';

void main() {
  group('RoleProfile', () {
    test('retorna perfil do professor com metricas e prioridades', () {
      final profile = RoleProfile.fromRole(UserRole.professor);

      expect(profile.title, 'Perfil Professor');
      expect(profile.metrics, isNotEmpty);
      expect(profile.priorities, isNotEmpty);
    });

    test('retorna perfil default quando role e nulo', () {
      final profile = RoleProfile.fromRole(null);

      expect(profile.title, 'Visão geral do SIGAD');
      expect(profile.focus, isNotEmpty);
    });
  });
}
