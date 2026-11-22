import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';

/// Stores only the app's own editing preferences (shape, blur type and
/// strength). Nothing about picked images is ever stored.
class LocalStorage {
  LocalStorage._privateConstructor();

  static final LocalStorage _instance = LocalStorage._privateConstructor();

  factory LocalStorage() {
    return _instance;
  }

  Future<bool?> getBool(String key) async {
    var prefs = await SharedPreferences.getInstance();
    return prefs.getBool(key);
  }

  Future<bool> putBool(String key, bool value) async {
    var prefs = await SharedPreferences.getInstance();
    return prefs.setBool(key, value);
  }

  Future<double?> getDouble(String key) async {
    var prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(key);
  }

  Future<bool> putDouble(String key, double value) async {
    var prefs = await SharedPreferences.getInstance();
    return prefs.setDouble(key, value);
  }
}
