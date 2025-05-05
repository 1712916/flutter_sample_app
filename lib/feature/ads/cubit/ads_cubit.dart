import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meow_app/main.dart';

class AdsCubit extends Cubit<AdsState> {
  AdsCubit() : super(AdsState(isShow: false));

  void showAds() {
    emit(AdsState(isShow: true));
    //
    appMenuCubit.showMoveDown();
  }

  void hideAds() {
    emit(AdsState(isShow: false));
    appMenuCubit.hideMoveDown();
  }
}

class AdsState {
  final bool isShow;

  AdsState({required this.isShow});
}
