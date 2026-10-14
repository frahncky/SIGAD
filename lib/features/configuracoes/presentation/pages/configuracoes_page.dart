import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../app/routes/app_routes.dart';
import '../../../../app/theme/sigad_colors.dart';
import '../../../../app/theme/sigad_icon.dart';
import '../../../../app/theme/sigad_icons.dart';
import '../../../../core/security/authorization_policy.dart';
import '../../../../core/services/theme_provider.dart';
import '../../../../core/services/locale_provider.dart';
import '../../../../l10n/l10n.dart';
import '../../../../core/services/user_context_provider.dart';
import '../../../../core/services/greeting_name_provider.dart';
import '../greeting_name_dialog.dart';
import '../../../../shared/widgets/icon_avatar.dart';
import '../../data/configuracoes_repository.dart';
import '../../domain/configuracoes_models.dart';
import '../../domain/configuracoes_service.dart';

class ConfiguracoesPage extends StatefulWidget {
  const ConfiguracoesPage({super.key});

  @override
  State<ConfiguracoesPage> createState() => _ConfiguracoesPageState();
}

class _ConfiguracoesPageState extends State<ConfiguracoesPage> {
  bool _notificacoesAtivas =
      ConfiguracoesService.defaultData().notificacoesAtivas;
  bool _notificarAntesDaDisciplina =
      ConfiguracoesService.defaultData().notificarAntesDaDisciplina;
  int _antecedenciaNotificacaoMinutos =
      ConfiguracoesService.defaultData().antecedenciaNotificacaoMinutos;
  bool _modoDark = ConfiguracoesService.defaultData().modoDark;
  bool _biometriaAtiva = ConfiguracoesService.defaultData().biometriaAtiva;
  bool _backupAutomaticoAtivo =
      ConfiguracoesService.defaultData().backupAutomaticoAtivo;
  String _idioma = ConfiguracoesService.defaultData().idioma;
  String _tamanhoFonte = ConfiguracoesService.defaultData().tamanhoFonte;
  String _nomePerfil = ConfiguracoesService.defaultData().nomePerfil;
  String _cargoPerfil = ConfiguracoesService.defaultData().cargoPerfil;
  String _emailUsuario = ConfiguracoesService.defaultData().emailUsuario;
  String _ultimaAlteracaoSenha =
      ConfiguracoesService.defaultData().ultimaAlteracaoSenha;
  String _proximoBackup = ConfiguracoesService.defaultData().proximoBackup;
  String _ultimoBackup = ConfiguracoesService.defaultData().ultimoBackup;
  int _problemasReportados =
      ConfiguracoesService.defaultData().problemasReportados;
  List<CompromissoAgenda> _agendaCompromissos = List<CompromissoAgenda>.of(
    ConfiguracoesService.defaultData().agendaCompromissos,
    growable: true,
  );

  final ConfiguracoesRepository _configuracoesRepository =
      ConfiguracoesRepository();

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
      _agendaCompromissos = List<CompromissoAgenda>.of(
        data.agendaCompromissos,
        growable: true,
      );
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

  @override
  Widget build(BuildContext context) {
    final userContext = context.watch<UserContextProvider>();
    final role = userContext.userRole;
    if (!AuthorizationPolicy.canAccessConfiguracoes(role)) {
      return const _ConfiguracoesAccessDenied();
    }
    final usuario = userContext.currentUser;
    final tema = context.watch<ThemeProvider>();
    final greeting = context.watch<GreetingNameProvider>();

    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          _ConfigSection(
            titulo: context.l10n.minhaConta,
            icon: SigadIcons.pessoa,
            children: [
              ListTile(
                leading: const SigadIcon(SigadIcons.pessoa),
                title: Text(greetingNameLabel(context)),
                subtitle: Text(greeting.displayName),
                trailing: const Icon(Icons.edit_outlined),
                enabled: usuario != null && !greeting.loading,
                onTap: () async {
                  final saved = await showDialog<bool>(
                    context: context,
                    barrierDismissible: false,
                    builder: (_) => GreetingNameDialog(preference: greeting),
                  );
                  if (saved == true && context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(context.l10n.nomeSaudacaoSalvo)),
                    );
                  }
                },
              ),
              _ConfigInfo(
                icon: SigadIcons.pessoa,
                titulo: context.l10n.nome,
                valor: usuario?.name ?? '—',
              ),
              _ConfigInfo(
                icon: SigadIcons.email,
                titulo: context.l10n.email,
                valor: usuario?.email ?? '—',
                tone: SigadColors.info,
              ),
              _ConfigInfo(
                icon: SigadIcons.cracha,
                titulo: context.l10n.perfilAcesso,
                valor: role?.nomeEm(context.l10n) ?? '—',
                tone: SigadColors.success,
              ),
            ],
          ),
          _ConfigSection(
            titulo: context.l10n.aparenciaLeitura,
            icon: SigadIcons.paleta,
            tone: SigadColors.info,
            children: [
              _ConfigToggle(
                icon: SigadIcons.lua,
                titulo: context.l10n.modoNoturno,
                subtitulo: context.l10n.modoNoturnoSub,
                value: _modoDark,
                onChanged: (value) {
                  setState(() => _modoDark = value);
                  context.read<ThemeProvider>().setDark(value);
                  _saveData();
                },
                tone: SigadColors.info,
              ),
              _ConfigDropdown(
                icon: SigadIcons.texto,
                titulo: context.l10n.tamanhoTexto,
                valor: tema.tamanhoTexto,
                opcoes: ThemeProvider.tamanhosTexto.keys.toList(
                  growable: false,
                ),
                rotulo: (opcao) => switch (opcao) {
                  'Normal' => context.l10n.tamanhoNormal,
                  'Grande' => context.l10n.tamanhoGrande,
                  'Muito grande' => context.l10n.tamanhoMuitoGrande,
                  _ => context.l10n.tamanhoMedio,
                },
                onChanged: (valor) {
                  setState(() => _tamanhoFonte = valor);
                  context.read<ThemeProvider>().setTamanhoTexto(valor);
                  _saveData();
                },
                tone: SigadColors.warning,
              ),
              _ConfigDropdown(
                icon: SigadIcons.idioma,
                titulo: context.l10n.idioma,
                valor: context.watch<LocaleProvider>().idioma,
                opcoes: LocaleProvider.opcoes,
                rotulo: (opcao) => opcao == LocaleProvider.automatico
                    ? context.l10n.idiomaAutomatico
                    : opcao,
                onChanged: (valor) {
                  setState(() => _idioma = valor);
                  context.read<LocaleProvider>().setIdioma(valor);
                  _saveData();
                },
                tone: SigadColors.info,
              ),
            ],
          ),
          if (AuthorizationPolicy.canManageMural(role))
            _ConfigSection(
              titulo: context.l10n.departamento,
              icon: SigadIcons.predio,
              children: [
                _ConfigItem(
                  icon: SigadIcons.aviso,
                  titulo: context.l10n.navMural,
                  subtitulo: context.l10n.muralDepartamentoSub,
                  onTap: () =>
                      Navigator.pushReplacementNamed(context, AppRoutes.mural),
                ),
              ],
            ),
          _ConfigSection(
            titulo: context.l10n.sobre,
            icon: SigadIcons.info,
            children: [
              _ConfigItem(
                icon: SigadIcons.info,
                titulo: context.l10n.sobreSigad,
                subtitulo: context.l10n.versaoBuild('1.0.0 (Build 42)'),
                onTap: () => _showSobre(context),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            onPressed: () => _showConfirmacaoLogout(context),
            icon: const SigadIcon(SigadIcons.sair),
            label: Text(context.l10n.sairDaConta),
            style: ElevatedButton.styleFrom(
              backgroundColor: SigadColors.risk,
              foregroundColor: Colors.white,
              minimumSize: const Size.fromHeight(52),
            ),
          ),
        ],
      ),
    );
  }

  void _showSobre(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (sheetContext) {
        final screenWidth = MediaQuery.sizeOf(sheetContext).width;
        final horizontalPadding = screenWidth <= 360 ? 16.0 : 24.0;

        return FractionallySizedBox(
          heightFactor: 0.92,
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: SizedBox(
                width: double.infinity,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    horizontalPadding,
                    8,
                    horizontalPadding,
                    horizontalPadding,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              context.l10n.sobreSigad,
                              style: textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            tooltip: context.l10n.fecharSobre,
                            onPressed: () => Navigator.pop(sheetContext),
                            icon: const SigadIcon(SigadIcons.fechar),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 8),
                              Center(
                                child: Semantics(
                                  image: true,
                                  label: 'SIGAD',
                                  child: ExcludeSemantics(
                                    child: Container(
                                      width: 80,
                                      height: 80,
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: SigadColors.brand,
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: const FittedBox(
                                        fit: BoxFit.scaleDown,
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
                                ),
                              ),
                              const SizedBox(height: 24),
                              _DetailSection(
                                label: context.l10n.versao,
                                value: '1.0.0 (Build 42)',
                              ),
                              _DetailSection(
                                label: context.l10n.desenvolvidoPor,
                                value: context.l10n.equipeDesenvolvimento,
                              ),
                              _DetailSection(
                                label: context.l10n.dataLancamento,
                                value: '15/03/2026',
                              ),
                              _DetailSection(
                                label: context.l10n.compatibilidade,
                                value: 'Android 8.0+, iOS 12.0+',
                              ),
                              const SizedBox(height: 24),
                              Text(
                                context.l10n.sobreDescricao,
                                style: textTheme.bodyMedium,
                              ),
                              const SizedBox(height: 8),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(sheetContext),
                          child: Text(context.l10n.fechar),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showConfirmacaoLogout(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.sair),
        content: Text(context.l10n.sairPergunta, style: textTheme.bodyMedium),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(context.l10n.cancelar),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await context.read<UserContextProvider>().logout();
              if (!context.mounted) return;
              await Navigator.of(
                context,
              ).pushNamedAndRemoveUntil(AppRoutes.login, (route) => false);
            },
            child: Text(
              context.l10n.sair,
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
            const SigadIcon(SigadIcons.cadeado, size: 56),
            const SizedBox(height: 12),
            Text(
              context.l10n.facaLogin,
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
    required this.icon,
    this.tone = SigadColors.brand,
    required this.children,
  });

  final String titulo;
  final IconData icon;
  final Color tone;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Semantics(
            header: true,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(4, 0, 4, 8),
              child: Row(
                children: [
                  SigadIcon(icon, color: tone, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      titulo,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Material(
            color: theme.colorScheme.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
              side: BorderSide(color: theme.colorScheme.outlineVariant),
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                for (var i = 0; i < children.length; i++) ...[
                  children[i],
                  if (i < children.length - 1)
                    Divider(
                      height: 1,
                      indent: 16,
                      endIndent: 16,
                      color: theme.colorScheme.outlineVariant,
                    ),
                ],
              ],
            ),
          ),
        ],
      ),
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
  static const tone = SigadColors.brand;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: SigadIcon(icon, color: tone),
      title: Text(
        titulo,
        style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        subtitulo,
        style: textTheme.bodySmall?.copyWith(color: SigadColors.muted),
      ),
      trailing: SigadIcon(SigadIcons.chevronDireita, color: SigadColors.muted),
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
    this.tone = SigadColors.brand,
  });

  final IconData icon;
  final String titulo;
  final String subtitulo;
  final bool value;
  final ValueChanged<bool> onChanged;
  final Color tone;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: SigadIcon(icon, color: tone),
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
    this.tone = SigadColors.brand,
    this.rotulo,
  });

  final IconData icon;
  final String titulo;
  final String valor;
  final List<String> opcoes;
  final ValueChanged<String> onChanged;
  final Color tone;

  /// Texto exibido para cada opção (o valor salvo continua o mesmo).
  final String Function(String opcao)? rotulo;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          SigadIcon(icon, color: tone),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
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
                        .map(
                          (opcao) => DropdownMenuItem(
                            value: opcao,
                            child: Text(
                              rotulo?.call(opcao) ?? opcao,
                              style: textTheme.bodySmall,
                            ),
                          ),
                        )
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

/// Linha só de leitura (dados da conta).
class _ConfigInfo extends StatelessWidget {
  const _ConfigInfo({
    required this.icon,
    required this.titulo,
    required this.valor,
    this.tone = SigadColors.brand,
  });

  final IconData icon;
  final String titulo;
  final String valor;
  final Color tone;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Semantics(
      container: true,
      label: '$titulo: $valor',
      excludeSemantics: true,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            SigadIconAvatar(icon: icon, tone: tone),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titulo,
                    style: textTheme.bodySmall?.copyWith(
                      color: SigadColors.muted,
                    ),
                  ),
                  Text(valor, style: textTheme.bodyLarge),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
