import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../../http_client/api_client.dart';
import '../../data.dart';
import '../../response/custom_response.dart';
import '../../response/status_code.dart';

class SearchQueryModel {
  final String url;
  final int? limit;
  final int? page;
  final OrderType? orderType;
  final List<ImageType>? imageTypes;
  final String apiKey;

  SearchQueryModel({
    required this.url,
    this.limit,
    this.page,
    this.orderType,
    this.imageTypes,
    required this.apiKey,
  });
}

class ISearchService {}

class SearchService {
  Future<CustomResponse<List<SearchModel>>> search({
    int? limit,
    int? page,
    OrderType? order = OrderType.desc,
    List<ImageType>? imageTypes,
    required String apiKey,
  }) async {
    final response = await compute<SearchQueryModel, CustomResponse<List<SearchModel>>>(
      searchIsolate,
      SearchQueryModel(
        url: ApiPath.searchAndPagination.getPath(),
        limit: limit,
        page: page,
        orderType: order,
        imageTypes: imageTypes,
        apiKey: apiKey,
      ),
    );
    return response;
  }
}

Future<CustomResponse<List<SearchModel>>> searchIsolate(SearchQueryModel searchQueryModel) async {
  List<ImageType> _imageTypes = searchQueryModel.imageTypes ?? ImageType.values;
  String mimeTypesString = _imageTypes.map((e) => e.name).toList().join(',');
  String _order = searchQueryModel.orderType?.name ?? OrderType.desc.name;
  final Response? response = await ApiRequest.call(HttpMethod.get, url: searchQueryModel.url, queryParameters: {
    'limit': searchQueryModel.limit ?? 20,
    if (searchQueryModel.page != null) 'page': searchQueryModel.page,
    'order': _order,
    'mime_types': mimeTypesString,
    // 'api_key': searchQueryModel.apiKey,
  });
  if (response == null) {
    return CustomResponse(statusCode: StatusCode.badRequest); //
  } else if (response.statusCode == StatusCode.requestTimeout) {
    return CustomResponse(statusCode: StatusCode.requestTimeout); //
  } else if (response.statusCode == StatusCode.success) {
    log('response data: ${response.data}');
    final responseData = response.data;
    return CustomResponse<List<SearchModel>>(
      statusCode: response.statusCode,
      // message: responseData['message'],
      data: searchModelsList(responseData),
    );
  }
  return CustomResponse(statusCode: StatusCode.badRequest); //
}
