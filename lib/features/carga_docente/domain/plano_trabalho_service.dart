import '../../../core/models/user.dart';
import '../../../core/models/user_role.dart';
import 'docente_form_service.dart';
import 'docente_models.dart';

class ResultadoOperacaoPlanoTrabalho {
  const ResultadoOperacaoPlanoTrabalho({this.plano, this.erro, this.validacao});

  final PlanoTrabalhoDocente? plano;
  final String? erro;
  final ResultadoValidacaoPlanoTrabalho? validacao;

  bool get sucesso => plano != null && erro == null;
}

abstract final class PlanoTrabalhoService {
  static bool usuarioRepresentaDocente(User? usuario, Docente docente) {
    if (usuario == null) return false;
    final userId = (docente.userId ?? '').trim().toLowerCase();
    final email = (docente.userEmail ?? '').trim().toLowerCase();
    return userId == usuario.id.trim().toLowerCase() ||
        email == usuario.email.trim().toLowerCase();
  }

  static bool podeEditar({required User? usuario, required Docente docente}) {
    return usuarioRepresentaDocente(usuario, docente);
  }

  static bool podeAvaliar({required User? usuario, required Docente docente}) {
    return usuario?.role == UserRole.chefeDepartamento &&
        !usuarioRepresentaDocente(usuario, docente);
  }

  static ResultadoOperacaoPlanoTrabalho salvarRascunho({
    required User? usuario,
    required Docente docente,
    required PlanoTrabalhoDocente plano,
    DateTime? agora,
  }) {
    if (!podeEditar(usuario: usuario, docente: docente)) {
      return const ResultadoOperacaoPlanoTrabalho(
        erro: 'Somente o próprio docente pode editar este PIT.',
      );
    }
    if (plano.status == StatusPlanoTrabalhoDocente.submetido ||
        plano.status == StatusPlanoTrabalhoDocente.aprovado) {
      return const ResultadoOperacaoPlanoTrabalho(
        erro: 'O PIT submetido ou aprovado não pode ser editado.',
      );
    }

    final instante = agora ?? DateTime.now();
    return ResultadoOperacaoPlanoTrabalho(
      plano: plano.copyWith(
        atualizadoEm: instante,
        criadoEm: plano.criadoEm ?? instante,
      ),
    );
  }

  static ResultadoOperacaoPlanoTrabalho submeter({
    required User? usuario,
    required Docente docente,
    required PlanoTrabalhoDocente plano,
    RegrasDistribuicaoCarga regras = const RegrasDistribuicaoCarga.ifma(),
    DateTime? agora,
  }) {
    if (!podeEditar(usuario: usuario, docente: docente)) {
      return const ResultadoOperacaoPlanoTrabalho(
        erro: 'Somente o próprio docente pode submeter este PIT.',
      );
    }
    if (plano.status == StatusPlanoTrabalhoDocente.aprovado) {
      return const ResultadoOperacaoPlanoTrabalho(
        erro: 'O PIT já foi aprovado.',
      );
    }

    final validacao = DocenteFormService.validarPlanoTrabalho(
      docente: docente,
      plano: plano,
      regras: regras,
    );
    if (!validacao.podeSubmeter) {
      return ResultadoOperacaoPlanoTrabalho(
        erro: 'Corrija as pendências antes de submeter o PIT.',
        validacao: validacao,
      );
    }

    final instante = agora ?? DateTime.now();
    return ResultadoOperacaoPlanoTrabalho(
      plano: plano.copyWith(
        status: StatusPlanoTrabalhoDocente.submetido,
        criadoEm: plano.criadoEm ?? instante,
        atualizadoEm: instante,
        submetidoEm: instante,
        limparParecerAvaliacao: true,
        limparAvaliacao: true,
      ),
      validacao: validacao,
    );
  }

  static ResultadoOperacaoPlanoTrabalho aprovar({
    required User? usuario,
    required Docente docente,
    required PlanoTrabalhoDocente plano,
    String? parecer,
    DateTime? agora,
  }) {
    if (!podeAvaliar(usuario: usuario, docente: docente)) {
      return const ResultadoOperacaoPlanoTrabalho(
        erro: 'Somente o Chefe de Departamento pode avaliar PITs de terceiros.',
      );
    }
    if (plano.status != StatusPlanoTrabalhoDocente.submetido) {
      return const ResultadoOperacaoPlanoTrabalho(
        erro: 'Apenas PITs submetidos podem ser aprovados.',
      );
    }
    final instante = agora ?? DateTime.now();
    return ResultadoOperacaoPlanoTrabalho(
      plano: plano.copyWith(
        status: StatusPlanoTrabalhoDocente.aprovado,
        parecerAvaliacao: parecer?.trim(),
        atualizadoEm: instante,
        avaliadoEm: instante,
      ),
    );
  }

  static ResultadoOperacaoPlanoTrabalho devolver({
    required User? usuario,
    required Docente docente,
    required PlanoTrabalhoDocente plano,
    required String motivo,
    DateTime? agora,
  }) {
    if (!podeAvaliar(usuario: usuario, docente: docente)) {
      return const ResultadoOperacaoPlanoTrabalho(
        erro: 'Somente o Chefe de Departamento pode avaliar PITs de terceiros.',
      );
    }
    if (plano.status != StatusPlanoTrabalhoDocente.submetido) {
      return const ResultadoOperacaoPlanoTrabalho(
        erro: 'Apenas PITs submetidos podem ser devolvidos.',
      );
    }
    if (motivo.trim().isEmpty) {
      return const ResultadoOperacaoPlanoTrabalho(
        erro: 'Informe o motivo da devolução.',
      );
    }
    final instante = agora ?? DateTime.now();
    return ResultadoOperacaoPlanoTrabalho(
      plano: plano.copyWith(
        status: StatusPlanoTrabalhoDocente.devolvido,
        parecerAvaliacao: motivo.trim(),
        atualizadoEm: instante,
        avaliadoEm: instante,
      ),
    );
  }
}
