import '../../data/data.dart';
import '../base/base.dart';

class GameState extends BaseState implements Copyable<GameState> {
  GameState({
    LoadStatus? loadStatus,
    int? errorStatus,
  }) : super(loadStatus: loadStatus, errorStatus: errorStatus);

  @override
  GameState copy() {
    return this;
  }

  @override
  GameState copyWith({
    LoadStatus? loadStatus,
    int? errorStatus,
  }) {
    return GameState(
      loadStatus: loadStatus ?? this.loadStatus,
      errorStatus: errorStatus ?? this.errorStatus,
    );
  }

  @override
  List<Object?> get props => [
        loadStatus,
        errorStatus,
      ];
}
