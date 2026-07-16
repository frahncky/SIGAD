import '../domain/docente_models.dart';
import 'docente_repository.dart';

/// Dados fictícios para testes manuais no contexto do DEE/IFMA.
Future<void> seedDocentes() async {
  final repo = DocenteRepository();
  var fallbackId = 0;
  final existentes = await repo.loadDocentes(
    generateFallbackId: () => 'seed-fallback-${fallbackId++}',
  );
  if (existentes.isNotEmpty) return;

  final docentes = [
    Docente(
      id: 'DOC-DEE-01',
      nome: 'Docente 01',
      userId: 'docente01',
      userEmail: 'docente01@ifma.edu.br',
      departamento: 'DEE — Engenharia Elétrica',
      cargaHoraria: 20,
      cargaMaxima: 20,
      disciplinas: ['Circuitos Elétricos', 'Medidas Elétricas'],
      horariosAula: const [],
    ),
    Docente(
      id: 'DOC-DEE-02',
      nome: 'Docente 02',
      userId: 'docente02',
      userEmail: 'docente02@ifma.edu.br',
      departamento: 'DEE — Eletrônica',
      cargaHoraria: 18,
      cargaMaxima: 20,
      disciplinas: ['Eletrônica Analógica', 'Eletrônica Digital'],
      horariosAula: const [],
    ),
    Docente(
      id: 'DOC-DEE-03',
      nome: 'Docente 03',
      userId: 'docente03',
      userEmail: 'docente03@ifma.edu.br',
      departamento: 'DEE — Eletrotécnica',
      cargaHoraria: 16,
      cargaMaxima: 20,
      disciplinas: ['Máquinas Elétricas', 'Instalações Elétricas'],
      horariosAula: const [],
    ),
    Docente(
      id: 'DOC-DEE-04',
      nome: 'Docente 04',
      userId: 'docente04',
      userEmail: 'docente04@ifma.edu.br',
      departamento: 'DEE — Telecomunicações',
      cargaHoraria: 14,
      cargaMaxima: 20,
      disciplinas: ['Sistemas de Comunicação', 'Redes de Telecomunicações'],
      horariosAula: const [],
    ),
    Docente(
      id: 'DOC-DEE-05',
      nome: 'Docente 05',
      userId: 'docente05',
      userEmail: 'docente05@ifma.edu.br',
      departamento: 'DEE — Automação',
      cargaHoraria: 12,
      cargaMaxima: 20,
      disciplinas: ['Automação Industrial', 'Sistemas Embarcados'],
      horariosAula: const [],
    ),
  ];
  await repo.saveDocentes(docentes);
}
