import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter_sample_app/data/api_config.dart';
import 'package:flutter_sample_app/data/response/status_code.dart';

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

enum ApiPath {
  searchAndPagination,
}

extension GetPath on ApiPath {
  String getPath() {
    switch (this) {
      case ApiPath.searchAndPagination:
        return '${ApiConfig.baseUrl}${ApiConfig.searchPath}';
    }
  }
}

class ApiRequest {
  static final Dio _dio = Dio();

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
    } on DioError catch (e) {
      log('Time out: $e');
      return Response(
        requestOptions: RequestOptions(path: url),
        statusCode: StatusCode.requestTimeout,
      );
    } catch (e) {
      log('Thrown an exception when call api: $e');
      return null;
    }
  }
}
