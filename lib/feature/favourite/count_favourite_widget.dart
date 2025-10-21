import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:isar_community/isar.dart';
import 'package:meow_app/feature/favourite/data/favourite_collection.dart';
import 'package:meow_app/resources/theme/theme_data.dart';

import '../../routers/route.dart';

class CountFavouriteWidget extends StatefulWidget {
  const CountFavouriteWidget({super.key});

  @override
  State<CountFavouriteWidget> createState() => _CountFavouriteWidgetState();
}

class _CountFavouriteWidgetState extends State<CountFavouriteWidget> with SingleTickerProviderStateMixin {
  late final ValueNotifier<int> _favouriteCountNotifier;
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;

  final Isar isar = Isar.getInstance()!;

  @override
  void initState() {
    super.initState();

    _favouriteCountNotifier = ValueNotifier(0);

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _scaleAnimation = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.2), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.2, end: 1.0), weight: 50),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    isar.favouriteCollections.watchLazy(fireImmediately: true).listen((_) async {
      final count = await isar.favouriteCollections.count();
      if (count != _favouriteCountNotifier.value && mounted) {
        _favouriteCountNotifier.value = count;
        _controller.forward(from: 0);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _favouriteCountNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ValueListenableBuilder<int>(
      valueListenable: _favouriteCountNotifier,
      builder: (context, count, _) {
        return AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: child,
            );
          },
          child: CircleAvatar(
            backgroundColor: theme.actionBackground,
            child: IconButton(
              onPressed: () {
                Navigator.of(context).pushNamed(RouteManager.favouritePage);
              },
              icon: Badge(
                isLabelVisible: count > 0,
                backgroundColor: theme.favoriteColor,
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                label: Text(
                  '$count',
                  style: theme.textTheme.bodySmall!.copyWith(
                    color: theme.iconColor,
                    fontSize: 10,
                  ),
                ),
                child: HugeIcon(
                  icon: HugeIcons.strokeRoundedFavourite,
                  color: theme.iconColor,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class CountFavouriteWidget2 extends StatefulWidget {
  const CountFavouriteWidget2({super.key});

  @override
  State<CountFavouriteWidget2> createState() => _CountFavouriteWidget2State();
}

class _CountFavouriteWidget2State extends State<CountFavouriteWidget2> with SingleTickerProviderStateMixin {
  late final ValueNotifier<int> _favouriteCountNotifier;
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;

  final Isar isar = Isar.getInstance()!;

  @override
  void initState() {
    super.initState();

    _favouriteCountNotifier = ValueNotifier(0);

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _scaleAnimation = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.2), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.2, end: 1.0), weight: 50),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    isar.favouriteCollections.watchLazy(fireImmediately: true).listen((_) async {
      final count = await isar.favouriteCollections.count();
      if (count != _favouriteCountNotifier.value && mounted) {
        _favouriteCountNotifier.value = count;
        _controller.forward(from: 0);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _favouriteCountNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ValueListenableBuilder<int>(
      valueListenable: _favouriteCountNotifier,
      builder: (context, count, _) {
        return AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: child,
            );
          },
          child: Badge(
            isLabelVisible: count > 0,
            backgroundColor: theme.favoriteColor,
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            label: Text(
              '$count',
              style: theme.textTheme.bodySmall!.copyWith(
                color: theme.iconColor,
                fontSize: 10,
              ),
            ),
            child: HugeIcon(
              icon: HugeIcons.strokeRoundedFavourite,
              color: theme.iconColor,
            ),
          ),
        );
      },
    );
  }
}
