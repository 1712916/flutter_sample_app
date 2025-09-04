import 'package:flutter/material.dart';
import 'package:meow_app/feature/chat/chat_page.dart';
import 'package:meow_app/feature/image/image_list_page.dart';
import 'package:meow_app/resources/theme/theme_data.dart';
import 'package:meow_app/widgets/widgets.dart';

import '../../routers/route.dart';

class DetailImagePage extends StatefulWidget {
  final String url;
  final String heroTag;

  const DetailImagePage({
    required this.url,
    required this.heroTag,
  });

  @override
  State<DetailImagePage> createState() => _DetailImagePageState();

  Future show(
    BuildContext context, {
    Duration duration = const Duration(milliseconds: 400),
    bool rootNavigator = true,
  }) {
    context.hideKeyboard();

    return Navigator.of(context, rootNavigator: rootNavigator).push(
      PageRouteBuilder(
        opaque: false,
        transitionDuration: duration,
        reverseTransitionDuration: const Duration(milliseconds: 200),
        pageBuilder: (_, __, ___) => this,
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }
}

class _DetailImagePageState extends State<DetailImagePage> with SingleTickerProviderStateMixin {
  Offset _offset = Offset.zero;
  late final AnimationController _controller;
  late Animation<Offset> _animation;
  bool _popped = false;

  /// Ngưỡng kéo để pop (0.0 → 1.0) = % màn hình
  final double popThreshold = 0.12;

  double get _dragPercent {
    final size = MediaQuery.of(context).size;
    final dy = _offset.dy.abs() / (size.height * popThreshold);
    final dx = _offset.dx.abs() / (size.width * popThreshold);
    return (dy > dx ? dy : dx).clamp(0.0, 1.0);
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 200));
  }

  void _handleDrag(DragUpdateDetails details) {
    setState(() {
      _offset += details.delta;
    });
  }

  void _handleDragEnd(DragEndDetails details) {
    final size = MediaQuery.of(context).size;
    final overVertical = _offset.dy.abs() > size.height * popThreshold;
    final overHorizontal = _offset.dx.abs() > size.width * popThreshold;

    if ((overVertical || overHorizontal) && !_popped) {
      _popped = true;
      Navigator.of(context).pop();
    } else {
      _animateBack();
    }
  }

  void _animateBack() {
    _animation = Tween<Offset>(
      begin: _offset,
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut))
      ..addListener(() {
        setState(() {
          _offset = _animation.value;
        });
      });

    _controller.forward(from: 0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onPanUpdate: _handleDrag,
        onPanEnd: _handleDragEnd,
        onTap: () => Navigator.of(context).pop(),
        child: ColoredBox(
          color: Colors.black.withOpacity(1 - _dragPercent * 0.3),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Transform.translate(
                offset: _offset,
                child: Center(
                  child: Hero(
                    tag: widget.heroTag,
                    child: AppImage(
                      image: widget.url,
                    ),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.topCenter,
                child: SafeArea(
                  child: SizedBox(
                    height: 56,
                    child: AppBar(
                      backgroundColor: Colors.transparent,
                      leading: Center(
                        child: CircleAvatar(
                          backgroundColor: theme.actionBackground,
                          child: IconButton(
                            onPressed: () => Navigator.of(context).pop(),
                            icon: Icon(
                              Icons.close,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      actions: [
                        PopupMenuButton<String>(
                          color: theme.actionBackground,
                          offset: const Offset(0, 56),
                          onSelected: (String value) {
                            final url = widget.url;
                            if (value == 'share') {
                              // Handle share action
                              // Example: Share.share('Check out this game!');
                              ShareWidget(
                                url: url,
                                onDelete: null,
                              ).show(context);
                            } else if (value == 'play') {
                              // Handle play game action
                              // Example: Navigator.push(context, MaterialPageRoute(builder: (context) => GameScreen()));
                              goToCropImageView(url);
                            }
                          },
                          itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                            const PopupMenuItem<String>(
                              value: 'share',
                              child: LText(LKey.share),
                            ),
                            const PopupMenuItem<String>(
                              value: 'play',
                              child: LText(LKey.playGame),
                            ),
                          ],
                          icon: Icon(
                            Icons.more_vert_rounded,
                            color: Colors.white,
                          ),
                        ),
                      ],
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
