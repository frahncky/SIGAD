import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Serviço simples de persistência local via SharedPreferences + JSON.
class LocalStorageService {
  /// Salva uma lista de mapas serializada em JSON.
  static Future<void> saveList(String key, List<Map<String, dynamic>> data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, jsonEncode(data));
  }

  /// Carrega uma lista de mapas de JSON.  Retorna lista vazia se não existir.
  static Future<List<Map<String, dynamic>>> loadList(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(key);
    if (raw == null) return [];
    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  /// Salva um mapa serializado em JSON.
  static Future<void> saveMap(String key, Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, jsonEncode(data));
  }

  /// Carrega um mapa de JSON.  Retorna null se não existir.
  static Future<Map<String, dynamic>?> loadMap(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(key);
    if (raw == null) return null;
    return Map<String, dynamic>.from(jsonDecode(raw) as Map);
  }
}
