import 'dart:developer';

import 'package:dio/dio.dart';

enum HttpMethod {
  get,
  put,
  post,
  delete,
  option,
}

extension MethodExtensions on HttpMethod {
  String get value => ['GET', 'PUT', 'POST', 'DELETE', 'OPTION'][index];
}

class ApiRequest {
  static final Dio _dio = Dio();

  static int timeOut = 600; //1000 = 1 second

  static Future<Response?> call(
    HttpMethod httpMethod, {
    required String url,
    Map<String, dynamic>? queryParameters,
    dynamic data,
    CancelToken? cancelToken,
    Options? options,
  }) async {
    options ??= Options(headers: {});
    options.method = httpMethod.value;
    options.headers = {
      'Accept': "application/json",
      'Content-type': 'application/json; charset=utf-8',
    };
    options.sendTimeout = timeOut;
    options.receiveTimeout = timeOut;

    log('call api: $url');
    log('call api param: $queryParameters');
    try {
      return await _dio.request(
        url,
        queryParameters: queryParameters,
        data: data,
        cancelToken: cancelToken,
        options: options,
      );
    } catch (e) {
      log('Thrown an exception when call api: $e');
      return null;
    }

  }
}
