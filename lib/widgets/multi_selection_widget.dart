import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_sample_app/cubits/cubits.dart';

class MultiSelectionWidget<T> extends StatefulWidget {
  final List<T> list;
  final Set<int> currentSelects;
  final Widget Function(T) itemBuilder;
  final Widget Function(T) selectedBuilder;
  final Function(int)? onChange;
  final Function(Set<int>)? onListChange;
  final bool? canEmpty;

  const MultiSelectionWidget({
    Key? key,
    required this.list,
    required this.currentSelects,
    required this.itemBuilder,
    required this.selectedBuilder,
    this.onChange,
    this.onListChange,
    this.canEmpty = false,
  }) : super(key: key);

  @override
  _MultiSelectionWidgetState<T> createState() => _MultiSelectionWidgetState<T>();
}

class _MultiSelectionWidgetState<T> extends State<MultiSelectionWidget<T>> {
  late Set<int> _currentSelected;

  @override
  void initState() {
    _currentSelected = widget.currentSelects;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: widget.list.length,
      itemBuilder: (context, index) {
        final item = widget.list[index];
        return GestureDetector(
          onTap: () {
            if (_currentSelected.contains(index)) {
              if ((widget.canEmpty!) || _currentSelected.length > 1) {
                _currentSelected.remove(index);
              }
            } else {
              _currentSelected.add(index);
            }
            widget.onListChange?.call(_currentSelected);
            widget.onChange?.call(index);
            setState(() {});
          },
          child: _currentSelected.contains(index) ? widget.selectedBuilder(item) : widget.itemBuilder(item),
          // child: Row(
          //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //   children: [
          //   Text('ALO'),
          //   Container(
          //       height: 10,
          //       width: 10,
          //       color: Colors.cyanAccent),
          // ],),
        );
      },
    );
  }
}

class MultiSelectionItem extends StatelessWidget {
  final String title;
  final bool isSelected;

  const MultiSelectionItem({
    Key? key,
    required this.title,
    required this.isSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colors = context.read<ThemeCubit>().getColors;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
      margin: const EdgeInsets.only(bottom: 10),
      color: isSelected ? colors.focusColor : Colors.grey.shade200,
      child: Row(
        children: [
          Container(
            width: 20,
            height: 20,
            padding: const EdgeInsets.all(4),
            margin: const EdgeInsets.only(right: 10),
            decoration: BoxDecoration(border: Border.all(color: colors.accentColor)),
            child: CircleAvatar(backgroundColor: isSelected ? colors.accentColor : Colors.transparent),
          ),
          Expanded(
              child: Text(
            title,
            style: Theme.of(context).textTheme.headline6?.copyWith(
              color: Colors.black54
            ),
          )),
        ],
      ),
    );
  }
}
