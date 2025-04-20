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
}

class AppMenuState extends Equatable {
  final bool isShowGridMenu;
  final bool isShowGameMenu;
  final bool isShowShareMenu;

  AppMenuState({
    required this.isShowGridMenu,
    required this.isShowGameMenu,
    required this.isShowShareMenu,
  });

  factory AppMenuState.initial() {
    return AppMenuState(
      isShowGridMenu: true,
      isShowGameMenu: true,
      isShowShareMenu: true,
    );
  }

  AppMenuState copyWith({
    bool? isShowGridMenu,
    bool? isShowGameMenu,
    bool? isShowShareMenu,
  }) {
    return AppMenuState(
      isShowGridMenu: isShowGridMenu ?? this.isShowGridMenu,
      isShowGameMenu: isShowGameMenu ?? this.isShowGameMenu,
      isShowShareMenu: isShowShareMenu ?? this.isShowShareMenu,
    );
  }

  @override
  List<Object?> get props => [
        isShowGridMenu,
        isShowGameMenu,
        isShowShareMenu,
      ];

  bool get isHideAll => !isShowGridMenu && !isShowGameMenu && !isShowShareMenu;
}
