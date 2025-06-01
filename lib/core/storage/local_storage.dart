import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:home_management/core/error/exceptions.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class LocalStorage {
  Future<void> saveString(String key, String value);
  Future<String?> getString(String key);
  Future<void> saveInt(String key, int value);
  Future<int?> getInt(String key);
  Future<void> saveDouble(String key, double value);
  Future<double?> getDouble(String key);
  Future<void> saveBool(String key, bool value);
  Future<bool?> getBool(String key);
  Future<void> saveObject(String key, Map<String, dynamic> value);
  Future<Map<String, dynamic>?> getObject(String key);
  Future<void> saveSecureString(String key, String value);
  Future<String?> getSecureString(String key);
  Future<void> remove(String key);
  Future<void> removeSecure(String key);
  Future<void> clear();
  Future<void> clearSecure();
}

@LazySingleton(as: LocalStorage)
class LocalStorageImpl implements LocalStorage {
  final SharedPreferences _preferences;
  final FlutterSecureStorage _secureStorage;

  LocalStorageImpl(this._preferences, this._secureStorage);

  @override
  Future<void> saveString(String key, String value) async {
    try {
      await _preferences.setString(key, value);
    } catch (e) {
      throw CacheException(message: 'Veri kaydedilemedi: $e');
    }
  }

  @override
  Future<String?> getString(String key) async {
    try {
      return _preferences.getString(key);
    } catch (e) {
      throw CacheException(message: 'Veri alınamadı: $e');
    }
  }

  @override
  Future<void> saveInt(String key, int value) async {
    try {
      await _preferences.setInt(key, value);
    } catch (e) {
      throw CacheException(message: 'Veri kaydedilemedi: $e');
    }
  }

  @override
  Future<int?> getInt(String key) async {
    try {
      return _preferences.getInt(key);
    } catch (e) {
      throw CacheException(message: 'Veri alınamadı: $e');
    }
  }

  @override
  Future<void> saveDouble(String key, double value) async {
    try {
      await _preferences.setDouble(key, value);
    } catch (e) {
      throw CacheException(message: 'Veri kaydedilemedi: $e');
    }
  }

  @override
  Future<double?> getDouble(String key) async {
    try {
      return _preferences.getDouble(key);
    } catch (e) {
      throw CacheException(message: 'Veri alınamadı: $e');
    }
  }

  @override
  Future<void> saveBool(String key, bool value) async {
    try {
      await _preferences.setBool(key, value);
    } catch (e) {
      throw CacheException(message: 'Veri kaydedilemedi: $e');
    }
  }

  @override
  Future<bool?> getBool(String key) async {
    try {
      return _preferences.getBool(key);
    } catch (e) {
      throw CacheException(message: 'Veri alınamadı: $e');
    }
  }

  @override
  Future<void> saveObject(String key, Map<String, dynamic> value) async {
    try {
      final jsonString = json.encode(value);
      await _preferences.setString(key, jsonString);
    } catch (e) {
      throw CacheException(message: 'Veri kaydedilemedi: $e');
    }
  }

  @override
  Future<Map<String, dynamic>?> getObject(String key) async {
    try {
      final jsonString = _preferences.getString(key);
      if (jsonString == null) return null;
      return json.decode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      throw CacheException(message: 'Veri alınamadı: $e');
    }
  }

  @override
  Future<void> saveSecureString(String key, String value) async {
    try {
      await _secureStorage.write(key: key, value: value);
    } catch (e) {
      throw CacheException(message: 'Güvenli veri kaydedilemedi: $e');
    }
  }

  @override
  Future<String?> getSecureString(String key) async {
    try {
      return await _secureStorage.read(key: key);
    } catch (e) {
      throw CacheException(message: 'Güvenli veri alınamadı: $e');
    }
  }

  @override
  Future<void> remove(String key) async {
    try {
      await _preferences.remove(key);
    } catch (e) {
      throw CacheException(message: 'Veri silinemedi: $e');
    }
  }

  @override
  Future<void> removeSecure(String key) async {
    try {
      await _secureStorage.delete(key: key);
    } catch (e) {
      throw CacheException(message: 'Güvenli veri silinemedi: $e');
    }
  }

  @override
  Future<void> clear() async {
    try {
      await _preferences.clear();
    } catch (e) {
      throw CacheException(message: 'Veriler temizlenemedi: $e');
    }
  }

  @override
  Future<void> clearSecure() async {
    try {
      await _secureStorage.deleteAll();
    } catch (e) {
      throw CacheException(message: 'Güvenli veriler temizlenemedi: $e');
    }
  }
}