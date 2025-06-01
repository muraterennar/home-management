import 'dart:io';

import 'package:dio/dio.dart';
import 'package:home_management/core/error/exceptions.dart';
import 'package:home_management/core/network/network_info.dart';
import 'package:injectable/injectable.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

@lazySingleton
class ApiClient {
  final Dio _dio;
  final NetworkInfo _networkInfo;

  ApiClient(this._dio, this._networkInfo) {
    _dio.options.baseUrl = 'https://api.example.com'; // API URL'nizi buraya ekleyin
    _dio.options.connectTimeout = const Duration(seconds: 10);
    _dio.options.receiveTimeout = const Duration(seconds: 10);
    _dio.options.headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    _dio.interceptors.add(
      PrettyDioLogger(
        requestHeader: true,
        requestBody: true,
        responseBody: true,
        responseHeader: false,
        error: true,
        compact: true,
      ),
    );
  }

  void setAuthToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  void removeAuthToken() {
    _dio.options.headers.remove('Authorization');
  }

  Future<dynamic> get(String path, {Map<String, dynamic>? queryParameters}) async {
    try {
      if (!await _networkInfo.isConnected) {
        throw NetworkException(message: 'İnternet bağlantısı bulunamadı');
      }

      final response = await _dio.get(path, queryParameters: queryParameters);
      return response.data;
    } on DioException catch (e) {
      _handleDioError(e);
    } on SocketException {
      throw NetworkException(message: 'İnternet bağlantısı bulunamadı');
    }
  }

  Future<dynamic> post(String path, {dynamic data}) async {
    try {
      if (!await _networkInfo.isConnected) {
        throw NetworkException(message: 'İnternet bağlantısı bulunamadı');
      }

      final response = await _dio.post(path, data: data);
      return response.data;
    } on DioException catch (e) {
      _handleDioError(e);
    } on SocketException {
      throw NetworkException(message: 'İnternet bağlantısı bulunamadı');
    }
  }

  Future<dynamic> put(String path, {dynamic data}) async {
    try {
      if (!await _networkInfo.isConnected) {
        throw NetworkException(message: 'İnternet bağlantısı bulunamadı');
      }

      final response = await _dio.put(path, data: data);
      return response.data;
    } on DioException catch (e) {
      _handleDioError(e);
    } on SocketException {
      throw NetworkException(message: 'İnternet bağlantısı bulunamadı');
    }
  }

  Future<dynamic> delete(String path, {dynamic data}) async {
    try {
      if (!await _networkInfo.isConnected) {
        throw NetworkException(message: 'İnternet bağlantısı bulunamadı');
      }

      final response = await _dio.delete(path, data: data);
      return response.data;
    } on DioException catch (e) {
      _handleDioError(e);
    } on SocketException {
      throw NetworkException(message: 'İnternet bağlantısı bulunamadı');
    }
  }

  void _handleDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        throw NetworkException(message: 'Bağlantı zaman aşımına uğradı');
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        final data = e.response?.data;
        String message = 'Bir hata oluştu';

        if (data != null && data is Map<String, dynamic>) {
          message = data['message'] ?? message;
        }

        if (statusCode == 401) {
          throw AuthException(message: message, statusCode: statusCode);
        } else if (statusCode == 422) {
          Map<String, String>? errors;
          if (data != null && data is Map<String, dynamic> && data['errors'] != null) {
            errors = Map<String, String>.from(data['errors']);
          }
          throw ValidationException(message: message, errors: errors);
        } else {
          throw ServerException(message: message, statusCode: statusCode);
        }
      case DioExceptionType.cancel:
        throw ServerException(message: 'İstek iptal edildi');
      case DioExceptionType.unknown:
      default:
        if (e.error is SocketException) {
          throw NetworkException(message: 'İnternet bağlantısı bulunamadı');
        }
        throw ServerException(message: e.message ?? 'Bir hata oluştu');
    }
  }
}