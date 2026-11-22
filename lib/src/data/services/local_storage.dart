import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage {
  LocalStorage._privateConstructor();

  static final LocalStorage _instance = LocalStorage._privateConstructor();

  factory LocalStorage() {
    return _instance;
  }

  late SharedPreferences _sharedPrefs;

  Future<bool> setLastPath(String path) {
    return putValue('lastImage', path);
  }

  Future<String> getLastPath() {
    return getValue('lastImage');
  }

  Future<bool> removeLastPath() {
    return putValue('lastImage', null);
  }

  Future<String> getValue(String key) async {
    await _init();
    return Future.value(_sharedPrefs.getString(key) ?? '');
  }

  Future<bool> putValue(String key, String? value) async {
    await _init();
    if (value == null) {
      return _sharedPrefs.remove(key);
    } else {
      return _sharedPrefs.setString(key, value);
    }
  }

  Future<bool?> getBool(String key) async {
    await _init();
    return _sharedPrefs.getBool(key);
  }

  Future<bool> putBool(String key, bool value) async {
    await _init();
    return _sharedPrefs.setBool(key, value);
  }

  Future<double?> getDouble(String key) async {
    await _init();
    return _sharedPrefs.getDouble(key);
  }

  Future<bool> putDouble(String key, double value) async {
    await _init();
    return _sharedPrefs.setDouble(key, value);
  }

  Future _init() async {
    _sharedPrefs = await SharedPreferences.getInstance();
    return Future.value();
  }
}
