import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_sample_app/cubits/event/event.dart';

class EventCubit extends Cubit<EventState> {
  EventCubit( ) : super(EventState());


  void addText(String text) {
    emit(state.copyWith(data: text));
  }
}