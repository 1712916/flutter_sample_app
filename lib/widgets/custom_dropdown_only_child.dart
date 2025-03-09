import 'package:flutter/material.dart';

class OnlyChildDropdownButton extends StatefulWidget {
  final Widget child;
  final Widget dropdownBuilder;
  final VoidCallback? onTap;
  final BoxConstraints? constraints;
  final bool hideDecoration;
  final BorderRadius? borderRadius;
  final Color dropdownBackgroundColor;

  const OnlyChildDropdownButton({
    Key? key,
    required this.child,
    required this.dropdownBuilder,
    this.onTap,
    this.constraints,
    this.hideDecoration = false,
    this.borderRadius,
    this.dropdownBackgroundColor = Colors.white,
  }) : super(key: key);

  @override
  State<OnlyChildDropdownButton> createState() => _OnlyChildDropdownButtonState();
}

class _OnlyChildDropdownButtonState extends State<OnlyChildDropdownButton> with TickerProviderStateMixin {
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  late AnimationController _animationController;
  late Animation<double> _expandAnimation;
  bool _isOpen = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _expandAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  void _toggleDropdown() {
    if (_isOpen) {
      _closeDropdown();
    } else {
      _openDropdown();
    }
  }

  void _openDropdown() {
    _overlayEntry = _createOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);
    _animationController.forward();
    _isOpen = true;
  }

  void _closeDropdown() {
    _animationController.reverse().then((_) {
      _overlayEntry?.remove();
      _overlayEntry = null;
      _isOpen = false;
    });
  }

  OverlayEntry _createOverlayEntry() {
    RenderBox renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;
    final offset = renderBox.localToGlobal(Offset.zero);

    return OverlayEntry(
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: _closeDropdown,
            child: Stack(
              children: [
                Positioned(
                  left: offset.dx,
                  top: offset.dy + size.height + 8,
                  width: 150,
                  child: CompositedTransformFollower(
                    link: _layerLink,
                    showWhenUnlinked: false,
                    offset: Offset(-70 / 2, size.height + 8),
                    child: Material(
                      color: Colors.transparent,
                      child: SizeTransition(
                        axisAlignment: 1,
                        sizeFactor: _expandAnimation,
                        child: Container(
                          constraints: widget.constraints ?? BoxConstraints(maxHeight: 200),
                          decoration: BoxDecoration(
                            color: widget.dropdownBackgroundColor,
                            borderRadius: widget.borderRadius ?? BorderRadius.circular(8),
                            boxShadow: const [
                              BoxShadow(color: Colors.black26, blurRadius: 6),
                            ],
                          ),
                          child: widget.dropdownBuilder,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          _toggleDropdown();
          widget.onTap?.call();
        },
        child: widget.child,
      ),
    );
  }

  @override
  void dispose() {
    if (_overlayEntry?.mounted ?? false) {
      _overlayEntry?.remove();
      _overlayEntry?.dispose();
    }
    _animationController.dispose();
    super.dispose();
  }
}
