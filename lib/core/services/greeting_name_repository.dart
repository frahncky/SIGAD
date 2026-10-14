import 'local_storage_service.dart';

/// Preferência apenas neste dispositivo, separada dos dados institucionais.
class GreetingNameRepository {
  String _key(String userId) =>
      'greeting_name_v1_${Uri.encodeComponent(userId)}';

  Future<String?> load(String userId) async {
    final data = await LocalStorageService.loadMap(_key(userId));
    final value = data?['name'];
    return value is String && value.trim().isNotEmpty ? value.trim() : null;
  }

  Future<void> save(String userId, String? name) =>
      LocalStorageService.saveMap(_key(userId), {'name': name});
}
