import 'package:flutter/material.dart';

import '../../data/data.dart';
import '../base/base.dart';
import 'package:image/image.dart' as imglib;

class GameState extends BaseState implements Copyable<GameState> {
  GameState({
    LoadStatus? loadStatus,
    int? errorStatus,
    this.image,
    this.cells,
    this.isComplete,
  }) : super(loadStatus: loadStatus, errorStatus: errorStatus);

  final imglib.Image? image;
  final List<Widget>? cells;
  final bool? isComplete;

  @override
  GameState copy() {
    return this;
  }

  @override
  GameState copyWith({
    LoadStatus? loadStatus,
    int? errorStatus,
    imglib.Image? image,
    List<Widget>? cells,
    bool? isComplete,
  }) {
    return GameState(
      loadStatus: loadStatus ?? this.loadStatus,
      errorStatus: errorStatus ?? this.errorStatus,
      image: image ?? this.image,
      cells: cells ?? this.cells,
      isComplete: isComplete ?? this.isComplete,
    );
  }

  @override
  List<Object?> get props => [
        loadStatus,
        errorStatus,
        image,
        cells.hashCode,
        isComplete,
      ];
}
