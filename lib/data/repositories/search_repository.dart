import 'package:flutter_sample_app/data/models/search_model.dart';

import '../data_provider/data_provider.dart';
import '../response/custom_response.dart';

abstract class ISearchRepository {
  Future<CustomResponse<List<SearchModel>>> search({int? limit, int? page, String? order});
}

class SearchRepository extends ISearchRepository {
  final SearchService _service = SearchService();
  @override
  Future<CustomResponse<List<SearchModel>>> search({int? limit, int? page, String? order}) {
    return _service.search(limit: limit, page: page, order: order);
  }
}