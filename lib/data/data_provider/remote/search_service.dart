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

  SearchQueryModel({required this.url, this.limit, this.page, this.orderType, this.imageTypes});
}

class ISearchService {}

class SearchService {
  Future<CustomResponse<List<SearchModel>>> search({int? limit, int? page, OrderType? order = OrderType.desc, List<ImageType>? imageTypes}) async {
    final response = await compute<SearchQueryModel, CustomResponse<List<SearchModel>>>(
      searchIsolate,
      SearchQueryModel(
        url: ApiPath.searchAndPagination.getPath(),
        limit: limit,
        page: page,
        orderType: order,
        imageTypes: imageTypes,
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
    'page': searchQueryModel.page ?? 0,
    'order': _order,
    'mime_types': mimeTypesString,
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
