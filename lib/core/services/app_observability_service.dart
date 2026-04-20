import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

abstract final class AppObservabilityService {
  static bool _enabled = false;
  static Uri? _endpoint;
  static Duration _timeout = const Duration(seconds: 3);
  static http.Client _client = http.Client();

  static void configure({
    required bool enabled,
    String endpoint = '',
    Duration timeout = const Duration(seconds: 3),
    http.Client? client,
  }) {
    _enabled = enabled;
    _timeout = timeout;
    _endpoint = _parseEndpoint(endpoint);
    if (client != null) {
      _client = client;
    }
  }

  static void dispatchAction({
    required String eventName,
    required String flavor,
    required Map<String, Object?> details,
  }) {
    _dispatch(
      severity: 'action',
      eventName: eventName,
      flavor: flavor,
      details: details,
    );
  }

  static void dispatchError({
    required String eventName,
    required String flavor,
    required Object error,
    required Map<String, Object?> details,
    StackTrace? stackTrace,
  }) {
    _dispatch(
      severity: 'error',
      eventName: eventName,
      flavor: flavor,
      details: details,
      error: error.toString(),
      stackTrace: stackTrace?.toString(),
    );
  }

  static void _dispatch({
    required String severity,
    required String eventName,
    required String flavor,
    required Map<String, Object?> details,
    String? error,
    String? stackTrace,
  }) {
    final endpoint = _endpoint;
    if (!_enabled || endpoint == null) return;

    final payload = <String, Object?>{
      'timestamp': DateTime.now().toUtc().toIso8601String(),
      'severity': severity,
      'eventName': eventName,
      'flavor': flavor,
      'details': details,
      ...?error == null ? null : {'error': error},
      ...?stackTrace == null ? null : {'stackTrace': stackTrace},
    };

    unawaited(_sendPayload(endpoint, payload));
  }

  static Uri? _parseEndpoint(String endpoint) {
    final normalized = endpoint.trim();
    if (normalized.isEmpty) return null;
    final parsed = Uri.tryParse(normalized);
    if (parsed == null || !parsed.hasAuthority || !parsed.hasScheme) return null;
    return parsed;
  }

  static Future<void> _sendPayload(Uri endpoint, Map<String, Object?> payload) async {
    try {
      await _client
          .post(
            endpoint,
            headers: const {'Content-Type': 'application/json'},
            body: jsonEncode(payload),
          )
          .timeout(_timeout);
    } catch (_) {
      // Não bloqueia fluxo principal por falha de telemetria.
    }
  }
}
