import '../../data/data.dart';
import '../base/base_state.dart';

class MainState extends BaseState implements Copyable<MainState> {
  MainState({
    LoadStatus? loadStatus,
    this.currentPageIndex,
  }) : super(loadStatus: loadStatus);

  final int? currentPageIndex;

  @override
  MainState copy() {
    // TODO: implement copy
    throw UnimplementedError();
  }

  @override
  MainState copyWith() {
    // TODO: implement copyWith
    throw UnimplementedError();
  }

  @override
  // TODO: implement props
  List<Object?> get props => throw UnimplementedError();

}