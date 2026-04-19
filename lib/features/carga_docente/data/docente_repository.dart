import '../../../core/services/local_storage_service.dart';
import '../domain/docente_models.dart';

class DocenteRepository {
  DocenteRepository({this.storageKey = 'sigad_docentes'});

  final String storageKey;

  Future<List<Docente>> loadDocentes({required String Function() generateFallbackId}) async {
    final list = await LocalStorageService.loadList(storageKey);
    if (list.isEmpty) return const [];

    final carregados = <Docente>[];
    for (final item in list) {
      try {
        carregados.add(_docenteFromJson(item, generateFallbackId: generateFallbackId));
      } catch (_) {
        // Ignora entradas inválidas para evitar falha ao abrir a tela.
      }
    }
    return carregados;
  }

  Future<void> saveDocentes(List<Docente> docentes) {
    return LocalStorageService.saveList(
      storageKey,
      docentes.map(_docenteToJson).toList(growable: false),
    );
  }

  Map<String, dynamic> _docenteToJson(Docente d) => {
        'id': d.id,
        'nome': d.nome,
        if (d.userId != null) 'userId': d.userId,
        if (d.userEmail != null) 'userEmail': d.userEmail,
        'departamento': d.departamento,
        'cargaHoraria': d.cargaHoraria,
        'cargaMaxima': d.cargaMaxima,
        'disciplinas': d.disciplinas,
        'horariosAula': d.horariosAula
            .map(
              (h) => {
                'diaSemana': h.diaSemana,
                'inicio': h.inicio,
                'fim': h.fim,
                if (h.disciplina != null) 'disciplina': h.disciplina,
                if (h.cargaHoraria != null) 'cargaHoraria': h.cargaHoraria,
                if (h.turma != null) 'turma': h.turma,
                if (h.modalidade != null) 'modalidade': h.modalidade,
              },
            )
            .toList(growable: false),
      };

  Docente _docenteFromJson(
    Map<String, dynamic> json, {
    required String Function() generateFallbackId,
  }) {
    return Docente(
      id: json['id']?.toString().trim().isNotEmpty == true
          ? json['id']!.toString().trim()
          : generateFallbackId(),
      nome: json['nome']?.toString().trim().isNotEmpty == true
          ? json['nome']!.toString().trim()
          : 'Docente sem nome',
      userId: _normalizeNullable(json['userId']),
      userEmail: json['userEmail']?.toString().trim().isEmpty == true
          ? null
          : json['userEmail']?.toString().trim().toLowerCase(),
      departamento: json['departamento']?.toString().trim().isNotEmpty == true
          ? json['departamento']!.toString().trim()
          : 'Não informado',
      cargaHoraria: _toInt(json['cargaHoraria']),
      cargaMaxima: _toInt(json['cargaMaxima'], defaultValue: 20, minValue: 0),
      disciplinas: _disciplinasFromJson(json['disciplinas']),
      horariosAula: _horariosAulaFromJson(json['horariosAula']),
    );
  }

  String? _normalizeNullable(dynamic raw) {
    final value = raw?.toString().trim();
    if (value == null || value.isEmpty) return null;
    return value;
  }

  int _toInt(dynamic raw, {int defaultValue = 0, int minValue = 0}) {
    final parsed = int.tryParse(raw?.toString() ?? '');
    if (parsed == null) return defaultValue;
    return parsed < minValue ? minValue : parsed;
  }

  List<String> _disciplinasFromJson(dynamic raw) {
    if (raw is! List) return const [];

    return raw
        .map((item) => item?.toString().trim() ?? '')
        .where((item) => item.isNotEmpty)
        .toList(growable: false);
  }

  List<HorarioAula> _horariosAulaFromJson(dynamic raw) {
    if (raw is! List) return const [];

    return raw
        .whereType<Map>()
        .map((item) {
          final map = Map<String, dynamic>.from(item);
          final diaSemana = map['diaSemana']?.toString().trim();
          final inicio = map['inicio']?.toString().trim();
          final fim = map['fim']?.toString().trim();

          if (diaSemana == null ||
              diaSemana.isEmpty ||
              inicio == null ||
              inicio.isEmpty ||
              fim == null ||
              fim.isEmpty) {
            return null;
          }

          return HorarioAula(
            diaSemana: diaSemana,
            inicio: inicio,
            fim: fim,
            disciplina: map['disciplina']?.toString().trim(),
            cargaHoraria: map['cargaHoraria']?.toString().trim(),
            turma: map['turma']?.toString().trim(),
            modalidade: map['modalidade']?.toString().trim(),
          );
        })
        .whereType<HorarioAula>()
        .toList(growable: false);
  }
}
