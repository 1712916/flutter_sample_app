import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../data/data.dart';
import '../../../../data/response/status_code.dart';
import '../../../../widgets/widgets.dart';
import '../../../core/index.dart';

part 'image_list_state.dart';

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

  Future init() {
    return _randomLoad(imageListLimit, retry: true);
  }

  Future loadMore(int number) async {
    await InternetCheckerHelper.checkInternetAccess(onConnected: () async {
      await _randomLoad(number, retry: true);
    }, onDisconnected: () async {
      Toast.makeText(message: LKey.checkInternetAccess.tr());
      await Future.delayed(const Duration(milliseconds: 300));
    });
  }

  Future<void> _randomLoad(int number, {bool retry = false}) async {
    try {
      final response = await searchRepository.search(
        limit: number,
        page: _page,
      );

      if (response.statusCode == StatusCode.success) {
        if (!isClosed) {
          emit(
            state.copyWith(
              images: List.from(
                Set.from([...?state.images, ...?response.data]),
              ),
              loadStatus: LoadStatus.loaded,
            ),
          );
        }
        _page++;
        return;
      }

      if (retry) {
        await _randomLoad(number);
      } else {
        _handleError(response.statusCode ?? 0);
      }
    } catch (e, stackTrace) {
      // Log lỗi để dễ debug hơn
      debugPrint('Error in _randomLoad: $e\n$stackTrace');
      if (!retry) {
        Toast.makeText(message: LKey.haveAnError.tr());
      }
    }
  }

  void _handleError(int statusCode) {
    switch (statusCode) {
      case StatusCode.requestTimeout:
        Toast.makeText(message: LKey.timeOutMessage.tr());
        break;
      default:
        Toast.makeText(message: LKey.haveAnError.tr());
        break;
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

  void switchView(bool isMeow) async {
    SettingManager.isMeow = isMeow;
    await SettingManager.save();
    refreshData();
  }

  Future refreshData() async {
    emit(state.copyWith(images: [], loadStatus: LoadStatus.loading));
    _page = 0;
    currentIndex = 0;
    pageController?.dispose();
    pageController = PageController(initialPage: currentIndex);
    return init();
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
    } catch (e) {}
  }
}
