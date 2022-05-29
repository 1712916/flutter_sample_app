import 'package:flutter/material.dart';

class SingleSelectionWidget<T> extends StatefulWidget {
  final List<T>? data;
  final Function(int)? onChoice;
  final int? defaultIndex;
  final Widget Function(T)? buildItemNotSelect;
  final Widget Function(T)? buildItemSelected;

  const SingleSelectionWidget({Key? key, this.data, this.onChoice, this.defaultIndex, this.buildItemNotSelect, this.buildItemSelected}) : super(key: key);

  @override
  _SingleSelectionWidgetState<T> createState() => _SingleSelectionWidgetState<T>();
}

class _SingleSelectionWidgetState<T> extends State<SingleSelectionWidget<T>> {
  late int _currentSelected;

  @override
  void initState() {
    _currentSelected = widget.defaultIndex!;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: widget.data?.length,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () {
            widget.onChoice?.call(index);
            setState(() {
              _currentSelected = index;
            });
          },
          child: _currentSelected == index ? widget.buildItemSelected!(widget.data![index]) : widget.buildItemNotSelect!(widget.data![index]),
        );
      },
    );
  }

  @override
  void didUpdateWidget(covariant SingleSelectionWidget<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_currentSelected != widget.defaultIndex) {
      _currentSelected = widget.defaultIndex!;
      setState(() {});
    }
  }
}

// class SingleChoiceWrapWidget<T> extends StatefulWidget {
//   final List<T>? data;
//   final T? initSelected;
//   final Widget Function(T)? buildItem;
//   final Widget Function(T)? buildSelectedItem;
//   final bool? isFirstDefault;
//   final Function(T)? onSelected;
//
//   const SingleChoiceWrapWidget({
//     Key? key,
//     this.data,
//     this.initSelected,
//     this.buildItem,
//     this.buildSelectedItem,
//     this.onSelected,
//     this.isFirstDefault = false,
//   }) : super(key: key);
//
//   @override
//   _SingleChoiceWrapWidgetState<T> createState() =>
//       _SingleChoiceWrapWidgetState<T>();
// }
//
// class _SingleChoiceWrapWidgetState<T> extends State<SingleChoiceWrapWidget<T>> {
//   late T _currentSelect;
//
//   @override
//   void initState() {
//     _currentSelect = (widget.initSelected ??
//         (widget.isFirstDefault && widget.data?.length > 0)
//         ? widget.data?.first
//         : null)!;
//     widget.onSelected?.call(_currentSelect);
//     super.initState();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     if (widget.data == null || widget.data.isEmpty)
//       return const SizedBox.shrink();
//     final data = widget.data;
//     return Wrap(
//       children: List.generate(data.length, (index) {
//         return GestureDetector(
//           onTap: () {
//             if (_currentSelect != data[index]) {
//               _currentSelect = data[index];
//               widget.onSelected?.call(_currentSelect);
//               setState(() {});
//             }
//           },
//           child: Builder(builder: (context) {
//             if (data[index] == _currentSelect) {
//               return widget.buildSelectedItem(data[index]);
//             }
//             return widget.buildItem(data[index]);
//           }),
//         );
//       }).toList(),
//     );
//   }
//
//   @override
//   void didUpdateWidget(covariant SingleChoiceWrapWidget<T> oldWidget) {
//     super.didUpdateWidget(oldWidget);
//     if (oldWidget.isFirstDefault != widget.isFirstDefault ||
//         oldWidget.data != widget.data ||
//         oldWidget.initSelected != widget.initSelected) {
//       setState(() {});
//     }
//   }
// }
