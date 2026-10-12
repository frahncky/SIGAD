import '../../../core/models/user_role.dart';
import '../../../core/models/user.dart';
import 'reserva_models.dart';

abstract final class ReservaService {
  static List<ReservaLaboratorio> defaultReservas({
    required int ano,
    required int mes,
  }) {
    return [
      ReservaLaboratorio(
        id: 'RES-101',
        professor: 'Docente 01',
        laboratorio: 'Lab. de Eletrônica Analógica',
        ano: ano,
        mes: mes,
        semanaDoMes: 2,
        diaSemana: 'Seg',
        turno: Turno.matutino,
        periodo: 4,
      ),
      ReservaLaboratorio(
        id: 'RES-102',
        professor: 'Docente 02',
        laboratorio: 'Lab. de Eletrônica Analógica',
        ano: ano,
        mes: mes,
        semanaDoMes: 2,
        diaSemana: 'Ter',
        turno: Turno.matutino,
        periodo: 4,
      ),
      ReservaLaboratorio(
        id: 'RES-103',
        professor: 'Docente 03',
        laboratorio: 'Lab. de Eletrônica Analógica',
        ano: ano,
        mes: mes,
        semanaDoMes: 3,
        diaSemana: 'Sex',
        turno: Turno.noturno,
        periodo: 1,
      ),
      ReservaLaboratorio(
        id: 'RES-104',
        professor: 'Docente 04',
        laboratorio: 'Lab. de Eletrônica Analógica',
        ano: ano,
        mes: mes,
        semanaDoMes: 3,
        diaSemana: 'Seg',
        turno: Turno.vespertino,
        periodo: 3,
      ),
    ];
  }

  static bool canAccess(UserRole? role) {
    return role == UserRole.professor ||
        role == UserRole.coordenador ||
        role == UserRole.chefeDepartamento;
  }

  static bool canEdit(UserRole? role) => canAccess(role);

  static bool canChangeReservation({
    required User? user,
    required UserRole? role,
  }) {
    if (user == null) return false;
    return canAccess(role);
  }

  static bool canRemoveReservation({
    required UserRole? role,
    required String currentUserName,
    required ReservaLaboratorio reserva,
  }) {
    return role == UserRole.chefeDepartamento ||
        reserva.professor == currentUserName;
  }

  static bool isSlotOccupied({
    required List<ReservaLaboratorio> reservas,
    required String laboratorio,
    required int ano,
    required int mes,
    required int semanaDoMes,
    required String diaSemana,
    required Turno turno,
    required int periodo,
  }) {
    return reservas.any(
      (reserva) =>
          reserva.laboratorio == laboratorio &&
          reserva.ano == ano &&
          reserva.mes == mes &&
          reserva.semanaDoMes == semanaDoMes &&
          reserva.diaSemana == diaSemana &&
          reserva.turno == turno &&
          reserva.periodo == periodo,
    );
  }

  static ReservaLaboratorio createReserva({
    required String professor,
    required String laboratorio,
    required int ano,
    required int mes,
    required int semanaDoMes,
    required String diaSemana,
    required Turno turno,
    required int periodo,
    String? disciplina,
    String? grupoId,
  }) {
    return ReservaLaboratorio(
      id: 'RES-${DateTime.now().microsecondsSinceEpoch}-${_idSequence++}',
      professor: professor,
      laboratorio: laboratorio,
      ano: ano,
      mes: mes,
      semanaDoMes: semanaDoMes,
      diaSemana: diaSemana,
      turno: turno,
      periodo: periodo,
      disciplina: _normalizeNullable(disciplina),
      grupoId: grupoId,
    );
  }

  static int _idSequence = 0;

  static List<ReservaLaboratorio> reservasDoLaboratorio({
    required List<ReservaLaboratorio> reservas,
    required String laboratorio,
    required int ano,
    required int mes,
    required int semanaDoMes,
  }) {
    return reservas
        .where(
          (reserva) =>
              reserva.laboratorio == laboratorio &&
              reserva.ano == ano &&
              reserva.mes == mes &&
              reserva.semanaDoMes == semanaDoMes,
        )
        .toList(growable: false);
  }

  static List<IndicadorOcupacaoLaboratorio> calcularOcupacaoLaboratorios({
    required List<ReservaLaboratorio> reservas,
    required List<String> laboratorios,
    required int ano,
    required int mes,
    required int semanaDoMes,
  }) {
    final totalSlots = 5 * gerarLinhasGrade().length;

    return laboratorios
        .map((laboratorio) {
          final reservados = reservas.where((reserva) {
            return reserva.laboratorio == laboratorio &&
                reserva.ano == ano &&
                reserva.mes == mes &&
                reserva.semanaDoMes == semanaDoMes;
          }).length;

          return IndicadorOcupacaoLaboratorio(
            laboratorio: laboratorio,
            totalSlots: totalSlots,
            slotsReservados: reservados,
          );
        })
        .toList(growable: false);
  }

  static List<SugestaoReservaLaboratorio> sugerirSlotsLivres({
    required List<ReservaLaboratorio> reservas,
    required List<String> laboratorios,
    required int ano,
    required int mes,
    required int semanaDoMes,
    String? diaSemanaPreferencial,
    int limite = 3,
  }) {
    if (limite <= 0) return const [];

    final indicadores = calcularOcupacaoLaboratorios(
      reservas: reservas,
      laboratorios: laboratorios,
      ano: ano,
      mes: mes,
      semanaDoMes: semanaDoMes,
    );

    final ocupacaoPorLaboratorio = {
      for (final indicador in indicadores)
        indicador.laboratorio: indicador.taxaOcupacao,
    };

    const diasSemana = ['Seg', 'Ter', 'Qua', 'Qui', 'Sex'];
    final linhas = gerarLinhasGrade();
    final sugestoes = <SugestaoReservaLaboratorio>[];

    for (final laboratorio in laboratorios) {
      final ocupacao = ocupacaoPorLaboratorio[laboratorio] ?? 0;
      for (final diaSemana in diasSemana) {
        final bonusDia = diaSemanaPreferencial == diaSemana ? 0.35 : 0;
        for (final linha in linhas) {
          final ocupado = isSlotOccupied(
            reservas: reservas,
            laboratorio: laboratorio,
            ano: ano,
            mes: mes,
            semanaDoMes: semanaDoMes,
            diaSemana: diaSemana,
            turno: linha.turno,
            periodo: linha.periodo,
          );

          if (ocupado) continue;

          final bonusTurno = linha.turno == Turno.matutino
              ? 0.12
              : linha.turno == Turno.vespertino
              ? 0.08
              : 0.04;

          final score = (1 - ocupacao) + bonusDia + bonusTurno;
          sugestoes.add(
            SugestaoReservaLaboratorio(
              laboratorio: laboratorio,
              diaSemana: diaSemana,
              turno: linha.turno,
              periodo: linha.periodo,
              horario: linha.horario,
              score: score,
            ),
          );
        }
      }
    }

    sugestoes.sort((a, b) => b.score.compareTo(a.score));
    return sugestoes.take(limite).toList(growable: false);
  }

  static List<HorarioGridRow> gerarLinhasGrade() {
    return [
      for (final turno in Turno.values)
        for (var periodo = 1; periodo <= turno.horarios.length; periodo++)
          HorarioGridRow(
            turno: turno,
            periodo: periodo,
            horario: turno.horarioDo(periodo),
          ),
    ];
  }

  static ReservaLaboratorio? reservaPara({
    required List<ReservaLaboratorio> reservas,
    required String diaSemana,
    required Turno turno,
    required int periodo,
  }) {
    for (final reserva in reservas) {
      if (reserva.diaSemana == diaSemana &&
          reserva.turno == turno &&
          reserva.periodo == periodo) {
        return reserva;
      }
    }
    return null;
  }

  static String diaCompleto(String diaSemana) {
    switch (diaSemana) {
      case 'Seg':
        return 'segunda-feira';
      case 'Ter':
        return 'terça-feira';
      case 'Qua':
        return 'quarta-feira';
      case 'Qui':
        return 'quinta-feira';
      case 'Sex':
        return 'sexta-feira';
      default:
        return diaSemana;
    }
  }

  static String nomeMes(int mes, List<String> meses) {
    if (mes < 1 || mes > meses.length) {
      return 'Mês inválido';
    }
    return meses[mes - 1];
  }

  static String descricaoSemana(int semana) => '${semana}a semana';

  static const diasUteis = ['Seg', 'Ter', 'Qua', 'Qui', 'Sex'];

  /// Bloco de 7 dias do mês em que a data cai (dias 1–7 = 1, 8–14 = 2…).
  ///
  /// É a "semana do mês" gravada na reserva. Como cada bloco tem exatamente
  /// um dia de cada dia da semana, bloco + dia da semana identificam a data.
  static int semanaDoMesDe(DateTime data) => ((data.day - 1) ~/ 7) + 1;

  /// Abreviação do dia útil ('Seg'…'Sex'), ou nulo no fim de semana.
  static String? diaSemanaDe(DateTime data) =>
      data.weekday <= DateTime.friday ? diasUteis[data.weekday - 1] : null;

  /// Data real de uma reserva, ou nulo se os campos não formam uma data.
  static DateTime? dataDaReserva(ReservaLaboratorio reserva) {
    final inicio = 7 * (reserva.semanaDoMes - 1) + 1;
    for (var dia = inicio; dia < inicio + 7; dia++) {
      final data = DateTime(reserva.ano, reserva.mes, dia);
      if (data.month != reserva.mes) return null;
      if (diaSemanaDe(data) == reserva.diaSemana) return data;
    }
    return null;
  }

  /// Reserva do laboratório na data e horário informados.
  static ReservaLaboratorio? reservaNaData({
    required List<ReservaLaboratorio> reservas,
    required String laboratorio,
    required DateTime data,
    required Turno turno,
    required int periodo,
  }) {
    final diaSemana = diaSemanaDe(data);
    if (diaSemana == null) return null;
    final semana = semanaDoMesDe(data);
    for (final reserva in reservas) {
      if (reserva.laboratorio == laboratorio &&
          reserva.ano == data.year &&
          reserva.mes == data.month &&
          reserva.semanaDoMes == semana &&
          reserva.diaSemana == diaSemana &&
          reserva.turno == turno &&
          reserva.periodo == periodo) {
        return reserva;
      }
    }
    return null;
  }

  /// Data do dia útil [diaSemana] na mesma semana (segunda a sexta) de [data].
  static DateTime? diaDaMesmaSemana(DateTime data, String diaSemana) {
    final indice = diasUteis.indexOf(diaSemana);
    if (indice < 0) return null;
    final segunda = segundaDaSemana(data);
    return DateTime(segunda.year, segunda.month, segunda.day + indice);
  }

  /// Segunda-feira da semana a mostrar para [data]. No fim de semana,
  /// avança para a semana seguinte.
  static DateTime segundaDaSemana(DateTime data) {
    final dia = DateTime(data.year, data.month, data.day);
    if (dia.weekday >= DateTime.saturday) {
      return DateTime(dia.year, dia.month, dia.day + 8 - dia.weekday);
    }
    return DateTime(dia.year, dia.month, dia.day - (dia.weekday - DateTime.monday));
  }

  static String? validateDisciplina(String? disciplina) {
    final normalized = disciplina?.trim();
    if (normalized == null || normalized.isEmpty) {
      return 'Informe a disciplina.';
    }
    return null;
  }

  static String? _normalizeNullable(String? value) {
    final normalized = value?.trim();
    if (normalized == null || normalized.isEmpty) return null;
    return normalized;
  }
}
