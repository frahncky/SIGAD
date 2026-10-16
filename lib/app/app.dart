import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../core/config/app_runtime_config.dart';
import '../core/services/chat_provider.dart';
import '../core/services/locale_provider.dart';
import '../l10n/l10n.dart';
import '../core/services/theme_provider.dart';
import '../core/services/user_context_provider.dart';
import '../core/services/greeting_name_provider.dart';
import '../features/mural/presentation/state/mural_controller.dart';
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
    this.localeProvider,
  });

  final String initialRoute;
  final UserContextProvider? userContextProvider;
  final ThemeProvider? themeProvider;
  final LocaleProvider? localeProvider;

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
        ChangeNotifierProvider(
          create: (context) =>
              GreetingNameProvider(context.read<UserContextProvider>()),
        ),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
        ChangeNotifierProvider(create: (_) => MuralController()..carregar()),
        if (themeProviderValue == null)
          ChangeNotifierProvider(create: (_) => ThemeProvider())
        else
          ChangeNotifierProvider<ThemeProvider>.value(
            value: themeProviderValue,
          ),
        if (localeProvider == null)
          ChangeNotifierProvider(create: (_) => LocaleProvider())
        else
          ChangeNotifierProvider<LocaleProvider>.value(value: localeProvider!),
      ],
      child: Consumer2<ThemeProvider, LocaleProvider>(
        builder: (context, themeCtrl, localeCtrl, _) => MaterialApp(
          title: 'SIGAD',
          locale: localeCtrl.locale,
          supportedLocales: LocaleProvider.suportados,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          localeListResolutionCallback: (aparelho, _) =>
              LocaleProvider.resolver(
                aparelho == null || aparelho.isEmpty ? null : aparelho.first,
              ),
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
              child: MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  textScaler: AmpliacaoDeTexto(
                    MediaQuery.textScalerOf(context),
                    fator: themeCtrl.fatorTexto,
                  ),
                ),
                child: _FlavorBanner(child: child ?? const SizedBox.shrink()),
              ),
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

/// Amplia todos os textos do app sobre a escala escolhida no sistema,
/// conforme o "Tamanho do texto" das Configurações, sem ignorar a
/// preferência do aparelho.
class AmpliacaoDeTexto extends TextScaler {
  const AmpliacaoDeTexto(this.base, {this.fator = 1.1});

  final double fator;

  final TextScaler base;

  @override
  double scale(double fontSize) => base.scale(fontSize) * fator;

  @override
  // ignore: deprecated_member_use
  double get textScaleFactor => base.textScaleFactor * fator;

  @override
  bool operator ==(Object other) =>
      other is AmpliacaoDeTexto && other.base == base && other.fator == fator;

  @override
  int get hashCode => Object.hash(base, fator);
}
