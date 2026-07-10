import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../core/config/app_runtime_config.dart';
import '../core/services/chat_provider.dart';
import '../core/services/theme_provider.dart';
import '../core/services/user_context_provider.dart';
import 'routes/app_router.dart';
import 'routes/app_routes.dart';
import 'theme/app_theme.dart';

/// Widget principal do aplicativo SIGAD.
/// Responsável por configurar provedores globais e o MaterialApp.
class SigadApp extends StatelessWidget {
  const SigadApp({
    super.key,
    this.initialRoute = AppRoutes.login,
    this.userContextProvider,
    this.themeProvider,
  });

  final String initialRoute;
  final UserContextProvider? userContextProvider;
  final ThemeProvider? themeProvider;

  @override
  Widget build(BuildContext context) {
    final userProvider = userContextProvider;
    final themeProviderValue = themeProvider;

    return MultiProvider(
      providers: [
        if (userProvider == null)
          ChangeNotifierProvider(create: (_) => UserContextProvider())
        else
          ChangeNotifierProvider<UserContextProvider>.value(
            value: userProvider,
          ),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
        if (themeProviderValue == null)
          ChangeNotifierProvider(create: (_) => ThemeProvider())
        else
          ChangeNotifierProvider<ThemeProvider>.value(
            value: themeProviderValue,
          ),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeCtrl, _) => MaterialApp(
          title: 'SIGAD',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          themeMode: themeCtrl.mode,
          initialRoute: initialRoute,
          onGenerateRoute: AppRouter.onGenerateRoute,
          builder: (context, child) {
            final isDark = Theme.of(context).brightness == Brightness.dark;
            final overlayStyle =
                (isDark
                        ? SystemUiOverlayStyle.light
                        : SystemUiOverlayStyle.dark)
                    .copyWith(statusBarColor: Colors.transparent);

            return AnnotatedRegion<SystemUiOverlayStyle>(
              value: overlayStyle,
              child: _FlavorBanner(child: child ?? const SizedBox.shrink()),
            );
          },
        ),
      ),
    );
  }
}

/// Banner de ambiente (flavor) exibido no topo da tela, exceto em PROD e DEV.
class _FlavorBanner extends StatelessWidget {
  const _FlavorBanner({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final flavor = AppRuntimeConfig.flavor.toUpperCase();
    if (flavor == 'PROD' || flavor == 'DEV') {
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
