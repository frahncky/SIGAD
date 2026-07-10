import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:sigad/core/network/api_error.dart';
import 'package:sigad/core/network/api_request.dart';
import 'package:sigad/core/network/http_package_client.dart';

void main() {
  group('HttpPackageClient', () {
    test('envia GET e decodifica resposta json', () async {
      final client = HttpPackageClient(
        baseUrl: 'https://api.sigad.local',
        httpClient: MockClient((request) async {
          expect(request.url.path, '/atividades');
          expect(request.method, 'GET');
          return http.Response(
            '[{"id":"1"}]',
            200,
            headers: {'content-type': 'application/json'},
          );
        }),
      );

      final response = await client.send(const ApiRequest(path: '/atividades'));

      expect(response.isSuccess, isTrue);
      expect(response.body, isA<List<dynamic>>());
    });

    test('lança ApiError para status não 2xx', () async {
      final client = HttpPackageClient(
        baseUrl: 'https://api.sigad.local',
        httpClient: MockClient(
          (_) async => http.Response('{"error":"fail"}', 500),
        ),
      );

      expect(
        () => client.send(const ApiRequest(path: '/demandas')),
        throwsA(isA<ApiError>().having((e) => e.statusCode, 'statusCode', 500)),
      );
    });

    test('lança ApiError em cenário de timeout/offline', () async {
      final client = HttpPackageClient(
        baseUrl: 'https://api.sigad.local',
        httpClient: MockClient((_) async {
          await Future<void>.delayed(const Duration(milliseconds: 60));
          return http.Response('{"ok":true}', 200);
        }),
      );

      expect(
        () => client.send(
          const ApiRequest(
            path: '/demandas',
            timeout: Duration(milliseconds: 5),
          ),
        ),
        throwsA(
          isA<ApiError>().having(
            (e) => e.message,
            'message',
            contains('Tempo limite'),
          ),
        ),
      );
    });
  });
}
