import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Serviço simples de persistência local via SharedPreferences + JSON.
class LocalStorageService {
  /// Salva uma lista de mapas serializada em JSON.
  static Future<void> saveList(
    String key,
    List<Map<String, dynamic>> data,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final saved = await prefs.setString(key, jsonEncode(data));
    if (!saved) {
      throw StateError('Não foi possível salvar os dados locais.');
    }
  }

  /// Carrega uma lista de mapas de JSON.  Retorna lista vazia se não existir.
  static Future<List<Map<String, dynamic>>> loadList(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(key);
    if (raw == null) return [];
    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList(growable: false);
  }

  /// Salva um mapa serializado em JSON.
  static Future<void> saveMap(String key, Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    final saved = await prefs.setString(key, jsonEncode(data));
    if (!saved) {
      throw StateError('Não foi possível salvar os dados locais.');
    }
  }

  /// Carrega um mapa de JSON.  Retorna null se não existir.
  static Future<Map<String, dynamic>?> loadMap(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(key);
    if (raw == null) return null;
    return Map<String, dynamic>.from(jsonDecode(raw) as Map);
  }

  /// Remove um registro salvo por chave.
  static Future<void> remove(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final removed = await prefs.remove(key);
    if (!removed) {
      throw StateError('Não foi possível remover os dados locais.');
    }
  }
}
