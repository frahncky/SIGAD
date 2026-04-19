import 'configuracoes_models.dart';

abstract final class ConfiguracoesService {
  static ConfiguracoesData defaultData() {
    return const ConfiguracoesData(
      notificacoesAtivas: true,
      modoDark: false,
      biometriaAtiva: false,
      backupAutomaticoAtivo: true,
      idioma: 'Portugues (Brasil)',
      tamanhoFonte: 'Medio',
      nomePerfil: 'Joao Silva',
      cargoPerfil: 'Coordenador Academico',
      emailUsuario: 'joao.silva@universidade.edu.br',
      ultimaAlteracaoSenha: '20/02/2026',
      proximoBackup: '25/04/2026',
      ultimoBackup: '20/04/2026 as 14:30',
      problemasReportados: 0,
    );
  }

  static String dataAtual() {
    final agora = DateTime.now();
    final dia = agora.day.toString().padLeft(2, '0');
    final mes = agora.month.toString().padLeft(2, '0');
    final ano = agora.year.toString();
    return '$dia/$mes/$ano';
  }

  static String dataHoraAtual() {
    final agora = DateTime.now();
    final dia = agora.day.toString().padLeft(2, '0');
    final mes = agora.month.toString().padLeft(2, '0');
    final ano = agora.year.toString();
    final hora = agora.hour.toString().padLeft(2, '0');
    final minuto = agora.minute.toString().padLeft(2, '0');
    return '$dia/$mes/$ano as $hora:$minuto';
  }

  static String dataFutura(int dias) {
    final data = DateTime.now().add(Duration(days: dias));
    final dia = data.day.toString().padLeft(2, '0');
    final mes = data.month.toString().padLeft(2, '0');
    final ano = data.year.toString();
    return '$dia/$mes/$ano';
  }

  static String? validarPerfil({
    required String nome,
    required String cargo,
  }) {
    if (nome.trim().isEmpty || cargo.trim().isEmpty) {
      return 'Preencha nome e cargo';
    }
    return null;
  }

  static String? validarEmail(String email) {
    final emailLimpo = email.trim();
    final hasAt = emailLimpo.contains('@');
    final hasEspaco = emailLimpo.contains(' ');
    final partes = emailLimpo.split('@');
    final dominioValido =
        partes.length == 2 &&
        partes[1].contains('.') &&
        !partes[1].startsWith('.') &&
        !partes[1].endsWith('.');
    final emailValido = hasAt && !hasEspaco && dominioValido;

    if (!emailValido) {
      return 'Informe um email valido';
    }
    return null;
  }

  static String? validarAlteracaoSenha({
    required String senhaAtual,
    required String novaSenha,
    required String confirmarSenha,
  }) {
    if (senhaAtual.trim().isEmpty) {
      return 'Informe a senha atual';
    }

    if (novaSenha.trim().length < 6) {
      return 'A nova senha deve ter ao menos 6 caracteres';
    }

    if (novaSenha.trim() != confirmarSenha.trim()) {
      return 'A confirmacao da senha nao confere';
    }

    return null;
  }

  static String? validarRelatoProblema({
    required String titulo,
    required String descricao,
  }) {
    if (titulo.trim().isEmpty || descricao.trim().isEmpty) {
      return 'Preencha titulo e descricao';
    }
    return null;
  }
}
