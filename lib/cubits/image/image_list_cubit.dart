import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meow_app/cubits/base/base_state.dart';

import '../../data/data.dart';
import '../../data/response/custom_response.dart';
import '../../data/response/status_code.dart';
import '../../resources/resources.dart';
import '../../utils/utils.dart';
import '../../widgets/widgets.dart';
import 'image_list_state.dart';

const imageListLimit = 30;

class ImageListCubit extends Cubit<ImageListState> {
  ImageListCubit() : super(ImageListState.init());
  final ISearchRepository searchRepository = SearchRepository();
  int _page = 0;

  final GlobalKey<NavigatorState> navKey = GlobalKey<NavigatorState>();
  PageController? pageController;
  String? get currentUrl => currentImage?.url;

  SearchModel? get currentImage => state.images?[currentIndex];

  int currentIndex = 0;

  void initData(List<SearchModel> searchModels) {
    emit(state.copyWith(
      images: searchModels,
      loadStatus: LoadStatus.init,
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
            loadStatus: LoadStatus.loaded,
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
    currentIndex = index;
    if (pageController != null) {
      pageController!.dispose();
      pageController = null;
    }

    pageController = PageController(initialPage: currentIndex);
    navKey.currentState!.pushNamed(state.viewType.path, arguments: index);
  }

  void switchToCat() async {
    SettingManager.isMeow = true;
    await SettingManager.save();
    refreshData();
  }

  void switchToDog() async {
    SettingManager.isMeow = false;
    await SettingManager.save();
    refreshData();
  }

  void refreshData() {
    emit(state.copyWith(images: [], loadStatus: LoadStatus.loading));
    _page = 0;
    currentIndex = 0;
    pageController?.dispose();
    pageController = PageController(initialPage: currentIndex);
    init();
  }

  @override
  Future<void> close() {
    pageController?.dispose();
    return super.close();
  }

  void onDelete() {
    //remove current index
    try {
      final List<SearchModel> images = state.images?.toList() ?? [];
      images.removeAt(currentIndex);
      emit(state.copyWith(images: images));
    } catch (e) {
      print(e);
    }
  }
}
