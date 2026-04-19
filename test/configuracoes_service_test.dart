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
        inicioIso: '2026-04-20T10:00:00.000',
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

    test('atualiza status do convite na agenda', () {
      final base = ConfiguracoesService.defaultData().copyWith(
        agendaCompromissos: const [
          CompromissoAgenda(
            id: 'c-status',
            titulo: 'Reunião',
            descricao: 'x',
            inicio: 'Hoje',
            inicioIso: '2026-04-19T10:00:00.000',
            local: 'Sala 1',
            origem: 'Convite',
            destinatarioUserId: 'u1',
          ),
        ],
      );

      final atualizado = ConfiguracoesService.atualizarStatusConvite(
        data: base,
        compromissoId: 'c-status',
        status: StatusConviteAgenda.aceito,
      );

      expect(atualizado.agendaCompromissos.first.statusConvite, StatusConviteAgenda.aceito);
    });

    test('filtra agenda por período da semana', () {
      final compromissos = [
        const CompromissoAgenda(
          id: 'h1',
          titulo: 'Hoje',
          descricao: 'x',
          inicio: 'Hoje',
          inicioIso: '2026-04-19T10:00:00.000',
          local: 'Sala 1',
          origem: 'Convite',
          destinatarioUserId: 'u1',
        ),
        const CompromissoAgenda(
          id: 'f1',
          titulo: 'Futuro distante',
          descricao: 'x',
          inicio: 'Futuro',
          inicioIso: '2026-05-10T10:00:00.000',
          local: 'Sala 2',
          origem: 'Convite',
          destinatarioUserId: 'u1',
        ),
      ];

      final semana = ConfiguracoesService.filtrarAgendaPorPeriodo(
        compromissos: compromissos,
        agora: DateTime(2026, 4, 19, 8, 0),
        periodo: 'Semana',
      );

      expect(semana, hasLength(1));
      expect(semana.first.id, 'h1');
    });

    test('retorna lembretes pendentes conforme antecedência configurada', () {
      final data = ConfiguracoesService.defaultData().copyWith(
        antecedenciaNotificacaoMinutos: 30,
        agendaCompromissos: const [
          CompromissoAgenda(
            id: 'r1',
            titulo: 'Aula de algoritmos',
            descricao: 'Turma A',
            inicio: 'Hoje 10:20',
            inicioIso: '2026-04-19T10:20:00.000',
            local: 'Lab 3',
            origem: 'Disciplina',
            destinatarioUserId: 'u-prof',
          ),
        ],
      );

      final lembretes = ConfiguracoesService.lembretesPendentesProfessor(
        data: data,
        userId: 'u-prof',
        agora: DateTime(2026, 4, 19, 10, 0),
      );

      expect(lembretes, hasLength(1));
      expect(lembretes.first.id, 'r1');
    });
  });
}
