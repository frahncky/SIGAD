import 'package:flutter_test/flutter_test.dart';
import 'package:sigad/core/models/user.dart';
import 'package:sigad/core/models/user_role.dart';
import 'package:sigad/features/carga_docente/domain/docente_models.dart';
import 'package:sigad/features/carga_docente/domain/plano_trabalho_service.dart';

void main() {
  final docente = Docente(
    id: 'd1',
    nome: 'Docente IFMA',
    userId: 'u-docente',
    userEmail: 'docente@ifma.edu.br',
    departamento: 'Computação',
    cargaHoraria: 10,
    cargaMaxima: 20,
    disciplinas: const ['Algoritmos'],
  );
  final professor = User(
    id: 'u-docente',
    name: 'Docente IFMA',
    email: 'docente@ifma.edu.br',
    role: UserRole.professor,
    createdAt: DateTime(2026),
  );
  final chefe = User(
    id: 'u-chefe',
    name: 'Chefia',
    email: 'chefia@ifma.edu.br',
    role: UserRole.chefeDepartamento,
    createdAt: DateTime(2026),
  );
  final planoValido = PlanoTrabalhoDocente(
    docenteId: 'd1',
    periodoLetivo: '2026.2',
    avaliadorId: 'u-chefe',
    atividades: const [
      AtividadePlanoDocente(
        tipo: TipoAtividadePlanoDocente.preparacaoManutencaoApoioEnsino,
        descricao: 'Preparação de aulas',
        cargaSemanalMinutos: 460,
      ),
      AtividadePlanoDocente(
        tipo: TipoAtividadePlanoDocente.pesquisa,
        descricao: 'Projeto institucional',
        cargaSemanalMinutos: 240,
      ),
    ],
  );

  test('docente submete PIT válido e chefia de terceiro aprova', () {
    final submetido = PlanoTrabalhoService.submeter(
      usuario: professor,
      docente: docente,
      plano: planoValido,
      agora: DateTime(2026, 7, 1),
    );

    expect(submetido.sucesso, isTrue);
    expect(submetido.plano?.status, StatusPlanoTrabalhoDocente.submetido);

    final aprovado = PlanoTrabalhoService.aprovar(
      usuario: chefe,
      docente: docente,
      plano: submetido.plano!,
      parecer: 'De acordo.',
      agora: DateTime(2026, 7, 2),
    );
    expect(aprovado.sucesso, isTrue);
    expect(aprovado.plano?.status, StatusPlanoTrabalhoDocente.aprovado);
    expect(aprovado.plano?.parecerAvaliacao, 'De acordo.');
  });

  test('chefia não pode aprovar o próprio PIT', () {
    final docenteChefe = docente.copyWith(
      userId: chefe.id,
      userEmail: chefe.email,
    );
    final resultado = PlanoTrabalhoService.aprovar(
      usuario: chefe,
      docente: docenteChefe,
      plano: planoValido.copyWith(status: StatusPlanoTrabalhoDocente.submetido),
    );

    expect(resultado.sucesso, isFalse);
    expect(resultado.erro, contains('terceiros'));
  });

  test('devolução exige motivo', () {
    final resultado = PlanoTrabalhoService.devolver(
      usuario: chefe,
      docente: docente,
      plano: planoValido.copyWith(status: StatusPlanoTrabalhoDocente.submetido),
      motivo: '  ',
    );

    expect(resultado.sucesso, isFalse);
    expect(resultado.erro, contains('motivo'));
  });
}
