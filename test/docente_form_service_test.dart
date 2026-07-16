import 'package:flutter_test/flutter_test.dart';
import 'package:sigad/features/carga_docente/domain/docente_form_service.dart';
import 'package:sigad/features/carga_docente/domain/docente_models.dart';

void main() {
  group('DocenteFormService', () {
    test('valida docente com campos obrigatórios', () {
      expect(
        DocenteFormService.validateDocente(
          nome: '',
          email: 'docente@ifma.edu.br',
          departamento: 'Computação',
          cargaMaxima: '20',
          disciplinas: const ['Algoritmos'],
          regimeTrabalho: RegimeTrabalhoEbtt.vinteHoras,
          horarios: const [],
        ),
        'Informe o nome do docente',
      );

      expect(
        DocenteFormService.validateDocente(
          nome: 'Prof. Teste',
          email: 'docente@ifma.edu.br',
          departamento: 'Computação',
          cargaMaxima: '0',
          disciplinas: const ['Algoritmos'],
          regimeTrabalho: RegimeTrabalhoEbtt.vinteHoras,
          horarios: const [],
        ),
        'Informe uma carga horária máxima válida',
      );
    });

    test('valida email de acesso vazio, inválido e válido', () {
      expect(
        DocenteFormService.validateEmail('  '),
        'Informe o email de acesso',
      );
      expect(
        DocenteFormService.validateEmail('docente@ifma'),
        'Informe um email de acesso válido',
      );
      expect(DocenteFormService.validateEmail(' DOCENTE@IFMA.EDU.BR '), isNull);
    });

    test('identifica email duplicado e ignora o próprio docente', () {
      const docentes = [
        Docente(
          id: '#DOC-EMAIL-1',
          nome: 'Docente existente',
          userEmail: 'docente@ifma.edu.br',
          departamento: 'Computação',
          cargaHoraria: 8,
          cargaMaxima: 20,
          disciplinas: ['Algoritmos'],
        ),
      ];

      expect(
        DocenteFormService.emailJaCadastrado(
          email: ' DOCENTE@IFMA.EDU.BR ',
          docentes: docentes,
        ),
        isTrue,
      );
      expect(
        DocenteFormService.emailJaCadastrado(
          email: 'docente@ifma.edu.br',
          docentes: docentes,
          ignorarDocenteId: '#DOC-EMAIL-1',
        ),
        isFalse,
      );
    });

    test('restringe carga máxima ao regime EBTT e à distribuição cadastrada', () {
      expect(
        DocenteFormService.validateDocente(
          nome: 'Prof. Teste',
          email: 'docente@ifma.edu.br',
          departamento: 'Computação',
          cargaMaxima: '40',
          disciplinas: const ['Algoritmos'],
          regimeTrabalho: RegimeTrabalhoEbtt.vinteHoras,
          horarios: const [],
        ),
        'O regime 20h permite até 20h semanais.',
      );

      expect(
        DocenteFormService.validateDocente(
          nome: 'Prof. Teste',
          email: 'docente@ifma.edu.br',
          departamento: 'Computação',
          cargaMaxima: '3',
          disciplinas: const ['Algoritmos'],
          regimeTrabalho: RegimeTrabalhoEbtt.vinteHoras,
          horarios: const [
            HorarioAula(
              diaSemana: 'Segunda',
              inicio: '08:00',
              fim: '09:40',
              cargaHoraria: '4h/sem · 60h',
            ),
          ],
        ),
        'A distribuição semanal cadastrada (4h) excede a carga máxima do docente (3h).',
      );
    });

    test('normaliza email e gera userId na criação', () {
      final docente = DocenteFormService.createDocente(
        id: '#DOC-010',
        nome: ' Profa. Teste ',
        email: 'PROF.TESTE@SIGAD.BR ',
        departamento: ' Laboratório ',
        cargaMaxima: '20',
        disciplinas: const ['Prática I'],
        regimeTrabalho: RegimeTrabalhoEbtt.vinteHoras,
        horarios: const [
          HorarioAula(diaSemana: 'Segunda', inicio: '08:00', fim: '09:40'),
        ],
      );

      expect(docente.nome, 'Profa. Teste');
      expect(docente.departamento, 'Laboratório');
      expect(docente.userEmail, 'prof.teste@sigad.br');
      expect(docente.userId, 'user_email_prof.teste@sigad.br');
      expect(docente.cargaHoraria, 2);
    });

    test('atualiza docente preservando id e recalculando carga', () {
      const original = Docente(
        id: '#DOC-011',
        nome: 'Prof. Original',
        departamento: 'DSI',
        cargaHoraria: 4,
        cargaMaxima: 20,
        disciplinas: ['Banco de Dados'],
        regimeTrabalho: RegimeTrabalhoEbtt.vinteHoras,
      );

      final atualizado = DocenteFormService.updateDocente(
        docente: original,
        nome: 'Prof. Atualizado',
        email: 'novo@sigad.br',
        departamento: 'Redes',
        cargaMaxima: '16',
        disciplinas: const ['Redes I', 'Redes II'],
        regimeTrabalho: RegimeTrabalhoEbtt.vinteHoras,
        horarios: const [
          HorarioAula(diaSemana: 'Terça', inicio: '10:00', fim: '11:40'),
          HorarioAula(diaSemana: 'Quinta', inicio: '10:00', fim: '11:40'),
        ],
      );

      expect(atualizado.id, '#DOC-011');
      expect(atualizado.nome, 'Prof. Atualizado');
      expect(atualizado.departamento, 'Redes');
      expect(atualizado.userEmail, 'novo@sigad.br');
      expect(atualizado.cargaHoraria, 4);
      expect(atualizado.cargaMaxima, 16);
      expect(atualizado.disciplinas, ['Redes I', 'Redes II']);
    });

    test('valida disciplina e horário', () {
      expect(
        DocenteFormService.validateDisciplina(
          disciplina: ' ',
          disciplinasExistentes: const [],
        ),
        'Informe o nome da disciplina.',
      );

      expect(
        DocenteFormService.validateDisciplina(
          disciplina: 'Algoritmos',
          disciplinasExistentes: const ['Algoritmos'],
        ),
        'Disciplina já adicionada.',
      );

      expect(
        DocenteFormService.validateDisciplina(
          disciplina: 'programacao i',
          disciplinasExistentes: const ['Programação I'],
        ),
        'Disciplina já adicionada.',
      );

      expect(
        DocenteFormService.validateHorario(
          diaSemana: 'Segunda',
          inicio: '8:00',
          fim: '09:40',
        ),
        'Use o formato HH:MM para os horários.',
      );

      expect(
        DocenteFormService.validateHorario(
          diaSemana: 'Segunda',
          inicio: '10:00',
          fim: '09:40',
        ),
        'O horário de fim deve ser posterior ao de início.',
      );

      expect(
        DocenteFormService.validateHorario(
          diaSemana: 'Segunda',
          inicio: '08:30',
          fim: '09:00',
          horariosExistentes: const [
            HorarioAula(diaSemana: 'Segunda', inicio: '08:00', fim: '09:40'),
          ],
        ),
        'Já existe horário cadastrado em conflito para Segunda.',
      );
    });

    test('simula redistribuicao entre docentes com mesma disciplina', () {
      final resultado = DocenteFormService.simularRedistribuicaoDocentes([
        const Docente(
          id: '#DOC-301',
          nome: 'Profa. Alta',
          departamento: 'Computação',
          cargaHoraria: 14,
          cargaMaxima: 20,
          disciplinas: ['Algoritmos'],
          horariosAula: [
            HorarioAula(
              diaSemana: 'Segunda',
              inicio: '08:00',
              fim: '09:40',
              disciplina: 'Algoritmos',
              cargaHoraria: '4h/sem · 60h',
            ),
          ],
        ),
        const Docente(
          id: '#DOC-302',
          nome: 'Prof. Baixa',
          departamento: 'Computação',
          cargaHoraria: 6,
          cargaMaxima: 20,
          disciplinas: ['Algoritmos'],
          horariosAula: [],
        ),
      ]);

      expect(resultado.propostas, isNotEmpty);
      expect(resultado.propostas.first.docenteOrigemId, '#DOC-301');
      expect(resultado.propostas.first.docenteDestinoId, '#DOC-302');
      expect(
        resultado.mediaOcupacaoDepois,
        lessThanOrEqualTo(resultado.mediaOcupacaoAntes),
      );
    });

    test('compara elegibilidade de disciplina sem caixa ou acentos', () {
      final resultado = DocenteFormService.simularRedistribuicaoDocentes([
        const Docente(
          id: '#DOC-DISC-ORIGEM',
          nome: 'Docente origem',
          departamento: 'Computação',
          cargaHoraria: 12,
          cargaMaxima: 20,
          disciplinas: ['Programação I'],
          horariosAula: [
            HorarioAula(
              diaSemana: 'Segunda',
              inicio: '08:00',
              fim: '09:40',
              disciplina: 'PROGRAMACAO I',
              cargaHoraria: '2h/sem',
            ),
          ],
        ),
        const Docente(
          id: '#DOC-DISC-DESTINO',
          nome: 'Docente destino',
          departamento: 'Computação',
          cargaHoraria: 7,
          cargaMaxima: 20,
          disciplinas: ['Programação I'],
        ),
      ]);

      expect(resultado.propostas, hasLength(1));
      expect(resultado.propostas.single.docenteDestinoId, '#DOC-DISC-DESTINO');
    });

    test(
      'respeita carga minima da origem e limite maximo de ensino no destino',
      () {
        final resultadoLimiteDestino =
            DocenteFormService.simularRedistribuicaoDocentes([
              const Docente(
                id: '#DOC-401',
                nome: 'Profa. Origem',
                departamento: 'Computação',
                cargaHoraria: 16,
                cargaMaxima: 20,
                disciplinas: ['Algoritmos'],
                horariosAula: [
                  HorarioAula(
                    diaSemana: 'Segunda',
                    inicio: '08:00',
                    fim: '09:40',
                    disciplina: 'Algoritmos',
                    cargaHoraria: '4h/sem · 60h',
                  ),
                ],
              ),
              const Docente(
                id: '#DOC-402',
                nome: 'Prof. Destino',
                departamento: 'Computação',
                cargaHoraria: 9,
                cargaMaxima: 20,
                disciplinas: ['Algoritmos'],
                horariosAula: [],
              ),
            ]);

        final resultadoMinimoOrigem =
            DocenteFormService.simularRedistribuicaoDocentes([
              const Docente(
                id: '#DOC-403',
                nome: 'Profa. Origem próxima do mínimo',
                departamento: 'Computação',
                cargaHoraria: 11,
                cargaMaxima: 20,
                disciplinas: ['Algoritmos'],
                horariosAula: [
                  HorarioAula(
                    diaSemana: 'Terça',
                    inicio: '08:00',
                    fim: '09:40',
                    disciplina: 'Algoritmos',
                    cargaHoraria: '4h/sem · 60h',
                  ),
                ],
              ),
              const Docente(
                id: '#DOC-404',
                nome: 'Prof. Destino abaixo do mínimo',
                departamento: 'Computação',
                cargaHoraria: 6,
                cargaMaxima: 20,
                disciplinas: ['Algoritmos'],
              ),
            ]);

        expect(resultadoLimiteDestino.propostas, isEmpty);
        expect(resultadoMinimoOrigem.propostas, isEmpty);
      },
    );

    group('limites IFMA convertidos em hora-aula', () {
      test('regime 20h respeita o limite mínimo de 8 horas-aula', () {
        final exatamenteNoMinimo = _simularTransferenciaNoLimite(
          regime: RegimeTrabalhoEbtt.vinteHoras,
          cargaOrigem: 10,
          cargaDestino: 4,
          cargaTransferida: 2,
        );
        final abaixoDoMinimo = _simularTransferenciaNoLimite(
          regime: RegimeTrabalhoEbtt.vinteHoras,
          cargaOrigem: 9,
          cargaDestino: 4,
          cargaTransferida: 2,
        );

        expect(exatamenteNoMinimo.propostas, hasLength(1));
        expect(abaixoDoMinimo.propostas, isEmpty);
      });

      test('regime 20h respeita o limite máximo de 10 horas-aula', () {
        final exatamenteNoMaximo = _simularTransferenciaNoLimite(
          regime: RegimeTrabalhoEbtt.vinteHoras,
          cargaOrigem: 12,
          cargaDestino: 8,
          cargaTransferida: 2,
        );
        final acimaDoMaximo = _simularTransferenciaNoLimite(
          regime: RegimeTrabalhoEbtt.vinteHoras,
          cargaOrigem: 12,
          cargaDestino: 9,
          cargaTransferida: 2,
        );

        expect(exatamenteNoMaximo.propostas, hasLength(1));
        expect(acimaDoMaximo.propostas, isEmpty);
      });

      test('regime integral respeita o limite mínimo de 10 horas-aula', () {
        final exatamenteNoMinimo = _simularTransferenciaNoLimite(
          regime: RegimeTrabalhoEbtt.dedicacaoExclusiva,
          cargaOrigem: 12,
          cargaDestino: 8,
          cargaTransferida: 2,
        );
        final abaixoDoMinimo = _simularTransferenciaNoLimite(
          regime: RegimeTrabalhoEbtt.dedicacaoExclusiva,
          cargaOrigem: 11,
          cargaDestino: 8,
          cargaTransferida: 2,
        );

        expect(exatamenteNoMinimo.propostas, hasLength(1));
        expect(abaixoDoMinimo.propostas, isEmpty);
      });

      test('regime integral respeita o limite máximo de 20 horas-aula', () {
        final exatamenteNoMaximo = _simularTransferenciaNoLimite(
          regime: RegimeTrabalhoEbtt.dedicacaoExclusiva,
          cargaOrigem: 22,
          cargaDestino: 18,
          cargaTransferida: 2,
        );
        final acimaDoMaximo = _simularTransferenciaNoLimite(
          regime: RegimeTrabalhoEbtt.dedicacaoExclusiva,
          cargaOrigem: 22,
          cargaDestino: 19,
          cargaTransferida: 2,
        );

        expect(exatamenteNoMaximo.propostas, hasLength(1));
        expect(acimaDoMaximo.propostas, isEmpty);
      });
    });

    test('aplica limites de aulas do IFMA por regime de trabalho', () {
      const regras = RegrasDistribuicaoCarga.ifma();

      final parcial = regras.limitesAulasPara(RegimeTrabalhoEbtt.vinteHoras);
      final integral = regras.limitesAulasPara(
        RegimeTrabalhoEbtt.dedicacaoExclusiva,
      );

      expect((parcial.minima, parcial.maxima), (8, 10));
      expect((integral.minima, integral.maxima), (10, 20));
      expect(regras.referenciaInstitucional, contains('67/2019'));
      expect(regras.referenciaFederal, contains('750/2024'));
    });

    test('reduz minima integral para 8h somente quando RAP foi atingida', () {
      const semRap = RegrasDistribuicaoCarga.ifma();
      const comRap = RegrasDistribuicaoCarga.ifma(rapCampusAtingida: true);

      expect(
        semRap.limitesAulasPara(RegimeTrabalhoEbtt.quarentaHoras).minima,
        10,
      );
      expect(
        comRap.limitesAulasPara(RegimeTrabalhoEbtt.quarentaHoras).minima,
        8,
      );
    });

    test('converte hora-aula do IFMA em minutos', () {
      final minutos =
          DocenteFormService.calcularCargaAulasSemanalMinutos(const [
            HorarioAula(
              diaSemana: 'Segunda',
              inicio: '08:00',
              fim: '09:40',
              cargaHoraria: '6h/sem · 90h',
            ),
            HorarioAula(diaSemana: 'Terça', inicio: '10:00', fim: '11:40'),
          ]);

      expect(minutos, 400);
    });

    test('detecta conflito ao tentar encaixar horario existente', () {
      const candidato = HorarioAula(
        diaSemana: 'Terça',
        inicio: '10:00',
        fim: '11:40',
        disciplina: 'Estruturas',
      );

      final conflito = DocenteFormService.existeConflitoHorario(
        horarios: const [
          HorarioAula(
            diaSemana: 'Terça',
            inicio: '10:30',
            fim: '11:20',
            disciplina: 'Banco de Dados',
          ),
        ],
        candidato: candidato,
      );

      expect(conflito, isTrue);
      expect(
        DocenteFormService.cargaSemanalDoHorario(candidato),
        greaterThanOrEqualTo(1),
      );
    });
  });
}

ResultadoSimulacaoRedistribuicao _simularTransferenciaNoLimite({
  required RegimeTrabalhoEbtt regime,
  required int cargaOrigem,
  required int cargaDestino,
  required int cargaTransferida,
}) {
  final cargaMaxima = regime == RegimeTrabalhoEbtt.vinteHoras ? 20 : 40;

  return DocenteFormService.simularRedistribuicaoDocentes(
    [
      Docente(
        id: '#DOC-LIMITE-ORIGEM',
        nome: 'Docente origem',
        departamento: 'Computação',
        cargaHoraria: cargaOrigem,
        cargaMaxima: cargaMaxima,
        disciplinas: const ['Algoritmos'],
        regimeTrabalho: regime,
        horariosAula: [
          HorarioAula(
            diaSemana: 'Segunda',
            inicio: '08:00',
            fim: '09:40',
            disciplina: 'Algoritmos',
            cargaHoraria: '${cargaTransferida}h/sem',
          ),
        ],
      ),
      Docente(
        id: '#DOC-LIMITE-DESTINO',
        nome: 'Docente destino',
        departamento: 'Computação',
        cargaHoraria: cargaDestino,
        cargaMaxima: cargaMaxima,
        disciplinas: const ['Algoritmos'],
        regimeTrabalho: regime,
      ),
    ],
    // Isola as regras legais do mecanismo heurístico de classificação de carga.
    limiarAlta: 0,
    limiarBaixa: 1,
  );
}
