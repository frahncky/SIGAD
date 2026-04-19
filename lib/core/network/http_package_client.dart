import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../services/app_event_logger.dart';
import 'api_config.dart';
import 'api_error.dart';
import 'api_request.dart';
import 'api_response.dart';
import 'app_http_client.dart';

class HttpPackageClient implements AppHttpClient {
  HttpPackageClient({
    required this.httpClient,
    this.baseUrl = ApiConfig.baseUrl,
    this.defaultTimeout = const Duration(seconds: 15),
  });

  final http.Client httpClient;
  final String baseUrl;
  final Duration defaultTimeout;

  @override
  Future<ApiResponse> send(ApiRequest request) async {
    final operationId = DateTime.now().microsecondsSinceEpoch.toString();
    final uri = Uri.parse(baseUrl).replace(
      path: _normalizePath(request.path),
      queryParameters: request.queryParameters.isEmpty ? null : request.queryParameters,
    );

    AppEventLogger.action('http_send_start', details: {
      'operationId': operationId,
      'method': request.method.name,
      'path': request.path,
    });

    final headers = {
      'Content-Type': 'application/json',
      ...request.headers,
    };

    final body = request.body == null ? null : jsonEncode(request.body);

    try {
      late http.Response response;
      switch (request.method) {
        case HttpMethod.get:
          response = await httpClient.get(uri, headers: headers).timeout(request.timeout ?? defaultTimeout);
        case HttpMethod.post:
          response = await httpClient
              .post(uri, headers: headers, body: body)
              .timeout(request.timeout ?? defaultTimeout);
        case HttpMethod.put:
          response = await httpClient
              .put(uri, headers: headers, body: body)
              .timeout(request.timeout ?? defaultTimeout);
        case HttpMethod.patch:
          response = await httpClient
              .patch(uri, headers: headers, body: body)
              .timeout(request.timeout ?? defaultTimeout);
        case HttpMethod.delete:
          response = await httpClient
              .delete(uri, headers: headers, body: body)
              .timeout(request.timeout ?? defaultTimeout);
      }

      final parsedBody = _tryDecodeJson(response.body);

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw ApiError(
          message: 'Falha na comunicacao com a API',
          statusCode: response.statusCode,
          details: parsedBody,
        );
      }

      AppEventLogger.action('http_send_success', details: {
        'operationId': operationId,
        'method': request.method.name,
        'path': request.path,
        'statusCode': response.statusCode,
      });

      return ApiResponse(
        statusCode: response.statusCode,
        body: parsedBody,
        headers: response.headers,
      );
    } on TimeoutException catch (error, stackTrace) {
      AppEventLogger.error('http_send_timeout:$operationId', error, stackTrace: stackTrace);
      throw ApiError(
        message: 'Tempo limite excedido na comunicacao com a API',
      );
    } catch (error, stackTrace) {
      AppEventLogger.error('http_send_error:$operationId', error, stackTrace: stackTrace);
      rethrow;
    }
  }

  Object? _tryDecodeJson(String body) {
    if (body.trim().isEmpty) return null;
    try {
      return jsonDecode(body);
    } catch (_) {
      return body;
    }
  }

  String _normalizePath(String path) {
    final normalizedBase = Uri.parse(baseUrl).path;
    final cleanPath = path.startsWith('/') ? path : '/$path';

    if (normalizedBase.isEmpty || normalizedBase == '/') {
      return cleanPath;
    }

    final base = normalizedBase.endsWith('/')
        ? normalizedBase.substring(0, normalizedBase.length - 1)
        : normalizedBase;
    return '$base$cleanPath';
  }
}
