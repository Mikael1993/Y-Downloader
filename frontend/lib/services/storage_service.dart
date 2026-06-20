import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _downloadsKey = 'downloads_history';
  static const String _accentColorKey = 'settings_accent_color';
  static const String _concurrentThreadsKey = 'settings_concurrent_threads';
  static const String _wifiOnlyKey = 'settings_wifi_only';
  static const String _searchHistoryKey = 'search_history_list';

  static late SharedPreferences _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // --- Downloads History ---
  static Future<List<Map<String, dynamic>>> loadDownloads() async {
    try {
      final jsonString = _prefs.getString(_downloadsKey);
      if (jsonString == null) {
        return [];
      }

      final jsonList = jsonDecode(jsonString) as List;
      return jsonList
          .map((item) => Map<String, dynamic>.from(item as Map))
          .toList();
    } catch (e) {
      print('Error loading downloads: $e');
      return [];
    }
  }

  static Future<void> saveDownloads(
      List<Map<String, dynamic>> downloads) async {
    try {
      final jsonString = jsonEncode(downloads);
      await _prefs.setString(_downloadsKey, jsonString);
    } catch (e) {
      print('Error saving downloads: $e');
    }
  }

  static Future<void> clearDownloads() async {
    try {
      await _prefs.remove(_downloadsKey);
    } catch (e) {
      print('Error clearing downloads: $e');
    }
  }

  // --- Accent Color (default Crimson Red: 0xFFFF1A1A) ---
  static int getAccentColor() {
    return _prefs.getInt(_accentColorKey) ?? 0xFFFF1A1A;
  }

  static Future<void> setAccentColor(int colorHex) async {
    await _prefs.setInt(_accentColorKey, colorHex);
  }

  // --- Concurrent Threads (default 1) ---
  static int getConcurrentThreads() {
    return _prefs.getInt(_concurrentThreadsKey) ?? 1;
  }

  static Future<void> setConcurrentThreads(int threads) async {
    await _prefs.setInt(_concurrentThreadsKey, threads);
  }

  // --- WiFi-Only (default false) ---
  static bool getWifiOnly() {
    return _prefs.getBool(_wifiOnlyKey) ?? false;
  }

  static Future<void> setWifiOnly(bool wifiOnly) async {
    await _prefs.setBool(_wifiOnlyKey, wifiOnly);
  }

  // --- Search History ---
  static List<String> getSearchHistory() {
    return _prefs.getStringList(_searchHistoryKey) ?? [];
  }

  static Future<void> saveSearchHistory(List<String> history) async {
    await _prefs.setStringList(_searchHistoryKey, history);
  }

  static Future<void> addSearchQuery(String query) async {
    final q = query.trim();
    if (q.isEmpty) return;
    
    final history = getSearchHistory();
    // Case-insensitive removal of existing duplicates
    history.removeWhere((item) => item.toLowerCase() == q.toLowerCase());
    history.insert(0, q);
    
    // Cap at 15 items
    if (history.length > 15) {
      history.removeRange(15, history.length);
    }
    
    await saveSearchHistory(history);
  }

  static Future<void> clearSearchHistory() async {
    await _prefs.remove(_searchHistoryKey);
  }

  // --- Reset All Settings ---
  static Future<void> resetSettings() async {
    await _prefs.remove(_accentColorKey);
    await _prefs.remove(_concurrentThreadsKey);
    await _prefs.remove(_wifiOnlyKey);
  }
}
