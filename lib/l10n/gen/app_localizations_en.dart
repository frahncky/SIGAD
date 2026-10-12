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

  @override
  String get calAgendaCompleta => 'Full schedule';

  @override
  String get calResumoSemana => 'Week summary';

  @override
  String calPeriodoSemana(String inicio, String fim) {
    return '$inicio – $fim';
  }

  @override
  String get calVerAgenda => 'View schedule';

  @override
  String get calEventosAgendados => 'Scheduled events';

  @override
  String get calReservasLaboratorio => 'Lab bookings';

  @override
  String get calReuniaoMarcada => 'Scheduled meeting';

  @override
  String get calDepartamento => 'Department';

  @override
  String get calTipoItem => 'Item type';

  @override
  String get calTodos => 'All';

  @override
  String get calReuniao => 'Meeting';

  @override
  String get calLaboratorio => 'Laboratory';

  @override
  String get calComunicacao => 'Communication';

  @override
  String get calToqueParaAlterar => 'Tap to change';

  @override
  String calAulaPratica(String disciplina) {
    return 'Practical class – $disciplina';
  }

  @override
  String get calReservaLaboratorio => 'Lab booking';

  @override
  String calReservaDe(String laboratorio) {
    return 'Booking: $laboratorio';
  }

  @override
  String calResponsavel(String professor) {
    return 'Responsible: $professor';
  }

  @override
  String get calProximosCompromissos => 'Upcoming appointments';

  @override
  String get calVerTodos => 'See all';

  @override
  String get calNenhumaReservaFutura => 'No upcoming bookings found.';

  @override
  String get calAgendaDoDia => 'Day\'s schedule';

  @override
  String get calVerAgendaCompleta => 'View full schedule';

  @override
  String get calNenhumCompromisso => 'No appointments on this day.';

  @override
  String get calOcupacaoHoje => 'Lab occupancy (today)';

  @override
  String get calNenhumaReserva => 'No bookings yet.';

  @override
  String calHorariosReservados(int horas, int total) {
    return '$horas of $total slots booked this week';
  }

  @override
  String get calMesAnterior => 'Previous month';

  @override
  String get calProximoMes => 'Next month';

  @override
  String get calHoje => 'today';

  @override
  String calFeriado(String nome) {
    return 'holiday: $nome';
  }

  @override
  String calEventos(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count events',
      one: '1 event',
    );
    return '$_temp0';
  }

  @override
  String get notaGeral => 'General';

  @override
  String get notaReunioes => 'Meetings';

  @override
  String get notaPlanejamento => 'Planning';

  @override
  String get notaCargaHoraria => 'Teaching hours';

  @override
  String get notaEventos => 'Events';

  @override
  String get notaTodas => 'All';

  @override
  String get notaNova => 'New note';

  @override
  String get notaEditar => 'Edit note';

  @override
  String get notaExcluir => 'Delete note';

  @override
  String get notaExcluirMensagem =>
      'Are you sure you want to delete this note?';

  @override
  String get notaDica => 'Write down an idea, follow-up or reminder...';

  @override
  String get notaCategoria => 'Category';

  @override
  String get notaGerenciarFixadas => 'Manage pinned';

  @override
  String get notaNenhumaCriada => 'No notes created yet.';

  @override
  String get notaBuscar => 'Search notes, meetings, topics...';

  @override
  String get notaFixadas => 'Pinned';

  @override
  String get notaTodasAnotacoes => 'All notes';

  @override
  String get notaMaisRecentes => 'Newest';

  @override
  String get notaMaisAntigas => 'Oldest';

  @override
  String notaOrdenarPor(String ordem) {
    return 'Sort by: $ordem';
  }

  @override
  String get notaNenhumaEncontrada => 'No notes found.';

  @override
  String get notaVazio => 'No notes. Tap \"+\" to create one.';

  @override
  String get notaVazioDica =>
      'Use this space to record follow-ups, ideas and quick reminders.';

  @override
  String get notaCriarPrimeira => 'Create first note';

  @override
  String get notaDesafixar => 'Unpin';

  @override
  String get notaFixar => 'Pin note';

  @override
  String notaDataHora(String dia, String mes, String hora) {
    return '$mes/$dia at $hora';
  }

  @override
  String get chatFacaLogin => 'Sign in to use the chat.';

  @override
  String get chatNenhumUsuario => 'No users available to chat with.';

  @override
  String get chatConversas => 'Conversations';

  @override
  String get chatNovaConversa => 'New conversation';

  @override
  String get chatBuscarConversa => 'Search conversations';

  @override
  String get chatLimparBusca => 'Clear search';

  @override
  String get chatNenhumaEncontrada => 'No conversations found.';

  @override
  String get chatNenhumaAinda => 'No conversations yet.\nTap ✏️ to start one.';

  @override
  String get chatNenhumaMensagem => 'No messages yet.';

  @override
  String get chatDigiteMensagem => 'Type your message';

  @override
  String get chatEnviar => 'Send';

  @override
  String get chatVoltar => 'Back to conversations';

  @override
  String get chatSelecione => 'Select a conversation\nor start a new one';

  @override
  String get chatBuscarContato => 'Search by name, email or role';

  @override
  String get chatNenhumContato => 'No contacts found.';

  @override
  String chatDiaMes(String dia, String mes) {
    return '$mes/$dia';
  }

  @override
  String get demErroCarregar => 'Could not load the requests.';

  @override
  String get demErroCarregarTitulo => 'Could not load the data';

  @override
  String get demErroSalvar =>
      'Could not save the request. Your data was kept. Please try again.';

  @override
  String get demBuscar => 'Search requests';

  @override
  String get demBuscarDica => 'Search by title, description or owner';

  @override
  String get demBuscarExemplo => 'Title, description or owner';

  @override
  String demFiltrosAtivos(int count) {
    return 'Active filters: $count';
  }

  @override
  String get demFiltrar => 'Filter requests';

  @override
  String get demCarregando => 'Loading requests...';

  @override
  String get demNenhuma => 'No requests found';

  @override
  String get demLimparFiltrosDica => 'Try clearing the active filters.';

  @override
  String get demCrieNova => 'Create a new request to get started.';

  @override
  String get demLimparFiltros => 'Clear filters';

  @override
  String get demCriarNova => 'Create new request';

  @override
  String get demFiltros => 'Filters';

  @override
  String get demFecharFiltros => 'Close filters';

  @override
  String get demStatus => 'Status';

  @override
  String get demPrioridade => 'Priority';

  @override
  String get demOrdenacao => 'Sort order';

  @override
  String get demLimpar => 'Clear';

  @override
  String get demAplicar => 'Apply';

  @override
  String get demNova => 'New Request';

  @override
  String get demEditar => 'Edit Request';

  @override
  String get demFecharFormulario => 'Close request form';

  @override
  String get demTitulo => 'Title';

  @override
  String get demTituloDica => 'Enter the request title';

  @override
  String get demDescricao => 'Description';

  @override
  String get demDescricaoDica => 'Describe the request in detail';

  @override
  String get demProprietario => 'Owner';

  @override
  String get demStatusInicial => 'Initial status';

  @override
  String get demCriar => 'Create';

  @override
  String get demSalvando => 'Saving...';

  @override
  String get demCriada => 'Request created successfully!';

  @override
  String get demAtualizada => 'Request updated successfully!';

  @override
  String get demExcluida => 'Request deleted successfully!';

  @override
  String get demConfirmarExclusao => 'Confirm deletion';

  @override
  String demExcluirMensagem(String titulo) {
    return 'Are you sure you want to delete $titulo?';
  }

  @override
  String get demSemPermissaoCriar =>
      'Your profile is not allowed to create requests.';

  @override
  String get demSemPermissaoEditar =>
      'Your profile is not allowed to edit requests.';

  @override
  String get demSemPermissaoExcluir =>
      'Your profile is not allowed to delete requests.';

  @override
  String get demInformeTitulo => 'Enter the request title';

  @override
  String get demInformeDescricao => 'Enter the request description';

  @override
  String get demResumo => 'Requests summary';

  @override
  String get demNoTotal => 'Total';

  @override
  String get demAbertas => 'Open';

  @override
  String get demUrgentes => 'Urgent';

  @override
  String get demEditarAcao => 'Edit';

  @override
  String demAbrir(String titulo) {
    return 'Open request $titulo';
  }

  @override
  String get demFecharDetalhes => 'Close request details';

  @override
  String get demPrazo => 'Due date';

  @override
  String get demTodas => 'All';

  @override
  String get demStatusNovo => 'New';

  @override
  String get demStatusEmAndamento => 'In progress';

  @override
  String get demStatusAguardando => 'Waiting';

  @override
  String get demStatusRevisao => 'Review';

  @override
  String get demStatusConcluido => 'Done';

  @override
  String get demPrioridadeAlta => 'High';

  @override
  String get demPrioridadeMedia => 'Medium';

  @override
  String get demPrioridadeBaixa => 'Low';

  @override
  String get demOrdemPrazo => 'Nearest due date';

  @override
  String get demOrdemRecentes => 'Recently created';

  @override
  String get tarErroCarregar => 'Could not load the task board.';

  @override
  String get tarNovoCard => 'New card';

  @override
  String get tarCarregando => 'Loading task board...';

  @override
  String get tarNenhumCard => 'No cards yet';

  @override
  String get tarNenhumCardDica => 'Tap + to add the first card to the board.';

  @override
  String get tarCriarCard => 'Create card';

  @override
  String get tarArrasteDica =>
      'Swipe sideways to move between the board columns.';

  @override
  String tarExcluirCardMensagem(String titulo) {
    return 'Delete the card \"$titulo\"?';
  }

  @override
  String tarCardRemovido(String titulo) {
    return 'Card \"$titulo\" removed';
  }

  @override
  String get tarTituloDica => 'Enter the card title';

  @override
  String get tarColuna => 'Column';

  @override
  String get tarCardCriado => 'Card created successfully!';

  @override
  String get tarSolteAqui => 'Drop here';

  @override
  String tarCardSemantica(String titulo, String prioridade) {
    return 'Card: $titulo. Priority $prioridade.';
  }

  @override
  String get tarMaisAcoes => 'More card actions';

  @override
  String tarId(String id) {
    return 'ID: $id';
  }

  @override
  String tarColunaValor(String coluna) {
    return 'Column: $coluna';
  }

  @override
  String tarPrioridadeValor(String prioridade) {
    return 'Priority: $prioridade';
  }

  @override
  String get tarExcluirEsteCard => 'Are you sure you want to delete this card?';

  @override
  String get tarInformeTitulo => 'Enter the card title';

  @override
  String get tarColunaBacklog => 'Backlog';

  @override
  String get tarColunaEmProgresso => 'In Progress';

  @override
  String get tarColunaEmRevisao => 'In Review';

  @override
  String get tarColunaConcluido => 'Done';

  @override
  String get atvFiltrar => 'Filter activities';

  @override
  String get atvFecharFiltro => 'Close filter';

  @override
  String get atvErroCarregar => 'Could not load the activities.';

  @override
  String get atvBuscarDica => 'Search by title, description or owner';

  @override
  String get atvCarregando => 'Loading activities...';

  @override
  String get atvNenhuma => 'No activities found';

  @override
  String get atvNenhumaDica => 'Adjust the filters or create a new activity.';

  @override
  String get atvCriarNova => 'Create new activity';

  @override
  String get atvNova => 'New Activity';

  @override
  String get atvEditar => 'Edit Activity';

  @override
  String get atvFecharFormulario => 'Close form';

  @override
  String get atvTituloDica => 'Enter the activity title';

  @override
  String get atvDescricaoDica => 'Describe the activity in detail';

  @override
  String get atvResponsavel => 'Owner';

  @override
  String get atvCriada => 'Activity created successfully!';

  @override
  String get atvAtualizada => 'Activity updated successfully!';

  @override
  String get atvExcluida => 'Activity deleted successfully!';

  @override
  String get atvAgendaOperacional => 'Operational agenda';

  @override
  String get atvConcluidas => 'Completed';

  @override
  String get atvPendentes => 'Pending';

  @override
  String atvAbrir(String titulo) {
    return 'Open activity $titulo';
  }

  @override
  String get atvMaisAcoes => 'More activity actions';

  @override
  String get atvFecharDetalhes => 'Close activity details';

  @override
  String get atvData => 'Date';

  @override
  String get atvInformeTitulo => 'Enter the activity title';

  @override
  String get atvInformeDescricao => 'Enter the activity description';

  @override
  String get atvStatusConcluida => 'Completed';

  @override
  String get atvStatusEmProgresso => 'In progress';

  @override
  String get atvStatusAgendada => 'Scheduled';

  @override
  String get atvStatusPendente => 'Pending';

  @override
  String get relErroCarregar => 'Could not load the reports.';

  @override
  String relBaixado(String titulo) {
    return 'Report downloaded: $titulo';
  }

  @override
  String relLinkGerado(String titulo) {
    return 'Share link created for $titulo';
  }

  @override
  String get relBuscarDica => 'Search by title, description or author';

  @override
  String get relArrasteDica => 'Swipe sideways to see all statuses.';

  @override
  String get relDisponiveisConsulta => 'reports available';

  @override
  String get relCarregando => 'Loading reports...';

  @override
  String get relNenhum => 'No reports found';

  @override
  String get relNenhumDica => 'Adjust the filters to see results.';

  @override
  String get relSemPermissao =>
      'Your profile is not allowed to access reports.';

  @override
  String get relAcessoNegado => 'Access not allowed for this profile.';

  @override
  String get relCentral => 'Reports center';

  @override
  String get relDisponiveis => 'Available';

  @override
  String get relPublicados => 'Published';

  @override
  String get relEmRevisao => 'In review';

  @override
  String relVer(String titulo) {
    return 'View report $titulo';
  }

  @override
  String get relMaisAcoes => 'More report actions';

  @override
  String get relVisualizar => 'View';

  @override
  String get relBaixarPdf => 'Download PDF';

  @override
  String get relCompartilhar => 'Share';

  @override
  String get relFecharDetalhes => 'Close report details';

  @override
  String get relTipo => 'Report type';

  @override
  String get relAutor => 'Author';

  @override
  String get relDownloads => 'Downloads';

  @override
  String get relCompartilhamentos => 'Shares';

  @override
  String get relStatusTodos => 'All';

  @override
  String get relStatusPublicado => 'Published';

  @override
  String get relStatusAgendado => 'Scheduled';

  @override
  String get relStatusDisponivel => 'Available';

  @override
  String get relTipoAnaliseGeral => 'General Analysis';

  @override
  String get relTipoRecursosHumanos => 'Human Resources';

  @override
  String get relTipoDesempenho => 'Performance';

  @override
  String get relTipoInfraestrutura => 'Infrastructure';

  @override
  String get relTipoConformidade => 'Compliance';

  @override
  String get relPdfBaixadoAgora => 'PDF downloaded just now';

  @override
  String get relCompartilhadoAgora => 'Shared just now';

  @override
  String get cdBuscarDocente => 'Search teacher by name, email or department';

  @override
  String get cdOrdemCrescente => 'Ascending order';

  @override
  String get cdOrdemDecrescente => 'Descending order';

  @override
  String get cdNenhumDocente => 'No teachers found';

  @override
  String get cdAdicionarDocente => 'Add teacher';

  @override
  String get cdNovoDocente => 'New Teacher';

  @override
  String get cdEditarDocente => 'Edit Teacher';

  @override
  String get cdAdicionar => 'Add';

  @override
  String get cdDocenteAdicionado => 'Teacher added successfully!';

  @override
  String get cdDocenteAtualizado => 'Teacher updated successfully!';

  @override
  String get cdDocenteExcluido => 'Teacher deleted successfully!';

  @override
  String get cdFecharFormulario => 'Close teacher form';

  @override
  String get cdNomeCompleto => 'Full Name';

  @override
  String get cdNomeDica => 'Enter the teacher name';

  @override
  String get cdEmailAcesso => 'Sign-in email';

  @override
  String get cdDepartamento => 'Department';

  @override
  String get cdDepartamentoDica => 'Enter the department';

  @override
  String get cdCargaMaxima => 'Maximum Weekly Hours';

  @override
  String get cdRegimeEbtt => 'EBTT Regime';

  @override
  String cdRegimeOpcao(String label, String code) {
    return '$label ($code)';
  }

  @override
  String cdDistribuicaoAulasSemana(int horas) {
    return 'Class distribution: ${horas}h/week';
  }

  @override
  String cdRegimeLimite(String code, int limite) {
    return 'Regime $code: legal weekly limit of ${limite}h in the EBTT career. Research, outreach and management still depend on the institution\'s internal rules.';
  }

  @override
  String get cdDisciplinas => 'Subjects';

  @override
  String get cdHorariosAula => 'Class Times';

  @override
  String get cdNenhumHorario => 'No class times yet';

  @override
  String cdHorasSemana(int horas) {
    return '${horas}h/wk';
  }

  @override
  String cdCargaDistribuida(int horas) {
    return 'Hours assigned to classes: ${horas}h/week';
  }

  @override
  String get cdAdicionarDisciplina => 'Add Subject';

  @override
  String get cdNomeDisciplina => 'Subject Name';

  @override
  String get cdExemploDisciplina => 'E.g.: Programming I';

  @override
  String get cdAdicionarHorario => 'Add Class Time';

  @override
  String get cdDiaSemana => 'Day of the Week';

  @override
  String get cdInicio => 'Start';

  @override
  String get cdFim => 'End';

  @override
  String get cdDisciplina => 'Subject';

  @override
  String get cdCargaHoraria => 'Hours';

  @override
  String get cdExemploCarga => 'E.g.: 2h/week · 80h';

  @override
  String get cdTurma => 'Class';

  @override
  String get cdModalidade => 'Modality';

  @override
  String cdExcluirMensagem(String nome) {
    return 'Are you sure you want to delete $nome?';
  }

  @override
  String get cdSugestaoEquilibrada =>
      'The current distribution is balanced. Prioritize biweekly follow-up and fine-tuning by subject.';

  @override
  String cdSugestaoPressao(String nomes) {
    return 'Teachers under the most pressure: $nomes. Consider redistributing practical classes and advising to reduce the risk of overload.';
  }

  @override
  String cdSugestaoOciosa(String nomes) {
    return 'There is spare capacity with $nomes. Prioritize shared components and extra lab sessions.';
  }

  @override
  String get cdSugestaoRevisao =>
      'Schedule a weekly joint review between coordination and labs to reduce scheduling conflicts and empty gaps.';

  @override
  String cdRedistribuicoesAplicadas(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count redistributions applied successfully.',
      one: '1 redistribution applied successfully.',
    );
    return '$_temp0';
  }

  @override
  String get cdMaisAcoes => 'More teacher actions';

  @override
  String cdRegimeDocente(String label, String code) {
    return 'EBTT Regime: $label ($code)';
  }

  @override
  String cdDistribuicaoAulas(int horas, int maximo) {
    return 'Class distribution: ${horas}h/${maximo}h';
  }

  @override
  String get cdOtimizacao => 'Distribution optimization';

  @override
  String get cdSimular => 'Simulate';

  @override
  String get cdAproveitamentoMedio => 'average use of teaching hours';

  @override
  String get cdOcupacaoMedia => 'Average occupancy';

  @override
  String get cdAltaCarga => 'High load (>=90%)';

  @override
  String get cdBaixaCarga => 'Low load (<=50%)';

  @override
  String get cdSimulacao => 'Redistribution simulation';

  @override
  String cdOcupacaoPrevista(String antes, String depois) {
    return 'Expected average occupancy: $antes% -> $depois%';
  }

  @override
  String get cdNenhumaRedistribuicao =>
      'No safe redistribution was found for the current scenario.';

  @override
  String get cdAplicarSugestao => 'Apply suggestion';

  @override
  String get cdAcessoRestrito => 'Restricted access';

  @override
  String get cdAcessoRestritoMensagem =>
      'Only teachers, coordination, department heads and administrative staff can access this area.';

  @override
  String get cdAgendaDocente => 'Teacher\'s schedule';

  @override
  String get cdDistribuicaoSemanal => 'Weekly distribution';

  @override
  String get cdConviteReuniao => 'Meeting invitation';

  @override
  String get cdConviteEnviadoAgenda =>
      'Invitation sent via the SIGAD calendar.';

  @override
  String get cdEnviarConviteReuniao => 'Send meeting invitation';

  @override
  String get cdTituloConvite => 'Invitation title';

  @override
  String get cdTituloConviteDica => 'E.g.: Alignment meeting';

  @override
  String get cdDescricaoConviteDica => 'Invitation details';

  @override
  String get cdLocal => 'Location';

  @override
  String get cdLocalDica => 'Room 12 or Online';

  @override
  String get cdHorarioInvalido => 'Could not read the time of this cell.';

  @override
  String get cdInformeTituloConvite => 'Enter the invitation title.';

  @override
  String get cdInformeLocalConvite => 'Enter the invitation location.';

  @override
  String get cdConviteEnviado => 'Invitation sent to the teacher\'s calendar.';

  @override
  String get cdEnviarConvite => 'Send invitation';

  @override
  String get cdAgendaSemanal => 'Weekly schedule';

  @override
  String cdSemanaDe(String semana, String mes) {
    return '$mes $semana';
  }

  @override
  String cdIntervalo(String inicio, String fim) {
    return '$inicio – $fim';
  }

  @override
  String cdDiaSelecionado(int dia, String abreviado, String completo) {
    return 'Selected day: $dia ($abreviado - $completo)';
  }

  @override
  String cdMes(String mes) {
    String _temp0 = intl.Intl.selectLogic(mes, {
      '1': 'January',
      '2': 'February',
      '3': 'March',
      '4': 'April',
      '5': 'May',
      '6': 'June',
      '7': 'July',
      '8': 'August',
      '9': 'September',
      '10': 'October',
      '11': 'November',
      'other': 'December',
    });
    return '$_temp0';
  }

  @override
  String get cdDiaSab => 'Sat';

  @override
  String get cdDiaDom => 'Sun';

  @override
  String get cdDiaSabado => 'Saturday';

  @override
  String get cdDiaDomingo => 'Sunday';

  @override
  String get cdTurnoCurtoM => 'M';

  @override
  String get cdTurnoCurtoT => 'A';

  @override
  String get cdTurnoCurtoN => 'E';

  @override
  String get cdLivre => 'Free';

  @override
  String get cdAula => 'Class';

  @override
  String get cdOcupado => 'Busy';

  @override
  String get cdHorarioIndefinido => 'Undefined time';

  @override
  String get cdSegunda => 'Monday';

  @override
  String get cdTerca => 'Tuesday';

  @override
  String get cdQuarta => 'Wednesday';

  @override
  String get cdQuinta => 'Thursday';

  @override
  String get cdSexta => 'Friday';

  @override
  String get cdModalidadeIntegral => 'Integrated';

  @override
  String get cdModalidadeConcomitante => 'Concurrent';

  @override
  String get cdModalidadeSubsequente => 'Subsequent';

  @override
  String get cdModalidadeEja => 'Adult education';

  @override
  String get cdModalidadeSuperior => 'Higher education';

  @override
  String get cdRegime20h => '20 hours';

  @override
  String get cdRegime40h => '40 hours';

  @override
  String get cdRegimeDe => 'Exclusive dedication';

  @override
  String get cdInformeNome => 'Enter the teacher name';

  @override
  String get cdInformeDepartamento => 'Enter the department';

  @override
  String get cdInformeCargaMaxima => 'Enter a valid maximum workload';

  @override
  String cdRegimePermite(String code, String limite) {
    return 'The $code regime allows up to ${limite}h per week.';
  }

  @override
  String get cdAdicioneDisciplina => 'Add at least one subject';

  @override
  String cdDistribuicaoExcede(String distribuida, String maxima) {
    return 'The weekly distribution (${distribuida}h) exceeds the teacher\'s maximum load (${maxima}h).';
  }

  @override
  String get cdInformeNomeDisciplina => 'Enter the subject name.';

  @override
  String get cdDisciplinaJaAdicionada => 'Subject already added.';

  @override
  String get cdInformeInicioFim => 'Enter start and end times.';

  @override
  String get cdFormatoHorario => 'Use the HH:MM format for times.';

  @override
  String get cdFimPosterior => 'The end time must be after the start time.';

  @override
  String cdConflitoHorario(String dia) {
    return 'There is already a conflicting time on $dia.';
  }
}
