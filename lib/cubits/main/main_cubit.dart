import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_sample_app/cubits/base/base.dart';

import 'main_state.dart';

class MainCubit extends Cubit<MainState> {
  MainCubit() : super(MainState(loadStatus: LoadStatus.init));

}