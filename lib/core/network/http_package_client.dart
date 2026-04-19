import 'dart:convert';

import 'package:http/http.dart' as http;

import 'api_config.dart';
import 'api_error.dart';
import 'api_request.dart';
import 'api_response.dart';
import 'app_http_client.dart';

class HttpPackageClient implements AppHttpClient {
  HttpPackageClient({
    required this.httpClient,
    this.baseUrl = ApiConfig.baseUrl,
  });

  final http.Client httpClient;
  final String baseUrl;

  @override
  Future<ApiResponse> send(ApiRequest request) async {
    final uri = Uri.parse(baseUrl).replace(
      path: _normalizePath(request.path),
      queryParameters: request.queryParameters.isEmpty ? null : request.queryParameters,
    );

    final headers = {
      'Content-Type': 'application/json',
      ...request.headers,
    };

    final body = request.body == null ? null : jsonEncode(request.body);

    late http.Response response;
    switch (request.method) {
      case HttpMethod.get:
        response = await httpClient.get(uri, headers: headers);
      case HttpMethod.post:
        response = await httpClient.post(uri, headers: headers, body: body);
      case HttpMethod.put:
        response = await httpClient.put(uri, headers: headers, body: body);
      case HttpMethod.patch:
        response = await httpClient.patch(uri, headers: headers, body: body);
      case HttpMethod.delete:
        response = await httpClient.delete(uri, headers: headers, body: body);
    }

    final parsedBody = _tryDecodeJson(response.body);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiError(
        message: 'Falha na comunicacao com a API',
        statusCode: response.statusCode,
        details: parsedBody,
      );
    }

    return ApiResponse(
      statusCode: response.statusCode,
      body: parsedBody,
      headers: response.headers,
    );
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
