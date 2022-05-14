import 'package:flutter_sample_app/cubits/base/base.dart';

import '../../data/data.dart';
import '../../data/models/search_model.dart';

class HomeState extends BaseState implements Copyable<HomeState> {
  final List<SearchModel>? contents;
  final int? currentPage;
  final bool? loadingMore;

  HomeState({
    LoadStatus? loadStatus,
    this.contents,
    this.currentPage,
    this.loadingMore,
  }) : super(loadStatus: loadStatus);

  @override
  List<Object?> get props => [
        loadStatus,
        contents.hashCode,
        currentPage,
        loadingMore,
      ];

  @override
  HomeState copy() {
    return this;
  }

  @override
  HomeState copyWith({
    LoadStatus? loadStatus,
    List<SearchModel>? contents,
    int? currentPage,
    bool? loadingMore,
  }) {
    return HomeState(
      loadStatus: loadStatus ?? this.loadStatus,
      contents: contents ?? this.contents,
      currentPage: currentPage ?? this.currentPage,
      loadingMore: loadingMore ?? this.loadingMore,
    );
  }
}
