import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage {
  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  static SharedPreferences get instance {
    final prefs = _prefs;

    if (prefs == null) {
      throw StateError(
        'LocalStorage is not initialized. Call LocalStorage.init() first.',
      );
    }

    return prefs;
  }

  static Future<bool> setString(String key, String value) {
    return instance.setString(key, value);
  }

  static String? getString(String key) {
    return instance.getString(key);
  }

  static Future<bool> setBool(String key, bool value) {
    return instance.setBool(key, value);
  }

  static bool getBool(String key, {bool defaultValue = false}) {
    return instance.getBool(key) ?? defaultValue;
  }

  static Future<bool> remove(String key) {
    return instance.remove(key);
  }
}
