import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:meow_app/utils/setting.dart';

import '../../data/models/search_model.dart';
import '../../data/repositories/search_repository.dart';
import '../../data/response/custom_response.dart';
import '../../data/response/status_code.dart';
import '../../helpers/helpers.dart';
import '../../views/views.dart';
import '../cubits.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit() : super(HomeState(loadStatus: LoadStatus.init, currentPage: 0, loadingMore: false));
  final ISearchRepository searchRepository = SearchRepository();

  bool _isFirstInit = true;

  void initData() async {
    emit(state.copyWith(
      loadStatus: LoadStatus.loading,
    ));
    await InternetCheckerHelper.checkInternetAccess(
      onConnected: () async {
        await _loadData();
      },
      onDisconnected: () async {
        await Future.delayed(const Duration(milliseconds: 600));
        if (_isFirstInit) {
          await _loadData();
        } else {
          emit(
            state.copyWith(
              loadStatus: LoadStatus.error,
            ),
          );
        }
      },
    );
    _isFirstInit = false;
  }

  Future _loadData() async {
    CustomResponse<List<SearchModel>>? response = await searchRepository.search(limit: GridPattern.list[SettingManager.patternIndex!].length * 3, page: state.currentPage);
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
    } else {
      emit(
        state.copyWith(
          loadStatus: LoadStatus.error,
        ),
      );
    }
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
          await _loadMore();
        },
      );
    }
  }

  Future _loadMore() async {
    int page = state.currentPage! + 1;
    CustomResponse<List<SearchModel>> response = await searchRepository.search(limit: GridPattern.list[SettingManager.patternIndex!].length * 3, page: page);
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
  }
}
