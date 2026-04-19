import 'package:flutter_test/flutter_test.dart';
import 'package:sigad/features/configuracoes/domain/configuracoes_models.dart';
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
        'Informe um email válido',
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
      expect(ConfiguracoesService.dataHoraAtual().contains(' às '), isTrue);
    });

    test('valida antecedência de lembrete da disciplina', () {
      expect(ConfiguracoesService.validarAntecedenciaDisciplina(15), isNull);
      expect(
        ConfiguracoesService.validarAntecedenciaDisciplina(7),
        'Selecione uma antecedência válida',
      );
    });

    test('adiciona convite recebido na agenda', () {
      final base = ConfiguracoesService.defaultData();
      const convite = CompromissoAgenda(
        id: 'c1',
        titulo: 'Reunião de alinhamento',
        descricao: 'Alinhamento semanal',
        inicio: '20/04/2026 10:00',
        local: 'Sala 2',
        origem: 'Convite de reunião',
        destinatarioUserId: 'u-prof',
      );

      final atualizado = ConfiguracoesService.adicionarConviteNaAgenda(
        data: base,
        convite: convite,
      );

      expect(atualizado.agendaCompromissos, hasLength(1));
      expect(atualizado.agendaCompromissos.first.titulo, 'Reunião de alinhamento');
    });
  });
}
