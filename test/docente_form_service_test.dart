import 'package:flutter_test/flutter_test.dart';
import 'package:sigad/features/carga_docente/domain/docente_form_service.dart';
import 'package:sigad/features/carga_docente/domain/docente_models.dart';

void main() {
  group('DocenteFormService', () {
    test('valida docente com campos obrigatórios', () {
      expect(
        DocenteFormService.validateDocente(
          nome: '',
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
          departamento: 'Computação',
          cargaMaxima: '0',
          disciplinas: const ['Algoritmos'],
          regimeTrabalho: RegimeTrabalhoEbtt.vinteHoras,
          horarios: const [],
        ),
        'Informe uma carga horária máxima válida',
      );
    });

    test('restringe carga máxima ao regime EBTT e à distribuição cadastrada', () {
      expect(
        DocenteFormService.validateDocente(
          nome: 'Prof. Teste',
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
  });
}
