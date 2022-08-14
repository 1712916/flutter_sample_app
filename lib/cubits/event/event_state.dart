import '../../data/data.dart';
import '../base/base.dart';

class EventState extends BaseState implements Copyable<EventState> {

  final String? data;

  EventState({this.data});

  @override
  EventState copy() {
    return this;
  }

  @override
  EventState copyWith({String? data}) {
    return EventState(
      data: data ?? this.data,
    );
  }

  @override
  List<Object?> get props => [
    data,
  ];
}