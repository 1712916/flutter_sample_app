import '../../utils/utils.dart';
import '../data.dart';
import '../data_provider/data_provider.dart';
import '../response/custom_response.dart';

abstract class ISearchRepository {
  Future<CustomResponse<List<SearchModel>>> search({int? limit, int? page});
}

class SearchRepository extends ISearchRepository {
  final SearchService _service = SearchService();

  @override
  Future<CustomResponse<List<SearchModel>>> search({int? limit, int? page}) {
    return _service.search(limit: limit, page: page, order: SettingManager.orderType, imageTypes: SettingManager.imageTypes);
  }
}