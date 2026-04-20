import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../app/routes/app_routes.dart';
import '../../../../app/theme/sigad_colors.dart';
import '../../../../core/security/authorization_policy.dart';
import '../../../../core/services/app_feedback_service.dart';
import '../../../../core/models/user_role.dart';
import '../../../../core/services/theme_provider.dart';
import '../../../../core/services/user_context_provider.dart';
import '../../data/configuracoes_repository.dart';
import '../../domain/configuracoes_models.dart';
import '../../domain/configuracoes_service.dart';

class ConfiguracoesPage extends StatefulWidget {
  const ConfiguracoesPage({super.key});

  @override
  State<ConfiguracoesPage> createState() => _ConfiguracoesPageState();
}

class _ConfiguracoesPageState extends State<ConfiguracoesPage> {
  bool _notificacoesAtivas = ConfiguracoesService.defaultData().notificacoesAtivas;
  bool _notificarAntesDaDisciplina = ConfiguracoesService.defaultData().notificarAntesDaDisciplina;
  int _antecedenciaNotificacaoMinutos = ConfiguracoesService.defaultData().antecedenciaNotificacaoMinutos;
  bool _modoDark = ConfiguracoesService.defaultData().modoDark;
  bool _biometriaAtiva = ConfiguracoesService.defaultData().biometriaAtiva;
  bool _backupAutomaticoAtivo = ConfiguracoesService.defaultData().backupAutomaticoAtivo;
  String _idioma = ConfiguracoesService.defaultData().idioma;
  String _tamanhoFonte = ConfiguracoesService.defaultData().tamanhoFonte;
  String _nomePerfil = ConfiguracoesService.defaultData().nomePerfil;
  String _cargoPerfil = ConfiguracoesService.defaultData().cargoPerfil;
  String _emailUsuario = ConfiguracoesService.defaultData().emailUsuario;
  String _ultimaAlteracaoSenha = ConfiguracoesService.defaultData().ultimaAlteracaoSenha;
  String _proximoBackup = ConfiguracoesService.defaultData().proximoBackup;
  String _ultimoBackup = ConfiguracoesService.defaultData().ultimoBackup;
  int _problemasReportados = ConfiguracoesService.defaultData().problemasReportados;
  List<CompromissoAgenda> _agendaCompromissos = ConfiguracoesService.defaultData().agendaCompromissos;

  final ConfiguracoesRepository _configuracoesRepository = ConfiguracoesRepository();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final data = await _configuracoesRepository.load();
    if (data == null) return;
    setState(() {
      _notificacoesAtivas = data.notificacoesAtivas;
      _notificarAntesDaDisciplina = data.notificarAntesDaDisciplina;
      _antecedenciaNotificacaoMinutos = data.antecedenciaNotificacaoMinutos;
      _modoDark = data.modoDark;
      _biometriaAtiva = data.biometriaAtiva;
      _backupAutomaticoAtivo = data.backupAutomaticoAtivo;
      _idioma = data.idioma;
      _tamanhoFonte = data.tamanhoFonte;
      _nomePerfil = data.nomePerfil;
      _cargoPerfil = data.cargoPerfil;
      _emailUsuario = data.emailUsuario;
      _ultimaAlteracaoSenha = data.ultimaAlteracaoSenha;
      _proximoBackup = data.proximoBackup;
      _ultimoBackup = data.ultimoBackup;
      _problemasReportados = data.problemasReportados;
      _agendaCompromissos = data.agendaCompromissos;
    });
  }

  void _saveData() {
    _configuracoesRepository.save(
      ConfiguracoesData(
        notificacoesAtivas: _notificacoesAtivas,
        notificarAntesDaDisciplina: _notificarAntesDaDisciplina,
        antecedenciaNotificacaoMinutos: _antecedenciaNotificacaoMinutos,
        modoDark: _modoDark,
        biometriaAtiva: _biometriaAtiva,
        backupAutomaticoAtivo: _backupAutomaticoAtivo,
        idioma: _idioma,
        tamanhoFonte: _tamanhoFonte,
        nomePerfil: _nomePerfil,
        cargoPerfil: _cargoPerfil,
        emailUsuario: _emailUsuario,
        ultimaAlteracaoSenha: _ultimaAlteracaoSenha,
        proximoBackup: _proximoBackup,
        ultimoBackup: _ultimoBackup,
        problemasReportados: _problemasReportados,
        agendaCompromissos: _agendaCompromissos,
      ),
    );
  }

  void _mostrarFeedback(String mensagem) {
    AppFeedbackService.info(context, mensagem);
  }

  @override
  Widget build(BuildContext context) {
    final role = context.watch<UserContextProvider>().userRole;
    if (!AuthorizationPolicy.canAccessConfiguracoes(role)) {
      return const _ConfiguracoesAccessDenied();
    }

    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        children: [
          _ConfigSection(
            titulo: 'Conta',
            children: [
              _ConfigItem(
                icon: Icons.person,
                titulo: 'Perfil',
                subtitulo: 'Nome: $_nomePerfil',
                onTap: () => _showAlerta(context, 'Perfil'),
              ),
              _ConfigItem(
                icon: Icons.email,
                titulo: 'Email',
                subtitulo: _emailUsuario,
                onTap: () => _showAlerta(context, 'Email'),
              ),
              _ConfigItem(
                icon: Icons.lock,
                titulo: 'Senha',
                subtitulo: 'Última alteração: $_ultimaAlteracaoSenha',
                onTap: () => _showAlerta(context, 'Alterar Senha'),
              ),
            ],
          ),
          _ConfigSection(
            titulo: 'Preferências',
            children: [
              _ConfigToggle(
                icon: Icons.notifications,
                titulo: 'Notificações',
                subtitulo: 'Receber alertas de demandas e atividades',
                value: _notificacoesAtivas,
                onChanged: (value) {
                  setState(() => _notificacoesAtivas = value);
                                  _saveData();
                },
              ),
              _ConfigToggle(
                icon: Icons.dark_mode,
                titulo: 'Modo noturno',
                subtitulo: 'Ativar tema escuro',
                value: _modoDark,
                onChanged: (value) {
                  setState(() => _modoDark = value);
                  context.read<ThemeProvider>().setDark(value);
                                  _saveData();
                },
              ),
              _ConfigToggle(
                icon: Icons.fingerprint,
                titulo: 'Autenticação biométrica',
                subtitulo: 'Usar impressão digital ou rosto',
                value: _biometriaAtiva,
                onChanged: (value) {
                  setState(() => _biometriaAtiva = value);
                                  _saveData();
                },
              ),
            ],
          ),
          if (_isDocenteComLembrete(role))
            _ConfigSection(
              titulo: 'Disciplinas e lembretes',
              children: [
                _ConfigToggle(
                  icon: Icons.schedule,
                  titulo: 'Lembrete da próxima disciplina',
                  subtitulo: _notificarAntesDaDisciplina
                      ? 'Notificar $_antecedenciaNotificacaoMinutos min antes do início'
                      : 'Lembrete desativado',
                  value: _notificarAntesDaDisciplina,
                  onChanged: (value) {
                    setState(() => _notificarAntesDaDisciplina = value);
                    _saveData();
                  },
                ),
                if (_notificarAntesDaDisciplina)
                  _ConfigDropdown(
                    icon: Icons.timer_outlined,
                    titulo: 'Antecedência do lembrete',
                    valor: '$_antecedenciaNotificacaoMinutos min',
                    opcoes: ConfiguracoesService.opcoesAntecedenciaMinutos
                        .map((item) => '$item min')
                        .toList(growable: false),
                    onChanged: (valor) {
                      final minutos = int.parse(valor.replaceAll(' min', ''));
                      final erro = ConfiguracoesService.validarAntecedenciaDisciplina(minutos);
                      if (erro != null) {
                        _mostrarFeedback(erro);
                        return;
                      }
                      setState(() => _antecedenciaNotificacaoMinutos = minutos);
                      _saveData();
                    },
                  ),
              ],
            ),
          // Removed Agenda de compromissos section
          _ConfigSection(
            titulo: 'Idioma e Aparência',
            children: [
              _ConfigDropdown(
                icon: Icons.language,
                titulo: 'Idioma',
                valor: _idioma,
                opcoes: [
                  'Português (Brasil)',
                  'English',
                  'Español',
                ],
                onChanged: (valor) {
                  setState(() => _idioma = valor);
                                  _saveData();
                },
              ),
              _ConfigDropdown(
                icon: Icons.text_fields,
                titulo: 'Tamanho da fonte',
                valor: _tamanhoFonte,
                opcoes: [
                  'Pequeno',
                  'Médio',
                  'Grande',
                ],
                onChanged: (valor) {
                  setState(() => _tamanhoFonte = valor);
                                  _saveData();
                },
              ),
            ],
          ),
          _ConfigSection(
            titulo: 'Dados e Privacidade',
            children: [
              _ConfigItem(
                icon: Icons.backup,
                titulo: 'Backup automático',
                subtitulo: 'Próximo backup em: $_proximoBackup',
                onTap: () => _showAlerta(context, 'Backup'),
              ),
              _ConfigItem(
                icon: Icons.privacy_tip,
                titulo: 'Política de privacidade',
                subtitulo: 'Versão 2.1 (efetivo desde 01/01/2026)',
                onTap: () => _showAlerta(context, 'Política de Privacidade'),
              ),
              _ConfigItem(
                icon: Icons.description,
                titulo: 'Termos de serviço',
                subtitulo: 'Versão 1.5',
                onTap: () => _showAlerta(context, 'Termos de Serviço'),
              ),
            ],
          ),
          _ConfigSection(
            titulo: 'Sobre',
            children: [
              _ConfigItem(
                icon: Icons.info,
                titulo: 'Sobre o SIGAD',
                subtitulo: 'Versão 1.0.0 (Build 42)',
                onTap: () => _showAlerta(context, 'Sobre'),
              ),
              _ConfigItem(
                icon: Icons.bug_report,
                titulo: 'Reportar problema',
                subtitulo: _problemasReportados == 0
                    ? 'Enviar feedback ou relatar bugs'
                    : '$_problemasReportados relato(s) enviados',
                onTap: () => _showAlerta(context, 'Reportar Problema'),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: ElevatedButton.icon(
              onPressed: () => _showConfirmacaoLogout(context),
              icon: const Icon(Icons.logout),
              label: const Text('Sair'),
              style: ElevatedButton.styleFrom(
                backgroundColor: SigadColors.risk,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool _isDocenteComLembrete(UserRole? role) {
    return role == UserRole.professor ||
        role == UserRole.coordenador ||
        role == UserRole.chefeDepartamento;
  }

  void _showAlerta(BuildContext context, String titulo) {
    switch (titulo) {
      case 'Perfil':
        _showEditarPerfil(context);
        break;
      case 'Email':
        _showAlterarEmail(context);
        break;
      case 'Alterar Senha':
        _showAlterarSenha(context);
        break;
      case 'Backup':
        _showBackup(context);
        break;
      case 'Política de Privacidade':
        _showPoliticaPrivacidade(context);
        break;
      case 'Termos de Serviço':
        _showTermosServico(context);
        break;
      case 'Sobre':
        _showSobre(context);
        break;
      case 'Reportar Problema':
        _showReportarProblema(context);
        break;
      default:
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(titulo),
            content: Text('Funcionalidade de $titulo implementada aqui.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
    }
  }

  void _showEditarPerfil(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final nomeController = TextEditingController(text: _nomePerfil);
    final cargoController = TextEditingController(text: _cargoPerfil);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        height: MediaQuery.of(context).size.height * 0.7,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Editar Perfil', style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 24),
            TextField(
              controller: nomeController,
              decoration: const InputDecoration(
                labelText: 'Nome Completo',
                hintText: 'Digite seu nome completo',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: cargoController,
              decoration: const InputDecoration(
                labelText: 'Cargo',
                hintText: 'Digite seu cargo',
              ),
            ),
            const Spacer(),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancelar'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                        final erro = ConfiguracoesService.validarPerfil(
                          nome: nomeController.text,
                          cargo: cargoController.text,
                        );
                        if (erro != null) {
                          _mostrarFeedback(erro);
                        return;
                        }

                      setState(() {
                        _nomePerfil = nomeController.text.trim();
                        _cargoPerfil = cargoController.text.trim();
                      });
                      _saveData();

                      Navigator.pop(context);
                      _mostrarFeedback('Perfil atualizado com sucesso!');
                    },
                    child: const Text('Salvar'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showAlterarEmail(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final emailController = TextEditingController(text: _emailUsuario);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        height: MediaQuery.of(context).size.height * 0.6,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Alterar Email', style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 24),
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Novo Email',
                hintText: 'Digite seu novo email',
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Será enviado um código de verificação para o novo email.',
              style: textTheme.bodySmall?.copyWith(color: SigadColors.muted),
            ),
            const Spacer(),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancelar'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      final email = emailController.text.trim();
                        final erro = ConfiguracoesService.validarEmail(email);
                        if (erro != null) {
                          _mostrarFeedback(erro);
                        return;
                        }

                      setState(() {
                        _emailUsuario = email;
                      });
                      _saveData();

                      Navigator.pop(context);
                      _mostrarFeedback('Código de verificação enviado!');
                    },
                    child: const Text('Enviar Código'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showAlterarSenha(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final senhaAtualController = TextEditingController();
    final novaSenhaController = TextEditingController();
    final confirmarSenhaController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        height: MediaQuery.of(context).size.height * 0.8,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Alterar Senha', style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 24),
            TextField(
              controller: senhaAtualController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Senha Atual',
                hintText: 'Digite sua senha atual',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: novaSenhaController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Nova Senha',
                hintText: 'Digite sua nova senha',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: confirmarSenhaController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Confirmar Nova Senha',
                hintText: 'Confirme sua nova senha',
              ),
            ),
            const Spacer(),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancelar'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      final senhaAtual = senhaAtualController.text.trim();
                      final novaSenha = novaSenhaController.text.trim();
                      final confirmarSenha = confirmarSenhaController.text.trim();

                        final erro = ConfiguracoesService.validarAlteracaoSenha(
                          senhaAtual: senhaAtual,
                          novaSenha: novaSenha,
                          confirmarSenha: confirmarSenha,
                        );
                        if (erro != null) {
                          _mostrarFeedback(erro);
                          return;
                        }

                      setState(() {
                          _ultimaAlteracaoSenha = ConfiguracoesService.dataAtual();
                      });
                      _saveData();

                      Navigator.pop(context);
                      _mostrarFeedback('Senha alterada com sucesso!');
                    },
                    child: const Text('Alterar'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showBackup(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    showModalBottomSheet(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Backup Automático', style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                'Configurações de Backup',
                style: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 16),
              _ConfigToggle(
                icon: Icons.backup,
                titulo: 'Backup automático',
                subtitulo: 'Realizar backup diariamente',
                value: _backupAutomaticoAtivo,
                onChanged: (value) {
                  setState(() {
                    _backupAutomaticoAtivo = value;
                    _proximoBackup = value ? ConfiguracoesService.dataFutura(1) : 'Desativado';
                  });
                  _saveData();
                  setModalState(() {});
                },
              ),
              const SizedBox(height: 16),
              Text(
                'Último backup: $_ultimoBackup',
                style: textTheme.bodySmall?.copyWith(color: SigadColors.muted),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        setState(() {
                          _ultimoBackup = ConfiguracoesService.dataHoraAtual();
                          _proximoBackup = _backupAutomaticoAtivo ? ConfiguracoesService.dataFutura(1) : 'Desativado';
                        });
                        _saveData();
                        Navigator.pop(context);
                        _mostrarFeedback('Backup realizado com sucesso!');
                      },
                      child: const Text('Fazer Backup Agora'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPoliticaPrivacidade(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        height: MediaQuery.of(context).size.height * 0.8,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Política de Privacidade', style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  'Política de Privacidade do SIGAD\n\n'
                  'Última atualização: 01/01/2026\n\n'
                  'Esta Política de Privacidade descreve como coletamos, usamos e protegemos suas informações pessoais...\n\n'
                  '1. Informações que coletamos\n'
                  '• Dados de conta (nome, email, cargo)\n'
                  '• Dados de uso da aplicação\n'
                  '• Preferências de configuração\n\n'
                  '2. Como usamos suas informações\n'
                  '• Para fornecer e melhorar nossos serviços\n'
                  '• Para comunicação sobre atualizações\n'
                  '• Para suporte técnico\n\n'
                  '3. Compartilhamento de dados\n'
                  '• Não vendemos seus dados pessoais\n'
                  '• Dados podem ser compartilhados apenas com consentimento\n'
                  '• Cumprimos todas as leis de proteção de dados\n\n'
                  'Para mais informações, entre em contato conosco.',
                  style: textTheme.bodyMedium,
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Entendi'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showTermosServico(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        height: MediaQuery.of(context).size.height * 0.8,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Termos de Serviço', style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  'Termos de Serviço do SIGAD\n\n'
                  'Última atualização: 15/12/2025\n\n'
                  'Ao usar o SIGAD, você concorda com estes termos...\n\n'
                  '1. Aceitação dos Termos\n'
                  '• Ao acessar e usar o SIGAD, você aceita estes termos\n'
                  '• Se não concordar, não use a aplicação\n\n'
                  '2. Uso da Aplicação\n'
                  '• Uso destinado apenas para fins acadêmicos\n'
                  '• Proibido uso comercial sem autorização\n'
                  '• Responsabilidade pelo conteúdo inserido\n\n'
                  '3. Privacidade e Segurança\n'
                  '• Comprometemo-nos com a proteção dos dados\n'
                  '• Uso de criptografia para dados sensíveis\n'
                  '• Conformidade com LGPD\n\n'
                  '4. Limitação de Responsabilidade\n'
                  '• Serviço fornecido "como está"\n'
                  '• Não garantimos disponibilidade 100%\n'
                  '• Usuário responsável por backup de dados\n\n'
                  'Para dúvidas, contate o suporte.',
                  style: textTheme.bodyMedium,
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Aceito'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSobre(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Sobre o SIGAD', style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Center(
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: SigadColors.brand,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Center(
                  child: Text(
                    'SIGAD',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            _DetailSection(label: 'Versão', value: '1.0.0 (Build 42)'),
            _DetailSection(label: 'Desenvolvido por', value: 'Equipe de Desenvolvimento SIGAD'),
            _DetailSection(label: 'Data de lançamento', value: '15/03/2026'),
            _DetailSection(label: 'Compatibilidade', value: 'Android 8.0+, iOS 12.0+'),
            const SizedBox(height: 24),
            Text(
              'O SIGAD é um sistema integrado de gestão acadêmica desenvolvido para otimizar processos administrativos e acadêmicos.',
              style: textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Fechar'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showReportarProblema(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final tituloController = TextEditingController();
    final descricaoController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        height: MediaQuery.of(context).size.height * 0.8,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Reportar Problema', style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 24),
            TextField(
              controller: tituloController,
              decoration: const InputDecoration(
                labelText: 'Título do Problema',
                hintText: 'Descreva brevemente o problema',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descricaoController,
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: 'Descrição Detalhada',
                hintText: 'Descreva o problema em detalhes, incluindo passos para reproduzir',
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Inclua capturas de tela se possível para ajudar no diagnóstico.',
              style: textTheme.bodySmall?.copyWith(color: SigadColors.muted),
            ),
            const Spacer(),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancelar'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                        final erro = ConfiguracoesService.validarRelatoProblema(
                          titulo: tituloController.text,
                          descricao: descricaoController.text,
                        );
                        if (erro != null) {
                          _mostrarFeedback(erro);
                        return;
                        }

                      setState(() {
                        _problemasReportados += 1;
                      });
                      _saveData();

                      Navigator.pop(context);
                      _mostrarFeedback('Relatório enviado com sucesso!');
                    },
                    child: const Text('Enviar'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showConfirmacaoLogout(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sair'),
        content: Text(
          'Tem certeza que deseja sair da aplicação?',
          style: textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.login, (route) => false);
            },
            child: Text(
              'Sair',
              style: TextStyle(color: SigadColors.risk),
            ),
          ),
        ],
      ),
    );
  }
}

class _ConfiguracoesAccessDenied extends StatelessWidget {
  const _ConfiguracoesAccessDenied();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.lock_outline, size: 56),
            const SizedBox(height: 12),
            Text(
              'Faça login para acessar configurações.',
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _ConfigSection extends StatelessWidget {
  const _ConfigSection({
    required this.titulo,
    required this.children,
  });

  final String titulo;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Text(
            titulo,
            style: textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: SigadColors.muted,
            ),
          ),
        ),
        ...children.asMap().entries.map(
              (entry) => Column(
                children: [
                  entry.value,
                  if (entry.key < children.length - 1)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Divider(color: SigadColors.divider),
                    ),
                ],
              ),
            ),
        const SizedBox(height: 8),
      ],
    );
  }
}

class _ConfigItem extends StatelessWidget {
  const _ConfigItem({
    required this.icon,
    required this.titulo,
    required this.subtitulo,
    required this.onTap,
  });

  final IconData icon;
  final String titulo;
  final String subtitulo;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: Icon(icon, color: SigadColors.brand),
      title: Text(
        titulo,
        style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        subtitulo,
        style: textTheme.bodySmall?.copyWith(color: SigadColors.muted),
      ),
      trailing: Icon(Icons.chevron_right, color: SigadColors.muted),
      onTap: onTap,
    );
  }
}

class _ConfigToggle extends StatelessWidget {
  const _ConfigToggle({
    required this.icon,
    required this.titulo,
    required this.subtitulo,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String titulo;
  final String subtitulo;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: Icon(icon, color: SigadColors.brand),
      title: Text(
        titulo,
        style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        subtitulo,
        style: textTheme.bodySmall?.copyWith(color: SigadColors.muted),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeThumbColor: SigadColors.brand,
      ),
    );
  }
}

class _DetailSection extends StatelessWidget {
  const _DetailSection({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: textTheme.labelSmall?.copyWith(
              color: SigadColors.muted,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(value, style: textTheme.bodyMedium),
        ],
      ),
    );
  }
}

class _ConfigDropdown extends StatelessWidget {
  const _ConfigDropdown({
    required this.icon,
    required this.titulo,
    required this.valor,
    required this.opcoes,
    required this.onChanged,
  });

  final IconData icon;
  final String titulo;
  final String valor;
  final List<String> opcoes;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: SigadColors.brand),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: SigadColors.divider),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButton<String>(
                    value: valor,
                    isExpanded: true,
                    underline: const SizedBox(),
                    items: opcoes
                        .map((opcao) => DropdownMenuItem(
                              value: opcao,
                              child: Text(opcao, style: textTheme.bodySmall),
                            ))
                        .toList(),
                    onChanged: (newValue) {
                      if (newValue != null) {
                        onChanged(newValue);
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
