import 'package:dio/dio.dart';
import 'package:frontend/Core/storage/token_storage.dart';
import '../../../../Core/network/app_exception.dart';
import '../../../../Core/network/dio_client.dart';

class AuthRemoteDataSource {
  final DioClient _dioClient;
  final TokenStorage _storage;

  AuthRemoteDataSource(this._dioClient, this._storage);

  Future<Map<String, dynamic>> register({
    required String displayName,
    required String email,
    required String password,
    String? phoneNumber,
  }) async {
    try {
      final res = await _dioClient.post(
        '/api/auth/register/',
        data: {
          'display_name': displayName,
          'email': email,
          'password': password,
          if (phoneNumber != null) 'phone_number': phoneNumber,
        },
      );
      await _storage.saveTokens(res.data['access'], res.data['refresh']);
      return res.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw AppException(message: _parseError(e));
    }
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final res = await _dioClient.post(
        '/api/auth/login/',
        data: {'email': email, 'password': password},
      );
      await _storage.saveTokens(res.data['access'], res.data['refresh']);
      return res.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw AppException(message: _parseError(e));
    }
  }

  Future<void> logout() async {
    try {
      await _dioClient.post('/api/auth/logout/');
    } catch (_) {
      // Ignore errors on logout
    }
    await _storage.clearTokens();
  }

  Future<bool> tryRestoreSession() async {
    try {
      final accessToken = await _storage.getAccessToken();
      final refreshToken = await _storage.getRefreshToken();

      if (accessToken == null || accessToken.isEmpty) {
        return false;
      }
      if (refreshToken == null || refreshToken.isEmpty) {
        await _storage.clearTokens();
        return false;
      }

      try {
        final refreshResponse = await _dioClient.post(
          '/api/auth/token/refresh/',
          data: {'refresh': refreshToken},
        );

        final newAccessToken = refreshResponse.data['access'] as String?;
        if (newAccessToken == null || newAccessToken.isEmpty) {
          throw Exception('Unable to refresh authentication token.');
        }

        await _storage.write(
          key: TokenStorage.accessTokenKey,
          value: newAccessToken,
        );
        return true;
      } catch (_) {
        await _storage.clearTokens();
        return false;
      }
    } catch (_) {
      await _storage.clearTokens();
      return false;
    }
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
