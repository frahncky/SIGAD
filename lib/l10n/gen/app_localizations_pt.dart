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
      'Gestão acadêmica e departamental do IFMA — Campus São Luís–Monte Castelo.';

  @override
  String get loginSubtitulo =>
      'Planeje as atividades do DEE: carga docente, laboratórios, reuniões e demandas.';

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
  String get departamentoCampus =>
      'Departamento de Eletroeletrônica · IFMA Campus Monte Castelo';

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
}
