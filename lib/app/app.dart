import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'routes/app_router.dart';
import 'routes/app_routes.dart';
import 'theme/app_theme.dart';
import '../core/config/app_runtime_config.dart';
import '../core/services/chat_provider.dart';
import '../core/services/user_context_provider.dart';

class SigadApp extends StatelessWidget {
  const SigadApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserContextProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
      ],
      child: MaterialApp(
        title: 'SIGAD',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        initialRoute: AppRoutes.splash,
        onGenerateRoute: AppRouter.onGenerateRoute,
        builder: (context, child) => _FlavorBanner(child: child ?? const SizedBox.shrink()),
      ),
    );
  }
}

class _FlavorBanner extends StatelessWidget {
  const _FlavorBanner({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final flavor = AppRuntimeConfig.flavor.toUpperCase();
    if (flavor == 'PROD') {
      return child;
    }

    return Banner(
      message: flavor,
      location: BannerLocation.topEnd,
      color: flavor == 'STAGING' ? Colors.orange : Colors.blueGrey,
      child: child,
    );
  }
}
