import 'package:flutter/material.dart';

import '../../domain/docente_form_service.dart';
import '../../domain/docente_models.dart';

class DocenteFormController {
  DocenteFormController._({Docente? docente})
      : nomeController = TextEditingController(text: docente?.nome ?? ''),
        emailController = TextEditingController(text: docente?.userEmail ?? ''),
        departamentoController = TextEditingController(text: docente?.departamento ?? ''),
        cargaMaximaController = TextEditingController(
          text: docente?.cargaMaxima.toString() ?? '',
        ),
        disciplinas = List<String>.from(docente?.disciplinas ?? const []),
        horarios = List<HorarioAula>.from(docente?.horariosAula ?? const []);

  factory DocenteFormController.createNew() => DocenteFormController._();

  factory DocenteFormController.fromDocente(Docente docente) =>
      DocenteFormController._(docente: docente);

  final TextEditingController nomeController;
  final TextEditingController emailController;
  final TextEditingController departamentoController;
  final TextEditingController cargaMaximaController;
  final List<String> disciplinas;
  final List<HorarioAula> horarios;

  String? validate() {
    return DocenteFormService.validateDocente(
      nome: nomeController.text,
      departamento: departamentoController.text,
      cargaMaxima: cargaMaximaController.text,
      disciplinas: disciplinas,
    );
  }

  String? validateDisciplina(String disciplina) {
    return DocenteFormService.validateDisciplina(
      disciplina: disciplina,
      disciplinasExistentes: disciplinas,
    );
  }

  String? validateHorario({required String inicio, required String fim}) {
    return DocenteFormService.validateHorario(inicio: inicio, fim: fim);
  }

  void addDisciplina(String disciplina) {
    disciplinas.add(disciplina.trim());
  }

  void removeDisciplina(String disciplina) {
    disciplinas.remove(disciplina);
  }

  void addHorario(HorarioAula horario) {
    horarios.add(horario);
  }

  void removeHorario(HorarioAula horario) {
    horarios.remove(horario);
  }

  HorarioAula createHorario({
    required String diaSemana,
    required String inicio,
    required String fim,
    required String modalidade,
    String? disciplina,
    String? cargaHoraria,
    String? turma,
  }) {
    return DocenteFormService.createHorario(
      diaSemana: diaSemana,
      inicio: inicio,
      fim: fim,
      disciplina: disciplina,
      cargaHoraria: cargaHoraria,
      turma: turma,
      modalidade: modalidade,
    );
  }

  Docente buildNewDocente(String id) {
    return DocenteFormService.createDocente(
      id: id,
      nome: nomeController.text,
      email: emailController.text,
      departamento: departamentoController.text,
      cargaMaxima: cargaMaximaController.text,
      disciplinas: disciplinas,
      horarios: horarios,
    );
  }

  Docente buildUpdatedDocente(Docente docente) {
    return DocenteFormService.updateDocente(
      docente: docente,
      nome: nomeController.text,
      email: emailController.text,
      departamento: departamentoController.text,
      cargaMaxima: cargaMaximaController.text,
      disciplinas: disciplinas,
      horarios: horarios,
    );
  }

  void dispose() {
    nomeController.dispose();
    emailController.dispose();
    departamentoController.dispose();
    cargaMaximaController.dispose();
  }
}
