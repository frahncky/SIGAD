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
  /// **'Gestão acadêmica e departamental do IFMA — Campus São Luís–Monte Castelo.'**
  String get loginTitulo;

  /// No description provided for @loginSubtitulo.
  ///
  /// In pt, this message translates to:
  /// **'Planeje as atividades do DEE: carga docente, laboratórios, reuniões e demandas.'**
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
  /// **'Departamento de Eletroeletrônica · IFMA Campus Monte Castelo'**
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
