enum HttpMethod { get, post, put, patch, delete }

class ApiRequest {
  const ApiRequest({
    required this.path,
    this.method = HttpMethod.get,
    this.queryParameters = const {},
    this.headers = const {},
    this.body,
  });

  final String path;
  final HttpMethod method;
  final Map<String, String> queryParameters;
  final Map<String, String> headers;
  final Object? body;
}
