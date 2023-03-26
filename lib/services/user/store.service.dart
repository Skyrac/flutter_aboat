import 'package:shared_preferences/shared_preferences.dart';

class StoreService {
  Future<void> set(String key, dynamic value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (value is int) {
      await prefs.setInt(key, value);
    } else if (value is double) {
      await prefs.setDouble(key, value);
    } else if (value is String) {
      await prefs.setString(key, value);
    } else if (value is List<String>) {
      await prefs.setStringList(key, value);
    }else if (value is bool) {
      await prefs.setBool(key, value);
    } else {
      throw Exception('Unsupported value type');
    }
  }

  Future<T> get<T>(String key, T defaultValue) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if(!prefs.containsKey(key)) {
      return defaultValue;
    }
    return prefs.get(key) as T ?? defaultValue;
  }
}