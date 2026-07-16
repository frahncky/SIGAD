import '../domain/reserva_models.dart';
import '../../../core/services/local_storage_service.dart';

class ReservaRepository {
  ReservaRepository({this.storageKey = 'sigad_reservas'});

  final String storageKey;

  Future<List<ReservaLaboratorio>> loadReservas({
    List<ReservaLaboratorio> initialData = const [],
  }) async {
    final list = await LocalStorageService.loadListOrNull(storageKey);
    if (list == null) {
      if (initialData.isNotEmpty) {
        await saveReservas(initialData);
      }
      return List<ReservaLaboratorio>.of(initialData, growable: false);
    }
    if (list.isEmpty) return const [];

    final reservas = <ReservaLaboratorio>[];
    for (final item in list) {
      try {
        reservas.add(_reservaFromJson(item));
      } catch (_) {
        // Ignora dados inválidos para não bloquear a tela.
      }
    }
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
    'mes': r.mes,
    'semanaDoMes': r.semanaDoMes,
    'diaSemana': r.diaSemana,
    'turno': r.turno.name,
    'periodo': r.periodo,
    if (r.disciplina != null) 'disciplina': r.disciplina,
  };

  ReservaLaboratorio _reservaFromJson(Map<String, dynamic> json) {
    return ReservaLaboratorio(
      id: json['id'] as String,
      professor: json['professor'] as String,
      laboratorio: json['laboratorio'] as String,
      mes: json['mes'] as int,
      semanaDoMes: json['semanaDoMes'] as int,
      diaSemana: json['diaSemana'] as String,
      turno: Turno.values.firstWhere((turno) => turno.name == json['turno']),
      periodo: json['periodo'] as int,
      disciplina: json['disciplina'] as String?,
    );
  }
}
