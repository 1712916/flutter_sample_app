import 'package:flutter_bloc/flutter_bloc.dart';

import '../../views/pages/base_page/base_page.dart';
import '../cubits.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit() : super(HomeState(loadStatus: LoadStatus.init));

  void initData() async {
    emit(HomeState(
      loadStatus: LoadStatus.loading,
    ));
    await Future.delayed(const Duration(seconds: 1));
    emit(
      state.copyWith(
        loadStatus: LoadStatus.loaded,
        contents: List.generate(
          20,
          (index) => 'index content: $index',
        ),
      ),
    );
  }

  void loadMore() async {
    emit(
      state.copyWith(
        contents: List.generate(
          40,
              (index) => 'index content: $index',
        ),
      ),
    );
  }
}
