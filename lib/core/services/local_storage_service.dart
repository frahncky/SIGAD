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
    await prefs.setString(key, jsonEncode(data));
  }

  /// Carrega uma lista de mapas de JSON. Retorna lista vazia se não existir.
  static Future<List<Map<String, dynamic>>> loadList(String key) async {
    return await loadListOrNull(key) ?? const [];
  }

  /// Carrega uma lista preservando a diferença entre ausência e lista vazia.
  ///
  /// Retorna `null` somente quando a chave ainda não foi inicializada. Uma lista
  /// vazia persistida é retornada como `[]`, permitindo que telas com dados de
  /// demonstração não recriem os itens depois que o usuário excluir todos.
  static Future<List<Map<String, dynamic>>?> loadListOrNull(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(key);
    if (raw == null) return null;
    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList(growable: false);
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

  /// Remove um registro salvo por chave.
  static Future<void> remove(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(key);
  }
}
