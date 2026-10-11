import '../domain/reserva_models.dart';
import '../../../core/services/local_storage_service.dart';

class ReservaRepository {
  ReservaRepository({this.storageKey = 'sigad_reservas', int? legacyYear})
    : legacyYear = legacyYear ?? DateTime.now().year;

  final String storageKey;
  final int legacyYear;

  Future<List<ReservaLaboratorio>> loadReservas() async {
    final list = await LocalStorageService.loadList(storageKey);
    if (list.isEmpty) return const [];

    final reservas = <ReservaLaboratorio>[];
    var migratedLegacyYear = false;
    for (final item in list) {
      try {
        final reserva = _reservaFromJson(item);
        reservas.add(reserva);
        if (!item.containsKey('ano')) migratedLegacyYear = true;
      } catch (_) {
        // Ignora dados inválidos para não bloquear a tela.
      }
    }
    if (migratedLegacyYear) await saveReservas(reservas);
    return reservas;
  }

  Future<void> saveReservas(List<ReservaLaboratorio> reservas) {
    return LocalStorageService.saveList(
      storageKey,
      reservas.map(_reservaToJson).toList(growable: false),
    );
  }

  Map<String, dynamic> _reservaToJson(ReservaLaboratorio r) => {
    'id': r.id,
    'professor': r.professor,
    'laboratorio': r.laboratorio,
    'ano': r.ano,
    'mes': r.mes,
    'semanaDoMes': r.semanaDoMes,
    'diaSemana': r.diaSemana,
    'turno': r.turno.name,
    'periodo': r.periodo,
    if (r.disciplina != null) 'disciplina': r.disciplina,
    'grupoId': r.grupoId,
  };

  ReservaLaboratorio _reservaFromJson(Map<String, dynamic> json) {
    return ReservaLaboratorio(
      id: json['id'] as String,
      professor: json['professor'] as String,
      laboratorio: json['laboratorio'] as String,
      ano: json['ano'] as int? ?? legacyYear,
      mes: json['mes'] as int,
      semanaDoMes: json['semanaDoMes'] as int,
      diaSemana: json['diaSemana'] as String,
      turno: Turno.values.firstWhere((turno) => turno.name == json['turno']),
      periodo: json['periodo'] as int,
      disciplina: json['disciplina'] as String?,
      grupoId: json['grupoId'] as String?,
    );
  }
}
