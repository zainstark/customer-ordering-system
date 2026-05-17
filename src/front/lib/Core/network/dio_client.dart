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
          final appException = NetworkErrors.fromDioException(error);
         // If 401, session is dead — clear and notify
         if (error.response?.statusCode == 401 || error.response?.statusCode == 403) {
           await _handleSessionExpired();
         }

         return handler.reject(
           error.copyWith(error: appException, message: appException.message),
         );
        },
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
