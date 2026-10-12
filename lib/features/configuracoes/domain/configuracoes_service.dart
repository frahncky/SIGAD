import 'configuracoes_models.dart';

abstract final class ConfiguracoesService {
  static const List<int> opcoesAntecedenciaMinutos = [
    5,
    10,
    15,
    20,
    30,
    45,
    60,
  ];

  static ConfiguracoesData defaultData() {
    return const ConfiguracoesData(
      notificacoesAtivas: true,
      notificarAntesDaDisciplina: true,
      antecedenciaNotificacaoMinutos: 15,
      modoDark: false,
      biometriaAtiva: false,
      backupAutomaticoAtivo: true,
      idioma: 'Automático',
      tamanhoFonte: 'Médio',
      nomePerfil: 'Usuário Demonstrativo',
      cargoPerfil: 'Coordenação dos Cursos do DEE',
      emailUsuario: 'usuario.demo@ifma.edu.br',
      ultimaAlteracaoSenha: '20/02/2026',
      proximoBackup: '25/04/2026',
      ultimoBackup: '20/04/2026 às 14:30',
      problemasReportados: 0,
      agendaCompromissos: [],
    );
  }

  static String? validarAntecedenciaDisciplina(int minutos) {
    if (!opcoesAntecedenciaMinutos.contains(minutos)) {
      return 'Selecione uma antecedência válida';
    }
    return null;
  }

  static ConfiguracoesData adicionarConviteNaAgenda({
    required ConfiguracoesData data,
    required CompromissoAgenda convite,
  }) {
    final compromissos = List<CompromissoAgenda>.from(data.agendaCompromissos)
      ..add(convite);

    return data.copyWith(agendaCompromissos: compromissos);
  }

  static ConfiguracoesData atualizarStatusConvite({
    required ConfiguracoesData data,
    required String compromissoId,
    required StatusConviteAgenda status,
  }) {
    final atualizados = data.agendaCompromissos
        .map(
          (item) => item.id == compromissoId
              ? item.copyWith(statusConvite: status)
              : item,
        )
        .toList(growable: false);

    return data.copyWith(agendaCompromissos: atualizados);
  }

  static List<CompromissoAgenda> filtrarAgendaPorPeriodo({
    required List<CompromissoAgenda> compromissos,
    required DateTime agora,
    required String periodo,
  }) {
    if (periodo == 'Todos') return compromissos;

    return compromissos
        .where((item) {
          final inicio = DateTime.tryParse(item.inicioIso);
          if (inicio == null) return false;

          if (periodo == 'Hoje') {
            return inicio.year == agora.year &&
                inicio.month == agora.month &&
                inicio.day == agora.day;
          }

          if (periodo == 'Semana') {
            final monday = agora.subtract(
              Duration(days: agora.weekday - DateTime.monday),
            );
            final sunday = monday.add(const Duration(days: 6));
            final dayOnly = DateTime(inicio.year, inicio.month, inicio.day);
            final mondayOnly = DateTime(monday.year, monday.month, monday.day);
            final sundayOnly = DateTime(sunday.year, sunday.month, sunday.day);
            return !dayOnly.isBefore(mondayOnly) &&
                !dayOnly.isAfter(sundayOnly);
          }

          return true;
        })
        .toList(growable: false);
  }

  static List<CompromissoAgenda> lembretesPendentesProfessor({
    required ConfiguracoesData data,
    required String userId,
    required DateTime agora,
  }) {
    if (!data.notificacoesAtivas || !data.notificarAntesDaDisciplina) {
      return const [];
    }

    return data.agendaCompromissos
        .where((item) {
          if (item.destinatarioUserId.isNotEmpty &&
              item.destinatarioUserId != userId) {
            return false;
          }
          if (item.statusConvite == StatusConviteAgenda.recusado) return false;

          final inicio = DateTime.tryParse(item.inicioIso);
          if (inicio == null) return false;

          final diff = inicio.difference(agora).inMinutes;
          return diff >= 0 && diff <= data.antecedenciaNotificacaoMinutos;
        })
        .toList(growable: false);
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
    return '$dia/$mes/$ano às $hora:$minuto';
  }

  static String dataFutura(int dias) {
    final data = DateTime.now().add(Duration(days: dias));
    final dia = data.day.toString().padLeft(2, '0');
    final mes = data.month.toString().padLeft(2, '0');
    final ano = data.year.toString();
    return '$dia/$mes/$ano';
  }

  static String? validarPerfil({required String nome, required String cargo}) {
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
      return 'Informe um email válido';
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
      return 'A confirmação da senha não confere';
    }

    return null;
  }

  static String? validarRelatoProblema({
    required String titulo,
    required String descricao,
  }) {
    if (titulo.trim().isEmpty || descricao.trim().isEmpty) {
      return 'Preencha título e descrição';
    }
    return null;
  }
}
