import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../l10n/l10n.dart';
import '../../../../app/routes/app_routes.dart';
import '../../../../app/theme/sigad_colors.dart';
import '../../../../app/theme/sigad_icon.dart';
import '../../../../app/theme/sigad_icons.dart';
import '../../../../core/config/app_runtime_config.dart';
import '../../../../core/models/user.dart';
import '../../../../core/models/user_role.dart';
import '../../../../core/security/oidc_sign_in_service.dart';
import '../../../../core/services/app_event_logger.dart';
import '../../../../core/services/app_feedback_service.dart';
import '../../../../core/services/user_context_provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({
    super.key,
    this.institutionalSignInService,
    this.dataSourceMode,
  });

  /// Permite testar o fluxo remoto sem abrir um navegador externo.
  final InstitutionalSignInService? institutionalSignInService;
  final DataSourceMode? dataSourceMode;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  UserRole _selectedRole = UserRole.professor;
  bool _isLoading = false;
  bool _obscurePassword = true;
  late final InstitutionalSignInService _institutionalSignInService;

  bool get _isRemote =>
      (widget.dataSourceMode ?? AppRuntimeConfig.dataSourceMode) ==
      DataSourceMode.remote;

  @override
  void initState() {
    super.initState();
    _institutionalSignInService =
        widget.institutionalSignInService ??
        AppAuthInstitutionalSignInService();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return Scaffold(
      body: Stack(
        children: [
          const _LoginBackground(),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 920),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final wide =
                          constraints.maxWidth >= 760 && size.height >= 720;

                      return wide
                          ? Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const Expanded(
                                  flex: 5,
                                  child: _LoginHero(wide: true),
                                ),
                                const SizedBox(width: 40),
                                Expanded(
                                  flex: 6,
                                  child: _LoginSurface(child: _buildForm()),
                                ),
                              ],
                            )
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                const SizedBox(height: 12),
                                const _LoginHero(wide: false),
                                const SizedBox(height: 24),
                                _LoginSurface(child: _buildForm(compact: true)),
                              ],
                            );
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForm({bool compact = false}) {
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.entrar,
          style: compact
              ? theme.textTheme.titleLarge
              : theme.textTheme.headlineSmall,
        ),
        const SizedBox(height: 14),
        if (AppRuntimeConfig.allowLocalDemo) ...[
          Text(
            context.l10n.perfilDemonstracao,
            style: theme.textTheme.labelLarge,
          ),
          const SizedBox(height: 8),
          LayoutBuilder(
            builder: (context, constraints) {
              final itemWidth = ((constraints.maxWidth - 8) / 2).clamp(
                0.0,
                double.infinity,
              );
              return Wrap(
                spacing: 8,
                runSpacing: 8,
                children: UserRole.values
                    .map(
                      (role) => SizedBox(
                        width: itemWidth,
                        child: ChoiceChip(
                          avatar: SigadIcon(_roleIcon(role), size: 16),
                          label: Text(
                            role.nomeEm(context.l10n),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          selected: _selectedRole == role,
                          onSelected: (_) =>
                              setState(() => _selectedRole = role),
                          visualDensity: VisualDensity.compact,
                        ),
                      ),
                    )
                    .toList(growable: false),
              );
            },
          ),
          const SizedBox(height: 14),
        ],
        if (_isRemote) ...[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text(
              _institutionalSignInService.isReady
                  ? (Localizations.localeOf(context).languageCode == 'en'
                        ? 'Sign in securely through the institutional identity provider. '
                              'SIGAD never collects your institutional password.'
                        : 'Entre com segurança pelo provedor de identidade institucional. '
                              'O SIGAD não coleta sua senha institucional.')
                  : (Localizations.localeOf(context).languageCode == 'en'
                        ? 'Institutional access is not configured on this device. '
                              'The IT department must register the OIDC client, '
                              'callback and API before this option is enabled.'
                        : 'O acesso institucional ainda não está configurado neste dispositivo. '
                              'A TI precisa cadastrar o cliente OIDC, '
                              'o retorno do login e a API para habilitá-lo.'),
            ),
          ),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _isLoading || !_institutionalSignInService.isReady
                  ? null
                  : _handleInstitutionalLogin,
              icon: _isLoading
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const SigadIcon(SigadIcons.entrar),
              label: Text(
                Localizations.localeOf(context).languageCode == 'en'
                    ? 'Institutional sign-in'
                    : 'Entrar com conta institucional',
              ),
            ),
          ),
        ] else ...[
          AutofillGroup(
            child: Column(
              children: [
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [
                    AutofillHints.username,
                    AutofillHints.email,
                  ],
                  autocorrect: false,
                  decoration: InputDecoration(
                    labelText: context.l10n.emailInstitucional,
                    hintText: 'nome@exemplo.edu.br',
                    prefixIcon: const SigadIcon(SigadIcons.arroba),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  textInputAction: TextInputAction.done,
                  autofillHints: const [AutofillHints.password],
                  onSubmitted: (_) {
                    if (!_isLoading) _handleLogin();
                  },
                  decoration: InputDecoration(
                    labelText: context.l10n.senha,
                    prefixIcon: const SigadIcon(SigadIcons.cadeado),
                    suffixIcon: IconButton(
                      tooltip: _obscurePassword
                          ? context.l10n.mostrarSenha
                          : context.l10n.ocultarSenha,
                      onPressed: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                      icon: SigadIcon(
                        _obscurePassword
                            ? SigadIcons.visivel
                            : SigadIcons.oculto,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () => AppFeedbackService.info(
                context,
                context.l10n.recuperacaoSenhaAviso,
              ),
              child: Text(context.l10n.esqueciSenha),
            ),
          ),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _isLoading ? null : _handleLogin,
              icon: _isLoading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const SigadIcon(SigadIcons.entrar),
              label: Text(context.l10n.entrar),
            ),
          ),
        ],
        if (AppRuntimeConfig.allowLocalDemo) ...[
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _isLoading ? null : _handleDemoLogin,
              icon: const SigadIcon(SigadIcons.laboratorio),
              label: Text(context.l10n.acessoDemo),
            ),
          ),
        ],
      ],
    );
  }

  IconData _roleIcon(UserRole role) {
    switch (role) {
      case UserRole.professor:
        return SigadIcons.professor;
      case UserRole.coordenador:
        return SigadIcons.contaGerenciar;
      case UserRole.servidorAdministrativo:
        return SigadIcons.cracha;
      case UserRole.chefeDepartamento:
        return SigadIcons.escudo;
    }
  }

  Future<void> _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showWarning(context.l10n.preenchaEmailSenha);
      return;
    }

    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!emailRegex.hasMatch(email)) {
      _showWarning(context.l10n.emailInvalido);
      return;
    }

    if (password.length < 4) {
      _showWarning(context.l10n.senhaCurta);
      return;
    }

    _showError(context.l10n.autenticacaoIndisponivel);
  }

  Future<void> _handleInstitutionalLogin() async {
    if (_isLoading || !_isRemote || !_institutionalSignInService.isReady) {
      return;
    }
    setState(() => _isLoading = true);
    try {
      final accessToken = await _institutionalSignInService.signIn();
      if (!mounted) return;
      // Apenas /auth/me no backend concede sessão e perfil.
      await context.read<UserContextProvider>().loginInstitutional(accessToken);
      if (!mounted) return;
      await Navigator.of(context).pushReplacementNamed(AppRoutes.dashboard);
    } on InstitutionalSignInCancelled {
      // Cancelar o navegador não é uma falha de segurança.
    } catch (_) {
      if (mounted) {
        _showError(
          Localizations.localeOf(context).languageCode == 'en'
              ? 'Institutional sign-in could not be completed. Check your access or contact IT.'
              : 'Não foi possível concluir o acesso institucional. '
                    'Verifique sua autorização ou contate a TI.',
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleDemoLogin() async {
    if (!AppRuntimeConfig.allowLocalDemo) return;
    setState(() => _isLoading = true);
    try {
      await Future<void>.delayed(const Duration(milliseconds: 300));
      final role = _selectedRole;
      final user = User(
        id: 'demo_${role.name}',
        name: _demoNameFor(role),
        email: _demoEmailFor(role),
        role: role,
        createdAt: DateTime.fromMillisecondsSinceEpoch(0),
        lastLogin: DateTime.now(),
      );

      if (!mounted) return;
      await context.read<UserContextProvider>().login(user);
      if (!mounted) return;
      await Navigator.of(context).pushReplacementNamed(AppRoutes.dashboard);
    } catch (error, stackTrace) {
      AppEventLogger.error('demo_login_error', error, stackTrace: stackTrace);
      if (mounted) _showError(context.l10n.erroAcessoDemo);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _demoNameFor(UserRole role) {
    switch (role) {
      case UserRole.professor:
        return 'Professor Demonstrativo';
      case UserRole.coordenador:
        return 'Coordenação Demonstrativa';
      case UserRole.servidorAdministrativo:
        return 'Servidor Demonstrativo';
      case UserRole.chefeDepartamento:
        return 'Chefia Demonstrativa';
    }
  }

  String _demoEmailFor(UserRole role) {
    switch (role) {
      case UserRole.professor:
        return 'professor.demo@exemplo.edu.br';
      case UserRole.coordenador:
        return 'coordenacao.demo@exemplo.edu.br';
      case UserRole.servidorAdministrativo:
        return 'servidor.demo@exemplo.edu.br';
      case UserRole.chefeDepartamento:
        return 'chefia.demo@exemplo.edu.br';
    }
  }

  void _showWarning(String message) {
    AppFeedbackService.warning(context, message);
  }

  void _showError(String message) {
    AppFeedbackService.error(context, message);
  }
}

/// Apresentação do SIGAD na tela de entrada: logotipo, nome e subtítulo.
///
/// Em telas largas mostra também uma descrição curta e os destaques do app.
class _LoginHero extends StatelessWidget {
  const _LoginHero({required this.wide});

  final bool wide;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final alinhamento = wide
        ? CrossAxisAlignment.start
        : CrossAxisAlignment.center;
    final alinhamentoTexto = wide ? TextAlign.start : TextAlign.center;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: alinhamento,
      children: [
        _Logomarca(tamanho: wide ? 84 : 64),
        SizedBox(height: wide ? 22 : 14),
        Text(
          'SIGAD',
          textAlign: alinhamentoTexto,
          style: (wide ? textTheme.displayMedium : textTheme.displaySmall)
              ?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                letterSpacing: 2,
                height: 1,
              ),
        ),
        const SizedBox(height: 10),
        Text(
          context.l10n.loginTitulo,
          textAlign: alinhamentoTexto,
          style: (wide ? textTheme.titleLarge : textTheme.titleMedium)
              ?.copyWith(
                color: Colors.white.withValues(alpha: 0.92),
                fontWeight: FontWeight.w600,
                height: 1.3,
              ),
        ),
        const SizedBox(height: 16),
        Container(
          width: 48,
          height: 5,
          decoration: BoxDecoration(
            color: SigadColors.accent,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        if (wide) ...[
          const SizedBox(height: 22),
          Text(
            context.l10n.loginSubtitulo,
            style: textTheme.bodyLarge?.copyWith(
              color: Colors.white.withValues(alpha: 0.82),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 22),
          _FeatureLine(
            icon: SigadIcons.relogio,
            label: context.l10n.loginDestaquePlanejamento,
          ),
          _FeatureLine(
            icon: SigadIcons.laboratorio,
            label: context.l10n.loginDestaqueLaboratorios,
          ),
          _FeatureLine(
            icon: SigadIcons.analise,
            label: context.l10n.loginDestaqueIndicadores,
          ),
        ],
      ],
    );
  }
}

/// Logomarca do SIGAD: as três barras do ícone do app, com a do meio em
/// destaque.
class _Logomarca extends StatelessWidget {
  const _Logomarca({required this.tamanho});

  final double tamanho;

  @override
  Widget build(BuildContext context) {
    final barra = tamanho * 0.5;
    final espessura = tamanho * 0.1;

    Widget linha(Color cor) => Container(
      width: barra,
      height: espessura,
      decoration: BoxDecoration(
        color: cor,
        borderRadius: BorderRadius.circular(espessura / 2),
      ),
    );

    return Semantics(
      label: context.l10n.logotipoSigad,
      image: true,
      child: Container(
        width: tamanho,
        height: tamanho,
        padding: EdgeInsets.all(tamanho * 0.08),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(tamanho * 0.28),
        ),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: SigadColors.brand,
            borderRadius: BorderRadius.circular(tamanho * 0.22),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.18),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              linha(const Color(0xFFE8E9EA)),
              SizedBox(height: espessura * 0.8),
              linha(SigadColors.accent),
              SizedBox(height: espessura * 0.8),
              linha(const Color(0xFFE8E9EA)),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeatureLine extends StatelessWidget {
  const _FeatureLine({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          SigadIcon(icon, color: Colors.white, size: 20),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              label,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LoginSurface extends StatelessWidget {
  const _LoginSurface({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLight = theme.brightness == Brightness.light;

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withValues(
          alpha: isLight ? 0.94 : 0.91,
        ),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: isLight
              ? Colors.white.withValues(alpha: 0.70)
              : theme.colorScheme.outlineVariant,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isLight ? 0.18 : 0.30),
            blurRadius: 36,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _LoginBackground extends StatelessWidget {
  const _LoginBackground();

  // Ícones decorativos espalhados pelo fundo: (ícone, x, y, tamanho), com
  // posições relativas à tela.
  static const _icones = <(IconData, double, double, double)>[
    (SigadIcons.laboratorio, 0.80, 0.08, 64),
    (SigadIcons.calendario, 0.10, 0.06, 44),
    (SigadIcons.conversa, 0.86, 0.46, 52),
    (SigadIcons.kanban, 0.06, 0.52, 46),
    (SigadIcons.relogio, 0.16, 0.86, 54),
    (SigadIcons.analise, 0.78, 0.84, 46),
  ];

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      key: const ValueKey('login-background'),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          stops: [0, 0.55, 1],
          colors: [Color(0xFF0A8B77), SigadColors.brand, SigadColors.brandDeep],
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final w = constraints.maxWidth;
          final h = constraints.maxHeight;
          return ExcludeSemantics(
            child: Stack(
              children: [
                Positioned(
                  right: -w * 0.18,
                  top: -w * 0.22,
                  child: _Circulo(diametro: w * 0.7),
                ),
                Positioned(
                  left: -w * 0.2,
                  bottom: -w * 0.25,
                  child: _Circulo(diametro: w * 0.6),
                ),
                for (final (icone, x, y, tamanho) in _icones)
                  Positioned(
                    left: x * w - tamanho / 2,
                    top: y * h - tamanho / 2,
                    child: Opacity(
                      opacity: 0.16,
                      child: SigadIcon(
                        icone,
                        color: Colors.white,
                        size: tamanho,
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _Circulo extends StatelessWidget {
  const _Circulo({required this.diametro});

  final double diametro;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: diametro,
      height: diametro,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: 0.05),
      ),
    );
  }
}
