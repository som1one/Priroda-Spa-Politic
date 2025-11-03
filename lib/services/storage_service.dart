import 'dart:convert';
// import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  // SharedPreferences? _prefs;

  // Future<void> init() async {
  //   _prefs = await SharedPreferences.getInstance();
  // }

  Future<void> saveString(String key, String value) async {
    // TODO: Реализовать сохранение через SharedPreferences
    // await _prefs?.setString(key, value);
    await Future.delayed(Duration.zero);
  }

  Future<String?> getString(String key) async {
    // TODO: Реализовать получение через SharedPreferences
    // return _prefs?.getString(key);
    return null;
  }

  Future<void> saveBool(String key, bool value) async {
    // TODO: Реализовать сохранение через SharedPreferences
    // await _prefs?.setBool(key, value);
    await Future.delayed(Duration.zero);
  }

  Future<bool?> getBool(String key) async {
    // TODO: Реализовать получение через SharedPreferences
    // return _prefs?.getBool(key);
    return null;
  }

  Future<void> saveObject(String key, Map<String, dynamic> value) async {
    // TODO: Реализовать сохранение через SharedPreferences
    // final jsonString = jsonEncode(value);
    // await _prefs?.setString(key, jsonString);
    await Future.delayed(Duration.zero);
  }

  Future<Map<String, dynamic>?> getObject(String key) async {
    // TODO: Реализовать получение через SharedPreferences
    // final jsonString = _prefs?.getString(key);
    // if (jsonString != null) {
    //   return jsonDecode(jsonString) as Map<String, dynamic>;
    // }
    return null;
  }

  Future<void> remove(String key) async {
    // TODO: Реализовать удаление через SharedPreferences
    // await _prefs?.remove(key);
    await Future.delayed(Duration.zero);
  }

  Future<void> clear() async {
    // TODO: Реализовать очистку через SharedPreferences
    // await _prefs?.clear();
    await Future.delayed(Duration.zero);
  }

  // Методы для конкретных данных
  Future<void> saveToken(String token) async {
    await saveString(AppConstants.tokenKey, token);
  }

  Future<String?> getToken() async {
    return await getString(AppConstants.tokenKey);
  }

  Future<void> removeToken() async {
    await remove(AppConstants.tokenKey);
  }
}

