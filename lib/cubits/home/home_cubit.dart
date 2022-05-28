import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import '../../data/models/search_model.dart';
import '../../data/repositories/search_repository.dart';
import '../../data/response/custom_response.dart';
import '../../data/response/status_code.dart';
import '../../helpers/helpers.dart';
import '../cubits.dart';

const List<QuiltedGridTile> gridPattern = [
  QuiltedGridTile(1, 1),
  QuiltedGridTile(1, 1),
  QuiltedGridTile(2, 1),
  QuiltedGridTile(1, 1),
  QuiltedGridTile(1, 1),
  QuiltedGridTile(1, 1),
  QuiltedGridTile(1, 1),
  QuiltedGridTile(1, 1),
  QuiltedGridTile(1, 1),
  QuiltedGridTile(1, 1),
  QuiltedGridTile(1, 1),
  QuiltedGridTile(2, 1),
  QuiltedGridTile(1, 1),
  QuiltedGridTile(1, 1),
  QuiltedGridTile(1, 1),
  QuiltedGridTile(1, 1),
  QuiltedGridTile(1, 1),
  QuiltedGridTile(1, 1),
  QuiltedGridTile(1, 1),
  QuiltedGridTile(1, 1),
  QuiltedGridTile(1, 1),
  QuiltedGridTile(1, 1),
];

class HomeCubit extends Cubit<HomeState> {
  HomeCubit() : super(HomeState(loadStatus: LoadStatus.init, currentPage: 0, loadingMore: false));
  final ISearchRepository searchRepository = SearchRepository();

  final int countPattern = gridPattern.length;

  void initData() async {
    emit(state.copyWith(
      loadStatus: LoadStatus.loading,
    ));
    CustomResponse<List<SearchModel>>? response = await searchRepository.search(limit: countPattern * 3, page: state.currentPage);
   if (response.statusCode == StatusCode.success) {
      emit(
        state.copyWith(
          loadStatus: LoadStatus.loaded,
          contents: response.data,
        ),
      );
    } else if (response.statusCode == StatusCode.requestTimeout) {
      emit(
        state.copyWith(
          loadStatus: LoadStatus.error,
        ),
      );
    } else {}
  }

  void loadMore() async {
    if (state.loadingMore == false) {
      emit(state.copyWith(
        loadingMore: true,
      ));

      await InternetCheckerHelper.checkInternetAccess(
        onDisconnected: () async {
          await Future.delayed(const Duration(milliseconds: 600));
          emit(state.copyWith(
            loadingMore: false,
          ));
        },
        onConnected: () async {
          int page = state.currentPage! + 1;
          CustomResponse<List<SearchModel>> response = await searchRepository.search(limit: countPattern * 3, page: page);
          if (response.statusCode == StatusCode.success) {
            emit(
              state.copyWith(
                loadStatus: LoadStatus.loaded,
                loadingMore: false,
                contents: [
                  ...?state.contents,
                  ...?response.data,
                ],
                currentPage: page,
              ),
            );
          } else if (response.statusCode == StatusCode.requestTimeout) {
            emit(
              state.copyWith(
                loadingMore: false,
                errorStatus: StatusCode.requestTimeout,
              ),
            );
          }
        },
      );
    }
  }
}
