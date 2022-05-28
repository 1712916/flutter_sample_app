import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_sample_app/data/data.dart';

import '../../data/response/custom_response.dart';
import '../../data/response/status_code.dart';
import 'image_list_state.dart';

class ImageListCubit extends Cubit<ImageListState> {
  ImageListCubit() : super(ImageListState());
  final ISearchRepository searchRepository = SearchRepository();

  void initData(SearchModel searchModel) {
    emit(state.copyWith(
      images: [searchModel],
    ));
    randomLoad(5);
  }

  Future randomLoad(int number) async {
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
