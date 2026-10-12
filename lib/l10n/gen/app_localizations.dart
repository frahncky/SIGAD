import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_pt.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'gen/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('pt'),
  ];

  /// No description provided for @cancelar.
  ///
  /// In pt, this message translates to:
  /// **'Cancelar'**
  String get cancelar;

  /// No description provided for @fechar.
  ///
  /// In pt, this message translates to:
  /// **'Fechar'**
  String get fechar;

  /// No description provided for @sair.
  ///
  /// In pt, this message translates to:
  /// **'Sair'**
  String get sair;

  /// No description provided for @verTodas.
  ///
  /// In pt, this message translates to:
  /// **'Ver todas'**
  String get verTodas;

  /// No description provided for @verTudo.
  ///
  /// In pt, this message translates to:
  /// **'Ver tudo'**
  String get verTudo;

  /// No description provided for @tentarNovamente.
  ///
  /// In pt, this message translates to:
  /// **'Tentar novamente'**
  String get tentarNovamente;

  /// No description provided for @acessoRapido.
  ///
  /// In pt, this message translates to:
  /// **'Acesso rápido'**
  String get acessoRapido;

  /// No description provided for @navVisaoGeral.
  ///
  /// In pt, this message translates to:
  /// **'Visão geral'**
  String get navVisaoGeral;

  /// No description provided for @navVisaoGeralSub.
  ///
  /// In pt, this message translates to:
  /// **'Indicadores, prioridades e atalhos'**
  String get navVisaoGeralSub;

  /// No description provided for @navBatePapo.
  ///
  /// In pt, this message translates to:
  /// **'Bate-papo'**
  String get navBatePapo;

  /// No description provided for @navBatePapoSub.
  ///
  /// In pt, this message translates to:
  /// **'Conversas individuais e em grupo'**
  String get navBatePapoSub;

  /// No description provided for @navDemandas.
  ///
  /// In pt, this message translates to:
  /// **'Demandas'**
  String get navDemandas;

  /// No description provided for @navDemandasSub.
  ///
  /// In pt, this message translates to:
  /// **'Solicitações, prazos e responsáveis'**
  String get navDemandasSub;

  /// No description provided for @navProfessores.
  ///
  /// In pt, this message translates to:
  /// **'Professores'**
  String get navProfessores;

  /// No description provided for @navProfessoresSub.
  ///
  /// In pt, this message translates to:
  /// **'Cadastro, situação e carga atribuída'**
  String get navProfessoresSub;

  /// No description provided for @navTarefas.
  ///
  /// In pt, this message translates to:
  /// **'Tarefas'**
  String get navTarefas;

  /// No description provided for @navTarefasSub.
  ///
  /// In pt, this message translates to:
  /// **'Quadro de acompanhamento das atividades'**
  String get navTarefasSub;

  /// No description provided for @navLaboratorios.
  ///
  /// In pt, this message translates to:
  /// **'Laboratórios'**
  String get navLaboratorios;

  /// No description provided for @navLaboratoriosSub.
  ///
  /// In pt, this message translates to:
  /// **'Ocupação, reservas e conflitos'**
  String get navLaboratoriosSub;

  /// No description provided for @navCargaDocente.
  ///
  /// In pt, this message translates to:
  /// **'Carga docente'**
  String get navCargaDocente;

  /// No description provided for @navCargaDocenteSub.
  ///
  /// In pt, this message translates to:
  /// **'Distribuição de aulas e atividades'**
  String get navCargaDocenteSub;

  /// No description provided for @navAtividades.
  ///
  /// In pt, this message translates to:
  /// **'Atividades'**
  String get navAtividades;

  /// No description provided for @navAtividadesSub.
  ///
  /// In pt, this message translates to:
  /// **'Ensino, pesquisa, extensão e gestão'**
  String get navAtividadesSub;

  /// No description provided for @navRelatorios.
  ///
  /// In pt, this message translates to:
  /// **'Relatórios'**
  String get navRelatorios;

  /// No description provided for @navRelatoriosSub.
  ///
  /// In pt, this message translates to:
  /// **'Indicadores e exportações gerenciais'**
  String get navRelatoriosSub;

  /// No description provided for @navConfiguracoes.
  ///
  /// In pt, this message translates to:
  /// **'Configurações'**
  String get navConfiguracoes;

  /// No description provided for @navConfiguracoesSub.
  ///
  /// In pt, this message translates to:
  /// **'Conta, preferências e permissões'**
  String get navConfiguracoesSub;

  /// No description provided for @navCalendario.
  ///
  /// In pt, this message translates to:
  /// **'Calendário'**
  String get navCalendario;

  /// No description provided for @navAnotacoes.
  ///
  /// In pt, this message translates to:
  /// **'Anotações'**
  String get navAnotacoes;

  /// No description provided for @navMais.
  ///
  /// In pt, this message translates to:
  /// **'Mais'**
  String get navMais;

  /// No description provided for @navMural.
  ///
  /// In pt, this message translates to:
  /// **'Mural do departamento'**
  String get navMural;

  /// No description provided for @notificacoes.
  ///
  /// In pt, this message translates to:
  /// **'Notificações'**
  String get notificacoes;

  /// No description provided for @perfil.
  ///
  /// In pt, this message translates to:
  /// **'Perfil'**
  String get perfil;

  /// No description provided for @nenhumaNotificacao.
  ///
  /// In pt, this message translates to:
  /// **'Nenhuma notificação no momento.'**
  String get nenhumaNotificacao;

  /// No description provided for @buscarModulo.
  ///
  /// In pt, this message translates to:
  /// **'Buscar módulo'**
  String get buscarModulo;

  /// No description provided for @nenhumModulo.
  ///
  /// In pt, this message translates to:
  /// **'Nenhum módulo encontrado.'**
  String get nenhumModulo;

  /// No description provided for @confirmarSaida.
  ///
  /// In pt, this message translates to:
  /// **'Confirmar saída'**
  String get confirmarSaida;

  /// No description provided for @confirmarSaidaMensagem.
  ///
  /// In pt, this message translates to:
  /// **'Tem certeza de que deseja sair da aplicação?'**
  String get confirmarSaidaMensagem;

  /// No description provided for @perfilProfessor.
  ///
  /// In pt, this message translates to:
  /// **'Professor'**
  String get perfilProfessor;

  /// No description provided for @perfilCoordenador.
  ///
  /// In pt, this message translates to:
  /// **'Coordenador de Curso'**
  String get perfilCoordenador;

  /// No description provided for @perfilServidor.
  ///
  /// In pt, this message translates to:
  /// **'Servidor Administrativo'**
  String get perfilServidor;

  /// No description provided for @perfilChefe.
  ///
  /// In pt, this message translates to:
  /// **'Chefe do Departamento'**
  String get perfilChefe;

  /// No description provided for @entrar.
  ///
  /// In pt, this message translates to:
  /// **'Entrar'**
  String get entrar;

  /// No description provided for @perfilDemonstracao.
  ///
  /// In pt, this message translates to:
  /// **'Perfil de demonstração'**
  String get perfilDemonstracao;

  /// No description provided for @emailInstitucional.
  ///
  /// In pt, this message translates to:
  /// **'Email institucional'**
  String get emailInstitucional;

  /// No description provided for @senha.
  ///
  /// In pt, this message translates to:
  /// **'Senha'**
  String get senha;

  /// No description provided for @mostrarSenha.
  ///
  /// In pt, this message translates to:
  /// **'Mostrar senha'**
  String get mostrarSenha;

  /// No description provided for @ocultarSenha.
  ///
  /// In pt, this message translates to:
  /// **'Ocultar senha'**
  String get ocultarSenha;

  /// No description provided for @recuperacaoSenhaAviso.
  ///
  /// In pt, this message translates to:
  /// **'A recuperação de senha será vinculada ao serviço institucional.'**
  String get recuperacaoSenhaAviso;

  /// No description provided for @esqueciSenha.
  ///
  /// In pt, this message translates to:
  /// **'Esqueci minha senha'**
  String get esqueciSenha;

  /// No description provided for @acessoDemo.
  ///
  /// In pt, this message translates to:
  /// **'Acesso demo do perfil selecionado'**
  String get acessoDemo;

  /// No description provided for @preenchaEmailSenha.
  ///
  /// In pt, this message translates to:
  /// **'Preencha email e senha.'**
  String get preenchaEmailSenha;

  /// No description provided for @emailInvalido.
  ///
  /// In pt, this message translates to:
  /// **'Informe um email válido.'**
  String get emailInvalido;

  /// No description provided for @senhaCurta.
  ///
  /// In pt, this message translates to:
  /// **'A senha deve ter pelo menos 4 caracteres.'**
  String get senhaCurta;

  /// No description provided for @autenticacaoIndisponivel.
  ///
  /// In pt, this message translates to:
  /// **'Autenticação institucional indisponível. A integração com o serviço de acesso ainda não foi concluída.'**
  String get autenticacaoIndisponivel;

  /// No description provided for @erroAcessoDemo.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível entrar com acesso demo.'**
  String get erroAcessoDemo;

  /// No description provided for @loginTitulo.
  ///
  /// In pt, this message translates to:
  /// **'Sistema Integrado de Gestão\nAcadêmica e Departamental'**
  String get loginTitulo;

  /// No description provided for @logotipoSigad.
  ///
  /// In pt, this message translates to:
  /// **'Logotipo do SIGAD'**
  String get logotipoSigad;

  /// No description provided for @loginSubtitulo.
  ///
  /// In pt, this message translates to:
  /// **'Planeje as atividades do departamento: carga docente, laboratórios, reuniões e demandas.'**
  String get loginSubtitulo;

  /// No description provided for @loginDestaquePlanejamento.
  ///
  /// In pt, this message translates to:
  /// **'Planejamento integrado'**
  String get loginDestaquePlanejamento;

  /// No description provided for @loginDestaqueLaboratorios.
  ///
  /// In pt, this message translates to:
  /// **'Gestão de laboratórios'**
  String get loginDestaqueLaboratorios;

  /// No description provided for @loginDestaqueIndicadores.
  ///
  /// In pt, this message translates to:
  /// **'Indicadores e relatórios'**
  String get loginDestaqueIndicadores;

  /// No description provided for @boasVindas.
  ///
  /// In pt, this message translates to:
  /// **'Boas-vindas'**
  String get boasVindas;

  /// No description provided for @avisos.
  ///
  /// In pt, this message translates to:
  /// **'Avisos'**
  String get avisos;

  /// No description provided for @quantidadeAvisos.
  ///
  /// In pt, this message translates to:
  /// **'{count, plural, =0{0 avisos} =1{1 aviso} other{{count} avisos}}'**
  String quantidadeAvisos(int count);

  /// No description provided for @verTodosAvisos.
  ///
  /// In pt, this message translates to:
  /// **'Ver todos os avisos'**
  String get verTodosAvisos;

  /// No description provided for @resumoDepartamento.
  ///
  /// In pt, this message translates to:
  /// **'Resumo do departamento'**
  String get resumoDepartamento;

  /// No description provided for @bomDia.
  ///
  /// In pt, this message translates to:
  /// **'Bom dia'**
  String get bomDia;

  /// No description provided for @boaTarde.
  ///
  /// In pt, this message translates to:
  /// **'Boa tarde'**
  String get boaTarde;

  /// No description provided for @boaNoite.
  ///
  /// In pt, this message translates to:
  /// **'Boa noite'**
  String get boaNoite;

  /// No description provided for @saudacaoComNome.
  ///
  /// In pt, this message translates to:
  /// **'{saudacao}, {nome}!'**
  String saudacaoComNome(String saudacao, String nome);

  /// No description provided for @saudacaoSemNome.
  ///
  /// In pt, this message translates to:
  /// **'{saudacao}!'**
  String saudacaoSemNome(String saudacao);

  /// No description provided for @fraseSemCadastro.
  ///
  /// In pt, this message translates to:
  /// **'Cada pequena entrega de hoje constrói o departamento de amanhã.'**
  String get fraseSemCadastro;

  /// No description provided for @departamentoCampus.
  ///
  /// In pt, this message translates to:
  /// **'Departamento de Eletroeletrônica'**
  String get departamentoCampus;

  /// No description provided for @mostrarSlide.
  ///
  /// In pt, this message translates to:
  /// **'Mostrar {rotulo}'**
  String mostrarSlide(String rotulo);

  /// No description provided for @dadosIndisponiveis.
  ///
  /// In pt, this message translates to:
  /// **'Dados indisponíveis. Puxe para atualizar.'**
  String get dadosIndisponiveis;

  /// No description provided for @atualizandoInformacoes.
  ///
  /// In pt, this message translates to:
  /// **'Atualizando informações'**
  String get atualizandoInformacoes;

  /// No description provided for @atividadesRegistradas.
  ///
  /// In pt, this message translates to:
  /// **'{count, plural, =0{0 atividades registradas} =1{1 atividade registrada} other{{count} atividades registradas}}'**
  String atividadesRegistradas(int count);

  /// No description provided for @itensFluxo.
  ///
  /// In pt, this message translates to:
  /// **'{count, plural, =0{0 itens no fluxo de trabalho} =1{1 item no fluxo de trabalho} other{{count} itens no fluxo de trabalho}}'**
  String itensFluxo(int count);

  /// No description provided for @demandasRegistradas.
  ///
  /// In pt, this message translates to:
  /// **'{count, plural, =0{0 demandas registradas} =1{1 demanda registrada} other{{count} demandas registradas}}'**
  String demandasRegistradas(int count);

  /// No description provided for @atividadesDepartamento.
  ///
  /// In pt, this message translates to:
  /// **'Atividades do departamento'**
  String get atividadesDepartamento;

  /// No description provided for @quadroTrabalho.
  ///
  /// In pt, this message translates to:
  /// **'Quadro de trabalho'**
  String get quadroTrabalho;

  /// No description provided for @demandasDepartamento.
  ///
  /// In pt, this message translates to:
  /// **'Demandas do departamento'**
  String get demandasDepartamento;

  /// No description provided for @acessoDepartamento.
  ///
  /// In pt, this message translates to:
  /// **'Acesso ao departamento'**
  String get acessoDepartamento;

  /// No description provided for @acessoDepartamentoSub.
  ///
  /// In pt, this message translates to:
  /// **'Informações exibidas conforme seu perfil'**
  String get acessoDepartamentoSub;

  /// No description provided for @atencaoAgora.
  ///
  /// In pt, this message translates to:
  /// **'Atenção agora'**
  String get atencaoAgora;

  /// No description provided for @atencaoAgoraSub.
  ///
  /// In pt, this message translates to:
  /// **'Itens abertos ordenados por impacto'**
  String get atencaoAgoraSub;

  /// No description provided for @nenhumaDemandaAberta.
  ///
  /// In pt, this message translates to:
  /// **'Nenhuma demanda aberta.'**
  String get nenhumaDemandaAberta;

  /// No description provided for @responsavelPrazo.
  ///
  /// In pt, this message translates to:
  /// **'{responsavel} • prazo {prazo}'**
  String responsavelPrazo(String responsavel, String prazo);

  /// No description provided for @proximasAtividades.
  ///
  /// In pt, this message translates to:
  /// **'Próximas atividades'**
  String get proximasAtividades;

  /// No description provided for @proximasAtividadesSub.
  ///
  /// In pt, this message translates to:
  /// **'Compromissos que ainda pedem atenção'**
  String get proximasAtividadesSub;

  /// No description provided for @nenhumaAtividadeAberta.
  ///
  /// In pt, this message translates to:
  /// **'Nenhuma atividade aberta.'**
  String get nenhumaAtividadeAberta;

  /// No description provided for @atualizandoVisao.
  ///
  /// In pt, this message translates to:
  /// **'Atualizando visão operacional...'**
  String get atualizandoVisao;

  /// No description provided for @erroIndicadores.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível atualizar os indicadores.'**
  String get erroIndicadores;

  /// No description provided for @escolhaAtalhos.
  ///
  /// In pt, this message translates to:
  /// **'Escolha quais atalhos do menu aparecem na visão geral.'**
  String get escolhaAtalhos;

  /// No description provided for @personalizarAtalhos.
  ///
  /// In pt, this message translates to:
  /// **'Personalizar atalhos'**
  String get personalizarAtalhos;

  /// No description provided for @nenhumAtalho.
  ///
  /// In pt, this message translates to:
  /// **'Nenhum atalho selecionado. Toque no ícone acima para escolher.'**
  String get nenhumAtalho;

  /// No description provided for @minhaConta.
  ///
  /// In pt, this message translates to:
  /// **'Minha conta'**
  String get minhaConta;

  /// No description provided for @nome.
  ///
  /// In pt, this message translates to:
  /// **'Nome'**
  String get nome;

  /// No description provided for @email.
  ///
  /// In pt, this message translates to:
  /// **'E-mail'**
  String get email;

  /// No description provided for @perfilAcesso.
  ///
  /// In pt, this message translates to:
  /// **'Perfil de acesso'**
  String get perfilAcesso;

  /// No description provided for @aparenciaLeitura.
  ///
  /// In pt, this message translates to:
  /// **'Aparência e leitura'**
  String get aparenciaLeitura;

  /// No description provided for @modoNoturno.
  ///
  /// In pt, this message translates to:
  /// **'Modo noturno'**
  String get modoNoturno;

  /// No description provided for @modoNoturnoSub.
  ///
  /// In pt, this message translates to:
  /// **'Fundo escuro, mais confortável à noite'**
  String get modoNoturnoSub;

  /// No description provided for @tamanhoTexto.
  ///
  /// In pt, this message translates to:
  /// **'Tamanho do texto'**
  String get tamanhoTexto;

  /// No description provided for @tamanhoNormal.
  ///
  /// In pt, this message translates to:
  /// **'Normal'**
  String get tamanhoNormal;

  /// No description provided for @tamanhoMedio.
  ///
  /// In pt, this message translates to:
  /// **'Médio'**
  String get tamanhoMedio;

  /// No description provided for @tamanhoGrande.
  ///
  /// In pt, this message translates to:
  /// **'Grande'**
  String get tamanhoGrande;

  /// No description provided for @tamanhoMuitoGrande.
  ///
  /// In pt, this message translates to:
  /// **'Muito grande'**
  String get tamanhoMuitoGrande;

  /// No description provided for @idioma.
  ///
  /// In pt, this message translates to:
  /// **'Idioma'**
  String get idioma;

  /// No description provided for @idiomaAutomatico.
  ///
  /// In pt, this message translates to:
  /// **'Automático (idioma do celular)'**
  String get idiomaAutomatico;

  /// No description provided for @departamento.
  ///
  /// In pt, this message translates to:
  /// **'Departamento'**
  String get departamento;

  /// No description provided for @muralDepartamentoSub.
  ///
  /// In pt, this message translates to:
  /// **'Avisos do painel e frases motivacionais'**
  String get muralDepartamentoSub;

  /// No description provided for @sobre.
  ///
  /// In pt, this message translates to:
  /// **'Sobre'**
  String get sobre;

  /// No description provided for @sobreSigad.
  ///
  /// In pt, this message translates to:
  /// **'Sobre o SIGAD'**
  String get sobreSigad;

  /// No description provided for @versaoBuild.
  ///
  /// In pt, this message translates to:
  /// **'Versão {versao}'**
  String versaoBuild(String versao);

  /// No description provided for @sairDaConta.
  ///
  /// In pt, this message translates to:
  /// **'Sair da conta'**
  String get sairDaConta;

  /// No description provided for @fecharSobre.
  ///
  /// In pt, this message translates to:
  /// **'Fechar sobre o SIGAD'**
  String get fecharSobre;

  /// No description provided for @versao.
  ///
  /// In pt, this message translates to:
  /// **'Versão'**
  String get versao;

  /// No description provided for @desenvolvidoPor.
  ///
  /// In pt, this message translates to:
  /// **'Desenvolvido por'**
  String get desenvolvidoPor;

  /// No description provided for @equipeDesenvolvimento.
  ///
  /// In pt, this message translates to:
  /// **'Equipe de Desenvolvimento SIGAD'**
  String get equipeDesenvolvimento;

  /// No description provided for @dataLancamento.
  ///
  /// In pt, this message translates to:
  /// **'Data de lançamento'**
  String get dataLancamento;

  /// No description provided for @compatibilidade.
  ///
  /// In pt, this message translates to:
  /// **'Compatibilidade'**
  String get compatibilidade;

  /// No description provided for @sobreDescricao.
  ///
  /// In pt, this message translates to:
  /// **'O SIGAD é um sistema integrado de gestão acadêmica desenvolvido para otimizar processos administrativos e acadêmicos.'**
  String get sobreDescricao;

  /// No description provided for @sairPergunta.
  ///
  /// In pt, this message translates to:
  /// **'Tem certeza que deseja sair da aplicação?'**
  String get sairPergunta;

  /// No description provided for @facaLogin.
  ///
  /// In pt, this message translates to:
  /// **'Faça login para acessar configurações.'**
  String get facaLogin;

  /// No description provided for @salvar.
  ///
  /// In pt, this message translates to:
  /// **'Salvar'**
  String get salvar;

  /// No description provided for @excluir.
  ///
  /// In pt, this message translates to:
  /// **'Excluir'**
  String get excluir;

  /// No description provided for @continuar.
  ///
  /// In pt, this message translates to:
  /// **'Continuar'**
  String get continuar;

  /// No description provided for @reservar.
  ///
  /// In pt, this message translates to:
  /// **'Reservar'**
  String get reservar;

  /// No description provided for @hoje.
  ///
  /// In pt, this message translates to:
  /// **'Hoje'**
  String get hoje;

  /// No description provided for @feriado.
  ///
  /// In pt, this message translates to:
  /// **'Feriado'**
  String get feriado;

  /// No description provided for @detalhes.
  ///
  /// In pt, this message translates to:
  /// **'Detalhes'**
  String get detalhes;

  /// No description provided for @erroSalvar.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível salvar. Tente novamente.'**
  String get erroSalvar;

  /// No description provided for @diaSeg.
  ///
  /// In pt, this message translates to:
  /// **'Seg'**
  String get diaSeg;

  /// No description provided for @diaTer.
  ///
  /// In pt, this message translates to:
  /// **'Ter'**
  String get diaTer;

  /// No description provided for @diaQua.
  ///
  /// In pt, this message translates to:
  /// **'Qua'**
  String get diaQua;

  /// No description provided for @diaQui.
  ///
  /// In pt, this message translates to:
  /// **'Qui'**
  String get diaQui;

  /// No description provided for @diaSex.
  ///
  /// In pt, this message translates to:
  /// **'Sex'**
  String get diaSex;

  /// No description provided for @diaSegunda.
  ///
  /// In pt, this message translates to:
  /// **'segunda-feira'**
  String get diaSegunda;

  /// No description provided for @diaTerca.
  ///
  /// In pt, this message translates to:
  /// **'terça-feira'**
  String get diaTerca;

  /// No description provided for @diaQuarta.
  ///
  /// In pt, this message translates to:
  /// **'quarta-feira'**
  String get diaQuarta;

  /// No description provided for @diaQuinta.
  ///
  /// In pt, this message translates to:
  /// **'quinta-feira'**
  String get diaQuinta;

  /// No description provided for @diaSexta.
  ///
  /// In pt, this message translates to:
  /// **'sexta-feira'**
  String get diaSexta;

  /// No description provided for @turnoTodos.
  ///
  /// In pt, this message translates to:
  /// **'Todos'**
  String get turnoTodos;

  /// No description provided for @turnoManha.
  ///
  /// In pt, this message translates to:
  /// **'Manhã'**
  String get turnoManha;

  /// No description provided for @turnoTarde.
  ///
  /// In pt, this message translates to:
  /// **'Tarde'**
  String get turnoTarde;

  /// No description provided for @turnoNoite.
  ///
  /// In pt, this message translates to:
  /// **'Noite'**
  String get turnoNoite;

  /// No description provided for @turnoMatutino.
  ///
  /// In pt, this message translates to:
  /// **'Matutino'**
  String get turnoMatutino;

  /// No description provided for @turnoVespertino.
  ///
  /// In pt, this message translates to:
  /// **'Tarde'**
  String get turnoVespertino;

  /// No description provided for @turnoNoturno.
  ///
  /// In pt, this message translates to:
  /// **'Noite'**
  String get turnoNoturno;

  /// No description provided for @mesAbrev.
  ///
  /// In pt, this message translates to:
  /// **'{mes, select, 1{jan.} 2{fev.} 3{mar.} 4{abr.} 5{maio} 6{jun.} 7{jul.} 8{ago.} 9{set.} 10{out.} 11{nov.} other{dez.}}'**
  String mesAbrev(String mes);

  /// No description provided for @labAgenda.
  ///
  /// In pt, this message translates to:
  /// **'Agenda'**
  String get labAgenda;

  /// No description provided for @labErroCarregar.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível carregar as reservas.'**
  String get labErroCarregar;

  /// No description provided for @labIrParaSemana.
  ///
  /// In pt, this message translates to:
  /// **'Ir para a semana de'**
  String get labIrParaSemana;

  /// No description provided for @labSugestoes.
  ///
  /// In pt, this message translates to:
  /// **'Sugestões de horários'**
  String get labSugestoes;

  /// No description provided for @labSugestoesSub.
  ///
  /// In pt, this message translates to:
  /// **'Ocupação da semana e horários livres'**
  String get labSugestoesSub;

  /// No description provided for @labSomenteDocentes.
  ///
  /// In pt, this message translates to:
  /// **'Somente perfis docentes podem reservar horários.'**
  String get labSomenteDocentes;

  /// No description provided for @labHorarioOcupado.
  ///
  /// In pt, this message translates to:
  /// **'Esse horário já está ocupado. Escolha outro horário livre.'**
  String get labHorarioOcupado;

  /// No description provided for @labReservaFeita.
  ///
  /// In pt, this message translates to:
  /// **'Reserva feita: {lab}, {dia} {data}, {horario}.'**
  String labReservaFeita(String lab, String dia, String data, String horario);

  /// No description provided for @labHorariosReservados.
  ///
  /// In pt, this message translates to:
  /// **'{count, plural, =1{1 horário reservado.} other{{count} horários reservados.}}'**
  String labHorariosReservados(int count);

  /// No description provided for @labJaOcupados.
  ///
  /// In pt, this message translates to:
  /// **'{count, plural, =1{1 já estava ocupado.} other{{count} já estavam ocupados.}}'**
  String labJaOcupados(int count);

  /// No description provided for @labErroOperacao.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível concluir a operação. Tente novamente.'**
  String get labErroOperacao;

  /// No description provided for @labEditarOcorrencias.
  ///
  /// In pt, this message translates to:
  /// **'Editar ocorrências'**
  String get labEditarOcorrencias;

  /// No description provided for @labRepeteEditar.
  ///
  /// In pt, this message translates to:
  /// **'Essa reserva se repete em {count} ocorrências. Selecione quais você quer editar.'**
  String labRepeteEditar(int count);

  /// No description provided for @labRepeteExcluir.
  ///
  /// In pt, this message translates to:
  /// **'Essa reserva se repete em {count} ocorrências. Selecione quais você quer excluir.'**
  String labRepeteExcluir(int count);

  /// No description provided for @labNovoHorarioOcupado.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível salvar: o novo horário já está ocupado em todas as ocorrências selecionadas.'**
  String get labNovoHorarioOcupado;

  /// No description provided for @labReservaAtualizada.
  ///
  /// In pt, this message translates to:
  /// **'Reserva atualizada.'**
  String get labReservaAtualizada;

  /// No description provided for @labOcorrenciasAtualizadas.
  ///
  /// In pt, this message translates to:
  /// **'{count} ocorrências atualizadas.'**
  String labOcorrenciasAtualizadas(int count);

  /// No description provided for @labNaoMovidas.
  ///
  /// In pt, this message translates to:
  /// **'{count} não puderam ser movidas (horário ocupado).'**
  String labNaoMovidas(int count);

  /// No description provided for @labExcluirOcorrencias.
  ///
  /// In pt, this message translates to:
  /// **'Excluir ocorrências'**
  String get labExcluirOcorrencias;

  /// No description provided for @labRevisarExclusao.
  ///
  /// In pt, this message translates to:
  /// **'Revisar exclusão'**
  String get labRevisarExclusao;

  /// No description provided for @labExcluirReserva.
  ///
  /// In pt, this message translates to:
  /// **'Excluir reserva'**
  String get labExcluirReserva;

  /// No description provided for @labRemoverUma.
  ///
  /// In pt, this message translates to:
  /// **'Deseja remover a reserva de {ocorrencia} no {lab}?'**
  String labRemoverUma(String ocorrencia, String lab);

  /// No description provided for @labRemoverVarias.
  ///
  /// In pt, this message translates to:
  /// **'Deseja remover as {count} ocorrências selecionadas no {lab}?'**
  String labRemoverVarias(int count, String lab);

  /// No description provided for @labReservaRemovida.
  ///
  /// In pt, this message translates to:
  /// **'Reserva removida.'**
  String get labReservaRemovida;

  /// No description provided for @labOcorrenciasRemovidas.
  ///
  /// In pt, this message translates to:
  /// **'{count} ocorrências removidas.'**
  String labOcorrenciasRemovidas(int count);

  /// No description provided for @labFacaLogin.
  ///
  /// In pt, this message translates to:
  /// **'Faça login para reservar horários.'**
  String get labFacaLogin;

  /// No description provided for @labSemSugestoes.
  ///
  /// In pt, this message translates to:
  /// **'Não há horários livres sugeridos para esta semana.'**
  String get labSemSugestoes;

  /// No description provided for @labReservarSugeridoTitulo.
  ///
  /// In pt, this message translates to:
  /// **'Reservar horário sugerido?'**
  String get labReservarSugeridoTitulo;

  /// No description provided for @labReservaNoSeuNome.
  ///
  /// In pt, this message translates to:
  /// **'A reserva fica no seu nome.'**
  String get labReservaNoSeuNome;

  /// No description provided for @labSugestaoIndisponivel.
  ///
  /// In pt, this message translates to:
  /// **'A sugestão ficou indisponível. Tente novamente.'**
  String get labSugestaoIndisponivel;

  /// No description provided for @labEditarReserva.
  ///
  /// In pt, this message translates to:
  /// **'Editar reserva'**
  String get labEditarReserva;

  /// No description provided for @labDisciplinaOpcional.
  ///
  /// In pt, this message translates to:
  /// **'Disciplina (opcional)'**
  String get labDisciplinaOpcional;

  /// No description provided for @labDiaSemana.
  ///
  /// In pt, this message translates to:
  /// **'Dia da semana'**
  String get labDiaSemana;

  /// No description provided for @labHorario.
  ///
  /// In pt, this message translates to:
  /// **'Horário'**
  String get labHorario;

  /// No description provided for @labHorarioJaOcupado.
  ///
  /// In pt, this message translates to:
  /// **'Horário já ocupado'**
  String get labHorarioJaOcupado;

  /// No description provided for @labLaboratorio.
  ///
  /// In pt, this message translates to:
  /// **'Laboratório'**
  String get labLaboratorio;

  /// No description provided for @labSemanaMesmoMes.
  ///
  /// In pt, this message translates to:
  /// **'{inicio} a {fim} de {mes}'**
  String labSemanaMesmoMes(int inicio, int fim, String mes);

  /// No description provided for @labSemanaDoisMeses.
  ///
  /// In pt, this message translates to:
  /// **'{inicio} de {mesInicio} a {fim} de {mesFim}'**
  String labSemanaDoisMeses(
    int inicio,
    String mesInicio,
    int fim,
    String mesFim,
  );

  /// No description provided for @labSemanaAnterior.
  ///
  /// In pt, this message translates to:
  /// **'Semana anterior'**
  String get labSemanaAnterior;

  /// No description provided for @labProximaSemana.
  ///
  /// In pt, this message translates to:
  /// **'Próxima semana'**
  String get labProximaSemana;

  /// No description provided for @labSemanaSemantica.
  ///
  /// In pt, this message translates to:
  /// **'Semana de {rotulo} de {ano}. Escolher outra data'**
  String labSemanaSemantica(String rotulo, String ano);

  /// No description provided for @labEstaSemana.
  ///
  /// In pt, this message translates to:
  /// **'Esta semana'**
  String get labEstaSemana;

  /// No description provided for @labHorarioLivre.
  ///
  /// In pt, this message translates to:
  /// **'Horário livre'**
  String get labHorarioLivre;

  /// No description provided for @labMinhaReserva.
  ///
  /// In pt, this message translates to:
  /// **'Minha reserva'**
  String get labMinhaReserva;

  /// No description provided for @labReservadoPorOutro.
  ///
  /// In pt, this message translates to:
  /// **'Reservado por outro'**
  String get labReservadoPorOutro;

  /// No description provided for @labArrasteAgenda.
  ///
  /// In pt, this message translates to:
  /// **'Arraste a agenda para o lado para ver todos os dias.'**
  String get labArrasteAgenda;

  /// No description provided for @labCabecalhoDia.
  ///
  /// In pt, this message translates to:
  /// **'{dia}, {data}'**
  String labCabecalhoDia(String dia, String data);

  /// No description provided for @labHojeSufixo.
  ///
  /// In pt, this message translates to:
  /// **', hoje'**
  String get labHojeSufixo;

  /// No description provided for @labFeriadoSufixo.
  ///
  /// In pt, this message translates to:
  /// **', feriado: {nome}'**
  String labFeriadoSufixo(String nome);

  /// No description provided for @labCelula.
  ///
  /// In pt, this message translates to:
  /// **'Célula {dia}, dia {numero}, {turno}, período {periodo}, horário {horario}.'**
  String labCelula(
    String dia,
    int numero,
    String turno,
    int periodo,
    String horario,
  );

  /// No description provided for @labLivre.
  ///
  /// In pt, this message translates to:
  /// **'Livre'**
  String get labLivre;

  /// No description provided for @labReservadoPor.
  ///
  /// In pt, this message translates to:
  /// **'Reservado por {nome}'**
  String labReservadoPor(String nome);

  /// No description provided for @labToqueDetalhes.
  ///
  /// In pt, this message translates to:
  /// **'Toque para ver os detalhes da reserva.'**
  String get labToqueDetalhes;

  /// No description provided for @labToqueReservar.
  ///
  /// In pt, this message translates to:
  /// **'Toque para reservar.'**
  String get labToqueReservar;

  /// No description provided for @labDetalhesReserva.
  ///
  /// In pt, this message translates to:
  /// **'Detalhes da reserva'**
  String get labDetalhesReserva;

  /// No description provided for @labReservaDeLaboratorio.
  ///
  /// In pt, this message translates to:
  /// **'Reserva de laboratório'**
  String get labReservaDeLaboratorio;

  /// No description provided for @labSuaReserva.
  ///
  /// In pt, this message translates to:
  /// **'Sua reserva'**
  String get labSuaReserva;

  /// No description provided for @labData.
  ///
  /// In pt, this message translates to:
  /// **'Data'**
  String get labData;

  /// No description provided for @labReservadoPorRotulo.
  ///
  /// In pt, this message translates to:
  /// **'Reservado por'**
  String get labReservadoPorRotulo;

  /// No description provided for @labSoQuemFez.
  ///
  /// In pt, this message translates to:
  /// **'Só quem fez a reserva ou a chefia pode alterá-la.'**
  String get labSoQuemFez;

  /// No description provided for @labAcessoRestrito.
  ///
  /// In pt, this message translates to:
  /// **'Acesso restrito'**
  String get labAcessoRestrito;

  /// No description provided for @labAcessoRestritoMsg.
  ///
  /// In pt, this message translates to:
  /// **'Este módulo está disponível para professor, coordenador e chefe do departamento.'**
  String get labAcessoRestritoMsg;

  /// No description provided for @labOtimizacao.
  ///
  /// In pt, this message translates to:
  /// **'Otimização de laboratórios'**
  String get labOtimizacao;

  /// No description provided for @labReservarSugestao.
  ///
  /// In pt, this message translates to:
  /// **'Reservar sugestão'**
  String get labReservarSugestao;

  /// No description provided for @labOcupadoNaSemana.
  ///
  /// In pt, this message translates to:
  /// **'ocupado na semana em {lab}'**
  String labOcupadoNaSemana(String lab);

  /// No description provided for @labIndicadorOcupacao.
  ///
  /// In pt, this message translates to:
  /// **'{lab}: {taxa}% · {livres} livres'**
  String labIndicadorOcupacao(String lab, String taxa, int livres);

  /// No description provided for @labSugestoesSlots.
  ///
  /// In pt, this message translates to:
  /// **'Sugestões de horários livres'**
  String get labSugestoesSlots;

  /// No description provided for @labRecomendacoesCruzadas.
  ///
  /// In pt, this message translates to:
  /// **'Recomendações cruzadas com carga docente'**
  String get labRecomendacoesCruzadas;

  /// No description provided for @labRecomendacao.
  ///
  /// In pt, this message translates to:
  /// **'{nome}: priorizar {lab} em {dia} {horario} para aliviar carga em turmas práticas.'**
  String labRecomendacao(String nome, String lab, String dia, String horario);

  /// No description provided for @labAvisoInterditado.
  ///
  /// In pt, this message translates to:
  /// **'Este laboratório está interditado. Confirme com a chefia antes de reservar.'**
  String get labAvisoInterditado;

  /// No description provided for @labAvisoManutencao.
  ///
  /// In pt, this message translates to:
  /// **'Este laboratório está em manutenção. Confirme se ele estará disponível antes de reservar.'**
  String get labAvisoManutencao;

  /// No description provided for @labTodosCount.
  ///
  /// In pt, this message translates to:
  /// **'Todos ({count})'**
  String labTodosCount(int count);

  /// No description provided for @labStatusCount.
  ///
  /// In pt, this message translates to:
  /// **'{status} ({count})'**
  String labStatusCount(String status, int count);

  /// No description provided for @labOcorrenciaRegistrada.
  ///
  /// In pt, this message translates to:
  /// **'Ocorrência registrada.'**
  String get labOcorrenciaRegistrada;

  /// No description provided for @labMarcarResolvida.
  ///
  /// In pt, this message translates to:
  /// **'Marcar como resolvida?'**
  String get labMarcarResolvida;

  /// No description provided for @labDeixaraDeContar.
  ///
  /// In pt, this message translates to:
  /// **'\"{titulo}\" deixará de contar como ativa.'**
  String labDeixaraDeContar(String titulo);

  /// No description provided for @labResolvida.
  ///
  /// In pt, this message translates to:
  /// **'Resolvida'**
  String get labResolvida;

  /// No description provided for @labOcorrenciaResolvidaMsg.
  ///
  /// In pt, this message translates to:
  /// **'Ocorrência marcada como resolvida.'**
  String get labOcorrenciaResolvidaMsg;

  /// No description provided for @labReportarProblema.
  ///
  /// In pt, this message translates to:
  /// **'Reportar problema'**
  String get labReportarProblema;

  /// No description provided for @labProximasReservas.
  ///
  /// In pt, this message translates to:
  /// **'Próximas reservas'**
  String get labProximasReservas;

  /// No description provided for @labVerAgenda.
  ///
  /// In pt, this message translates to:
  /// **'Ver agenda'**
  String get labVerAgenda;

  /// No description provided for @labNenhumaReservaFutura.
  ///
  /// In pt, this message translates to:
  /// **'Nenhuma reserva futura para este laboratório.'**
  String get labNenhumaReservaFutura;

  /// No description provided for @labEquipamentos.
  ///
  /// In pt, this message translates to:
  /// **'Equipamentos'**
  String get labEquipamentos;

  /// No description provided for @labNenhumEquipamento.
  ///
  /// In pt, this message translates to:
  /// **'Nenhum equipamento cadastrado.'**
  String get labNenhumEquipamento;

  /// No description provided for @labUnidades.
  ///
  /// In pt, this message translates to:
  /// **'{count, plural, =1{1 unidade} other{{count} unidades}}'**
  String labUnidades(int count);

  /// No description provided for @labManutencao.
  ///
  /// In pt, this message translates to:
  /// **'Manutenção'**
  String get labManutencao;

  /// No description provided for @labConcluida.
  ///
  /// In pt, this message translates to:
  /// **'Concluída'**
  String get labConcluida;

  /// No description provided for @labEmAndamento.
  ///
  /// In pt, this message translates to:
  /// **'Em andamento'**
  String get labEmAndamento;

  /// No description provided for @labOcorrencias.
  ///
  /// In pt, this message translates to:
  /// **'Ocorrências'**
  String get labOcorrencias;

  /// No description provided for @labResolverOcorrencia.
  ///
  /// In pt, this message translates to:
  /// **'Resolver ocorrência: {titulo}'**
  String labResolverOcorrencia(String titulo);

  /// No description provided for @labResolver.
  ///
  /// In pt, this message translates to:
  /// **'Resolver'**
  String get labResolver;

  /// No description provided for @labOperando.
  ///
  /// In pt, this message translates to:
  /// **'Operando'**
  String get labOperando;

  /// No description provided for @labEmManutencao.
  ///
  /// In pt, this message translates to:
  /// **'Em manutenção'**
  String get labEmManutencao;

  /// No description provided for @labInterditado.
  ///
  /// In pt, this message translates to:
  /// **'Interditado'**
  String get labInterditado;

  /// No description provided for @labReservasNoMes.
  ///
  /// In pt, this message translates to:
  /// **'Reservas no mês'**
  String get labReservasNoMes;

  /// No description provided for @labOcorrenciasAtivas.
  ///
  /// In pt, this message translates to:
  /// **'Ocorrências ativas'**
  String get labOcorrenciasAtivas;

  /// No description provided for @labCapacidadePessoas.
  ///
  /// In pt, this message translates to:
  /// **'Capacidade: {count} pessoas'**
  String labCapacidadePessoas(int count);

  /// No description provided for @labPessoas.
  ///
  /// In pt, this message translates to:
  /// **'{count} pessoas'**
  String labPessoas(int count);

  /// No description provided for @labEquipamentosDisponiveisCount.
  ///
  /// In pt, this message translates to:
  /// **'{count, plural, =0{0 equipamentos disponíveis} =1{1 equipamento disponível} other{{count} equipamentos disponíveis}}'**
  String labEquipamentosDisponiveisCount(int count);

  /// No description provided for @labReservasNesteMes.
  ///
  /// In pt, this message translates to:
  /// **'{count, plural, =0{0 reservas neste mês} =1{1 reserva neste mês} other{{count} reservas neste mês}}'**
  String labReservasNesteMes(int count);

  /// No description provided for @labOcorrenciasAtivasCount.
  ///
  /// In pt, this message translates to:
  /// **'{count, plural, =1{1 ocorrência ativa} other{{count} ocorrências ativas}}'**
  String labOcorrenciasAtivasCount(int count);

  /// No description provided for @labCapacidade.
  ///
  /// In pt, this message translates to:
  /// **'Capacidade'**
  String get labCapacidade;

  /// No description provided for @labResponsavelTecnico.
  ///
  /// In pt, this message translates to:
  /// **'Responsável técnico'**
  String get labResponsavelTecnico;

  /// No description provided for @labEquipamentosDisponiveis.
  ///
  /// In pt, this message translates to:
  /// **'Equipamentos disponíveis'**
  String get labEquipamentosDisponiveis;

  /// No description provided for @labNenhumLabStatus.
  ///
  /// In pt, this message translates to:
  /// **'Nenhum laboratório encontrado com este status.'**
  String get labNenhumLabStatus;

  /// No description provided for @labDisponivel.
  ///
  /// In pt, this message translates to:
  /// **'Disponível'**
  String get labDisponivel;

  /// No description provided for @labEmUso.
  ///
  /// In pt, this message translates to:
  /// **'Em uso'**
  String get labEmUso;

  /// No description provided for @labIndisponivel.
  ///
  /// In pt, this message translates to:
  /// **'Indisponível'**
  String get labIndisponivel;

  /// No description provided for @labRegistrarOcorrencia.
  ///
  /// In pt, this message translates to:
  /// **'Registrar ocorrência'**
  String get labRegistrarOcorrencia;

  /// No description provided for @labOQueAconteceu.
  ///
  /// In pt, this message translates to:
  /// **'O que aconteceu?'**
  String get labOQueAconteceu;

  /// No description provided for @labExemploProblema.
  ///
  /// In pt, this message translates to:
  /// **'Ex.: Osciloscópio da bancada 3 não liga'**
  String get labExemploProblema;

  /// No description provided for @labDescrevaProblema.
  ///
  /// In pt, this message translates to:
  /// **'Descreva o problema em poucas palavras.'**
  String get labDescrevaProblema;

  /// No description provided for @labDetalhesOpcional.
  ///
  /// In pt, this message translates to:
  /// **'Detalhes (opcional)'**
  String get labDetalhesOpcional;

  /// No description provided for @labDetalhesHint.
  ///
  /// In pt, this message translates to:
  /// **'Onde, desde quando e o que já foi tentado.'**
  String get labDetalhesHint;

  /// No description provided for @labSemDadosPessoais.
  ///
  /// In pt, this message translates to:
  /// **'Não inclua nomes, matrículas ou dados pessoais.'**
  String get labSemDadosPessoais;

  /// No description provided for @labSoEstaSemana.
  ///
  /// In pt, this message translates to:
  /// **'Só esta semana'**
  String get labSoEstaSemana;

  /// No description provided for @labEstaEMais.
  ///
  /// In pt, this message translates to:
  /// **'{count, plural, =1{Esta e mais 1 semana} other{Esta e mais {count} semanas}}'**
  String labEstaEMais(int count);

  /// No description provided for @labReservarHorario.
  ///
  /// In pt, this message translates to:
  /// **'Reservar horário'**
  String get labReservarHorario;

  /// No description provided for @labHorarioEMais.
  ///
  /// In pt, this message translates to:
  /// **'{count, plural, =1{{horario} e mais 1 horário} other{{horario} e mais {count} horários}}'**
  String labHorarioEMais(String horario, int count);

  /// No description provided for @labRepetir.
  ///
  /// In pt, this message translates to:
  /// **'Repetir'**
  String get labRepetir;

  /// No description provided for @labRepeticaoAte.
  ///
  /// In pt, this message translates to:
  /// **'A repetição vai no máximo até {data}, fim do mês.'**
  String labRepeticaoAte(String data);

  /// No description provided for @labOutrosHorarios.
  ///
  /// In pt, this message translates to:
  /// **'Reservar outros horários deste dia'**
  String get labOutrosHorarios;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'pt'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'pt':
      return AppLocalizationsPt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
