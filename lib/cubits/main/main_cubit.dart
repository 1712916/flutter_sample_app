import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubits.dart';
import 'main_state.dart';

class MainCubit extends Cubit<MainState> {
  MainCubit() : super(MainState(loadStatus: LoadStatus.init));

}