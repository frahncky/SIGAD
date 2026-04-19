import '../../../../app/theme/sigad_colors.dart';
import 'package:flutter/material.dart';

class ReservaLaboratorio {
  const ReservaLaboratorio({
    required this.id,
    required this.professor,
    required this.laboratorio,
    required this.mes,
    required this.semanaDoMes,
    required this.diaSemana,
    required this.turno,
    required this.periodo,
    this.disciplina,
  });

  final String id;
  final String professor;
  final String laboratorio;
  final int mes;
  final int semanaDoMes;
  final String diaSemana;
  final Turno turno;
  final int periodo;
  final String? disciplina;
}

class HorarioGridRow {
  const HorarioGridRow({
    required this.turno,
    required this.periodo,
    required this.horario,
  });

  final Turno turno;
  final int periodo;
  final String horario;
}

enum Turno {
  matutino('Matutino'),
  vespertino('Tarde'),
  noturno('Noite');

  const Turno(this.label);

  final String label;

  String get shortLabel {
    switch (this) {
      case Turno.matutino:
        return 'M';
      case Turno.vespertino:
        return 'T';
      case Turno.noturno:
        return 'N';
    }
  }

  Color get chipBackground {
    switch (this) {
      case Turno.matutino:
        return SigadColors.successSoft.withValues(alpha: 0.85);
      case Turno.vespertino:
        return SigadColors.accentSoft.withValues(alpha: 0.85);
      case Turno.noturno:
        return SigadColors.surfaceAlt;
    }
  }

  Color get chipTextColor {
    switch (this) {
      case Turno.matutino:
        return SigadColors.success;
      case Turno.vespertino:
        return SigadColors.warning;
      case Turno.noturno:
        return SigadColors.brandDark;
    }
  }

  List<String> get horarios {
    switch (this) {
      case Turno.matutino:
        return const ['07:15-08:05', '08:05-08:55', '08:55-09:45', '09:45-10:35', '10:50-11:40', '11:40-12:30'];
      case Turno.vespertino:
        return const ['13:10-14:00', '14:00-14:50', '14:50-15:40', '15:55-16:45', '16:45-17:35', '17:35-18:25'];
      case Turno.noturno:
        return const ['18:30-19:20', '19:20-20:10', '20:30-21:15', '21:15-22:00', '22:00-22:45'];
    }
  }

  String horarioDo(int periodo) {
    if (periodo < 1 || periodo > horarios.length) {
      return 'Horário indefinido';
    }
    return horarios[periodo - 1];
  }
}
