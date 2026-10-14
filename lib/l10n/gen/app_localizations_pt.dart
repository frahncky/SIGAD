// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get cancelar => 'Cancelar';

  @override
  String get nomeSaudacao => 'Nome na saudação';

  @override
  String get nomeSaudacaoAjuda =>
      'Somente neste dispositivo. Deixe vazio para usar o primeiro nome da conta.';

  @override
  String get nomeSaudacaoErro => 'Não foi possível salvar. Tente novamente.';

  @override
  String get nomeSaudacaoSalvo => 'Nome na saudação salvo.';

  @override
  String get nomeSaudacaoSalvando => 'Salvando…';

  @override
  String get fechar => 'Fechar';

  @override
  String get sair => 'Sair';

  @override
  String get verTodas => 'Ver todas';

  @override
  String get verTudo => 'Ver tudo';

  @override
  String get tentarNovamente => 'Tentar novamente';

  @override
  String get acessoRapido => 'Acesso rápido';

  @override
  String get navVisaoGeral => 'Visão geral';

  @override
  String get navVisaoGeralSub => 'Indicadores, prioridades e atalhos';

  @override
  String get navBatePapo => 'Bate-papo';

  @override
  String get navBatePapoSub => 'Conversas individuais e em grupo';

  @override
  String get navDemandas => 'Demandas';

  @override
  String get navDemandasSub => 'Solicitações, prazos e responsáveis';

  @override
  String get navProfessores => 'Professores';

  @override
  String get navProfessoresSub => 'Cadastro, situação e carga atribuída';

  @override
  String get navTarefas => 'Tarefas';

  @override
  String get navTarefasSub => 'Quadro de acompanhamento das atividades';

  @override
  String get navLaboratorios => 'Laboratórios';

  @override
  String get navLaboratoriosSub => 'Ocupação, reservas e conflitos';

  @override
  String get navCargaDocente => 'Carga docente';

  @override
  String get navCargaDocenteSub => 'Distribuição de aulas e atividades';

  @override
  String get navAtividades => 'Atividades';

  @override
  String get navAtividadesSub => 'Ensino, pesquisa, extensão e gestão';

  @override
  String get navRelatorios => 'Relatórios';

  @override
  String get navRelatoriosSub => 'Indicadores e exportações gerenciais';

  @override
  String get navConfiguracoes => 'Configurações';

  @override
  String get navConfiguracoesSub => 'Conta, preferências e permissões';

  @override
  String get navCalendario => 'Calendário';

  @override
  String get navAnotacoes => 'Anotações';

  @override
  String get navMais => 'Mais';

  @override
  String get navMural => 'Mural do departamento';

  @override
  String get notificacoes => 'Notificações';

  @override
  String get perfil => 'Perfil';

  @override
  String get nenhumaNotificacao => 'Nenhuma notificação no momento.';

  @override
  String get buscarModulo => 'Buscar módulo';

  @override
  String get nenhumModulo => 'Nenhum módulo encontrado.';

  @override
  String get confirmarSaida => 'Confirmar saída';

  @override
  String get confirmarSaidaMensagem =>
      'Tem certeza de que deseja sair da aplicação?';

  @override
  String get perfilProfessor => 'Professor';

  @override
  String get perfilCoordenador => 'Coordenador de Curso';

  @override
  String get perfilServidor => 'Servidor Administrativo';

  @override
  String get perfilChefe => 'Chefe do Departamento';

  @override
  String get entrar => 'Entrar';

  @override
  String get perfilDemonstracao => 'Perfil de demonstração';

  @override
  String get emailInstitucional => 'Email institucional';

  @override
  String get senha => 'Senha';

  @override
  String get mostrarSenha => 'Mostrar senha';

  @override
  String get ocultarSenha => 'Ocultar senha';

  @override
  String get recuperacaoSenhaAviso =>
      'A recuperação de senha será vinculada ao serviço institucional.';

  @override
  String get esqueciSenha => 'Esqueci minha senha';

  @override
  String get acessoDemo => 'Acesso demo do perfil selecionado';

  @override
  String get preenchaEmailSenha => 'Preencha email e senha.';

  @override
  String get emailInvalido => 'Informe um email válido.';

  @override
  String get senhaCurta => 'A senha deve ter pelo menos 4 caracteres.';

  @override
  String get autenticacaoIndisponivel =>
      'Autenticação institucional indisponível. A integração com o serviço de acesso ainda não foi concluída.';

  @override
  String get erroAcessoDemo => 'Não foi possível entrar com acesso demo.';

  @override
  String get loginTitulo =>
      'Sistema Integrado de Gestão\nAcadêmica e Departamental';

  @override
  String get logotipoSigad => 'Logotipo do SIGAD';

  @override
  String get loginSubtitulo =>
      'Planeje as atividades do departamento: carga docente, laboratórios, reuniões e demandas.';

  @override
  String get loginDestaquePlanejamento => 'Planejamento integrado';

  @override
  String get loginDestaqueLaboratorios => 'Gestão de laboratórios';

  @override
  String get loginDestaqueIndicadores => 'Indicadores e relatórios';

  @override
  String get boasVindas => 'Boas-vindas';

  @override
  String get avisos => 'Avisos';

  @override
  String quantidadeAvisos(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count avisos',
      one: '1 aviso',
      zero: '0 avisos',
    );
    return '$_temp0';
  }

  @override
  String get verTodosAvisos => 'Ver todos os avisos';

  @override
  String get resumoDepartamento => 'Resumo do departamento';

  @override
  String get bomDia => 'Bom dia';

  @override
  String get boaTarde => 'Boa tarde';

  @override
  String get boaNoite => 'Boa noite';

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
      'Cada pequena entrega de hoje constrói o departamento de amanhã.';

  @override
  String get departamentoCampus => 'Departamento de Eletroeletrônica';

  @override
  String mostrarSlide(String rotulo) {
    return 'Mostrar $rotulo';
  }

  @override
  String get dadosIndisponiveis => 'Dados indisponíveis. Puxe para atualizar.';

  @override
  String get atualizandoInformacoes => 'Atualizando informações';

  @override
  String atividadesRegistradas(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count atividades registradas',
      one: '1 atividade registrada',
      zero: '0 atividades registradas',
    );
    return '$_temp0';
  }

  @override
  String itensFluxo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count itens no fluxo de trabalho',
      one: '1 item no fluxo de trabalho',
      zero: '0 itens no fluxo de trabalho',
    );
    return '$_temp0';
  }

  @override
  String demandasRegistradas(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count demandas registradas',
      one: '1 demanda registrada',
      zero: '0 demandas registradas',
    );
    return '$_temp0';
  }

  @override
  String get atividadesDepartamento => 'Atividades do departamento';

  @override
  String get quadroTrabalho => 'Quadro de trabalho';

  @override
  String get demandasDepartamento => 'Demandas do departamento';

  @override
  String get acessoDepartamento => 'Acesso ao departamento';

  @override
  String get acessoDepartamentoSub =>
      'Informações exibidas conforme seu perfil';

  @override
  String get atencaoAgora => 'Atenção agora';

  @override
  String get atencaoAgoraSub => 'Itens abertos ordenados por impacto';

  @override
  String get nenhumaDemandaAberta => 'Nenhuma demanda aberta.';

  @override
  String responsavelPrazo(String responsavel, String prazo) {
    return '$responsavel • prazo $prazo';
  }

  @override
  String get proximasAtividades => 'Próximas atividades';

  @override
  String get proximasAtividadesSub => 'Compromissos que ainda pedem atenção';

  @override
  String get nenhumaAtividadeAberta => 'Nenhuma atividade aberta.';

  @override
  String get atualizandoVisao => 'Atualizando visão operacional...';

  @override
  String get erroIndicadores => 'Não foi possível atualizar os indicadores.';

  @override
  String get escolhaAtalhos =>
      'Escolha quais atalhos do menu aparecem na visão geral.';

  @override
  String get personalizarAtalhos => 'Personalizar atalhos';

  @override
  String get nenhumAtalho =>
      'Nenhum atalho selecionado. Toque no ícone acima para escolher.';

  @override
  String get minhaConta => 'Minha conta';

  @override
  String get nome => 'Nome';

  @override
  String get email => 'E-mail';

  @override
  String get perfilAcesso => 'Perfil de acesso';

  @override
  String get aparenciaLeitura => 'Aparência e leitura';

  @override
  String get modoNoturno => 'Modo noturno';

  @override
  String get modoNoturnoSub => 'Fundo escuro, mais confortável à noite';

  @override
  String get tamanhoTexto => 'Tamanho do texto';

  @override
  String get tamanhoNormal => 'Normal';

  @override
  String get tamanhoMedio => 'Médio';

  @override
  String get tamanhoGrande => 'Grande';

  @override
  String get tamanhoMuitoGrande => 'Muito grande';

  @override
  String get idioma => 'Idioma';

  @override
  String get idiomaAutomatico => 'Automático (idioma do celular)';

  @override
  String get departamento => 'Departamento';

  @override
  String get muralDepartamentoSub => 'Avisos do painel e frases motivacionais';

  @override
  String get sobre => 'Sobre';

  @override
  String get sobreSigad => 'Sobre o SIGAD';

  @override
  String versaoBuild(String versao) {
    return 'Versão $versao';
  }

  @override
  String get sairDaConta => 'Sair da conta';

  @override
  String get fecharSobre => 'Fechar sobre o SIGAD';

  @override
  String get versao => 'Versão';

  @override
  String get desenvolvidoPor => 'Desenvolvido por';

  @override
  String get equipeDesenvolvimento => 'Equipe de Desenvolvimento SIGAD';

  @override
  String get dataLancamento => 'Data de lançamento';

  @override
  String get compatibilidade => 'Compatibilidade';

  @override
  String get sobreDescricao =>
      'O SIGAD é um sistema integrado de gestão acadêmica desenvolvido para otimizar processos administrativos e acadêmicos.';

  @override
  String get sairPergunta => 'Tem certeza que deseja sair da aplicação?';

  @override
  String get facaLogin => 'Faça login para acessar configurações.';

  @override
  String get salvar => 'Salvar';

  @override
  String get excluir => 'Excluir';

  @override
  String get continuar => 'Continuar';

  @override
  String get reservar => 'Reservar';

  @override
  String get hoje => 'Hoje';

  @override
  String get feriado => 'Feriado';

  @override
  String get detalhes => 'Detalhes';

  @override
  String get erroSalvar => 'Não foi possível salvar. Tente novamente.';

  @override
  String get diaSeg => 'Seg';

  @override
  String get diaTer => 'Ter';

  @override
  String get diaQua => 'Qua';

  @override
  String get diaQui => 'Qui';

  @override
  String get diaSex => 'Sex';

  @override
  String get diaSegunda => 'segunda-feira';

  @override
  String get diaTerca => 'terça-feira';

  @override
  String get diaQuarta => 'quarta-feira';

  @override
  String get diaQuinta => 'quinta-feira';

  @override
  String get diaSexta => 'sexta-feira';

  @override
  String get turnoTodos => 'Todos';

  @override
  String get turnoManha => 'Manhã';

  @override
  String get turnoTarde => 'Tarde';

  @override
  String get turnoNoite => 'Noite';

  @override
  String get turnoMatutino => 'Matutino';

  @override
  String get turnoVespertino => 'Tarde';

  @override
  String get turnoNoturno => 'Noite';

  @override
  String mesAbrev(String mes) {
    String _temp0 = intl.Intl.selectLogic(mes, {
      '1': 'jan.',
      '2': 'fev.',
      '3': 'mar.',
      '4': 'abr.',
      '5': 'maio',
      '6': 'jun.',
      '7': 'jul.',
      '8': 'ago.',
      '9': 'set.',
      '10': 'out.',
      '11': 'nov.',
      'other': 'dez.',
    });
    return '$_temp0';
  }

  @override
  String get labAgenda => 'Agenda';

  @override
  String get labErroCarregar => 'Não foi possível carregar as reservas.';

  @override
  String get labIrParaSemana => 'Ir para a semana de';

  @override
  String get labSugestoes => 'Sugestões de horários';

  @override
  String get labSugestoesSub => 'Ocupação da semana e horários livres';

  @override
  String get labSomenteDocentes =>
      'Somente perfis docentes podem reservar horários.';

  @override
  String get labHorarioOcupado =>
      'Esse horário já está ocupado. Escolha outro horário livre.';

  @override
  String labReservaFeita(String lab, String dia, String data, String horario) {
    return 'Reserva feita: $lab, $dia $data, $horario.';
  }

  @override
  String labHorariosReservados(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count horários reservados.',
      one: '1 horário reservado.',
    );
    return '$_temp0';
  }

  @override
  String labJaOcupados(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count já estavam ocupados.',
      one: '1 já estava ocupado.',
    );
    return '$_temp0';
  }

  @override
  String get labErroOperacao =>
      'Não foi possível concluir a operação. Tente novamente.';

  @override
  String get labEditarOcorrencias => 'Editar ocorrências';

  @override
  String labRepeteEditar(int count) {
    return 'Essa reserva se repete em $count ocorrências. Selecione quais você quer editar.';
  }

  @override
  String labRepeteExcluir(int count) {
    return 'Essa reserva se repete em $count ocorrências. Selecione quais você quer excluir.';
  }

  @override
  String get labNovoHorarioOcupado =>
      'Não foi possível salvar: o novo horário já está ocupado em todas as ocorrências selecionadas.';

  @override
  String get labReservaAtualizada => 'Reserva atualizada.';

  @override
  String labOcorrenciasAtualizadas(int count) {
    return '$count ocorrências atualizadas.';
  }

  @override
  String labNaoMovidas(int count) {
    return '$count não puderam ser movidas (horário ocupado).';
  }

  @override
  String get labExcluirOcorrencias => 'Excluir ocorrências';

  @override
  String get labRevisarExclusao => 'Revisar exclusão';

  @override
  String get labExcluirReserva => 'Excluir reserva';

  @override
  String labRemoverUma(String ocorrencia, String lab) {
    return 'Deseja remover a reserva de $ocorrencia no $lab?';
  }

  @override
  String labRemoverVarias(int count, String lab) {
    return 'Deseja remover as $count ocorrências selecionadas no $lab?';
  }

  @override
  String get labReservaRemovida => 'Reserva removida.';

  @override
  String labOcorrenciasRemovidas(int count) {
    return '$count ocorrências removidas.';
  }

  @override
  String get labFacaLogin => 'Faça login para reservar horários.';

  @override
  String get labSemSugestoes =>
      'Não há horários livres sugeridos para esta semana.';

  @override
  String get labReservarSugeridoTitulo => 'Reservar horário sugerido?';

  @override
  String get labReservaNoSeuNome => 'A reserva fica no seu nome.';

  @override
  String get labSugestaoIndisponivel =>
      'A sugestão ficou indisponível. Tente novamente.';

  @override
  String get labEditarReserva => 'Editar reserva';

  @override
  String get labDisciplinaOpcional => 'Disciplina (opcional)';

  @override
  String get labDiaSemana => 'Dia da semana';

  @override
  String get labHorario => 'Horário';

  @override
  String get labHorarioJaOcupado => 'Horário já ocupado';

  @override
  String get labLaboratorio => 'Laboratório';

  @override
  String labSemanaMesmoMes(int inicio, int fim, String mes) {
    return '$inicio a $fim de $mes';
  }

  @override
  String labSemanaDoisMeses(
    int inicio,
    String mesInicio,
    int fim,
    String mesFim,
  ) {
    return '$inicio de $mesInicio a $fim de $mesFim';
  }

  @override
  String get labSemanaAnterior => 'Semana anterior';

  @override
  String get labProximaSemana => 'Próxima semana';

  @override
  String labSemanaSemantica(String rotulo, String ano) {
    return 'Semana de $rotulo de $ano. Escolher outra data';
  }

  @override
  String get labEstaSemana => 'Esta semana';

  @override
  String get labHorarioLivre => 'Horário livre';

  @override
  String get labMinhaReserva => 'Minha reserva';

  @override
  String get labReservadoPorOutro => 'Reservado por outro';

  @override
  String get labArrasteAgenda =>
      'Arraste a agenda para o lado para ver todos os dias.';

  @override
  String labCabecalhoDia(String dia, String data) {
    return '$dia, $data';
  }

  @override
  String get labHojeSufixo => ', hoje';

  @override
  String labFeriadoSufixo(String nome) {
    return ', feriado: $nome';
  }

  @override
  String labCelula(
    String dia,
    int numero,
    String turno,
    int periodo,
    String horario,
  ) {
    return 'Célula $dia, dia $numero, $turno, período $periodo, horário $horario.';
  }

  @override
  String get labLivre => 'Livre';

  @override
  String labReservadoPor(String nome) {
    return 'Reservado por $nome';
  }

  @override
  String get labToqueDetalhes => 'Toque para ver os detalhes da reserva.';

  @override
  String get labToqueReservar => 'Toque para reservar.';

  @override
  String get labDetalhesReserva => 'Detalhes da reserva';

  @override
  String get labReservaDeLaboratorio => 'Reserva de laboratório';

  @override
  String get labSuaReserva => 'Sua reserva';

  @override
  String get labData => 'Data';

  @override
  String get labReservadoPorRotulo => 'Reservado por';

  @override
  String get labSoQuemFez =>
      'Só quem fez a reserva ou a chefia pode alterá-la.';

  @override
  String get labAcessoRestrito => 'Acesso restrito';

  @override
  String get labAcessoRestritoMsg =>
      'Este módulo está disponível para professor, coordenador e chefe do departamento.';

  @override
  String get labOtimizacao => 'Otimização de laboratórios';

  @override
  String get labReservarSugestao => 'Reservar sugestão';

  @override
  String labOcupadoNaSemana(String lab) {
    return 'ocupado na semana em $lab';
  }

  @override
  String labIndicadorOcupacao(String lab, String taxa, int livres) {
    return '$lab: $taxa% · $livres livres';
  }

  @override
  String get labSugestoesSlots => 'Sugestões de horários livres';

  @override
  String get labRecomendacoesCruzadas =>
      'Recomendações cruzadas com carga docente';

  @override
  String labRecomendacao(String nome, String lab, String dia, String horario) {
    return '$nome: priorizar $lab em $dia $horario para aliviar carga em turmas práticas.';
  }

  @override
  String get labAvisoInterditado =>
      'Este laboratório está interditado. Confirme com a chefia antes de reservar.';

  @override
  String get labAvisoManutencao =>
      'Este laboratório está em manutenção. Confirme se ele estará disponível antes de reservar.';

  @override
  String labTodosCount(int count) {
    return 'Todos ($count)';
  }

  @override
  String labStatusCount(String status, int count) {
    return '$status ($count)';
  }

  @override
  String get labOcorrenciaRegistrada => 'Ocorrência registrada.';

  @override
  String get labMarcarResolvida => 'Marcar como resolvida?';

  @override
  String labDeixaraDeContar(String titulo) {
    return '\"$titulo\" deixará de contar como ativa.';
  }

  @override
  String get labResolvida => 'Resolvida';

  @override
  String get labOcorrenciaResolvidaMsg => 'Ocorrência marcada como resolvida.';

  @override
  String get labReportarProblema => 'Reportar problema';

  @override
  String get labProximasReservas => 'Próximas reservas';

  @override
  String get labVerAgenda => 'Ver agenda';

  @override
  String get labNenhumaReservaFutura =>
      'Nenhuma reserva futura para este laboratório.';

  @override
  String get labEquipamentos => 'Equipamentos';

  @override
  String get labNenhumEquipamento => 'Nenhum equipamento cadastrado.';

  @override
  String labUnidades(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count unidades',
      one: '1 unidade',
    );
    return '$_temp0';
  }

  @override
  String get labManutencao => 'Manutenção';

  @override
  String get labConcluida => 'Concluída';

  @override
  String get labEmAndamento => 'Em andamento';

  @override
  String get labOcorrencias => 'Ocorrências';

  @override
  String labResolverOcorrencia(String titulo) {
    return 'Resolver ocorrência: $titulo';
  }

  @override
  String get labResolver => 'Resolver';

  @override
  String get labOperando => 'Operando';

  @override
  String get labEmManutencao => 'Em manutenção';

  @override
  String get labInterditado => 'Interditado';

  @override
  String get labReservasNoMes => 'Reservas no mês';

  @override
  String get labOcorrenciasAtivas => 'Ocorrências ativas';

  @override
  String labCapacidadePessoas(int count) {
    return 'Capacidade: $count pessoas';
  }

  @override
  String labPessoas(int count) {
    return '$count pessoas';
  }

  @override
  String labEquipamentosDisponiveisCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count equipamentos disponíveis',
      one: '1 equipamento disponível',
      zero: '0 equipamentos disponíveis',
    );
    return '$_temp0';
  }

  @override
  String labReservasNesteMes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count reservas neste mês',
      one: '1 reserva neste mês',
      zero: '0 reservas neste mês',
    );
    return '$_temp0';
  }

  @override
  String labOcorrenciasAtivasCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ocorrências ativas',
      one: '1 ocorrência ativa',
    );
    return '$_temp0';
  }

  @override
  String get labCapacidade => 'Capacidade';

  @override
  String get labResponsavelTecnico => 'Responsável técnico';

  @override
  String get labEquipamentosDisponiveis => 'Equipamentos disponíveis';

  @override
  String get labNenhumLabStatus =>
      'Nenhum laboratório encontrado com este status.';

  @override
  String get labDisponivel => 'Disponível';

  @override
  String get labEmUso => 'Em uso';

  @override
  String get labIndisponivel => 'Indisponível';

  @override
  String get labRegistrarOcorrencia => 'Registrar ocorrência';

  @override
  String get labOQueAconteceu => 'O que aconteceu?';

  @override
  String get labExemploProblema => 'Ex.: Osciloscópio da bancada 3 não liga';

  @override
  String get labDescrevaProblema => 'Descreva o problema em poucas palavras.';

  @override
  String get labDetalhesOpcional => 'Detalhes (opcional)';

  @override
  String get labDetalhesHint => 'Onde, desde quando e o que já foi tentado.';

  @override
  String get labSemDadosPessoais =>
      'Não inclua nomes, matrículas ou dados pessoais.';

  @override
  String get labSoEstaSemana => 'Só esta semana';

  @override
  String labEstaEMais(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Esta e mais $count semanas',
      one: 'Esta e mais 1 semana',
    );
    return '$_temp0';
  }

  @override
  String get labReservarHorario => 'Reservar horário';

  @override
  String labHorarioEMais(String horario, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$horario e mais $count horários',
      one: '$horario e mais 1 horário',
    );
    return '$_temp0';
  }

  @override
  String get labRepetir => 'Repetir';

  @override
  String labRepeticaoAte(String data) {
    return 'A repetição vai no máximo até $data, fim do mês.';
  }

  @override
  String get labOutrosHorarios => 'Reservar outros horários deste dia';

  @override
  String get paginaNaoEncontrada => 'Página não encontrada';

  @override
  String get paginaNaoEncontradaMensagem =>
      'O endereço informado não corresponde a um módulo do SIGAD.';

  @override
  String get voltarVisaoGeral => 'Voltar à visão geral';

  @override
  String get maisCargaDocenteDesc => 'Planeje e acompanhe a carga horária.';

  @override
  String get maisProfessoresDesc => 'Gerencie docentes do departamento.';

  @override
  String get maisLaboratoriosDesc => 'Recursos, reservas e ocupação.';

  @override
  String get maisReunioes => 'Reuniões';

  @override
  String get maisReunioesDesc => 'Pautas, atas e participantes.';

  @override
  String get maisDemandasDesc => 'Acompanhe e gerencie solicitações.';

  @override
  String get maisNoticias => 'Notícias';

  @override
  String get maisNoticiasDesc => 'Comunicados e informativos.';

  @override
  String get maisRelatoriosDesc => 'Indicadores e dados do departamento.';

  @override
  String get maisCursos => 'Cursos';

  @override
  String get maisCursosDesc => 'Disciplinas e ofertas acadêmicas.';

  @override
  String get maisAdministracao => 'Administração';

  @override
  String get maisAgendaIntegrada => 'Agenda integrada';

  @override
  String get maisAgendaIntegradaDesc =>
      'Visualize eventos e compromissos do departamento.';

  @override
  String get maisConfiguracoesDesc => 'Personalize preferências do aplicativo.';

  @override
  String get maisAjuda => 'Ajuda';

  @override
  String get maisAjudaDesc => 'Central de ajuda, tutoriais e suporte.';

  @override
  String get maisAvisosImportantes => 'Avisos importantes';

  @override
  String get maisNenhumAviso => 'Nenhum aviso no momento.';

  @override
  String get maisCentralAjuda => 'Central de ajuda';

  @override
  String get maisCentralAjudaMensagem =>
      'Tutoriais e suporte estarão disponíveis em breve. Para dúvidas urgentes, abra um chamado com a equipe de TI do campus.';

  @override
  String get maisDepartamento => 'DEPARTAMENTO';

  @override
  String get maisVerTodosAvisos => 'Ver todos os avisos';

  @override
  String get maisPrecisaSuporte => 'Precisando de suporte?';

  @override
  String get maisFaleComTi => 'Fale com a equipe de TI do campus.';

  @override
  String get maisAbrirChamado => 'Abrir chamado';

  @override
  String get muralErroCarregar =>
      'Não foi possível ler o mural salvo. A edição está bloqueada para não sobrescrever os dados.';

  @override
  String get muralFrases => 'Frases';

  @override
  String get muralAcessoNegado =>
      'Somente a chefia do departamento pode gerenciar o mural.';

  @override
  String get muralNovoAviso => 'Novo aviso';

  @override
  String get muralNenhumAviso =>
      'Nenhum aviso cadastrado.\nSem avisos, o painel mostra só as boas-vindas.';

  @override
  String get muralDesativado => 'Desativado';

  @override
  String get muralAgendado => 'Agendado';

  @override
  String get muralEncerrado => 'Encerrado';

  @override
  String get muralNoAr => 'No ar';

  @override
  String get muralTodosPerfis => 'Todos os perfis';

  @override
  String get muralFixado => 'Fixado';

  @override
  String get muralModeloInformativo => 'Informativo';

  @override
  String get muralModeloImportante => 'Importante';

  @override
  String get muralModeloEvento => 'Evento';

  @override
  String get muralModeloLembrete => 'Lembrete';

  @override
  String get muralExibirAPartirDe => 'Exibir a partir de';

  @override
  String get muralExibirAte => 'Exibir até';

  @override
  String get muralDataFinalInvalida =>
      'A data final deve ser igual ou posterior à inicial.';

  @override
  String get muralAvisoPublicado => 'Aviso publicado.';

  @override
  String get muralErroSalvarAviso => 'Não foi possível salvar o aviso.';

  @override
  String get muralExcluirAvisoTitulo => 'Excluir aviso?';

  @override
  String muralExcluirAvisoMensagem(String titulo) {
    return '\"$titulo\" deixará de aparecer.';
  }

  @override
  String get muralAvisoExcluido => 'Aviso excluído.';

  @override
  String get muralErroExcluirAviso => 'Não foi possível excluir o aviso.';

  @override
  String get muralEditarAviso => 'Editar aviso';

  @override
  String get muralModelo => 'Modelo';

  @override
  String get muralTitulo => 'Título';

  @override
  String get muralInformeTitulo => 'Informe o título do aviso.';

  @override
  String get muralConteudo => 'Conteúdo';

  @override
  String get muralConteudoDica =>
      'Escreva o aviso completo para o departamento.';

  @override
  String get muralInformeConteudo => 'Escreva o conteúdo do aviso.';

  @override
  String get muralQuemVe => 'Quem vê';

  @override
  String get muralTodos => 'Todos';

  @override
  String get muralPeriodoExibicao => 'Período de exibição';

  @override
  String get muralAPartirDe => 'A partir de';

  @override
  String get muralImediatamente => 'Imediatamente';

  @override
  String get muralLimparDataInicial => 'Limpar data inicial';

  @override
  String get muralAte => 'Até';

  @override
  String get muralSemDataSair => 'Sem data para sair';

  @override
  String get muralLimparDataFinal => 'Limpar data final';

  @override
  String get muralFixarTopo => 'Fixar no topo';

  @override
  String get muralFixarTopoSub => 'Aparece antes dos outros avisos.';

  @override
  String get muralAtivo => 'Ativo';

  @override
  String get muralAtivoSub => 'Desative para esconder sem excluir.';

  @override
  String get muralPreviaPainel => 'Pré-visualização no painel';

  @override
  String get muralPreviaAvisoSub =>
      'É assim que o aviso aparece no card do topo para quem pode vê-lo.';

  @override
  String get muralPreviaTitulo => 'Título do aviso';

  @override
  String get muralPreviaConteudo => 'O conteúdo do aviso aparece aqui.';

  @override
  String get muralPublicarAviso => 'Publicar aviso';

  @override
  String get muralExcluirAviso => 'Excluir aviso';

  @override
  String get muralNovaFrase => 'Nova frase';

  @override
  String get muralEditarFrase => 'Editar frase';

  @override
  String get muralTrocarFrase => 'Trocar a frase';

  @override
  String get muralPeriodoDiaria => 'Todo dia';

  @override
  String get muralPeriodoSemanal => 'Toda semana';

  @override
  String get muralPeriodoQuinzenal => 'A cada 15 dias';

  @override
  String get muralPeriodoMensal => 'Todo mês';

  @override
  String get muralErroFrequencia => 'Não foi possível salvar a frequência.';

  @override
  String get muralFraseEmExibicao => 'Frase em exibição';

  @override
  String get muralNenhumaFrase => 'Nenhuma frase ativa.';

  @override
  String muralFrasesLista(int count) {
    return 'Frases ($count) — entram em rodízio as ativas';
  }

  @override
  String get muralFraseAtivaRodizio => 'Frase ativa no rodízio';

  @override
  String get muralExcluirFrase => 'Excluir frase';

  @override
  String get muralExcluirFraseTitulo => 'Excluir frase?';

  @override
  String get muralErroSalvarFrase => 'Não foi possível salvar a frase.';

  @override
  String get muralErroExcluirFrase => 'Não foi possível excluir a frase.';

  @override
  String get muralFrase => 'Frase';

  @override
  String get muralFraseDica => 'Escreva uma frase curta e motivadora.';

  @override
  String get muralEscrevaFrase => 'Escreva a frase.';

  @override
  String get muralPreviaFraseSub =>
      'É assim que a frase aparece no card de boas-vindas.';

  @override
  String get muralPreviaFrase => 'A frase aparece aqui.';

  @override
  String get muralSalvarFrase => 'Salvar frase';

  @override
  String get calAgendaCompleta => 'Agenda completa';

  @override
  String get calResumoSemana => 'Resumo da semana';

  @override
  String calPeriodoSemana(String inicio, String fim) {
    return '$inicio a $fim';
  }

  @override
  String get calVerAgenda => 'Ver agenda';

  @override
  String get calEventosAgendados => 'Eventos agendados';

  @override
  String get calReservasLaboratorio => 'Reservas de laboratório';

  @override
  String get calReuniaoMarcada => 'Reunião marcada';

  @override
  String get calDepartamento => 'Departamento';

  @override
  String get calTipoItem => 'Tipo de item';

  @override
  String get calTodos => 'Todos';

  @override
  String get calReuniao => 'Reunião';

  @override
  String get calLaboratorio => 'Laboratório';

  @override
  String get calComunicacao => 'Comunicação';

  @override
  String get calToqueParaAlterar => 'Toque para alterar';

  @override
  String calAulaPratica(String disciplina) {
    return 'Aula prática – $disciplina';
  }

  @override
  String get calReservaLaboratorio => 'Reserva de laboratório';

  @override
  String calReservaDe(String laboratorio) {
    return 'Reserva: $laboratorio';
  }

  @override
  String calResponsavel(String professor) {
    return 'Responsável: $professor';
  }

  @override
  String get calProximosCompromissos => 'Próximos compromissos';

  @override
  String get calVerTodos => 'Ver todos';

  @override
  String get calNenhumaReservaFutura => 'Nenhuma reserva futura encontrada.';

  @override
  String get calAgendaDoDia => 'Agenda do dia';

  @override
  String get calVerAgendaCompleta => 'Ver agenda completa';

  @override
  String get calNenhumCompromisso => 'Nenhum compromisso neste dia.';

  @override
  String get calOcupacaoHoje => 'Ocupação dos laboratórios (hoje)';

  @override
  String get calNenhumaReserva => 'Nenhuma reserva cadastrada.';

  @override
  String calHorariosReservados(int horas, int total) {
    return '$horas de $total horários reservados na semana';
  }

  @override
  String get calMesAnterior => 'Mês anterior';

  @override
  String get calProximoMes => 'Próximo mês';

  @override
  String get calHoje => 'hoje';

  @override
  String calFeriado(String nome) {
    return 'feriado: $nome';
  }

  @override
  String calEventos(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count eventos',
      one: '1 evento',
    );
    return '$_temp0';
  }

  @override
  String get notaGeral => 'Geral';

  @override
  String get notaReunioes => 'Reuniões';

  @override
  String get notaPlanejamento => 'Planejamento';

  @override
  String get notaCargaHoraria => 'Carga horária';

  @override
  String get notaEventos => 'Eventos';

  @override
  String get notaTodas => 'Todas';

  @override
  String get notaNova => 'Nova anotação';

  @override
  String get notaEditar => 'Editar anotação';

  @override
  String get notaExcluir => 'Excluir anotação';

  @override
  String get notaExcluirMensagem =>
      'Tem certeza que deseja excluir esta anotação?';

  @override
  String get notaDica => 'Registre uma ideia, encaminhamento ou lembrete...';

  @override
  String get notaCategoria => 'Categoria';

  @override
  String get notaGerenciarFixadas => 'Gerenciar fixadas';

  @override
  String get notaNenhumaCriada => 'Nenhuma anotação criada ainda.';

  @override
  String get notaBuscar => 'Buscar anotações, reuniões, temas...';

  @override
  String get notaFixadas => 'Fixadas';

  @override
  String get notaTodasAnotacoes => 'Todas as anotações';

  @override
  String get notaMaisRecentes => 'Mais recentes';

  @override
  String get notaMaisAntigas => 'Mais antigas';

  @override
  String notaOrdenarPor(String ordem) {
    return 'Ordenar por: $ordem';
  }

  @override
  String get notaNenhumaEncontrada => 'Nenhuma anotação encontrada.';

  @override
  String get notaVazio => 'Nenhuma anotação. Toque em \"+\" para criar.';

  @override
  String get notaVazioDica =>
      'Use este espaço para registrar encaminhamentos, ideias e lembretes rápidos.';

  @override
  String get notaCriarPrimeira => 'Criar primeira anotação';

  @override
  String get notaDesafixar => 'Desafixar';

  @override
  String get notaFixar => 'Fixar anotação';

  @override
  String notaDataHora(String dia, String mes, String hora) {
    return '$dia/$mes às $hora';
  }

  @override
  String get chatFacaLogin => 'Faça login para acessar o bate-papo.';

  @override
  String get chatNenhumUsuario => 'Nenhum usuário disponível para conversa.';

  @override
  String get chatConversas => 'Conversas';

  @override
  String get chatNovaConversa => 'Nova conversa';

  @override
  String get chatBuscarConversa => 'Buscar conversa';

  @override
  String get chatLimparBusca => 'Limpar busca';

  @override
  String get chatNenhumaEncontrada => 'Nenhuma conversa encontrada.';

  @override
  String get chatNenhumaAinda =>
      'Nenhuma conversa ainda.\nToque em ✏️ para iniciar.';

  @override
  String get chatNenhumaMensagem => 'Nenhuma mensagem ainda.';

  @override
  String get chatDigiteMensagem => 'Digite sua mensagem';

  @override
  String get chatEnviar => 'Enviar';

  @override
  String get chatVoltar => 'Voltar às conversas';

  @override
  String get chatSelecione => 'Selecione uma conversa\nou inicie uma nova';

  @override
  String get chatBuscarContato => 'Buscar por nome, e-mail ou cargo';

  @override
  String get chatNenhumContato => 'Nenhum contato encontrado.';

  @override
  String chatDiaMes(String dia, String mes) {
    return '$dia/$mes';
  }

  @override
  String get demErroCarregar => 'Não foi possível carregar as demandas.';

  @override
  String get demErroCarregarTitulo => 'Não foi possível carregar os dados';

  @override
  String get demErroSalvar =>
      'Não foi possível salvar a demanda. Seus dados foram mantidos. Tente novamente.';

  @override
  String get demBuscar => 'Buscar demandas';

  @override
  String get demBuscarDica => 'Pesquise por título, descrição ou responsável';

  @override
  String get demBuscarExemplo => 'Título, descrição ou responsável';

  @override
  String demFiltrosAtivos(int count) {
    return 'Filtros ativos: $count';
  }

  @override
  String get demFiltrar => 'Filtrar demandas';

  @override
  String get demCarregando => 'Carregando demandas...';

  @override
  String get demNenhuma => 'Nenhuma demanda encontrada';

  @override
  String get demLimparFiltrosDica => 'Tente limpar os filtros ativos.';

  @override
  String get demCrieNova => 'Crie uma nova demanda para começar.';

  @override
  String get demLimparFiltros => 'Limpar filtros';

  @override
  String get demCriarNova => 'Criar nova demanda';

  @override
  String get demFiltros => 'Filtros';

  @override
  String get demFecharFiltros => 'Fechar filtros';

  @override
  String get demStatus => 'Status';

  @override
  String get demPrioridade => 'Prioridade';

  @override
  String get demOrdenacao => 'Ordenação';

  @override
  String get demLimpar => 'Limpar';

  @override
  String get demAplicar => 'Aplicar';

  @override
  String get demNova => 'Nova Demanda';

  @override
  String get demEditar => 'Editar Demanda';

  @override
  String get demFecharFormulario => 'Fechar formulário da demanda';

  @override
  String get demTitulo => 'Título';

  @override
  String get demTituloDica => 'Digite o título da demanda';

  @override
  String get demDescricao => 'Descrição';

  @override
  String get demDescricaoDica => 'Descreva a demanda em detalhes';

  @override
  String get demProprietario => 'Proprietário';

  @override
  String get demStatusInicial => 'Status inicial';

  @override
  String get demCriar => 'Criar';

  @override
  String get demSalvando => 'Salvando...';

  @override
  String get demCriada => 'Demanda criada com sucesso!';

  @override
  String get demAtualizada => 'Demanda atualizada com sucesso!';

  @override
  String get demExcluida => 'Demanda excluída com sucesso!';

  @override
  String get demConfirmarExclusao => 'Confirmar exclusão';

  @override
  String demExcluirMensagem(String titulo) {
    return 'Tem certeza que deseja excluir $titulo?';
  }

  @override
  String get demSemPermissaoCriar =>
      'Seu perfil não possui permissão para criar demandas.';

  @override
  String get demSemPermissaoEditar =>
      'Seu perfil não possui permissão para editar demandas.';

  @override
  String get demSemPermissaoExcluir =>
      'Seu perfil não possui permissão para excluir demandas.';

  @override
  String get demInformeTitulo => 'Informe o título da demanda';

  @override
  String get demInformeDescricao => 'Informe a descrição da demanda';

  @override
  String get demResumo => 'Resumo das demandas';

  @override
  String get demNoTotal => 'No total';

  @override
  String get demAbertas => 'Abertas';

  @override
  String get demUrgentes => 'Urgentes';

  @override
  String get demEditarAcao => 'Editar';

  @override
  String demAbrir(String titulo) {
    return 'Abrir demanda $titulo';
  }

  @override
  String get demFecharDetalhes => 'Fechar detalhes da demanda';

  @override
  String get demPrazo => 'Prazo';

  @override
  String get demTodas => 'Todas';

  @override
  String get demStatusNovo => 'Novo';

  @override
  String get demStatusEmAndamento => 'Em andamento';

  @override
  String get demStatusAguardando => 'Aguardando';

  @override
  String get demStatusRevisao => 'Revisão';

  @override
  String get demStatusConcluido => 'Concluído';

  @override
  String get demPrioridadeAlta => 'Alta';

  @override
  String get demPrioridadeMedia => 'Média';

  @override
  String get demPrioridadeBaixa => 'Baixa';

  @override
  String get demOrdemPrazo => 'Prazo mais próximo';

  @override
  String get demOrdemRecentes => 'Recém-criadas';

  @override
  String get tarErroCarregar =>
      'Não foi possível carregar o quadro de tarefas.';

  @override
  String get tarNovoCard => 'Novo card';

  @override
  String get tarCarregando => 'Carregando quadro de tarefas...';

  @override
  String get tarNenhumCard => 'Nenhum card criado';

  @override
  String get tarNenhumCardDica =>
      'Toque no + para adicionar o primeiro card ao quadro.';

  @override
  String get tarCriarCard => 'Criar card';

  @override
  String get tarArrasteDica =>
      'Arraste lateralmente para navegar entre as colunas do quadro.';

  @override
  String tarExcluirCardMensagem(String titulo) {
    return 'Deseja excluir o card \"$titulo\"?';
  }

  @override
  String tarCardRemovido(String titulo) {
    return 'Card \"$titulo\" removido';
  }

  @override
  String get tarTituloDica => 'Digite o título do card';

  @override
  String get tarColuna => 'Coluna';

  @override
  String get tarCardCriado => 'Card criado com sucesso!';

  @override
  String get tarSolteAqui => 'Solte aqui';

  @override
  String tarCardSemantica(String titulo, String prioridade) {
    return 'Card: $titulo. Prioridade $prioridade.';
  }

  @override
  String get tarMaisAcoes => 'Mais ações do card';

  @override
  String tarId(String id) {
    return 'ID: $id';
  }

  @override
  String tarColunaValor(String coluna) {
    return 'Coluna: $coluna';
  }

  @override
  String tarPrioridadeValor(String prioridade) {
    return 'Prioridade: $prioridade';
  }

  @override
  String get tarExcluirEsteCard => 'Tem certeza que deseja excluir este card?';

  @override
  String get tarInformeTitulo => 'Informe o título do card';

  @override
  String get tarColunaBacklog => 'Backlog';

  @override
  String get tarColunaEmProgresso => 'Em Progresso';

  @override
  String get tarColunaEmRevisao => 'Em Revisão';

  @override
  String get tarColunaConcluido => 'Concluído';

  @override
  String get atvFiltrar => 'Filtrar atividades';

  @override
  String get atvFecharFiltro => 'Fechar filtro';

  @override
  String get atvErroCarregar => 'Não foi possível carregar as atividades.';

  @override
  String get atvBuscarDica => 'Buscar por título, descrição ou responsável';

  @override
  String get atvCarregando => 'Carregando atividades...';

  @override
  String get atvNenhuma => 'Nenhuma atividade encontrada';

  @override
  String get atvNenhumaDica => 'Ajuste os filtros ou crie uma nova atividade.';

  @override
  String get atvCriarNova => 'Criar nova atividade';

  @override
  String get atvNova => 'Nova Atividade';

  @override
  String get atvEditar => 'Editar Atividade';

  @override
  String get atvFecharFormulario => 'Fechar formulário';

  @override
  String get atvTituloDica => 'Digite o título da atividade';

  @override
  String get atvDescricaoDica => 'Descreva a atividade em detalhes';

  @override
  String get atvResponsavel => 'Responsável';

  @override
  String get atvCriada => 'Atividade criada com sucesso!';

  @override
  String get atvAtualizada => 'Atividade atualizada com sucesso!';

  @override
  String get atvExcluida => 'Atividade excluída com sucesso!';

  @override
  String get atvAgendaOperacional => 'Agenda operacional';

  @override
  String get atvConcluidas => 'Concluídas';

  @override
  String get atvPendentes => 'Pendentes';

  @override
  String atvAbrir(String titulo) {
    return 'Abrir atividade $titulo';
  }

  @override
  String get atvMaisAcoes => 'Mais ações da atividade';

  @override
  String get atvFecharDetalhes => 'Fechar detalhes da atividade';

  @override
  String get atvData => 'Data';

  @override
  String get atvInformeTitulo => 'Informe o título da atividade';

  @override
  String get atvInformeDescricao => 'Informe a descrição da atividade';

  @override
  String get atvStatusConcluida => 'Concluída';

  @override
  String get atvStatusEmProgresso => 'Em progresso';

  @override
  String get atvStatusAgendada => 'Agendada';

  @override
  String get atvStatusPendente => 'Pendente';

  @override
  String get relErroCarregar => 'Não foi possível carregar os relatórios.';

  @override
  String relBaixado(String titulo) {
    return 'Relatório baixado: $titulo';
  }

  @override
  String relLinkGerado(String titulo) {
    return 'Link de compartilhamento gerado para $titulo';
  }

  @override
  String get relBuscarDica => 'Buscar por título, descrição ou autor';

  @override
  String get relArrasteDica => 'Arraste lateralmente para ver todos os status.';

  @override
  String get relDisponiveisConsulta => 'relatórios disponíveis para consulta';

  @override
  String get relCarregando => 'Carregando relatórios...';

  @override
  String get relNenhum => 'Nenhum relatório encontrado';

  @override
  String get relNenhumDica => 'Ajuste os filtros para visualizar resultados.';

  @override
  String get relSemPermissao =>
      'Seu perfil não possui permissão para relatórios.';

  @override
  String get relAcessoNegado => 'Acesso não permitido para este perfil.';

  @override
  String get relCentral => 'Central de relatórios';

  @override
  String get relDisponiveis => 'Disponíveis';

  @override
  String get relPublicados => 'Publicados';

  @override
  String get relEmRevisao => 'Em revisão';

  @override
  String relVer(String titulo) {
    return 'Ver relatório $titulo';
  }

  @override
  String get relMaisAcoes => 'Mais ações do relatório';

  @override
  String get relVisualizar => 'Visualizar';

  @override
  String get relBaixarPdf => 'Baixar PDF';

  @override
  String get relCompartilhar => 'Compartilhar';

  @override
  String get relFecharDetalhes => 'Fechar detalhes do relatório';

  @override
  String get relTipo => 'Tipo de relatório';

  @override
  String get relAutor => 'Autor';

  @override
  String get relDownloads => 'Downloads';

  @override
  String get relCompartilhamentos => 'Compartilhamentos';

  @override
  String get relStatusTodos => 'Todos';

  @override
  String get relStatusPublicado => 'Publicado';

  @override
  String get relStatusAgendado => 'Agendado';

  @override
  String get relStatusDisponivel => 'Disponível';

  @override
  String get relTipoAnaliseGeral => 'Análise Geral';

  @override
  String get relTipoRecursosHumanos => 'Recursos Humanos';

  @override
  String get relTipoDesempenho => 'Desempenho';

  @override
  String get relTipoInfraestrutura => 'Infraestrutura';

  @override
  String get relTipoConformidade => 'Conformidade';

  @override
  String get relPdfBaixadoAgora => 'PDF baixado agora';

  @override
  String get relCompartilhadoAgora => 'Compartilhado agora';

  @override
  String get cdBuscarDocente =>
      'Buscar docente por nome, e-mail ou departamento';

  @override
  String get cdOrdemCrescente => 'Ordem crescente';

  @override
  String get cdOrdemDecrescente => 'Ordem decrescente';

  @override
  String get cdNenhumDocente => 'Nenhum docente encontrado';

  @override
  String get cdAdicionarDocente => 'Adicionar docente';

  @override
  String get cdNovoDocente => 'Novo Docente';

  @override
  String get cdEditarDocente => 'Editar Docente';

  @override
  String get cdAdicionar => 'Adicionar';

  @override
  String get cdDocenteAdicionado => 'Docente adicionado com sucesso!';

  @override
  String get cdDocenteAtualizado => 'Docente atualizado com sucesso!';

  @override
  String get cdDocenteExcluido => 'Docente excluído com sucesso!';

  @override
  String get cdFecharFormulario => 'Fechar formulário do docente';

  @override
  String get cdNomeCompleto => 'Nome Completo';

  @override
  String get cdNomeDica => 'Digite o nome do docente';

  @override
  String get cdEmailAcesso => 'Email de acesso';

  @override
  String get cdDepartamento => 'Departamento';

  @override
  String get cdDepartamentoDica => 'Digite o departamento';

  @override
  String get cdCargaMaxima => 'Carga Horária Máxima Semanal (horas)';

  @override
  String get cdRegimeEbtt => 'Regime EBTT';

  @override
  String cdRegimeOpcao(String label, String code) {
    return '$label ($code)';
  }

  @override
  String cdDistribuicaoAulasSemana(int horas) {
    return 'Distribuição em aulas: ${horas}h/sem';
  }

  @override
  String cdRegimeLimite(String code, int limite) {
    return 'Regime $code: limite legal semanal de ${limite}h na carreira EBTT. Pesquisa, extensão e gestão continuam dependentes da normativa interna da instituição.';
  }

  @override
  String get cdDisciplinas => 'Disciplinas';

  @override
  String get cdHorariosAula => 'Horários de Aula';

  @override
  String get cdNenhumHorario => 'Nenhum horário cadastrado';

  @override
  String cdHorasSemana(int horas) {
    return '${horas}h/sem';
  }

  @override
  String cdCargaDistribuida(int horas) {
    return 'Carga distribuída em aulas: ${horas}h/sem';
  }

  @override
  String get cdAdicionarDisciplina => 'Adicionar Disciplina';

  @override
  String get cdNomeDisciplina => 'Nome da Disciplina';

  @override
  String get cdExemploDisciplina => 'Ex: Programação I';

  @override
  String get cdAdicionarHorario => 'Adicionar Horário';

  @override
  String get cdDiaSemana => 'Dia da Semana';

  @override
  String get cdInicio => 'Início';

  @override
  String get cdFim => 'Fim';

  @override
  String get cdDisciplina => 'Disciplina';

  @override
  String get cdCargaHoraria => 'Carga Horária';

  @override
  String get cdExemploCarga => 'Ex: 2h/sem · 80h';

  @override
  String get cdTurma => 'Turma';

  @override
  String get cdModalidade => 'Modalidade';

  @override
  String cdExcluirMensagem(String nome) {
    return 'Tem certeza que deseja excluir $nome?';
  }

  @override
  String get cdSugestaoEquilibrada =>
      'A distribuição atual está equilibrada. Priorize acompanhamento quinzenal e ajuste fino por disciplina.';

  @override
  String cdSugestaoPressao(String nomes) {
    return 'Docentes com maior pressão: $nomes. Considere redistribuir turmas práticas e orientações para reduzir risco de sobrecarga.';
  }

  @override
  String cdSugestaoOciosa(String nomes) {
    return 'Há capacidade ociosa com $nomes. Priorize alocação de componentes compartilhados e reforço em horários de laboratório.';
  }

  @override
  String get cdSugestaoRevisao =>
      'Programe revisão semanal conjunta entre coordenação e laboratórios para reduzir conflitos de agenda e janelas vazias.';

  @override
  String cdRedistribuicoesAplicadas(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count redistribuições aplicadas com sucesso.',
      one: '1 redistribuição aplicada com sucesso.',
    );
    return '$_temp0';
  }

  @override
  String get cdMaisAcoes => 'Mais ações do docente';

  @override
  String cdRegimeDocente(String label, String code) {
    return 'Regime EBTT: $label ($code)';
  }

  @override
  String cdDistribuicaoAulas(int horas, int maximo) {
    return 'Distribuição em aulas: ${horas}h/${maximo}h';
  }

  @override
  String get cdOtimizacao => 'Otimização da distribuição';

  @override
  String get cdSimular => 'Simular';

  @override
  String get cdAproveitamentoMedio =>
      'de aproveitamento médio da carga horária';

  @override
  String get cdOcupacaoMedia => 'Ocupação média';

  @override
  String get cdAltaCarga => 'Alta carga (>=90%)';

  @override
  String get cdBaixaCarga => 'Baixa carga (<=50%)';

  @override
  String get cdSimulacao => 'Simulação de redistribuição';

  @override
  String cdOcupacaoPrevista(String antes, String depois) {
    return 'Ocupação média prevista: $antes% -> $depois%';
  }

  @override
  String get cdNenhumaRedistribuicao =>
      'Nenhuma redistribuição segura foi encontrada para o cenário atual.';

  @override
  String get cdAplicarSugestao => 'Aplicar sugestão';

  @override
  String get cdAcessoRestrito => 'Acesso restrito';

  @override
  String get cdAcessoRestritoMensagem =>
      'Somente docentes, coordenação, chefia e servidor administrativo podem acessar esta área.';

  @override
  String get cdAgendaDocente => 'Agenda do docente';

  @override
  String get cdDistribuicaoSemanal => 'Distribuição semanal';

  @override
  String get cdConviteReuniao => 'Convite para reunião';

  @override
  String get cdConviteEnviadoAgenda => 'Convite enviado via agenda do SIGAD.';

  @override
  String get cdEnviarConviteReuniao => 'Enviar convite de reunião';

  @override
  String get cdTituloConvite => 'Título do convite';

  @override
  String get cdTituloConviteDica => 'Ex: Reunião de alinhamento';

  @override
  String get cdDescricaoConviteDica => 'Detalhes do convite';

  @override
  String get cdLocal => 'Local';

  @override
  String get cdLocalDica => 'Sala 12 ou Online';

  @override
  String get cdHorarioInvalido =>
      'Não foi possível interpretar o horário da célula.';

  @override
  String get cdInformeTituloConvite => 'Informe o título do convite.';

  @override
  String get cdInformeLocalConvite => 'Informe o local do convite.';

  @override
  String get cdConviteEnviado =>
      'Convite enviado com sucesso para a agenda do docente.';

  @override
  String get cdEnviarConvite => 'Enviar convite';

  @override
  String get cdAgendaSemanal => 'Agenda semanal';

  @override
  String cdSemanaDe(String semana, String mes) {
    return '$semana de $mes';
  }

  @override
  String cdIntervalo(String inicio, String fim) {
    return '$inicio a $fim';
  }

  @override
  String cdDiaSelecionado(int dia, String abreviado, String completo) {
    return 'Dia selecionado: $dia ($abreviado - $completo)';
  }

  @override
  String cdMes(String mes) {
    String _temp0 = intl.Intl.selectLogic(mes, {
      '1': 'Janeiro',
      '2': 'Fevereiro',
      '3': 'Março',
      '4': 'Abril',
      '5': 'Maio',
      '6': 'Junho',
      '7': 'Julho',
      '8': 'Agosto',
      '9': 'Setembro',
      '10': 'Outubro',
      '11': 'Novembro',
      'other': 'Dezembro',
    });
    return '$_temp0';
  }

  @override
  String get cdDiaSab => 'Sab';

  @override
  String get cdDiaDom => 'Dom';

  @override
  String get cdDiaSabado => 'sábado';

  @override
  String get cdDiaDomingo => 'domingo';

  @override
  String get cdTurnoCurtoM => 'M';

  @override
  String get cdTurnoCurtoT => 'T';

  @override
  String get cdTurnoCurtoN => 'N';

  @override
  String get cdLivre => 'Livre';

  @override
  String get cdAula => 'Aula';

  @override
  String get cdOcupado => 'Ocupado';

  @override
  String get cdHorarioIndefinido => 'Horário indefinido';

  @override
  String get cdSegunda => 'Segunda';

  @override
  String get cdTerca => 'Terça';

  @override
  String get cdQuarta => 'Quarta';

  @override
  String get cdQuinta => 'Quinta';

  @override
  String get cdSexta => 'Sexta';

  @override
  String get cdModalidadeIntegral => 'Integral';

  @override
  String get cdModalidadeConcomitante => 'Concomitante';

  @override
  String get cdModalidadeSubsequente => 'Subsequente';

  @override
  String get cdModalidadeEja => 'EJA';

  @override
  String get cdModalidadeSuperior => 'Superior';

  @override
  String get cdRegime20h => '20 horas';

  @override
  String get cdRegime40h => '40 horas';

  @override
  String get cdRegimeDe => 'Dedicação exclusiva';

  @override
  String get cdInformeNome => 'Informe o nome do docente';

  @override
  String get cdInformeDepartamento => 'Informe o departamento';

  @override
  String get cdInformeCargaMaxima => 'Informe uma carga horária máxima válida';

  @override
  String cdRegimePermite(String code, String limite) {
    return 'O regime $code permite até ${limite}h semanais.';
  }

  @override
  String get cdAdicioneDisciplina => 'Adicione pelo menos uma disciplina';

  @override
  String cdDistribuicaoExcede(String distribuida, String maxima) {
    return 'A distribuição semanal cadastrada (${distribuida}h) excede a carga máxima do docente (${maxima}h).';
  }

  @override
  String get cdInformeNomeDisciplina => 'Informe o nome da disciplina.';

  @override
  String get cdDisciplinaJaAdicionada => 'Disciplina já adicionada.';

  @override
  String get cdInformeInicioFim => 'Informe horário de início e fim.';

  @override
  String get cdFormatoHorario => 'Use o formato HH:MM para os horários.';

  @override
  String get cdFimPosterior =>
      'O horário de fim deve ser posterior ao de início.';

  @override
  String cdConflitoHorario(String dia) {
    return 'Já existe horário cadastrado em conflito para $dia.';
  }

  @override
  String get vgCargaAlocada => 'Carga horária alocada';

  @override
  String get vgVsMesAnterior6 => '↑ 6% vs. mês anterior';

  @override
  String get vgLabsEmUso => 'Laboratórios em uso';

  @override
  String get vgVsSemana12 => '↑ 12% vs. semana anterior';

  @override
  String get vgNoticiasEnviadas => 'Notícias enviadas';

  @override
  String get vgVsSemana3 => '↑ 3 vs. semana anterior';

  @override
  String get vgPendenciasAbertas => 'Pendências em aberto';

  @override
  String get vgVsSemana1 => '↓ 1 vs. semana anterior';

  @override
  String get vgIndicadoresPainel => 'Indicadores do painel';

  @override
  String get vgEscolhaIndicadores =>
      'Escolha quais indicadores aparecem no panorama.';

  @override
  String get vgPanorama => 'Panorama do departamento';

  @override
  String get vgAtualizadoAgora => 'Atualizado agora';

  @override
  String get vgPersonalizarIndicadores => 'Personalizar indicadores';

  @override
  String get vgProximasPrioridades => 'Próximas prioridades';

  @override
  String get vgPrioridadesDepartamento => 'Prioridades do departamento';

  @override
  String get vgPrioridadesSub => 'Planejamento e atividades mais próximas';

  @override
  String get vgPersonalizar => 'Personalizar';

  @override
  String get vgNenhumIndicador =>
      'Nenhum indicador selecionado. Toque no ícone ao lado para escolher.';

  @override
  String get vgOntem => 'Ontem';

  @override
  String get vgMensagemEnviada => 'Mensagem enviada.';

  @override
  String get vgSelecioneUsuarios =>
      'Selecione usuários ou grupos para iniciar uma conversa.';

  @override
  String get vgPeriodo => 'Período';

  @override
  String get vgTipo => 'Tipo';

  @override
  String get vgArea => 'Área';

  @override
  String get vgLaboratorio => 'Laboratório';

  @override
  String get vgVisualizacao => 'Visualização';

  @override
  String get vgAcaoRegistrada => 'Ação registrada.';

  @override
  String get vgContinuar => 'Continuar';

  @override
  String vgResultados(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count resultados',
      one: '1 resultado',
    );
    return '$_temp0';
  }

  @override
  String vgItens(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count itens',
      one: '1 item',
    );
    return '$_temp0';
  }

  @override
  String vgPrazo(String data) {
    return 'Prazo $data';
  }

  @override
  String get vgComunicacao => 'COMUNICAÇÃO';

  @override
  String get vgChatSub => 'Conversas, grupos e avisos internos do DEE.';

  @override
  String get vgSelecioneConversa => 'Selecione uma conversa.';

  @override
  String get vgDisponivel => 'Disponível';

  @override
  String get vgEscreverMensagem => 'Escrever mensagem';

  @override
  String get vgGestaoAcademica => 'GESTÃO ACADÊMICA';

  @override
  String get vgCargaSub =>
      'Distribuição, limites, conflitos e validação das atividades.';

  @override
  String get vgNovaDistribuicao => 'Nova distribuição';

  @override
  String get vgNovaDistribuicaoMsg =>
      'Cadastre disciplinas, atividades e carga do docente.';

  @override
  String get vgBuscarProfessor => 'Buscar professor';

  @override
  String get vgDocentes => 'Docentes';

  @override
  String vgPeriodoValor(String periodo) {
    return 'Período $periodo';
  }

  @override
  String get vgCargaRegular => 'Carga regular';

  @override
  String get vgDoQuadro => '75% do quadro';

  @override
  String get vgRequerAtencao => 'Requer atenção';

  @override
  String get vgAbaixoAcima => 'Abaixo ou acima do limite';

  @override
  String get vgConflitos => 'Conflitos';

  @override
  String get vgHorariosSobrepostos => 'Horários sobrepostos';

  @override
  String get vgDistribuicaoPorDocente => 'Distribuição por docente';

  @override
  String get vgDistribuicaoSub =>
      'Ensino, pesquisa, extensão, gestão e orientações';

  @override
  String vgEnsinoOutras(String ensino, String outras) {
    return 'Ensino: ${ensino}h · Outras atividades: ${outras}h';
  }

  @override
  String vgTotalDeMaximo(String total, String maximo) {
    return '$total h de $maximo h';
  }

  @override
  String get vgGestaoPessoas => 'GESTÃO DE PESSOAS';

  @override
  String get vgProfessoresSub =>
      'Quadro docente, áreas, situação funcional e carga atual.';

  @override
  String get vgCadastrar => 'Cadastrar';

  @override
  String get vgCadastrarProfessor => 'Cadastrar professor';

  @override
  String get vgCadastrarProfessorMsg =>
      'Informe dados funcionais, área e vínculo.';

  @override
  String get vgBuscarNomeArea => 'Buscar nome ou área';

  @override
  String vgProfessorDetalhe(String area, String carga, String situacao) {
    return 'Área: $area\nCarga atual: $carga\nSituação: $situacao';
  }

  @override
  String vgCargaAtual(String carga) {
    return 'Carga atual: $carga';
  }

  @override
  String get vgPlanejamento => 'PLANEJAMENTO';

  @override
  String get vgDemandasSub =>
      'Solicitações, responsáveis, prazos e acompanhamento.';

  @override
  String get vgNovaDemanda => 'Nova demanda';

  @override
  String get vgNovaDemandaMsg =>
      'Cadastre descrição, responsável, prazo e prioridade.';

  @override
  String get vgNoPeriodoAtual => 'No período atual';

  @override
  String get vgDoTotal58 => '58% do total';

  @override
  String get vgAtrasadas => 'Atrasadas';

  @override
  String get vgAcaoNecessaria => 'Ação necessária';

  @override
  String get vgBuscarDemanda => 'Buscar demanda';

  @override
  String get vgListaDemandas => 'Lista de demandas';

  @override
  String vgDemandaDetalhe(
    String id,
    String responsavel,
    String prazo,
    String prioridade,
  ) {
    return '$id\nResponsável: $responsavel\nPrazo: $prazo\nPrioridade: $prioridade';
  }

  @override
  String get vgExecucao => 'EXECUÇÃO';

  @override
  String get vgTarefasSub =>
      'Quadro visual para acompanhar atividades e responsáveis.';

  @override
  String get vgNovaTarefa => 'Nova tarefa';

  @override
  String get vgNovaTarefaMsg =>
      'Defina título, responsável, prazo e prioridade.';

  @override
  String vgAdicionarTarefaEm(String coluna) {
    return 'Ação para adicionar tarefa em $coluna.';
  }

  @override
  String get vgInfraestrutura => 'INFRAESTRUTURA';

  @override
  String get vgLabsSub => 'Disponibilidade, reservas, conflitos e manutenção.';

  @override
  String get vgNovaReserva => 'Nova reserva';

  @override
  String get vgNovaReservaMsg =>
      'Selecione laboratório, data, turno, disciplina e responsável.';

  @override
  String get vgReservasHoje => 'Reservas hoje';

  @override
  String get vgCincoLabs => '5 laboratórios';

  @override
  String get vgEmUso => 'Em uso';

  @override
  String get vgNesteHorario => 'Neste horário';

  @override
  String get vgEmManutencao => 'Em manutenção';

  @override
  String get vgAcessoRestrito => 'Acesso temporariamente restrito';

  @override
  String get vgNenhumaSobreposicao => 'Nenhuma sobreposição';

  @override
  String get vgAgendaSemanalSub => 'Períodos de segunda a sexta';

  @override
  String get vgCalendarioReservas => 'Calendário de reservas';

  @override
  String get vgVisaoMes => 'Visão consolidada do mês';

  @override
  String get vgOcupacaoOtimizacao => 'Ocupação e otimização';

  @override
  String get vgUsoMedio => 'Uso médio e horários disponíveis';

  @override
  String get vgReservado => 'Reservado';

  @override
  String get vgLivre => 'Livre';

  @override
  String get vgComReservas => 'Com reservas';

  @override
  String get vgAcompanhamento => 'ACOMPANHAMENTO';

  @override
  String get vgAtividadesSub =>
      'Ações acadêmicas e administrativas com prazos e responsáveis.';

  @override
  String get vgNovaAtividade => 'Nova atividade';

  @override
  String get vgNovaAtividadeMsg =>
      'Cadastre título, categoria, prazo e responsável.';

  @override
  String get vgBuscarAtividade => 'Buscar atividade';

  @override
  String get vgAtividadesPeriodo => 'Atividades do período';

  @override
  String vgAtividadeDetalhe(String categoria, String prazo, String status) {
    return 'Categoria: $categoria\nPrazo: $prazo\nStatus: $status';
  }

  @override
  String get vgAnalise => 'ANÁLISE';

  @override
  String get vgRelatoriosSub =>
      'Indicadores, documentos e exportações para apoio à gestão.';

  @override
  String get vgGerarRelatorio => 'Gerar relatório';

  @override
  String get vgGerarRelatorioMsg =>
      'Selecione fonte, período, formato e filtros.';

  @override
  String get vgRelatoriosDisponiveis => 'Relatórios disponíveis';

  @override
  String get vgQuatroCategorias => '4 categorias';

  @override
  String get vgExportadosMes => 'Exportados no mês';

  @override
  String get vgAgendados => 'Agendados';

  @override
  String get vgEnvioAutomatico => 'Envio automático';

  @override
  String vgAbrindo(String titulo) {
    return 'Abrindo $titulo.';
  }

  @override
  String get vgExportacaoPreparada => 'Exportação preparada.';

  @override
  String get vgExportar => 'Exportar';

  @override
  String get vgAtualizadoHoje => 'Atualizado hoje';

  @override
  String get vgAtualizadoOntem => 'Atualizado ontem';

  @override
  String vgAtualizadoEm(String data) {
    return 'Atualizado em $data';
  }

  @override
  String get vgPreferencias => 'PREFERÊNCIAS';

  @override
  String get vgConfigSub =>
      'Conta, notificações, aparência, segurança e dados.';

  @override
  String get vgConfigSalvas => 'Configurações salvas.';

  @override
  String get vgPerfilConta => 'Perfil e conta';

  @override
  String get vgDadosSessao => 'Dados da sessão atual';

  @override
  String get vgNomeExibicao => 'Nome de exibição';

  @override
  String get vgUsuarioInstitucional => 'Usuário institucional';

  @override
  String get vgEmail => 'E-mail';

  @override
  String get vgContaInstitucional => 'Conta institucional';

  @override
  String get vgPerfilAcesso => 'Perfil de acesso';

  @override
  String get vgDefinidoAutenticacao => 'Definido pela autenticação';

  @override
  String get vgEditarPerfil => 'Editar perfil';

  @override
  String get vgEditarPerfilMsg => 'Atualize dados pessoais e preferências.';

  @override
  String get vgCanaisAlertas => 'Canais e alertas';

  @override
  String get vgNotifApp => 'Notificações no aplicativo';

  @override
  String get vgNotifAppSub => 'Alertas, convites e prazos';

  @override
  String get vgNotifEmail => 'Notificações por e-mail';

  @override
  String get vgNotifEmailSub => 'Resumo e comunicações importantes';

  @override
  String get vgAparencia => 'Aparência';

  @override
  String get vgDensidade => 'Densidade e visualização';

  @override
  String get vgModoCompacto => 'Modo compacto';

  @override
  String get vgModoCompactoSub => 'Exibe mais informações por tela';

  @override
  String get vgTema => 'Tema';

  @override
  String get vgTemaValor => 'Segue a configuração do aplicativo';

  @override
  String get vgSegurancaDados => 'Segurança e dados';

  @override
  String get vgSessaoAcesso => 'Sessão, acesso e armazenamento';

  @override
  String get vgBiometria => 'Biometria';

  @override
  String get vgBiometriaSub => 'Usar autenticação do dispositivo';

  @override
  String get vgSincronizacao => 'Sincronização';

  @override
  String get vgSincronizacaoValor => 'Automática quando disponível';

  @override
  String get vgLimparDados => 'Limpar dados locais';

  @override
  String get vgLimparDadosMsg =>
      'Esta ação remove apenas caches e preferências locais.';

  @override
  String get vgOpTodos => 'Todos';

  @override
  String get vgOpTodas => 'Todas';

  @override
  String get vgOpRegular => 'Regular';

  @override
  String get vgOpAtencao => 'Atenção';

  @override
  String get vgOpExcedida => 'Excedida';

  @override
  String get vgOpAtivo => 'Ativo';

  @override
  String get vgOpAfastamento => 'Afastamento';

  @override
  String get vgOpEmAnalise => 'Em análise';

  @override
  String get vgOpEmAndamento => 'Em andamento';

  @override
  String get vgOpAguardando => 'Aguardando';

  @override
  String get vgOpAtrasada => 'Atrasada';

  @override
  String get vgOpAFazer => 'A fazer';

  @override
  String get vgOpConcluido => 'Concluído';

  @override
  String get vgOpPendente => 'Pendente';

  @override
  String get vgOpEmProgresso => 'Em progresso';

  @override
  String get vgOpConcluida => 'Concluída';

  @override
  String get vgOpAgendaSemanal => 'Agenda semanal';

  @override
  String get vgOpCalendarioMensal => 'Calendário mensal';

  @override
  String get vgOpOcupacao => 'Ocupação';

  @override
  String get vgOpAcademico => 'Acadêmico';

  @override
  String get vgOpGestao => 'Gestão';

  @override
  String get vgOpProdutividade => 'Produtividade';
}
