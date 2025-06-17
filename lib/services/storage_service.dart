import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class StorageService {
  static StorageService? _instance;
  static SharedPreferences? _prefs;

  StorageService._();

  static Future<StorageService> getInstance() async {
    _instance ??= StorageService._();
    _prefs ??= await SharedPreferences.getInstance();
    return _instance!;
  }

  // Métodos para salvar dados
  Future<bool> saveString(String key, String value) async {
    return await _prefs!.setString(key, value);
  }

  Future<bool> saveInt(String key, int value) async {
    return await _prefs!.setInt(key, value);
  }

  Future<bool> saveBool(String key, bool value) async {
    return await _prefs!.setBool(key, value);
  }

  Future<bool> saveDouble(String key, double value) async {
    return await _prefs!.setDouble(key, value);
  }

  Future<bool> saveStringList(String key, List<String> value) async {
    return await _prefs!.setStringList(key, value);
  }

  Future<bool> saveMap(String key, Map<String, dynamic> value) async {
    return await _prefs!.setString(key, jsonEncode(value));
  }

  Future<bool> saveList(String key, List<Map<String, dynamic>> value) async {
    return await _prefs!.setString(key, jsonEncode(value));
  }

  // Métodos para recuperar dados
  String? getString(String key) {
    return _prefs!.getString(key);
  }

  int? getInt(String key) {
    return _prefs!.getInt(key);
  }

  bool? getBool(String key) {
    return _prefs!.getBool(key);
  }

  double? getDouble(String key) {
    return _prefs!.getDouble(key);
  }

  List<String>? getStringList(String key) {
    return _prefs!.getStringList(key);
  }

  Map<String, dynamic>? getMap(String key) {
    final String? value = _prefs!.getString(key);
    if (value != null) {
      try {
        return jsonDecode(value) as Map<String, dynamic>;
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  List<Map<String, dynamic>>? getList(String key) {
    final String? value = _prefs!.getString(key);
    if (value != null) {
      try {
        final List<dynamic> decoded = jsonDecode(value);
        return decoded.map((item) => item as Map<String, dynamic>).toList();
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  // Métodos para verificar existência e remover dados
  bool containsKey(String key) {
    return _prefs!.containsKey(key);
  }

  Future<bool> remove(String key) async {
    return await _prefs!.remove(key);
  }

  Future<bool> clear() async {
    return await _prefs!.clear();
  }

  // Métodos específicos para o aplicativo
  Future<bool> saveUserSession(Map<String, dynamic> userData) async {
    return await saveMap('user_session', userData);
  }

  Map<String, dynamic>? getUserSession() {
    return getMap('user_session');
  }

  Future<bool> clearUserSession() async {
    return await remove('user_session');
  }

  Future<bool> saveFavoriteProducts(List<int> productIds) async {
    return await saveStringList('favorite_products', productIds.map((id) => id.toString()).toList());
  }

  List<int> getFavoriteProducts() {
    final List<String>? stringIds = getStringList('favorite_products');
    if (stringIds != null) {
      return stringIds.map((id) => int.parse(id)).toList();
    }
    return [];
  }

  Future<bool> saveFavoriteServices(List<int> serviceIds) async {
    return await saveStringList('favorite_services', serviceIds.map((id) => id.toString()).toList());
  }

  List<int> getFavoriteServices() {
    final List<String>? stringIds = getStringList('favorite_services');
    if (stringIds != null) {
      return stringIds.map((id) => int.parse(id)).toList();
    }
    return [];
  }

  Future<bool> saveRecentSearches(List<String> searches) async {
    // Manter apenas os últimos 10 termos de busca
    final recentSearches = searches.take(10).toList();
    return await saveStringList('recent_searches', recentSearches);
  }

  List<String> getRecentSearches() {
    return getStringList('recent_searches') ?? [];
  }

  Future<bool> addRecentSearch(String searchTerm) async {
    final currentSearches = getRecentSearches();
    
    // Remove o termo se já existe
    currentSearches.remove(searchTerm);
    
    // Adiciona no início da lista
    currentSearches.insert(0, searchTerm);
    
    return await saveRecentSearches(currentSearches);
  }

  Future<bool> saveAppSettings(Map<String, dynamic> settings) async {
    return await saveMap('app_settings', settings);
  }

  Map<String, dynamic> getAppSettings() {
    return getMap('app_settings') ?? {
      'theme': 'light',
      'notifications': true,
      'language': 'pt_BR',
      'autoSync': true,
    };
  }

  Future<bool> updateAppSetting(String key, dynamic value) async {
    final settings = getAppSettings();
    settings[key] = value;
    return await saveAppSettings(settings);
  }

  // Cache de dados temporários
  Future<bool> cacheData(String key, Map<String, dynamic> data, {Duration? duration}) async {
    final cacheData = {
      'data': data,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'duration': duration?.inMilliseconds,
    };
    return await saveMap('cache_$key', cacheData);
  }

  Map<String, dynamic>? getCachedData(String key) {
    final cacheData = getMap('cache_$key');
    if (cacheData != null) {
      final timestamp = cacheData['timestamp'] as int;
      final duration = cacheData['duration'] as int?;
      
      if (duration != null) {
        final expiryTime = DateTime.fromMillisecondsSinceEpoch(timestamp).add(Duration(milliseconds: duration));
        if (DateTime.now().isAfter(expiryTime)) {
          // Cache expirado, remover
          remove('cache_$key');
          return null;
        }
      }
      
      return cacheData['data'] as Map<String, dynamic>;
    }
    return null;
  }

  Future<bool> clearCache() async {
    final keys = _prefs!.getKeys();
    final cacheKeys = keys.where((key) => key.startsWith('cache_'));
    
    for (final key in cacheKeys) {
      await remove(key);
    }
    
    return true;
  }
}