import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../app/routes/app_routes.dart';
import '../../../../app/theme/sigad_colors.dart';
import '../../../../app/theme/sigad_icon.dart';
import '../../../../app/theme/sigad_icons.dart';
import '../../../../core/config/app_runtime_config.dart';
import '../../../../core/models/user.dart';
import '../../../../core/models/user_role.dart';
import '../../../../core/services/app_event_logger.dart';
import '../../../../core/services/app_feedback_service.dart';
import '../../../../core/services/user_context_provider.dart';
import '../../../../shared/widgets/brand_title.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  UserRole _selectedRole = UserRole.professor;
  bool _isLoading = false;
  bool _obscurePassword = true;

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
                          ? _LoginSurface(
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Expanded(
                                    flex: 5,
                                    child: _InstitutionPanel(),
                                  ),
                                  const SizedBox(width: 24),
                                  Expanded(flex: 6, child: _buildForm()),
                                ],
                              ),
                            )
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                const SizedBox(
                                  height: 150,
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 8,
                                    ),
                                    child: Align(
                                      alignment: Alignment.bottomLeft,
                                      child: _CompactBrandHeader(light: true),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
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
          'Entrar',
          style: compact
              ? theme.textTheme.titleLarge
              : theme.textTheme.headlineSmall,
        ),
        const SizedBox(height: 14),
        if (AppRuntimeConfig.allowLocalDemo) ...[
          Text('Perfil de demonstração', style: theme.textTheme.labelLarge),
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
                            role.displayName,
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
                decoration: const InputDecoration(
                  labelText: 'Email institucional',
                  hintText: 'nome@exemplo.edu.br',
                  prefixIcon: SigadIcon(SigadIcons.arroba),
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
                  labelText: 'Senha',
                  prefixIcon: const SigadIcon(SigadIcons.cadeado),
                  suffixIcon: IconButton(
                    tooltip: _obscurePassword
                        ? 'Mostrar senha'
                        : 'Ocultar senha',
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                    icon: SigadIcon(
                      _obscurePassword ? SigadIcons.visivel : SigadIcons.oculto,
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
              'A recuperação de senha será vinculada ao serviço institucional.',
            ),
            child: const Text('Esqueci minha senha'),
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
            label: const Text('Entrar'),
          ),
        ),
        if (AppRuntimeConfig.allowLocalDemo) ...[
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _isLoading ? null : _handleDemoLogin,
              icon: const SigadIcon(SigadIcons.laboratorio),
              label: const Text('Acesso demo do perfil selecionado'),
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
      _showWarning('Preencha email e senha.');
      return;
    }

    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!emailRegex.hasMatch(email)) {
      _showWarning('Informe um email válido.');
      return;
    }

    if (password.length < 4) {
      _showWarning('A senha deve ter pelo menos 4 caracteres.');
      return;
    }

    _showError(
      'Autenticação institucional indisponível. A integração com o serviço de acesso ainda não foi concluída.',
    );
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
      if (mounted) _showError('Não foi possível entrar com acesso demo.');
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

class _CompactBrandHeader extends StatelessWidget {
  const _CompactBrandHeader({this.light = false});

  final bool light;

  @override
  Widget build(BuildContext context) {
    return BrandTitle(compact: true, light: light);
  }
}

class _InstitutionPanel extends StatelessWidget {
  const _InstitutionPanel();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            SigadColors.brandDeep.withValues(alpha: 0.94),
            SigadColors.brand.withValues(alpha: 0.86),
          ],
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const BrandTitle(compact: true, light: true),
          const SizedBox(height: 24),
          Text(
            'Gestão acadêmica e departamental.',
            style: textTheme.headlineSmall?.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 10),
          Text(
            'Planeje as atividades do DEE: carga docente, laboratórios, reuniões e demandas.',
            style: textTheme.bodyMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.82),
            ),
          ),
          const SizedBox(height: 22),
          const _FeatureLine(
            icon: SigadIcons.relogio,
            label: 'Planejamento integrado',
          ),
          const _FeatureLine(
            icon: SigadIcons.laboratorio,
            label: 'Gestão de laboratórios',
          ),
          const _FeatureLine(
            icon: SigadIcons.analise,
            label: 'Indicadores e relatórios',
          ),
        ],
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

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final compact = width < 760;

    return ColoredBox(
      key: const ValueKey('login-background'),
      color: SigadColors.brandDeep,
      child: Stack(
        fit: StackFit.expand,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                stops: const [0, 0.56, 1],
                colors: [
                  SigadColors.brandDeep.withValues(
                    alpha: compact ? 0.48 : 0.64,
                  ),
                  SigadColors.brandDark.withValues(
                    alpha: compact ? 0.28 : 0.36,
                  ),
                  Colors.black.withValues(alpha: 0.46),
                ],
              ),
            ),
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.white.withValues(alpha: 0.04),
                  Colors.transparent,
                  SigadColors.brandDeep.withValues(alpha: 0.32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
