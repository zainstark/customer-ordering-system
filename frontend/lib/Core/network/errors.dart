import 'package:dio/dio.dart';
import 'package:frontend/Core/network/app_exception.dart';

class NetworkErrors {
  NetworkErrors._();

  static AppException fromDioException(DioException error) {
    final statusCode = error.response?.statusCode;
    final serverMessage = _extractMessage(error.response?.data);

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return AppException(
          message: 'Request timeout. Please try again.',
          statusCode: statusCode,
        );
      case DioExceptionType.connectionError:
        return AppException(
          message: 'No internet connection. Please check your network.',
          statusCode: statusCode,
        );
      case DioExceptionType.badCertificate:
        return AppException(
          message: 'Secure connection failed.',
          statusCode: statusCode,
        );
      case DioExceptionType.cancel:
        return AppException(
          message: 'Request was cancelled.',
          statusCode: statusCode,
        );
      case DioExceptionType.badResponse:
        return AppException(
          message: serverMessage ?? _messageFromStatusCode(statusCode),
          statusCode: statusCode,
        );
      case DioExceptionType.unknown:
        return AppException(
          message: serverMessage ?? 'Unexpected network error occurred.',
          statusCode: statusCode,
        );
    }
  }

  static String _messageFromStatusCode(int? statusCode) {
    switch (statusCode) {
      case 400:
        return 'Bad request.';
      case 401:
        return 'Unauthorized request.';
      case 403:
        return 'Access denied.';
      case 404:
        return 'Requested resource not found.';
      case 409:
        return 'Request conflict occurred.';
      case 422:
        return 'Validation failed.';
      case 500:
        return 'Internal server error.';
      case 502:
      case 503:
      case 504:
        return 'Service is temporarily unavailable.';
      default:
        return 'Request failed${statusCode == null ? '' : ' (status: $statusCode)'}.';
    }
  }

  static String? _extractMessage(dynamic data) {
    if (data is String && data.trim().isNotEmpty) return data;
    if (data is Map<String, dynamic>) {
      final dynamic message =
          data['message'] ?? data['error'] ?? data['detail'];
      if (message is String && message.trim().isNotEmpty) return message;
    }
    return null;
  }
}
