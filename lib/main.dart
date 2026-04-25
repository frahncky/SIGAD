import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app/app.dart';
import 'app/routes/app_routes.dart';
import 'core/config/app_runtime_config.dart';
import 'core/services/app_event_logger.dart';
import 'core/services/app_observability_service.dart';
import 'core/services/theme_provider.dart';
import 'core/services/user_context_provider.dart';
import 'features/configuracoes/data/configuracoes_repository.dart';
import 'features/carga_docente/data/seed_docentes.dart';



Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kDebugMode) {
    // Carrega docentes de exemplo para testes (apenas em desenvolvimento)
    await seedDocentes();
  }
  AppObservabilityService.configure(
    enabled: AppRuntimeConfig.enableObservability,
    endpoint: AppRuntimeConfig.observabilityEndpoint,
  );

  FlutterError.onError = (details) {
    AppEventLogger.error('flutter_framework_error', details.exception, stackTrace: details.stack);
  };

  PlatformDispatcher.instance.onError = (error, stackTrace) {
    AppEventLogger.error('flutter_platform_error', error, stackTrace: stackTrace);
    return true;
  };

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarBrightness: Brightness.light,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  final userContext = UserContextProvider();
  await userContext.restoreSession();
  final initialRoute = userContext.isAuthenticated ? AppRoutes.dashboard : AppRoutes.login;

  final savedConfig = await ConfiguracoesRepository().load();
  final themeProvider = ThemeProvider(isDark: savedConfig?.modoDark ?? false);

  runApp(
    SigadApp(
      initialRoute: initialRoute,
      userContextProvider: userContext,
      themeProvider: themeProvider,
    ),
  );
}
