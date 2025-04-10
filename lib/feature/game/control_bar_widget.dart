import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meow_app/resources/theme/theme_data.dart';

import 'cubit/game_setting_cubit.dart';
import 'play_area_widget.dart';

class ControlBarWidget extends StatefulWidget {
  const ControlBarWidget({
    super.key,
    required this.onDirectionTap,
    this.iconColor = Colors.white,
    this.duration = const Duration(milliseconds: 400),
    this.barColor,
    this.centerHoleColor,
    this.toggleButtonColor,
  });

  final ValueChanged<Direction> onDirectionTap;
  final Color iconColor;
  final Duration duration;
  final Color? barColor;
  final Color? centerHoleColor;
  final Color? toggleButtonColor;

  @override
  State<ControlBarWidget> createState() => _ControlBarWidgetState();
}

class _ControlBarWidgetState extends State<ControlBarWidget> {
  bool _isVisible = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final barColor = widget.barColor ?? theme.colorScheme.primary;
    final centerHoleColor = widget.centerHoleColor ?? theme.scaffoldBackgroundColor;
    final toggleColor = widget.toggleButtonColor ?? barColor;
    final double size = 120;
    final double iconSize = 30;

    final colors = [
      Colors.cyanAccent,
      Colors.orangeAccent,
      Colors.pinkAccent,
    ].map((e) => e.withOpacity(0.5)).toList();

    final width = MediaQuery.of(context).size.width;

    return Stack(
      children: [
        Align(
          alignment: Alignment.bottomCenter,
          child: AnimatedContainer(
            duration: widget.duration,
            curve: Curves.easeInOut,
            transform: Matrix4.translationValues(_isVisible ? 0 : width / 2 + size / 2, 0, 0),
            width: _isVisible ? size : 0,
            child: GestureDetector(
              onHorizontalDragEnd: _handleSwipeClose,
              child: ClipPath(
                clipper: HoleClipper(),
                child: Container(
                  width: size,
                  height: size,
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      transform: const GradientRotation(2.0),
                      stops: const [0.0, 0.6, 1.0],
                      colors: colors,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      tileMode: TileMode.decal,
                    ),
                    boxShadow: [
                      // BoxShadow(
                      //   color: barColor.withOpacity(0.5),
                      //   blurRadius: 10,
                      //   spreadRadius: 2,
                      // ),
                    ],
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Positioned(
                        top: 0,
                        child: IconButton(
                          icon: Icon(Icons.keyboard_arrow_up, size: iconSize, color: widget.iconColor),
                          onPressed: () => widget.onDirectionTap(Direction.up),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        child: IconButton(
                          icon: Icon(Icons.keyboard_arrow_down, size: iconSize, color: widget.iconColor),
                          onPressed: () => widget.onDirectionTap(Direction.down),
                        ),
                      ),
                      Positioned(
                        left: 0,
                        child: IconButton(
                          icon: Icon(Icons.keyboard_arrow_left, size: iconSize, color: widget.iconColor),
                          onPressed: () => widget.onDirectionTap(Direction.left),
                        ),
                      ),
                      Positioned(
                        right: 0,
                        child: IconButton(
                          icon: Icon(Icons.keyboard_arrow_right, size: iconSize, color: widget.iconColor),
                          onPressed: () => widget.onDirectionTap(Direction.right),
                        ),
                      ),

                      //create a circle in the center with close icon
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        // Toggle button
        AnimatedPositioned(
          duration: widget.duration,
          curve: Curves.easeInOut,
          right: !_isVisible ? 0 : -40,
          child: GestureDetector(
            onTap: () => setState(() => _isVisible = true),
            onHorizontalDragEnd: _handleSwipeToOpen,
            child: Container(
              height: 80,
              width: 30,
              alignment: Alignment.centerRight,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.horizontal(left: Radius.circular(20)),
                gradient: LinearGradient(
                  colors: colors,
                  stops: const [0.0, 0.8, 1.0],
                  begin: Alignment.topCenter,
                  end: Alignment.centerRight,
                ),
              ),
              child: Icon(Icons.chevron_left, color: widget.iconColor),
            ),
          ),
        ),
      ],
    );
  }

  void _handleSwipeClose(DragEndDetails details) {
    final velocity = details.primaryVelocity ?? 0;
    setState(() {
      if (velocity > 0) {
        _isVisible = false;
      } else if (velocity < 0) {
        _isVisible = true;
      }
    });
  }

  void _handleSwipeToOpen(DragEndDetails details) {
    setState(() {
      _isVisible = true;
    });
  }
}

class ControlBarWrapper extends StatefulWidget {
  const ControlBarWrapper({
    super.key,
    required this.onDirectionTap,
    this.iconColor = Colors.white,
    this.duration = const Duration(milliseconds: 350),
    this.centerHoleColor,
    this.toggleButtonColor,
    required this.child,
  });

  final ValueChanged<Direction> onDirectionTap;
  final Color iconColor;
  final Duration duration;
  final Color? centerHoleColor;
  final Color? toggleButtonColor;
  final Widget child;

  @override
  State<ControlBarWrapper> createState() => _ControlBarWrapperState();
}

class _ControlBarWrapperState extends State<ControlBarWrapper> with WidgetsBindingObserver {
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);

    super.initState();

    _focusNode.addListener(_handleFocusChanged);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _handleFocusChanged();
    });
  }

  void _handleFocusChanged() {
    if (!_focusNode.hasFocus) {
      _focusNode.requestFocus();
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocusChanged);
    _focusNode.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      _handleFocusChanged();
    }
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardListener(
      focusNode: _focusNode,
      autofocus: true,
      onKeyEvent: _handleKeyPress,
      child: BlocSelector<GameSettingCubit, GameSettingState, bool>(
        selector: (state) => state.gameController,
        builder: (context, isShow) {
          if (!isShow) {
            return widget.child;
          }

          return Stack(
            fit: StackFit.loose,
            children: [
              widget.child,
              Positioned(
                bottom: 40,
                left: 0,
                right: 0,
                child: ControlBarWidget(
                  onDirectionTap: widget.onDirectionTap,
                  iconColor: widget.iconColor,
                  duration: widget.duration,
                  barColor: Theme.of(context).highlightColor2,
                  centerHoleColor: widget.centerHoleColor,
                  toggleButtonColor: widget.toggleButtonColor,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _handleKeyPress(KeyEvent event) {
    if (event is KeyDownEvent) {
      final data = event.logicalKey;

      if (data == LogicalKeyboardKey.arrowUp) {
        widget.onDirectionTap(Direction.up);
      } else if (data == LogicalKeyboardKey.arrowDown) {
        widget.onDirectionTap(Direction.down);
      } else if (data == LogicalKeyboardKey.arrowLeft) {
        widget.onDirectionTap(Direction.left);
      } else if (data == LogicalKeyboardKey.arrowRight) {
        widget.onDirectionTap(Direction.right);
      }
    }
  }
}

class ControlBarPage extends StatefulWidget {
  const ControlBarPage({super.key});

  @override
  State<ControlBarPage> createState() => _ControlBarPageState();
}

class _ControlBarPageState extends State<ControlBarPage> {
  StringBuffer log = StringBuffer();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Control Bar'),
      ),
      body: ControlBarWrapper(
        onDirectionTap: (direction) {
          // Handle direction tap
          log.writeln('Direction tapped: $direction');
          setState(() {});
        },
        child: ListView(
          children: [
            Text(
              log.toString(),
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}

class HoleClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.addRect(Rect.fromLTWH(0, 0, size.width, size.height));

    final holeRadius = 0.12 * (size.width < size.height ? size.width : size.height);
    final center = Offset(size.width / 2, size.height / 2);
    final hole = Path()..addOval(Rect.fromCircle(center: center, radius: holeRadius));

    return Path.combine(PathOperation.difference, path, hole);
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}
