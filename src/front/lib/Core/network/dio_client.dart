import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend/Core/network/app_exception.dart';
import 'package:frontend/Core/network/errors.dart';

class DioClient {
  static const _refreshTokenKey = 'refresh_token';
  static const _accessTokenKey = 'access_token';
  
  final Dio _dio;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  bool _isRefreshing = false;
  final List<Function> _refreshRequests = [];

  DioClient()
    : _dio = Dio(
        BaseOptions(
          baseUrl: "http://127.0.0.1:8000",
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      ) {
    _setupInterceptors();
  }

  void _setupInterceptors() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Add authorization header if token exists
          final accessToken = await _storage.read(key: _accessTokenKey);
          if (accessToken != null && accessToken.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $accessToken';
          }
          
          debugPrint('🌐 REQUEST: ${options.method} ${options.path}');
          debugPrint('   Full URL: ${options.uri}');
          debugPrint('   Headers: ${options.headers}');
          if (options.queryParameters.isNotEmpty) {
            debugPrint('   Query: ${options.queryParameters}');
          }
          if (options.data != null) {
            debugPrint('   Body: ${options.data}');
          }
          return handler.next(options);
        },
        onResponse: (response, handler) {
          debugPrint('✅ RESPONSE: ${response.statusCode} ${response.requestOptions.path}');
          debugPrint('   Data: ${response.data}');
          return handler.next(response);
        },
        onError: (error, handler) async {
          debugPrint('❌ ERROR: ${error.type} - ${error.message}');
          debugPrint('   Path: ${error.requestOptions.path}');
          debugPrint('   Status: ${error.response?.statusCode}');
          debugPrint('   Response: ${error.response?.data}');
          
          // Handle token expiration and refresh
          if (error.response?.statusCode == 401 &&
              error.requestOptions.path != '/api/auth/token/refresh/' &&
              error.requestOptions.path != '/api/auth/login/' &&
              error.requestOptions.path != '/api/auth/register/') {
            return _handleTokenExpiry(error, handler);
          }
          
          final appException = NetworkErrors.fromDioException(error);
          return handler.reject(
            error.copyWith(error: appException, message: appException.message),
          );
        },
      ),
    );
  }

  Future<dynamic> _handleTokenExpiry(DioException error, ErrorInterceptorHandler handler) async {
    if (!_isRefreshing) {
      _isRefreshing = true;
      try {
        final refreshToken = await _storage.read(key: _refreshTokenKey);
        if (refreshToken == null) {
          // No refresh token, reject the request
          return handler.reject(error);
        }
        
        final refreshResponse = await _dio.post(
          '/api/auth/token/refresh/',
          data: {'refresh': refreshToken},
        );
        
        final newAccessToken = refreshResponse.data['access'] as String;
        await _storage.write(key: _accessTokenKey, value: newAccessToken);
        
        _isRefreshing = false;
        
        // Retry the original request with new token
        final opts = error.requestOptions;
        opts.headers['Authorization'] = 'Bearer $newAccessToken';
        return handler.resolve(await _dio.request(
          opts.path,
          options: Options(
            method: opts.method,
            headers: opts.headers,
          ),
          data: opts.data,
          queryParameters: opts.queryParameters,
        ));
      } catch (e) {
        _isRefreshing = false;
        // Refresh failed, reject the request
        return handler.reject(error);
      }
    } else {
      // Already refreshing, queue this request
      _refreshRequests.add(() async {
        final opts = error.requestOptions;
        final accessToken = await _storage.read(key: _accessTokenKey);
        opts.headers['Authorization'] = 'Bearer $accessToken';
        return handler.resolve(await _dio.request(
          opts.path,
          options: Options(
            method: opts.method,
            headers: opts.headers,
          ),
          data: opts.data,
          queryParameters: opts.queryParameters,
        ));
      });
    }
  }

  Future<String?> getAccessToken() async {
    return await _storage.read(key: _accessTokenKey);
  }

  Future<void> saveTokens(String accessToken, String refreshToken) async {
    await _storage.write(key: _accessTokenKey, value: accessToken);
    await _storage.write(key: _refreshTokenKey, value: refreshToken);
  }

  Future<void> clearTokens() async {
    await _storage.delete(key: _accessTokenKey);
    await _storage.delete(key: _refreshTokenKey);
  }

  // GET request
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (error) {
      if (error.error is AppException) throw error.error! as AppException;
      throw NetworkErrors.fromDioException(error);
    }
  }

  // POST request
  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (error) {
      if (error.error is AppException) throw error.error! as AppException;
      throw NetworkErrors.fromDioException(error);
    }
  }

  // PUT request
  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (error) {
      if (error.error is AppException) throw error.error! as AppException;
      throw NetworkErrors.fromDioException(error);
    }
  }

  // DELETE request
  Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (error) {
      if (error.error is AppException) throw error.error! as AppException;
      throw NetworkErrors.fromDioException(error);
    }
  }

  // PATCH request
  Future<Response> patch(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.patch(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (error) {
      if (error.error is AppException) throw error.error! as AppException;
      throw NetworkErrors.fromDioException(error);
    }
  }
}
