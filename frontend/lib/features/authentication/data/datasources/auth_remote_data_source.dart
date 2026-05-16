import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../data/models/account_model.dart';
import '../../../../Core/network/app_exception.dart';

class AuthRemoteDataSource {
  static const _refreshKey = 'refresh_token';

  final Dio _dio;
  final FlutterSecureStorage _storage;
  String? accessToken;

  AuthRemoteDataSource(this._dio)
      : _storage = const FlutterSecureStorage();

  Future<Map<String, dynamic>> register({
    required String displayName,
    required String email,
    required String password,
    String? phoneNumber,
  }) async {
    try {
      final res = await _dio.post('/auth/register/', data: {
        'display_name': displayName,
        'email':        email,
        'password':     password,
        if (phoneNumber != null) 'phone_number': phoneNumber,
      });
      await _saveTokens(res.data['access'], res.data['refresh']);
      return res.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw AppException(_parseError(e));
    }
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final res = await _dio.post('/auth/login/', data: {
        'email':    email,
        'password': password,
      });
      await _saveTokens(res.data['access'], res.data['refresh']);
      return res.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw AppException(_parseError(e));
    }
  }

  Future<void> logout() async {
    final refresh = await _storage.read(key: _refreshKey);
    if (refresh != null) {
      try {
        await _dio.post('/auth/logout/', data: {'refresh': refresh});
      } catch (_) {}
    }
    await _clearTokens();
  }

  Future<bool> tryRestoreSession() async {
    final refresh = await _storage.read(key: _refreshKey);
    if (refresh == null) return false;
    try {
      final plain = Dio(BaseOptions(baseUrl: _dio.options.baseUrl));
      final res = await plain.post('/auth/token/refresh/', data: {'refresh': refresh});
      accessToken = res.data['access'] as String;
      return true;
    } catch (_) {
      await _clearTokens();
      return false;
    }
  }

  Future<void> _saveTokens(String access, String refresh) async {
    accessToken = access;
    await _storage.write(key: _refreshKey, value: refresh);
  }

  Future<void> _clearTokens() async {
    accessToken = null;
    await _storage.delete(key: _refreshKey);
  }

  String _parseError(DioException e) {
    try {
      final data = e.response?.data;
      if (data is Map) {
        if (data.containsKey('detail')) return data['detail'].toString();
        final value = data[data.keys.first];
        if (value is List && value.isNotEmpty) return value.first.toString();
        return value.toString();
      }
    } catch (_) {}
    return 'Network error, please try again';
  }
}
