import 'package:flutter_bloc/flutter_bloc.dart';

abstract class BaseEvent {
  const BaseEvent();
}

class InitEvent extends BaseEvent {}

class ForceLoadingEvent extends BaseEvent {
  final bool isLoading;

  ForceLoadingEvent({this.isLoading = true});
}

class BaseEventCubit extends Cubit<BaseEvent> {
  BaseEventCubit() : super(InitEvent());
}

class ForceLoadingCubit extends Cubit<ForceLoadingEvent> {
  ForceLoadingCubit() : super(ForceLoadingEvent(isLoading: false));
}