import 'package:flutter_test/flutter_test.dart';
import 'package:sigad/core/config/app_runtime_config.dart';

void main() {
  group('AppRuntimeConfig.resolveDemoAccess', () {
    test('permite demo somente nos ambientes explicitamente autorizados', () {
      for (final flavor in ['dev', 'test', 'staging']) {
        expect(
          AppRuntimeConfig.resolveDemoAccess(
            flavor: flavor,
            demoAccessRequested: true,
          ),
          isTrue,
          reason: 'O ambiente $flavor deveria permitir demo.',
        );
      }
    });

    test('trata caixa e espaços nos ambientes autorizados', () {
      for (final flavor in ['DEV', ' Test ', 'StAgInG']) {
        expect(
          AppRuntimeConfig.resolveDemoAccess(
            flavor: flavor,
            demoAccessRequested: true,
          ),
          isTrue,
          reason: 'O ambiente $flavor deveria permitir demo.',
        );
      }
    });

    test('bloqueia produção mesmo quando demo foi solicitado', () {
      for (final flavor in ['prod', 'PROD', ' Prod ']) {
        expect(
          AppRuntimeConfig.resolveDemoAccess(
            flavor: flavor,
            demoAccessRequested: true,
          ),
          isFalse,
          reason: 'O ambiente $flavor nunca deve permitir demo.',
        );
      }
    });

    test(
      'falha fechada para flavors ausentes, desconhecidos ou incorretos',
      () {
        for (final flavor in ['', 'prd', 'production', 'qa']) {
          expect(
            AppRuntimeConfig.resolveDemoAccess(
              flavor: flavor,
              demoAccessRequested: true,
            ),
            isFalse,
            reason: 'O ambiente $flavor deve falhar fechado.',
          );
        }
      },
    );

    test('respeita a desativação explícita em ambientes não produtivos', () {
      for (final flavor in ['dev', 'test', 'staging']) {
        expect(
          AppRuntimeConfig.resolveDemoAccess(
            flavor: flavor,
            demoAccessRequested: false,
          ),
          isFalse,
        );
      }
    });
  });
}
