import 'package:equatable/equatable.dart';

enum LoadStatus {
  init, loading, loaded, error,
}

abstract class BaseState implements Equatable{
  final LoadStatus? loadStatus;

  BaseState({this.loadStatus});

  @override
  bool? get stringify => false;
}