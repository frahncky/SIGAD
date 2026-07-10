import 'package:flutter/foundation.dart';

import '../config/app_runtime_config.dart';
import 'app_health_service.dart';
import 'app_observability_service.dart';
import 'event_payload_sanitizer.dart';

/// Logging funcional leve para ações críticas da aplicação.
abstract final class AppEventLogger {
  static void action(String name, {Map<String, Object?> details = const {}}) {
    AppHealthService.registerAction(name);
    final sanitizedDetails = EventPayloadSanitizer.sanitizeDetails(details);

    AppObservabilityService.dispatchAction(
      eventName: name,
      flavor: AppRuntimeConfig.flavor,
      details: sanitizedDetails,
    );

    if (!kReleaseMode || AppRuntimeConfig.verboseLogs) {
      final payload = sanitizedDetails.entries
          .map((e) => '${e.key}=${e.value}')
          .join(', ');
      debugPrint(
        '[SIGAD][ACTION] $name${payload.isEmpty ? '' : ' | $payload'}',
      );
    }
  }

  static void error(String name, Object error, {StackTrace? stackTrace}) {
    AppHealthService.registerError(name);
    final sanitizedError = EventPayloadSanitizer.sanitizeDetails({
      'error': error.toString(),
    });

    AppObservabilityService.dispatchError(
      eventName: name,
      flavor: AppRuntimeConfig.flavor,
      error: error,
      stackTrace: stackTrace,
      details: sanitizedError,
    );

    if (!kReleaseMode || AppRuntimeConfig.verboseLogs) {
      debugPrint('[SIGAD][ERROR] $name | ${sanitizedError['error']}');
      if (stackTrace != null) {
        debugPrint(stackTrace.toString());
      }
    }
  }
}
