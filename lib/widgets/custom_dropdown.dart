import 'package:flutter/material.dart';
import 'package:meow_app/resources/theme/theme_data.dart';

class CustomDropdownButton<T> extends StatefulWidget {
  final int? initial;
  final List<T> items;
  final ValueChanged<int>? onChange;
  final Widget Function(T item, bool isSelected) itemBuilder;
  final Widget Function(T? item) title;
  final VoidCallback? onTap;
  final BoxConstraints? constraints;
  final bool isError;
  final bool hideDecoration;

  CustomDropdownButton({
    Key? key,
    this.initial,
    required this.items,
    required this.itemBuilder,
    required this.title,
    this.onChange,
    this.onTap,
    this.constraints,
    this.isError = false,
    this.hideDecoration = false,
  }) : super(key: key) {
    if (initial != null) {
      assert(initial! <= items.length);
    }
  }

  @override
  State<CustomDropdownButton<T>> createState() => _CustomDropdownButtonState<T>();
}

class _CustomDropdownButtonState<T> extends State<CustomDropdownButton<T>> {
  final ValueNotifier<bool> _openNotifier = ValueNotifier(false);
  late ValueNotifier<int?> _currentIndexNotifier;
  late final ScrollController _scrollController;

  GlobalKey? _selectedItemKey;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _currentIndexNotifier = ValueNotifier(widget.initial);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return _DropDownOverlayView(
      constraints: widget.constraints,
      openNotifier: _openNotifier,
      getSelectedKey: () {
        return _selectedItemKey;
      },
      builder: (context) => ValueListenableBuilder<int?>(
        valueListenable: _currentIndexNotifier,
        builder: (_, val, __) => Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: theme.actionBackground,
          ),
          clipBehavior: Clip.none,
          child: Scrollbar(
            thumbVisibility: true,
            controller: _scrollController,
            child: ListView.separated(
              padding: EdgeInsets.zero,
              // physics: const NeverScrollableScrollPhysics(),
              controller: _scrollController,
              shrinkWrap: true,
              itemBuilder: (context, index) {
                final isSelected = index == _currentIndexNotifier.value;
                if (isSelected) {
                  _selectedItemKey = GlobalKey();
                }

                return TextButton(
                  key: isSelected ? _selectedItemKey : null,
                  onPressed: () {
                    if (index == val) {
                      return;
                    }
                    _itemSelected(index);
                  },
                  style: TextButton.styleFrom(
                    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                    padding: EdgeInsets.zero,
                  ),
                  child: widget.itemBuilder(widget.items[index], isSelected),
                );
              },
              separatorBuilder: (BuildContext context, int index) => Divider(
                height: 2,
              ),
              itemCount: widget.items.length,
            ),
          ),
        ),
      ),
      child: widget.hideDecoration
          ? getChild()
          : ValueListenableBuilder<bool>(
              valueListenable: _openNotifier,
              builder: (_, val, __) {
                return Center(
                  child: GestureDetector(
                    onTap: () async {
                      _openNotifier.value = !val;
                      widget.onTap?.call();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(40),
                        color: theme.actionBackground,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          getChild(),
                          const SizedBox(width: 8),
                          AnimatedRotation(
                            turns: val ? 0.5 : 0.0,
                            duration: const Duration(milliseconds: 300),
                            child: Icon(
                              Icons.keyboard_arrow_down_outlined,
                              size: 20,
                              color: theme.iconColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }

  void _itemSelected(int index) {
    _currentIndexNotifier.value = index;
    _openNotifier.value = false;
    widget.onChange?.call(index);
  }

  @override
  void dispose() {
    _openNotifier.dispose();
    _currentIndexNotifier.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Widget getChild() {
    return widget.title(_currentIndexNotifier.value != null ? widget.items[_currentIndexNotifier.value!] : null);
  }
}

class _DropDownOverlayView extends StatefulWidget {
  final Widget child;
  final ValueChanged<bool>? onToggle;
  final BorderRadius? borderRadius;
  final Color bgColor;
  final Color? borderColor;
  final double? elevation;
  final WidgetBuilder? builder;
  final EdgeInsetsGeometry padding;
  final BoxConstraints? constraints;
  final ValueNotifier<bool> openNotifier;

  //use max height of content
  final bool showMaxHeight;

  //set max height for content
  final double maxHeight;

  final GlobalKey? Function() getSelectedKey;

  const _DropDownOverlayView({
    Key? key,
    required this.child,
    this.onToggle,
    this.borderRadius,
    this.bgColor = const Color(0xFFFFFFFF),
    this.borderColor,
    this.elevation,
    this.builder,
    this.constraints,
    required this.openNotifier,
    this.padding = const EdgeInsets.all(10),
    this.showMaxHeight = false,
    this.maxHeight = 250,
    required this.getSelectedKey,
  }) : super(key: key);

  @override
  State<_DropDownOverlayView> createState() => _DropDownOverlayViewState();
}

class _DropDownOverlayViewState extends State<_DropDownOverlayView> with TickerProviderStateMixin {
  final LayerLink _layerLink = LayerLink();
  late final ValueNotifier<bool> _openNotifier;

  late final AnimationController _animationController;
  late final Animation<double> _expandAnimation;

  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    super.initState();
    _openNotifier = widget.openNotifier;
    _animationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    _expandAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _openNotifier.addListener(_animationListener);
  }

  _animationListener() {
    if (_openNotifier.value) {
      _overlayEntry = _createOverlayEntry(context);
      Overlay.of(context)?.insert(_overlayEntry!);
      _animationController.forward();
    } else {
      _animationController.reverse().then((value) {
        if (_overlayEntry?.mounted ?? false) {
          _overlayEntry?.remove();
        }
        _overlayEntry = null;
      });
    }
    widget.onToggle?.call(_openNotifier.value);
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () => _toggle(),
        child: widget.child,
      ),
    );
  }

  void _toggle() {
    if (mounted) {
      if (_animationController.isAnimating) {
        return;
      }
      _openNotifier.value = !_openNotifier.value;
    }
  }

  @override
  void dispose() {
    if (_overlayEntry?.mounted ?? false) {
      _overlayEntry?.remove();
      _overlayEntry?.dispose();
    }
    _animationController.dispose();
    _openNotifier.removeListener(_animationListener);
    super.dispose();
  }

  OverlayEntry _createOverlayEntry(BuildContext context) {
    RenderBox? renderBox = context.findRenderObject() as RenderBox?;
    final size = renderBox?.size ?? const Size(0, 0);
    final offset = renderBox?.localToGlobal(Offset.zero) ?? const Offset(0, 0);
    final topOffset = offset.dy + size.height + 5;
    final sz = MediaQuery.of(context).size;
    final overlayOffset = Offset(0, size.height);

    try {
      if (sz.height - offset.dy < 300) {
        Scrollable.ensureVisible(
          context,
          duration: const Duration(milliseconds: 350),
          curve: Curves.bounceIn,
        );
      }
    } catch (e) {}

    return OverlayEntry(
      builder: (context) => GestureDetector(
        onTap: () => _toggle(),
        behavior: HitTestBehavior.translucent,
        child: CompositedTransformFollower(
          offset: overlayOffset,
          link: _layerLink,
          showWhenUnlinked: false,
          child: Stack(
            clipBehavior: Clip.none,
            fit: StackFit.expand,
            children: [
              Positioned(
                left: -offset.dx,
                width: sz.width,
                child: Material(
                  type: MaterialType.transparency,
                  clipBehavior: Clip.none,
                  elevation: 0,
                  child: SizeTransition(
                    axisAlignment: 1,
                    sizeFactor: _expandAnimation,
                    child: DropDownContainer(
                      padding: widget.padding,
                      maxHeight: widget.maxHeight,
                      showMaxHeight: widget.showMaxHeight,
                      builder: widget.builder,
                      constraints: widget.constraints,
                      size: size,
                      offset: offset,
                      getSelectedKey: widget.getSelectedKey,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DropDownContainer extends StatefulWidget {
  const DropDownContainer({
    super.key,
    required this.size,
    required this.offset,
    this.builder,
    required this.padding,
    this.constraints,
    required this.showMaxHeight,
    required this.maxHeight,
    required this.getSelectedKey,
  });

  final Size size;
  final Offset offset;
  final WidgetBuilder? builder;
  final EdgeInsetsGeometry padding;
  final BoxConstraints? constraints;

  //use max height of content
  final bool showMaxHeight;

  //set max height for content
  final double maxHeight;

  final GlobalKey? Function() getSelectedKey;

  @override
  State<DropDownContainer> createState() => _DropDownContainerState();
}

class _DropDownContainerState extends State<DropDownContainer> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      final key = widget.getSelectedKey();

      if (key != null) {
        try {
          Scrollable.ensureVisible(key.currentContext!);
        } catch (e) {}
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.size.width,
      margin: EdgeInsets.fromLTRB(widget.offset.dx, 4, 0, widget.offset.dx),
      constraints: widget.constraints ??
          BoxConstraints(
            minHeight: 40,
            maxHeight: widget.showMaxHeight ? double.infinity : widget.maxHeight,
          ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
      ),
      child: widget.builder?.call(context) ?? const SizedBox.shrink(),
    );
  }
}
