import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/data.dart';
import '../../data/response/custom_response.dart';
import '../../data/response/status_code.dart';
import '../../helpers/helpers.dart';
import '../../resources/resources.dart';
import '../../widgets/widgets.dart';
import 'image_list_state.dart';

const imageListLimit = 30;

class ImageListCubit extends Cubit<ImageListState> {
  ImageListCubit() : super(ImageListState.init());
  final ISearchRepository searchRepository = SearchRepository();
  final PageController controller = PageController();
  int _page = 0;

  final GlobalKey<NavigatorState> navKey = GlobalKey<NavigatorState>();

  String? get currentUrl => currentImage?.url;

  SearchModel? currentImage = null;

  void setCurrentImage(SearchModel? image) {
    currentImage = image;
  }

  void initData(List<SearchModel> searchModels) {
    emit(state.copyWith(
      images: searchModels,
    ));
    loadMore(imageListLimit);
  }

  Future loadMore(int number) async {
    await InternetCheckerHelper.checkInternetAccess(onConnected: () async {
      await _randomLoad(number);
    }, onDisconnected: () async {
      await Future.delayed(const Duration(milliseconds: 300));
      Toast.makeText(message: LocaleKeys.checkInternetAccess.tr());
    });
  }

  Future _randomLoad(int number) async {
    CustomResponse<List<SearchModel>> response = await searchRepository.search(limit: number, page: _page);
    if (response.statusCode == StatusCode.success) {
      if (!isClosed) {
        emit(
          state.copyWith(
            images: [...?state.images, ...?response.data].toSet().toList(),
          ),
        );
      }
      _page++;
    } else if (response.statusCode == StatusCode.requestTimeout) {
      Toast.makeText(message: LocaleKeys.timeOutMessage.tr());
    } else {
      Toast.makeText(message: LocaleKeys.haveAnError.tr());
    }
  }

  void showGridView() {
    emit(
      state.copyWith(
        viewType: ImageViewType.grid,
      ),
    );
    navKey.currentState!.pop();
  }

  void init() {
    loadMore(imageListLimit);
  }

  void showPageView(int index) {
    emit(
      state.copyWith(
        viewType: ImageViewType.page,
      ),
    );
    navKey.currentState!.pushNamed(state.viewType.path, arguments: index);
  }
}
