import 'package:flutter_test/flutter_test.dart';
import 'package:sigad/features/configuracoes/domain/configuracoes_service.dart';

void main() {
  group('ConfiguracoesService', () {
    test('valida perfil, email e senha', () {
      expect(
        ConfiguracoesService.validarPerfil(nome: '', cargo: 'Coordenação'),
        'Preencha nome e cargo',
      );

      expect(
        ConfiguracoesService.validarEmail('email-invalido'),
        'Informe um email valido',
      );

      expect(
        ConfiguracoesService.validarAlteracaoSenha(
          senhaAtual: 'abc123',
          novaSenha: '123',
          confirmarSenha: '123',
        ),
        'A nova senha deve ter ao menos 6 caracteres',
      );
    });

    test('datas seguem padrão dd/mm/aaaa', () {
      final data = ConfiguracoesService.dataAtual();
      final dataFutura = ConfiguracoesService.dataFutura(1);


      expect(data.split('/'), hasLength(3));
      expect(dataFutura.split('/'), hasLength(3));
      expect(ConfiguracoesService.dataHoraAtual().contains(' as '), isTrue);
    });
  });
}
