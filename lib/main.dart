import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app/app.dart';
import 'core/config/app_runtime_config.dart';
import 'core/services/app_event_logger.dart';
import 'core/services/app_observability_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

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

  runApp(const SigadApp());
}
