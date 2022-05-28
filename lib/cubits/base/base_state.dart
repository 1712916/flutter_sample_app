import 'package:equatable/equatable.dart';

enum LoadStatus {
  init, loading, loaded, error,
}

abstract class BaseState implements Equatable{
  final LoadStatus? loadStatus;
  final int? errorStatus;

  BaseState({this.loadStatus, this.errorStatus});

  @override
  bool? get stringify => false;
}