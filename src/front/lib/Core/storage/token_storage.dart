// lib/core/storage/token_storage.dart
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TokenStorage {
  static const _accessTokenKey = 'access_token';
  static String get accessTokenKey => _accessTokenKey;

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  SharedPreferences? _prefs;

  Future<void> _ensurePrefs() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  Future<void> write({required String key, required String value}) async {
    if (kIsWeb) {
      await _ensurePrefs();
      await _prefs!.setString(key, value);
    } else {
      await _secureStorage.write(key: key, value: value);
    }
  }

  Future<String?> read({required String key}) async {
    if (kIsWeb) {
      await _ensurePrefs();
      return _prefs!.getString(key);
    } else {
      return await _secureStorage.read(key: key);
    }
  }

  Future<void> delete({required String key}) async {
    if (kIsWeb) {
      await _ensurePrefs();
      await _prefs!.remove(key);
    } else {
      await _secureStorage.delete(key: key);
    }
  }

  Future<void> saveTokens(String accessToken) async {
    await write(key: _accessTokenKey, value: accessToken);
  }

  Future<String?> getAccessToken() async {
    return await read(key: _accessTokenKey);
  }

  Future<void> clearTokens() async {
    await delete(key: _accessTokenKey);
  }
}
