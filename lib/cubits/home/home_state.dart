import '../../data/data.dart';
import '../cubits.dart';

class HomeState extends BaseState implements Copyable<HomeState> {
  final Set<SearchModel>? contents;
  final int? currentPage;
  final bool? loadingMore;

  HomeState({
    LoadStatus? loadStatus,
    int? errorStatus,
    this.contents,
    this.currentPage,
    this.loadingMore,
  }) : super(loadStatus: loadStatus, errorStatus: errorStatus);

  @override
  List<Object?> get props => [
        loadStatus,
        contents.hashCode,
        currentPage,
        loadingMore,
        errorStatus,
      ];

  @override
  HomeState copy() {
    return this;
  }

  @override
  HomeState copyWith({
    LoadStatus? loadStatus,
    Set<SearchModel>? contents,
    int? currentPage,
    bool? loadingMore,
    int? errorStatus,
  }) {
    return HomeState(
      loadStatus: loadStatus ?? this.loadStatus,
      contents: contents ?? this.contents,
      currentPage: currentPage ?? this.currentPage,
      loadingMore: loadingMore ?? this.loadingMore,
      errorStatus: errorStatus,
    );
  }
}
