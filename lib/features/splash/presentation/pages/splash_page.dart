import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../../../../app/routes/app_routes.dart';
import '../../../../core/services/user_context_provider.dart';

const _splashBackgroundColor = Color(0xFF08453C);
const _splashForegroundColor = Colors.white;

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _iconScaleAnimation;
  Timer? _navigationTimer;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 900),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.22, 1.0, curve: Curves.easeOut),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.22, 1.0, curve: Curves.easeOutCubic),
      ),
    );

    _iconScaleAnimation = Tween<double>(begin: 0.88, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.15, 0.8, curve: Curves.easeOutBack),
      ),
    );

    _animationController.forward();

    _navigationTimer = Timer(const Duration(milliseconds: 2500), () async {
      if (!mounted) return;
      final userContext = context.read<UserContextProvider>();
      await userContext.restoreSession();
      if (!mounted) return;
      final nextRoute = userContext.isAuthenticated ? AppRoutes.dashboard : AppRoutes.login;
      Navigator.of(context).pushReplacementNamed(nextRoute);
    });
  }

  @override
  void dispose() {
    _navigationTimer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final titleStyle = Theme.of(context).textTheme.headlineSmall?.copyWith(
          color: _splashForegroundColor.withValues(alpha: 0.9),
          fontWeight: FontWeight.bold,
          letterSpacing: 0.6,
        );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarBrightness: Brightness.dark,
        statusBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: _splashBackgroundColor,
        body: Stack(
          children: [
            Positioned.fill(
              child: ColoredBox(color: _splashBackgroundColor),
            ),
            Center(
              child: Text('SIGAD', style: titleStyle),
            ),
            Center(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: ScaleTransition(
                  scale: _iconScaleAnimation,
                  child: Transform.translate(
                    offset: const Offset(0, -106),
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _splashForegroundColor.withValues(alpha: 0.1),
                        border: Border.all(
                          color: _splashForegroundColor.withValues(alpha: 0.3),
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.school_rounded,
                          size: 52,
                          color: _splashForegroundColor.withValues(alpha: 0.9),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Center(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Transform.translate(
                    offset: const Offset(0, 62),
                    child: SizedBox(
                      width: 46,
                      height: 46,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          _splashForegroundColor.withValues(alpha: 0.72),
                        ),
                        strokeWidth: 2,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Center(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Transform.translate(
                  offset: const Offset(0, 112),
                  child: Text(
                    'Carregando...',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: _splashForegroundColor.withValues(alpha: 0.8),
                        ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
