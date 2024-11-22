import 'package:shared_preferences/shared_preferences.dart';

class SettingsApi {
  Future<String?> getSetting(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final content = prefs.getString(key);
    return content;
  }

  Future<void> saveSetting(String key, String content) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, content);
  }

  Future<void> deleteSetting(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(key);
  }
}
