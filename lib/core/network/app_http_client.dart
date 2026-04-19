import 'api_request.dart';
import 'api_response.dart';

abstract class AppHttpClient {
  Future<ApiResponse> send(ApiRequest request);
}
