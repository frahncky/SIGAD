import 'package:flutter/foundation.dart';

/// Logging funcional leve para ações críticas da aplicação.
abstract final class AppEventLogger {
  static void action(String name, {Map<String, Object?> details = const {}}) {
    final payload = details.entries.map((e) => '${e.key}=${e.value}').join(', ');
    debugPrint('[SIGAD][ACTION] $name${payload.isEmpty ? '' : ' | $payload'}');
  }

  static void error(String name, Object error, {StackTrace? stackTrace}) {
    debugPrint('[SIGAD][ERROR] $name | $error');
    if (stackTrace != null) {
      debugPrint(stackTrace.toString());
    }
  }
}
