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
      'Integrated Academic and\nDepartment Management System';

  @override
  String get logotipoSigad => 'SIGAD logo';

  @override
  String get loginSubtitulo =>
      'Plan the department activities: teaching load, laboratories, meetings and requests.';

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
  String get departamentoCampus => 'Department of Electrical and Electronics';

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

  @override
  String get salvar => 'Save';

  @override
  String get excluir => 'Delete';

  @override
  String get continuar => 'Continue';

  @override
  String get reservar => 'Book';

  @override
  String get hoje => 'Today';

  @override
  String get feriado => 'Holiday';

  @override
  String get detalhes => 'Details';

  @override
  String get erroSalvar => 'Could not save. Try again.';

  @override
  String get diaSeg => 'Mon';

  @override
  String get diaTer => 'Tue';

  @override
  String get diaQua => 'Wed';

  @override
  String get diaQui => 'Thu';

  @override
  String get diaSex => 'Fri';

  @override
  String get diaSegunda => 'Monday';

  @override
  String get diaTerca => 'Tuesday';

  @override
  String get diaQuarta => 'Wednesday';

  @override
  String get diaQuinta => 'Thursday';

  @override
  String get diaSexta => 'Friday';

  @override
  String get turnoTodos => 'All';

  @override
  String get turnoManha => 'Morning';

  @override
  String get turnoTarde => 'Afternoon';

  @override
  String get turnoNoite => 'Evening';

  @override
  String get turnoMatutino => 'Morning';

  @override
  String get turnoVespertino => 'Afternoon';

  @override
  String get turnoNoturno => 'Evening';

  @override
  String mesAbrev(String mes) {
    String _temp0 = intl.Intl.selectLogic(mes, {
      '1': 'Jan',
      '2': 'Feb',
      '3': 'Mar',
      '4': 'Apr',
      '5': 'May',
      '6': 'Jun',
      '7': 'Jul',
      '8': 'Aug',
      '9': 'Sep',
      '10': 'Oct',
      '11': 'Nov',
      'other': 'Dec',
    });
    return '$_temp0';
  }

  @override
  String get labAgenda => 'Schedule';

  @override
  String get labErroCarregar => 'Could not load the bookings.';

  @override
  String get labIrParaSemana => 'Go to the week of';

  @override
  String get labSugestoes => 'Suggested time slots';

  @override
  String get labSugestoesSub => 'Weekly occupancy and free slots';

  @override
  String get labSomenteDocentes =>
      'Only teaching profiles can book time slots.';

  @override
  String get labHorarioOcupado =>
      'This slot is already taken. Choose another free slot.';

  @override
  String labReservaFeita(String lab, String dia, String data, String horario) {
    return 'Booked: $lab, $dia $data, $horario.';
  }

  @override
  String labHorariosReservados(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count slots booked.',
      one: '1 slot booked.',
    );
    return '$_temp0';
  }

  @override
  String labJaOcupados(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count were already taken.',
      one: '1 was already taken.',
    );
    return '$_temp0';
  }

  @override
  String get labErroOperacao => 'Could not complete the operation. Try again.';

  @override
  String get labEditarOcorrencias => 'Edit occurrences';

  @override
  String labRepeteEditar(int count) {
    return 'This booking repeats $count times. Select which ones to edit.';
  }

  @override
  String labRepeteExcluir(int count) {
    return 'This booking repeats $count times. Select which ones to delete.';
  }

  @override
  String get labNovoHorarioOcupado =>
      'Could not save: the new slot is already taken in all selected occurrences.';

  @override
  String get labReservaAtualizada => 'Booking updated.';

  @override
  String labOcorrenciasAtualizadas(int count) {
    return '$count occurrences updated.';
  }

  @override
  String labNaoMovidas(int count) {
    return '$count could not be moved (slot taken).';
  }

  @override
  String get labExcluirOcorrencias => 'Delete occurrences';

  @override
  String get labRevisarExclusao => 'Review deletion';

  @override
  String get labExcluirReserva => 'Delete booking';

  @override
  String labRemoverUma(String ocorrencia, String lab) {
    return 'Remove the booking on $ocorrencia at $lab?';
  }

  @override
  String labRemoverVarias(int count, String lab) {
    return 'Remove the $count selected occurrences at $lab?';
  }

  @override
  String get labReservaRemovida => 'Booking removed.';

  @override
  String labOcorrenciasRemovidas(int count) {
    return '$count occurrences removed.';
  }

  @override
  String get labFacaLogin => 'Sign in to book time slots.';

  @override
  String get labSemSugestoes => 'There are no suggested free slots this week.';

  @override
  String get labReservarSugeridoTitulo => 'Book the suggested slot?';

  @override
  String get labReservaNoSeuNome => 'The booking will be in your name.';

  @override
  String get labSugestaoIndisponivel =>
      'The suggestion is no longer available. Try again.';

  @override
  String get labEditarReserva => 'Edit booking';

  @override
  String get labDisciplinaOpcional => 'Course (optional)';

  @override
  String get labDiaSemana => 'Day of the week';

  @override
  String get labHorario => 'Time';

  @override
  String get labHorarioJaOcupado => 'Slot already taken';

  @override
  String get labLaboratorio => 'Laboratory';

  @override
  String labSemanaMesmoMes(int inicio, int fim, String mes) {
    return '$mes $inicio–$fim';
  }

  @override
  String labSemanaDoisMeses(
    int inicio,
    String mesInicio,
    int fim,
    String mesFim,
  ) {
    return '$mesInicio $inicio – $mesFim $fim';
  }

  @override
  String get labSemanaAnterior => 'Previous week';

  @override
  String get labProximaSemana => 'Next week';

  @override
  String labSemanaSemantica(String rotulo, String ano) {
    return 'Week of $rotulo, $ano. Choose another date';
  }

  @override
  String get labEstaSemana => 'This week';

  @override
  String get labHorarioLivre => 'Free slot';

  @override
  String get labMinhaReserva => 'My booking';

  @override
  String get labReservadoPorOutro => 'Booked by someone else';

  @override
  String get labArrasteAgenda => 'Swipe the schedule sideways to see all days.';

  @override
  String labCabecalhoDia(String dia, String data) {
    return '$dia, $data';
  }

  @override
  String get labHojeSufixo => ', today';

  @override
  String labFeriadoSufixo(String nome) {
    return ', holiday: $nome';
  }

  @override
  String labCelula(
    String dia,
    int numero,
    String turno,
    int periodo,
    String horario,
  ) {
    return 'Cell $dia, day $numero, $turno, period $periodo, time $horario.';
  }

  @override
  String get labLivre => 'Free';

  @override
  String labReservadoPor(String nome) {
    return 'Booked by $nome';
  }

  @override
  String get labToqueDetalhes => 'Tap to see the booking details.';

  @override
  String get labToqueReservar => 'Tap to book.';

  @override
  String get labDetalhesReserva => 'Booking details';

  @override
  String get labReservaDeLaboratorio => 'Laboratory booking';

  @override
  String get labSuaReserva => 'Your booking';

  @override
  String get labData => 'Date';

  @override
  String get labReservadoPorRotulo => 'Booked by';

  @override
  String get labSoQuemFez =>
      'Only the person who booked it or the department head can change it.';

  @override
  String get labAcessoRestrito => 'Restricted access';

  @override
  String get labAcessoRestritoMsg =>
      'This module is available to professors, coordinators and the head of department.';

  @override
  String get labOtimizacao => 'Laboratory optimization';

  @override
  String get labReservarSugestao => 'Book suggestion';

  @override
  String labOcupadoNaSemana(String lab) {
    return 'occupied this week at $lab';
  }

  @override
  String labIndicadorOcupacao(String lab, String taxa, int livres) {
    return '$lab: $taxa% · $livres free';
  }

  @override
  String get labSugestoesSlots => 'Suggested free slots';

  @override
  String get labRecomendacoesCruzadas =>
      'Recommendations based on teaching load';

  @override
  String labRecomendacao(String nome, String lab, String dia, String horario) {
    return '$nome: prioritize $lab on $dia $horario to ease the load of practical classes.';
  }

  @override
  String get labAvisoInterditado =>
      'This laboratory is closed. Check with the department head before booking.';

  @override
  String get labAvisoManutencao =>
      'This laboratory is under maintenance. Make sure it will be available before booking.';

  @override
  String labTodosCount(int count) {
    return 'All ($count)';
  }

  @override
  String labStatusCount(String status, int count) {
    return '$status ($count)';
  }

  @override
  String get labOcorrenciaRegistrada => 'Issue reported.';

  @override
  String get labMarcarResolvida => 'Mark as resolved?';

  @override
  String labDeixaraDeContar(String titulo) {
    return '\"$titulo\" will no longer count as active.';
  }

  @override
  String get labResolvida => 'Resolved';

  @override
  String get labOcorrenciaResolvidaMsg => 'Issue marked as resolved.';

  @override
  String get labReportarProblema => 'Report a problem';

  @override
  String get labProximasReservas => 'Upcoming bookings';

  @override
  String get labVerAgenda => 'View schedule';

  @override
  String get labNenhumaReservaFutura =>
      'No upcoming bookings for this laboratory.';

  @override
  String get labEquipamentos => 'Equipment';

  @override
  String get labNenhumEquipamento => 'No equipment registered.';

  @override
  String labUnidades(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count units',
      one: '1 unit',
    );
    return '$_temp0';
  }

  @override
  String get labManutencao => 'Maintenance';

  @override
  String get labConcluida => 'Completed';

  @override
  String get labEmAndamento => 'In progress';

  @override
  String get labOcorrencias => 'Issues';

  @override
  String labResolverOcorrencia(String titulo) {
    return 'Resolve issue: $titulo';
  }

  @override
  String get labResolver => 'Resolve';

  @override
  String get labOperando => 'Operating';

  @override
  String get labEmManutencao => 'Under maintenance';

  @override
  String get labInterditado => 'Closed';

  @override
  String get labReservasNoMes => 'Bookings this month';

  @override
  String get labOcorrenciasAtivas => 'Active issues';

  @override
  String labCapacidadePessoas(int count) {
    return 'Capacity: $count people';
  }

  @override
  String labPessoas(int count) {
    return '$count people';
  }

  @override
  String labEquipamentosDisponiveisCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pieces of equipment available',
      one: '1 piece of equipment available',
    );
    return '$_temp0';
  }

  @override
  String labReservasNesteMes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count bookings this month',
      one: '1 booking this month',
    );
    return '$_temp0';
  }

  @override
  String labOcorrenciasAtivasCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count active issues',
      one: '1 active issue',
    );
    return '$_temp0';
  }

  @override
  String get labCapacidade => 'Capacity';

  @override
  String get labResponsavelTecnico => 'Technical manager';

  @override
  String get labEquipamentosDisponiveis => 'Available equipment';

  @override
  String get labNenhumLabStatus => 'No laboratory found with this status.';

  @override
  String get labDisponivel => 'Available';

  @override
  String get labEmUso => 'In use';

  @override
  String get labIndisponivel => 'Unavailable';

  @override
  String get labRegistrarOcorrencia => 'Report issue';

  @override
  String get labOQueAconteceu => 'What happened?';

  @override
  String get labExemploProblema =>
      'E.g.: The oscilloscope at bench 3 won\'t turn on';

  @override
  String get labDescrevaProblema => 'Describe the problem in a few words.';

  @override
  String get labDetalhesOpcional => 'Details (optional)';

  @override
  String get labDetalhesHint => 'Where, since when and what has been tried.';

  @override
  String get labSemDadosPessoais =>
      'Do not include names, student IDs or personal data.';

  @override
  String get labSoEstaSemana => 'This week only';

  @override
  String labEstaEMais(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'This and $count more weeks',
      one: 'This and 1 more week',
    );
    return '$_temp0';
  }

  @override
  String get labReservarHorario => 'Book a slot';

  @override
  String labHorarioEMais(String horario, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$horario and $count more slots',
      one: '$horario and 1 more slot',
    );
    return '$_temp0';
  }

  @override
  String get labRepetir => 'Repeat';

  @override
  String labRepeticaoAte(String data) {
    return 'Repetition goes at most until $data, the end of the month.';
  }

  @override
  String get labOutrosHorarios => 'Book other slots on this day';

  @override
  String get paginaNaoEncontrada => 'Page not found';

  @override
  String get paginaNaoEncontradaMensagem =>
      'The address does not match any SIGAD module.';

  @override
  String get voltarVisaoGeral => 'Back to overview';

  @override
  String get maisCargaDocenteDesc => 'Plan and track teaching hours.';

  @override
  String get maisProfessoresDesc => 'Manage department faculty.';

  @override
  String get maisLaboratoriosDesc => 'Resources, bookings and occupancy.';

  @override
  String get maisReunioes => 'Meetings';

  @override
  String get maisReunioesDesc => 'Agendas, minutes and attendees.';

  @override
  String get maisDemandasDesc => 'Track and manage requests.';

  @override
  String get maisNoticias => 'News';

  @override
  String get maisNoticiasDesc => 'Announcements and bulletins.';

  @override
  String get maisRelatoriosDesc => 'Department indicators and data.';

  @override
  String get maisCursos => 'Courses';

  @override
  String get maisCursosDesc => 'Subjects and academic offerings.';

  @override
  String get maisAdministracao => 'Administration';

  @override
  String get maisAgendaIntegrada => 'Integrated calendar';

  @override
  String get maisAgendaIntegradaDesc =>
      'View department events and appointments.';

  @override
  String get maisConfiguracoesDesc => 'Customize app preferences.';

  @override
  String get maisAjuda => 'Help';

  @override
  String get maisAjudaDesc => 'Help center, tutorials and support.';

  @override
  String get maisAvisosImportantes => 'Important notices';

  @override
  String get maisNenhumAviso => 'No notices right now.';

  @override
  String get maisCentralAjuda => 'Help center';

  @override
  String get maisCentralAjudaMensagem =>
      'Tutorials and support will be available soon. For urgent questions, open a ticket with the campus IT team.';

  @override
  String get maisDepartamento => 'DEPARTMENT';

  @override
  String get maisVerTodosAvisos => 'See all notices';

  @override
  String get maisPrecisaSuporte => 'Need support?';

  @override
  String get maisFaleComTi => 'Contact the campus IT team.';

  @override
  String get maisAbrirChamado => 'Open a ticket';

  @override
  String get muralErroCarregar =>
      'Could not read the saved board. Editing is locked so data is not overwritten.';

  @override
  String get muralFrases => 'Quotes';

  @override
  String get muralAcessoNegado =>
      'Only the department head can manage the board.';

  @override
  String get muralNovoAviso => 'New notice';

  @override
  String get muralNenhumAviso =>
      'No notices yet.\nWithout notices, the dashboard shows only the welcome message.';

  @override
  String get muralDesativado => 'Disabled';

  @override
  String get muralAgendado => 'Scheduled';

  @override
  String get muralEncerrado => 'Ended';

  @override
  String get muralNoAr => 'Live';

  @override
  String get muralTodosPerfis => 'All profiles';

  @override
  String get muralFixado => 'Pinned';

  @override
  String get muralModeloInformativo => 'Information';

  @override
  String get muralModeloImportante => 'Important';

  @override
  String get muralModeloEvento => 'Event';

  @override
  String get muralModeloLembrete => 'Reminder';

  @override
  String get muralExibirAPartirDe => 'Show from';

  @override
  String get muralExibirAte => 'Show until';

  @override
  String get muralDataFinalInvalida =>
      'The end date must be on or after the start date.';

  @override
  String get muralAvisoPublicado => 'Notice published.';

  @override
  String get muralErroSalvarAviso => 'Could not save the notice.';

  @override
  String get muralExcluirAvisoTitulo => 'Delete notice?';

  @override
  String muralExcluirAvisoMensagem(String titulo) {
    return '\"$titulo\" will no longer be shown.';
  }

  @override
  String get muralAvisoExcluido => 'Notice deleted.';

  @override
  String get muralErroExcluirAviso => 'Could not delete the notice.';

  @override
  String get muralEditarAviso => 'Edit notice';

  @override
  String get muralModelo => 'Type';

  @override
  String get muralTitulo => 'Title';

  @override
  String get muralInformeTitulo => 'Enter the notice title.';

  @override
  String get muralConteudo => 'Content';

  @override
  String get muralConteudoDica => 'Write the full notice for the department.';

  @override
  String get muralInformeConteudo => 'Write the notice content.';

  @override
  String get muralQuemVe => 'Who sees it';

  @override
  String get muralTodos => 'Everyone';

  @override
  String get muralPeriodoExibicao => 'Display period';

  @override
  String get muralAPartirDe => 'From';

  @override
  String get muralImediatamente => 'Immediately';

  @override
  String get muralLimparDataInicial => 'Clear start date';

  @override
  String get muralAte => 'Until';

  @override
  String get muralSemDataSair => 'No end date';

  @override
  String get muralLimparDataFinal => 'Clear end date';

  @override
  String get muralFixarTopo => 'Pin to top';

  @override
  String get muralFixarTopoSub => 'Shown before other notices.';

  @override
  String get muralAtivo => 'Active';

  @override
  String get muralAtivoSub => 'Turn off to hide without deleting.';

  @override
  String get muralPreviaPainel => 'Dashboard preview';

  @override
  String get muralPreviaAvisoSub =>
      'This is how the notice appears in the top card for those who can see it.';

  @override
  String get muralPreviaTitulo => 'Notice title';

  @override
  String get muralPreviaConteudo => 'The notice content appears here.';

  @override
  String get muralPublicarAviso => 'Publish notice';

  @override
  String get muralExcluirAviso => 'Delete notice';

  @override
  String get muralNovaFrase => 'New quote';

  @override
  String get muralEditarFrase => 'Edit quote';

  @override
  String get muralTrocarFrase => 'Change the quote';

  @override
  String get muralPeriodoDiaria => 'Every day';

  @override
  String get muralPeriodoSemanal => 'Every week';

  @override
  String get muralPeriodoQuinzenal => 'Every 15 days';

  @override
  String get muralPeriodoMensal => 'Every month';

  @override
  String get muralErroFrequencia => 'Could not save the frequency.';

  @override
  String get muralFraseEmExibicao => 'Quote on display';

  @override
  String get muralNenhumaFrase => 'No active quote.';

  @override
  String muralFrasesLista(int count) {
    return 'Quotes ($count) — active ones rotate';
  }

  @override
  String get muralFraseAtivaRodizio => 'Quote active in rotation';

  @override
  String get muralExcluirFrase => 'Delete quote';

  @override
  String get muralExcluirFraseTitulo => 'Delete quote?';

  @override
  String get muralErroSalvarFrase => 'Could not save the quote.';

  @override
  String get muralErroExcluirFrase => 'Could not delete the quote.';

  @override
  String get muralFrase => 'Quote';

  @override
  String get muralFraseDica => 'Write a short, motivating quote.';

  @override
  String get muralEscrevaFrase => 'Write the quote.';

  @override
  String get muralPreviaFraseSub =>
      'This is how the quote appears in the welcome card.';

  @override
  String get muralPreviaFrase => 'The quote appears here.';

  @override
  String get muralSalvarFrase => 'Save quote';
}
