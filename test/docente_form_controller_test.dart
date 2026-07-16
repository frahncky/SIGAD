import 'package:flutter_test/flutter_test.dart';
import 'package:sigad/features/carga_docente/domain/docente_models.dart';
import 'package:sigad/features/carga_docente/presentation/controllers/docente_form_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('DocenteFormController', () {
    test('cria controller vazio e monta novo docente', () {
      final controller = DocenteFormController.createNew();
      controller.nomeController.text = 'Profa. Ana';
      controller.emailController.text = 'ANA@sigad.br';
      controller.departamentoController.text = 'Computação';
      controller.cargaMaximaController.text = '20';
      controller.regimeTrabalho = RegimeTrabalhoEbtt.vinteHoras;
      controller.addDisciplina('Algoritmos');
      controller.addHorario(
        controller.createHorario(
          diaSemana: 'Segunda',
          inicio: '08:00',
          fim: '09:40',
          modalidade: 'Integral',
        ),
      );

      final docente = controller.buildNewDocente('#DOC-100');

      expect(docente.id, '#DOC-100');
      expect(docente.userEmail, 'ana@sigad.br');
      expect(docente.userId, 'user_email_ana@sigad.br');
      expect(docente.horariosAula, hasLength(1));
      controller.dispose();
    });

    test('valida email de acesso antes de montar o docente', () {
      final controller = DocenteFormController.createNew();
      controller.nomeController.text = 'Profa. Ana';
      controller.departamentoController.text = 'Computação';
      controller.cargaMaximaController.text = '20';
      controller.addDisciplina('Algoritmos');

      expect(controller.validate(), 'Informe o email de acesso');

      controller.emailController.text = 'email-invalido';
      expect(controller.validate(), 'Informe um email de acesso válido');

      controller.emailController.text = 'ana@ifma.edu.br';
      expect(controller.validate(), isNull);
      controller.dispose();
    });

    test('carrega docente existente e atualiza dados', () {
      const docente = Docente(
        id: '#DOC-101',
        nome: 'Prof. Original',
        userEmail: 'old@sigad.br',
        departamento: 'DSI',
        cargaHoraria: 2,
        cargaMaxima: 20,
        disciplinas: ['Banco de Dados'],
        regimeTrabalho: RegimeTrabalhoEbtt.vinteHoras,
      );

      final controller = DocenteFormController.fromDocente(docente);
      controller.nomeController.text = 'Prof. Atualizado';
      controller.emailController.text = 'novo@sigad.br';
      controller.departamentoController.text = 'Redes';
      controller.cargaMaximaController.text = '16';
      controller.regimeTrabalho = RegimeTrabalhoEbtt.vinteHoras;
      controller.removeDisciplina('Banco de Dados');
      controller.addDisciplina('Redes I');

      final atualizado = controller.buildUpdatedDocente(docente);

      expect(atualizado.id, '#DOC-101');
      expect(atualizado.nome, 'Prof. Atualizado');
      expect(atualizado.departamento, 'Redes');
      expect(atualizado.disciplinas, ['Redes I']);
      controller.dispose();
    });

    test('reaproveita validações de disciplina e horário', () {
      final controller = DocenteFormController.createNew();
      controller.addDisciplina('Algoritmos');

      expect(
        controller.validateDisciplina('Algoritmos'),
        'Disciplina já adicionada.',
      );
      expect(
        controller.validateHorario(
          diaSemana: 'Segunda',
          inicio: '8:00',
          fim: '09:40',
        ),
        'Use o formato HH:MM para os horários.',
      );

      controller.addHorario(
        controller.createHorario(
          diaSemana: 'Segunda',
          inicio: '08:00',
          fim: '09:40',
          modalidade: 'Integral',
        ),
      );
      expect(
        controller.validateHorario(
          diaSemana: 'Segunda',
          inicio: '08:30',
          fim: '09:00',
        ),
        'Já existe horário cadastrado em conflito para Segunda.',
      );
      controller.dispose();
    });
  });
}
