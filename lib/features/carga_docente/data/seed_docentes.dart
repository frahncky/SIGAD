import '../domain/docente_models.dart';
import 'docente_repository.dart';

/// Executa uma carga inicial de docentes para testes manuais.
Future<void> seedDocentes() async {
  final repo = DocenteRepository();
  final docentes = [
    Docente(
      id: '1',
      nome: 'Ana Souza',
      userId: 'ana.souza',
      userEmail: 'ana.souza@univ.br',
      departamento: 'Matemática',
      cargaHoraria: 20,
      cargaMaxima: 20,
      disciplinas: ['Álgebra', 'Cálculo'],
      horariosAula: const [],
    ),
    Docente(
      id: '2',
      nome: 'Bruno Lima',
      userId: 'bruno.lima',
      userEmail: 'bruno.lima@univ.br',
      departamento: 'Física',
      cargaHoraria: 18,
      cargaMaxima: 20,
      disciplinas: ['Física I', 'Física II'],
      horariosAula: const [],
    ),
    Docente(
      id: '3',
      nome: 'Carla Dias',
      userId: 'carla.dias',
      userEmail: 'carla.dias@univ.br',
      departamento: 'Química',
      cargaHoraria: 16,
      cargaMaxima: 20,
      disciplinas: ['Química Orgânica'],
      horariosAula: const [],
    ),
    Docente(
      id: '4',
      nome: 'Daniel Alves',
      userId: 'daniel.alves',
      userEmail: 'daniel.alves@univ.br',
      departamento: 'Biologia',
      cargaHoraria: 14,
      cargaMaxima: 20,
      disciplinas: ['Biologia Celular'],
      horariosAula: const [],
    ),
    Docente(
      id: '5',
      nome: 'Elisa Martins',
      userId: 'elisa.martins',
      userEmail: 'elisa.martins@univ.br',
      departamento: 'História',
      cargaHoraria: 12,
      cargaMaxima: 20,
      disciplinas: ['História do Brasil'],
      horariosAula: const [],
    ),
  ];
  await repo.saveDocentes(docentes);
}
