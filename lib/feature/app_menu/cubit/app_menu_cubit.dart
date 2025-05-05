import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AppMenuCubit extends Cubit<AppMenuState> {
  AppMenuCubit() : super(AppMenuState.initial());

  AppMenuState? _previousState;

  @override
  void emit(AppMenuState state) {
    _previousState = this.state;
    super.emit(state);
  }

  void toggleGridMenu() {
    emit(state.copyWith(isShowGridMenu: !state.isShowGridMenu));
  }

  void toggleGameMenu() {
    emit(state.copyWith(isShowGameMenu: !state.isShowGameMenu));
  }

  void toggleShareMenu() {
    emit(state.copyWith(isShowShareMenu: !state.isShowShareMenu));
  }

  void hideAll() {
    emit(state.copyWith(
      isShowGridMenu: false,
      isShowGameMenu: false,
      isShowShareMenu: false,
    ));
  }

  void showForGridView() {
    emit(state.copyWith(
      isShowGridMenu: false,
      isShowGameMenu: true,
      isShowShareMenu: false,
    ));
  }

  void showForPageView() {
    emit(state.copyWith(
      isShowGridMenu: true,
      isShowGameMenu: true,
      isShowShareMenu: true,
    ));
  }

  void previousMenu() {
    if (_previousState != null) {
      emit(_previousState!);
      _previousState = null;
    }
  }

  void showMoveDown() {
    emit(state.copyWith(
      isShowGridMenu: false,
      isShowGameMenu: false,
      isShowShareMenu: false,
      isShowMoveDown: true,
    ));
  }

  void hideMoveDown() {
    emit(state.copyWith(
      isShowGridMenu: true,
      isShowGameMenu: true,
      isShowShareMenu: true,
      isShowMoveDown: false,
    ));
  }
}

class AppMenuState extends Equatable {
  final bool isShowGridMenu;
  final bool isShowGameMenu;
  final bool isShowShareMenu;
  final bool isShowMoveDown;

  AppMenuState({
    required this.isShowGridMenu,
    required this.isShowGameMenu,
    required this.isShowShareMenu,
    required this.isShowMoveDown,
  }) {
    if (isShowMoveDown) {
      //other menu must be false
      assert(!isShowGridMenu && !isShowGameMenu && !isShowShareMenu,
          'If isShowMoveDown is true, all other menus must be false');
    }
  }

  factory AppMenuState.initial() {
    return AppMenuState(
      isShowGridMenu: true,
      isShowGameMenu: true,
      isShowShareMenu: true,
      isShowMoveDown: false,
    );
  }

  AppMenuState copyWith({
    bool? isShowGridMenu,
    bool? isShowGameMenu,
    bool? isShowShareMenu,
    bool? isShowMoveDown,
  }) {
    return AppMenuState(
      isShowGridMenu: isShowGridMenu ?? this.isShowGridMenu,
      isShowGameMenu: isShowGameMenu ?? this.isShowGameMenu,
      isShowShareMenu: isShowShareMenu ?? this.isShowShareMenu,
      isShowMoveDown: isShowMoveDown ?? this.isShowMoveDown,
    );
  }

  @override
  List<Object?> get props => [
        isShowGridMenu,
        isShowGameMenu,
        isShowShareMenu,
        isShowMoveDown,
      ];

  bool get isHideAll => !isShowGridMenu && !isShowGameMenu && !isShowShareMenu;
}
