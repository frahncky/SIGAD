import 'package:flutter/foundation.dart';

import 'app_health_service.dart';

/// Logging funcional leve para ações críticas da aplicação.
abstract final class AppEventLogger {
  static void action(String name, {Map<String, Object?> details = const {}}) {
    AppHealthService.registerAction(name);
    final payload = details.entries.map((e) => '${e.key}=${e.value}').join(', ');
    debugPrint('[SIGAD][ACTION] $name${payload.isEmpty ? '' : ' | $payload'}');
  }

  static void error(String name, Object error, {StackTrace? stackTrace}) {
    AppHealthService.registerError(name);
    debugPrint('[SIGAD][ERROR] $name | $error');
    if (stackTrace != null) {
      debugPrint(stackTrace.toString());
    }
  }
}
