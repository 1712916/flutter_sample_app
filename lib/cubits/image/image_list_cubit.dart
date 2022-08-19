import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/data.dart';
import '../../data/response/custom_response.dart';
import '../../data/response/status_code.dart';
import '../../helpers/helpers.dart';
import '../../resources/resources.dart';
import '../../widgets/widgets.dart';
import 'image_list_state.dart';
const imageListLimit = 10;

class ImageListCubit extends Cubit<ImageListState> {
  ImageListCubit() : super(ImageListState());
  final ISearchRepository searchRepository = SearchRepository();

  int _page = 0;

  void initData(List<SearchModel> searchModels) {
    emit(state.copyWith(
      images: searchModels,
    ));
    loadMore(imageListLimit);
  }

  Future loadMore(int number) async {
    await InternetCheckerHelper.checkInternetAccess(
      onConnected: () async {
        await _randomLoad(number);
      },
      onDisconnected: () async {
        await Future.delayed(const Duration(milliseconds: 300));
        Toast.makeText(message: LocaleKeys.checkInternetAccess.tr());
      }
    );
  }

  Future _randomLoad(int number) async {
    CustomResponse<List<SearchModel>> response = await searchRepository.search(limit: number, page: _page);
    if (response.statusCode == StatusCode.success) {
      emit(
        state.copyWith(
          images: [
            ...?state.images,
            ...?response.data
          ],
        ),
      );
      _page++;
    } else if (response.statusCode == StatusCode.requestTimeout) {
      Toast.makeText(message: LocaleKeys.timeOutMessage.tr());
    } else {
      Toast.makeText(message: LocaleKeys.haveAnError.tr());
    }
  }
}
