// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get cancelar => 'Cancel';

  @override
  String get fechar => 'Close';

  @override
  String get sair => 'Sign out';

  @override
  String get verTodas => 'See all';

  @override
  String get verTudo => 'See all';

  @override
  String get tentarNovamente => 'Try again';

  @override
  String get acessoRapido => 'Quick access';

  @override
  String get navVisaoGeral => 'Overview';

  @override
  String get navVisaoGeralSub => 'Indicators, priorities and shortcuts';

  @override
  String get navBatePapo => 'Chat';

  @override
  String get navBatePapoSub => 'One-to-one and group conversations';

  @override
  String get navDemandas => 'Requests';

  @override
  String get navDemandasSub => 'Requests, deadlines and owners';

  @override
  String get navProfessores => 'Faculty';

  @override
  String get navProfessoresSub => 'Records, status and assigned workload';

  @override
  String get navTarefas => 'Tasks';

  @override
  String get navTarefasSub => 'Activity tracking board';

  @override
  String get navLaboratorios => 'Laboratories';

  @override
  String get navLaboratoriosSub => 'Occupancy, bookings and conflicts';

  @override
  String get navCargaDocente => 'Teaching load';

  @override
  String get navCargaDocenteSub => 'Distribution of classes and activities';

  @override
  String get navAtividades => 'Activities';

  @override
  String get navAtividadesSub => 'Teaching, research, outreach and management';

  @override
  String get navRelatorios => 'Reports';

  @override
  String get navRelatoriosSub => 'Management indicators and exports';

  @override
  String get navConfiguracoes => 'Settings';

  @override
  String get navConfiguracoesSub => 'Account, preferences and permissions';

  @override
  String get navCalendario => 'Calendar';

  @override
  String get navAnotacoes => 'Notes';

  @override
  String get navMais => 'More';

  @override
  String get navMural => 'Department board';

  @override
  String get notificacoes => 'Notifications';

  @override
  String get perfil => 'Profile';

  @override
  String get nenhumaNotificacao => 'No notifications right now.';

  @override
  String get buscarModulo => 'Search module';

  @override
  String get nenhumModulo => 'No module found.';

  @override
  String get confirmarSaida => 'Confirm sign out';

  @override
  String get confirmarSaidaMensagem => 'Are you sure you want to sign out?';

  @override
  String get perfilProfessor => 'Professor';

  @override
  String get perfilCoordenador => 'Program Coordinator';

  @override
  String get perfilServidor => 'Administrative Staff';

  @override
  String get perfilChefe => 'Head of Department';

  @override
  String get entrar => 'Sign in';

  @override
  String get perfilDemonstracao => 'Demo profile';

  @override
  String get emailInstitucional => 'Institutional email';

  @override
  String get senha => 'Password';

  @override
  String get mostrarSenha => 'Show password';

  @override
  String get ocultarSenha => 'Hide password';

  @override
  String get recuperacaoSenhaAviso =>
      'Password recovery will be linked to the institutional service.';

  @override
  String get esqueciSenha => 'Forgot my password';

  @override
  String get acessoDemo => 'Demo access for the selected profile';

  @override
  String get preenchaEmailSenha => 'Enter your email and password.';

  @override
  String get emailInvalido => 'Enter a valid email.';

  @override
  String get senhaCurta => 'The password must have at least 4 characters.';

  @override
  String get autenticacaoIndisponivel =>
      'Institutional sign-in is unavailable. The integration with the access service is not finished yet.';

  @override
  String get erroAcessoDemo => 'Could not sign in with demo access.';

  @override
  String get loginTitulo =>
      'Academic and department management at IFMA — São Luís–Monte Castelo Campus.';

  @override
  String get loginSubtitulo =>
      'Plan the DEE activities: teaching load, laboratories, meetings and requests.';

  @override
  String get loginDestaquePlanejamento => 'Integrated planning';

  @override
  String get loginDestaqueLaboratorios => 'Laboratory management';

  @override
  String get loginDestaqueIndicadores => 'Indicators and reports';

  @override
  String get boasVindas => 'Welcome';

  @override
  String get avisos => 'Notices';

  @override
  String quantidadeAvisos(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count notices',
      one: '1 notice',
    );
    return '$_temp0';
  }

  @override
  String get verTodosAvisos => 'See all notices';

  @override
  String get resumoDepartamento => 'Department summary';

  @override
  String get bomDia => 'Good morning';

  @override
  String get boaTarde => 'Good afternoon';

  @override
  String get boaNoite => 'Good evening';

  @override
  String saudacaoComNome(String saudacao, String nome) {
    return '$saudacao, $nome!';
  }

  @override
  String saudacaoSemNome(String saudacao) {
    return '$saudacao!';
  }

  @override
  String get fraseSemCadastro =>
      'Every small delivery today builds the department of tomorrow.';

  @override
  String get departamentoCampus =>
      'Department of Electrical and Electronics · IFMA Monte Castelo Campus';

  @override
  String mostrarSlide(String rotulo) {
    return 'Show $rotulo';
  }

  @override
  String get dadosIndisponiveis => 'Data unavailable. Pull to refresh.';

  @override
  String get atualizandoInformacoes => 'Updating information';

  @override
  String atividadesRegistradas(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count activities recorded',
      one: '1 activity recorded',
    );
    return '$_temp0';
  }

  @override
  String itensFluxo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count items in the workflow',
      one: '1 item in the workflow',
    );
    return '$_temp0';
  }

  @override
  String demandasRegistradas(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count requests recorded',
      one: '1 request recorded',
    );
    return '$_temp0';
  }

  @override
  String get atividadesDepartamento => 'Department activities';

  @override
  String get quadroTrabalho => 'Work board';

  @override
  String get demandasDepartamento => 'Department requests';

  @override
  String get acessoDepartamento => 'Department access';

  @override
  String get acessoDepartamentoSub =>
      'Information shown according to your profile';

  @override
  String get atencaoAgora => 'Needs attention';

  @override
  String get atencaoAgoraSub => 'Open items sorted by impact';

  @override
  String get nenhumaDemandaAberta => 'No open requests.';

  @override
  String responsavelPrazo(String responsavel, String prazo) {
    return '$responsavel • due $prazo';
  }

  @override
  String get proximasAtividades => 'Upcoming activities';

  @override
  String get proximasAtividadesSub => 'Commitments that still need attention';

  @override
  String get nenhumaAtividadeAberta => 'No open activities.';

  @override
  String get atualizandoVisao => 'Updating operational view...';

  @override
  String get erroIndicadores => 'Could not update the indicators.';

  @override
  String get escolhaAtalhos =>
      'Choose which menu shortcuts appear on the overview.';

  @override
  String get personalizarAtalhos => 'Customize shortcuts';

  @override
  String get nenhumAtalho =>
      'No shortcut selected. Tap the icon above to choose.';

  @override
  String get minhaConta => 'My account';

  @override
  String get nome => 'Name';

  @override
  String get email => 'Email';

  @override
  String get perfilAcesso => 'Access profile';

  @override
  String get aparenciaLeitura => 'Appearance and reading';

  @override
  String get modoNoturno => 'Dark mode';

  @override
  String get modoNoturnoSub => 'Dark background, easier on the eyes at night';

  @override
  String get tamanhoTexto => 'Text size';

  @override
  String get tamanhoNormal => 'Normal';

  @override
  String get tamanhoMedio => 'Medium';

  @override
  String get tamanhoGrande => 'Large';

  @override
  String get tamanhoMuitoGrande => 'Extra large';

  @override
  String get idioma => 'Language';

  @override
  String get idiomaAutomatico => 'Automatic (phone language)';

  @override
  String get departamento => 'Department';

  @override
  String get muralDepartamentoSub =>
      'Dashboard notices and motivational quotes';

  @override
  String get sobre => 'About';

  @override
  String get sobreSigad => 'About SIGAD';

  @override
  String versaoBuild(String versao) {
    return 'Version $versao';
  }

  @override
  String get sairDaConta => 'Sign out';

  @override
  String get fecharSobre => 'Close about SIGAD';

  @override
  String get versao => 'Version';

  @override
  String get desenvolvidoPor => 'Developed by';

  @override
  String get equipeDesenvolvimento => 'SIGAD Development Team';

  @override
  String get dataLancamento => 'Release date';

  @override
  String get compatibilidade => 'Compatibility';

  @override
  String get sobreDescricao =>
      'SIGAD is an integrated academic management system designed to streamline administrative and academic processes.';

  @override
  String get sairPergunta => 'Are you sure you want to sign out?';

  @override
  String get facaLogin => 'Sign in to access settings.';
}
