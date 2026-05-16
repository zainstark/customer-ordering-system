// lib/core/network/dio_client.dart
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:frontend/Core/network/app_exception.dart';
import 'package:frontend/Core/network/errors.dart';
import 'package:frontend/Core/storage/token_storage.dart';

class _QueuedRequest {
  _QueuedRequest(this.requestOptions, this.completer);

  final RequestOptions requestOptions;
  final Completer<Response> completer;
}

class DioClient {
  final Dio _dio;
  final TokenStorage _storage;
  bool _isRefreshing = false;
  final List<_QueuedRequest> _refreshRequests = [];

  VoidCallback? onSessionExpired;

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
          final detailMessage =
              (error.response?.data?['detail'] as String? ?? '').toLowerCase();
          final is403Expired =
              error.response?.statusCode == 403 &&
              (detailMessage.contains('expired') ||
                  detailMessage.contains('invalid') ||
                  detailMessage.contains('token'));

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
    final refreshToken = await _storage.getRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) {
      await _handleSessionExpired();
      return handler.reject(error);
    }

    final completer = Completer<Response>();
    _refreshRequests.add(_QueuedRequest(error.requestOptions, completer));

    if (!_isRefreshing) {
      _isRefreshing = true;
      try {
        final refreshResponse = await _dio.post(
          '/api/auth/token/refresh/',
          data: {'refresh': refreshToken},
        );

        final newAccessToken = refreshResponse.data['access'] as String?;
        if (newAccessToken == null || newAccessToken.isEmpty) {
          throw AppException(
            message: 'Unable to refresh authentication token.',
            statusCode: refreshResponse.statusCode,
          );
        }

        await _storage.write(
          key: TokenStorage.accessTokenKey,
          value: newAccessToken,
        );

        _isRefreshing = false;

        for (final queued in _refreshRequests) {
          try {
            queued.completer.complete(
              await _retryRequest(queued.requestOptions, newAccessToken),
            );
          } catch (retryError) {
            queued.completer.completeError(retryError);
          }
        }
        _refreshRequests.clear();
      } catch (e) {
        _isRefreshing = false;
        for (final queued in _refreshRequests) {
          queued.completer.completeError(e);
        }
        _refreshRequests.clear();
        await _handleSessionExpired();
      }
    }

    try {
      final response = await completer.future;
      return handler.resolve(response);
    } catch (_) {
      return handler.reject(error);
    }
  }

  Future<Response> _retryRequest(RequestOptions requestOptions, String accessToken) {
    final headers = Map<String, dynamic>.from(requestOptions.headers);
    headers['Authorization'] = 'Bearer $accessToken';

    return _dio.request(
      requestOptions.path,
      data: requestOptions.data,
      queryParameters: requestOptions.queryParameters,
      options: Options(
        method: requestOptions.method,
        headers: headers,
        responseType: requestOptions.responseType,
        contentType: requestOptions.contentType,
        sendTimeout: requestOptions.sendTimeout,
        receiveTimeout: requestOptions.receiveTimeout,
        extra: requestOptions.extra,
        followRedirects: requestOptions.followRedirects,
        validateStatus: requestOptions.validateStatus,
      ),
    );
  }

  Future<void> _handleSessionExpired() async {
    await _storage.clearTokens();
    if (onSessionExpired != null) {
      onSessionExpired!();
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
