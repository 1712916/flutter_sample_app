import 'dart:async';

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class FavouriteWrapper extends StatefulWidget {
  const FavouriteWrapper({
    super.key,
    required this.child,
    required this.onFavourite,
    this.iconSize = 300,
    this.animationDuration = const Duration(milliseconds: 1000),
    this.favouriteCooldown = const Duration(milliseconds: 600),
    this.lottieAsset = 'assets/animations/heart.json',
  });

  final Widget child;
  final VoidCallback onFavourite;
  final double iconSize;
  final Duration animationDuration;
  final Duration favouriteCooldown;
  final String lottieAsset;

  @override
  State<FavouriteWrapper> createState() => _FavouriteWrapperState();
}

class _FavouriteWrapperState extends State<FavouriteWrapper> {
  final ValueNotifier<Map<int, _HeartAnimation>> _hearts = ValueNotifier({});
  int _idCounter = 0;

  Timer? _favouriteCooldownTimer;
  bool _isInCooldown = false;

  void _onDoubleTap(TapDownDetails details) {
    final newHeart = _HeartAnimation(
      id: _idCounter++,
      position: details.localPosition,
    );

    _hearts.value = {
      ..._hearts.value,
      newHeart.id: newHeart,
    };

    if (!_isInCooldown) {
      widget.onFavourite();
      _startCooldown();
    }
  }

  void _startCooldown() {
    _isInCooldown = true;
    _favouriteCooldownTimer?.cancel();
    _favouriteCooldownTimer = Timer(widget.favouriteCooldown, () {
      _isInCooldown = false;
    });
  }

  @override
  void dispose() {
    _favouriteCooldownTimer?.cancel();
    _hearts.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onDoubleTapDown: _onDoubleTap,
      child: Stack(
        fit: StackFit.expand,
        children: [
          widget.child,
          ValueListenableBuilder<Map<int, _HeartAnimation>>(
            valueListenable: _hearts,
            builder: (context, heartMap, _) {
              return Stack(
                children: heartMap.entries.map((entry) {
                  final heart = entry.value;
                  return HeartAnimationWidget(
                    key: ValueKey(heart.id),
                    position: heart.position,
                    size: widget.iconSize,
                    lottieAsset: widget.lottieAsset,
                    duration: widget.animationDuration,
                    onCompleted: () {
                      final updated = {..._hearts.value}..remove(heart.id);
                      _hearts.value = updated;
                    },
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _HeartAnimation {
  final Offset position;
  final int id;

  _HeartAnimation({required this.position, required this.id});
}

class HeartAnimationWidget extends StatefulWidget {
  final Offset position;
  final double size;
  final String lottieAsset;
  final Duration duration;
  final VoidCallback onCompleted;

  const HeartAnimationWidget({
    super.key,
    required this.position,
    required this.size,
    required this.lottieAsset,
    required this.duration,
    required this.onCompleted,
  });

  @override
  State<HeartAnimationWidget> createState() => _HeartAnimationWidgetState();
}

class _HeartAnimationWidgetState extends State<HeartAnimationWidget> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;
  late final Animation<Offset> _offset;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _opacity = Tween<double>(begin: 1, end: 0.5).animate(_controller);
    _offset = Tween<Offset>(begin: Offset.zero, end: const Offset(0, -0.5)).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _controller.forward().whenComplete(() => widget.onCompleted());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: widget.position.dx - widget.size / 2,
      top: widget.position.dy - widget.size / 2,
      child: SlideTransition(
        position: _offset,
        child: FadeTransition(
          opacity: _opacity,
          child: SizedBox(
            width: widget.size,
            height: widget.size,
            child: Lottie.asset(widget.lottieAsset, repeat: false),
          ),
        ),
      ),
    );
  }
}
