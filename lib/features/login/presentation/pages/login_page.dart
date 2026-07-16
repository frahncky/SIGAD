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
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  UserRole? _selectedRole = UserRole.professor;
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
    return Scaffold(
      body: Stack(
        children: [
          const _LoginBackground(),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 920),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final wide = constraints.maxWidth >= 760;
                      return _LoginPanel(
                        child: wide
                            ? Row(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  const Expanded(child: _InstitutionPanel()),
                                  const SizedBox(width: 32),
                                  Expanded(child: _buildForm()),
                                ],
                              )
                            : Column(
                                children: [
                                  const _InstitutionPanel(compact: true),
                                  const SizedBox(height: 24),
                                  _buildForm(),
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

  Widget _buildForm() {
    final textTheme = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('Entrar no SIGAD', style: textTheme.headlineSmall),
        const SizedBox(height: 6),
        Text(
          'Use suas credenciais institucionais para acessar o ambiente.',
          style: textTheme.bodyMedium?.copyWith(color: colors.onSurfaceVariant),
        ),
        const SizedBox(height: 22),
        Text('Perfil de acesso', style: textTheme.labelLarge),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: UserRole.values
              .map(
                (role) => ChoiceChip(
                  avatar: Icon(_roleIcon(role), size: 18),
                  label: Text(role.displayName),
                  selected: _selectedRole == role,
                  onSelected: (_) => setState(() => _selectedRole = role),
                ),
              )
              .toList(growable: false),
        ),
        const SizedBox(height: 20),
        AutofillGroup(
          child: Column(
            children: [
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.username, AutofillHints.email],
                autocorrect: false,
                decoration: const InputDecoration(
                  labelText: 'Email institucional',
                  hintText: 'nome@ifma.edu.br',
                  prefixIcon: Icon(Icons.alternate_email_rounded),
                ),
              ),
              const SizedBox(height: 12),
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
                    tooltip: _obscurePassword ? 'Mostrar senha' : 'Ocultar senha',
                    onPressed: () => setState(
                      () => _obscurePassword = !_obscurePassword,
                    ),
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
        const SizedBox(height: 10),
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
        const SizedBox(height: 6),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: _isLoading ? null : _handleLogin,
            icon: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.login_rounded),
            label: const Text('Entrar'),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _isLoading ? null : _handleDemoLogin,
            icon: const Icon(Icons.science_outlined),
            label: const Text('Acesso demo do perfil selecionado'),
          ),
        ),
        const SizedBox(height: 18),
        Row(
          children: [
            const Icon(Icons.verified_user_outlined, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Ambiente de demonstração. O perfil definitivo será validado pelo serviço institucional.',
                style: textTheme.bodySmall?.copyWith(
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

    if (_selectedRole == null) {
      _showWarning('Selecione um perfil.');
      return;
    }

    final normalizedEmail = email.toLowerCase();
    AppEventLogger.action(
      'login_attempt',
      details: {
        'emailDomain': normalizedEmail.split('@').last,
        'role': _selectedRole!.name,
      },
    );

    setState(() => _isLoading = true);
    try {
      await Future.delayed(const Duration(milliseconds: 700));
      final user = User(
        id: 'user_email_$normalizedEmail',
        name: email.split('@').first,
        email: email,
        role: _selectedRole!,
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
    final role = _selectedRole;
    if (role == null) {
      _showWarning('Selecione um perfil para usar demo.');
      return;
    }

    setState(() => _isLoading = true);
    try {
      await Future.delayed(const Duration(milliseconds: 400));
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
        return 'João Silva';
      case UserRole.coordenador:
        return 'Maria Santos';
      case UserRole.servidorAdministrativo:
        return 'Carlos Oliveira';
      case UserRole.chefeDepartamento:
        return 'Ana Pereira';
    }
  }

  String _demoEmailFor(UserRole role) {
    switch (role) {
      case UserRole.professor:
        return 'joao.silva@ifma.edu.br';
      case UserRole.coordenador:
        return 'maria.santos@ifma.edu.br';
      case UserRole.servidorAdministrativo:
        return 'carlos.oliveira@ifma.edu.br';
      case UserRole.chefeDepartamento:
        return 'ana.pereira@ifma.edu.br';
    }
  }

  void _showWarning(String message) => AppFeedbackService.warning(context, message);
  void _showError(String message) => AppFeedbackService.error(context, message);
}

class _InstitutionPanel extends StatelessWidget {
  const _InstitutionPanel({this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: EdgeInsets.all(compact ? 20 : 28),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [SigadColors.brandDeep, SigadColors.brand],
        ),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const BrandTitle(compact: true),
          SizedBox(height: compact ? 18 : 32),
          Text(
            'Gestão acadêmica e departamental em um único ambiente.',
            style: textTheme.headlineSmall?.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 12),
          Text(
            'Planeje carga docente, laboratórios, reuniões, demandas e atividades com mais clareza.',
            style: textTheme.bodyLarge?.copyWith(
              color: Colors.white.withValues(alpha: 0.82),
            ),
          ),
          if (!compact) ...[
            const SizedBox(height: 28),
            const _FeatureLine(Icons.schedule_rounded, 'Planejamento integrado'),
            const _FeatureLine(Icons.science_outlined, 'Gestão de laboratórios'),
            const _FeatureLine(Icons.analytics_outlined, 'Indicadores e relatórios'),
          ],
        ],
      ),
    );
  }
}

class _FeatureLine extends StatelessWidget {
  const _FeatureLine(this.icon, this.label);

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: SigadColors.accent, size: 21),
          const SizedBox(width: 10),
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}

class _LoginPanel extends StatelessWidget {
  const _LoginPanel({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 32,
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
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [SigadColors.canvas, SigadColors.surfaceAlt],
        ),
      ),
      child: Stack(
        children: const [
          Positioned(top: -90, right: -70, child: _Glow(SigadColors.accentSoft, 240)),
          Positioned(bottom: -80, left: -60, child: _Glow(SigadColors.mint, 210)),
        ],
      ),
    );
  }
}

class _Glow extends StatelessWidget {
  const _Glow(this.color, this.size);

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.55),
        shape: BoxShape.circle,
      ),
    );
  }
}
