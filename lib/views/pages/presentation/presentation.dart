import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:meow_app/cubits/cubits.dart';

class GridPattern {
  static const QuiltedGridTile _sample11 = QuiltedGridTile(1, 1);

  static const List<QuiltedGridTile> gridPatternB = [
    _sample11,
    QuiltedGridTile(2, 2),
    _sample11,
    _sample11,
    _sample11,
    _sample11,
  ];

  static const int gridPatternBLength = 6;

  static const List<QuiltedGridTile> gridPatternC = [
    _sample11,
    _sample11,
    _sample11,
    _sample11,
    _sample11,
    _sample11,
    _sample11,
    _sample11,
    _sample11,
  ];

  static const int gridPatternCLength = 9;

  static const List<QuiltedGridTile> gridPatternD = [
    _sample11,
    _sample11,
    _sample11,
    _sample11,
  ];

  static const int gridPatternDLength = 4;

  static const String lengthKey = 'length';
  static const String patternKey = 'pattern';

  static List<GridPatternModel> list = [
    GridPatternModel(
      gridPattern: [
        _sample11,
        _sample11,
        QuiltedGridTile(2, 1),
        _sample11,
        _sample11,
        _sample11,
        _sample11,
        _sample11,
      ],
      length: 8,
      crossAxisCount: 3,
    ),
    GridPatternModel(
      gridPattern: [
        _sample11,
        QuiltedGridTile(2, 2),
        _sample11,
        _sample11,
        _sample11,
        _sample11,
      ],
      length: 6,
      crossAxisCount: 3,
    ),
    GridPatternModel(
      gridPattern: [
        _sample11,
        _sample11,
        _sample11,
        _sample11,
        _sample11,
        _sample11,
        _sample11,
        _sample11,
        _sample11,
      ],
      length: 9,
      crossAxisCount: 3,
    ),
    GridPatternModel(
      gridPattern: [
        _sample11,
        _sample11,
        _sample11,
        _sample11,
      ],
      length: 4,
      crossAxisCount: 2,
    ),
    GridPatternModel(
      gridPattern: [
        QuiltedGridTile(1, 2),
        _sample11,
        _sample11,
        QuiltedGridTile(1, 2),
      ],
      length: 4,
      crossAxisCount: 3,
    ),
  ];
}

class GridPatternModel {
  final List<QuiltedGridTile> gridPattern;
  final int length;
  final int crossAxisCount;

  GridPatternModel({
    required this.gridPattern,
    required this.length,
    required this.crossAxisCount,
  });
}

class PresentationPage extends StatelessWidget {
  const PresentationPage({
    Key? key,
    required this.gridPattern,
    required this.length,
    this.crossAxisCount = 3,
  }) : super(key: key);

  final List<QuiltedGridTile> gridPattern;
  final int length;
  final int crossAxisCount;

  @override
  Widget build(BuildContext context) {
    return GridView.custom(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      gridDelegate: SliverQuiltedGridDelegate(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: 2,
        crossAxisSpacing: 2,
        repeatPattern: QuiltedGridRepeatPattern.same,
        pattern: gridPattern,
      ),
      childrenDelegate: SliverChildBuilderDelegate(
        (context, index) => Container(
          color: context.read<ThemeCubit>().getColors.accentColor,
        ),
        childCount: length,
      ),
    );
  }
}
