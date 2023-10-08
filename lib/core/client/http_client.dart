import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../common/utils/base_interceptor.dart';

class HttpsClient {
  late Dio dio;
  late String _baseUrl;
  HttpsClient() {
    BaseOptions options = BaseOptions(
        receiveDataWhenStatusError: true,
        sendTimeout: const Duration(milliseconds: 600 * 1000), //60 seconds
        connectTimeout: const Duration(milliseconds: 600 * 1000), // 60 seconds
        receiveTimeout: const Duration(milliseconds: 600 * 1000)
    );

    dio = Dio(options);

    dio.interceptors..add(LogInterceptor(
        requestBody: !kReleaseMode,
        responseBody: !kReleaseMode,
      ))
      ..add(BaseInterceptor());
    // TODO (@hongquang198) setup baseUrl
    // _baseUrl = getIt<FlavorConfig>().baseUrl;
  }

  /// Sẽ remove hết key-value của query nếu value là String rỗng
  Future<Response<Map<String, dynamic>>> get(
    String endPoint, {
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
    Map<String, String> path = const {},
  }) async {
    String url = _baseUrl + endPoint;
    path.forEach((key, value) {
      url = url.replaceFirst('{$key}', value);
    });
    queryParameters = queryParameters ?? {};
    queryParameters.removeWhere((key, value) {
      if (value == null) {
        return true;
      }
      if (value is! String && value is! bool && value is! int) {
        throw ArgumentError('only support bool || int || string');
      }

      if (value is String && value.isEmpty) {
        return true;
      }

      return false;
    });
    final result = await dio.get<Map<String, dynamic>>(
      url,
      queryParameters: queryParameters,
    );
    return result;
  }

  Future<Response<Map<String, dynamic>>> post(
    String endPoint, {
    Map<String, dynamic> body = const {},
    Map<String, String> path = const {},
  }) async {
    String url = _baseUrl + endPoint;
    path.forEach((key, value) {
      url = url.replaceFirst('{$key}', value);
    });
    final result = await dio.post<Map<String, dynamic>>(
      url,
      data: body,
    );
    return result;
  }

  Future<Response<Map<String, dynamic>> > patch(
    String endPoint, {
    Map<String, dynamic> body = const {},
    Map<String, String> path = const {},
  }) async {
    String url = _baseUrl + endPoint;
    path.forEach((key, value) {
      url = url.replaceFirst('{$key}', value);
    });
    final result = await dio.patch<Map<String, dynamic>>(
      url,
      data: body,
    );
    return result;
  }

  Future<Response<Map<String, dynamic>> > delete(
    String endPoint, {
    Map<String, dynamic> body = const {},
    Map<String, String> path = const {},
  }) async {
    String url = _baseUrl + endPoint;
    path.forEach((key, value) {
      url = url.replaceFirst('{$key}', value);
    });
    final result = await dio.delete<Map<String, dynamic>>(
      url,
      data: body,
    );
    return result;
  }
}
