import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/data.dart';
import '../../data/response/custom_response.dart';
import '../../data/response/status_code.dart';
import '../../helpers/helpers.dart';
import '../../widgets/widgets.dart';
import 'image_list_state.dart';

class ImageListCubit extends Cubit<ImageListState> {
  ImageListCubit() : super(ImageListState());
  final ISearchRepository searchRepository = SearchRepository();

  void initData(List<SearchModel> searchModels) {
    emit(state.copyWith(
      images: searchModels,
    ));
    loadMore(5);
  }

  Future loadMore(int number) async {
    await InternetCheckerHelper.checkInternetAccess(
      onConnected: () async {
        await _randomLoad(number);
      },
      onDisconnected: () async {
        await Future.delayed(const Duration(milliseconds: 300));
        Toast.makeText(message: 'Please check internet access');
      }
    );
  }

  Future _randomLoad(int number) async {
    CustomResponse<List<SearchModel>> response = await searchRepository.search(limit: number);
    if (response.statusCode == StatusCode.success) {
      emit(
        state.copyWith(
          images: [
            ...?state.images,
            ...?response.data
          ],
        ),
      );
    } else if (response.statusCode == StatusCode.requestTimeout) {

    }
  }
}
