import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sigad/features/carga_docente/data/docente_repository.dart';
import 'package:sigad/features/carga_docente/domain/docente_models.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('DocenteRepository', () {
    late DocenteRepository repository;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      repository = DocenteRepository(storageKey: 'test_sigad_docentes');
    });

    test(
      'salva e carrega docentes preservando horários e vínculo do usuário',
      () async {
        final docentes = [
          const Docente(
            id: '#DOC-101',
            nome: 'Profa. Teste',
            userId: 'user_email_prof.teste@sigad.br',
            userEmail: 'prof.teste@sigad.br',
            departamento: 'Teste',
            cargaHoraria: 12,
            cargaMaxima: 20,
            disciplinas: ['Laboratório I'],
            regimeTrabalho: RegimeTrabalhoEbtt.vinteHoras,
            horariosAula: [
              HorarioAula(
                diaSemana: 'Segunda',
                inicio: '08:00',
                fim: '09:40',
                disciplina: 'Laboratório I',
                cargaHoraria: '2h/sem · 60h',
                turma: 'LAB-1',
                modalidade: 'Integral',
              ),
            ],
          ),
        ];

        await repository.saveDocentes(docentes);
        final carregados = await repository.loadDocentes(
          generateFallbackId: () => '#DOC-999',
        );

        expect(carregados, hasLength(1));
        expect(carregados.first.id, '#DOC-101');
        expect(carregados.first.userId, 'user_email_prof.teste@sigad.br');
        expect(carregados.first.userEmail, 'prof.teste@sigad.br');
        expect(carregados.first.regimeTrabalho, RegimeTrabalhoEbtt.vinteHoras);
        expect(carregados.first.horariosAula, hasLength(1));
        expect(carregados.first.horariosAula.first.disciplina, 'Laboratório I');
      },
    );

    test(
      'ignora registros inválidos e gera id fallback quando necessário',
      () async {
        SharedPreferences.setMockInitialValues({
          'test_sigad_docentes': jsonEncode([
            {
              'nome': 'Docente sem id',
              'departamento': 'Teste',
              'cargaHoraria': 8,
              'cargaMaxima': 20,
              'disciplinas': ['Algoritmos'],
              'horariosAula': [
                {'diaSemana': 'Terça', 'inicio': '10:00', 'fim': '11:40'},
              ],
            },
            'entrada-invalida',
          ]),
        });

        repository = DocenteRepository(storageKey: 'test_sigad_docentes');

        final carregados = await repository.loadDocentes(
          generateFallbackId: () => '#DOC-555',
        );

        expect(carregados, hasLength(1));
        expect(carregados.first.id, '#DOC-555');
        expect(carregados.first.nome, 'Docente sem id');
      },
    );
  });
}
