import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../app/routes/app_routes.dart';
import '../../../../app/theme/sigad_colors.dart';
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

                      return _LoginSurface(
                        child: wide
                            ? Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Expanded(
                                    flex: 5,
                                    child: _InstitutionPanel(),
                                  ),
                                  const SizedBox(width: 24),
                                  Expanded(flex: 6, child: _buildForm()),
                                ],
                              )
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  const _CompactBrandHeader(),
                                  const SizedBox(height: 14),
                                  _buildForm(compact: true),
                                ],
                              ),
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
    final colors = theme.colorScheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Entrar no SIGAD',
          style: compact
              ? theme.textTheme.titleLarge
              : theme.textTheme.headlineSmall,
        ),
        const SizedBox(height: 4),
        Text(
          'Use suas credenciais do IFMA para acessar o Campus São Luís–Monte Castelo.',
          style: theme.textTheme.bodySmall?.copyWith(
            color: colors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 14),
        Text('Perfil de acesso', style: theme.textTheme.labelLarge),
        const SizedBox(height: 8),
        LayoutBuilder(
          builder: (context, constraints) {
            final itemWidth = (constraints.maxWidth - 8) / 2;
            return Wrap(
              spacing: 8,
              runSpacing: 8,
              children: UserRole.values
                  .map(
                    (role) => SizedBox(
                      width: itemWidth,
                      child: ChoiceChip(
                        avatar: Icon(_roleIcon(role), size: 16),
                        label: Text(
                          role.displayName,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        selected: _selectedRole == role,
                        onSelected: (_) => setState(() => _selectedRole = role),
                        visualDensity: VisualDensity.compact,
                      ),
                    ),
                  )
                  .toList(growable: false),
            );
          },
        ),
        const SizedBox(height: 14),
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
                  hintText: 'nome@ifma.edu.br',
                  prefixIcon: Icon(Icons.alternate_email_rounded),
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
                  prefixIcon: const Icon(Icons.lock_outline_rounded),
                  suffixIcon: IconButton(
                    tooltip: _obscurePassword
                        ? 'Mostrar senha'
                        : 'Ocultar senha',
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
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
                : const Icon(Icons.login_rounded),
            label: const Text('Entrar'),
          ),
        ),
        if (kDebugMode) ...[
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _isLoading ? null : _handleDemoLogin,
              icon: const Icon(Icons.science_outlined),
              label: const Text('Acesso demo do perfil selecionado'),
            ),
          ),
        ],
        const SizedBox(height: 10),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.verified_user_outlined,
              size: 17,
              color: colors.onSurfaceVariant,
            ),
            const SizedBox(width: 7),
            Expanded(
              child: Text(
                kDebugMode
                    ? 'Modo de desenvolvimento ativo. O perfil definitivo será validado pelo serviço institucional.'
                    : 'A autenticação e o perfil serão validados pelo serviço institucional.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  IconData _roleIcon(UserRole role) {
    switch (role) {
      case UserRole.professor:
        return Icons.school_outlined;
      case UserRole.coordenador:
        return Icons.manage_accounts_outlined;
      case UserRole.servidorAdministrativo:
        return Icons.badge_outlined;
      case UserRole.chefeDepartamento:
        return Icons.account_balance_outlined;
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

    final normalizedEmail = email.toLowerCase();
    AppEventLogger.action(
      'login_attempt',
      details: {
        'emailDomain': normalizedEmail.split('@').last,
        'role': _selectedRole.name,
      },
    );

    setState(() => _isLoading = true);
    try {
      await Future<void>.delayed(const Duration(milliseconds: 500));
      final user = User(
        id: 'user_email_$normalizedEmail',
        name: email.split('@').first,
        email: normalizedEmail,
        role: _selectedRole,
        createdAt: DateTime.now(),
        lastLogin: DateTime.now(),
      );

      if (!mounted) return;
      await context.read<UserContextProvider>().login(
        user,
        sessionToken: 'session_$normalizedEmail',
      );
      if (!mounted) return;
      await Navigator.of(context).pushReplacementNamed(AppRoutes.dashboard);
    } catch (error, stackTrace) {
      AppEventLogger.error('login_error', error, stackTrace: stackTrace);
      if (mounted) _showError('Não foi possível entrar. Tente novamente.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleDemoLogin() async {
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
      await context.read<UserContextProvider>().login(
        user,
        sessionToken: 'session_demo_${role.name}',
      );
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
        return 'professor.demo@ifma.edu.br';
      case UserRole.coordenador:
        return 'coordenacao.demo@ifma.edu.br';
      case UserRole.servidorAdministrativo:
        return 'servidor.demo@ifma.edu.br';
      case UserRole.chefeDepartamento:
        return 'chefia.demo@ifma.edu.br';
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
  const _CompactBrandHeader();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: SigadColors.brandLight,
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Icon(
            Icons.account_balance_outlined,
            color: SigadColors.brandDark,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const BrandTitle(compact: true),
              Text(
                'IFMA — Campus São Luís–Monte Castelo',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: colors.onSurfaceVariant),
              ),
            ],
          ),
        ),
      ],
    );
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
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [SigadColors.brandDeep, SigadColors.brand],
        ),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const BrandTitle(compact: true, light: true),
          const SizedBox(height: 24),
          Text(
            'IFMA — Campus São Luís–Monte Castelo do IFMA — Campus São Luís–Monte Castelo.',
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
            icon: Icons.schedule_rounded,
            label: 'Planejamento integrado',
          ),
          const _FeatureLine(
            icon: Icons.science_outlined,
            label: 'Gestão de laboratórios',
          ),
          const _FeatureLine(
            icon: Icons.analytics_outlined,
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
          Icon(icon, color: SigadColors.accent, size: 20),
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
    return Material(
      color: Theme.of(context).colorScheme.surface,
      elevation: 0,
      shadowColor: Colors.black.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(30),
      child: Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.07),
              blurRadius: 28,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: child,
      ),
    );
  }
}

class _LoginBackground extends StatelessWidget {
  const _LoginBackground();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFFDFC), SigadColors.canvas],
        ),
      ),
      child: const SizedBox.expand(),
    );
  }
}
