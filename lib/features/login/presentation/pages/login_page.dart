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
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  UserRole? _selectedRole = UserRole.professor;
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
  }

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
                  constraints: const BoxConstraints(maxWidth: 860),
                  child: _LoginPanel(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final isWide = constraints.maxWidth >= 760;
                        if (isWide) {
                          return Row(
                            children: [
                              Expanded(child: _buildIntro()),
                              Container(
                                width: 1,
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                ),
                                color: Theme.of(context).dividerColor,
                              ),
                              Expanded(child: _buildForm(context)),
                            ],
                          );
                        }
                        return Column(
                          children: [
                            _buildIntro(),
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 18),
                              child: Divider(height: 1),
                            ),
                            _buildForm(context),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIntro() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const BrandTitle(),
        const SizedBox(height: 18),
        Text(
          'Acesso por perfil',
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 14),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: UserRole.values
              .map(
                (role) => _RolePill(
                  role: role,
                  selected: _selectedRole == role,
                  onTap: () => setState(() => _selectedRole = role),
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  Widget _buildForm(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Entrar no SIGAD',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 16),
        AutofillGroup(
          child: Column(
            children: [
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                enableSuggestions: false,
                autofillHints: const [
                  AutofillHints.username,
                  AutofillHints.email,
                ],
                autocorrect: false,
                decoration: const InputDecoration(
                  labelText: 'Email institucional',
                  hintText: 'nome@instituicao.edu.br',
                  prefixIcon: Icon(Icons.email_outlined),
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
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                    tooltip: _obscurePassword
                        ? 'Mostrar senha'
                        : 'Ocultar senha',
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
        const SizedBox(height: 18),
        SizedBox(
          width: double.infinity,
          height: 46,
          child: FilledButton(
            onPressed: _isLoading ? null : _handleLogin,
            child: _isLoading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Entrar'),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          height: 46,
          child: OutlinedButton.icon(
            onPressed: _isLoading ? null : _handleDemoLogin,
            icon: const Icon(Icons.bolt_outlined),
            label: const Text('Acesso demo do perfil selecionado'),
          ),
        ),
      ],
    );
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

    final emailDomain = email.contains('@') ? email.split('@').last : 'invalid';
    AppEventLogger.action(
      'login_attempt',
      details: {'emailDomain': emailDomain, 'role': _selectedRole!.name},
    );

    setState(() => _isLoading = true);

    try {
      await Future.delayed(const Duration(milliseconds: 900));

      final normalizedEmail = email.toLowerCase();

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
      AppEventLogger.action(
        'login_success',
        details: {'userRef': _userRef(user.id), 'role': user.role.name},
      );
      if (!mounted) return;
      await Navigator.of(context).pushReplacementNamed(AppRoutes.dashboard);
    } catch (error, stackTrace) {
      AppEventLogger.error('login_error', error, stackTrace: stackTrace);
      if (!mounted) return;
      _showError('Não foi possível entrar. Tente novamente.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleDemoLogin() async {
    if (_selectedRole == null) {
      _showWarning('Selecione um perfil para usar demo.');
      return;
    }

    AppEventLogger.action(
      'demo_login_attempt',
      details: {'role': _selectedRole!.name},
    );

    setState(() => _isLoading = true);
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      final role = _selectedRole!;

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
      AppEventLogger.action(
        'demo_login_success',
        details: {'userRef': _userRef(user.id), 'role': user.role.name},
      );
      if (!mounted) return;
      await Navigator.of(context).pushReplacementNamed(AppRoutes.dashboard);
    } catch (error, stackTrace) {
      AppEventLogger.error('demo_login_error', error, stackTrace: stackTrace);
      if (!mounted) return;
      _showError('Não foi possível entrar com acesso demo.');
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
        return 'joao.silva@univ.br';
      case UserRole.coordenador:
        return 'maria.santos@univ.br';
      case UserRole.servidorAdministrativo:
        return 'carlos.oliveira@univ.br';
      case UserRole.chefeDepartamento:
        return 'ana.pereira@univ.br';
    }
  }

  void _showWarning(String message) {
    AppFeedbackService.warning(context, message);
  }

  void _showError(String message) {
    AppFeedbackService.error(context, message);
  }

  String _userRef(String userId) {
    final normalized = userId.trim();
    if (normalized.isEmpty) return 'unknown';
    if (normalized.length <= 6) return normalized;
    return '${normalized.substring(0, 2)}***${normalized.substring(normalized.length - 2)}';
  }
}

class _RolePill extends StatelessWidget {
  const _RolePill({
    required this.role,
    required this.selected,
    required this.onTap,
  });

  final UserRole role;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final dividerColor = Theme.of(context).dividerColor;

    return Semantics(
      button: true,
      selected: selected,
      label: 'Perfil ${role.displayName}',
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
          decoration: BoxDecoration(
            color: selected
                ? colorScheme.primary.withValues(alpha: 0.14)
                : colorScheme.surface,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: selected ? colorScheme.primary : dividerColor,
            ),
          ),
          child: Text(
            role.displayName,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
              color: selected ? colorScheme.primary : colorScheme.onSurface,
            ),
          ),
        ),
      ),
    );
  }
}

class _LoginPanel extends StatelessWidget {
  const _LoginPanel({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final dividerColor = Theme.of(context).dividerColor;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface.withValues(alpha: isDark ? 0.92 : 0.90),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: dividerColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.26 : 0.08),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: child,
    );
  }
}

class _LoginBackground extends StatelessWidget {
  const _LoginBackground();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  colorScheme.surface,
                  colorScheme.surface.withValues(alpha: 0.88),
                ]
              : [SigadColors.canvas, SigadColors.surfaceAlt],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -80,
            right: -80,
            child: _blob(
              isDark
                  ? colorScheme.secondary.withValues(alpha: 0.35)
                  : SigadColors.accentSoft,
              220,
            ),
          ),
          Positioned(
            left: -50,
            bottom: -50,
            child: _blob(
              isDark
                  ? colorScheme.primary.withValues(alpha: 0.32)
                  : SigadColors.mint,
              190,
            ),
          ),
        ],
      ),
    );
  }

  Widget _blob(Color color, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.45),
        shape: BoxShape.circle,
      ),
    );
  }
}
