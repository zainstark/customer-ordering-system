// lib/core/network/dio_client.dart
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:frontend/Core/network/app_exception.dart';
import 'package:frontend/Core/network/errors.dart';
import 'package:frontend/Core/storage/token_storage.dart';

class DioClient {
  final Dio _dio;
  final TokenStorage _storage;
  bool _isRefreshing = false;
  final List<Function> _refreshRequests = [];

  DioClient(this._storage)
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
          final accessToken = await _storage.getAccessToken();
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
          debugPrint(
            '✅ RESPONSE: ${response.statusCode} ${response.requestOptions.path}',
          );
          debugPrint('   Data: ${response.data}');
          return handler.next(response);
        },
        onError: (error, handler) async {
          debugPrint('❌ ERROR: ${error.type} - ${error.message}');
          debugPrint('   Path: ${error.requestOptions.path}');
          debugPrint('   Status: ${error.response?.statusCode}');
          debugPrint('   Response: ${error.response?.data}');

          // Handle token expiration and refresh
          final is401 = error.response?.statusCode == 401;
          final is403Expired =
              error.response?.statusCode == 403 &&
              (error.response?.data?['detail'] as String? ?? '')
                  .toLowerCase()
                  .contains('expired');

          if ((is401 || is403Expired) &&
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

  Future<dynamic> _handleTokenExpiry(
    DioException error,
    ErrorInterceptorHandler handler,
  ) async {
    if (!_isRefreshing) {
      _isRefreshing = true;
      try {
        final refreshToken = await _storage.getRefreshToken();
        if (refreshToken == null) {
          _isRefreshing = false; // ← Bug 2 fix
          return handler.reject(error);
        }

        final refreshResponse = await _dio.post(
          '/api/auth/token/refresh/',
          data: {'refresh': refreshToken},
        );

        final newAccessToken = refreshResponse.data['access'] as String;
        await _storage.write(
          key: TokenStorage.accessTokenKey,
          value: newAccessToken,
        );

        _isRefreshing = false;

        // ← Bug 1 fix: drain the queue
        for (final retryRequest in _refreshRequests) {
          retryRequest();
        }
        _refreshRequests.clear();

        // Retry the original request
        final opts = error.requestOptions;
        opts.headers['Authorization'] = 'Bearer $newAccessToken';
        return handler.resolve(
          await _dio.request(
            opts.path,
            options: Options(method: opts.method, headers: opts.headers),
            data: opts.data,
            queryParameters: opts.queryParameters,
          ),
        );
      } catch (e) {
        _isRefreshing = false;
        _refreshRequests.clear(); // ← don't leave stale requests on failure
        return handler.reject(error);
      }
    } else {
      _refreshRequests.add(() async {
        final opts = error.requestOptions;
        final accessToken = await _storage.getAccessToken();
        opts.headers['Authorization'] = 'Bearer $accessToken';
        return handler.resolve(
          await _dio.request(
            opts.path,
            options: Options(method: opts.method, headers: opts.headers),
            data: opts.data,
            queryParameters: opts.queryParameters,
          ),
        );
      });
    }
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
