import 'package:dio/dio.dart';

import '../../../http_client/api_client.dart';
import '../../data.dart';
import '../../response/custom_response.dart';
import '../../response/status_code.dart';

class ISearchService {}

class SearchService {
  Future<CustomResponse<List<SearchModel>>> search({int? limit, int? page, OrderType? order = OrderType.desc, List<ImageType>? imageTypes}) async {
    List<ImageType> _imageTypes =  imageTypes ?? ImageType.values;
    String mimeTypesString = _imageTypes.map((e) => e.name).toList().join(',');
    String _order = order?.name ?? OrderType.desc.name;
    final Response? response = await ApiRequest.call(HttpMethod.get, url: ApiPath.searchAndPagination.getPath(), queryParameters: {
      'limit': limit ?? 20,
      'page': page ?? 0,
      'order': _order,
      'mime_types': mimeTypesString,
    });
    if (response == null) {}
    else if (response.statusCode == StatusCode.requestTimeout) {
      return CustomResponse(statusCode: StatusCode.requestTimeout); //
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
