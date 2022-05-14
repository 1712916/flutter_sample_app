import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_sample_app/data/models/search_model.dart';
import 'package:flutter_sample_app/http_client/api_client.dart';

import '../../response/custom_response.dart';
import '../../response/status_code.dart';

class ISearchService {}

class SearchService {
  Future<CustomResponse<List<SearchModel>>> search({int? limit, int? page, String? order}) async {
    final Response? response = await ApiRequest.call(HttpMethod.get, url: ApiPath.searchAndPagination.getPath(), queryParameters: {
      'limit': limit ?? 20,
      'page': page ?? 0,
      'order': order ?? 'DESC',
    });
    if (response == null) {
      return CustomResponse(statusCode: StatusCode.badRequest); //
    } else if (response.statusCode == StatusCode.success) {
      print('response data: ${response.data}');
      final responseData = response.data;
      return CustomResponse<List<SearchModel>>(
        statusCode: response.statusCode,
        // message: responseData['message'],
        data: searchModelsList(responseData),
      );
    }
    return CustomResponse(statusCode: StatusCode.badRequest); //

  }
}
