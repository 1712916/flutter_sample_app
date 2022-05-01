import 'package:flutter_sample_app/cubits/base/base.dart';

import '../../data/data.dart';


class HomeState extends BaseState implements Copyable<HomeState> {
  final List<String>? contents;

  HomeState({
    LoadStatus? loadStatus,
    this.contents,
  }) : super(loadStatus: loadStatus);

  @override
  List<Object?> get props => [loadStatus, contents.hashCode];

  @override
  HomeState copy() {
    return this;
  }

  @override
  HomeState copyWith({LoadStatus? loadStatus, List<String>? contents}) {
    return HomeState(
      loadStatus: loadStatus ?? this.loadStatus,
      contents: contents ?? this.contents,
    );
  }
}

void lol() {
  HomeState homeState = HomeState(
    contents: [],
    loadStatus: LoadStatus.init,
  );
  print('HomeState: ${homeState.loadStatus}');
  HomeState homeStateCP = homeState.copy();
  print('HomeState copy: ${homeStateCP.copy().loadStatus}');
  HomeState homeStateCPW = homeState.copyWith(loadStatus: LoadStatus.loaded);
  print('HomeState copy: ${homeStateCPW.loadStatus}');

}